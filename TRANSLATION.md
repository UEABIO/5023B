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
| Mixed models | lme4 / lmerTest | pymer4 | Wraps R's lme4 via `rpy2` — needs a working R installation with lme4/lmerTest to actually run, the one Python idiom in this book with a non-Python runtime dependency. In exchange, formula strings (including nested and `cbind()` forms) pass through to lme4 essentially unchanged. |
| Causal DAGs | ggdag / dagitty | causalgraphicalmodels | Small, dagitty-inspired package covering DAG construction and backdoor-adjustment-set identification. Lightly maintained — the same trade-off already accepted for pymer4, made deliberately rather than reaching for a heavier general-purpose causal-inference library the chapter doesn't otherwise need. |
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

Chapters fitting GLMs with an explicit family (`poisson.qmd`, `binomial.qmd`,
and others further into the modelling half of the book) add to the block
above rather than replacing it:

```python
import statsmodels.api as sm
```

`sm` supplies `sm.families.Poisson()` etc. for the `family=` argument to
`smf.glm(...)`, and its `sm.graphics`/matplotlib plotting is the deliberate
exception used for model-diagnostic plots (see "Model diagnostics" below) —
plotnine and the `performance` package have no equivalent for Q-Q or
residuals-vs-fitted plots, so this is the one place in the book a Python tab
uses matplotlib directly rather than plotnine. Import it alongside `sm`:

```python
import matplotlib.pyplot as plt
```

Chapters fitting mixed models (`intro-mixed-model.qmd` and beyond) add:

```python
from pymer4.models import Lmer
```

Import `graphviz` only in the specific chapter(s) that port a `DiagrammeR::grViz()`
decision-tree diagram (see "Diagrams" below):

```python
import graphviz
```

Chapters building causal DAGs (`causal-models.qmd` and beyond) add:

