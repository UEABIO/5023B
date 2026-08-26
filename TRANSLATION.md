# Translation decisions and idiom glossary

Authoritative. If a rule here conflicts with what looks natural, follow the rule
and log the conflict in `OPEN-QUESTIONS.md`.

## Governing principle

Where two Python idioms are otherwise equally good, choose the one that maps more
visibly onto the R tab. The book teaches operations, not syntax, and the tabset is
the mechanism by which a student sees the operation behind both languages. This is
a deliberate choice with a known cost: some idioms here are not the most common in
the wider Python ecosystem.

## Stack

| Purpose | R | Python | Notes |
|---|---|---|---|
| Data frames | dplyr / tidyr | pandas | Not polars. Not both. |
| Plotting | ggplot2 | plotnine | Not matplotlib or seaborn. |
| Models | stats / broom | statsmodels (formula API) | Preserves the `y ~ x` narrative. |
| Machine learning | tidymodels | scikit-learn | Not statsmodels. Pipeline mirrors recipe/workflow structure. |
| Arrays and numerics | base R | numpy | |
| Distributions and tests | stats | scipy.stats | |

Version floor: pandas >= 2.2, plotnine >= 0.13. Record the actual pinned versions
in `requirements.txt` once the setup chapter is written.

## Import block

Every chapter's first Python tab repeats this block; later chunks in the chapter
assume it.

```python
import pandas as pd
import numpy as np
from plotnine import *
import statsmodels.formula.api as smf
```

`from plotnine import *` is a deliberate exception to normal practice: it keeps
`ggplot(...) + geom_point()` visually parallel to the R tab. Do not use a wildcard
import for any other library.

Machine-learning chapters (`ml-regression.qmd`, `ml-logistic-regression.qmd`,
`workshop_03_random_forests.qmd`, `workshop_04_pca_kmeans.qmd`) add to the block
above rather than replacing it:

```python
from sklearn.model_selection import train_test_split, GridSearchCV, cross_val_score
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression, LogisticRegression, Ridge, Lasso, ElasticNet
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.decomposition import PCA
from sklearn.cluster import KMeans
from sklearn.metrics import confusion_matrix, roc_curve, mean_squared_error, r2_score
```

Import only the names a chapter actually uses; this is the full set across all
four ML chapters, not a block to repeat verbatim in each one.

## Style conventions

- snake_case throughout. Where an R object name contains a dot, replace it with an
  underscore and change nothing else (`penguins.clean` becomes `penguins_clean`).
- Otherwise preserve R variable names exactly, so the two tabs read side by side.
- Mirror the pipe with a parenthesised method chain, one method per line, using
  `.loc[lambda ...]` for row filtering and `.assign()` for column creation:

  ```python
  (
      penguins
      .loc[lambda d: d["body_mass_g"] > 3000]
      .assign(mass_kg=lambda d: d["body_mass_g"] / 1000)
      .groupby("species", as_index=False)
      .agg(mean_mass=("mass_kg", "mean"))
  )
  ```

  Not `.query()`: its condition is a string, so errors are opaque and editors
  cannot check it. Not bare masking (`d[d["x"] > 3]`): it breaks the chain and
  invites `SettingWithCopyWarning`.
- No `inplace=True`. Ever.
- Four-space indentation, double-quoted strings.
- In a `ggplot` translation, place the leading `+` at the start of each
  continuation line so the layers stack visibly, as they do in the R tab.
- Comments in the R chunk are carried across where they still describe the
  code they sit above. If a comment names an R function (`mutate()`,
  `case_when()`, etc.), reword it to name the Python equivalent actually used
  rather than carrying the R name across verbatim. If a comment describes
  neither the R code above it nor the Python code below it (a stale
  copy-paste leftover), drop it from the Python tab rather than editing
  around it — do not touch the R comment itself (hard rule 1). Log the
  general shape of the discrepancy in `OPEN-QUESTIONS.md` if it recurs.

