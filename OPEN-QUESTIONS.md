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

---
