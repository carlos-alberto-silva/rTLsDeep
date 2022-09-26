#'Predict post-hurricane individual tree level damage
#'
#'@description This function predicts post-hurricane individual tree-level damage from TLS derived 2D images
#'
#'@usage predict_treedamage(input_file_path, model, weights, target_size, class_list, batch_size)
#'
#'@param input_file_path A character string describing the path to the images to predict, e.g.: "C:/test_data/".
#'@param model_type A character string describing the deep learning model to be used. Available models: "vgg", "resnet", "inception", "densenet", "efficientnet", "simple".
#'@param weights A character string indicating the filename of the weights to use for prediction.
#'@param target_size A vector of two values describing the image dimensions (Width and height) to be used in the model. Default: c(256,256)
#'@param batch_size A numerical value indicating the number of images to be processed at the same time. Reduce the batch_size if the GPU is giving memory errors.
#'@param class_list A character string or numeric value describing the post-hurricane individual tree level damage classes, e.g.: c("1","2","3","4","5","6").
#'@param tensorflow_dir A character string indicating the directory for the tensorflow python environment. Guide to install the environment here: https://doi.org/10.5281/zenodo.3929709
#'
#'@return Returns a character string with the prediction classes.
#'
#'
#'@examples
#'\donttest{
#'# Set directory to tensorflow (python environment)
#'# This is required if running deep learning local computer with GPU
#'# Guide to install here: https://doi.org/10.5281/zenodo.3929709
#'tensorflow_dir = 'C:\\ProgramData\\Miniconda3\\envs\\r-tensorflow'
#'
#'# define model type
#'model_type = "simple"
#'#model_type = "vgg"
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
#'weights_fname = fit_dl_model(model = model,
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
#'tree_damage<-predict_treedamage(model=model,
#'                            input_file_path=getwd(),
#'                            weights=weights,
#'                            target_size = c(256,256),
#'                            class_list=class_list,
#'                            batch_size = batch_size)
#'}
#'@importFrom keras load_model_weights_hdf5 flow_images_from_directory
#'@export
predict_treedamage = function(model , input_file_path, weights, target_size = c(256,256), class_list, batch_size = 8) {


  # load weights
  keras::load_model_weights_hdf5(model, weights)

  # Validation data shouldn't be augmented! But it should also be scaled.
  valid_data_gen <- keras::image_data_generator(
    rescale = 1/255
  )

  # validation images
  valid_image_array_gen <- keras::flow_images_from_directory(input_file_path,
                                                             valid_data_gen,
                                                             shuffle = F,
                                                             color_mode = "rgb",
                                                             target_size = target_size,
                                                             class_mode = "categorical",
                                                             classes = as.character(class_list),
                                                             batch = batch_size,
                                                             seed = 42)

  # predict for validation dataset
  predictions <- stats::predict(model, valid_image_array_gen)

  # get class with max probability
  predict_class = factor(apply(predictions, 1, which.max), levels = class_list)

  # return
  return(predict_class)

}