## Idiom glossary

Extend this table from the chapter inventory before bulk work starts. Any idiom
not listed goes through the ambiguity protocol in `CLAUDE.md`.

| R | Python |
|---|---|
| `read_csv("f.csv")` | `pd.read_csv("f.csv")` |
| `filter(x > 3)` | `.loc[lambda d: d["x"] > 3]` |
| `select(a, b)` | `[["a", "b"]]` |
| `mutate(z = x + y)` | `.assign(z=lambda d: d["x"] + d["y"])` |
| `rename(new = old)` | `.rename(columns={"old": "new"})` |
| `arrange(x)` | `.sort_values("x")` |
| `arrange(desc(x))` | `.sort_values("x", ascending=False)` |
| `summarise(m = mean(x), .by = g)` | `.groupby("g", as_index=False).agg(m=("x", "mean"))` |
| `count(g)` | `.groupby("g", as_index=False).size().rename(columns={"size": "n"})` |
| `left_join(y, by = join_by(id))` | `.merge(y, on="id", how="left")` |
| `pivot_longer(cols, names_to, values_to)` | `.melt(id_vars=..., var_name=..., value_name=...)` |
| `pivot_wider(names_from, values_from)` | `.pivot(index=..., columns=..., values=...)` |
| `distinct()` | `.drop_duplicates()` |
| `drop_na()` | `.dropna()` |
| `n()` | `"size"` inside `.agg()` |
| `head(6)` | `.head(6)` |
| `nrow(df)` | `len(df)` |
| `ncol(df)` | `df.shape[1]` |
| `glimpse(df)` | `df.info()` |
| `ggplot(d, aes(x, y))` | `ggplot(d, aes("x", "y"))` - aesthetics are strings |
| `facet_wrap(~g)` | `facet_wrap("g")` |
| `labs(x =, y =, title =)` | `labs(x=, y=, title=)` |
| `theme_minimal()` | `theme_minimal()` |
| `lm(y ~ x, data = d)` | `smf.ols("y ~ x", data=d).fit()` |
| `summary(model)` | `model.summary()` |
| `t.test(x, y)` | `stats.ttest_ind(x, y)` |
| `seq(1, 10)` | `np.arange(1, 11)` |
| `rep(0, 5)` | `np.zeros(5)` |

### String manipulation (stringr) and conditional recoding

`str_detect()`, `str_remove()` and `str_remove_all()` need `import re` in
addition to the base import block. R's stringr/ICU regex and Python's `re`
are not identical, but the simple patterns used in this book (literal text,
basic groups, lookahead for `separate()`) translate directly.

| R | Python |
|---|---|
| `str_trim(x)` | `x.strip()` |
| `str_trim(x, side = "left")` | `x.lstrip()` |
| `str_trim(x, side = "right")` | `x.rstrip()` |
| `str_squish(x)` | `" ".join(x.split())` |
| `str_trunc(x, width = w, side = "right")` | `x[:w] + "…" if len(x) > w else x` |
| `str_split(x, pattern)` | `x.split(pattern)` for a single string; `.str.split(pattern)` over a column |
| `str_c(a, b, sep = s)` | `s.join([a, b])` |
| `str_detect(x, pattern)` | `re.search(pattern, x) is not None`; `.str.contains(pattern)` over a column |
| `str_remove(x, pattern)` | `re.sub(pattern, "", x, count=1)` |
| `str_remove_all(x, pattern)` | `re.sub(pattern, "", x)`; `.str.replace(pattern, "", regex=True)` over a column |
| `word(x, n)` | `x.split()[n - 1]` for a single string; `.str.split().str[n - 1]` over a column |
| `str_to_title(x)` | `x.title()`; `.str.title()` over a column |
| `str_to_upper(x)` | `x.upper()`; `.str.upper()` over a column |
| `str_to_lower(x)` | `x.lower()`; `.str.lower()` over a column |
| `case_when(cond1 ~ a, cond2 ~ b, .default = d)` | `np.select([cond1, cond2], [a, b], default=d)` |
| `if_else(cond, a, b)` | `np.where(cond, a, b)` |
| `separate(col, into = c("a", "b"), sep = pattern)` | `col.str.split(pattern, n=1, regex=True)`, assigned to two columns from an intermediate split variable — `.assign()` cannot reference a value produced earlier in the same call |

