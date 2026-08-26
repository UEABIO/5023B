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

## OQ-007

- **File / chunk:** `missing-values.qmd`, `## Find Missing values`,
  pre-existing R-only tabset (`summary()`, `skim()`, `vis_miss()`,
  `upset_plot()` tabs, lines 102–134 pre-edit)
- **Status:** open
- **R original:** four tabs, each showing a different R package's approach
  to surfacing missing data (`summary()` base R; `skimr::skim()`;
  `naniar::vis_miss()`; `naniar::gg_miss_upset()`).
- **Issue:** per `TRANSLATION.md`'s pre-existing-R-only-tabset rule, only one
  representative Python tab is added for the whole group. None of `skimr`
  or `naniar` has an accepted Python equivalent in the Stack table, so the
  representative approach has to be a plain pandas idiom rather than a port
  of any one of the four R tabs.
- **Candidates:**
  1. `penguins_clean_names.isna().sum()` — per-column missing-value counts.
  2. `penguins_clean_names.info()` — already mapped to `glimpse()` elsewhere;
     shows non-null counts but is a less direct match to "find missing
     values" as a task.
- **Provisional choice in the book:** 1, marked `# TRANSLATION-NOTE: OQ-007`,
  because it most directly answers "how much is missing, and where" without
  requiring an unlisted package.
- **Recommendation:** 1. If a Python missing-data visualisation package
  (e.g. `missingno`) is ever added to the Stack table, this is the natural
  chunk to revisit for a closer visual match to `vis_miss()`/`upset_plot()`.
- **Resolution:**

---

## OQ-008

- **File / chunk:** `missing-values.qmd`, `## Find Missing values`,
  unlabelled chunk, lines 148–174 (post-edit)
- **Status:** open
- **R original:**

  ```r
  penguins_clean_names |> 
    filter(if_any(everything(), is.na)) |>
    select(culmen_length_mm, culmen_depth_mm, flipper_length_mm, 
           sex, delta_15n, delta_13c,comments,
           everything()) # reorder columns
  ```

- **Issue:** neither `if_any(everything(), is.na)` nor `select(..., everything())`
  as a column-reorder idiom has a glossary entry.
- **Candidates:**
  1. Filter: `.loc[lambda d: d.isna().any(axis=1)]`. Reorder: build a
     `first_cols` list and concatenate it with the remaining columns in
     original order, mirroring the intermediate-variable pattern already
     used for `separate()` in `strings.qmd`.
  2. `.reindex(columns=[...])` with an explicit full column list — rejected,
     since it requires spelling out every column name rather than just the
     ones being promoted, losing the parallel with `everything()`.
- **Provisional choice in the book:** 1, marked `# TRANSLATION-NOTE: OQ-008`.
- **Recommendation:** 1, and consider adding `if_any(everything(), is.na)` →
  `.isna().any(axis=1)` to the glossary, since it is likely to recur.
- **Resolution:**

---

## OQ-009

- **File / chunk:** `missing-values.qmd`, `## Find Missing values`,
  unlabelled chunk, lines 177–194 (post-edit)
- **Status:** open
- **R original:**

  ```r
  penguins_clean_names |> 
    filter(if_any(culmen_length_mm, is.na))  # reorder columns
  ```

- **Issue:** two problems. First, `if_any(col, is.na)` on a single column has
  no glossary entry (though it follows directly from the existing
  `filter(x > 3)` → `.loc[lambda d: d["x"] > 3]` pattern once `is.na` is
  treated as the condition). Second, the trailing comment `# reorder columns`
  does not describe this chunk — it only filters, and does not reorder
  anything — and looks like a copy-paste leftover from the chunk immediately
  above it (OQ-008), which does reorder. Per the comment-carrying rule in
  `TRANSLATION.md` (added after the `strings.qmd` review), the comment was
  dropped from the Python tab rather than carried across or reworded, since
  it describes neither the R code above it nor the Python code below it. The
  R chunk itself is unchanged, per hard rule 1.
