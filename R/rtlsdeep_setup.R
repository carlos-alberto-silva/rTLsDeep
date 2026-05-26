#' Setup python and tensorflow environment
#'
#' Uses reticulate/keras3 APIs (platform-agnostic) to create a self-contained
#' Python virtual environment and install TensorFlow + dependencies.
#'
#' @param python_version Character string with Python version constraint,
#'   passed to `reticulate::virtualenv_create`. Default: `">=3.9,<=3.12"`.
#' @param envname Name of the Python virtual environment to create or reuse.
#'   Default: `"r-rtlsdeep"`. Can be overridden by the `RETICULATE_PYTHON_ENV`
#'   environment variable.
#'
#' @return Nothing, called for side effects.
#' @export
rtlsdeep_setup = function(python_version = ">=3.9,<=3.12",
                          envname = "r-rtlsdeep")
{
  # Respect RETICULATE_PYTHON_ENV if set
  env_override <- Sys.getenv("RETICULATE_PYTHON_ENV")
  if (nzchar(env_override)) {
    envname <- env_override
  }

  # 1. Try existing virtualenv — virtualenv_find() does NOT initialize
  #    reticulate, so it's safe to call before use_virtualenv().
  venv_python <- tryCatch(
    reticulate::virtualenv_find(envname),
    error = function(e) NULL
  )
  if (!is.null(venv_python)) {
    reticulate::use_virtualenv(envname, required = TRUE)
    if (reticulate::py_module_available('tensorflow')) {
      message("TensorFlow already available via '", envname, "' environment.")
      return(invisible(NULL))
    }
    message("'", envname, "' exists but TensorFlow not found. Installing...")
    reticulate::py_install(c("tensorflow", "numpy", "scipy", "pillow"),
                           envname = envname)
    if (reticulate::py_module_available('tensorflow')) {
      message("TensorFlow installed into '", envname, "'.")
      return(invisible(NULL))
    }
    stop("Failed to install TensorFlow into '", envname, "'.")
  }

  # 2. Try RETICULATE_PYTHON env var (user-specified Python binary path)
  py_path <- Sys.getenv("RETICULATE_PYTHON")
  if (nzchar(py_path) && file.exists(py_path)) {
    reticulate::use_python(py_path, required = TRUE)
    if (reticulate::py_module_available('tensorflow')) {
      message("TensorFlow available via RETICULATE_PYTHON.")
      return(invisible(NULL))
    }
    message("TensorFlow not found at RETICULATE_PYTHON. Installing...")
    reticulate::py_install(c("tensorflow", "numpy", "scipy", "pillow"),
                           envname = envname)
    reticulate::use_virtualenv(envname, required = TRUE)
    if (reticulate::py_module_available('tensorflow')) {
      message("TensorFlow installed into '", envname, "'.")
      return(invisible(NULL))
    }
    stop("Failed to install TensorFlow.")
  }

  # 3. Create virtualenv + install TF via keras3::install_keras()
  message("Creating virtual environment '", envname,
          "' and installing TensorFlow via keras3::install_keras()...")
  keras3::install_keras(
    envname = envname,
    extra_packages = c("scipy", "Pillow", "numpy"),
    python_version = python_version,
    backend = "tensorflow",
    restart_session = FALSE
  )

  reticulate::use_virtualenv(envname, required = TRUE)

  if (!reticulate::py_module_available('tensorflow')) {
    stop("TensorFlow installation failed. Check the logs above for details.")
  }

  message("TensorFlow installation complete.")
  invisible(NULL)
}
