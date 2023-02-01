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
#'# Image and model properties
#'val_image_files_path = system.file('extdata', 'validation', package='rTLsDeep')
#'
#'# Get damage classes for validation datasets
#'classes = get_validation_classes(file_path=val_image_files_path)
#'
#'@export
get_validation_classes = function(file_path) {

  # get reference classes based on the paths
  validation_classes = dirname(list.files(file_path, recursive=T))

  return(validation_classes)
}
