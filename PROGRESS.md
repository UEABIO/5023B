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
| 1 | `{python}` chunks with `eval: false` render with no Python installed and no reticulate configured | Pass (2026-08-25, human render) |
| 2 | A `.panel-tabset` inside `hide()`/`unhide()` initialises correctly, including the tab that is not active when the container is revealed | Pass (2026-08-25, human render) |
| 3 | A five-colon tabset inside `::::{.task-container}` renders with the task styling intact | Pass (2026-08-25, human render) |
| 4 | `group="language"` syncs across chapters, not merely within a page | Pass (2026-08-25, human render) |
| 5 | `scripts/verify_python.R` runs the pilot chapter's extracted Python without error | Pass (2026-08-25, human render) |

## Chapters

Inventory pass completed 2026-08-25 on branch `2027`. Counts for the seven
files marked exact are a full read; the rest are chunk-header/first-line
surveys and are marked `~` — they get re-verified per-chunk at step 4 of the
`translate-chapter` skill before any edits happen regardless. No pilot
chapter is chosen yet — see "Needs a decision before bulk work" below.

| # | File | Chunks eligible | Status | Open Qs | Commit | Date | Notes |
|---|---|---|---|---|---|---|---|
| 0 | index.qmd | 0 | todo | | | | preface: standing warnings, written last |
| 1 | 03-github.qmd | 1 | todo | | | | mostly usethis/gitcreds auth tooling, skip-log |
| 2 | week-1.qmd | 0 | todo | | | | worksheet, no code |
| 3 | strings.qmd | 16 (exact) | reviewed | 2 | 2b1be5d | 2026-08-25 | **pilot chapter** — pilot gate passed, all 5 checks; OQ-002 resolved same pass |
| 4 | duplicates.qmd | 6 (exact) | translated | 4 | 1cd238c | 2026-08-25 | R-only tabsets handled per TRANSLATION.md; RDS chunk skip-logged (OQ-003); dplyr tab's broken `sum()` flagged, left untouched (OQ-004) |
| 5 | missing-values.qmd | 9 (exact) | translated | 4 | 7b7fb28 | 2026-08-25 | R-only tabset handled per TRANSLATION.md; RDS chunk skip-logged (OQ-010, also has a stray typo); stale "reorder columns" comment dropped, not carried (OQ-009) |
| 6 | dates.qmd | 15 (exact) | translated | 3 | 2633522 | 2026-08-26 | lubridate glossary seeded in TRANSLATION.md first (separate commit) since >8 open questions would otherwise result; `plants` bug in Filter dates fixed to `penguins_clean_names` in both R and Python, human-authorised exception to hard rule 1 (OQ-013) |
| 7 | numeric-plausibility.qmd | 13 (exact) | translated | 6 | 609d270 | 2026-08-26 | 2 base-glossary additions first (multi-condition filter, !is.na); ggplot chunks translated mechanically per Stack/style conventions; one likely-inert `#\|` option placement flagged, not fixed (OQ-019) |
| 8 | week-2.qmd | 0 | translated | 0 | | 2026-08-26 | confirmed on read: sole chunk is a fill-in-the-blank scaffold (`# YOUR CODE HERE` placeholders), no real operation to mirror — no `.qmd` edits made |
| 9 | summarise.qmd | 20 (exact) | translated | 7 | 4ec1d32 | 2026-08-26 | 6 base-glossary additions first (ungrouped count, sd/median/IQR, summarise_at/if); ggpairs skip-logged (OQ-026, no Python equivalent, seaborn ruled out by Stack table); colorspace scale_*_discrete_qualitative() omitted (OQ-024); malformed RDS URL flagged (OQ-020) |
| 10 | poisson.qmd | 30 (exact) | translated | 6 | c0f6db7 | 2026-08-26 | performance/emmeans/glm.nb/quasipoisson/broom/anova idioms seeded in TRANSLATION.md first (OQ-027–031, each resolved-once-reused); `downloadthis::download_link()` treated as skip-silent book furniture (no OQ, analogous to `include_graphics()`); one `echo=F` demo chunk skip-logged (OQ-032) since it has no visible R source to pair a Python tab against |
| 11 | week-3.qmd | 0 | translated | 0 | | 2026-08-26 | confirmed on read: sole `{r}` chunk is `echo=FALSE` `knitr::include_graphics()`, skip-silent; the file's other fenced code blocks (` ```r `, ` ```markdown `, ` ```yaml `) are plain illustrative fences without `{r}`, not executable Quarto chunks — out of scope entirely, no `.qmd` edits made |
| 12 | binomial.qmd | 25 (exact) | translated | 6 | cd5a2ee | 2026-08-26 | reused poisson.qmd's emmeans/broom/performance idioms throughout; new GLM-family idioms for binomial/quasibinomial + cbind() formulas and `DescTools::PseudoR2()` seeded (OQ-033/034); three pre-existing R-only tabsets got one Python tab each (OQ-035/036), one nested 3-colon tabset left under-nested inside its 4-colon task-container per hard rule 1 (flagged, not fixed); three more `echo=F` demo-plot chunks skip-logged (OQ-037, same shape as OQ-032); `janitor::clean_names()` idiom seeded (OQ-038) |
| 13 | week-4.qmd | 6 (exact) | translated | 4 | 8d82c1a | 2026-08-26 | unlike week-2/3.qmd this is a workshop scaffold with real hidden-solution `{r, eval=FALSE}` chunks, not placeholders — all 6 eligible and translated; two chunks have pre-existing R bugs flagged and translated to evident intent (OQ-039/040); one carries forward an undefined-variable bug for parallelism (OQ-041); `GGally::ggpairs()` skip-logged reusing OQ-026's precedent (OQ-042); `skimr::skim()` substitution reuses OQ-007/021's `.info()` precedent |
| 14 | mixed-model.qmd | 0 | translated | 0 | | 2026-08-26 | confirmed on read: both `{r}` chunks are `echo=F`/library-load-only setup chunks, skip-silent — no `.qmd` edits made |
| 15 | intro-mixed-model.qmd | 28 (exact) | translated | 8 | 9b6f9a3 | 2026-08-26 | biggest Stack decision yet: adopted `pymer4` (wraps lme4 via rpy2) for all `lmer()`/`glmer()` calls including nested formulas and binomial GLMMs (OQ-043/044) — the one Python idiom in the book needing a local R install; `MuMIn::r.squaredGLMM()` reimplemented manually (OQ-045); `sjPlot::tab_model()` skip-logged (OQ-046); `DiagrammeR` diagram skip-logged for being `echo=F`, idiom kept for a future visible occurrence (OQ-047); `aggregate()` idiom seeded (OQ-048); every `emmeans`/`ggpredict` confidence-ribbon chunk skip-logged as a standing rule since no Python tool computes mixed-model prediction CIs, point-prediction-only chunks kept (OQ-049); `rats.rds` skip-logged (OQ-050) |
| 16 | causal-models.qmd | 22 (exact) | translated | 4 | 8bfe598 | 2026-08-26 | adopted `causalgraphicalmodels` for ggdag/dagitty (dagify/ggdag_collider/ggdag_adjustment_set/adjustmentSets) over the heavier `dowhy` (OQ-051); `ggdag_paths()` skip-logged as a standing rule, no Python tool computes open/closed path status (OQ-052); three pre-existing R-only tabsets collapsed to one Python tab each, including a genuine judgment call picking one representative model out of three non-alternative model specs (OQ-053); one more `echo=F` DAG diagram skip-logged (OQ-054); caught and fixed two colon-count mistakes and one off-by-one chunk-boundary bug (missed closing fences) during verification before committing |
| 17 | power_analysis_chapter.qmd | 11 (exact) | translated | 2 | | 2026-08-26 | no new Stack package needed — numpy/scipy cover distributions and logit/expit; `replicate()`/`map_dfr()` idiom seeded via a helper-function + list-comprehension pattern (OQ-055); Poisson/Binomial `Single iteration`/`Power curve` tabsets nested rather than collapsed since both tabs are substantial independent teaching units, a second resolution to the same "pre-existing multi-tab" shape as OQ-053 (OQ-056) |
| 18 | AI-programming.qmd | ~24 | todo | | | | mostly deliberately-broken debugging exercises |
| 19 | ml-regression.qmd | ~5 | todo | | | | tidymodels stack undocumented, see below |
| 20 | ml-logistic-regression.qmd | ~4 | todo | | | | tidymodels stack undocumented, see below |
| 21 | workshop_03_random_forests.qmd | ~3 | todo | | | | tidymodels + vip undocumented |
| 22 | workshop_04_pca_kmeans.qmd | ~3 | todo | | | | tidymodels PCA/k-means undocumented |

