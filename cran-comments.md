# 2023-08-19

We've fixed the issue pointed by Kurt Hornik with Roxygen2 not finding automatically adding -package alias with @docType.

* This is an update

# Latest submission

Fixed `--run-donttest` example failures: wrapped all `@examples \donttest{}` blocks that depend on tensorflow in `if (requireNamespace("tensorflow", quietly = TRUE)) { tryCatch({ ... }, error = function(e) NULL) }` guards. This prevents failures when the R tensorflow package is installed but the Python tensorflow module is not available (as on CRAN's build infrastructure). Affected functions: `get_dl_model`, `fit_dl_model`, `predict_treedamage`, `confmatrix_treedamage`.