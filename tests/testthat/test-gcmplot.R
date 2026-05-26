test_that("gcmplot returns a ggplot object", {
  predict_class <- c("C1", "C1", "C2", "C2", "C1", "C2")
  test_classes <- c("C1", "C2", "C2", "C2", "C1", "C1")
  class_list <- c("C1", "C2")

  cm <- confmatrix_treedamage(
    predict_class = predict_class,
    test_classes = test_classes,
    class_list = class_list
  )

  plot_obj <- gcmplot(cm, title = "test")
  expect_s3_class(plot_obj, "ggplot")
})

test_that("gcmplot accepts custom colors", {
  predict_class <- c("C1", "C1", "C2", "C2")
  test_classes <- c("C1", "C2", "C2", "C1")
  class_list <- c("C1", "C2")

  cm <- confmatrix_treedamage(
    predict_class = predict_class,
    test_classes = test_classes,
    class_list = class_list
  )

  plot_obj <- gcmplot(cm, colors = c(low = "white", high = "red"), title = "test")
  expect_s3_class(plot_obj, "ggplot")
})
