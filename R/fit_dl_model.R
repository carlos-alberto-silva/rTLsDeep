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
#'\dontrun{
#'  # Set directory to tensorflow (python environment)
#'  # This is required if running deep learning local computer with GPU
#'  # Guide to install here: https://doi.org/10.5281/zenodo.3929709
#'  tensorflow_dir = NA
#'
#'  # define model type
#'  model_type = "simple"
#'  #model_type = "vgg"
#'  #model_type = "inception"
#'  #model_type = "resnet"
#'  #model_type = "densenet"
#'  #model_type = "efficientnet"
#'
#'   # Image and model properties
#'   # path to image folders - black
#'  train_image_files_path = system.file('extdata', 'train', package='rTLsDeep')
#'  test_image_files_path = system.file('extdata', 'validation', package='rTLsDeep')
#'  img_width <- 256
#'  img_height <- 256
#'  class_list_train = unique(list.files(train_image_files_path))
#'  class_list_test = unique(list.files(test_image_files_path))
#'  lr_rate = 0.0001
#'  target_size <- c(img_width, img_height)
#'  channels <- 4
#'  batch_size = 8L
#'  epochs = 2L
#'
#'  # get model
#'  rtlsdeep_setup()
#'
#'  model = get_dl_model(model_type=model_type,
#'                       img_width=img_width,
#'                       img_height=img_height,
#'                       channels=channels,
#'                       lr_rate = lr_rate,
#'                       tensorflow_dir = tensorflow_dir,
#'                       class_list = class_list_train)
#'
#'
#'  # train model and return best weights
#'  weights = fit_dl_model(model = model,
#'                               train_input_path = train_image_files_path,
#'                               test_input_path = test_image_files_path,
#'                               target_size = target_size,
#'                               batch_size = batch_size,
#'                               class_list = class_list_train,
#'                               epochs = epochs,
#'                               lr_rate = lr_rate)
#'
#'
#'  unlink('epoch_history', recursive = TRUE)
#'  unlink('weights', recursive = TRUE)
#'  unlink('weights_r_save', recursive = TRUE)
#'}
#'@importFrom keras3 image_dataset_from_directory callback_csv_logger callback_model_checkpoint fit
#'@importFrom tensorflow tf
#'@export
fit_dl_model = function(model, train_input_path, test_input_path, output_path = tempdir(), target_size = c(256,256), batch_size = 8, class_list, epochs = 20L, lr_rate = 0.0001) {

  # get number of classes
  output_n = length(class_list)

  ## Data generator

  # training images
  train_ds <- keras3::image_dataset_from_directory(
    train_input_path,
    label_mode = "categorical",
    image_size = target_size,
    batch_size = batch_size,
    seed = 42
  )

  # validation images
  valid_ds <- keras3::image_dataset_from_directory(
    test_input_path,
    label_mode = "categorical",
    image_size = target_size,
    batch_size = batch_size,
    seed = 42,
    shuffle = FALSE
  )

  # count samples
  train_samples <- length(list.files(train_input_path, recursive = TRUE))
  valid_samples <- length(list.files(test_input_path, recursive = TRUE))

  message("Training samples: ", train_samples, " Validation samples: ", valid_samples)

  # directories
  epoch_history_path <- file.path(output_path, 'epoch_history')
  weights_path <- file.path(output_path, 'weights')
  weights_r_path <- file.path(output_path, 'weights_r_save')
  dir.create(epoch_history_path, showWarnings = FALSE, recursive = TRUE)
  dir.create(weights_path, showWarnings = FALSE, recursive = TRUE)
  dir.create(weights_r_path, showWarnings = FALSE, recursive = TRUE)

  epoch_history_filepath <- file.path(epoch_history_path, 'epoch_history.csv')

  # clear weights
  unlink(list.files(weights_path, full.names = TRUE))

  ## Train the model

  # mixed precision
  has_gpu <- length(tensorflow::tf$config$list_physical_devices("GPU")) > 0
  best_precision <- ifelse(has_gpu, 'mixed_float16', 'float32')
  tensorflow::tf$keras$mixed_precision$set_global_policy(best_precision)

  # call backs
  callbacks_list <- list(
    keras3::callback_csv_logger(epoch_history_filepath),
    keras3::callback_model_checkpoint(
      filepath = file.path(weights_path, "model_{epoch:05d}_{val_accuracy:.4f}.weights.h5"),
      monitor = "val_accuracy", save_best_only = TRUE,
      save_weights_only = TRUE, mode = "max"
    )
  )

  # fit model
  keras3::fit(model,
              train_ds$`repeat`(),
              steps_per_epoch = as.integer(train_samples / batch_size),
              validation_data = valid_ds,
              validation_steps = as.integer(valid_samples / batch_size),
              epochs = epochs,
              callbacks = callbacks_list)

  # clear GPU
  tensorflow::tf$keras.backend$clear_session()
  py_gc <- reticulate::import('gc')
  py_gc$collect()

  # copy the best weight to the save folder
  weight_fname <- rev(list.files(weights_path, pattern = "\\.weights\\.h5$", full.names = TRUE))[1]
  if (is.na(weight_fname)) stop("No weight files found after training")
  weight_fname2 <- sub("weights", "weights_r_save", weight_fname)
  file.copy(weight_fname, weight_fname2)
  file.copy(epoch_history_filepath, sub("\\.weights\\.h5$", ".csv", weight_fname2))
  message("The best weight was saved in weights_r_save folder, named: ", basename(weight_fname2))

  # return
  return(weight_fname2)
}
