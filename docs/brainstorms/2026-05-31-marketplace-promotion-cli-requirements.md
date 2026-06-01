# Marketplace Promotion CLI Requirements

Date: 2026-05-31
Status: ready for planning

## Problem Frame

The marketplace policy is correct but too manual. If safe promotion requires six
manual steps while unsafe global install is one copy command, the unsafe path
will eventually win when the user is tired.

## Requirements

- R1: Provide one command that promotes a reviewed skill into the private
  marketplace and optionally syncs selected global runtime roots.
- R2: The command must validate `SKILL.md` frontmatter before copying.
- R3: The command must refuse unsafe paths: approved output under quarantine,
  active/global sync from quarantine, missing source skill, and catalog hash
  mismatches.
- R4: The command must copy the reviewed skill into
  `E:/agent-marketplace/skills/<skill>`, compute the `SKILL.md` SHA256, and pin
  that hash in `catalog/approved-skills.json`.
- R5: The command must support selected global targets: Codex, Copilot, and
  shared agents.
- R6: The command must run or enable the existing firebreak proof after catalog
  mutation.
- R7: The command must have a deterministic selftest that exercises the happy
  path and a refusal path without mutating the real marketplace or globals.

## Scope Boundaries

- Do not build a public marketplace importer.
- Do not automate LLM code review inside the script.
- Do not make `E:/agent-marketplace` a runtime skill root.
- Do not replace `skill-marketplace-firebreak.ps1`; reuse it as the blocking
  policy proof.

## Success Criteria

- `scripts/promote-marketplace-skill.ps1` can promote a local reviewed skill
  using one command with `-Approved`.
- `scripts/promote-marketplace-skill-selftest.ps1` proves the script updates a
  temp catalog, pins a hash, optionally syncs a temp global root, and refuses a
  quarantine destination.
- `kb-check -All` includes the selftest.
- Docs explain that the script is the fast path and direct global copy is the
  wrong path.

## Research Summary

External research skipped: low expected decision value. This is local workflow
automation around an existing private catalog and firebreak.

## Decisions

- Use PowerShell because existing repo checks and sync tooling are PowerShell.
- Keep human approval explicit through `-Approved`; interactive prompting is
  avoided so the command is scriptable and testable.
- Let quarantine be a possible reviewed source only when the output is copied
  into approved storage and the catalog/firebreak pass. Never sync or load
  directly from quarantine.

## Slice Candidates

- Build the promotion command.
- Add deterministic selftest and wire it into `kb-check`.
- Update marketplace docs and memory.