```python
from causalgraphicalmodels import CausalGraphicalModel
```

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
| `filter(cond1, cond2)` | `.loc[lambda d: (cond1) & (cond2)]` - comma-separated conditions are an implicit AND |
| `!is.na(x)` | `x.notna()` |
| `select(a, b)` | `[["a", "b"]]` |
| `mutate(z = x + y)` | `.assign(z=lambda d: d["x"] + d["y"])` |
| `rename(new = old)` | `.rename(columns={"old": "new"})` |
| `arrange(x)` | `.sort_values("x")` |
| `arrange(desc(x))` | `.sort_values("x", ascending=False)` |
| `summarise(m = mean(x), .by = g)` | `.groupby("g", as_index=False).agg(m=("x", "mean"))` |
| `count(g)` | `.groupby("g", as_index=False).size().rename(columns={"size": "n"})` |
| `count()` (no group, after `filter()`) | `len(df)` - shape differs (bare count vs a one-row/one-column `n` tibble) but the value matches |
| `sd(x)`, inside `summarise()` | `.std()` / `"std"` inside `.agg()` |
| `median(x)`, inside `summarise()` | `.median()` / `"median"` inside `.agg()` |
| `IQR(x)` | `x.quantile(0.75) - x.quantile(0.25)` |
| `summarise_at(c(cols), fn, na.rm = T)` (superseded dplyr verb, still used in this book) | `.groupby(g)[cols].agg(fn_name)` |
| `summarise_if(is.numeric, fn, na.rm = T)` (superseded dplyr verb, still used in this book) | `.groupby(g).agg(fn_name, numeric_only=True)` |
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
| `y ~ .` (formula: "all other columns as predictors") | build the formula string explicitly: `"y ~ " + " + ".join(c for c in df.columns if c != "y")` — patsy has no `.` shorthand |
| `step_naomit(all_predictors(), all_outcomes())` | `.dropna()` applied to the training `DataFrame` before building `X_train`/`y_train` — `Pipeline` has no row-dropping step, so this happens outside the pipeline rather than inside it |
| `metrics(truth = y, estimate = .pred)` (yardstick; rmse + rsq + mae together) | a small `DataFrame` built from `mean_squared_error(y_true, y_pred, squared=False)`, `r2_score(y_true, y_pred)` and `mean_absolute_error(y_true, y_pred)`, mirroring yardstick's `.metric`/`.estimate` shape |
| `extract_fit_engine(workflow_fit)` | `pipeline.named_steps["model"]` — the fitted estimator inside a `Pipeline` |
| `extract_fit_parsnip(workflow_fit) \|> tidy()` | a `DataFrame` built from `pipeline.named_steps["model"].coef_` and `.intercept_`; unlike `broom::tidy()`, scikit-learn regressors expose only point coefficients — no standard errors or p-values, consistent with this book's prediction-not-inference framing for the ML chapters |
| `autoplot(tune_grid_result)` | build a `DataFrame` from `grid_search.cv_results_["param_<name>"]` and `-grid_search.cv_results_["mean_test_score"]` (use `scoring="neg_root_mean_squared_error"` in `GridSearchCV`, since scikit-learn scorers are "higher is better"), then a plotnine point/line plot |
| `select_best()` / `finalize_workflow()` / `fit()` (three separate steps) | collapses into nothing extra — `GridSearchCV(...).fit(...)` already refits the best combination in one call; `.best_estimator_` is the finalised, fitted pipeline directly |
| `corrplot::corrplot(cor_matrix)` | no equivalent package in the Stack; reshape to long form with `.reset_index().melt(...)` and plot with `geom_tile()`, staying within plotnine rather than reaching for matplotlib/seaborn for an otherwise-ordinary heatmap |
| `read_table(path)` (whitespace-delimited, PLINK-style) | `pd.read_csv(path, sep=r"\s+")` |
| `predict(fit, new_data, type = "prob")` | `pipeline.predict_proba(X)` |
| `predict(fit, new_data, type = "class")` | `pipeline.predict(X)` |
| `accuracy(truth = y, estimate = .pred_class)` | `accuracy_score(y_true, y_pred)` |
| `sensitivity(...)` (= recall of the positive class) | `recall_score(y_true, y_pred, pos_label=...)` |
| `specificity(...)` (= recall of the negative class) | `recall_score(y_true, y_pred, pos_label=<negative class>)` — scikit-learn has no dedicated `specificity_score`; recall computed against the negative label gives the same quantity |
| `conf_mat(results, truth, estimate) \|> autoplot(type = "heatmap")` | reshape `confusion_matrix(y_true, y_pred)` into a long frame with the true/predicted labels and plot with `geom_tile()`, mirroring the corrplot heatmap idiom above |
| `roc_curve(results, truth, .pred_class) \|> autoplot()` | `fpr, tpr, _ = roc_curve(y_true, y_score)`, then a plotnine `geom_line()` plot of `tpr` against `fpr` |
| `roc_auc(results, truth, .pred_class)` | `roc_auc_score(y_true, y_score)` |
| `prep(recipe)` / `juice(prepped_recipe)` | `pipeline.fit_transform(X)` — a `Pipeline`'s `fit_transform` prepares and applies in one step, with no separate prep/juice distinction |
| `tidy(pca_prep, 2, type = "variance")` (percent variance per PC) | `pca.explained_variance_ratio_ * 100`, where `pca` is the fitted `PCA` step pulled from the pipeline |
| `tidy(pca_prep, 2)` (PCA loadings) | `pd.DataFrame(pca.components_.T, index=feature_names, columns=[f"PC{i+1}" for i in range(pca.n_components_)])` |
| `kmeans(data, centers = k)$tot.withinss` | `KMeans(n_clusters=k).fit(data).inertia_` |
| `rowMeans(across(where(is.numeric)))` | `df.select_dtypes("number").mean(axis=1)` |
| `p1 + p2` (patchwork, side-by-side composition) | no plotnine equivalent — patchwork's `+` composes two separate plot objects into one figure; plotnine's `+` is layer-addition within a single plot. Settled under OQ-066: show the two plots as two separate Python statements rather than inventing a composition mechanism |

| `set_engine("ranger", importance = "permutation")` \|> ... \|> `vip::vip(fit)` | `sklearn.inspection.permutation_importance(model, X, y)` — `RandomForestClassifier.feature_importances_` alone is impurity-based (mean decrease in Gini), not permutation-based; since the R chunk explicitly requests `importance = "permutation"`, the faithful port uses `permutation_importance`, not the plain `.feature_importances_` attribute |

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
| `min(x)` / `max(x)`, inside `summarise()` (any column type) | `.min()` / `.max()`, named the same way as any other `.agg()` aggregation |
| `tibble(col = c(v1, v2, ...))` | `pd.DataFrame({"col": [v1, v2, ...]})` |

### GLM families (base R to statsmodels)

`glm()`'s `family = poisson(link = "log")` is unambiguous and settled directly
here rather than logged. `quasipoisson()` and `MASS::glm.nb()` involve a real
choice of statsmodels mechanism, decided under OQ-027.

