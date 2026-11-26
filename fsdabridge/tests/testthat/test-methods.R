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

test_that("mcd: returns the raw MCD structure", {
  L = live_fsda(); f = L$fsda
  Y = L$data[, 2:4]
  f$eval_m("Y = hprice(:,2:4); rng(1)", nargout = 0)
  out = f$mcd(Y, nsamp = 100, plots = 0, msg = 0)
  f$eval_m("rng(1)", nargout = 0)
  expect_matches_matlab(f, out, "mcd(Y, 'nsamp', 100, 'plots', 0, 'msg', 0)")
})

test_that("FSM: returns the multivariate forward-search result", {
  L = live_fsda(); f = L$fsda
  Y = L$data[, 2:4]
  f$eval_m("Y = hprice(:,2:4); rng(1)", nargout = 0)
  out = f$FSM(Y, plots = 0, msg = 0)
  f$eval_m("rng(1)", nargout = 0)
  expect_matches_matlab(f, out, "FSM(Y, 'plots', 0, 'msg', 0)")
})

test_that("FSMeda: returns exploratory forward-search monitoring", {
  L = live_fsda(); f = L$fsda
  Y = L$data[, 2:4]
  f$eval_m("Y = hprice(:,2:4); rng(1)", nargout = 0)
  out = f$FSMeda(Y, bsb = 0, plots = 0, msg = 0)
  f$eval_m("rng(1)", nargout = 0)
  expect_matches_matlab(f, out, "FSMeda(Y, 0, 'plots', 0, 'msg', 0)")
})

test_that("Smult: returns the multivariate S-estimator structure", {
  L = live_fsda(); f = L$fsda
  Y = L$data[, 2:4]
  f$eval_m("Y = hprice(:,2:4); rng(1)", nargout = 0)
  out = f$Smult(Y, nsamp = 100, plots = 0, msg = 0)
  f$eval_m("rng(1)", nargout = 0)
  expect_matches_matlab(f, out, "Smult(Y, 'nsamp', 100, 'plots', 0, 'msg', 0)")
})

test_that("MMmult: returns the multivariate MM-estimator structure", {
  L = live_fsda(); f = L$fsda
  Y = L$data[, 2:4]
  f$eval_m("Y = hprice(:,2:4); rng(1)", nargout = 0)
  out = f$MMmult(Y, Snsamp = 100, plots = 0, Smsg = 0)
  f$eval_m("rng(1)", nargout = 0)
  expect_matches_matlab(f, out, "MMmult(Y, 'Snsamp', 100, 'plots', 0, 'Smsg', 0)")
})

test_that("mve: returns the raw MVE structure", {
  L = live_fsda(); f = L$fsda
  Y = L$data[, 2:4]
  f$eval_m("Y = hprice(:,2:4); rng(1)", nargout = 0)
  out = f$mve(Y, nsamp = 100, plots = 0, msg = 0)
  f$eval_m("rng(1)", nargout = 0)
  expect_matches_matlab(f, out, "mve(Y, 'nsamp', 100, 'plots', 0, 'msg', 0)")
})

test_that("pcaFS: returns the PCA result structure without launching the app", {
  L = live_fsda(); f = L$fsda
  Y = L$data[, 2:4]
  f$eval_m("Y = hprice(:,2:4);", nargout = 0)
  out = f$pcaFS(Y, biplot = 0, plots = 0, dispresults = FALSE)
  expect_matches_matlab(f, out, "pcaFS(Y, 'biplot', 0, 'plots', 0, 'dispresults', false)")
})

test_that("FSMmmd: returns the minimum Mahalanobis-distance monitoring matrix", {
  L = live_fsda(); f = L$fsda
  Y = L$data[, 2:4]
  f$eval_m("Y = hprice(:,2:4); rng(1)", nargout = 0)
  out = f$FSMmmd(Y, bsb = 0, plots = 0, msg = 0)
  f$eval_m("rng(1)", nargout = 0)
  expected = f$eval_m("FSMmmd(Y, 0, 'plots', 0, 'msg', 0)")
  expect_equal(out, expected, tolerance = 1e-9)
})