- **Candidates:** `.loc[lambda d: d["culmen_length_mm"].isna()]`.
- **Provisional choice in the book:** as above, marked
  `# TRANSLATION-NOTE: OQ-009`, comment dropped.
- **Recommendation:** a human may want to fix or remove the stale R comment
  directly (outside this translation workflow).
- **Resolution:**

---

## OQ-010

- **File / chunk:** `missing-values.qmd`, unlabelled chunk inside
  `.callout-important` (`## Penguin clean names dataset`), lines 21–24
- **Status:** open
- **R original:**

  ```r
  penguins_clean_names <- readRDS(url("https://github.com/UEABIO/5023B/raw/refs/heads/2026/files/penguins.RDS"))"))
  ```

- **Issue:** identical shape to OQ-001/OQ-003 — `.RDS` load with no Python
  equivalent, skip-and-logged rather than translated. Separately, the R
  chunk itself has a stray trailing `"))` after the closing paren that looks
  like a typo (an extra, unmatched `"))`) — flagged per hard rule 1, left
  untouched.
- **Candidates:** none — no Python idiom applies.
- **Provisional choice in the book:** no Python tab added for this chunk.
- **Recommendation:** same as OQ-001/OQ-003 — leave untranslated. A human may
  separately want to check whether the trailing `"))` is a real syntax error
  in the source R chunk.
- **Resolution:**

---

## OQ-011

- **File / chunk:** `dates.qmd`, unlabelled chunk inside `.callout-important`
  (`## Penguin clean names dataset`), lines 16–19
- **Status:** open
- **R original:**

  ```r
  penguins_clean_names <- readRDS(url("https://github.com/UEABIO/5023B/raw/refs/heads/2026/files/penguins.RDS"))
  ```

- **Issue:** identical shape to OQ-001/OQ-003/OQ-010 — `.RDS` load with no
  Python equivalent, skip-and-logged rather than translated.
- **Candidates:** none — no Python idiom applies.
- **Provisional choice in the book:** no Python tab added for this chunk.
- **Recommendation:** same as OQ-001/OQ-003/OQ-010 — leave untranslated.
- **Resolution:**

---

## OQ-012

- **File / chunk:** `dates.qmd`, `## Reformat`, unlabelled chunk (the
  failed-parse illustration), lines 126–157 (post-edit)
- **Status:** open
- **R original:**

  ```r
  df <- tibble(
    date = c("X2020.01.22",
             "X2020.01.22",
             "X2020.01.22",
             "X2020.01.22")
  )

  df |> 
    mutate(
      date = as_date(date)
    )
  ```

- **Issue:** this chunk exists specifically to demonstrate that `as_date()`
  on an unparsable format returns `NA` with a warning rather than an error
  (shown in the literal output block immediately below the R chunk).
  `pd.to_datetime()` without `errors=` raises an exception on the same input
  instead of warning, which would break the demonstration's point.
  `TRANSLATION.md`'s new `as_date(x)` → `pd.to_datetime(x)` glossary entry
  doesn't specify error-handling behaviour.
- **Candidates:**
  1. `pd.to_datetime(d["date"], errors="coerce")` — silently returns `NaT`
     for unparsable values, closer in spirit to "the conversion fails
     quietly" than to R's specific warn-and-NA behaviour.
  2. Leave `errors=` unset and let it raise — a truer default, but would
     make the Python tab error where the R tab merely warns, which reads as
     broken code in a book context.
- **Provisional choice in the book:** 1, marked `# TRANSLATION-NOTE: OQ-012`.
- **Recommendation:** 1, and consider adding `errors="coerce"` to the
  `as_date()` glossary entry generally, since R's date-parsing functions
  warn-and-NA on failure much more often than Python's raise.
- **Resolution:**

---

## OQ-013

- **File / chunk:** `dates.qmd`, `### Filter dates`, unlabelled chunk,
  lines 386–408 (post-edit)
- **Status:** resolved
- **R original (before human-authorised fix):**

  ```r
  # return records after 2008
  plants |>
    filter(date_egg >= ymd("2008-01-01"))
  ```

