# Phase 1: how we work on the R6 wrapper

The R side is one R6 class, `FSDA`, on top of the shared engine (see `architecture.png`).
Our job: add one method for each FSDA function, with help page, live check and demo line.

## 1. Setup

You need MATLAB with FSDA, Python with the MATLAB Engine, and R with `reticulate`, `R6`, `pkgload`, `roxygen2`.

Set two environment variables (for example in `~/.Renviron`):

```
FSDA_ROOT=/path/to/FSDA          # the FSDA toolbox folder
FSDA_DEV_VENV=/path/to/python    # the Python that has the MATLAB Engine
```

Check that it works, from the repo root:

```r
pkgload::load_all("fsdabridge")
fsda = FSDA$new(fsda_root = Sys.getenv("FSDA_ROOT"))
fsda$eval_m("load('hprice.txt')", nargout = 0)
fsda$close()
```

## 2. Branches and pull requests

- One branch per person and track, for example `simran/regression`, `ahmad/multivariate`.
- One pull request per 2 to 3 functions. Small PRs are reviewed faster.
- Nour reviews. Do not push to `main`.

## 3. Adding one function (four steps)

Use `resindexplot` as the model: look at it in `fsdabridge/R/fsda_r6.R` and `fsdabridge/R/fsda-methods-doc.R`.

1. **Method.** Add it to `fsdabridge/R/fsda_r6.R`. Read the FSDA `.m` help first.
   - Required inputs are positional arguments; every option is a named argument with default `NULL`.
   - Forward with `self$call("name", required, option = option, ...)`.
   - Functions that only draw: pass `nargout = 0`, then call `render_figures(private$h)` and return `invisible(NULL)`.
   - Functions that return results: return the value of `self$call(...)`.
2. **Help page.** Add `#' @param` lines in the method, and a block in `fsdabridge/R/fsda-methods-doc.R` with `@name <function>` and `@usage NULL`. Then run `roxygen2::roxygenise("fsdabridge")`.
3. **Test.** Add one `test_that` block to `fsdabridge/tests/testthat/test-methods.R` (copy a block there). Two checks cover every function:
   - Function that returns results: `expect_matches_matlab(...)` runs the same call directly in MATLAB and checks that the R numbers agree (tolerance 1e-9). Use `rng(1)` before both calls if the function uses random subsamples.
   - Function that draws: `expect_plot_made(...)` checks that the call works and that a MATLAB figure opens.
   Also look at the plot yourself once, and check that `?<function>` shows the help.
   Run the tests (MATLAB needed; without `FSDA_LIVE` they are skipped, so they never fail on a machine without MATLAB):
   ```
   FSDA_LIVE=1 Rscript -e 'pkgload::load_all("fsdabridge"); testthat::test_dir("fsdabridge/tests/testthat")'
   ```
4. **Demo.** Add one line to a demo script in `fsdabridge/demo/`.

## 4. Tasks

Already done: `LXS`, `FSR`, `FSReda`, `resfwdplot`, `mdrplot`, `levfwdplot`, `resindexplot`, `spmplot`.

| Simran: `regression` | Ahmad: `multivariate` | Nour: `graphics` |
|---|---|---|
| `MMreg` | `mcd` | `yXplot` |
| `Sreg` | `FSM` | `malfwdplot` |
| `FSRmdr` | `FSMeda` | `malindexplot` |
| `FSRbsb` | `Smult` | `mmdplot` |
| `FSRaddt` | `MMmult` | `fanplot` |
| `regressH` | `mve` | `boxplotb` |
| `regressB` | `pcaFS` | `scatterboxplot` |
| `Score` | `FSMmmd` | `covplot` |

Some functions are harder than others. If one is stuck, say so early and we swap it.

## 5. Keep in mind

Tests and examples should not fail when MATLAB is not installed.
