# Agent Skills Git Distribution

Checked: 2026-05-30
Budget mode: lean

## Question

Are we using Git correctly for this portable skill bundle, or are we creating
avoidable drift by treating local/global installs and ATV copies as peer source
trees?

## Findings

Agent Skills are intentionally simple, portable directories: a required
`SKILL.md` plus optional `scripts/`, `references/`, `assets/`, and other bundled
files. The open format is designed for cross-product reuse, with agents loading
only skill metadata at startup and reading the full skill only when relevant.

That implies this repo should treat skills like distributable source packages:

- one canonical source repo owns skill content;
- installed global skill directories are install artifacts, not authoring
  locations;
- downstream bundles such as ATV must have an explicit distribution policy
  instead of becoming an accidental second source of truth;
- sync should be deterministic and hash-verified after merge, not hand-managed
  during implementation.

The official specification says `SKILL.md` must contain YAML frontmatter and
Markdown body, and recommends progressive disclosure: keep the main skill body
bounded, move detail into focused reference files, and reference bundled files
with relative paths. It also states that `scripts/`, `references/`, and
`assets/` are optional directories. This supports the current direction of
moving deterministic checks into scripts and keeping long skill bodies under
pressure.

The best-practices guidance reinforces that skills should be grounded in real
work, not generic LLM output. It recommends extracting skills from hands-on
tasks, project artifacts, execution traces, failures, and version-control
history. It also says every token in an activated `SKILL.md` competes with the
rest of the context window, so skill content should include what the agent would
otherwise miss and cut what the model already knows.

The eval guidance says skill quality needs structured test cases, assertions,
grading evidence, and iteration. It distinguishes verifiable checks from softer
human-review judgments and explicitly recommends verification scripts for
mechanical checks such as valid JSON, row counts, and file existence. That lines
up with this repo's split between model actions and deterministic judges.

The description-optimization guidance treats `description` as the primary
triggering mechanism. It recommends realistic should-trigger and
should-not-trigger query sets, train/validation separation, and avoiding
keyword-level overfitting. That maps directly onto this repo's route-complexity
and live skill-eval fixtures.

The scripts guidance recommends pinning one-off command versions, stating
environment prerequisites, moving complex commands into tested scripts, exposing
`--help`, avoiding interactive prompts, using helpful errors, and emitting
structured output. This supports making `sync-skills.ps1`,
`check-skill-distribution.ps1`, and eval adapters policy-aware scripts rather
than relying on agent prose.

## Sources

- [Agent Skills overview](https://agentskills.io/home) - skill folders,
  cross-product reuse, progressive disclosure.
- [Agent Skills specification](https://agentskills.io/specification) - required
  frontmatter, directory structure, optional bundled directories, progressive
  disclosure, file-reference rules, validation.
- [Best practices for skill creators](https://agentskills.io/skill-creation/best-practices)
  - real expertise, project artifacts, execution traces, context economy,
  coherent scope, scripts for repeated logic.
- [Evaluating skill output quality](https://agentskills.io/skill-creation/evaluating-skills)
  - eval cases, assertions, grading evidence, script-based mechanical checks,
  iteration loop.
- [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
  - trigger eval queries, train/validation split, overfitting risk, description
  limits.
- [Using scripts in skills](https://agentskills.io/skill-creation/using-scripts)
  - pinned commands, prerequisites, script interfaces, `--help`, structured
  output.
- [Anthropic engineering: Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
  - skills as composable procedural knowledge, scripts as deterministic
  repeatable machinery, progressive disclosure.

## Applies When

- Changing skill content in `.github/skills/**`.
- Syncing to `C:\Users\marowe\.codex\skills`,
  `C:\Users\marowe\.copilot\skills`, or
  `C:\Users\marowe\.agents\skills`.
- Syncing or pruning ATV `.github/skills`, scaffold, or plugin copies.
- Designing the next distribution contract and sync/check scripts.
- Deciding whether a behavior belongs in `SKILL.md`, `references/`, `assets/`,
  or `scripts/`.

## Stale When

- Agent Skills changes the directory/spec/frontmatter contract.
- Codex, Copilot, or ATV stops using Agent Skills-compatible discovery.
- A package-manager-style installer replaces local global skill directories.
- ATV chooses and documents a stable full-bundle or thin-bundle policy.

## Rejected Approaches

- Editing global installs directly as source. This creates unreviewed drift and
  makes Git history incomplete.
- Treating ATV as a peer source repo without an explicit upstream/downstream
  policy. This hides distribution decisions inside sync warnings.
- Hash-gating line-ending churn without normalization. Byte-level gates are
  useful only when the sync path is byte-stable.
- Adding more skill prose to compensate for missing deterministic scripts. If
  the agent repeats the same parsing, scoring, syncing, or validation work,
  write a script and make the skill invoke it.
- Optimizing skill trigger descriptions only by intuition. Trigger behavior
  needs should-trigger and should-not-trigger prompts with holdout queries.

## Impact On Current Project

The repo should add a policy-aware distribution layer:

1. Add `config/skill-distribution.json`.
   - canonical skill list;
   - required global install targets;
   - ATV `.github/skills` policy;
   - ATV scaffold/plugin policy;
   - line-ending and hash expectations;
   - excluded or intentionally-thin targets.
2. Add `scripts/sync-skills.ps1`.
   - copy from landed canonical source only;
   - normalize text output consistently;
   - refuse to overwrite unreviewed downstream-only drift;
   - print a required-target hash table.
3. Add `scripts/check-skill-distribution.ps1`.
   - read-only policy gate;
   - fail required drift;
   - report optional/thin-bundle differences as declared policy, not vague
     warnings.
4. Add `.gitattributes` for stable skill/script/doc line endings.
5. Update README with a clear lifecycle:
   `feature branch -> kb-check -> merge main -> sync/install from main -> hash verify`.
6. Keep globals as installed artifacts. Never edit them first.

This does not mean the current work is invalid. It means the next reliability
improvement should make Git boring: canonical source, explicit release channels,
deterministic install, deterministic verification.
