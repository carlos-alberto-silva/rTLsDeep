#'Selecting deep learning modeling approaches
#'
#'@description This function selects and returns the deep learning approach to be used with the fit_dl_model function for
#'post-hurricane individual tree-level damage classification.
#'
#'@usage get_dl_model(model_type, img_width, img_height, channels, lr_rate, tensorflow_dir, class_list)
#'
#'@param model_type A character string describing the deep learning model to be used. Available models: "vgg", "resnet", "inception", "densenet", "efficientnet", "simple".
#'@param img_width A numeric value describing the width of the image used for training. Default: 256.
#'@param img_height A numeric value describing the height of the image used for training. Default: 256.
#'@param class_list A character string or numeric value describing the post-hurricane individual tree level damage classes, e.g.: c("1","2","3","4","5","6").
#'@param lr_rate A numeric value indicating the learning rate. Default: 0.0001.
#'@param tensorflow_dir A character string indicating the directory for the tensorflow python environment. Guide to install the environment here: https://doi.org/10.5281/zenodo.3929709
#'
#'@return Returns the model object with the required parameters.
#'
#'@seealso \url{XXXX}
#'
#'@examples
#'\donttest{
#'
#'# Set directory to tensorflow (python environment)
#'# This is required if running deep learning local computer with GPU
#'# Guide to install here: https://doi.org/10.5281/zenodo.3929709
#'tensorflow_dir = "C:\\ProgramData\\Miniconda3\\envs\\r-tensorflow"
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
#'lr_rate = 0.0001
#'class_list = as.character(1:6) # Damage classes
#'
#'# get model
#'model = get_dl_model(model_type=model_type,
#'                     img_width=img_width,
#'                     img_height=img_height,
#'                     lr_rate = lr_rate,
#'                     tensorflow_dir = tensorflow_dir,
#'                     class_list = class_list)
#'
#'}
#'@import keras layer_input layer_conv_2d layer_activation layer_activation_leaky_relu layer_batch_normalization layer_max_pooling_2d layer_dropout layer_flatten layer_dense keras_model application_vgg16 application_resnet152_v2 application_inception_v3 application_densenet201 application_efficientnet_b7 optimizer_adam
#'@import reticulate use_python
#'@import compiler compile
#'@export
get_dl_model = function(model_type = "vgg", img_width = 256, img_height = 256, lr_rate = 0.0001, tensorflow_dir, class_list) {

  # define tensorflow python environment
  reticulate::use_python(tensorflow_dir, required = T)

  # number of classes
  output_n = length(class_list)


  # simple cnn model (https://shirinsplayground.netlify.app/2018/06/keras_fruits/)

  if (model_type == "simple") {

    # define inputs
    inputs <- keras::layer_input(shape = c(img_width, img_height, channels))

    # define outputs
    outputs <- inputs[,,,1:3] %>%
      keras::layer_conv_2d(filter = 32, kernel_size = c(3,3), padding = "same") %>%
      keras::layer_activation("relu") %>%

      # Second hidden layer
      keras::layer_conv_2d(filter = 16, kernel_size = c(3,3), padding = "same") %>%
      keras::layer_activation_leaky_relu(0.5) %>%
      keras::layer_batch_normalization() %>%

      # Use max pooling
      keras::layer_max_pooling_2d(pool_size = c(2,2)) %>%
      keras::layer_dropout(0.25) %>%

      # Flatten max filtered output into feature vector
      # and feed into dense layer
      keras::layer_flatten() %>%
      keras::layer_dense(100) %>%
      keras::layer_activation("relu") %>%
      keras::layer_dropout(0.5) %>%

      # Outputs from dense layer are projected onto output layer
      keras::layer_dense(output_n) %>%
      keras::layer_activation("softmax")

    # put model together
    model <- keras::keras_model(inputs, outputs)
    model %>% compiler::compile(
      loss = "categorical_crossentropy",
      optimizer = keras::optimizer_adam(learning_rate = lr_rate),
      metrics = "accuracy"
    )


    #
    summary(model)

  }


  # pre-trained models (https://keras.io/api/applications/#usage-examples-for-image-classification-models)

  if (model_type != "simple") {

    # initialise model VGG16
    if (model_type == "vgg") conv_base <- keras::application_vgg16(weights = 'imagenet', include_top = FALSE, input_shape = c(img_width, img_height, 3))

    # initialise model ResNet
    if (model_type == "resnet") conv_base <- keras::application_resnet152_v2(weights = 'imagenet', include_top = FALSE, input_shape = c(img_width, img_height, 3))

    # initialise model InceptionV3
    if (model_type == "inception") conv_base <- keras::application_inception_v3(weights = 'imagenet', include_top = FALSE, input_shape = c(img_width, img_height, 3))

    # initialise model DenseNet
    if (model_type == "densenet") conv_base <- keras::application_densenet201(weights = 'imagenet', include_top = FALSE, input_shape = c(img_width, img_height, 3))

    # initialise model EfficientNet
    if (model_type == "efficientnet") conv_base <- keras::application_efficientnet_b7(weights = 'imagenet', include_top = FALSE, input_shape = c(img_width, img_height, 3))

    # define inputs
    inputs <- keras::layer_input(shape = c(img_width, img_height, 3))

    # define outputs
    outputs <- inputs %>%
      # the pre-trained model
      conv_base() %>%

      # Flatten
      keras::layer_flatten() %>%

      # Outputs from dense layer are projected onto output layer
      keras::layer_dense(output_n) %>%
      keras::layer_activation("softmax")

    # put model together
    model <- keras::keras_model(inputs, outputs)
    model %>% compiler::compile(
      loss = "categorical_crossentropy",
      optimizer = keras::optimizer_adam(learning_rate = lr_rate),
      metrics = "accuracy"
    )

    #
    summary(model)

  }

  return(model)

}