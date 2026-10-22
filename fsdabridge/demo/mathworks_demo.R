# Live demo for the MathWorks meeting: LXS -> FSReda -> resfwdplot, run
# through the FSDA R6 class, on FSDA's own "Houses Price Dataset"
# (regression/hprice.txt, as used in FSRBbsb.m's/FSRBeda.m's own help
# examples: y = price, X = lot size, bedrooms, bathrooms, stories).
#
# Run from inside fsdabridge/ (line by line in an R session for the live talk,
# or as a whole with Rscript to check it still runs clean beforehand):
#   FSDA_DEV_VENV=/path/to/venv/bin/python FSDA_ROOT=/path/to/FSDA/toolbox Rscript demo/mathworks_demo.R
# FSDA_ROOT defaults to this machine's local FSDA install if not set.
# FSDA_DEV_VENV has no machine-specific default (see engine.R) -- it must be
# set to a Python executable with 'matlabengine' installed, e.g. on this
# machine: /Users/melarepubblica/Documents/FSDA-bridge/.venv/bin/python3.12
# Needs the 'pkgload' package (installed with devtools; install.packages("pkgload") alone also works).
#
# Locates the package by this file's own path, not the working directory --
# load_all(".") would otherwise fail if sourced from the RStudio project
# root (RSandbox/) instead of fsdabridge/.
this_file = function() {
  frame = Filter(function(f) !is.null(f$ofile), sys.frames())
  if (length(frame) > 0) return(normalizePath(frame[[length(frame)]]$ofile))
  file_arg = grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  normalizePath(sub("^--file=", "", file_arg))
}

pkgload::load_all(dirname(dirname(this_file())))

fsda_root = path.expand(Sys.getenv(
  "FSDA_ROOT",
  unset = "~/Documents/MATLAB/DSwithMATLAB/FSDA/toolbox"
))

fsda = FSDA$new(fsda_root = fsda_root)

data = as.matrix(read.table(
  file.path(fsda_root, "datasets", "regression", "hprice.txt")
))
y = data[, 1]
X = data[, 2:5]
colnames(X) = c("lot_size", "bedrooms", "bathrooms", "stories")
cat("Loaded hprice: ", nrow(X), "houses,", ncol(X), "predictors.\n")
cat("First rows:\n")
print(head(cbind(price = y, X)))

out  = fsda$LXS(y, X, nsamp = 1000, plots = 0, msg = 0)
cat("LXS done, initial subset size:", length(out$bs), "\n")

out1 = fsda$FSReda(y, X, out$bs)
cat("FSReda done, steps monitored:", ncol(out1$RES), "\n")

fsda$resfwdplot(out1)
cat("resfwdplot drawn -- window should now show the actual trajectories.\n")

cat("Waiting for the MATLAB plot window to be closed by hand...\n")
fsda$wait_for_plot()

# Only safe to close the session once wait_for_plot() has returned above --
# stop_engine()/fsda$close() tears down the figure along with MATLAB itself.
fsda$close()
cat("closed.\n")