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

    #' @description MM-estimator of regression (FSDA `MMreg`). Note that `MMreg`
    #'   has no `msg` option and errors on unknown options; use `Smsg` to
    #'   silence the initial S estimator.
    #' @param y Response, n x 1 matrix.
    #' @param X Predictors, n x p matrix (without the column of ones).
    #' @param intercept Include a constant term. FSDA default: `TRUE`.
    #' @param InitialEst Starting values (a list with `beta` and `scale`).
    #'   FSDA default: empty, meaning an S estimator is computed first.
    #' @param eff Nominal efficiency, between 0.5 and 0.99. FSDA default: 0.95.
    #' @param effshape 1 = efficiency refers to shape, otherwise to location.
    #'   FSDA default: 0.
    #' @param rhofunc Rho function: `"bisquare"`, `"optimal"`, `"hyperbolic"`,
    #'   `"hampel"`, `"mdpd"` or `"AS"`. FSDA default: `"bisquare"`.
    #' @param rhofuncparam Extra parameters for `rhofunc`.
    #' @param refsteps Maximum number of iterations. FSDA default: 100.
    #' @param tol Convergence tolerance. FSDA default: 1e-7.
    #' @param conflev Confidence level to declare outliers. FSDA default: 0.975.
    #' @param plots 1 = robust residuals against index number. FSDA default: 0.
    #' @param nocheck Skip the checks on `y` and `X`. FSDA default: `FALSE`.
    #' @param yxsave Save `y` and `X` in the output. FSDA default: 0.
    #' @param Smsg Messages from the initial S estimator. FSDA default: `TRUE`.
    #' @param Snsamp Subsamples for the S estimator. FSDA default: `min(1000, choose(n, p))`.
    #' @param Srefsteps Refining steps per subsample. FSDA default: 3.
    #' @param Sbestr Number of best solutions refined further. FSDA default: 5.
    #' @param Sreftol Tolerance of the refining steps. FSDA default: 1e-6.
    #' @param Sminsctol Tolerance for the scale iterations. FSDA default: 1e-7.
    #' @param Srefstepsbestr Refining steps for the best solutions. FSDA default: 50.
    #' @param Sreftolbestr Tolerance for the best solutions. FSDA default: 1e-8.
    #' @param Sbdp Breakdown point of the S estimator. FSDA default: 0.5.
    #' @param Srhofunc Rho function of the S estimator. FSDA default: `"bisquare"`.
    #' @param Srhofuncparam Extra parameters for `Srhofunc`.
    #' @return FSDA's `out` structure, as a named list.
    MMreg = function(y, X, intercept = NULL, InitialEst = NULL, eff = NULL,
                     effshape = NULL, rhofunc = NULL, rhofuncparam = NULL,
                     refsteps = NULL, tol = NULL, conflev = NULL, plots = NULL,
                     nocheck = NULL, yxsave = NULL, Smsg = NULL, Snsamp = NULL,
                     Srefsteps = NULL, Sbestr = NULL, Sreftol = NULL,
                     Sminsctol = NULL, Srefstepsbestr = NULL, Sreftolbestr = NULL,
                     Sbdp = NULL, Srhofunc = NULL, Srhofuncparam = NULL) {
      self$call("MMreg", y, X, intercept = intercept, InitialEst = InitialEst,
                eff = eff, effshape = effshape, rhofunc = rhofunc,
                rhofuncparam = rhofuncparam, refsteps = refsteps, tol = tol,
                conflev = conflev, plots = plots, nocheck = nocheck,
                yxsave = yxsave, Smsg = Smsg, Snsamp = Snsamp,
                Srefsteps = Srefsteps, Sbestr = Sbestr, Sreftol = Sreftol,
                Sminsctol = Sminsctol, Srefstepsbestr = Srefstepsbestr,
                Sreftolbestr = Sreftolbestr, Sbdp = Sbdp, Srhofunc = Srhofunc,
                Srhofuncparam = Srhofuncparam)
    },

    #' @description Forward search for exploratory data analysis in regression
    #'   (FSDA `FSReda`). Usually started from a robust subset, e.g. `LXS(...)$bs`.
    #' @param y Response, n x 1 matrix.
    #' @param X Predictors, n x p matrix (without the column of ones).
    #' @param bsb Units forming the initial subset; 0 = p units chosen at random.
    #' @param intercept Include a constant term. FSDA default: `TRUE`.
    #' @param init Step where monitoring starts.
    #'   FSDA default: `p + 1` if n < 40, else `min(3 * p + 1, floor(0.5 * (n + p + 1)))`.
    #' @param tstat `"scal"` = rescaled t statistics, `"trad"` = traditional ones.
    #'   FSDA default: `"scal"`.
    #' @param nocheck Skip the checks on `y` and `X`. FSDA default: `FALSE`.
    #' @param conflev Confidence levels for the intervals of beta and sigma^2.
    #'   FSDA default: `c(0.95, 0.99)`.
    #' @param wREML Compute REML weights for the units outside the subset.
    #'   FSDA default: `FALSE`.
    #' @return FSDA's `out` structure, as a named list (`RES` holds the
    #'   residuals monitored at each step; this is what `resfwdplot` draws).
    FSReda = function(y, X, bsb, intercept = NULL, init = NULL, tstat = NULL,
                      nocheck = NULL, conflev = NULL, wREML = NULL) {
      self$call("FSReda", y, X, bsb, intercept = intercept, init = init,
                tstat = tstat, nocheck = nocheck, conflev = conflev,
                wREML = wREML)
    },

    #' @description Plot of the monitoring of residuals along the search
    #'   (FSDA `resfwdplot`). Produces a MATLAB figure and returns nothing.
    #' @param out Output of `FSReda` (only `RES` is strictly needed; `Un` too
    #'   when `datatooltip` is on).
    #' @param standard,fground,bground Lists controlling the appearance of all
    #'   trajectories, highlighted ones and background ones.
    #' @param datatooltip Interactive clicking on the plot. FSDA default: 1.
    #' @param label Row labels for the units.
    #' @param databrush Interactive brushing. FSDA default: empty.
    #' @param nameX Labels of the predictors.
    #' @param namey Label of the response.
    #' @param msg Display the options used.
    #' @param corres `TRUE` gives a 3-panel plot with the correlation of
    #'   residuals. FSDA default: `FALSE`.
    #' @param movieLength Length of the movie in seconds. FSDA default: 0.
    #' @param tag Plot tag. FSDA default: `"pl_resfwd"`.
    #' @return Invisibly `NULL`.
    resfwdplot = function(out, standard = NULL, fground = NULL, bground = NULL,
                          datatooltip = NULL, label = NULL, databrush = NULL,
                          nameX = NULL, namey = NULL, msg = NULL, corres = NULL,
                          movieLength = NULL, tag = NULL) {
      # nargout = 0: the plot is the result; resfwdplot's own output (plot
      # options) is not worth marshalling back.
      self$call("resfwdplot", out, standard = standard, fground = fground,
                bground = bground, datatooltip = datatooltip, label = label,
                databrush = databrush, nameX = nameX, namey = namey, msg = msg,
                corres = corres, movieLength = movieLength, tag = tag,
                nargout = 0)
      invisible(NULL)
    },

    #' @description Evaluate a MATLAB expression in this session's workspace.
    #'   Lets results stay inside MATLAB, e.g. to chain routines without
    #'   sending a structure back and forth.
    #' @param expr MATLAB expression, as a string.
    #' @param nargout 0 for a statement with no result (assignments, plots).
    eval = function(expr, nargout = 1) {
      eval_m(private$h, expr, nargout = nargout)
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
