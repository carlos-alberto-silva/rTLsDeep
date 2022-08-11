#'Confusion matrix
#'
#'@description This function calculates a cross-tabulation of reference and predicted classes with associated statistics based on the deep learning models.
#'
#'@usage confmatrix_treedamage(predict_class, validation_classes, class_list)
#'
#'@param predict_class A vector with the predicted classes. This is the output from the predict_treedamage function.
#'@param validation_classes A vector with the predicted classes. This is the output from the get_validation_classes function.
#'@param class_list A character string or numeric value describing the post-hurricane individual tree level damage classes, e.g.: c("1","2","3","4","5","6").
#'
#'@return Returns the confusion matrix comparing predictions with the reference from validation dataset.
#'
#'@seealso \url{https://www.rdocumentation.org/packages/caret/versions/3.45/topics/confusionMatrix}
#'
#'@examples
#'\donttest{
#'# Set directory to tensorflow (python environment)
#'# This is required if running deep learning local computer with GPU
#'# Guide to install here: https://doi.org/10.5281/zenodo.3929709
#'tensorflow_dir = 'C:\\ProgramData\\Miniconda3\\envs\\r-tensorflow'
#'
#'# define model type
#'#model_type = "simple"
#'model_type = "vgg"
#'#model_type = "inception"
#'#model_type = "resnet"
#'#model_type = "densenet"
#'#model_type = "efficientnet"
#'
# # Image and model properties
#'img_width <- 256
#'img_height <- 256
#'class_list = as.character(1:6)
#'lr_rate = 0.0001
#'target_size <- c(img_width, img_height)
#'channels <- 4
#'batch_size = 8L
#'epochs = 20L
# path to image folders - black
#'train_image_files_path <- getwd() # update the path for training datasets
#'valid_image_files_path <- getwd() # update the path for testing datasets
#'
#'# get model
#'model = get_dl_model(model_type=model_type,
#'                     img_width=img_width,
#'                     img_height=img_height,
#'                     lr_rate = lr_rate,
#'                     tensorflow_dir = tensorflow_dir,
#'                     class_list = class_list)
#'
#'
#'# train model and return best weights
#'weights_fname = train_treedamage(model = model,
#'                                 train_input_path = train_image_files_path,
#'                                 test_input_path = valid_image_files_path,
#'                                 target_size = target_size,
#'                                 batch_size = batch_size,
#'                                 class_list = as.character(1:6),
#'                                 epochs = epochs,
#'                                 lr_rate = lr_rate)
#'
#'
#'# Predicting post-hurricane damage at the tree-level
#'tree_damage<-predict_treedamage(model,
#'                            input_file_path,
#'                            weights,
#'                            target_size = c(256,256),
#'                            class_list=class_list,
#'                            batch_size = batch_size)
#'
#'# Get damage classes for validation datasets
#'validation_classes<-get_validation_classes(file_path=getwd(), class_list)
#'
#'# Calculate, print and return confusion matrix
#'cm = confmatrix_treedamage(pred_df = tree_damage,
#'                           validation_classes=validation_classes,
#'                           class_list = class_list)
#'}
#'@import caret confusionMatrix
#'@export
confmatrix_treedamage = function(predict_class, validation_classes, class_list) {

  # get reference classes
  ref = factor(validation_classes, levels = class_list)
  pred = factor(predict_class, levels = class_list)

  # confusion matrix
  cm = caret::confusionMatrix(pred, ref)
  print(cm)

  # return
  return(cm)
}