# ATV-Phoenix Self-Heal Comparison

Checked: 2026-07-05
Budget mode: standard

## Question

Should KB replace its learning/self-healing loop with ATV-Phoenix, or merge specific Phoenix mechanics into the existing KB app-local learning model?

## Findings

ATV-Phoenix latest inspected commit:
`fc6e3a4e537bf025be18eb5ac7ae9b98488da207` (`2026-07-03`, `chore(eval): north-star baseline...`).

Phoenix's strongest shipped primitive is not its full skill pack. It is the small executable spine:

- `phoenix_sense`: objective command/hash/regex checks.
- `phoenix_snapshot`: only blesses known-good state when a check passes.
- `phoenix_heal`: bounded retry or rollback, confirmed by an external recheck.
- `phoenix_verify_trace`: tamper-evident hash-chain verification.
- `phoenix_accept`: failure-first gate; a check is accepted only if the trace proves red -> green and it is green now.

This is stronger than KB's current convention-based repair loop because completion is computed from trace state, not authored in prose. KB already has good deterministic verification, protected oracle checks, scoped learning, `kb-repair` iteration ceilings, and repo-local memory. What it lacks is a generic trace-derived acceptance ledger for ordinary work, repairs, and long-running goals.

Phoenix should not replace KB wholesale:

- KB's app-local scoped learning model is more appropriate for downstream apps: default to narrow scope, pull ancestors only, promote on recurrence.
- KB's lane routing is richer for brainstorm/plan/work/complete/ship, review gates, handoffs, and repo memory.
- Phoenix's published skill pack duplicates many KB lifecycle skills and would reintroduce a parallel process vocabulary.
- Phoenix's learning gate is valuable but narrower: measured adoption eligibility for prompt/skill diffs, not a general replacement for scoped instincts.

## Where KB Is Better Overall

KB is stronger as the operating system for long-running project work:

- **Scoped learning:** lessons live at the narrowest workflow/app scope and climb
  only by recurrence. Phoenix has a valuable adoption gate, but not a better
  memory topology.
- **Route selection:** KB has proportional lanes for fix, troubleshoot,
  brainstorm, plan, work, complete, ship, epic, and durable goals.
- **Repo memory:** KB keeps project maps, handoffs, eval maps, solutions, todo
  ledgers, and scoped instincts in the working repo.
- **Completion discipline:** KB already has review, QA, compound, learn, evolve,
  and sync gates. Phoenix is better at one missing primitive: computed
  failure-first acceptance.

## Decomposition Gap

KB's decomposition is already strong on vertical slices, DAG blockers,
`expected_files`, verification mode, `test_level`, `functional_risk`, and HITL.
It does not yet say who can safely execute each slice.

Add an explicit model-tier field to plans:

- `large`: architecture, unclear decomposition, high-risk policy/security,
  long-context conflict resolution, final P0/P1 judgment.
- `medium`: ordinary implementation slices with clear acceptance criteria and
  known files.
- `small`: bounded subagent work such as test-level classification, fixture
  generation, log summaries, mechanical docs, and narrow patching when the
  oracle is already fixed.
- `tiny`: deterministic transforms, grep/path inventories, table maintenance,
  hash comparisons, and status/diff summaries.

The model tier never becomes proof. The proof remains the command, test,
browser/API/CLI probe, trace, or `kbcheck accept` result.

Best merge path:

1. Add a KB-native `kb-sense`/`kb-accept` proof layer, preferably inside `cmd/kbcheck`, using Phoenix's trace pattern.
2. Make `kb-goal`, `kb-work`, `kb-repair`, and `kb-troubleshoot` record objective sense events and require failure-first accept for fixes where a failing oracle exists.
3. Add optional snapshot/rollback for files touched by repair loops, but keep git commits/reverts as the primary durable rollback mechanism.
4. Port the measured-gain adoption gate idea into `/learn` + `/evolve`: a candidate shared/global skill change must clear held-out eval gain, no right-to-wrong regressions, and human approval.
5. Keep KB scoped learning as the memory model; Phoenix's measured gate becomes an adoption/promote gate, not the default memory store.

## Sources

- https://github.com/All-The-Vibes/ATV-Phoenix/tree/main
- https://github.com/All-The-Vibes/ATV-Phoenix/blob/main/src/sense.rs
- https://github.com/All-The-Vibes/ATV-Phoenix/blob/main/src/heal.rs
- https://github.com/All-The-Vibes/ATV-Phoenix/blob/main/src/snapshot.rs
- https://github.com/All-The-Vibes/ATV-Phoenix/blob/main/src/trace.rs
- https://github.com/All-The-Vibes/ATV-Phoenix/blob/main/src/accept.rs
- https://github.com/All-The-Vibes/ATV-Phoenix/blob/main/src/bin/phoenix_mcp.rs
- https://github.com/All-The-Vibes/ATV-Phoenix/blob/main/phoenix_learn/gate.py
- https://github.com/All-The-Vibes/ATV-Phoenix/blob/main/phoenix_learn/optimize.py
- https://github.com/All-The-Vibes/ATV-Phoenix/blob/main/evals/m1-self-heal/RESULT.md
- https://github.com/All-The-Vibes/ATV-Phoenix/blob/main/evals/autonomous-workflows/RESULT.md
- https://github.com/All-The-Vibes/ATV-Phoenix/blob/main/evals/c3-phoenix-learn/RESULT.md

## Applies When

- Designing KB self-heal proof, repair gates, long-running goal completion, or skill/learning promotion.
- Deciding whether an agent may mark work done after tests pass.
- Promoting local app learning into shared/global skills.

## Stale When

- Phoenix changes its spine semantics or ships a materially different `phoenix-learn` skill.
- KB adds its own trace-derived accept gate.
- A downstream app proves a different self-heal ledger in production.

## Rejected Approaches

- Replace KB with Phoenix wholesale: duplicates KB lane routing and would discard scoped app-local learning.
- Adopt Phoenix's entire skill pack: useful concepts, but too much parallel vocabulary.
- Keep KB as-is: misses the key Phoenix advantage, which is executable failure-first acceptance.

## Impact On Current Project

Create a KB-native self-heal/proof manifest before implementation. First slice should be `kbcheck sense/accept` with a `.kb/trace.jsonl` hash chain and tests for red->green, vacuous-green rejection, and tamper rejection.