| R | Python |
|---|---|
| `glm(y ~ x, data = d, family = poisson(link = "log"))` | `smf.glm("y ~ x", data=d, family=sm.families.Poisson()).fit()` |
| `glm(y ~ x, data = d, family = quasipoisson(link = "log"))` | `smf.glm("y ~ x", data=d, family=sm.families.Poisson()).fit(scale="X2")` — `scale="X2"` rescales standard errors by the Pearson-based dispersion estimate, giving the same point estimates and inflated SEs as R's quasi-Poisson, without a distinct statsmodels family object |
| `MASS::glm.nb(y ~ x, data = d)` | `smf.negativebinomial("y ~ x", data=d).fit()` — statsmodels estimates a dispersion parameter `alpha`; R's `theta` is its reciprocal (`alpha ≈ 1/theta`), not printed the same way |
| `glm(y ~ x, data = d, family = binomial(link = logit))` | `smf.glm("y ~ x", data=d, family=sm.families.Binomial()).fit()` |
| `glm(cbind(successes, failures) ~ x, data = d, family = binomial)` | `smf.glm("successes + failures ~ x", data=d, family=sm.families.Binomial()).fit()` — statsmodels' formula API treats a `successes + failures` left-hand side as the two-column binomial response, the same information as R's `cbind()` |
| `glm(cbind(successes, failures) ~ x, data = d, family = quasibinomial)` | `smf.glm("successes + failures ~ x", data=d, family=sm.families.Binomial()).fit(scale="X2")` — same `scale="X2"` mechanism as quasi-Poisson |
| `AIC(model1, model2)` | `model1.aic`, `model2.aic` — read directly off each fitted result, no combining call needed |
| `DescTools::PseudoR2(model)` (default McFadden) | `1 - model.llf / model.llnull` — statsmodels GLM results carry both log-likelihoods directly; other `PseudoR2()` types (Cox-Snell, Nagelkerke, …) have no settled equivalent and are not attempted |

### Prediction grids with confidence intervals (emmeans)

`emmeans()` builds a grid of predictor combinations and returns predicted
means with confidence intervals, on the response scale when `type =
"response"`. statsmodels has no single call that does this; the equivalent is
building the grid explicitly and calling `.get_prediction(...).summary_frame()`.
Settled under OQ-028.

```r
emmeans(model, specs = ~ Mass + Species,
        at = list(Mass = seq(0, 40, by = 5)),
        type = "response") |>
  as_tibble()
```

```python
grid = pd.DataFrame(
    [(mass, species) for mass in np.arange(0, 41, 5) for species in cuckoo["Species"].unique()],
    columns=["Mass", "Species"],
)
predictions = model.get_prediction(grid).summary_frame()
```

`summary_frame()` gives `mean`, `mean_ci_lower` and `mean_ci_upper` on the
response scale, in place of emmeans' `rate`/`response` and
`asymp.LCL`/`asymp.UCL` columns — the values are the analogous quantities, the
column names differ, and downstream code (ggplot/plotnine aesthetics
referencing the R column names) is translated using the Python names instead.

### Coefficient tables (broom::tidy())

statsmodels result objects carry the same information `broom::tidy()`
assembles, just as separate attributes rather than one data frame. Settled
under OQ-029.

```r
tidy(model, conf.int = TRUE)
```

```python
tidy = pd.DataFrame({
    "term": model.params.index,
    "estimate": model.params.values,
    "std_error": model.bse.values,
    "conf_low": model.conf_int()[0].values,
    "conf_high": model.conf_int()[1].values,
    "p_value": model.pvalues.values,
})
```

`tidy(model, exponentiate = TRUE, conf.int = TRUE)` is the same construction
with `np.exp()` applied to `estimate`, `conf_low` and `conf_high`.

### Nested-model comparison (anova(), drop1())

Base R's `anova(model1, model2)` on two nested GLMs, and `drop1(model, test =
"F")`, both run a likelihood-ratio-style test statsmodels has no single
wrapper for. Settled under OQ-030.

```python
from scipy import stats

