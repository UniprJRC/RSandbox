# One method per FSDA function; every option is a NULL-default argument forwarded
# with self$call().

#' FSDA session
#'
#' One object = one MATLAB session with FSDA on its path.
#'
#' @export
FSDA = R6::R6Class("FSDA",
  public = list(
    #' @description Start MATLAB.
    #' @param fsda_root FSDA folder; only needed if FSDA is not installed as an Add-On.
    initialize = function(fsda_root = NULL) {
      private$h = start_engine(fsda_root = fsda_root)
    },

    #' @description Call any FSDA (or MATLAB) function by name.
    #' @param name Function name.
    #' @param ... Positional inputs, then name = value options; `NULL` options are not sent.
    call = function(name, ...) {
      # handle and name are passed by name: positionally, R would match an option `h` to `handle`
      args = Filter(Negate(is.null), list(...))
      do.call(fsda_call, c(list(handle = private$h, name = name), args))
    },

    #' @description Least Median / Least Trimmed Squares regression (FSDA `LXS`).
    #' @param y Response, n x 1 matrix.
    #' @param X Predictors, n x p matrix (without the column of ones).
    #' @param intercept Include a constant term. FSDA default: `TRUE`.
    #' @param nsamp Number of subsamples, or a matrix of subsets; 0 = all subsets.
    #'   FSDA default: `min(3000, choose(n, p))`.
    #' @param h Number of observations that determine the estimator.
    #'   FSDA default: `floor(0.5 * (n + p + 1))`.
    #' @param bdp Breakdown point. FSDA default: `1 - h / n`.
    #' @param lms 1 = LMS, 2 = fast LTS, other = LTS without concentration steps;
    #'   or a structure of LTS settings. FSDA default: 1.
    #' @param rew Return the reweighted estimator. FSDA default: `FALSE`.
    #' @param plots 1 = plot robust residuals against index number. FSDA default: 0.
    #' @param nocheck Skip the checks on `y` and `X`. FSDA default: `FALSE`.
    #' @param nomes Suppress the estimated-time message. FSDA default: `FALSE`.
    #' @param conflev Confidence level to declare outliers. FSDA default: 0.975.
    #' @param conflevrew Confidence level for the reweighting step.
    #'   FSDA default: `conflev`.
    #' @param msg Display messages. FSDA default: 1.
    #' @param yxsave Save `y` and `X` in the output. FSDA default: 0.
    #' @param bonflevoutX Bonferroni level to exclude remote units in the X space from
    #'   the subsets. FSDA default: empty (no check).
    #' @param SmallSampleCor Small sample correction for the reweighting step (0-4).
    #'   FSDA default: 0.
    #' @return FSDA's `out` structure, as a named list.
    LXS = function(y, X, intercept = NULL, nsamp = NULL, h = NULL, bdp = NULL,
                   lms = NULL, rew = NULL, plots = NULL, nocheck = NULL, nomes = NULL,
                   conflev = NULL, conflevrew = NULL, msg = NULL, yxsave = NULL,
                   bonflevoutX = NULL, SmallSampleCor = NULL) {
      self$call("LXS", y, X, intercept = intercept, nsamp = nsamp, h = h,
                bdp = bdp, lms = lms, rew = rew, plots = plots, nocheck = nocheck,
                nomes = nomes, conflev = conflev, conflevrew = conflevrew,
                msg = msg, yxsave = yxsave, bonflevoutX = bonflevoutX,
                SmallSampleCor = SmallSampleCor)
    },

    #' @description Forward Search on regression data, continued (FSDA `FSReda`).
    #' @param y Response, n x 1 matrix.
    #' @param X Predictors, n x p matrix (without the column of ones).
    #' @param bsb List of units forming the initial subset. Unlike the other
    #'   arguments, MATLAB requires this one to always be passed; `0` (the
    #'   default) means a random start of p units.
    #' @param conflev Confidence levels for the confidence intervals of beta
    #'   and sigma2. FSDA default: `c(0.95, 0.99)`.
    #' @param init Search initialization step. FSDA default: `p + 1` if
    #'   `n < 40`, else `min(3 * p + 1, floor(0.5 * (n + p + 1)))`.
    #' @param intercept Include a constant term. FSDA default: `TRUE`.
    #' @param nocheck Skip the checks on `y` and `X`. FSDA default: `FALSE`.
    #' @param tstat `'trad'` or `'scal'` (rescaled) t-statistics to monitor.
    #'   FSDA default: `'scal'`.
    #' @param wREML Compute REML weights for the units excluded at each step.
    #'   FSDA default: `FALSE`.
    #' @return FSDA's `out` structure, as a named list.
    FSReda = function(y, X, bsb = 0, conflev = NULL, init = NULL,
                       intercept = NULL, nocheck = NULL, tstat = NULL,
                       wREML = NULL) {
      self$call("FSReda", y, X, bsb, conflev = conflev, init = init,
                intercept = intercept, nocheck = nocheck, tstat = tstat,
                wREML = wREML)
    },

    #' @description Shut down the MATLAB session.
    close = function() {
      if (!is.null(private$h)) stop_engine(private$h)
      private$h = NULL
      invisible(self)
    }
  ),

  private = list(
    h = NULL,

    finalize = function() {
      self$close()
    }
  )
)
