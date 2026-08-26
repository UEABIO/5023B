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

## OQ-020

- **File / chunk:** `summarise.qmd`, `## The data`, unlabelled chunk,
  lines 44–47
- **Status:** open
- **R original:**

  ```r
  penguins <- readRDS(url("https://UEABIO/5023B/raw/refs/heads/2026/files/penguins.RDS"))
  ```

- **Issue:** identical shape to OQ-001/003/010/011/014 — `.RDS` load with no
  Python equivalent, skip-and-logged rather than translated. Separately, the
  URL itself looks broken: every other chapter's equivalent chunk reads
  `https://github.com/UEABIO/5023B/raw/...` — this one is missing
  `github.com/`. Flagged per hard rule 1, left untouched.
- **Candidates:** none — no Python idiom applies.
- **Provisional choice in the book:** no Python tab added for this chunk.
- **Recommendation:** same as prior RDS entries — leave untranslated. A human
  may separately want to fix the malformed URL.
- **Resolution:**

---

## OQ-021

- **File / chunk:** `summarise.qmd`, `## A first glimpse`, pre-existing
  R-only tabset (`glimpse`/`str()`/`skim`, `##` tabs), lines 49–89
  (post-edit)
- **Status:** open
- **R original:** three tabs — `glimpse(penguins)`, `str(penguins)`,
  `skimr::skim(penguins)` — each giving a different structural overview of
  the dataset.
- **Issue:** per `TRANSLATION.md`'s pre-existing-R-only-tabset rule, one
  representative Python tab covers the group. `skim()` (skimr) has no
  accepted Python equivalent — same shape as OQ-007 in `missing-values.qmd`.
  `glimpse()` is already glossary-mapped to `.info()`, which also covers
  most of what `str()` shows.
- **Candidates:** `penguins.info()`.
- **Provisional choice in the book:** as above, marked
  `# TRANSLATION-NOTE: OQ-021`. This chunk is also the chapter's first
  eligible Python tab, so it carries the standard import block.
- **Recommendation:** as implemented, consistent with the OQ-007 precedent.
- **Resolution:**

---

## OQ-022

- **File / chunk:** `summarise.qmd`, `## Frequency counts by subgroups`,
  pre-existing R-only tabset (`Dplyr`/`Janitor`, `##` tabs), lines 197–236
  (post-edit)
- **Status:** open
- **R original:** `Dplyr` tab does
  `group_by(species, sex) |> count() |> arrange(desc(n))`; `Janitor` tab does
  `tabyl(sex, species) |> adorn_percentages("all") |> adorn_totals(c("row",
  "col")) |> adorn_pct_formatting(digits = 1)`.
- **Issue:** per the pre-existing-R-only-tabset rule, one representative
  Python tab covers the group. `tabyl()`/`adorn_*()` (janitor) have no
  accepted Python equivalent, so the representative approach mirrors the
  `Dplyr` tab instead, which is already fully glossary-covered
  (multi-column `count()`, `arrange(desc())`).
- **Candidates:** as implemented — groupby/size/rename/sort_values chain
  mirroring the `Dplyr` tab.
- **Provisional choice in the book:** as above, marked
  `# TRANSLATION-NOTE: OQ-022`.
- **Recommendation:** as implemented, consistent with the OQ-004/OQ-023-style
  precedent for R-only tabsets built on an uncovered package.
- **Resolution:**

---

## OQ-023

- **File / chunk:** `summarise.qmd`, `## Visualising Frequencies`,
  pre-existing R-only tabset (`Geom_col`/`Geom_bar`, `##` tabs, `Geom_col`
  containing a nested `hide()`/`unhide()` "Label the bars" variant),
  lines 244–321 (post-edit)
- **Status:** open
- **R original:** `Geom_col` pre-aggregates counts then plots with
  `geom_col(position = position_dodge2(preserve = "single"))`; its hidden
  variant adds `geom_label()` bar labels; `Geom_bar` lets ggplot aggregate
  directly with the same `position_dodge2()` call.
- **Issue:** one representative Python tab for the whole group, per the
  pre-existing-R-only-tabset rule (the nested hidden "Label the bars"
  variant stays R-only, same as any other tab in the group). `geom_bar`
  chosen as the representative since it doesn't depend on precomputed
  counts. Separately, plotnine's `position_dodge2` support/argument names
  don't reliably match ggplot2's `preserve = "single"` option, so this was
  simplified to a plain `position="dodge"` rather than attempting to match
  the exact dodge behaviour.
