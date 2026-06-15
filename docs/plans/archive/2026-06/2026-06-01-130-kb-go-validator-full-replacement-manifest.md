---
type: kb-manifest
kb_id: kb-2026-06-01-go-validator-full-replacement
brainstorm_path: skipped-clear
created: 2026-06-01
status: pending
workflow_shape: "pipeline-change"
slices:
  - id: slice-131
    title: "Port skill-lint to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck skill-lint. Test: valid repo passes; bad frontmatter/conflict/line-budget fixtures fail. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/checks.go, cmd/kbcheck/skill_validators.go, cmd/kbcheck/skill_validators_test.go, scripts/skill-lint.ps1. proof: go test ./cmd/kbcheck; go run .\\cmd\\kbcheck skill-lint --json."
  - id: slice-132
    title: "Port skill-sync-report to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck skill-sync-report. Test: temp roots prove match, required drift fail, optional drift warning. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/checks.go, cmd/kbcheck/skill_validators.go, cmd/kbcheck/skill_validators_test.go, scripts/skill-sync-report.ps1. proof: go test ./cmd/kbcheck; go run .\\cmd\\kbcheck skill-sync-report --json."
  - id: slice-133
    title: "Port marketplace firebreak to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck marketplace-firebreak. Test: valid config passes; quarantine active root fails. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/checks.go, cmd/kbcheck/skill_validators.go, cmd/kbcheck/skill_validators_test.go, scripts/skill-marketplace-firebreak.ps1. proof: go test ./cmd/kbcheck; go run .\\cmd\\kbcheck marketplace-firebreak-selftest."
  - id: slice-134
    title: "Replace marketplace firebreak selftest"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-133]
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck marketplace-firebreak-selftest. Test: native selftest passes without PowerShell. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/skill_validators.go, scripts/skill-marketplace-firebreak-selftest.ps1. proof: go run .\\cmd\\kbcheck marketplace-firebreak-selftest."
  - id: slice-135
    title: "Port skill-surface-report to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck surface-report. Test: route surface JSON snapshot and baseline compare pass/fail. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/checks.go, cmd/kbcheck/report_validators.go, scripts/skill-surface-report.ps1. proof: go test ./cmd/kbcheck; go run .\\cmd\\kbcheck surface-report --json."
  - id: slice-136
    title: "Port skill-surface-minimality to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck minimality. Test: protected skills stay protected; evidence classes emitted. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/checks.go, cmd/kbcheck/minimality.go, scripts/skill-surface-minimality.ps1. proof: go test ./cmd/kbcheck; go run .\\cmd\\kbcheck minimality --json."
  - id: slice-137
    title: "Replace minimality selftest"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-136]
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck minimality-selftest. Test: native selftest passes without PowerShell. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/minimality.go, scripts/skill-surface-minimality-selftest.ps1. proof: go run .\\cmd\\kbcheck minimality-selftest."
  - id: slice-138
    title: "Port cross-model benchmark validation to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck benchmark-validate. Test: benchmark fixtures validate; malformed fixture fails. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/checks.go, cmd/kbcheck/report_validators.go, scripts/cross-model-benchmark-validate.ps1. proof: go test ./cmd/kbcheck; go run .\\cmd\\kbcheck benchmark-validate --json."
  - id: slice-139
    title: "Port route-complexity eval to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck route-eval. Test: current fixtures pass; wrong route/tier fixture fails. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/checks.go, cmd/kbcheck/report_validators.go, scripts/route-complexity-eval.ps1. proof: go test ./cmd/kbcheck; go run .\\cmd\\kbcheck route-eval --json."
  - id: slice-140
    title: "Port skill-eval scorer to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: broad
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck skill-eval. Test: current pass/fail result fixtures behave identically. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/checks.go, cmd/kbcheck/skill_eval.go, scripts/skill-eval.ps1. proof: go test ./cmd/kbcheck; go run .\\cmd\\kbcheck skill-eval --json."
  - id: slice-141
    title: "Port skill-eval claim scorer to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-140]
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck skill-eval-claims. Test: true/false/ambiguous claim artifacts classify correctly. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/skill_eval.go, scripts/skill-eval-claims.ps1. proof: go run .\\cmd\\kbcheck skill-eval-claims --json."
  - id: slice-142
    title: "Port skill-eval quality scorer to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck skill-eval-quality. Test: computed quality fixtures pass/fail; hand-authored quality fails. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/checks.go, cmd/kbcheck/skill_eval.go, scripts/skill-eval-quality.ps1. proof: go run .\\cmd\\kbcheck skill-eval-quality --json."
  - id: slice-143
    title: "Port skill-eval regression report to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-140]
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck skill-eval-regression. Test: unchanged baseline passes; proof regression fails. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/skill_eval.go, scripts/skill-eval-regression-report.ps1. proof: go run .\\cmd\\kbcheck skill-eval-regression --run-root .atv\\eval-runs --json."
  - id: slice-144
    title: "Replace skill-eval manifest selftest"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-140]
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck skill-eval-manifest-selftest. Test: valid manifest passes; tampered SHA fails. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/skill_eval.go, cmd/kbcheck/eval_adapters.go, scripts/skill-eval-manifest-selftest.ps1. proof: go run .\\cmd\\kbcheck skill-eval-manifest-selftest."
  - id: slice-145
    title: "Replace skill-eval baseline selftest"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-143]
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck skill-eval-baseline-selftest. Test: unchanged compare passes; negative fixture regression fails. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/skill_eval.go, scripts/skill-eval-baseline-selftest.ps1. proof: go run .\\cmd\\kbcheck skill-eval-baseline-selftest."
  - id: slice-146
    title: "Port observed trace wrapper to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-140]
    verification: integration
    test_level: functional-cli
    functional_risk: broad
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck skill-eval-wrap. Test: dry-run observed trace captured; sealed forbidden write fails. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/checks.go, cmd/kbcheck/eval_adapters.go, scripts/skill-eval-wrap.ps1. proof: go run .\\cmd\\kbcheck skill-eval-wrap --fixture-id tiny-typo-fix --dry-run --sealed --json."
  - id: slice-147
    title: "Port Codex eval adapter to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-140]
    verification: integration
    test_level: functional-cli
    functional_risk: broad
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck eval-run-codex. Test: dry-run creates schema-valid result and protected hash manifest. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/checks.go, cmd/kbcheck/eval_adapters.go, scripts/skill-eval-run-codex.ps1. proof: go run .\\cmd\\kbcheck eval-run-codex --fixture-id tiny-typo-fix --dry-run --keep-run --json."
  - id: slice-148
    title: "Port GHCP eval adapter to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-140]
    verification: integration
    test_level: functional-cli
    functional_risk: broad
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck eval-run-ghcp. Test: dry-run creates schema-valid result and protected hash manifest. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/checks.go, cmd/kbcheck/eval_adapters.go, scripts/skill-eval-run-ghcp.ps1. proof: go run .\\cmd\\kbcheck eval-run-ghcp --fixture-id tiny-typo-fix --dry-run --keep-run --json."
  - id: slice-149
    title: "Port live corpus runner to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-147, slice-148]
    verification: integration
    test_level: functional-cli
    functional_risk: broad
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck eval-run-live-corpus. Test: dry-run dispatches Codex/GHCP adapters; live stays explicit. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/eval_adapters.go, scripts/skill-eval-run-live-corpus.ps1. proof: go run .\\cmd\\kbcheck eval-run-live-corpus --dry-run --json."
  - id: slice-150
    title: "Replace release gate selftest"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck release-selftest. Test: local/live profile labeling and required failure propagation pass. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/release.go, cmd/kbcheck/release_test.go, cmd/kbcheck/report_validators.go, scripts/kb-release-gate-selftest.ps1. proof: go test ./cmd/kbcheck; go run .\\cmd\\kbcheck release-selftest."
  - id: slice-151
    title: "Port KB pipeline tool to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck pipeline start/status. Test: start writes run metadata; status reads latest; unknown ID fails. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/checks.go, cmd/kbcheck/report_validators.go, scripts/kb-pipeline.ps1. proof: go test ./cmd/kbcheck; go run .\\cmd\\kbcheck pipeline-selftest."
  - id: slice-152
    title: "Replace KB pipeline selftest"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-151]
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck pipeline-selftest. Test: native selftest passes without PowerShell. scope-check: cmd/kbcheck/main.go, cmd/kbcheck/report_validators.go, scripts/kb-pipeline-selftest.ps1. proof: go run .\\cmd\\kbcheck pipeline-selftest."
  - id: slice-153
    title: "Port marketplace promotion tool to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-133]
    verification: integration
    test_level: functional-cli
    functional_risk: broad
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck marketplace-promote. Proof: marketplace-promote-selftest passed; promotion refuses missing --approved and quarantine destinations."
  - id: slice-154
    title: "Replace marketplace promotion selftest"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-153]
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck marketplace-promote-selftest. Proof: native selftest passed without PowerShell."
  - id: slice-155
    title: "Port ATV upstream delta to Go"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: []
    verification: integration
    test_level: functional-cli
    functional_risk: medium
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck atv-delta. Proof: atv-delta-selftest fixture repo classified KB-owned/shared/ATV-native/superseded rows."
  - id: slice-156
    title: "Replace ATV upstream delta selftest"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-155]
    verification: integration
    test_level: functional-cli
    functional_risk: narrow
    hitl: false
    status: done
    can_continue_other_slices: true
    notes: "Go target: kbcheck atv-delta-selftest. Proof: native selftest passed without PowerShell."
  - id: slice-157
    title: "Remove PS parity report script"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-131, slice-132, slice-133, slice-135, slice-136, slice-138, slice-139, slice-140, slice-142, slice-150, slice-151, slice-153, slice-155]
    verification: integration
    test_level: functional-cli
    functional_risk: broad
    hitl: false
    status: done
    can_continue_other_slices: false
    notes: "Deleted scripts/go-ps1-parity-report.ps1 after Go suite owned default gate. Proof pending final local-release."
  - id: slice-158
    title: "Remove PowerShell helper script"
    path: docs/plans/archive/2026-06/2026-06-01-130-kb-go-validator-full-replacement-slice-matrix.md
    blockers: [slice-134, slice-137, slice-144, slice-145, slice-146, slice-147, slice-148, slice-149, slice-152, slice-154, slice-156, slice-157]
    verification: integration
    test_level: functional-cli
    functional_risk: broad
    hitl: false
    status: done
    can_continue_other_slices: false
    notes: "Deleted scripts/powershell-helpers.ps1 after all script callers were removed. Proof: rg --files -g '*.ps1' returned no files; final local-release pending."
---

# KB: Go Validator Full Replacement

## Origin

User direction: replace PowerShell rather than maintaining Go and PowerShell in
parallel. Every remaining `.ps1` gets its own slice and an explicit test.

## Execution Notes

- Do not port all slices in one commit.
- Prefer ready-set swarming for independent deterministic validators.
- Delete a legacy `.ps1` in the same slice that proves its Go replacement.
- Live adapter slices run after scorer and wrapper primitives are native.
- `slice-157` and `slice-158` are final cleanup gates, not early work.
