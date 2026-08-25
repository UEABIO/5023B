---
name: translate-chapter
description: Add non-executing Python tabs to one chapter of the Quarto book, following TRANSLATION.md and logging ambiguities to OPEN-QUESTIONS.md. Use when translating a chapter of the dual-language book.
---

# Translate one chapter

Argument: the chapter filename. If none is given, take the first `todo` row in
`PROGRESS.md`.

## Procedure

1. Read `CLAUDE.md`, `TRANSLATION.md` and the whole of `OPEN-QUESTIONS.md`.
2. Confirm from `PROGRESS.md` that the pilot gate has passed. If it has not, and
   this is not the pilot chapter, stop and say so.
3. Read the entire chapter before editing anything.
4. List every `{r}` chunk with its label, its options, its enclosing heading
   level, and its eligibility under the "What to translate" rules in `CLAUDE.md`.
   Present this list and stop for confirmation.
5. On confirmation, edit the chapter. One tabset per eligible chunk.
6. Work through the definition-of-done checklist in `CLAUDE.md` and report each
   item explicitly, including the `git diff` check that no R or prose line moved.
7. Append any new entries to `OPEN-QUESTIONS.md`.
8. Update the chapter's row in `PROGRESS.md`.
9. Commit as `translate: <file>`. Do not push.

## Constraints

- Do not proceed past step 4 without confirmation.
- Do not touch a second chapter in the same run.
- Do not render, do not run code, do not install anything.
- Do not resolve an ambiguity by editing the R code, the data or the prose.
