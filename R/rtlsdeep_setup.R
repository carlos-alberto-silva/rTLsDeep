#' Setup python and tensorflow environment
#'
#' @return Nothing
#' @export
rtlsdeep_setup = function()
{
  if (reticulate::py_available() == FALSE)
  {
    reticulate::install_python()
  }
  if (reticulate::py_module_available('tensorflow') == FALSE)
  {
    tensorflow::install_tensorflow()
  }
}
