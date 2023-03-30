#'Fitting deep learning models for post-hurricane individual tree level damage classification
#'
#'@description This function fits deep learning models for post-hurricane individual tree level damage classification using TLS-derived 2D images
#'
#'@param model A model object output of the get_dl_model function. See [rTLsDeep::get_dl_model()].
#'@param train_input_path A character string describing the path to the training dataset, e.g.: "C:/train_data/".
#'@param test_input_path A character string describing the path to the testing dataset, e.g.: "C:/test_data/".
#'@param output_path A character string describing the path where to save the weights for the neural network.
#'@param target_size A vector of two values describing the image dimensions (Width and height) to be used in the model. Default: c(256,256)
#'@param batch_size A numerical value indicating the number of images to be processed at the same time. Reduce the batch_size if the GPU is giving memory errors.
#'@param class_list A character string or numeric value describing the post-hurricane individual tree level damage classes, e.g.: c("1","2","3","4","5","6").
#'@param epochs A numeric value indicating the number of iterations to train the model. Use at least 20 for pre-trained models, and at least 200 for a model without pre-trained weights.
#'@param lr_rate A numeric value indicating the learning rate. Default: 0.0001.
#'
#'@return Returns a character string indicating the filename of the best weights trained for the chosen model.
#'
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
# # Image and model properties
# path to image folders - black
#'train_image_files_path = system.file('extdata', 'train', package='rTLsDeep')
#'test_image_files_path = system.file('extdata', 'validation', package='rTLsDeep')
#'img_width <- 256
#'img_height <- 256
#'class_list_train = unique(list.files(train_image_files_path))
#'class_list_test = unique(list.files(test_image_files_path))
#'lr_rate = 0.0001
#'target_size <- c(img_width, img_height)
#'channels <- 4
#'batch_size = 8L
#'epochs = 2L
#'
#'# get model
#'rtlsdeep_setup()
#'
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
#'unlink('epoch_history', recursive = TRUE)
#'unlink('weights', recursive = TRUE)
#'unlink('weights_r_save', recursive = TRUE)
#'
#'}
#'@import keras tensorflow
#'@export
fit_dl_model = function(model, train_input_path, test_input_path, output_path = tempdir(), target_size = c(256,256), batch_size = 8, class_list, epochs = 20L, lr_rate = 0.0001) {

  # get number of classes
  output_n = length(class_list)

  # define pipe
  `%>%` <- keras::`%>%`

  ## Data generator

  # optional data augmentation
  train_data_gen = keras::image_data_generator(
    rescale = 1/255,
    #rotation_range = 40,
    width_shift_range = 0.2,
    height_shift_range = 0.2,
    shear_range = 0.2,
    zoom_range = 0.2,
    horizontal_flip = TRUE,
    #fill_mode = "nearest"
  )

  # Validation data shouldn't be augmented! But it should also be scaled.
  valid_data_gen <- keras::image_data_generator(
    rescale = 1/255
  )

  # training images
  train_image_array_gen <- keras::flow_images_from_directory(train_input_path,
                                                             train_data_gen,
                                                             color_mode = "rgb",
                                                             target_size = target_size,
                                                             class_mode = "categorical",
                                                             classes = NULL,
                                                             batch = batch_size,
                                                             seed = 42)

  # validation images
  valid_image_array_gen <- keras::flow_images_from_directory(test_input_path,
                                                             valid_data_gen,
                                                             shuffle = F,
                                                             color_mode = "rgb",
                                                             target_size = target_size,
                                                             class_mode = "categorical",
                                                             classes = NULL,
                                                             batch = batch_size,
                                                             seed = 42)
  message("Number of images per class:")

  table(factor(train_image_array_gen$classes))
  table(factor(valid_image_array_gen$classes))

  train_image_array_gen$class_indices


  # number of training samples
  train_samples <- train_image_array_gen$n
  # number of validation samples
  valid_samples <- valid_image_array_gen$n


  # directories
  epoch_history_path = dir.create(file.path(output_path, 'epoch_history'))
  epoch_history_filepath = file.path(epoch_history_path, 'epoch_history.csv')
  weights_path = dir.create(file.path(output_path, 'weights'))
  weights_r_path = dir.create(file.path(output_path, 'weights_r_save'))

  # # callbacks
  dir.create(epoch_history_path, showWarnings=F)
  dir.create(weights_path, showWarnings=F)
  dir.create(weights_r_path, showWarnings=F)

  # clear weights
  unlink(list.files(weights_path, full.names=T))


  ## Train the model

  # mixed precision
  best_precision = ifelse(tensorflow::tf$test$is_gpu_available(), 'mixed_float16', 'float32')
  if ('experimental' %in% reticulate::py_list_attributes(tensorflow::tf$keras$mixed_precision)) {
    tensorflow::tf$keras$mixed_precision$experimental$set_policy(best_precision)
  } else {
    tensorflow::tf$keras$mixed_precision$set_global_policy(best_precision)
  }

  # call backs
  callbacks_list = list(
    keras::callback_csv_logger(epoch_history_filepath),
    keras::callback_model_checkpoint(filepath = file.path(weights_path, "model_{epoch:05d}_{val_accuracy:.4f}.h5"),
                                     monitor = "val_accuracy",save_best_only = TRUE,
                                     save_weights_only = TRUE, mode = "max" ,save_freq = NULL)
  )

  # fit model
  hist = keras::fit(model,
                    train_image_array_gen,
                    steps_per_epoch = as.integer(train_samples / batch_size),
                    validation_data = valid_image_array_gen,
                    validation_steps = as.integer(valid_samples / batch_size),
                    epochs = epochs,
                    workers = 1,
                    callbacks = callbacks_list)


  # clear GPU
  tensorflow::tf$keras.backend$clear_session()
  py_gc <- reticulate::import('gc')
  py_gc$collect()

  # copy the best weight to the save folder
  weight_fname = rev(list.files(weights_path, pattern = ".h5", full.names=T))[1]
  weight_fname2 = sub("weights", "weights_r_save", weight_fname)
  file.copy(weight_fname, weight_fname2)
  file.copy(epoch_history_filepath, sub(".h5", ".csv", weight_fname2))
  message(paste0("The best weight was saved in weights_r_save folder, named: ", weight_fname2))

  # return
  return(weight_fname2)
}
