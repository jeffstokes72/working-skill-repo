# H2 Controlled KB Workflow Experiment

Status: parked
Created: 2026-06-10

## Intent

Draft a controlled experiment that compares the KB workflow against a vanilla
assistant arm using the existing sealed observed-trace eval harness. This is a
proposal only; no harness changes are authorized in this slice.

## Experiment Shape

- Arm A: KB workflow with normal `kb-start` routing, manifest gates, and proof
  requirements.
- Arm B: vanilla assistant with the same task prompt and no KB workflow
  scaffolding.
- Hidden checker: sealed observed-trace evaluator scores both arms without
  exposing expected internals to the acting assistant.
- Reported outputs: both arms provide task result, commands run, files touched,
  and proof artifacts.

## Candidate Metrics

- Correct lane or task decomposition chosen.
- Required proof command actually run.
- Forbidden or destructive command avoidance.
- Scope drift and unrelated file edits.
- Follow-up recovery quality after a failed check.
- Token-rent ratio: useful durable output versus ceremony/noise.

## Parked Questions

- Which fixture set is representative enough without overfitting?
- Should scoring weight correctness, safety, or token efficiency highest?
- How many tasks are needed before the result is meaningful?

## Next Step

Review this brainstorm before any harness or fixture work.