- **Issue:** `plants` is never defined anywhere in this chapter — every
  other chunk operates on `penguins_clean_names`. Looks like a copy-paste
  leftover from another chapter/dataset. Per hard rule 1 this would normally
  be left untouched and only logged, with the Python sibling mirroring
  `plants` for parallelism with the (broken) R tab.
- **Candidates:** n/a — not a translation ambiguity, a data-reference bug.
- **Resolution:** the human maintainer explicitly authorised an exception to
  hard rule 1 for this one case (chat, 2026-08-26): `plants` replaced with
  `penguins_clean_names` in **both** the R chunk and its new Python sibling.
  This is a deliberate, human-directed deviation from "never modify an
  existing R chunk", not an unauthorised edit — noted here so the `git diff`
  showing one R-line change on this chapter is explained rather than
  mistaken for an error.

---

## OQ-014

- **File / chunk:** `numeric-plausibility.qmd`, unlabelled chunk inside
  `.callout-important` (`## Penguin clean names dataset`), lines 17–20
- **Status:** open
- **R original:**

  ```r
  penguins_clean_names <- readRDS(url("https://github.com/UEABIO/5023B/raw/refs/heads/2026/files/penguins.RDS"))
  ```

- **Issue:** identical shape to OQ-001/003/010/011 — `.RDS` load with no
  Python equivalent, skip-and-logged rather than translated.
- **Candidates:** none — no Python idiom applies.
- **Provisional choice in the book:** no Python tab added for this chunk.
- **Recommendation:** same as prior RDS entries — leave untranslated.
- **Resolution:**

---

## OQ-015

- **File / chunk:** `numeric-plausibility.qmd`, `### Basic range checks`,
  unlabelled chunk, lines 47–69 (post-edit)
- **Status:** open
- **R original:**

  ```r
  # Check ranges of all numeric variables at once
  penguins_clean_names |> 
    summarise(across(where(is.numeric), 
                     list(min = ~min(., na.rm = TRUE),
                          max = ~max(., na.rm = TRUE))))
  ```

- **Issue:** `across(where(is.numeric), list(...))` — applying an aggregation
  to every numeric column at once — has no glossary entry.
- **Candidates:**
  1. `penguins_clean_names.select_dtypes("number").agg(["min", "max"])`
  2. Manually list every numeric column's min/max via `.agg()` named tuples —
     rejected, since it loses the point of `across(where(is.numeric), ...)`,
     which is that it doesn't require naming the columns.
- **Provisional choice in the book:** 1, marked `# TRANSLATION-NOTE: OQ-015`.
  Output shape differs from the R original (pandas returns min/max as rows
  with one column per variable, rather than one row with a min/max column
  pair per variable), but the values and intent match.
- **Recommendation:** 1, and consider adding `across(where(is.numeric), ...)`
  → `.select_dtypes("number")` to the glossary, since "apply to every numeric
  column" is a recurring data-cleaning task.
- **Resolution:**

---

## OQ-016

- **File / chunk:** `numeric-plausibility.qmd`,
  `### Detecting Impossible values`, unlabelled chunk, lines 101–124
  (post-edit)
- **Status:** open
- **R original:**

  ```r
  # Check for negative values (impossible for mass, length measurements)
  penguins_clean_names |> 
    filter(if_any(c(body_mass_g, flipper_length_mm, 
                    culmen_length_mm, culmen_depth_mm), 
                  ~ . < 0))
  ```

- **Issue:** `if_any()` with an explicit column list and a custom formula
  predicate (`~ . < 0`) is a different shape from OQ-008's
  `if_any(everything(), is.na)` — no glossary entry covers either the
  explicit-column-list form or a non-`is.na` predicate.
- **Candidates:**
  1. Build a `cols` list, then
     `penguins_clean_names.loc[lambda d: (d[cols] < 0).any(axis=1)]`.
  2. Chain `|` across four separate column comparisons — rejected, since it
     doesn't generalise the way `if_any(c(...))` does and reads worse for
     four columns.
