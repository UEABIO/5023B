# Dual-language Quarto book: adding Python alongside R

## What this project is

A student-facing Quarto book teaching data analysis in R. The task is to add a
non-executing Python equivalent alongside each student-facing R chunk, presented
in a tabset, so that a reader may work through the book in either language.

R is the primary language and the sole source of all printed output. The Python
is illustrative: it never runs during the render, so it produces no output in the
book. It is nonetheless real code that a student may run, and it is verified
outside the book by `scripts/verify_python.R`.

## Reference files

- `TRANSLATION.md` - the agreed stack, conventions and R-to-Python idiom
  glossary. Authoritative. Read in full before editing any chapter.
- `PROGRESS.md` - per-chapter status and the pilot gate. Read before starting,
  update on finishing.
- `OPEN-QUESTIONS.md` - the ambiguity log. Append only.

## Hard rules

Breaking any of these is a defect, not a judgement call.

1. Never modify an existing `{r}` chunk. Not to reformat it, rename a variable,
   change a chunk option, add a label, or improve the code. If an R chunk looks
   wrong, log it in `OPEN-QUESTIONS.md` and leave it alone.
2. Never modify prose. If a sentence names an R-specific object ("tibble", "the
   pipe") and now reads oddly alongside a Python tab, log it. Do not rewrite it.
3. Every `{python}` chunk carries `#| eval: false`. No exceptions, ever.
4. Do not render the book, run R, run Python, or install any package.
5. Follow `TRANSLATION.md` exactly, including where its choices are not the most
   common idiom in the wider Python ecosystem. Those choices are deliberate.
6. Do not invent a translation. If the idiom is not in `TRANSLATION.md`, follow
   the ambiguity protocol below.
7. Work one chapter at a time. One chapter, one commit.
8. British spelling in anything you write, including code comments.
9. The Python setup chapter is out of scope. Do not write, draft or extend any
   chapter about installing Python, environments, packages or editors, even if a
   chapter you are translating appears to need one. Log the need and move on.
10. Do not add explanatory prose to the book to compensate for a translation you
    are unsure about. Log the uncertainty instead.

## The canonical pattern

Given an existing R chunk, wrap it and its new Python sibling:

````markdown
::: {.panel-tabset group="language"}

## R

```{r}
#| label: fig-penguin-mass
#| fig-cap: "Body mass by species."
penguins |>
  ggplot(aes(species, body_mass_g)) +
  geom_boxplot()
```

## Python

```{python}
#| eval: false
(
    ggplot(penguins, aes("species", "body_mass_g"))
    + geom_boxplot()
)
```

:::
````

Rules for the pattern:

- `group="language"` on every tabset. The group name is always `language`, so
  the reader's choice of language persists across the whole book.
- Tab headings are exactly `R` and `Python`, in that order, always.
- The tab heading level is one level below the enclosing section heading. If the
  surrounding section is `##`, the tabs are `###`. Check the local context of
  every chunk; do not assume `##`.
- The R tab contains the original chunk, byte for byte.

## Fence arithmetic

Nested divs need strictly more colons than their parent. Inside a
`::::{.task-container}`, a tabset must open with five colons:

````markdown
:::{.task}
::::{.task-header}
**Task: fit the model**
::::

::::{.task-container}

:::::{.panel-tabset group="language"}

### R

```{r}
#| eval: false
lm(body_mass_g ~ flipper_length_mm, data = penguins)
```

### Python

```{python}
#| eval: false
smf.ols("body_mass_g ~ flipper_length_mm", data=penguins).fit()
```

:::::

::::
:::
````

Getting this wrong collapses the task styling silently. Count the colons on
every nested block you write.

## Python chunk options

- `#| eval: false` - mandatory.
- `#| label:` - only if the R chunk has one, and then it is the R label with
  `-py` appended. Labels must be unique within a file.
- Never carry over `fig-cap`, `tbl-cap`, `fig-height`, `out-width` or any other
  output-controlling option. The chunk produces no output, and a caption on it
  would create a phantom cross-reference target.

## What to translate

Translate: chunks a student is meant to read, type or adapt.

Skip silently:

- `#| include: false` setup chunks.
- Chunks that exist only to place a figure via `knitr::include_graphics()`.
- `webexercises` option chunks (`opts_*`) and any chunk with `results: asis`
  driving a widget.
- Inline R (`` `r ...` ``). Never touch it.
- A chunk using old-style `echo = F, warning = F, message = F` (or any subset)
  that contains only library loads, `source()` calls and/or a data import,
  with no other student-facing content. Treated as equivalent to
  `#| include: false` regardless of the exact option spelling.
- A chunk marked `echo = F` (with or without `eval = T`) that is a near-
  duplicate of the immediately preceding eligible chunk, differing only by
  something like an appended `|> head()`, and exists solely to render real
  output for the book. Translate the preceding chunk only.

Skip and log in `OPEN-QUESTIONS.md`:

- Chunks teaching something R-specific with no Python counterpart (`renv`,
  RStudio projects, R package structure, `sessionInfo()`).
- Chunks relying on an R package with no accepted Python equivalent in
  `TRANSLATION.md`.

## Task solutions

Hidden solution chunks are translated. `#| webex.hide:` is a per-chunk knitr
option and cannot wrap a two-chunk tabset, so use the inline form around the
whole tabset instead:

````markdown
`r hide("Click to see the solution")`

:::::{.panel-tabset group="language"}

### R

```{r}
#| eval: false
lm(body_mass_g ~ flipper_length_mm, data = penguins)
```

### Python

```{python}
#| eval: false
smf.ols("body_mass_g ~ flipper_length_mm", data=penguins).fit()
```

:::::

`r unhide()`
````

Note the colon count: five, because the tabset sits inside a task container.

Webexercises answers are a separate matter. Where a `fitb()` answer is a number
produced by a computation that differs between the languages (anything seeded or
sampled), log it rather than translating around it.

## Ambiguity protocol

When you meet an R idiom not covered by `TRANSLATION.md`:

1. Write the best candidate translation into the Python chunk.
2. Mark it with a comment on the line above: `# TRANSLATION-NOTE: <id>`.
3. Append an entry to `OPEN-QUESTIONS.md` using the template in that file.
4. Continue. Do not stop, do not ask mid-chapter, do not skip the chunk.

Never resolve an ambiguity by changing the R code, the data, or the prose.

## Definition of done for a chapter

- Every eligible R chunk has a Python sibling in a correctly nested tabset.
- Every Python chunk has `#| eval: false`.
- Colon counts verified on every nested block.
- Tab heading levels verified against the enclosing section.
- Every `TRANSLATION-NOTE` marker has a matching entry in `OPEN-QUESTIONS.md`.
- `git diff` shows no change to any line of R code or prose.
- `PROGRESS.md` updated with status, date, commit hash and open-question count.
- Committed as `translate: <chapter file>`. Do not push.

## Stop and report rather than continue

- More than eight open questions arise in one chapter.
- The chapter's structure does not fit the canonical pattern, for example R
  chunks split across intervening prose that assumes a single continuous
  session.
- Following these rules would require breaking one of them.
