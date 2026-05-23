---
name: kb-map
description: Cheap entry skill for consulting the project memory map used by KB workflows. Use when starting in a repo, when another KB skill needs to find the right architecture docs without the user pointing to files, or when the user says "map", "where is this", "project context", or "what should I read". If project memory is missing or stale, route to kb-map-bootstrap instead of doing a deep repo crawl here.
argument-hint: "[lookup|refresh] [optional task or subsystem]"
---

# KB Map - Project Memory Router

`kb-map` is the cheap project-memory entry skill. It lets new sessions understand where to look without re-reading the whole repo or relying on chat history.

Keep this skill small. Expensive repo indexing belongs in `kb-map-bootstrap`.

## Modes

Pick the mode from the argument. If absent, default to `lookup`.

| Mode | Use When | Cost |
|---|---|---|
| `lookup` | Project memory exists; find the right docs for the current request | low |
| `refresh` | Recent work changed architecture or routing; update affected docs | medium |

## Standard Layout

Every KB-enabled repo uses:

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

Use lowercase kebab-case for docs except `PROJECT.md` and folder `README.md` files.

## Lookup Mode

Read, in order:

1. `kb-handoff.md`
2. `kb.md`
3. `docs/context/PROJECT.md`

Then follow only relevant pointers to subsystem, research, decision, or operations docs.

Stop reading once you can answer:

- What app/repo is this?
- What is the user trying to accomplish?
- What is active or blocked?
- Which subsystem is relevant?
- Which files or commands are likely involved?
- What has already been tried or researched?
- Which KB route should handle this request?

Report the chosen route and the docs loaded. Do not bulk-load all context docs.

## Missing Memory

If any of these are missing:

- `kb-handoff.md`
- `kb.md`
- `docs/context/PROJECT.md`

Do not deep-crawl the repo in this skill. Say that project memory is missing and invoke or recommend `kb-map-bootstrap`.

If the repo is tiny and the user asked for a small fix, you may continue with a targeted scan, but still record that `kb-map-bootstrap` should be run later.

## Refresh Mode

Use after meaningful architecture changes.

Workflow:

1. Read `docs/context/PROJECT.md`.
2. Inspect changed files, recent plans/manifests, and relevant work logs.
3. Update only affected subsystem docs.
4. Add child docs when a parent doc is getting too large.
5. Update `kb-handoff.md` if the next-session route changed.
6. Run `document-review` when changes are substantial.

Do not re-bootstrap the whole repo here. If refresh discovers the map is missing or badly stale, route to `kb-map-bootstrap`.

## Document Contracts

### `PROJECT.md`

```markdown
# Project Map

## What This Is

## How To Run

## How To Test

## Current Architecture

## Subsystem Index

| Area | Read This | Use When |
|---|---|---|

## Current Work Pointers

## Known Sharp Edges

## Research Index

| Topic | Note | Stale When |
|---|---|---|

## Do Not Repeat

## Maintenance Notes
```

### Subsystem Docs

```markdown
# <Subsystem>

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

When a section gets large, split it into a child doc and replace the section with a pointer.
