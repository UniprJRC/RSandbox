# Runs last (files run in alphabetical order): closes the shared MATLAB session
# opened by live_fsda(), so no MATLAB process is left behind.
test_that("the shared MATLAB session is closed", {
  if (!is.null(.live$fsda)) {
    .live$fsda$close()
    .live$fsda = NULL
  }
  expect_null(.live$fsda)
})
