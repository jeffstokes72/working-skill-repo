# ATV Upstream Skill Delta

Date: 2026-05-31

## Compared Refs

- ATV fork repo: `<atv-repo>`
- Fork head: `origin/main` at `35b0925 Add OSV proof to ATV security skill`
- Upstream head: `upstream/main` at `cbe5d07 docs: add comprehensive /atv-security user guide (#49)`
- Parked branch source: `origin/feat/pocock-skills`
- Working bundle source: `<working-skill-repo>`

Method: `git fetch --all --prune`, then object/ref comparisons with
`git diff --name-status` and `git show`. No merge, checkout, or pull was run in
the dirty ATV worktree.

## Dirty Local State Before Import

`<atv-repo>` already contains propagated local skill changes in
`.github/skills`, `pkg/scaffold/templates/skills`, and
`plugins/atv-everything/skills`. Treat that worktree as unsafe for direct
upstream merge until committed or copied into a clean integration branch.

`<working-skill-repo>` is also dirty with current proof-harness,
marketplace-promotion, and ATV-resync planning work. Do not stage unrelated
files as part of this resync without a separate commit decision.

## Category Findings

### KB-Owned Skills

Decision: `keep-local`.

Upstream `main` deletes the KB family from ATV roots, including:

- `kb-brainstorm`
- `kb-check`
- `kb-compact`
- `kb-complete`
- `kb-epic`
- `kb-eval-map`
- `kb-first-principles`
- `kb-fix`
- `kb-functional-test`
- `kb-gate`
- `kb-handoff`
- `kb-map`
- `kb-map-bootstrap`
- `kb-memory-review`
- `kb-plan`
- `kb-qa`
- `kb-regression-snapshot`
- `kb-repair`
- `kb-research`
- `kb-review`
- `kb-ship`
- `kb-start`
- `kb-task`
- `kb-troubleshoot`
- `kb-work`
- `klfg`
- `tdd`

Rationale: upstream deletion conflicts with this repo's product. The portable
bundle owns KB skills and has current eval/sync gates for them.

### Shared Overlap Skills

Decision: `merge-review`, with focused review-improvement check complete.

| Skill | Local lines | Upstream lines | Upstream delta | Decision |
|---|---:|---:|---|---|
| `ce-compound` | 328 | 327 | Renames related command from `/kb-plan` to `/ce-plan`. | Keep local KB pointer. |
| `ce-compound-refresh` | 191 | 448 | Re-inlines large reference bodies and deletes separate references. | Keep local trimmed/lazy structure. |
| `ce-review` | 167 | 479 | Re-inlines review flow and changes reference files. | Keep local compact wrapper/reference split; focused check found the useful upstream review mechanics already present in local references. |
| `document-review` | 213 | 203 | Switches callers/agents from KB/runtime names to compound-engineering names. | Keep local runtime-valid KB/general agent guidance and KB caller names. |
| `evolve` | 91 | 72 | Lowers threshold to 0.8 and removes recency gate. | Keep local stricter 0.85 + recency/human approval behavior. |
| `learn` | 134 | 93 | Removes recency decay. | Keep local decay model. |

Rationale: upstream changes are mostly incompatible with the KB fork's naming,
approval, and token-minimality goals. The focused review check confirmed the
valuable review behavior is already present locally: fork-safe base resolution,
plan-source requirements checks, standards path passing, model-tier guidance,
CE-agent artifact preservation, and table/headless output rules. No shared
overlap import is accepted in this pass.

### ATV-Native Skills

Decision: `selective-review`, not mirror. Keep or import original ATV-owned
changes only when the local app/workflow still uses them, or when they contain
specific improvements worth porting.

Important finding: upstream `atv-security` scaffold/plugin copies remove the
local OSV Scanner machine-evidence gate and replace it with generic dependency
age/audit advice. Reject that upstream section and preserve local OSV proof.

First-pass candidates reviewed from original ATV `upstream/main`:

