# Skill Eval Results

This directory contains deterministic scoring fixtures for skill behavior.

The runner does not call a model. It scores captured agent results against the
route-complexity dataset:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\skill-eval.ps1
```

Default mode is a self-test under `evals/skill-eval/selftest/`. The self-test
contains one valid result and several intentionally bad results. The runner must
pass the good result and fail the bad ones; otherwise the scorer is too weak.

For real captured runs, write a result JSON and pass it explicitly:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\skill-eval.ps1 -ResultPath path\to\captured-result.json
```

## Result Shape

```json
{
  "id": "run-id",
  "fixture_id": "tiny-typo-fix",
  "expected_result": "pass",
  "actual": {
    "route": "kb-fix",
    "user_questions": 0,
    "artifacts": ["changed file", "verification note"],
    "proof": ["git diff --check", "targeted text/render check if UI-visible"]
  },
  "trace": {
    "files_read": ["todo.md"],
    "commands": ["git diff --check"],
    "tools": ["shell"]
  },
  "claim_checks": [
    {
      "type": "command_ran",
      "path": "",
      "contains": "git diff --check",
      "expected": true,
      "claim": "Agent claimed git diff --check was run"
    }
  ]
}
```

Supported claim checks:

- `file_exists`
- `command_ran`
- `file_read`

Optional `trace_rules` fields make trace discipline deterministic when a fixture
or captured result needs stronger proof than route/proof strings alone:

```json
{
  "trace_rules": {
    "required_files_read": ["docs/context/eval-map.md"],
    "required_commands": ["git diff --check"],
    "required_tools": ["shell"],
    "forbidden_files_read": ["secrets.env"],
    "forbidden_commands": ["git reset --hard"],
    "forbidden_tools": ["browser"]
  }
}
```

Required rules pass when any trace item contains the expected text after
case-insensitive whitespace normalization. Forbidden rules fail when any trace
item contains the forbidden text. These are scorer-only rules; live adapter JSON
schemas do not need to include them unless a future adapter wants the model to
emit them directly.

## Claim Artifact Verifier

Transcript-derived claim checks live outside the model transcript as JSON claim
artifacts:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\skill-eval-claims.ps1
```

Supported deterministic claim types match structured result claim checks:
`file_exists`, `command_ran`, and `file_read`. A claim with
`"type": "ambiguous"` is reported with an ambiguous count and does not become
proof. False deterministic claims fail; ambiguous claims are visible but do not
fail by themselves.

`scripts/skill-eval.ps1` also checks any result-level `claim_artifacts` array by
running each artifact through `scripts/skill-eval-claims.ps1`.

Live adapters produce this result shape from transcripts/traces, then let this
deterministic scorer decide pass/fail. Codex and GHCP adapters exist; live model
runs are explicit because they require runtime auth and spend.

## Codex Adapter

Run the Codex adapter in safe dry-run mode:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\skill-eval-run-codex.ps1 -FixtureId tiny-typo-fix -DryRun
```

Run one live Codex eval:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\skill-eval-run-codex.ps1 -FixtureId tiny-typo-fix -KeepRun
```

The live adapter creates a disposable git worktree under `.atv/eval-runs/`, runs
`codex exec` in read-only mode with a JSON output schema, writes `result.json`,
then calls `scripts/skill-eval.ps1 -ResultPath <result.json>`.

Dry-run mode is part of `kb-check -All`; live mode is explicit because it calls a
model.

## GHCP Adapter

Run the GHCP adapter in safe dry-run mode:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\skill-eval-run-ghcp.ps1 -FixtureId tiny-typo-fix -DryRun
```

Run one live GHCP eval:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\skill-eval-run-ghcp.ps1 -FixtureId tiny-typo-fix -KeepRun
```

The GHCP adapter creates a disposable git worktree under `.atv/eval-runs/`, runs
GitHub Copilot CLI non-interactively, captures stdout/stderr plus a transcript
artifact when available, parses strict JSON from the final response, writes
`result.json`, then calls `scripts/skill-eval.ps1 -ResultPath <result.json>`.

GHCP does not expose a Codex-style `--output-schema` flag in the currently
observed local CLI help, so this adapter uses prompt-level JSON constraints and
deterministic parsing. Invalid or missing JSON is a hard adapter failure, not a
pass.

## Live Corpus Runner

Run both adapters in dry-run mode:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\skill-eval-run-live-corpus.ps1 -All -Runtime codex,ghcp -DryRun
```

Run one explicit live cross-runtime fixture:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\skill-eval-run-live-corpus.ps1 -FixtureId tiny-typo-fix -Runtime codex,ghcp
```

The corpus runner writes `summary.json` and `summary.md` under
`.atv/eval-runs/<timestamp>-live-corpus*/`. Result statuses distinguish pass,
adapter-missing, adapter-failed, invalid-json, score-failed, and
runtime-unavailable. Live corpus runs are never part of the default
`kb-check -All` gate.