- **Candidates:** as implemented.
- **Provisional choice in the book:** as above, marked
  `# TRANSLATION-NOTE: OQ-023`.
- **Recommendation:** as implemented. If `position_dodge2`-equivalent
  behaviour turns out to matter visually, revisit with a closer look at
  plotnine's position adjustments.
- **Resolution:**

---

## OQ-024

- **File / chunk:** `summarise.qmd`, two chunks —
  `### Scatterplots` task-container chunk (`scale_colour_discrete_qualitative()`,
  lines 384–410 post-edit) and the `### Boxplots for group comparisons`
  task-container chunk (`scale_fill_discrete_qualitative()`, lines 718–744
  post-edit)
- **Status:** open
- **R original:** both call a `scale_*_discrete_qualitative()` function from
  the `colorspace` package (loaded in the chapter's setup chunk).
- **Issue:** `colorspace`'s discrete qualitative palette functions aren't in
  the Stack or glossary, and plotnine has no direct equivalent worth
  inventing on the spot. Rather than approximate with an unrelated plotnine
  scale, the call was omitted from both Python tabs — the preceding
  `colour=`/`fill=` aesthetic mapping alone still produces a qualitative
  (if differently-coloured) plot, consistent with the standing warning that
  plotnine and ggplot2 palettes differ.
- **Candidates:**
  1. Omit the scale call (implemented).
  2. Approximate with `scale_color_hue()`/`scale_fill_hue()` — rejected, an
     invented substitute for a specific named function the glossary doesn't
     cover, going beyond what the ambiguity protocol allows.
- **Provisional choice in the book:** 1, marked
  `# TRANSLATION-NOTE: OQ-024` at the first occurrence only (the second
  reuses the same resolved idiom, matching the `dmy()`-reuse precedent in
  `dates.qmd`).
- **Recommendation:** 1. Worth a glossary decision if `colorspace` scales
  recur further into the book.
- **Resolution:**

---

## OQ-025

- **File / chunk:** `summarise.qmd`, two chunks — `## Correlation`
  (lines 424–449 post-edit) and its grouped task-container variant
  (lines 463–493 post-edit)
- **Status:** open
- **R original:** `summarise(r = cor(culmen_length_mm, culmen_depth_mm, use
  = "complete.obs"))`, ungrouped and then grouped by species.
- **Issue:** `cor(x, y, use = "complete.obs")` has no glossary entry.
- **Candidates:**
  1. Ungrouped: `pd.DataFrame({"r": [x.corr(y)]})`, matching pandas'
     `Series.corr()`'s default pairwise-complete NaN handling to R's
     `use = "complete.obs"`. Grouped:
     `.groupby("species").apply(lambda d: pd.Series({"r": ...})).reset_index()`.
  2. `penguins[["culmen_length_mm", "culmen_depth_mm"]].corr()` (a full
     correlation matrix) — rejected, since it returns a 2×2 matrix rather
     than the single value the R tab's `r =` column produces, breaking the
     visual parallel.
- **Provisional choice in the book:** 1, marked `# TRANSLATION-NOTE: OQ-025`
  at the first (ungrouped) occurrence only.
- **Recommendation:** 1, and consider adding `cor(x, y, use =
  "complete.obs")` → `x.corr(y)` to the glossary, since correlation is
  likely to recur in modelling chapters.
- **Resolution:**

---

## OQ-026

- **File / chunk:** `summarise.qmd`, `## GGally`, unlabelled chunk,
  lines 787–792
- **Status:** open
- **R original:**

  ```r
  library(GGally)
  penguins |> 
    ggpairs(columns = 10:12, ggplot2::aes(colour = species))
  ```

- **Issue:** `GGally::ggpairs()` has no accepted Python equivalent in
  `TRANSLATION.md`. The closest Python analogue, seaborn's `pairplot()`,
  can't be used as a substitute since the Stack table explicitly rules out
  seaborn (`Not matplotlib or seaborn`). Per CLAUDE.md's "skip and log"
  category for chunks relying on an R package with no accepted Python
  equivalent, this chunk is skip-and-logged rather than translated.
- **Candidates:** none within the current Stack.
- **Provisional choice in the book:** no Python tab added for this chunk.
- **Recommendation:** revisit only if the Stack table is ever extended with
  a pairs-plot-capable package.
- **Resolution:**

---

## OQ-027

- **File / chunk:** `poisson.qmd`, first `quasipoisson()` chunk (`### Fit
  quasi-Poisson and negative binomial models`) and the `glm.nb()` chunk
  immediately below it
- **Status:** resolved
- **R original:**

  ```r
  cuckoo_quasi <- glm(Beg ~ Mass * Species, data = cuckoo, family = quasipoisson(link = "log"))
  cuckoo_negbin <- glm.nb(Beg ~ Mass * Species, data = cuckoo)
  ```

- **Issue:** neither `quasipoisson()` nor `MASS::glm.nb()` has a settled
  statsmodels mechanism in `TRANSLATION.md`; this recurs in `binomial.qmd`
  and the mixed-model chapters, so it's decided once here rather than
  per-chunk (human, chat, 2026-08-26: seed glossary entries now).
- **Candidates:** as written into `TRANSLATION.md`'s new "GLM families"
  section — `quasipoisson()` via `smf.glm(...).fit(scale="X2")`; `glm.nb()`
  via `smf.negativebinomial(...).fit()`, noting `alpha ≈ 1/theta`.
- **Provisional choice in the book:** as implemented, marked
  `# TRANSLATION-NOTE: OQ-027` at each chunk's first occurrence.
- **Recommendation:** as implemented.
- **Resolution:** glossary entries added to `TRANSLATION.md` under "GLM
  families (base R to statsmodels)" before translating the rest of the
  chapter.

---

## OQ-028

- **File / chunk:** `poisson.qmd`, every `emmeans(...) |> as_tibble()`
  prediction block (first occurrence: `### Generate predictions on the
  response scale`, chunk after `cuckoo_glm_add`)
- **Status:** resolved
- **R original:** see `TRANSLATION.md`'s "Prediction grids with confidence
  intervals" section for the representative form.
- **Issue:** `emmeans()` has no glossary entry and recurs roughly six times
  in this chapter alone as the mechanism for generating predictions with
  confidence intervals for plotting.
- **Candidates:** as written into `TRANSLATION.md` — an explicit prediction
  grid `DataFrame` passed to `model.get_prediction(grid).summary_frame()`.
- **Provisional choice in the book:** as implemented, marked
  `# TRANSLATION-NOTE: OQ-028` at the first occurrence only; later
  occurrences reuse the same idiom silently, consistent with the
  `dmy()`/OQ-024 reuse precedent.
- **Recommendation:** as implemented. Column names differ from emmeans'
  output (`mean`/`mean_ci_lower`/`mean_ci_upper` vs `rate`/`asymp.LCL`/
  `asymp.UCL`); downstream plotting code uses the Python names.
- **Resolution:** glossary entry added to `TRANSLATION.md` before
  translating the rest of the chapter.

---

## OQ-029

- **File / chunk:** `poisson.qmd`, `## How do modelling decisions affect
  inference?`, the `tidy(cuckoo_glm_int, conf.int = TRUE)` chunk and its two
  siblings
- **Status:** resolved
- **R original:** see `TRANSLATION.md`'s "Coefficient tables" section.
- **Issue:** `broom::tidy()` has no glossary entry and recurs four times in
  this chapter, extracting coefficient tables (plain and exponentiated) from
  fitted models.
- **Candidates:** as written into `TRANSLATION.md` — a `DataFrame` built
  directly from `model.params`/`.bse`/`.conf_int()`/`.pvalues`.
- **Provisional choice in the book:** as implemented, marked
  `# TRANSLATION-NOTE: OQ-029` at the first occurrence only, reused silently
  afterward.
- **Recommendation:** as implemented.
- **Resolution:** glossary entry added to `TRANSLATION.md` before
  translating the rest of the chapter.

---

## OQ-030

- **File / chunk:** `poisson.qmd`, `anova(cuckoo_glm_add, cuckoo_glm_int)`
  (`### Comparing model predictions`) and `drop1(cuckoo_quasi, test = "F")`
  (`### Extracting key values for reporting`, `eval: false` chunk)
- **Status:** resolved
- **R original:** see `TRANSLATION.md`'s "Nested-model comparison" section.
- **Issue:** neither `anova()` on two GLMs nor `drop1(model, test = "F")` has
  a one-line statsmodels equivalent.
- **Candidates:** `anova()` → a manual likelihood-ratio test via `.llf` and
  `scipy.stats.chi2.sf()`, as written into `TRANSLATION.md`. `drop1()` has no
  equivalent at all — no per-term F-test utility exists in statsmodels for
  GLMs — so the Python tab notes the gap rather than approximating a
  per-term loop.
- **Provisional choice in the book:** `anova()` translated per the glossary
  entry, marked `# TRANSLATION-NOTE: OQ-030`; `drop1()` left as a comment
  noting no equivalent, same marker.
- **Recommendation:** as implemented.
- **Resolution:** glossary entry added to `TRANSLATION.md` before
  translating the rest of the chapter.

---

## OQ-031

- **File / chunk:** `poisson.qmd`, every `performance::check_model()` and
  `check_overdispersion()` call (first occurrence: `## When Linear models
  fail`, task chunk `check_model(cuckoo_lm, detrend = FALSE)`)
- **Status:** resolved
- **R original:** see `TRANSLATION.md`'s "Model diagnostics" section.
- **Issue:** the `performance` package has no Python equivalent, and its
  diagnostic calls recur roughly nine times through this chapter as the
  mechanism for teaching residual/dispersion diagnostics — central to the
  chapter's point, not a side detail, so skip-and-log for every occurrence
  was rejected in favour of a settled per-check mapping (human, chat,
  2026-08-26: "use statsmodels diagnostics including the appropriate checks
  for each cell").
- **Candidates:** as written into `TRANSLATION.md` — Q-Q plot via
  `sm.qqplot()`, residuals-vs-fitted via a plain matplotlib scatter, and the
  dispersion ratio via `model.pearson_chi2 / model.df_resid`, each matched to
  the specific `check =` argument (or absence of one) in the R chunk being
  translated. This is a deliberate, logged exception to the Stack's
  plotnine-only plotting rule, since neither plotnine nor any listed package
  produces these diagnostic plots.
- **Provisional choice in the book:** as implemented, marked
  `# TRANSLATION-NOTE: OQ-031` at the first occurrence only, reused silently
  for the rest.
- **Recommendation:** as implemented. `performance`'s dispersion *plot*
  (grey variance-mean curve vs observed points) has no attempted equivalent,
  only its underlying ratio statistic — noted inline where that chunk is
  translated.
- **Resolution:** glossary entry added to `TRANSLATION.md` before
  translating the rest of the chapter.

---

## OQ-032

- **File / chunk:** `poisson.qmd`, `### The Poisson distribution and
  log-link`, unlabelled chunk (`{r, eval = T, echo=F}`), the `dpois()`
  barplot demonstration
- **Status:** open
- **R original:**

  ```r
  cols <- c("#377eb8", "#4daf4a", "#984ea3") # colorbrewer
  par(mfrow = c(3, 1))
  x <- 0:20
  rates <- c(1, 5, 10)
  barplot(dpois(x, rates[1]), col = cols[1], ylab = "Probability", xlab = "X", main = paste0("lambda = ", rates[1]), names.arg = x)
  for(i in 2:length(rates)) barplot(dpois(x, rates[i]), col = cols[i], ylab = "Probability", xlab = "X", main = paste0("lambda = ", rates[i]), names.arg = x)
  par(mfrow = c(1, 1))
  ```

- **Issue:** `echo=F` hides this chunk's source in the rendered R book — a
  reader only ever sees the resulting barplots, never this code. None of
  CLAUDE.md's named skip-silent categories cover it exactly (it's not a
  library-load/source/import setup chunk, and it's not
  `knitr::include_graphics()`), but adding a Python tab here would pair
  visible Python source against an R tab that renders with no visible
  source at all — an asymmetry none of the book's existing tabsets have.
  Treated as a judgement call and skip-logged rather than guessed at,
  consistent with hard rule 1 ("if an R chunk looks wrong... log it").
- **Candidates:** the content itself is trivially portable
  (`scipy.stats.poisson.pmf()` plus matplotlib bar plots), so this is a
  presentation question, not a translation gap.
- **Provisional choice in the book:** no Python tab added for this chunk.
- **Recommendation:** if a human decides `echo=F` demonstration chunks like
  this one should get a Python tab regardless (accepting the visible-code
  asymmetry), extend the "Setup chunks" section of `TRANSLATION.md` to say
  so explicitly, so later chapters don't re-raise the same question.
- **Resolution:**

---

## OQ-033

- **File / chunk:** `binomial.qmd`, `binomial_model <- glm(cbind(number_killed,number_survived) ~ dose, family = binomial, data = beetles)` (`## Fitting a binomial model`) and the quasi-likelihood task's `glm(cbind(...), family = quasibinomial, ...)` (`## Assumptions`)
- **Status:** resolved
- **R original:** see `TRANSLATION.md`'s "GLM families" table for the
  representative forms.
- **Issue:** neither plain `family = binomial(link = logit)` nor the
  `cbind(successes, failures) ~ x` two-column response form, nor
  `quasibinomial`, had a glossary entry.
- **Candidates:** `sm.families.Binomial()` for the family; statsmodels'
  formula API accepts a `successes + failures ~ x` left-hand side as the
  equivalent of R's `cbind()` two-column binomial response; `quasibinomial`
  via the same `scale="X2"` mechanism already settled for quasi-Poisson
  under OQ-027.
- **Provisional choice in the book:** as implemented, marked
  `# TRANSLATION-NOTE: OQ-033` at each chunk's first occurrence.
- **Recommendation:** as implemented.
- **Resolution:** glossary entries added to `TRANSLATION.md`'s "GLM
  families" table before translating the rest of the chapter.

---

## OQ-034

- **File / chunk:** `binomial.qmd`, `## Binomial vs Linear Model`,
  `DescTools::PseudoR2(binomial_model)`
- **Status:** resolved
- **R original:**

  ```r
  DescTools::PseudoR2(binomial_model)
  ```

- **Issue:** `DescTools` has no Stack/glossary coverage, and `PseudoR2()`'s
  default (McFadden's pseudo R²) has no statsmodels one-liner.
- **Candidates:** `1 - model.llf / model.llnull`, using the two
  log-likelihoods statsmodels' GLM results already carry — arithmetically
  identical to McFadden's R². `DescTools::PseudoR2()` can return other
  variants (Cox-Snell, Nagelkerke, …) via an argument the R chunk doesn't
  use, so only the default is covered.
- **Provisional choice in the book:** as implemented, marked
  `# TRANSLATION-NOTE: OQ-034`.
- **Recommendation:** as implemented.
- **Resolution:** glossary entry added to `TRANSLATION.md`'s "GLM families"
  table before translating the rest of the chapter.

---

## OQ-035

- **File / chunk:** `binomial.qmd`, `## Fitting a binomial model`,
  pre-existing R-only tabset (`summary`/`broom`, `##` tabs)
- **Status:** open
- **R original:** `summary` tab calls `summary(binomial_model)`; `broom` tab
  calls `binomial_model |> broom::tidy(conf.int = T)`.
- **Issue:** per `TRANSLATION.md`'s pre-existing-R-only-tabset rule, one
  representative Python tab covers the group. Unlike the earlier
  `duplicates.qmd`/`missing-values.qmd`/`summarise.qmd` cases, both existing
  R tabs here already have full glossary coverage (`model.summary()`; the
  `tidy()` helper from OQ-029), so either could serve as the representative.
- **Candidates:** 1. `binomial_model.summary()` — the more direct, single-call
  mirror of R's own `summary()`. 2. The `tidy()` helper from OQ-029 — richer
  output, but requires carrying that helper's definition into a chapter that
  wouldn't otherwise need it.
- **Provisional choice in the book:** 1, marked
  `# TRANSLATION-NOTE: OQ-035`, since it needs no supporting helper function
  and mirrors the plainer of the two R tabs directly.
- **Recommendation:** as implemented.
- **Resolution:**

---

## OQ-036

- **File / chunk:** `binomial.qmd`, two pre-existing R-only tabsets —
  `### Making predictions` (`Augment`/`Emmeans`, `##` tabs) and the hidden
  solution inside the `Make a ggplot of the change in probability` task
  (`Broom`/`Emmeans`, `##` tabs, nested inside `r hide()`/`r unhide()` inside
  a task-container)
- **Status:** open
- **R original:** each pairs a `broom::augment(binomial_model, data =
  beetles, type.predict = "response")`-based approach against an
  `emmeans::emmeans(binomial_model, ...) |> as_tibble()`-based approach to
  the same prediction task.
- **Issue:** per the pre-existing-R-only-tabset rule, one representative
  Python tab per group. Both tabsets are resolved the same way, so logged
  together rather than twice. `broom::augment()` itself never gets its own
  glossary entry in this chapter as a result — it isn't used anywhere
  outside these two R-only tabsets.
- **Candidates:** the Emmeans tab, reusing the prediction-grid idiom already
  settled under OQ-028 (`grid.assign(**model.get_prediction(grid).summary_frame())`),
  chosen over the Augment tab for consistency with every other prediction
  block already translated in this book.
- **Provisional choice in the book:** as implemented, marked
  `# TRANSLATION-NOTE: OQ-036` at the first occurrence only. Separately: the
  second tabset (inside the hidden solution) is a pre-existing `:::` (3
  colons) nested directly inside a `::::{.task-container}` (4 colons) — one
  colon short of the fence-arithmetic rule's minimum. Left as-is per hard
  rule 1 (not an R chunk or prose line, but not mine to silently "fix"
  either); the new Python tab is added at the same 3 colons as the existing
  R tabs, matching what's already there rather than what the rule would
  otherwise require.
- **Recommendation:** the colon-count anomaly is worth a human check against
  the rendered book — if the task styling collapses there, the fix is to
  bump this specific tabset to 5 colons, unrelated to translation.
- **Resolution:**

---

## OQ-037

- **File / chunk:** `binomial.qmd`, three `echo=F` demonstration-plot
  chunks: the `bernplot`-labelled `dbinom()` barplot (`## Logistic
  regression...` intro), the identity-line `logit(p)` plot, and the
  inverse-logit curve plot (both unlabelled, same section)
- **Status:** open
- **R original:** base-R `barplot()`/`plot()` calls, each `echo=F` so no
  source is shown to the reader in the R book — same shape as OQ-032 in
  `poisson.qmd`.
- **Issue:** as OQ-032: `echo=F` means the R tab would render with no
  visible source, so pairing it with a visibly-sourced Python tab would be
  the only asymmetric tabset of its kind. All three occurrences in this
  chapter share the identical shape, logged together rather than three
  times.
- **Candidates:** all three are trivially portable (`scipy.stats.bernoulli`/
  `binom.pmf()` and matplotlib line plots), so, as with OQ-032, this is a
  presentation question, not a translation gap.
- **Provisional choice in the book:** no Python tab added for any of the
  three chunks.
- **Recommendation:** same as OQ-032 — if a human settles how `echo=F`
  demonstration chunks should be handled generally, apply that decision to
  both this entry and OQ-032 at once.
- **Resolution:**

---

## OQ-038

- **File / chunk:** `binomial.qmd`, `## Data tidying`, hidden solution
  inside the "Your turn" task
- **Status:** open
- **R original:**

  ```r
  beetles <- beetles |>
    janitor::clean_names() |> # clean names
    mutate(number_survived = number_tested-number_killed) # mutate
  ```

- **Issue:** `janitor::clean_names()` has no glossary entry. In general it
  lowercases, snake_cases and de-duplicates column names; here the source
  columns are already single words with underscores (`Dose`,
  `Number_tested`, `Number_killed`, `Mortality_rate`), so the only actual
  transformation needed is lowercasing.
- **Candidates:** 1. `beetles.columns = beetles.columns.str.lower()` —
  covers exactly what this dataset's columns need. 2. A more general
  regex-based port of `clean_names()`'s full behaviour (punctuation
  stripping, de-duplication) — rejected as over-engineering for a column
  set that doesn't exercise any of that.
- **Provisional choice in the book:** 1, marked
  `# TRANSLATION-NOTE: OQ-038`.
- **Recommendation:** 1. Revisit with the fuller port if a later chapter's
  `clean_names()` call meets messier column names that need it.
- **Resolution:**

---

## OQ-039

- **File / chunk:** `week-4.qmd`, `## Script: \`01_data_preparation.R\``,
  hidden solution under "Range of Samples"
- **Status:** open
- **R original:**

  ```r
  mayfly_raw |> 
    summarise(max = max(`samples_collected`),
              min = min(`samples_collected`),
              mean = mean(`samples_collected`),
              n_sites = n(),
              n_samples = sum(`samples_collected))
  ```

- **Issue:** the final line has a stray unmatched backtick before
  `samples_collected` and appears to be missing the `summarise()` call's
  closing parenthesis — as written this would not parse in R. Flagged per
  hard rule 1 and left untouched; translated to the evident intent (closing
  the backtick-quoted name and the call correctly) rather than mirroring
  the syntax error, since a syntactically invalid line has no faithful
  Python mirror.
- **Candidates:** n/a — not a translation ambiguity, an R source bug.
- **Provisional choice in the book:** translated as if the line read
  `n_samples = sum(\`samples_collected\`))`, marked
  `# TRANSLATION-NOTE: OQ-039`.
- **Recommendation:** a human may want to fix the stray backtick/paren
  directly in the R chunk (outside this translation workflow).
- **Resolution:**

---

## OQ-040

- **File / chunk:** `week-4.qmd`, `## Script: \`01_data_preparation.R\``,
  hidden solution under "Possible solutions" (data quality checks)
- **Status:** open
- **R original:**

  ```r
  mayfly |> 
     filter(samples_with mayfly > samples_collected)
  
  mayfly |> 
    mayfly |> 
    summarise(across(where(is.numeric), 
                     list(max = ~max(.x, na.rm = TRUE), 
                          min = ~min(.x, na.rm = TRUE))))
  
  skimr::skim(mayfly)
  ```

- **Issue:** three separate problems in one chunk, all flagged per hard rule
  1 and left untouched in the R chunk. First, `samples_with mayfly` is
  missing its underscore (invalid R syntax as written — a bare space
  between two names). Second, `mayfly |> mayfly |> summarise(...)` pipes the
  same object into itself twice, a copy-paste duplicate. Third,
  `skimr::skim()` has no Python equivalent, same shape as OQ-007/OQ-021.
- **Candidates:** filter translated using the evident intended column name
  `samples_with_mayfly`; the duplicate pipe line collapsed to a single
  `.select_dtypes("number").agg(["max", "min"])` call (the
  `across(where(is.numeric), ...)` idiom from OQ-015); `skim()` substituted
  with `.info()`, consistent with the OQ-007/OQ-021 precedent.
- **Provisional choice in the book:** as implemented, marked
  `# TRANSLATION-NOTE: OQ-040` once for the whole chunk.
- **Recommendation:** a human may want to fix the typo and remove the
  duplicate pipe directly in the R chunk (outside this translation
  workflow).
- **Resolution:**

---

## OQ-041

- **File / chunk:** `week-4.qmd`, `## Script: \`01_data_preparation.R\``,
  hidden solution under "6. Exploratory visualisation"
- **Status:** open
- **R original:**

  ```r
  mayfly |> 
    ggplot(aes(x = log_copper_ugl,
               y = prop_mayfly))+
    geom_point(aes(size = samples_collected))
  ```

- **Issue:** `log_copper_ugl` is never created anywhere in this chapter's
  visible chunks (only `copper_ugl`, `samples_without_mayfly` and
  `prop_mayfly` are). Looks like a planned-but-missing `mutate(log_copper_ugl
  = log(copper_ugl))` step. Per hard rule 1, left untouched and mirrored for
  parallelism rather than fixed, same treatment as OQ-013 before its
  human-authorised exception.
- **Candidates:** n/a — not a translation ambiguity, a missing-variable bug.
- **Provisional choice in the book:** the undefined column name carried
  across unchanged into the Python tab, marked
  `# TRANSLATION-NOTE: OQ-041`.
- **Recommendation:** a human may want to add the missing `mutate()` step
  (or fix the reference to `copper_ugl`) directly in the R chunk.
- **Resolution:**

---

## OQ-042

- **File / chunk:** `week-4.qmd`, `## Script: \`01_data_preparation.R\``,
  "7. Correlation check"
- **Status:** open
- **R original:**

  ```r
  mayfly |> 
  GGally::ggpairs(columns = c(6,7,9))
  ```

- **Issue:** identical shape to OQ-026 in `summarise.qmd` — `GGally::ggpairs()`
  has no accepted Python equivalent in `TRANSLATION.md`, and seaborn is
  explicitly ruled out by the Stack table. Skip-and-logged rather than
  translated.
- **Candidates:** none within the current Stack.
- **Provisional choice in the book:** no Python tab added for this chunk.
- **Recommendation:** same as OQ-026 — revisit only if the Stack is
  extended with a pairs-plot-capable package.
- **Resolution:**

---
