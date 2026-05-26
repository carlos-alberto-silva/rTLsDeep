# Full end-to-end workflow test
# Tests the complete pipeline: TLS processing → image generation → CNN training → prediction → analysis
# Gated by environment variable: RTLSDEEP_E2E_TEST=TRUE

skip_e2e = function() {
  if (isFALSE(as.logical(Sys.getenv("RTLSDEEP_E2E_TEST", "FALSE")))) {
    skip("RTLSDEEP_E2E_TEST is not set to TRUE")
  }
  if (!reticulate::py_available(initialize = TRUE)) {
    skip("Python is not available")
  }
  if (!reticulate::py_module_available("tensorflow")) {
    skip("TensorFlow is not available")
  }
}

test_that("e2e: TLS data processing pipeline (load, rotate, 2D grid)", {
  skip_e2e()

  lasfile <- system.file("extdata", "tree_c1.laz", package = "rTLsDeep")
  skip_if_not(file.exists(lasfile))

  las <- lidR::readLAS(lasfile)
  expect_s4_class(las, "LAS")
  expect_true(nrow(las@data) > 0)

  # Rotate around z-axis
  las_rot <- tlsrotate3d(las, theta = 45, by = "z", scale = TRUE)
  expect_s4_class(las_rot, "LAS")
  expect_equal(nrow(las_rot@data), nrow(las@data))

  # Generate 2D grid snapshot (xz view)
  func = ~list(Z = max(Z))
  grid_xz <- getTLS2D(las_rot, res = 0.05, by = "xz", func = func, scale = TRUE)
  expect_s4_class(grid_xz, "SpatRaster")
  expect_true(terra::nlyr(grid_xz) >= 1)

  # Generate 2D grid snapshot (yz view)
  grid_yz <- getTLS2D(las_rot, res = 0.05, by = "yz", func = func, scale = TRUE)
  expect_s4_class(grid_yz, "SpatRaster")
  expect_true(terra::nlyr(grid_yz) >= 1)
})

