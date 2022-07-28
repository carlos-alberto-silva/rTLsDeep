#'Predict post-hurricane individual tree level damage
#'
#'@description This function predicts post-hurricane individual tree-level damage from TLS derived 2D images
#'
#'@usage predict_treedamage(file_path, use_model = "vgg", weights_fname, target_size, class_list, batch_size = 8, tensorflow_dir)
#'
#'@param file_path A GEDI Level2A object (output of [readLevel2A()] function).
#'An S4 object of class "gedi.level2a".
#'@param use_model Numeric. West longitude (x) coordinate of the bounding rectangle, in decimal degrees.
#'@param weights Character defining the weights based on the name of the output files of function XXXX.
#'@param target_size Numeric. South latitude (y) coordinate of the bounding rectangle, in decimal degrees.
#'@param class_list Numeric. North latitude (y) coordinate of the bounding rectangle, in decimal degrees.
#'@param batch_size Optional character path where to save the new hdf5file. The default stores a temporary file only.
#'@param tensorflow_dir Optional character path where to save the new hdf5file. The default stores a temporary file only.
#'
#'@return Returns XXX objects of class XXX containing XXX.
#'
#'@seealso \url{XXXX}
#'
#'@examples
#'\donttest{
#'
#'close(level2a_clip)
#'}
#'@export
predict_treedamage = function(file_path, use_model = "vgg", weights_fname, target_size, class_list, batch_size = 8, tensorflow_dir) {
  # file_path is the folder containing the images to use for prediction
  # weights_fname is the filename for the trained weights with .h5 file format
  # target_size is a two value array c(width, height) with widtht and height used to train the model
  # class_list is an array of available classes e.g. c(1,2,3,5,6)
  # batch_size is the number of images processed at the same time, reduce this if the GPU is giving memory errors
  # tensorflow_dir is the directory for the tensorflow python environment, guide to install here: https://doi.org/10.5281/zenodo.3929709

  # load model
  model = get_dl_model(use_model, tensorflow_dir = tensorflow_dir, class_list = class_list)

  # load weights
  load_model_weights_hdf5(model, weights_fname)

  # Validation data shouldn't be augmented! But it should also be scaled.
  valid_data_gen <- image_data_generator(
    rescale = 1/255
  )

  # validation images
  valid_image_array_gen <- flow_images_from_directory(file_path,
                                                      valid_data_gen,
                                                      shuffle = F,
                                                      color_mode = "rgba",
                                                      target_size = target_size,
                                                      class_mode = "categorical",
                                                      classes = as.character(class_list),
                                                      batch = batch_size,
                                                      seed = 42)

  # predict for validation dataset
  predictions <- predict(model, valid_image_array_gen)

  # get class with max probability
  predict_class = factor(apply(predictions, 1, which.max), levels = class_list)

  # get reference classes based on the paths
  validation_classes = dirname(list.files(valid_image_files_path, recursive=T))

  # create prediction data frame with prediction and reference class
  pred_df = data.frame(predict_class = predict_class, ref_class = validation_classes)

  # return
  return(pred_df)

}
