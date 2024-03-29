#'Confusion matrix
#'
#'@description This function calculates a cross-tabulation of reference and predicted classes with associated statistics based on the deep learning models.
#'
#'@param predict_class A vector with the predicted classes. This is the output from the predict_treedamage function.
#'@param test_classes A vector with the predicted classes. This is the output from the get_validation_classes function.
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
#'tensorflow_dir = NA
#'
#'# define model type
#'model_type = "simple"
#'#model_type = "vgg"
#'#model_type = "inception"
#'#model_type = "resnet"
#'#model_type = "densenet"
#'#model_type = "efficientnet"
#'
#' # Image and model properties
#' # path to image folders - black
#'train_image_files_path <- system.file('extdata', 'train', package='rTLsDeep')
#'test_image_files_path <- system.file('extdata', 'validation', package='rTLsDeep')
#'img_width <- 256
#'img_height <- 256
#'class_list_train = unique(list.files(train_image_files_path))
#'class_list_test = unique(list.files(test_image_files_path))
#'lr_rate = 0.00003
#'target_size = c(img_width, img_height)
#'channels = 4
#'batch_size = 8L
#'epochs = 4L
#'
#'# get model
#'rtlsdeep_setup()
#'model = get_dl_model(model_type=model_type,
#'                     img_width=img_width,
#'                     img_height=img_height,
#'                     channels=channels,
#'                     lr_rate = lr_rate,
#'                     tensorflow_dir = tensorflow_dir,
#'                     class_list = class_list_train)
#'
#'
#'# train model and return best weights
#'weights = fit_dl_model(model = model,
#'                                 train_input_path = train_image_files_path,
#'                                 test_input_path = test_image_files_path,
#'                                 target_size = target_size,
#'                                 batch_size = batch_size,
#'                                 class_list = class_list_train,
#'                                 epochs = epochs,
#'                                 lr_rate = lr_rate)
#'
#'
#'# Predicting post-hurricane damage at the tree-level
#'tree_damage<-predict_treedamage(model=model,
#'                            input_file_path=test_image_files_path,
#'                            weights=weights,
#'                            target_size = c(256,256),
#'                            class_list=class_list_test,
#'                            batch_size = batch_size)
#'
#'# Get damage classes for test datasets
#'classes<-get_validation_classes(file_path=test_image_files_path)
#'
#'# Calculate, print and return confusion matrix
#'cm = confmatrix_treedamage(predict_class = tree_damage,
#'                           test_classes=classes,
#'                           class_list = class_list_test)
#'}
#'@importFrom caret confusionMatrix
#'@export
confmatrix_treedamage = function(predict_class, test_classes, class_list) {

  # get reference classes
  ref = factor(test_classes, levels = class_list)
  pred = factor(predict_class, levels = class_list)

  # confusion matrix
  cm = caret::confusionMatrix(pred, ref)

  # return
  return(cm)
}
