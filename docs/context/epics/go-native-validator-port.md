# Go Native Validator Port

Status: active
Created: 2026-06-01
Last refreshed: 2026-06-01

## Intent

Remove the permanent Go-plus-PowerShell duplicate harness. `cmd/kbcheck` should
own the normal local validation suite natively in Go. PowerShell scripts may
exist only as migration surfaces until the corresponding Go command/selftest has
parity proof, then the `.ps1` is deleted or demoted out of the default gate.

## Success Criteria

- `go run ./cmd/kbcheck local-release` passes without requiring PowerShell for
  the normal local suite.
- Every removed `.ps1` has a Go command or Go selftest proving the same
  behavior.
- Docs identify any remaining PowerShell script as explicit legacy, live-adapter,
  or parked migration work.
- No validator remains permanently implemented twice.

## Architecture Decisions

- Port small deterministic validators first.
- Prefer `cmd/kbcheck` subcommands and native `Check.Run` hooks over shelling to
  scripts.
- Delete legacy `.ps1` files once Go parity lands for that validator.
- Keep live model adapters for last; they are higher risk because they interact
  with external CLIs and captured run artifacts.

## Workstreams

| Workstream | Brainstorm | Manifest | Status | Notes |
|---|---|---|---|---|
| Swarm proof utilities | skipped-clear | `docs/plans/2026-06-01-120-kb-go-validator-port-wave-1-manifest.md` | done | Ported ready-set and scope-lease checks to native Go; removed four `.ps1` files. |
| Full PowerShell replacement matrix | skipped-clear | `docs/plans/2026-06-01-130-kb-go-validator-full-replacement-manifest.md` | planned | One pending slice per remaining `.ps1`, each with a Go target and required test/proof. |
| Deterministic static reports | skipped-clear | `docs/plans/2026-06-01-130-kb-go-validator-full-replacement-manifest.md` | queued | `skill-lint`, `skill-sync-report`, marketplace firebreak, surface/minimality reports. |
| Eval scorers and regression | skipped-clear | `docs/plans/2026-06-01-130-kb-go-validator-full-replacement-manifest.md` | queued | `route-complexity-eval`, `skill-eval`, `skill-eval-quality`, baseline/regression/claims. |
| Pipeline and promotion tools | skipped-clear | `docs/plans/2026-06-01-130-kb-go-validator-full-replacement-manifest.md` | queued | `kb-pipeline`, marketplace promotion, upstream delta. |
| Live model adapters | skipped-clear | `docs/plans/2026-06-01-130-kb-go-validator-full-replacement-manifest.md` | queued-last | Codex/GHCP runners, live corpus, observed trace wrapper. |

## Dependency Map

1. Prove Go command behavior.
2. Wire native command into `cmd/kbcheck core` or release gate.
3. Delete the corresponding `.ps1`.
4. Update docs and memory.
5. Run `go run ./cmd/kbcheck local-release`.

## Human Checkpoints

None for wave 1. Future live-adapter ports may need human confirmation before
deleting PowerShell because live CLIs and auth behavior are more failure-prone.

## Parked / Blocked

- macOS/Linux proof remains parked until those environments are available.
- Live adapter ports run last because they interact with external CLIs and
  captured run artifacts.

## Full Replacement Slice Matrix

Every remaining `.ps1` gets a named slice. A slice is done only when the Go
replacement is wired, the legacy script is deleted or demoted out of the
default gate, and the listed proof passes.

