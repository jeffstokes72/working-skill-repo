# CLI Agent-Readiness Reviewer Merge

Date: 2026-06-10

## Decision

Merge `cli-agent-readiness-reviewer` into `cli-readiness-reviewer` and delete
only the approved trim candidate.

## Human Approval

The user explicitly approved this one deletion/merge. No other cold-storage
candidate is approved by this decision.

## Merge Result

Unique useful content folded into `cli-readiness-reviewer`:

- CLI plans/specs can be reviewed as design gaps.
- Findings should cite framework-idiomatic fixes.
- Framework calibration for Click, argparse, Cobra, clap, Commander/yargs/oclif,
  and Thor.
- Each finding should include a practical check or test purpose.

## Minimality Proof

Before:

```text
Skills: 38; agents: 52; cold-storage candidates: 12
conditional: 39
protected: 5
required: 34
trim-candidate: 1
unproven: 11
trim-candidate [agent] cli-agent-readiness-reviewer
```

After:

```text
Skills: 38; agents: 51; cold-storage candidates: 11
conditional: 39
protected: 5
required: 34
unproven: 11
```

Remaining unproven agents stay parked.
