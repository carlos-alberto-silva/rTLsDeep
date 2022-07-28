#'Fitting deep learning models for post-hurricane individual tree-level damage classification
#'
#'@description This function fits deep learning models for post-hurricane individual tree level damage classification using TLS-derived 2D images
#'
#'@usage fit_dl_model(use_model, train_image_files_path, valid_image_files_path, target_size, batch_size, class_list, epochs, tensorflow_dir)
#'
#'@param use_model A GEDI Level2A object (output of [readLevel2A()] function).
#'An S4 object of class "gedi.level2a".
#'@param img_width Numeric. West longitude (x) coordinate of the bounding rectangle, in decimal degrees.
#'@param img_height Numeric. East longitude (x) coordinate of the bounding rectangle, in decimal degrees.
#'@param channels Numeric. Number of channels in the input image (e.g. 1, 3 or 4 layers). Default is 4.
#'@param lr_rate Numeric. Model learning rate. Default is 0.0001.
#'@param class_list Numeric. North latitude (y) coordinate of the bounding rectangle, in decimal degrees
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
#'@import keras layer_input
#'@export
fit_dl_model = function(use_model = "vgg", img_width = 256, img_height = 256, channels = 4, lr_rate = 0.0001, tensorflow_dir, class_list) {
  # tensorflow_dir is the directory for the tensorflow python environment, guide to install here: https://doi.org/10.5281/zenodo.3929709

  # library
  require(reticulate)
  use_python(tensorflow_dir, required = T)
  require(keras)
  #require(tfdatasets)
  require(tidyverse)

  # number of classes
  output_n = length(class_list)


  # simple cnn model

  # https://shirinsplayground.netlify.app/2018/06/keras_fruits/

  if (use_model == "simple") {

    # define inputs
    inputs <- keras::layer_input(shape = c(img_width, img_height, channels))

    # define outputs
    outputs <- inputs[,,,1:3] %>%
      layer_conv_2d(filter = 32, kernel_size = c(3,3), padding = "same") %>%
      layer_activation("relu") %>%

      # Second hidden layer
      layer_conv_2d(filter = 16, kernel_size = c(3,3), padding = "same") %>%
      layer_activation_leaky_relu(0.5) %>%
      layer_batch_normalization() %>%

      # Use max pooling
      layer_max_pooling_2d(pool_size = c(2,2)) %>%
      layer_dropout(0.25) %>%

      # Flatten max filtered output into feature vector
      # and feed into dense layer
      layer_flatten() %>%
      layer_dense(100) %>%
      layer_activation("relu") %>%
      layer_dropout(0.5) %>%

      # Outputs from dense layer are projected onto output layer
      layer_dense(output_n) %>%
      layer_activation("softmax")

    # put model together
    model <- keras_model(inputs, outputs)
    model %>% compile(
      loss = "categorical_crossentropy",
      optimizer = optimizer_adam(learning_rate = lr_rate),
      metrics = "accuracy"
    )


    #
    summary(model)

  }


  # pre-trained models

  if (use_model != "simple") {

    # https://keras.io/api/applications/#usage-examples-for-image-classification-models

    # initialise model VGG16
    if (use_model == "vgg") conv_base <- application_vgg16(weights = 'imagenet', include_top = FALSE, input_shape = c(img_width, img_height, 3))

    # initialise model ResNet
    if (use_model == "resnet") conv_base <- application_resnet152_v2(weights = 'imagenet', include_top = FALSE, input_shape = c(img_width, img_height, 3))

    # initialise model InceptionV3
    if (use_model == "inception") conv_base <- application_inception_v3(weights = 'imagenet', include_top = FALSE, input_shape = c(img_width, img_height, 3))

    # initialise model DenseNet
    if (use_model == "densenet") conv_base <- application_densenet201(weights = 'imagenet', include_top = FALSE, input_shape = c(img_width, img_height, 3))

    # initialise model EfficientNet
    if (use_model == "efficientnet") conv_base <- application_efficientnet_b7(weights = 'imagenet', include_top = FALSE, input_shape = c(img_width, img_height, 3))

    # define inputs
    inputs <- layer_input(shape = c(img_width, img_height, channels))

    # define outputs
    outputs <- inputs[,,,1:3] %>%
      # the pre-trained model
      conv_base() %>%

      # Flatten
      layer_flatten() %>%

      # Outputs from dense layer are projected onto output layer
      layer_dense(output_n) %>%
      layer_activation("softmax")

    # put model together
    model <- keras_model(inputs, outputs)
    model %>% compile(
      loss = "categorical_crossentropy",
      optimizer = optimizer_adam(learning_rate = lr_rate),
      metrics = "accuracy"
    )

    #
    summary(model)

  }

  return(model)

}