lr_stat = 2 * (model2.llf - model1.llf)
df_diff = model1.df_resid - model2.df_resid
p_value = stats.chi2.sf(lr_stat, df_diff)
```

`drop1()`'s per-term F-tests have no equivalent one-liner at all; where a
chunk uses it, the Python tab notes the gap rather than approximating a
per-term loop.

### Model diagnostics (performance package)

`performance::check_model()` and `check_overdispersion()` have no Python
package equivalent — nothing in the current Stack produces the same combined
diagnostic panel. Rather than skip these silently (they are central to this
chapter's teaching point), each is translated to the closest statsmodels/
matplotlib diagnostic for the specific check being illustrated. Settled under
OQ-031; this is the one place in the book plotting uses matplotlib directly
rather than plotnine (see the import block note above).

| R (performance) | Python (statsmodels + matplotlib) |
|---|---|
| `check_model(model)` (full suite, `lm()` object) | `sm.qqplot(model.resid, line="45")` for the Q-Q plot, plus `plt.scatter(model.fittedvalues, model.resid)` for residuals vs fitted — shown as two chunks' worth of code, since there is no combined panel |
| `check_model(model)` (full suite, `glm()` object) | as above, using `model.resid_deviance` in place of `model.resid` |
| `check_model(model, check = "qq")` | `sm.qqplot(model.resid_deviance, line="45")` (`model.resid` for an `lm()` object) |
| `check_model(model, check = "homogeneity")` | `plt.scatter(model.fittedvalues, model.resid_deviance)` |
| `check_model(model, check = "overdispersion")` / `check_overdispersion(model)` | `model.pearson_chi2 / model.df_resid` — the Pearson-based dispersion ratio, statsmodels' closest built-in equivalent to performance's dispersion statistic; performance's dispersion *plot* itself has no direct equivalent and is not attempted |

### Mixed models (lme4/lmerTest to pymer4)

pymer4's `Lmer` forwards its formula string to R's lme4 via `rpy2`, so nested
and `cbind()` forms carry across with only cosmetic changes (spacing around
`|`, no backtick-quoted names). Settled under OQ-043/044.

| R | Python |
|---|---|
| `lmer(y ~ x + (1\|g), data = d)` | `Lmer("y ~ x + (1 \| g)", data=d).fit()` |
| `glmer(cbind(s, f) ~ x + (1\|g), family = binomial, data = d)` | `Lmer("cbind(s, f) ~ x + (1 \| g)", data=d, family="binomial").fit()` |
| `lmer(y ~ x + (1\|g1/g2), data = d)` (nested) | `Lmer("y ~ x + (1 \| g1/g2)", data=d).fit()` — the nested formula passes straight through to lme4, no workaround needed |
| `summary(model)` | `model.summary()` |
| `broom.mixed::tidy(model)` | `model.coefs` — pymer4's fitted `Lmer` already stores a fixed-effects table shaped like broom's output |
| Random-effects variance table | `model.ranef_var` |
| `predict(model, newdata, re.form = NA)` (population-average prediction) | `model.predict(data=grid, use_rfx=False)` |
| `predict(model, newdata)` (group-conditional prediction, random effects included) | `model.predict(data=grid, use_rfx=True)` |
| `AIC(model)` | `model.AIC` |

`emmeans`/`ggeffects`'s confidence intervals and ribbon plots have no
settled Python source — neither pymer4 nor statsmodels' `MixedLM` computes
marginal-mean confidence intervals for a mixed model. Per human decision
(chat, 2026-08-26), any chunk whose entire deliverable is a confidence
ribbon or CI band is skip-and-logged rather than approximated; a chunk that
also does other useful work (a plain prediction table, a diagnostic, a
model fit) is still translated for that part. See OQ-049 for the standing
rule and the list of chunks it applies to.

Model diagnostics on a fitted `Lmer` reuse the OQ-031 statsmodels/matplotlib
approach, substituting pymer4's attribute names: `model.residuals` for
`resid`/`resid_deviance`, `model.fits` for `fittedvalues`.

### Marginal and conditional R² (MuMIn::r.squaredGLMM())

No package computes this for a `Lmer` object; settled under OQ-045 as a
direct implementation of Nakagawa & Schielzeth's formula from the model's
own variance components:

```r
r.squaredGLMM(mixed_model)
```

```python
var_fixed = model.predict(data=d, use_rfx=False).var()
var_random = model.ranef_var.loc[model.ranef_var["Name"] != "Residual", "Var"].sum()
var_resid = model.ranef_var.loc[model.ranef_var["Name"] == "Residual", "Var"].sum()

