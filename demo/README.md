# Demo: robust regression with the FSDA R6 class

`r6_robust_regression.R` runs LXS, FSR and MMreg on the Hawkins data, then the
LXS → FSReda → resfwdplot pipeline, and prints PASS or FAIL for each step.

## Requirements

- MATLAB with the FSDA Add-On
- A Python venv with `matlabengine` matching your MATLAB release
- R with `devtools`, `R6` and `reticulate`

## How to run

1. Get the branch:

   ```bash
   git fetch origin
   git checkout sv/no-defaults
   ```

2. Start R from the repository root and run:

   ```r
   Sys.setenv(FSDA_DEV_VENV = "<path to your venv>/bin/python")
   devtools::document("fsdabridge")
   source("demo/r6_robust_regression.R")
   ```

   MATLAB takes about 30 seconds to start. At the end the script waits for
   Enter so you can look at the figures, then closes MATLAB.

## Expected output

- `[LXS]`, `[FSR]`, `[MMreg]` PASS, each flagging 42 outliers
- `[chain LXS -> FSReda]` PASS (RES is 128 x 101)
- `[A: resfwdplot(full FSReda list)]` PASS: FSReda's output goes back to MATLAB as an R list
- `[B: resfwdplot(list(RES = ...))]` FAIL: expected, because resfwdplot also reads `out.class`
- `[C: workspace route]` PASS, with the same RES as the chain step

## How optional arguments work

Methods declare their FSDA options without default values. They still
autocomplete in RStudio (type `fsda$LXS(y, X, ` and press Tab), but only the
options you actually type are sent to MATLAB, so FSDA applies its own defaults
to everything else. Required inputs (for example FSReda's `bsb`) are checked in
R and give a clear error if missing.

## Known issue on macOS

If you get `No module named 'numpy'` although your venv has it, `engine.R`
resolves the venv's `bin/python` symlink to the base interpreter. Local
workaround: in `fsdabridge/R/engine.R`, replace
`normalizePath(python, winslash = "/", mustWork = FALSE)` with
`path.expand(python)`. This is not committed, since `engine.R` is shared code.
