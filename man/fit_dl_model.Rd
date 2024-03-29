% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fit_dl_model.R
\name{fit_dl_model}
\alias{fit_dl_model}
\title{Fitting deep learning models for post-hurricane individual tree level damage classification}
\usage{
fit_dl_model(
  model,
  train_input_path,
  test_input_path,
  output_path = tempdir(),
  target_size = c(256, 256),
  batch_size = 8,
  class_list,
  epochs = 20L,
  lr_rate = 1e-04
)
}
\arguments{
\item{model}{A model object output of the get_dl_model function. See [rTLsDeep::get_dl_model()].}

\item{train_input_path}{A character string describing the path to the training dataset, e.g.: "C:/train_data/".}

\item{test_input_path}{A character string describing the path to the testing dataset, e.g.: "C:/test_data/".}

\item{output_path}{A character string describing the path where to save the weights for the neural network.}

\item{target_size}{A vector of two values describing the image dimensions (Width and height) to be used in the model. Default: c(256,256)}

\item{batch_size}{A numerical value indicating the number of images to be processed at the same time. Reduce the batch_size if the GPU is giving memory errors.}

\item{class_list}{A character string or numeric value describing the post-hurricane individual tree level damage classes, e.g.: c("1","2","3","4","5","6").}

\item{epochs}{A numeric value indicating the number of iterations to train the model. Use at least 20 for pre-trained models, and at least 200 for a model without pre-trained weights.}

\item{lr_rate}{A numeric value indicating the learning rate. Default: 0.0001.}
}
\value{
Returns a character string indicating the filename of the best weights trained for the chosen model.
}
\description{
This function fits deep learning models for post-hurricane individual tree level damage classification using TLS-derived 2D images
}
\examples{
\donttest{
# Set directory to tensorflow (python environment)
# This is required if running deep learning local computer with GPU
# Guide to install here: https://doi.org/10.5281/zenodo.3929709
tensorflow_dir = NA

# define model type
model_type = "simple"
#model_type = "vgg"
#model_type = "inception"
#model_type = "resnet"
#model_type = "densenet"
#model_type = "efficientnet"

train_image_files_path = system.file('extdata', 'train', package='rTLsDeep')
test_image_files_path = system.file('extdata', 'validation', package='rTLsDeep')
img_width <- 256
img_height <- 256
class_list_train = unique(list.files(train_image_files_path))
class_list_test = unique(list.files(test_image_files_path))
lr_rate = 0.0001
target_size <- c(img_width, img_height)
channels <- 4
batch_size = 8L
epochs = 2L

# get model
rtlsdeep_setup()

model = get_dl_model(model_type=model_type,
                    img_width=img_width,
                    img_height=img_height,
                    channels=channels,
                    lr_rate = lr_rate,
                    tensorflow_dir = tensorflow_dir,
                    class_list = class_list_train)


# train model and return best weights
weights = fit_dl_model(model = model,
                                train_input_path = train_image_files_path,
                                test_input_path = test_image_files_path,
                                target_size = target_size,
                                batch_size = batch_size,
                                class_list = class_list_train,
                                epochs = epochs,
                                lr_rate = lr_rate)

unlink('epoch_history', recursive = TRUE)
unlink('weights', recursive = TRUE)
unlink('weights_r_save', recursive = TRUE)

}
}
