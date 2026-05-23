---
name: kb-map-bootstrap
description: Token-expensive bootstrap skill that deeply indexes a project and creates the standard KB project memory structure. Use when kb-map reports missing or badly stale memory files, when entering an existing project without kb.md/kb-handoff.md/docs/context/PROJECT.md, or when the user says "bootstrap this project", "deep map this repo", "build project memory", or "index this app".
argument-hint: "[optional project focus or subsystem hints]"
---

# KB Map Bootstrap - Deep Project Index

`kb-map-bootstrap` is the expensive setup pass for projects that do not yet have KB project memory. It creates the pointer tree that future sessions can read cheaply through `kb-map`.

Do not use this for ordinary startup. Use `kb-map` first.

## Goal

Build the standard memory layout:

```text
kb.md
kb-done.md
kb-handoff.md
docs/context/
  PROJECT.md
  architecture/
    README.md
    <major-subsystem>.md
    <major-subsystem>/
      <child-area>.md
  research/
    README.md
    <topic>.md
  decisions/
    README.md
    <YYYY-MM-DD>-<decision>.md
  operations/
    README.md
    runbooks.md
    testing.md
```

## Bootstrap Workflow

1. **Inventory the repo**
   - Top-level files and folders
   - App entry points
   - Package/build/test config
   - Routes, screens, commands, or public interfaces
   - Services, actions, tools, workers, jobs, integrations
   - Tests
   - Existing docs

2. **Identify major subsystems**
   - User-facing workflows
   - Backend domains
   - Tool/action layers
   - Data/storage layers
   - External integrations
   - Runtime shells such as Electron, browser automation, mobile, or CLI

3. **Create missing folders and files**
   - Preserve existing user docs.
   - Do not overwrite non-empty memory files without reading and merging them.
   - Use lowercase kebab-case for docs except `PROJECT.md` and folder `README.md`.

4. **Write `docs/context/PROJECT.md`**
   - Keep it short.
   - Make it a pointer map, not an encyclopedia.
   - Include run/test commands and the subsystem index.

5. **Write subsystem docs**
   - One concise doc per major subsystem.
   - Add child docs only when a subsystem is too large for one file.
   - Parent docs summarize and point to children.

6. **Create KB workflow files when missing**
   - `kb.md`
   - `kb-done.md`
   - `kb-handoff.md`

7. **Review**
   - Run `document-review` on `PROJECT.md` and any large architecture docs when available.
   - Apply obvious auto-fixes.
   - Keep unresolved findings visible in `kb-handoff.md`.

## Claim Confidence

Mark non-obvious claims:

- `verified` - confirmed by reading source.
- `inferred` - likely from naming/structure, but not fully traced.
- `unknown` - needs follow-up.

Do not overstate confidence. Future agents should know whether a route-map entry is confirmed or inferred.

## PROJECT.md Template

```markdown
# Project Map

Bootstrap: <date>
Bootstrap confidence: verified|mixed|rough

## What This Is

## How To Run

## How To Test

## Current Architecture

## Subsystem Index

| Area | Read This | Use When | Confidence |
|---|---|---|---|

## Current Work Pointers

## Known Sharp Edges

## Research Index

| Topic | Note | Stale When |
|---|---|---|

## Do Not Repeat

## Maintenance Notes
```

## Subsystem Template

```markdown
# <Subsystem>

Confidence: verified|inferred|unknown

## What It Is

## Current Shape

## Entry Points

## Files To Read First

## Common Tasks

| Task | Read | Commands / Checks |
|---|---|---|

## What Works

## What We Tried And Rejected

## What Does Not Work

## Research Worth Keeping

## Child Docs

## Open Questions
```

## Output

Finish with:

- Files created or updated.
- Major subsystems discovered.
- Any uncertain areas.
- Recommended first `kb-route` test prompt.