### Machine learning (tidymodels to scikit-learn)

tidymodels' recipe/workflow separation does not map onto a single scikit-learn
object; `Pipeline` covers both preprocessing steps and the final estimator.
Where a tidymodels chunk builds a `recipe()` and a `workflow()` in separate
steps, translate them as one `Pipeline` rather than two objects, so the reader
still sees the whole modelling process in one place.

| R (tidymodels) | Python (scikit-learn) |
|---|---|
| `initial_split(data, prop = 0.8)` / `training()` / `testing()` | `train_test_split(data, train_size=0.8)` |
| `recipe(y ~ ., data = train) \|> step_normalize(all_numeric_predictors())` | `StandardScaler()` inside a `Pipeline` step |
| `recipe(...) \|> step_pca(all_numeric_predictors(), num_comp = 2)` | `PCA(n_components=2)` inside a `Pipeline` step |
| `workflow() \|> add_recipe(rec) \|> add_model(mod)` | `Pipeline([("preprocessor", ...), ("model", ...)])` |
| `linear_reg() \|> set_engine("lm")` | `LinearRegression()` |
| `logistic_reg() \|> set_engine("glm")` | `LogisticRegression()` |
| `linear_reg(penalty = , mixture = 1) \|> set_engine("glmnet")` | `Lasso(alpha=)` |
| `linear_reg(penalty = , mixture = 0) \|> set_engine("glmnet")` | `Ridge(alpha=)` |
| `linear_reg(penalty = , mixture = ) \|> set_engine("glmnet")`, `0 < mixture < 1` | `ElasticNet(alpha=, l1_ratio=)` |
| `rand_forest() \|> set_engine("ranger") \|> set_mode("classification")` | `RandomForestClassifier()` |
| `rand_forest() \|> set_engine("ranger") \|> set_mode("regression")` | `RandomForestRegressor()` |
| `fit(workflow, data = train)` | `pipeline.fit(X_train, y_train)` |
| `predict(fit, new_data = test)` | `pipeline.predict(X_test)` |
| `vfold_cv(train, v = 10)` / `tune_grid()` | `GridSearchCV(pipeline, param_grid, cv=10)` |
| `select_best()` / `finalize_workflow()` | `grid_search.best_estimator_` |
| `conf_mat(results, truth, estimate)` | `confusion_matrix(y_test, y_pred)` |
| `roc_curve(results, truth, .pred_class)` | `roc_curve(y_test, y_score)` |
| `metric_set(rmse, rsq)` applied to results | `mean_squared_error(y_test, y_pred, squared=False)`, `r2_score(y_test, y_pred)` |
| `vip::vip(fit)` | `pd.Series(model.feature_importances_, index=X.columns).sort_values().plot.barh()` |
| `kmeans(data, centers = 3)` | `KMeans(n_clusters=3).fit(data)` |
| `augment(fit, new_data = data)` | `model.predict(X)` assigned back onto a copy of the frame with `.assign()` |

### Dates and times (lubridate)

Python has no direct equivalent of the `lubridate` package: date and time
handling lives in pandas itself (`pd.to_datetime()` and the `.dt` accessor)
plus the base `datetime` module. An R chunk whose only content is
`library(lubridate)` therefore has no Python import of its own — the
chapter's standard import block (`pandas`/`numpy`/`plotnine`/`statsmodels`)
already covers it. Treat such a chunk as the first Python tab of the chapter
carrying that block, same as any other opening chunk, rather than logging it
as an open question.

