# Go Validator Full Replacement Slice Matrix

This file is the per-slice planning companion for
`2026-06-01-130-kb-go-validator-full-replacement-manifest.md`.

Each slice replaces exactly one remaining `.ps1` script or deletes one
PowerShell-only support script after all callers are gone. The test is part of
the slice acceptance criteria, not a later cleanup task.

| Slice | Legacy script | Replacement | Required test/proof |
|---|---|---|---|
| slice-131 | `skill-lint.ps1` | `kbcheck skill-lint` | valid repo passes; temp bad frontmatter/conflict/line-budget fixture fails |
| slice-132 | `skill-sync-report.ps1` | `kbcheck skill-sync-report` | temp roots prove match, required drift fail, optional drift warning |
| slice-133 | `skill-marketplace-firebreak.ps1` | `kbcheck marketplace firebreak` | valid config passes; quarantine active root fails |
| slice-134 | `skill-marketplace-firebreak-selftest.ps1` | `kbcheck marketplace-firebreak-selftest` | native selftest passes without PowerShell |
| slice-135 | `skill-surface-report.ps1` | `kbcheck surface-report` | route surface JSON snapshot and baseline compare pass/fail |
| slice-136 | `skill-surface-minimality.ps1` | `kbcheck minimality` | protected skills stay protected; evidence classes emitted |
| slice-137 | `skill-surface-minimality-selftest.ps1` | `kbcheck minimality-selftest` | native selftest passes without PowerShell |
| slice-138 | `cross-model-benchmark-validate.ps1` | `kbcheck benchmark-validate` | benchmark fixtures validate; malformed fixture fails |
| slice-139 | `route-complexity-eval.ps1` | `kbcheck route-eval` | current fixtures pass; wrong route/tier fixture fails |
| slice-140 | `skill-eval.ps1` | `kbcheck skill-eval` | current pass/fail result fixtures behave identically |
| slice-141 | `skill-eval-claims.ps1` | `kbcheck skill-eval-claims` | true/false/ambiguous claim artifacts classify correctly |
| slice-142 | `skill-eval-quality.ps1` | `kbcheck skill-eval-quality` | computed quality fixtures pass/fail; hand-authored quality fails |
| slice-143 | `skill-eval-regression-report.ps1` | `kbcheck skill-eval-regression` | unchanged baseline passes; proof regression fails |
| slice-144 | `skill-eval-manifest-selftest.ps1` | `kbcheck skill-eval-manifest-selftest` | valid manifest passes; tampered SHA fails |
| slice-145 | `skill-eval-baseline-selftest.ps1` | `kbcheck skill-eval-baseline-selftest` | unchanged compare passes; negative fixture regression fails |
| slice-146 | `skill-eval-wrap.ps1` | `kbcheck skill-eval-wrap` | dry-run observed trace captured; sealed forbidden write fails |
| slice-147 | `skill-eval-run-codex.ps1` | `kbcheck eval-run-codex` | dry-run creates schema-valid result and protected hash manifest |
| slice-148 | `skill-eval-run-ghcp.ps1` | `kbcheck eval-run-ghcp` | dry-run creates schema-valid result and protected hash manifest |
| slice-149 | `skill-eval-run-live-corpus.ps1` | `kbcheck eval-run-live-corpus` | dry-run dispatches Codex/GHCP adapters; live stays explicit |
| slice-150 | `kb-release-gate-selftest.ps1` | `kbcheck release-selftest` | local/live profile labeling and required failure propagation pass |
| slice-151 | `kb-pipeline.ps1` | `kbcheck pipeline start/status` | start writes run metadata; status reads latest; unknown ID fails |
| slice-152 | `kb-pipeline-selftest.ps1` | `kbcheck pipeline-selftest` | native selftest passes without PowerShell |
| slice-153 | `promote-marketplace-skill.ps1` | `kbcheck marketplace promote` | happy path hash-pins/copies; quarantine destination refused |
| slice-154 | `promote-marketplace-skill-selftest.ps1` | `kbcheck marketplace-promote-selftest` | native selftest passes without PowerShell |
| slice-155 | `atv-upstream-delta.ps1` | `kbcheck atv-delta` | fixture repo classifies KB-owned/shared/ATV-native/superseded rows |
| slice-156 | `atv-upstream-delta-selftest.ps1` | `kbcheck atv-delta-selftest` | native selftest passes without PowerShell |
| slice-157 | `go-ps1-parity-report.ps1` | delete after Go suite owns default gate | no default PS gate dependency; `local-release` passes |
| slice-158 | `powershell-helpers.ps1` | delete after all callers are gone | `rg "powershell-helpers"` has no script callers; `local-release` passes |

## Shared Acceptance Criteria

- The Go replacement has a command or native `Check.Run` hook.
- The default `core`/`local-release` gate does not call the deleted script.
- The legacy `.ps1` is deleted in the same slice unless the slice explicitly
  parks deletion because a live external adapter still needs a compatibility
  window.
- `go test ./...` passes.
- `go run ./cmd/kbcheck local-release --json` passes.
