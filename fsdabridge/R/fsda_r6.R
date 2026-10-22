# One method per FSDA function; every option is a NULL-default argument
# forwarded with self$call() (call() drops any NULL before it reaches MATLAB).
# Exception: a REQUIRED positional argument that merely has a documented
# default value (e.g. FSReda's `bsb`, default 0) must keep that real value as
# its R default, not NULL -- MATLAB errors if it's never passed at all.

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

    #' @description Evaluate a raw MATLAB expression (e.g. `load('<dataset>.txt')`
    #'   to load one of FSDA's own datasets the way our other language bridges do).
    #' @param expr A MATLAB expression as a string.
    #' @param nargout Number of outputs to request. Default 1.
    eval_m = function(expr, nargout = 1) {
      eval_m(private$h, expr, nargout = nargout)
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

    #' @description Monitor several quantities at each step of the forward
    #'   search (FSDA `FSReda`).
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

    #' @description Forward search in linear regression for outlier detection
    #'   (FSDA `FSR`).
    #' @param y Response, n x 1 matrix.
    #' @param X Predictors, n x p matrix (without the column of ones).
    #' @param h Number of observations that determine the LTS/LMS estimator used
    #'   to start the search. FSDA default: `floor(0.5 * (n + p + 1))`.
    #' @param nsamp Number of subsamples for the initial robust fit; 0 = all
    #'   subsets. FSDA default: all subsets if fewer than 1000, otherwise 1000.
    #' @param lms Initialisation: 1 = LMS, 2 = LTS with concentration steps,
    #'   other scalar = LTS without; a vector of unit numbers starts the search
    #'   from those units. FSDA default: 1.
    #' @param plots 1 = minimum deletion residual plot with envelopes plus the
    #'   yX plot with outliers highlighted; 2 = also the intermediate envelope
    #'   plots; 0 = no plots. FSDA default: 1.
    #' @param init Step where monitoring of exceedances starts.
    #'   FSDA default: `p + 1` if n < 40, else `min(3 * p + 1, floor(0.5 * (n + p + 1)))`.
    #' @param labeladd `"1"` adds outlier labels to the yX plot. FSDA default: `""`.
    #' @param bivarfit Superimpose bivariate least squares lines on the yX plot
    #'   (`"1"`, `"2"`, `"i1"`, ...). FSDA default: `""`.
    #' @param multivarfit Superimpose multivariate least squares lines on the
    #'   yX plot (`"1"` or `"2"`). FSDA default: `""`.
    #' @param xlim Two-element vector for the x axis of the mdr plot.
    #' @param ylim Two-element vector for the y axis of the mdr plot.
    #' @param nameX Character vector of labels for the predictors.
    #' @param namey Label for the response.
    #' @param msg Print the step where the signal took place. FSDA default: `TRUE`.
    #' @param nocheck Skip the checks on `y` and `X`. FSDA default: `FALSE`.
    #' @param intercept Include a constant term. FSDA default: `TRUE`.
    #' @param bonflev Bonferroni-based stopping rule for strongly non-normal data
    #'   (e.g. 0.99). FSDA default: empty (consecutive-exceedance rule).
    #' @param bsbmfullrank If a subset gives a singular X, force those units to
    #'   enter at the end of the search. FSDA default: `TRUE`.
    #' @param threshoutX Bound the effect of high-leverage units; 1 switches it on.
    #'   FSDA default: empty.
    #' @param weak Use the 'weak' decision rule to flag outliers. FSDA default: `FALSE`.
    #' @param tag Tags for the plots created.
    #' @return FSDA's `out` structure, as a named list (`ListOut` holds the
    #'   outliers, `mdr` the minimum deletion residual monitoring).
    FSR = function(y, X, h = NULL, nsamp = NULL, lms = NULL, plots = NULL,
                   init = NULL, labeladd = NULL, bivarfit = NULL,
                   multivarfit = NULL, xlim = NULL, ylim = NULL, nameX = NULL,
                   namey = NULL, msg = NULL, nocheck = NULL, intercept = NULL,
                   bonflev = NULL, bsbmfullrank = NULL, threshoutX = NULL,
                   weak = NULL, tag = NULL) {
      self$call("FSR", y, X, h = h, nsamp = nsamp, lms = lms, plots = plots,
                init = init, labeladd = labeladd, bivarfit = bivarfit,
                multivarfit = multivarfit, xlim = xlim, ylim = ylim,
                nameX = nameX, namey = namey, msg = msg, nocheck = nocheck,
                intercept = intercept, bonflev = bonflev,
                bsbmfullrank = bsbmfullrank, threshoutX = threshoutX,
                weak = weak, tag = tag)
    },

    #' @description Plot of the monitoring of residuals along the search
    #'   (FSDA `resfwdplot`). Produces a MATLAB figure and returns nothing.
    #' @param out Output of `FSReda` (only `RES` is strictly needed; `Un` too
    #'   when `datatooltip` is on).
    #' @param datatooltip Interactive clicking on the plot. FSDA default: 1.
    #' @param label Row labels for the units.
    #' @param nameX Labels of the predictors.
    #' @param namey Label of the response.
    #' @param msg Display the options used.
    #' @param tag Plot tag. FSDA default: `"pl_resfwd"`.
    #' @return Invisibly `NULL`.
    resfwdplot = function(out, datatooltip = NULL, label = NULL, nameX = NULL,
                          namey = NULL, msg = NULL, tag = NULL) {
      # nargout = 0: the plot is the result; resfwdplot's own output (plot
      # options) is not worth marshalling back.
      self$call("resfwdplot", out, datatooltip = datatooltip, label = label,
                nameX = nameX, namey = namey, msg = msg, tag = tag,
                nargout = 0)
      # The engine doesn't auto-flush MATLAB's graphics queue, so without
      # this the figure window opens but stays blank until something else
      # happens to trigger a drawnow.
      render_figures(private$h)
      invisible(NULL)
    },

    #' @description Block until every open MATLAB figure window is closed by
    #'   hand. Useful right after `resfwdplot()` so the plot stays up long
    #'   enough to look at, instead of risking `close()` tearing it down.
    wait_for_plot = function() {
      wait_for_figures(private$h)
      invisible(self)
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
