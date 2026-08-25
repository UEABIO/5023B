<!-- Paste into index.qmd. Written last, once the translation patterns are known. -->

Each example in this book is shown in both R and Python, and you may work through
the material in either language. Use the tabs above each code example to switch;
your choice is remembered across the book.

R is the language this book is built in. Every result, table and figure printed
here was produced by the R code shown. The Python code is illustrative: it is not
run when the book is built, so no output appears beneath it, and running it
yourself will produce similar rather than identical results. Figures in
particular will differ in appearance, since plotnine and ggplot2 have different
defaults for colour, type and spacing.

A few differences between the languages are structural rather than cosmetic, and
are worth knowing before you start. Python indexes from zero and its slices
exclude the final element, so any example that selects by position differs.
Random number generation differs, so any example using a random seed produces
different values in each language. Missing values behave differently: pandas
ignores them by default when computing a summary, whereas R does not.
