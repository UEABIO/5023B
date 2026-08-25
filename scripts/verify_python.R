# Verify the book's Python chunks outside the render.
#
# The Python in this book is never executed by Quarto (every chunk carries
# eval: false), so nothing catches a broken translation or an API change. This
# script extracts each chapter's Python chunks, concatenates them in document
# order with the shared import block, and runs them against the book's data.
#
# Run from the book root. Requires a Python environment with the book's packages.

library(tidyverse)
library(fs)

imports <- c(
  "import matplotlib",
  "matplotlib.use('Agg')",  # never open a plot window
  "import pandas as pd",
  "import numpy as np",
  "from plotnine import *",
  "import statsmodels.formula.api as smf"
)

# Chunks that demonstrate an error on purpose are marked "# VERIFY-SKIP" and
# dropped here rather than being reported as failures.
extract_python <- function(path) {
  lines <- read_lines(path)
  opens <- str_which(lines, "^\\s*```\\{python\\}")
  closes <- str_which(lines, "^\\s*```\\s*$")

  opens |>
    map(\(open) {
      close <- closes[closes > open][1]
      if (is.na(close)) {
        cli::cli_abort("Unclosed python chunk at line {open} of {path}.")
      }
      lines[(open + 1):(close - 1)]
    }) |>
    discard(\(chunk) any(str_detect(chunk, "VERIFY-SKIP"))) |>
    map(\(chunk) {
      chunk |>
        discard(\(line) str_detect(line, "^\\s*#\\|")) |>
        str_remove("^\\s{0,4}")  # undo indentation from nested divs
    }) |>
    list_c()
}

run_chapter <- function(path) {
  code <- extract_python(path)
  if (length(code) == 0) return(NA_character_)

  script <- path("_verify", path_ext_remove(path_file(path)), ext = "py")
  write_lines(c(imports, "", code), script)

  output <- system2("python", script, stdout = TRUE, stderr = TRUE)
  if (is.null(attr(output, "status"))) NA_character_ else str_flatten_lines(output)
}

dir_create("_verify")

failures <- dir_ls(".", glob = "*.qmd") |>
  set_names(\(paths) path_ext_remove(path_file(paths))) |>
  map(run_chapter) |>
  discard(is.na)

if (length(failures) == 0) {
  cli::cli_alert_success("All chapters executed cleanly.")
} else {
  iwalk(failures, \(msg, chapter) cli::cli_alert_danger("{chapter}:\n{msg}"))
}
