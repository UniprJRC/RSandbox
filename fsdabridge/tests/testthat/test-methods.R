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

# ---- Regression track (Simran) ----

test_that("MMreg: same numbers as MATLAB's MMreg", {
  L = live_fsda(); f = L$fsda
  f$eval_m("rng(1)", nargout = 0)
  r = f$MMreg(L$y, L$X, Smsg = 0, Snsamp = 100)
  f$eval_m("rng(1)", nargout = 0)
  expect_matches_matlab(f, r, "MMreg(y, X, 'Smsg', 0, 'Snsamp', 100)")
})

test_that("Sreg: same numbers as MATLAB's Sreg", {
  L = live_fsda(); f = L$fsda
  f$eval_m("rng(1)", nargout = 0)
  r = f$Sreg(L$y, L$X, nsamp = 100, msg = 0)
  f$eval_m("rng(1)", nargout = 0)
  expect_matches_matlab(f, r, "Sreg(y, X, 'nsamp', 100, 'msg', 0)")
})

test_that("FSRaddt: same numbers as MATLAB's FSRaddt", {
  L = live_fsda(); f = L$fsda
  f$eval_m("rng(1)", nargout = 0)
  r = f$FSRaddt(L$y, L$X, nsamp = 100, plots = 0, msg = 0)
  f$eval_m("rng(1)", nargout = 0)
  expect_matches_matlab(f, r, "FSRaddt(y, X, 'nsamp', 100, 'plots', 0, 'msg', 0)")
})

test_that("Score: same numbers as MATLAB's Score", {
  L = live_fsda(); f = L$fsda
  r = f$Score(L$y, L$X, la = c(-1, -0.5, 0, 0.5, 1))
  expect_matches_matlab(f, r, "Score(y, X, 'la', [-1 -0.5 0 0.5 1])")
})

test_that("regressH: same numbers as MATLAB's regressH", {
  L = live_fsda(); f = L$fsda
  # Z = lot size, the first predictor, drives the variance
  r = f$regressH(L$y, L$X, L$X[, 1, drop = FALSE], msgiter = 0)
  expect_matches_matlab(f, r, "regressH(y, X, X(:,1), 'msgiter', 0)")
})

test_that("regressB: same numbers as MATLAB's regressB", {
  L = live_fsda(); f = L$fsda
  # Prior built from the first 50 houses, as if they were an earlier sample
  f$eval_m(paste("Xc = [ones(50,1) X(1:50,:)]; R = Xc' * Xc;",
                 "beta0 = zeros(5,1); tau0 = 1; n0 = 50;"), nargout = 0)
  R = f$eval_m("R")
  r = f$regressB(L$y, L$X, matrix(0, 5, 1), R, 1, 50)
  expect_matches_matlab(f, r, "regressB(y, X, beta0, R, tau0, n0)")
})
