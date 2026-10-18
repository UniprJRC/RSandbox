# R6 prototype: robust regression on the Hawkins data, plus chaining experiments.
#
# Run from the repo root (RSandbox/), with MATLAB + FSDA installed and the
# Python venv that has matlabengine:
#   Sys.setenv(FSDA_DEV_VENV = "/path/to/.venv/bin/python")
#   source("demo/r6_robust_regression.R")
#
# Each experiment prints PASS or FAIL with the error, so the output can be
# pasted straight into the team chat.

devtools::load_all("fsdabridge")

try_step = function(label, expr) {
  res = tryCatch({ force(expr); "PASS" },
                 error = function(e) paste("FAIL:", conditionMessage(e)))
  cat(sprintf("\n[%s] %s\n", label, res))
  invisible(res)
}

fsda = FSDA$new()

# --- Data: Hawkins (128 x 9), loaded by MATLAB from FSDA's own datasets ------
hawkins = fsda$call("load", "hawkins.txt")
y = hawkins[, 9, drop = FALSE]   # keep y as an n x 1 matrix (column vector)
X = hawkins[, 1:8]

# --- 1. Single routines ----------------------------------------------------
try_step("LXS", {
  fsda$call("rng", 1234, nargout = 0)
  lxs = fsda$LXS(y, X, msg = 0)
  cat("LXS outliers:", length(lxs$outliers), "\n")
})

try_step("FSR", {
  fsda$call("rng", 1234, nargout = 0)
  fsr = fsda$FSR(y, X, plots = 0, msg = FALSE)
  cat("FSR outliers:", length(fsr$ListOut), "\n")
})

try_step("MMreg", {
  fsda$call("rng", 1234, nargout = 0)
  mm = fsda$MMreg(y, X, Smsg = FALSE)
  cat("MMreg outliers:", length(mm$outliers), "\n")
})

try_step("FSR with plots", {
  fsda$call("rng", 1234, nargout = 0)
  fsda$FSR(y, X, msg = FALSE)          # plots = 1 is FSDA's default
})

# --- 2. Chaining, step 1: numbers only (LXS -> FSReda) --------------------
# LXS's best subset `bs` is a plain numeric vector, so this should just work.
try_step("chain LXS -> FSReda", {
  fsda$call("rng", 1234, nargout = 0)
  lxs = fsda$LXS(y, X, nsamp = 1000, msg = 0)
  eda <<- fsda$FSReda(y, X, lxs$bs)
  cat("RES is", paste(dim(eda$RES), collapse = " x "), "\n")
})

# --- 3. Chaining, step 2: a structure back into MATLAB (FSReda -> resfwdplot)
# This is the open question. Three attempts, from most to least natural.

# A) Send the whole FSReda output back as it came out.
try_step("A: resfwdplot(full FSReda list)", fsda$resfwdplot(eda))

# B) Send only the field resfwdplot needs, with tooltips off (they need `Un`).
try_step("B: resfwdplot(list(RES = ...))",
         fsda$resfwdplot(list(RES = eda$RES), datatooltip = 0))

# C) Never bring the structure into R: keep it in the MATLAB workspace.
#    This is the route that worked for the Julia package.
try_step("C: workspace route", {
  fsda$eval("load('hawkins.txt'); yW = hawkins(:,9); XW = hawkins(:,1:8);", nargout = 0)
  fsda$eval("rng(1234); outLXS = LXS(yW, XW, 'nsamp', 1000, 'msg', 0);", nargout = 0)
  fsda$eval("outEDA = FSReda(yW, XW, outLXS.bs);", nargout = 0)
  fsda$eval("resfwdplot(outEDA);", nargout = 0)
  RES_C = fsda$eval("outEDA.RES")      # pull back just the numbers
  cat("Same RES as step 2:", isTRUE(all.equal(RES_C, eda$RES)), "\n")
})

fsda$eval("drawnow", nargout = 0)
readline("Look at the MATLAB figures, then press Enter to close MATLAB... ")
fsda$close()
