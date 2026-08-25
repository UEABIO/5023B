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

## OQ-003

- **File / chunk:** `duplicates.qmd`, unlabelled chunk inside
  `.callout-important` (`## Penguin clean names dataset`), lines 18–21
- **Status:** open
- **R original:**

  ```r
  penguins_clean_names <- readRDS(url("https://github.com/UEABIO/5023B/raw/refs/heads/2026/files/penguins.RDS"))
  ```

- **Issue:** identical shape to OQ-001 in `strings.qmd` — `.RDS` load with no
  Python equivalent. No Python chunk was written; skip-and-logged, not
  translated.
- **Candidates:** none — no Python idiom applies.
- **Provisional choice in the book:** no Python tab added for this chunk.
- **Recommendation:** same as OQ-001 — leave untranslated. This pattern
  recurs across most Data Cleaning/Insights chapters per the standing
  warning in `TRANSLATION.md`; each occurrence is still logged individually
  per CLAUDE.md's "skip and log" rule for R-specific chunks.
- **Resolution:**

---

## OQ-004

- **File / chunk:** `duplicates.qmd`, `## Duplicated rows`, pre-existing
  R-only tabset (`dplyr` tab, lines 33–41; `janitor` tab, lines 50–56)
- **Status:** open
- **R original:**

  ```r
  library(tidyverse)
  # check for whole duplicate 
  # rows in the data
  penguins_clean_names |> 
    filter(duplicated(across(everything())))
    sum() 
  ```

  ```r
  library(janitor)

  penguins_clean_names |> 
    get_dupes()
  ```

- **Issue:** two problems bundled together. First, this is a pre-existing
  R-only tabset (`dplyr` vs `janitor`); per `TRANSLATION.md` only one
  representative Python tab is added for the group, and neither
  `duplicated(across(everything()))` nor `get_dupes()` has a glossary entry.
  Second, the `dplyr` tab's R code looks wrong: `sum()` sits on its own line
  after the pipe closes, so it is not part of the `filter()` pipe as the
  surrounding text and printed output (`[1] 0`) imply. Per hard rule 1 the R
  chunk is left untouched regardless.
- **Candidates:**
  1. `penguins_clean_names.duplicated().sum()` — direct pandas idiom for
     counting duplicate rows, gives the same `0` result.
  2. Port `janitor::get_dupes()`'s intent as a groupby-based dupe count.
- **Provisional choice in the book:** 1, marked `# TRANSLATION-NOTE: OQ-004`,
  because it is the clean working equivalent of what the `dplyr` tab's
  broken code appears to intend, and reads most directly against the
  `janitor` tab's one-line call.
- **Recommendation:** 1. Also worth a human fixing the `dplyr` tab's missing
  pipe directly in the R chunk (outside this translation workflow).
- **Resolution:**

---

## OQ-005

- **File / chunk:** `duplicates.qmd`, `### Working with duplications`,
  unlabelled chunk, lines 79–84 (post-edit)
- **Status:** open
- **R original:**

  ```r
  penguins_demo <- penguins_clean_names |> 
    slice(1:50) |> 
    bind_rows(slice(penguins_clean_names, c(1,5,10,15,30)))
  ```

- **Issue:** neither `slice()` nor `bind_rows()` has a glossary entry.
- **Candidates:**
  1. `pd.concat([penguins_clean_names.iloc[0:50], penguins_clean_names.iloc[[0, 4, 9, 14, 29]]])`
  2. `pd.concat([penguins_clean_names.head(50), penguins_clean_names.iloc[[0, 4, 9, 14, 29]]])`
- **Provisional choice in the book:** 1, marked `# TRANSLATION-NOTE: OQ-005`.
  R's `slice(1:50)` is 1-indexed and inclusive; Python's `.iloc[0:50]` is
  0-indexed and half-open, but both select the first 50 rows (covered by the
  standing indexing warning in `TRANSLATION.md`, not restated here). The
  second `slice()` call's row numbers `c(1,5,10,15,30)` become 0-indexed
  positions `[0, 4, 9, 14, 29]`.
- **Recommendation:** 1, and consider adding `slice()` → `.iloc[]` and
  `bind_rows()` → `pd.concat([...])` to the glossary table given they are
  likely to recur.
- **Resolution:**

---

## OQ-006

- **File / chunk:** `duplicates.qmd`, `### Counting unique entries`,
  unlabelled chunk, lines 156–161 (post-edit)
- **Status:** open
- **R original:**

  ```r
  penguins_clean_names |> 
    summarise(
    n = n(),
    n_distinct(individual_id)
    )
  ```

- **Issue:** `n_distinct()` has no glossary entry. Separately, the R chunk's
  second `summarise()` argument is unnamed, so R gives the output column a
  derived name rather than `n_distinct` — left as-is per hard rule 1, not
  something to fix here.
- **Candidates:**
  1. `penguins_clean_names.agg(n=("individual_id", "size"), n_distinct=("individual_id", "nunique"))`
  2. `pd.Series({"n": len(penguins_clean_names), "n_distinct": penguins_clean_names["individual_id"].nunique()})`
- **Provisional choice in the book:** 1, marked `# TRANSLATION-NOTE: OQ-006`,
  because the named-tuple `.agg()` form visually mirrors the R `summarise()`
  call's `name = value` shape most closely, consistent with the governing
  principle in `TRANSLATION.md`.
- **Recommendation:** 1, and consider adding `n_distinct(x)` → `.nunique()`
  to the glossary table.
- **Resolution:**

---