test_that("e2e: image generation from 2D grids (train/val datasets)", {
  skip_e2e()

  tmpdir <- tempfile("e2e_images_")
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  # Create train/validation folders with classes
  dir.create(file.path(tmpdir, "train", "C1"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(tmpdir, "train", "C2"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(tmpdir, "validation", "C1"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(tmpdir, "validation", "C2"), recursive = TRUE, showWarnings = FALSE)

  # Load trees
  lasfile_c1 <- system.file("extdata", "tree_c1.laz", package = "rTLsDeep")
  lasfile_c2 <- system.file("extdata", "tree_c2.laz", package = "rTLsDeep")
  skip_if_not(file.exists(lasfile_c1))
  skip_if_not(file.exists(lasfile_c2))

  tree_c1 <- lidR::readLAS(lasfile_c1)
  tree_c2 <- lidR::readLAS(lasfile_c2)

  func = ~list(Z = max(Z))
  img_width <- 64
  img_height <- 64

  createImage = function(raster, file_path, width, height) {
    png(file_path, units = "px", width = width, height = height)
    par(mar = c(0, 0, 0, 0))
    terra::image(raster, col = viridis::viridis(50), axes = FALSE,
                 ylim = c(0, 30))
    dev.off()
  }

  rotations <- c(0, 45, 90, 135)
  ii = 1

  for (rotation in rotations) {
    tree1 <- tlsrotate3d(tree_c1, theta = rotation, by = "z", scale = TRUE)
    grid1 <- getTLS2D(tree1, res = 0.05, by = "xz", func = func, scale = TRUE)
    createImage(grid1, file.path(tmpdir, "train", "C1", paste0("img_", ii, ".png")),
                img_width, img_height)
    ii = ii + 1

    tree2 <- tlsrotate3d(tree_c2, theta = rotation, by = "z", scale = TRUE)
    grid2 <- getTLS2D(tree2, res = 0.05, by = "xz", func = func, scale = TRUE)
    createImage(grid2, file.path(tmpdir, "train", "C2", paste0("img_", ii, ".png")),
                img_width, img_height)
    ii = ii + 1
  }

  # Validation images (use original trees at 0 rotation)
  grid_v1 <- getTLS2D(tree_c1, res = 0.05, by = "xz", func = func, scale = TRUE)
  createImage(grid_v1, file.path(tmpdir, "validation", "C1", "val_img_1.png"),
              img_width, img_height)
  grid_v2 <- getTLS2D(tree_c2, res = 0.05, by = "xz", func = func, scale = TRUE)
  createImage(grid_v2, file.path(tmpdir, "validation", "C2", "val_img_1.png"),
              img_width, img_height)

  # Verify images were created
  train_files <- list.files(file.path(tmpdir, "train"), recursive = TRUE, full.names = TRUE)
  val_files <- list.files(file.path(tmpdir, "validation"), recursive = TRUE, full.names = TRUE)
  expect_true(length(train_files) >= 4)
  expect_true(length(val_files) >= 2)
  expect_true(all(file.exists(train_files)))
  expect_true(all(file.exists(val_files)))
})

test_that("e2e: full CNN workflow (setup, build, train, predict, confusion matrix)", {
  skip_e2e()

  tmpdir <- tempfile("e2e_cnn_")
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  # Use package built-in train/validation data (smaller images already exist)
  train_path <- system.file("extdata", "train", package = "rTLsDeep")
  val_path <- system.file("extdata", "validation", package = "rTLsDeep")
  skip_if_not(file.exists(train_path))
  skip_if_not(file.exists(val_path))

  # Setup Python and TensorFlow
  rtlsdeep_setup(python_version = "3.12")
  expect_true(reticulate::py_module_available("tensorflow"))

  # Model parameters
  img_width <- 64
  img_height <- 64
  class_list <- c("C1", "C2")
  lr_rate <- 0.0001
  batch_size <- 4L
  epochs <- 2L
  target_size <- c(img_width, img_height)

  # Build model
  model <- get_dl_model(
    model_type = "simple",
    img_width = img_width,
    img_height = img_height,
    channels = 4,
    lr_rate = lr_rate,
    tensorflow_dir = NA,
    class_list = class_list
  )
  expect_true(grepl("keras", class(model)[1], ignore.case = TRUE))

  # Train model
  weights_file <- fit_dl_model(
    model = model,
    train_input_path = train_path,
    test_input_path = val_path,
    output_path = file.path(tmpdir, "output"),
    target_size = target_size,
    batch_size = batch_size,
    class_list = class_list,
    epochs = epochs,
    lr_rate = lr_rate
  )
  expect_true(is.character(weights_file))
  expect_true(grepl("\\.weights\\.h5$", weights_file))
  expect_true(file.exists(weights_file))

  # Predict
  predictions <- predict_treedamage(
    model = model,
    input_file_path = val_path,
    weights = weights_file,
    target_size = target_size,
    class_list = class_list,
    batch_size = batch_size
  )
  expect_true(inherits(predictions, "factor"))
  expect_true(length(predictions) > 0)
  expect_true(all(levels(predictions) %in% class_list))

  # Get reference classes and confusion matrix
  ref_classes <- get_validation_classes(file_path = val_path)
  expect_true(length(ref_classes) == length(predictions))

  cm <- confmatrix_treedamage(
    predict_class = predictions,
    test_classes = ref_classes,
    class_list = class_list
  )
  expect_s3_class(cm, "confusionMatrix")
  expect_true(!is.null(cm$table))
  expect_true(!is.null(cm$overall))
  expect_true("Accuracy" %in% names(cm$overall))
})

test_that("e2e: confusion matrix plotting", {
  skip_e2e()

  tmpdir <- tempfile("e2e_plot_")
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  # Use package built-in data
  train_path <- system.file("extdata", "train", package = "rTLsDeep")
  val_path <- system.file("extdata", "validation", package = "rTLsDeep")
  skip_if_not(file.exists(train_path))
  skip_if_not(file.exists(val_path))

  # Quick setup and train
  rtlsdeep_setup(python_version = "3.12")

  model <- get_dl_model(
    model_type = "simple",
    img_width = 64,
    img_height = 64,
    channels = 4,
    lr_rate = 0.0001,
    tensorflow_dir = NA,
    class_list = c("C1", "C2")
  )

  weights_file <- fit_dl_model(
    model = model,
    train_input_path = train_path,
    test_input_path = val_path,
    output_path = file.path(tmpdir, "output"),
    target_size = c(64, 64),
    batch_size = 4L,
    class_list = c("C1", "C2"),
    epochs = 2L,
    lr_rate = 0.0001
  )

  predictions <- predict_treedamage(
    model = model,
    input_file_path = val_path,
    weights = weights_file,
    target_size = c(64, 64),
    class_list = c("C1", "C2"),
    batch_size = 4L
  )

  ref_classes <- get_validation_classes(file_path = val_path)
  cm <- confmatrix_treedamage(
    predict_class = predictions,
    test_classes = ref_classes,
    class_list = c("C1", "C2")
  )

  # Plot with percentage
  p1 <- gcmplot(cm, colors = c(low = "white", high = "#009194"),
                title = "Test E2E", prop = TRUE)
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p1, "gg")

  # Plot with frequency
  p2 <- gcmplot(cm, colors = c(low = "lightblue", high = "darkblue"),
                title = "Test E2E Freq", prop = FALSE)
  expect_s3_class(p2, "ggplot")
  expect_s3_class(p2, "gg")
})