### Appendices

| # | File | Chunks eligible | Status | Open Qs | Commit | Date | Notes |
|---|---|---|---|---|---|---|---|
| A1 | r-basics.qmd | ~55 | todo | | | | results='asis' fake-output pairing, see below |
| A2 | import.qmd | 2 | todo | | | | |
| A3 | script.qmd | 2 | todo | | | | |
| A4 | Naming conventions.qmd | 0 | todo | | | | all figures via include_graphics() |
| A5 | data_reshaping.qmd | 9 | todo | | | | mostly covered by existing glossary |
| A6 | quarto.qmd | ~5 | todo | | | | raw chunk count over-counts literal `` `r ''` `` fences, not real code |
| A7 | ggplot.qmd | ~35 | todo | | | | extension packages appear late in file |
| A8 | advanced_ggplot.qmd | ~3 | todo | | | | almost entirely undocumented geom-extension packages |
| A9 | summary-table.qmd | 0 | todo | | | | sjPlot/gtsummary, no equivalent |
| A10 | references.qmd | 0 | todo | | | | no code |

### Needs a decision before bulk work

Per CLAUDE.md's "Stop and report rather than continue": several chapters would
generate well over eight open questions each, and two have a structural
mismatch with the canonical pattern. Flagging here rather than logging dozens
of individual `OPEN-QUESTIONS.md` entries or picking a pilot chapter
unilaterally.

