#'Tree-level damage classes for validation datasets
#'
#'@description This function return the post-hurricane individual tree-level damage classes based on file names in a given directory.
#'
#'@param file_path A character string indicating the path to the validation folders, one for each class.
#'This folder must have sub folders with samples for each class.
#'
#'@return Returns the classes based on file names in a given folder.
#'
#'@examples
#'\donttest{
#'# Image and model properties
#'test_image_files_path <- getwd() # update the path for testing datasets
#'
#'# Get damage classes for validation datasets
#'test_classes<-get_validation_classes(file_path=test_image_files_path)
#'}
#'
#'@export
get_test_classes = function(file_path) {

  # get reference classes based on the paths
  test_classes = dirname(list.files(file_path, recursive=T))

  return(test_classes)
}
