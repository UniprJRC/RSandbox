# One test block per FSDA method. Copy a block for each new function.

test_that("LXS: same numbers as MATLAB's LXS", {
  L = live_fsda(); f = L$fsda
  f$eval_m("rng(1)", nargout = 0)
  r = f$LXS(L$y, L$X, nsamp = 100, plots = 0, msg = 0)
  f$eval_m("rng(1)", nargout = 0)
  expect_matches_matlab(f, r, "LXS(y, X, 'nsamp', 100, 'plots', 0, 'msg', 0)")
})

test_that("resindexplot: opens a figure, and a vector of names is accepted", {
  L = live_fsda(); f = L$fsda
  fit = f$LXS(L$y, L$X, nsamp = 100, plots = 0, msg = 0)
  expect_plot_made(f, f$resindexplot(fit$residuals, conflev = 0.99))
  expect_no_error(f$resindexplot(fit$residuals, nameX = c("lot size", "bedrooms")))
})

test_that("spmplot: opens a figure", {
  L = live_fsda(); f = L$fsda
  expect_plot_made(f, f$spmplot(L$data[, 1:5]))
})

test_that("call(): a NULL positional argument is an error, not a silent shift", {
  L = live_fsda(); f = L$fsda
  expect_error(f$call("LXS", L$y, NULL), "NULL passed as positional")
})