- ~~scikit-learn / tidymodels not in the Stack table~~ **Resolved 2026-08-25:**
  scikit-learn added to `TRANSLATION.md`'s Stack table and a tidymodels-to-
  scikit-learn idiom glossary section seeded. `ml-regression.qmd`,
  `ml-logistic-regression.qmd`, `workshop_03_random_forests.qmd` and
  `workshop_04_pca_kmeans.qmd` are back in normal scope.
- ~~R-only tabsets in `duplicates.qmd`/`missing-values.qmd`~~ **Resolved
  2026-08-25:** add one extra `Python` tab per existing R-only tabset group,
  showing one representative approach rather than mirroring every R tab.
  Documented in `TRANSLATION.md` under "Pre-existing R-only tabsets".
- **`intro-mixed-model.qmd`, `causal-models.qmd`, `advanced_ggplot.qmd`,
  `summary-table.qmd`** are each built on one or more R packages with no
  Python equivalent named in `TRANSLATION.md` (lme4/ggeffects/MuMIn/sjPlot;
  ggdag/dagitty; a different extension package per section — ggdist,
  ggridges, ggbump, patchwork, sf, etc.; sjPlot/gtsummary). Same shape as the
  ML gap above, just smaller — worth deciding per-chapter whether to seed a
  minimal glossary entry or defer.
- ~~`echo = F, warning = F, message = F` setup chunks~~ **Resolved
  2026-08-25:** treated as equivalent to `#| include: false` and skipped
  silently, no Python tab and no `OPEN-QUESTIONS.md` entry. Documented in
  `TRANSLATION.md`.
- **Recurring pattern, not yet a rule:** `readRDS(url(...))` appears in a
  `.callout-important` box at the top of most Data Cleaning/Insights
  chapters. `.RDS` has no Python analogue. Candidate for one standing warning
  in `TRANSLATION.md` rather than a fresh open question per chapter.
- **`r-basics.qmd`** pairs an `eval: false` "real" chunk with a following
  `results: asis` chunk that hardcodes the printed value (e.g. `cat("TRUE")`)
  as a display trick, not a webexercises widget. CLAUDE.md's `results: asis`
  skip rule is scoped to widgets. Needs confirmation the real chunk is
  eligible and the `asis` twin is skip-silent.
- **`quarto.qmd`** contains ```` ```{r}`r ''` ```` fences that are literal
  text illustrating chunk syntax, not executable code — exclude these from
  the eligible count entirely rather than logging them.

Full glossary-gap list (every R idiom used in an eligible chunk that is not
yet in `TRANSLATION.md`'s table, grouped by category) is available on request
before the Stack/glossary decisions above are made — not written into
`TRANSLATION.md` yet since filling it in requires those decisions first.

## Deferred goals

Not translation work. Do not start without explicit instruction.

| Goal | Status | Notes |
|---|---|---|
| Python setup chapter | not started | New writing: environment, packages, editor. Begin only after all chapters are `reviewed`. |
| `requirements.txt` with pinned versions | not started | Depends on the setup chapter. |
| Preface standing warnings | not started | Depends on the patterns found during translation. |
