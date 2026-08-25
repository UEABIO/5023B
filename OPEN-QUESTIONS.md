# Open questions

Append only. Never edit or delete an existing entry; change its `Status` and add a
`Resolution`. A resolved entry whose answer generalises must be copied into the
glossary in `TRANSLATION.md` before the next chapter is started.

Status vocabulary: `open`, `resolved`, `wontfix`.

Each entry's id must match the `# TRANSLATION-NOTE: <id>` comment left in the
chapter.

---

## OQ-000 (template, do not resolve)

- **File / chunk:** `02-wrangling.qmd`, `#| label: summarise-by-island`
- **Status:** open
- **R original:**

  ```r
  penguins |>
    summarise(n = n(), .by = c(species, island))
  ```

- **Issue:** one sentence on why the glossary does not settle this.
- **Candidates:**
  1. `.groupby(["species", "island"], as_index=False).size()`
  2. `.groupby(["species", "island"]).size().reset_index(name="n")`
- **Provisional choice in the book:** 2, marked `# TRANSLATION-NOTE: OQ-000`.
- **Recommendation:** 2, because option 1 names the column `size` and needs a
  rename anyway, which costs the parallelism the chain was buying.
- **Resolution:**

---

## OQ-001

- **File / chunk:** `strings.qmd`, unlabelled chunk inside `.callout-important`
  (`## Penguin clean names dataset`), line 17
- **Status:** open
- **R original:**

  ```r
  penguins_clean_names <- readRDS(url("https://github.com/UEABIO/5023B/raw/refs/heads/2026/files/penguins.RDS"))
  ```

- **Issue:** `.RDS` is R's native serialisation format with no Python
  equivalent (see the standing warning added to `TRANSLATION.md`). No Python
  chunk was written for this one; it is skip-and-logged, not translated.
- **Candidates:** none — no Python idiom applies.
- **Provisional choice in the book:** no Python tab added for this chunk.
- **Recommendation:** leave untranslated. Revisit only if the setup chapter
  (out of scope for now) ends up defining a Python-native equivalent dataset
  file the reader downloads instead.
- **Resolution:**

---

## OQ-002

- **File / chunk:** `strings.qmd`, unlabelled chunk under `## Rename text
  values with stringr` (originally line 206)
- **Status:** resolved
- **R original:**

  ```r
  # use mutate and case_when
  # for a statement that conditionally changes
  # the names of the values in a variable
  penguins_clean_names |>
    mutate(species = stringr::word(species, 1)
    ) |>
    mutate(sex = stringr::str_to_title(sex))
  ```

- **Issue:** the comment says "use mutate and case_when" but the code uses
  `word()`/`str_to_title()`, not `case_when()`. Looks like a copy-paste
  leftover from the chunk above it. Per hard rule 1 the R chunk is left
  untouched; the comment was carried across verbatim into the Python tab as
  written, per TRANSLATION.md's "carry comments across where they still
  apply" convention, even though it no longer quite applies here.
- **Candidates:** n/a — not a translation ambiguity.
- **Provisional choice in the book:** comment carried across unchanged.
- **Recommendation:** a human may want to fix the R comment directly (outside
  this translation workflow); not something Claude should alter under the
  hard rules.
- **Resolution:** On human review (2026-08-25), the stale comment was removed
  from the Python chunk rather than edited, since it described neither the R
  code above it nor the Python code below it (`str.split().str[0]` /
  `str.title()`, no conditional recoding). The R chunk is unchanged, per hard
  rule 1. Two similar comments elsewhere in the chapter (the `case_when()` and
  `if_else()` sections) named R functions (`mutate`, `case_when`, `if_else`)
  in the Python tab; those did describe the code below them, so they were
  edited to name the Python equivalents (`assign`/`np.select`,
  `assign`/`np.where`) instead of being removed.

---
