# Scaffold for the dual-language translation project

Where each file goes, relative to the book root:

```
CLAUDE.md                                     <- book root
TRANSLATION.md                                <- book root
PROGRESS.md                                   <- book root
OPEN-QUESTIONS.md                             <- book root
.claude/skills/translate-chapter/SKILL.md     <- creates /translate-chapter
scripts/verify_python.R                       <- run manually, not in the render
preface-text.md                               <- paste into index.qmd, then delete
README-scaffold.md                            <- this file, delete once read
```

Custom slash commands may also live in `.claude/commands/*.md`; that form still
works but has been merged into skills, and `.claude/skills/<name>/SKILL.md` is the
current recommended location. If both exist under the same name, the skill wins.
See https://code.claude.com/docs/en/slash-commands.md

## Before starting

1. Fill in the chapter table in `PROGRESS.md`, and nominate a pilot chapter. Pick
   a mid-book chapter of ordinary complexity, not chapter one.
2. Create a branch. Every chapter is one commit on it, so a bad pattern can be
   reverted chapter by chapter.
3. Run the inventory pass with no edits, then extend the glossary in
   `TRANSLATION.md` from what it finds.
4. Run the pilot, then work the pilot gate in `PROGRESS.md` by hand. Item 2 is
   blocking.
5. Only then start the bulk pass, using `/translate-chapter`. Use `/plan` before
   the first bulk chapter so the intended edits are visible before they land.

## What this scaffold assumes

- knitr engine throughout, because the book uses webexercises inline R calls.
- Python chunks always `eval: false`, so no Python installation or reticulate is
  needed to render. Confirm this as pilot gate item 1.
- All printed output comes from R. The Python is verified outside the book by
  `scripts/verify_python.R`, which is the only thing standing between a broken
  translation and a student. Run it between chapters.

## Two things deliberately left undone

- The Python setup chapter. New writing, not translation, and out of scope for
  Claude during the bulk pass. Rule 9 in `CLAUDE.md` enforces this.
- `requirements.txt`. Pin versions when the setup chapter is written, and update
  the version floor in `TRANSLATION.md` to match.
