#'Fitting deep learning models for post-hurricane individual tree level damage classification
#'
#'@description This function fits deep learning models for post-hurricane individual tree level damage classification using TLS-derived 2D images
#'
#'@usage fit_dl_model(use_model, train_image_files_path, valid_image_files_path, target_size, batch_size, class_list, epochs, tensorflow_dir)
#'
#'@param use_model A character describing the deep learning model to be used (e.g. "vgg", "resnet", "inception", "densenet", "efficientnet", "simple").
#'@param train_input_path A character describing the path to the training dataset.
#'@param test_input_path A character describing the path to the testing dataset.
#'@param target_size Vector. Rescaled dimensions (Width and height) of the images.
#'@param batch_size Numeric. Number of images processed at the same time (reduce the batch_size if the GPU is giving memory errors).
#'@param class_list Vector. Either character or numeric describing the post-hurricane individual tree level damage classes
#'@param epochs Numeric. Number of times to train the model, at least 20 for pre-trained models, and at least 200 for a model trained from zero
#'@param tensorflow_dir Character. Directory for the tensorflow python environment, guide to install here: https://doi.org/10.5281/zenodo.3929709
#'
#'@return Returns XXX objects of class XXX containing XXX.
#'
#'@seealso \url{XXXX}
#'
#'@examples
#'\donttest{
#'
#'# define model
#'#use_model = "simple"
#'use_model = "vgg"
#'#use_model = "inception"
#'#use_model = "resnet"
#'#use_model = "densenet"
#'#use_model = "efficientnet"
#'
# image and DL properties
#'img_width <- 256
#'img_height <- 256
#'target_size <- c(img_width, img_height)
#'class_list = as.character(1:6)
#'channels <- 4
#'batch_size = 8L
epochs = 20L
lr_rate = 0.0001

# path to image folders - black
train_image_files_path <- "D:\\2_Projects\\2_Collab\\58_Carlos_Silva\\1_TLS_treedamage_classification\\new_data_1500\\data_dir_black_1500\\train\\"
valid_image_files_path <- "D:\\2_Projects\\2_Collab\\58_Carlos_Silva\\1_TLS_treedamage_classification\\new_data_1500\\data_dir_black_1500\\val\\"

# # path to image folders - density
# train_image_files_path <- "D:\\2_Projects\\2_Collab\\58_Carlos_Silva\\1_TLS_treedamage_classification\\new_data_1500\\data_dir_density_1500\\train\\"
# valid_image_files_path <- "D:\\2_Projects\\2_Collab\\58_Carlos_Silva\\1_TLS_treedamage_classification\\new_data_1500\\data_dir_density_1500\\val\\"

# # path to image folders - height
# train_image_files_path <- "D:\\2_Projects\\2_Collab\\58_Carlos_Silva\\1_TLS_treedamage_classification\\new_data_1500\\data_dir_height_1500\\train\\"
# valid_image_files_path <- "D:\\2_Projects\\2_Collab\\58_Carlos_Silva\\1_TLS_treedamage_classification\\new_data_1500\\data_dir_height_1500\\val\\"

# train model and return best weights
weights_fname = train_treedamage(use_model = use_model, train_image_files_path = train_image_files_path, valid_image_files_path = valid_image_files_path, target_size = target_size, batch_size = batch_size, class_list = class_list, epochs = epochs, tensorflow_dir = tensorflow_dir)

#'}
#'@export
fit_dl_model = function(use_model, train_image_files_path, valid_image_files_path, target_size, batch_size = 8, class_list, epochs = 20L, tensorflow_dir) {
  # use_model is the desired model, available: vgg, resnet, inception, densenet, efficientnet, simple
  # train_image_files_path is the folder with the training images, there must be folders for the class names e.g. 1, 2, 3, 4, 5, 6
  # valid_image_files_path is the folder with the validation images, there must be folders for the class names e.g. 1, 2, 3, 4, 5, 6
  # target_size is a two value array c(width, height) with width and height used to train the model
  # batch_size is the number of images processed at the same time, reduce this if the GPU is giving memory errors
  # class_list is an array of available classes e.g. c(1,2,3,5,6)
  # epochs is the number of times to train the model, at least 20 for pre-trained models, and at least 200 for a model trained from zero
  # tensorflow_dir is the directory for the tensorflow python environment, guide to install here: https://doi.org/10.5281/zenodo.3929709

  # load model
  model = get_dl_model(use_model, tensorflow_dir = tensorflow_dir, class_list = class_list)

  # get number of classes
  output_n = length(class_list)

  ## Data generator

  # optional data augmentation
  train_data_gen = image_data_generator(
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
  valid_data_gen <- image_data_generator(
    rescale = 1/255
  )

  # training images
  train_image_array_gen <- flow_images_from_directory(train_image_files_path,
                                                      train_data_gen,
                                                      color_mode = "rgba",
                                                      target_size = target_size,
                                                      class_mode = "categorical",
                                                      classes = class_list,
                                                      batch = batch_size,
                                                      seed = 42)

  # validation images
  valid_image_array_gen <- flow_images_from_directory(valid_image_files_path,
                                                      valid_data_gen,
                                                      shuffle = F,
                                                      color_mode = "rgba",
                                                      target_size = target_size,
                                                      class_mode = "categorical",
                                                      classes = class_list,
                                                      batch = batch_size,
                                                      seed = 42)
  cat("Number of images per class:")

  table(factor(train_image_array_gen$classes))
  table(factor(valid_image_array_gen$classes))

  train_image_array_gen$class_indices


  # number of training samples
  train_samples <- train_image_array_gen$n
  # number of validation samples
  valid_samples <- valid_image_array_gen$n


  # # callbacks
  dir.create("./epoch_history/", showWarnings=F)
  dir.create("./weights/", showWarnings=F)
  dir.create("./weights_r_save/", showWarnings=F)

  # clear weights
  unlink(list.files("./weights/", full.names=T))


  ## Train the model

  # mixed precision
  tf$keras$mixed_precision$experimental$set_policy('mixed_float16')

  # fit
  hist <- model %>% fit_generator(
    # training data
    train_image_array_gen,

    # epochs
    steps_per_epoch = as.integer(train_samples / batch_size),
    epochs = epochs,

    # validation data
    validation_data = valid_image_array_gen,
    validation_steps = as.integer(valid_samples / batch_size),

    # print progress
    verbose = 2,
    # callbacks = list(
    #   # save best model after every epoch
    #   callback_model_checkpoint("weights", save_best_only = TRUE),
    #   # only needed for visualising with TensorBoard
    #   callback_tensorboard(log_dir = "epoch_history")
    # )
    callbacks_list <- list(
      callback_csv_logger("./epoch_history/epoch_history.csv", separator = ";", append = FALSE),
      callback_model_checkpoint(filepath = paste0("./weights/", use_model, "_tf2_{epoch:05d}_{val_accuracy:.4f}.h5"),
                                monitor = "val_accuracy",save_best_only = TRUE,
                                save_weights_only = TRUE, mode = "max" ,save_freq = NULL)
    )
  )


  # clear GPU
  tf$keras.backend$clear_session()
  py_gc <- import('gc')
  py_gc$collect()

  # copy the best weight to the save folder
  weight_fname = rev(list.files("weights", pattern = ".h5", full.names=T))[1]
  weight_fname2 = sub("weights", "weights_r_save", weight_fname)
  file.copy(weight_fname, weight_fname2)
  file.copy("epoch_history\\epoch_history.csv", sub(".h5", ".csv", weight_fname2))
  print(paste0("The best weight was saved in weights_r_save folder, named: ", weight_fname2))

  # return
  return(weight_fname2)


}
