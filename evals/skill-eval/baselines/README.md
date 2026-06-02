# Skill Eval Baselines

Baseline reports are selected JSON outputs from
`go run .\cmd\kbcheck skill-eval-regression`. Keep only useful comparison points,
such as the last accepted live corpus before a major skill-routing change.

Live run directories stay under `.atv/eval-runs/` and are ignored. A baseline is
checked in only when it is intentionally useful for regression comparison.

`go run .\cmd\kbcheck skill-eval` can also persist and enforce deterministic scoring
baselines:

```powershell
go run .\cmd\kbcheck skill-eval --baseline evals/skill-eval/baselines/selftest.json --update-baseline
go run .\cmd\kbcheck skill-eval --baseline evals/skill-eval/baselines/selftest.json
```

Baseline comparison fails when a baseline row disappears, a passing result
starts failing, or issue counts increase. Intentional baseline changes must use
`--update-baseline`.