| Slice | Legacy script | Go replacement target | Required proof |
|---|---|---|---|
| 131 | `skill-lint.ps1` | `kbcheck skill-lint` + Go tests | valid repo passes; temp bad frontmatter/conflict/line-budget fixture fails |
| 132 | `skill-sync-report.ps1` | `kbcheck skill-sync-report` | temp roots prove match, required drift fail, optional drift warning |
| 133 | `skill-marketplace-firebreak.ps1` | `kbcheck marketplace firebreak` | valid config passes; quarantine active root fails |
| 134 | `skill-marketplace-firebreak-selftest.ps1` | `kbcheck marketplace-firebreak-selftest` | native selftest passes without PowerShell |
| 135 | `skill-surface-report.ps1` | `kbcheck surface-report` | route surface JSON snapshot and baseline compare pass/fail |
| 136 | `skill-surface-minimality.ps1` | `kbcheck minimality` | protected skills stay protected; evidence classes emitted |
| 137 | `skill-surface-minimality-selftest.ps1` | `kbcheck minimality-selftest` | native selftest passes without PowerShell |
| 138 | `cross-model-benchmark-validate.ps1` | `kbcheck benchmark-validate` | benchmark fixtures validate; malformed fixture fails |
| 139 | `route-complexity-eval.ps1` | `kbcheck route-eval` | current route fixtures pass; wrong route/tier fixture fails |
| 140 | `skill-eval.ps1` | `kbcheck skill-eval` | current selftest pass/fail result fixtures behave identically |
| 141 | `skill-eval-claims.ps1` | `kbcheck skill-eval-claims` | true/false/ambiguous claim artifacts classify correctly |
| 142 | `skill-eval-quality.ps1` | `kbcheck skill-eval-quality` | computed quality fixtures pass/fail; hand-authored quality fails |
| 143 | `skill-eval-regression-report.ps1` | `kbcheck skill-eval-regression` | unchanged baseline passes; proof regression fails |
| 144 | `skill-eval-manifest-selftest.ps1` | `kbcheck skill-eval-manifest-selftest` | valid manifest passes; tampered SHA fails |
| 145 | `skill-eval-baseline-selftest.ps1` | `kbcheck skill-eval-baseline-selftest` | unchanged compare passes; negative fixture regression fails |
| 146 | `skill-eval-wrap.ps1` | `kbcheck skill-eval-wrap` | dry-run observed trace captured; sealed forbidden write fails |
| 147 | `skill-eval-run-codex.ps1` | `kbcheck eval-run-codex` | dry-run creates schema-valid result and protected hash manifest |
| 148 | `skill-eval-run-ghcp.ps1` | `kbcheck eval-run-ghcp` | dry-run creates schema-valid result and protected hash manifest |
| 149 | `skill-eval-run-live-corpus.ps1` | `kbcheck eval-run-live-corpus` | dry-run dispatches Codex/GHCP adapters; live stays explicit |
| 150 | `kb-release-gate-selftest.ps1` | `kbcheck release-selftest` | local/live profile labeling and required failure propagation pass |
| 151 | `kb-pipeline.ps1` | `kbcheck pipeline start/status` | start writes run metadata; status reads latest; unknown ID fails |
| 152 | `kb-pipeline-selftest.ps1` | `kbcheck pipeline-selftest` | native selftest passes without PowerShell |
| 153 | `promote-marketplace-skill.ps1` | `kbcheck marketplace promote` | happy path hash-pins/copies; quarantine destination refused |
| 154 | `promote-marketplace-skill-selftest.ps1` | `kbcheck marketplace-promote-selftest` | native selftest passes without PowerShell |
| 155 | `atv-upstream-delta.ps1` | `kbcheck atv-delta` | fixture repo classifies KB-owned/shared/ATV-native/superseded rows |
| 156 | `atv-upstream-delta-selftest.ps1` | `kbcheck atv-delta-selftest` | native selftest passes without PowerShell |
| 157 | `go-ps1-parity-report.ps1` | delete after Go suite owns default gate | `rg` shows no default PS gate dependency; `local-release` passes |
| 158 | `powershell-helpers.ps1` | delete after all callers are gone | `rg "powershell-helpers"` returns no script callers |

## Completion Criteria

Epic is complete when the normal local release gate no longer depends on
PowerShell and all remaining `.ps1` files are either deleted, outside default
gates, or explicitly classified as live/legacy with a follow-up owner.
