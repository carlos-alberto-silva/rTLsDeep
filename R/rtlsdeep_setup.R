#' Setup python and tensorflow environment
#'
#' Creates or reuses a micromamba environment with Python and TensorFlow.
#' If RETICULATE_PYTHON is set, uses that Python executable directly.
#' Otherwise, creates a 'rtlsdeep-tf' micromamba environment.
#'
#' @param python_version Character string with Python version to install if not found. Default: "3.12".
#'
#' @return Nothing
#' @export
rtlsdeep_setup = function(python_version = "3.12")
{
  # Already connected and tensorflow available? Done.
  if (reticulate::py_module_available('tensorflow')) {
    message("TensorFlow already available via reticulate.")
    return(invisible(NULL))
  }

  # Check RETICULATE_PYTHON env var first
  py_path <- Sys.getenv("RETICULATE_PYTHON")
  if (nzchar(py_path) && file.exists(py_path)) {
    message("Using RETICULATE_PYTHON: ", py_path)
    tryCatch({
      reticulate::use_python(py_path, required = TRUE)
    }, error = function(e) stop("Failed to connect to RETICULATE_PYTHON (", py_path, "): ", e$message))
    if (reticulate::py_module_available('tensorflow')) {
      message("TensorFlow available in specified Python environment.")
      return(invisible(NULL))
    }
    message("TensorFlow not found. Installing via pip...")
    py <- tryCatch(
      reticulate::py_discover_config(required = TRUE),
      error = function(e) NULL
    )
    if (is.null(py)) {
      # Fallback: use pip directly via system()
      message("Using system pip for installation...")
      pip <- file.path(dirname(py_path), "pip")
      if (!file.exists(pip)) pip <- file.path(dirname(py_path), "pip3")
      if (file.exists(pip)) {
        system2(pip, c("install", "tensorflow", "numpy", "scipy", "pillow"))
      } else {
        system2("python", c("-m", "pip", "install", "tensorflow", "numpy", "scipy", "pillow"))
      }
    } else {
      reticulate::py_install("tensorflow", method = "pip", python = py$python)
      reticulate::py_install("numpy", method = "pip", python = py$python)
      reticulate::py_install("scipy", method = "pip", python = py$python)
      reticulate::py_install("pillow", method = "pip", python = py$python)
    }
    message("TensorFlow and dependencies installed successfully.")
    return(invisible(NULL))
  }

  # Try system Python (e.g., /usr/bin/python3)
  system_python <- Sys.which("python3")
  if (nzchar(system_python) && file.exists(system_python)) {
    message("Trying system Python: ", system_python)
    tryCatch({
      reticulate::use_python(system_python, required = TRUE)
      if (reticulate::py_module_available('tensorflow')) {
        message("TensorFlow available on system Python.")
        return(invisible(NULL))
      }
    }, error = function(e) message("System Python failed: ", e$message))
  }

  # Fallback: create micromamba environment
  message("Creating micromamba 'rtlsdeep-tf' environment with Python ", python_version, " and TensorFlow...")
  micromamba_path <- Sys.which("micromamba")
  if (nzchar(micromamba_path)) {
    micromamba_exe <- micromamba_path
  } else {
    micromamba_exe <- file.path(Sys.getenv("HOME"), ".local", "bin", "micromamba")
    if (!file.exists(micromamba_exe)) {
      stop("micromamba not found. Please install micromamba or set RETICULATE_PYTHON.")
    }
  }

  env_name <- "rtlsdeep-tf"
  # Check common micromamba env paths
  env_path <- file.path(Sys.getenv("HOME"), "micromamba", "envs", env_name)
  if (!file.exists(env_path)) {
    env_path <- file.path(Sys.getenv("HOME"), ".local", "share", "mamba", "envs", env_name)
  }
  env_python <- file.path(env_path, "bin", "python")

  if (file.exists(env_python)) {
    message("Environment 'rtlsdeep-tf' already exists, using it.")
    reticulate::use_python(env_python, required = TRUE)
    if (reticulate::py_module_available('tensorflow')) {
      message("TensorFlow available in rtlsdeep-tf environment.")
      return(invisible(NULL))
    }
  }

  # Create environment
  cmd <- paste0(micromamba_exe, " create -n ", env_name, " python=", python_version,
                " tensorflow numpy scipy pillow -y")
  message("Running: ", cmd)
  system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)

  if (file.exists(env_python)) {
    reticulate::use_python(env_python, required = TRUE)
    pc <- reticulate::py_config()
    message("micromamba environment created successfully!")
    message("  Python: ", pc$python)
    message("  Version: ", pc$version)
    message("  TensorFlow: ", ifelse(reticulate::py_module_available('tensorflow'), "available", "not available"))
  } else {
    stop("Failed to create micromamba environment. Ensure micromamba is installed.")
  }
}