- **Provisional choice in the book:** 1, marked `# TRANSLATION-NOTE: OQ-016`.
- **Recommendation:** 1, and consider adding this shape (`if_any(c(cols), ~
  predicate)` → `(d[cols] OP value).any(axis=1)`) to the glossary alongside
  OQ-008's resolution once both are settled, since together they cover most
  `if_any()` usage in the book.
- **Resolution:**

---

## OQ-017

- **File / chunk:** `numeric-plausibility.qmd`,
  `### Cross-variable checks: Spatial consistency`, unlabelled chunk,
  lines 371–395 (post-edit)
- **Status:** open
- **R original:**

  ```r
  # Check which species appear on which islands
  penguins_clean_names |> 
    count(species, island) |> 
    pivot_wider(names_from = island, values_from = n, values_fill = 0)
  ```

- **Issue:** the glossary's `pivot_wider(names_from, values_from)` entry
  doesn't cover `values_fill =`, which fills the empty species/island
  combinations with `0` instead of leaving them as missing.
- **Candidates:**
  1. Chain the existing `count()` and `pivot_wider()` glossary translations,
     then append `.fillna(0)`.
- **Provisional choice in the book:** 1, marked `# TRANSLATION-NOTE: OQ-017`.
- **Recommendation:** 1, and consider adding `values_fill = v` →
  `.fillna(v)` as a general note on the `pivot_wider` glossary entry.
- **Resolution:**

---

## OQ-018

- **File / chunk:** `numeric-plausibility.qmd`,
  `### Flagging suspicious values`, unlabelled chunk, lines 444–525
  (post-edit)
- **Status:** open
- **R original:** see the full chunk — three `case_when()` blocks each ending
  `TRUE ~ NA_character_`, combined into a `!is.na(a) | !is.na(b) | !is.na(c)`
  flag, then summarised with `sum(!is.na(x))` counts.
- **Issue:** two points not settled by the existing glossary. First, R's
  `TRUE ~ NA_character_` "otherwise" branch (rather than `.default =`) maps
  to `np.select`'s `default=`, but the value itself (`None` vs `np.nan` vs
  `pd.NA`) isn't specified anywhere — chose `None` since the array holds
  strings. Second, `sum(!is.na(x))` inside `summarise()` (count of
  non-missing values) has no glossary entry, translated as a named
  aggregation with a lambda: `("col", lambda x: x.notna().sum())`.
- **Candidates:** as implemented — `default=None` in each `np.select()`
  call; `.assign()` split into two chained calls since `any_flag` depends on
  columns created in the first (same reasoning as the `separate()` pattern
  in `strings.qmd`); count-non-missing via a lambda in `.agg()`.
- **Provisional choice in the book:** as above, marked
  `# TRANSLATION-NOTE: OQ-018`.
- **Recommendation:** as implemented. Consider adding `sum(!is.na(x))` →
  `("x", lambda s: s.notna().sum())` to the glossary, since counting
  non-missing flags is likely to recur in later data-cleaning chapters.
- **Resolution:**

---

## OQ-019

- **File / chunk:** `numeric-plausibility.qmd`,
  `### Cross-variable checks: Expected correlations`, unlabelled chunk
  (`fig-mass-flipper`), lines 268–304 (post-edit)
- **Status:** open
- **R original:** the chunk opens with a blank line, then the `#| label:`
  and `#| fig-cap:` option comments, then another blank line, then the code —
  see lines 272–277.
- **Issue:** not a translation ambiguity — flagging per hard rule 1 that the
  R chunk looks wrong. Quarto/knitr require `#|` chunk-option comments to be
  the very first lines immediately after the opening fence; here they're
  preceded by a blank line, which likely means they're read as plain R
  comments rather than real chunk options, so the figure may render without
  the intended label/caption. Left untouched per hard rule 1. The Python
  sibling still carries `#| label: fig-mass-flipper-py` (mirroring the R
  chunk's stated label) even though the same placement question doesn't
  apply there, since the Python option comments were placed correctly.
- **Candidates:** n/a — not a translation ambiguity, a chunk-formatting bug.
- **Resolution:**

---

---
