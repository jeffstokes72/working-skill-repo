# Skill Eval Baselines

Baseline reports are selected JSON outputs from
`scripts/skill-eval-regression-report.ps1`. Keep only useful comparison points,
such as the last accepted live corpus before a major skill-routing change.

Live run directories stay under `.atv/eval-runs/` and are ignored. A baseline is
checked in only when it is intentionally useful for regression comparison.