R's parsing functions (`ymd()`, `dmy()`, `mdy()`, `ydm()`) infer the day/month
order from the function name; `pd.to_datetime()` infers the format
automatically in the common case, or takes `dayfirst=`/`yearfirst=` for the
ambiguous ones. `as_date(x, format = ...)` format codes are strptime-style
`%Y`/`%m`/`%d` codes, identical in R and Python, so a `format=` argument
carries across unchanged.

| R (lubridate) | Python (pandas) |
|---|---|
| `ymd(x)` | `pd.to_datetime(x)` |
| `ydm(x)` | `pd.to_datetime(x, yearfirst=True)` |
| `dmy(x)` | `pd.to_datetime(x, dayfirst=True)` |
| `mdy(x)` | `pd.to_datetime(x)` |
| `date(x)` | `pd.to_datetime(x).normalize()` |
| `as_date(x)` | `pd.to_datetime(x)` |
| `as_date(x, format = fmt)` | `pd.to_datetime(x, format=fmt)` |
| `year(x)` | `pd.to_datetime(x).year`; `.dt.year` over a column |
| `month(x)` | `pd.to_datetime(x).month`; `.dt.month` over a column |
| `week(x)` | `pd.to_datetime(x).isocalendar().week`; `.dt.isocalendar().week` over a column |
| `day(x)` | `pd.to_datetime(x).day`; `.dt.day` over a column |
| `janitor::excel_numeric_to_date(x)` | `pd.to_datetime(x, unit="D", origin="1899-12-30")` — Windows origin, matching the book's stated default; note as a comment if a chapter's data uses the Mac 1904 origin instead |
| `min(x)` / `max(x)` on a date column, inside `summarise()` | `.min()` / `.max()`, named the same way as any other `.agg()` aggregation |
| `tibble(col = c(v1, v2, ...))` | `pd.DataFrame({"col": [v1, v2, ...]})` |

## Setup chunks

An R chunk marked `{r, echo = F, warning = F, message = F}` (or any subset of
those options, old- or new-style) that contains only library loads,
`source()` calls and/or a data import, with no other student-facing content,
is treated as equivalent to `#| include: false` per CLAUDE.md's skip-silent
rule: no Python tab, no `OPEN-QUESTIONS.md` entry. Confirmed against the
`strings.qmd` pilot, where this is the shape of the file's opening chunk.

## Pre-existing R-only tabsets

`duplicates.qmd` and `missing-values.qmd` already contain `.panel-tabset`
blocks comparing different R approaches to the same task (for example `dplyr`
vs `janitor` deduplication). These do not get mirrored one-for-one into R/Python
pairs. Instead, add a single extra `Python` tab alongside the existing R-only
tabs, showing one representative Python approach for the task the whole group
demonstrates - not a Python sibling for every individual R tab. The `group=
"language"` attribute still applies to the tabset as a whole.

## Standing warnings

These belong in the preface, stated once, not repeated per chunk:

- Indexing is 0-based and slices are half-open, so any positional example differs.
- Random number streams differ. Any chunk using `set.seed()` produces different
  values in Python; the Python tab shows the method, not reproducible output.
- `NA` and `NaN` are not equivalent, and `mean()` skips missing values by default
  in pandas but not in base R.
- pandas has view-versus-copy semantics with no dplyr analogue.
- Locale-dependent string sorting differs.
- plotnine and ggplot2 differ in default palette, typeface, point size and legend
  placement. Figures will look similar, not identical.
- `.RDS` is R's native serialisation format and has no Python equivalent.
  Any `readRDS()`/`saveRDS()` chunk a student is meant to run is skip-and-
  logged as R-specific rather than translated; do not invent a pandas
  substitute for it.
- R's `Date` class has no time component. pandas has no bare-date type — a
  `pd.to_datetime()` result is always a `Timestamp` carrying a time component
  (`00:00:00` when unused). Printed values will show that difference even
  when both sides represent the same date.
