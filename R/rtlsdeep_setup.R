#' Setup python and tensorflow environment
#'
#' @param python_version Character string with Python version to install if not found. Default: "3.12".
#'
#' @return Nothing
#' @export
rtlsdeep_setup = function(python_version = "3.12")
{
  if (reticulate::py_available(initialize = TRUE) == FALSE)
  {
    reticulate::install_python(version = python_version)
  }
  if (reticulate::py_module_available('tensorflow') == FALSE)
  {
    tensorflow::install_tensorflow()
  }
}
