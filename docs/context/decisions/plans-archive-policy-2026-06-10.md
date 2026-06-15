# Plans Archive Policy

Date: 2026-06-10

## Decision

Keep root `docs/plans/` focused on current-day active and recently reviewed
plans. Archive historical root-level plan files by month under
`docs/plans/archive/YYYY-MM/` once they are no longer active in `todo.md`.

## Reason

Large root plan directories make fresh-session lookup noisy. Archive paths keep
durable history while making current work easier to find.

## Execution

Initial archive wave:

- Root plan files before: 100
- Moved to archive: 89
- Root plan files after: 11

References were rewritten from `docs/plans/<file>` to
`docs/plans/archive/YYYY-MM/<file>`.

## Future Rule

`kb-complete` should archive completed non-current-day plans after board/archive
state is updated, and should rewrite repo-relative references in memory docs.
