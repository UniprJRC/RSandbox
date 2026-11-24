# Helpers for live tests (need MATLAB + FSDA). Every live test starts with
# live_fsda(), which skips the test when MATLAB is not available, so these tests
# never fail on a machine without MATLAB (CRAN included).
#
# Run live tests locally:
#   FSDA_LIVE=1 Rscript -e 'devtools::test("fsdabridge")'

# One shared MATLAB session for the whole test run, with the hprice data loaded
# (y = price, X = lot size, bedrooms, bathrooms, stories).
.live = new.env()

live_fsda = function() {
  skip_if(!nzchar(Sys.getenv("FSDA_LIVE")),
          "set FSDA_LIVE=1 (with FSDA_DEV_VENV / FSDA_ROOT) to run live tests")
  if (is.null(.live$fsda)) {
    root = Sys.getenv("FSDA_ROOT")
    .live$fsda = FSDA$new(fsda_root = if (nzchar(root)) root else NULL)
    .live$fsda$eval_m("load('hprice.txt')", nargout = 0)
    .live$fsda$eval_m("y = hprice(:,1); X = hprice(:,2:5);", nargout = 0)
    d = .live$fsda$eval_m("hprice")
    .live$y = d[, 1]
    .live$X = d[, 2:5]
    .live$data = d
  }
  .live
}

# TEST 1 (functions that return results): the R method must give the same
# numbers as calling the same FSDA function directly in MATLAB.
#   r_result      : what the R6 method returned
#   matlab_expr   : the same call written in MATLAB, as a string
#   seed_first    : reset MATLAB's random generator first, for functions with
#                   random subsamples (rng(1) must also be run before the R call)
expect_matches_matlab = function(fsda, r_result, matlab_expr, tol = 1e-9) {
  m = fsda$eval_m(matlab_expr)
  expect_true(is.list(r_result) && is.list(m))
  common = intersect(names(r_result), names(m))
  expect_gt(length(common), 0)
  for (nm in common) {
    a = r_result[[nm]]; b = m[[nm]]
    if (is.numeric(a) && is.numeric(b)) {
      expect_equal(as.numeric(a), as.numeric(b), tolerance = tol, info = nm)
    }
  }
}

# TEST 2 (functions that draw): the call must not fail and must open a figure.
expect_plot_made = function(fsda, code) {
  count = function() as.numeric(fsda$eval_m("numel(findall(0, 'type', 'figure'))"))
  before = count()
  force(code)
  expect_gt(count(), before)
}
