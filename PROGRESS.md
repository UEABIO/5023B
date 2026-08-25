# Progress

Status vocabulary: `todo`, `in-progress`, `translated`, `reviewed`, `blocked`.
`translated` means Claude has finished a chapter. `reviewed` means a human has
checked it. Only a human sets `reviewed`.

## Branch policy

- Active working branch: `2027`. All translation work (inventory, pilot,
  bulk chapter passes) happens here.
- `2027` is not to become the repository's default branch. `2026` remains
  default on GitHub.
- Commit at the end of every completed step of the workflow below, not only
  at the end of a chapter: the inventory pass, each pilot-gate check, and
  each chapter's definition-of-done all get their own commit before moving
  on. Do not let uncommitted work accumulate across steps.

## Order of work

1. Inventory pass across all chapters. No edits. Produces the chunk counts in the
   table below and the additions to the glossary in `TRANSLATION.md`.
2. Pilot: one chapter only, then stop. The pilot gate below must pass before any
   further chapter is started.
3. Bulk pass, in the order listed, only after the pilot is `reviewed` and
   `TRANSLATION.md` has been amended from what the pilot revealed.
4. Preface and standing warnings last, once the real translation patterns are
   known.

## Pilot gate

All five must pass before bulk work begins. Item 2 is blocking: if it fails, the
solution mechanism needs redesigning before the pattern is committed to across
the book.

| # | Check | Result |
|---|---|---|
| 1 | `{python}` chunks with `eval: false` render with no Python installed and no reticulate configured | |
| 2 | A `.panel-tabset` inside `hide()`/`unhide()` initialises correctly, including the tab that is not active when the container is revealed | |
| 3 | A five-colon tabset inside `::::{.task-container}` renders with the task styling intact | |
| 4 | `group="language"` syncs across chapters, not merely within a page | |
| 5 | `scripts/verify_python.R` runs the pilot chapter's extracted Python without error | |

## Chapters

| # | File | Chunks eligible | Status | Open Qs | Commit | Date | Notes |
|---|---|---|---|---|---|---|---|
| 0 | index.qmd | | todo | | | | preface: standing warnings, written last |
| 1 | | | todo | | | | |
| 2 | | | todo | | | | pilot chapter |
| 3 | | | todo | | | | |

## Deferred goals

Not translation work. Do not start without explicit instruction.

| Goal | Status | Notes |
|---|---|---|
| Python setup chapter | not started | New writing: environment, packages, editor. Begin only after all chapters are `reviewed`. |
| `requirements.txt` with pinned versions | not started | Depends on the setup chapter. |
| Preface standing warnings | not started | Depends on the patterns found during translation. |
