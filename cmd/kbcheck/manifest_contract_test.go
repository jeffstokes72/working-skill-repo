package main

import (
	"path/filepath"
	"strings"
	"testing"
)

func TestManifestContractRequiresDoneGate(t *testing.T) {
	path := writeManifest(t, `
---
slices:
  - id: slice-001
    status: done
gate_ledger: []
---
`)
	result, err := validateManifestContract(path)
	if err != nil {
		t.Fatalf("validateManifestContract returned error: %v", err)
	}
	if result.OK || !hasManifestIssue(result.Issues, "missing-terminal-gate") {
		t.Fatalf("expected missing terminal gate issue, got %#v", result)
	}
}

func TestManifestContractRejectsBadPassedGate(t *testing.T) {
	path := writeManifest(t, `
---
slices:
  - id: slice-001
    status: done
gate_ledger:
  - gate_id: slice-slice-001-to-done
    status: passed
    required_evidence:
      - "proof required"
    proof: []
    blockers:
      - "still blocked"
    passed_at: ""
---
`)
	result, err := validateManifestContract(path)
	if err != nil {
		t.Fatalf("validateManifestContract returned error: %v", err)
	}
	if result.OK || !hasManifestIssue(result.Issues, "insufficient-proof") || !hasManifestIssue(result.Issues, "blocked-advanceable-gate") {
		t.Fatalf("expected proof and blocker issues, got %#v", result)
	}
}

func TestManifestContractPassesValidDoneAndParkedGates(t *testing.T) {
	proof := filepath.Join(t.TempDir(), "proof.md")
	writeFile(t, proof, "# proof\n")
	path := writeManifest(t, `
---
slices:
  - id: slice-001
    status: done
  - id: slice-002
    status: parked
gate_ledger:
  - gate_id: slice-slice-001-to-done
    status: passed
    required_evidence:
      - "proof exists"
    proof:
      - "`+filepath.ToSlash(proof)+`"
    blockers: []
    passed_at: "2026-06-10"
  - gate_id: slice-slice-002-to-parked
    status: parked
    required_evidence:
      - "parked proof exists"
    proof:
      - "todo.md"
    blockers: []
    passed_at: "2026-06-10"
---
`)
	result, err := validateManifestContract(path)
	if err != nil {
		t.Fatalf("validateManifestContract returned error: %v", err)
	}
	if !result.OK {
		t.Fatalf("expected valid manifest, got %#v", result)
	}
}

func TestGateLedgerCommandValidatesAllowedNext(t *testing.T) {
	path := writeManifest(t, `
---
slices:
  - id: slice-001
    status: done
gate_ledger:
  - gate_id: slice-slice-001-to-done
    status: passed
    required_evidence: []
    proof: []
    blockers: []
    passed_at: "2026-06-10"
    allowed_next_action: "kb-complete"
---
`)
	var out, errOut strings.Builder
	code := run([]string{"gate-ledger", "--manifest", path, "--gate", "slice-slice-001-to-done", "--allowed-next", "kb-complete"}, &out, &errOut)
	if code != 0 {
		t.Fatalf("gate-ledger command failed: code=%d stderr=%s", code, errOut.String())
	}
	if !strings.Contains(out.String(), "PASS: gate=slice-slice-001-to-done") {
		t.Fatalf("missing pass output: %s", out.String())
	}
}