r2m = var_fixed / (var_fixed + var_random + var_resid)  # marginal: fixed effects only
r2c = (var_fixed + var_random) / (var_fixed + var_random + var_resid)  # conditional: fixed + random
```

### Publication tables (sjPlot)

`sjPlot::tab_model()` has no Python equivalent — nothing in the Stack
produces a comparable publication-ready HTML/text regression table.
Skip-and-logged per CLAUDE.md's "chunk relying on an R package with no
accepted Python equivalent" rule (OQ-046).

### Diagrams (DiagrammeR)

`DiagrammeR::grViz()` renders a Graphviz DOT-language string — the DOT
language itself is not R-specific, so the diagram source carries across
almost unchanged; only the calling wrapper differs. Settled under OQ-047.

```r
library(DiagrammeR)
grViz("digraph { a -> b }")
```

```python
import graphviz
graphviz.Source("digraph { a -> b }")
```

### Grouped aggregation with `aggregate()`

Base R's `aggregate(y ~ a + b, data = d, mean)` — and the native-pipe
placeholder `_` used with it — has no glossary entry. Settled under
OQ-048.

| R | Python |
|---|---|
| `d \|> aggregate(y ~ a + b, data = _, mean)` | `d.groupby(["a", "b"], as_index=False)["y"].mean()` |

### Causal DAGs (ggdag/dagitty to causalgraphicalmodels)

`dagify()`'s `child ~ parent1 + parent2` formula convention becomes an
explicit edge list: each parent becomes a `(parent, child)` tuple.
`causalgraphicalmodels` methods take `exposure`/`outcome` as explicit
arguments per call, rather than storing them on the object the way
dagitty does — settled under OQ-051.

| R (ggdag/dagitty) | Python (causalgraphicalmodels) |
|---|---|
| `dagify(y ~ x + z, x ~ z, exposure = "x", outcome = "y")` | `CausalGraphicalModel(nodes=["x", "y", "z"], edges=[("z", "x"), ("z", "y"), ("x", "y")])` |
| `ggdag(dag, text = FALSE, use_labels = "name") + theme_dag()` | `dag.draw()` — returns a graphviz object; layout and styling differ from ggdag's ggplot2-based rendering, an extension of the plotnine/ggplot2 standing warning |
| `ggdag_collider(dag)` | `[n for n, d in dag.dag.in_degree() if d >= 2]` — lists collider nodes (two or more parents in the whole graph); ggdag's highlighted diagram itself has no equivalent, only the underlying node list |
| `ggdag_adjustment_set(dag)` / `adjustmentSets(dag)` | `dag.get_all_backdoor_adjustment_sets(exposure, outcome)` |
| `ggdag_paths(dag)` / `ggdag_paths(dag, adjust_for = ...)` | no equivalent — skip-and-logged (OQ-052); would require custom d-separation logic per path, a larger invention than the ambiguity protocol is meant to cover |

Custom node `labels =` (cosmetic display names distinct from the node's
variable name) have no `causalgraphicalmodels` equivalent and are dropped
from the Python translation rather than approximated — the node names
themselves are used, consistent with dropping other untranslatable cosmetic
arguments elsewhere (e.g. OQ-024's `colorspace` scale).

### Monte Carlo simulation (power analysis)

R's random-number generators, `replicate()` and `map_dfr()` have no glossary
entries. Settled under OQ-055.

| R | Python |
|---|---|
| `set.seed(x)` | `np.random.seed(x)` |
| `rnorm(n, mean, sd)` | `np.random.normal(mean, sd, n)` |
| `rpois(n, lambda)` | `np.random.poisson(lambda, n)` |
| `rbinom(n, size, prob)` | `np.random.binomial(size, prob, n)` |
| `qlogis(p)` | `logit(p)` (`from scipy.special import expit, logit`) |
| `plogis(x)` | `expit(x)` |
| `replicate(n, { expr })` | a `one_simulation()` helper function containing `expr`, called inside `[one_simulation() for _ in range(n)]` |
| `map_dfr(vector, function)` | `pd.DataFrame([function(x) for x in vector])`, where `function` returns a `dict` per row instead of a one-row tibble |

`tidy(model) |> filter(term == "x") |> pull(p.value)` is translated as
`model.pvalues["x"]` directly rather than building the full `tidy()` table
just to extract one value — simpler and equally clear for a single lookup.
Note that patsy's dummy-coding names a two-level factor's coefficient
`group[T.treatment]`, not R's `grouptreatment`; the first occurrence in a
chapter carries a comment flagging this, since it is easy to copy the R
name by habit and get a `KeyError`.

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