- `ce-ideate`
- `ce-plan`
- `ce-work`
- `create-agent-skill`
- `create-agent-skills`
- `deepen-plan`
- `generate_command`
- `ghcp-review-resolve`
- `git-commit-push-pr`
- `git-worktree`
- `land`
- `ralph-loop`
- `report-bug`
- `resolve-pr-parallel`
- `takeoff`
- `unslop`

Upstream-only deletions that should not automatically drive local behavior:

- `deepen-brainstorm`
- `handoff`
- `improve-codebase-architecture`

Rejected upstream import:

- `atv-security` A06 dependency section because upstream removes local OSV
  Scanner evidence requirements.

### Superseded Original-ATV Workflow Candidates

Decision: `remove-transient-imports`.

Upstream `main` adds:

- `lfg`
- `slfg`
- `workflows-brainstorm`
- `workflows-compound`
- `workflows-plan`
- `workflows-review`
- `workflows-work`

These are present in the actual `All-The-Vibes/ATV-StarterKit` upstream, but
they are not automatically useful here. They overlap KB replacements:

- `lfg` and `slfg` are superseded by `klfg`.
- `workflows-plan` is superseded by `kb-plan`.
- `workflows-work` is superseded by `kb-work`.
- `workflows-brainstorm` is superseded by `kb-brainstorm`.
- `workflows-review` is superseded by `kb-review`/`ce-review`.
- `workflows-compound` is superseded by `ce-compound`.

They were transiently imported during the first pass, then removed after the
user clarified the policy: keep only things the app uses, or port concrete
improvements into the active replacement skills.

Removed transient imports from ATV roots:

- `.github/skills/lfg`
- `.github/skills/slfg`
- `.github/skills/workflows-brainstorm`
- `.github/skills/workflows-compound`
- `.github/skills/workflows-plan`
- `.github/skills/workflows-review`
- `.github/skills/workflows-work`
- `pkg/scaffold/templates/skills/lfg`
- `pkg/scaffold/templates/skills/slfg`
- `plugins/atv-everything/skills/lfg`
- `plugins/atv-everything/skills/slfg`

OSV Scanner was run narrowly against the transiently imported `.github/skills`
workflow directories. It exited 1 with `No package sources found`, which is
expected for these skill-only directories and produced no vulnerability report.

### Parked Branch-Only Candidates

Decision: `parked`.

`origin/feat/pocock-skills` also contains workflow/kanban candidates such as:

- `kanban-brainstorm`
- `kanban-plan`
- `kanban-work`
- `kanban-lightsout`

These remain parked because they are branch-only, not current original ATV
`upstream/main`.

## Commands Used

```powershell
git -C <atv-repo> fetch --all --prune
git -C <atv-repo> diff --name-status origin/main..upstream/main -- .github/skills pkg/scaffold/templates/skills plugins/atv-everything/skills
git -C <atv-repo> diff --name-status origin/main..origin/feat/pocock-skills -- .github/skills pkg/scaffold/templates/skills plugins/atv-everything/skills
git -C <atv-repo> diff --stat origin/main..upstream/main -- .github/skills/ce-compound .github/skills/ce-compound-refresh .github/skills/ce-review .github/skills/document-review .github/skills/evolve .github/skills/learn
osv-scanner scan source -r <atv-repo>\.github\skills\lfg <atv-repo>\.github\skills\slfg <atv-repo>\.github\skills\workflows-brainstorm <atv-repo>\.github\skills\workflows-compound <atv-repo>\.github\skills\workflows-plan <atv-repo>\.github\skills\workflows-review <atv-repo>\.github\skills\workflows-work --format json --output <atv-repo>\docs\security\osv-atv-workflow-skills-2026-05-31.json
```

## Recommended Actions

- `keep-local`: all KB-owned skills.
- `keep-local`: shared overlap skills in this pass.
- `keep-local`: local `atv-security` OSV proof gate.
- `remove-transient-imports`: upstream-main workflow candidates superseded by
  KB lanes.
- `parked`: Pocock/kanban branch-only candidates.
- `selective-review`: original ATV-native helper skills listed above.
- `checked`: focused `ce-review`/`document-review` improvement port; no new
  upstream behavior needed.
- `rejected`: upstream `atv-security` A06 regression.
