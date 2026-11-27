# One method per FSDA function; every option is a NULL-default argument
# forwarded with self$call() (call() drops any NULL option before it reaches
# MATLAB, and stops on a NULL positional input).
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
    #' @param ... Positional inputs, then name = value options. `NULL` options are
    #'   not sent; a `NULL` positional input is an error.
    call = function(name, ...) {
      args = list(...)
      nm = names(args)
      if (is.null(nm)) nm = rep("", length(args))
      is_null = vapply(args, is.null, logical(1))
      # Dropping a NULL positional would shift every later argument one slot left in MATLAB.
      bad = which(is_null & nm == "")
      if (length(bad) > 0) {
        stop(sprintf(
          "%s: NULL passed as positional argument %s. A positional input cannot be skipped; pass its actual value.",
          name, paste(bad, collapse = ", ")
        ), call. = FALSE)
      }
      # handle and name are passed by name: positionally, R would match an option `h` to `handle`
      do.call(fsda_call, c(list(handle = private$h, name = name), args[!is_null]))
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

    #' @description Plot of the minimum deletion residual along the search,
    #'   with envelopes (FSDA `mdrplot`). Produces a MATLAB figure.
    #' @param out Output of `FSReda`.
    #' @param quant Quantiles for which envelopes are drawn.
    #' @param sign 1 = mdr with sign.
    #' @param mplus1 1 = also plot the (m+1)th order statistic.
    #' @param envm Sample size used to draw the envelopes.
    #' @param ncoord `TRUE` if `out$mdr` is in normal coordinates.
    #' @param xlimx Two-element vector, min and max of the x axis.
    #' @param ylimy Two-element vector, min and max of the y axis.
    #' @param lwd Line width of the curve.
    #' @param lwdenv Line width of the envelopes.
    #' @param FontSize Size of the axes labels.
    #' @param SizeAxesNum Size of the axes numbers.
    #' @param tag Plot tag. FSDA default: `"pl_mdr"`.
    #' @param datatooltip Interactive clicking on the plot.
    #' @param databrush Interactive mouse brushing.
    #' @param titl Main title.
    #' @param labx Label of the x axis.
    #' @param laby Label of the y axis.
    #' @param nameX Labels of the predictors.
    #' @param namey Label of the response.
    #' @param label Row labels for the units.
    #' @return Invisibly `NULL`.
    mdrplot = function(out, quant = NULL, sign = NULL, mplus1 = NULL,
                       envm = NULL, ncoord = NULL, xlimx = NULL, ylimy = NULL,
                       lwd = NULL, lwdenv = NULL, FontSize = NULL,
                       SizeAxesNum = NULL, tag = NULL, datatooltip = NULL,
                       databrush = NULL, titl = NULL, labx = NULL, laby = NULL,
                       nameX = NULL, namey = NULL, label = NULL) {
      self$call("mdrplot", out, quant = quant, sign = sign, mplus1 = mplus1,
                envm = envm, ncoord = ncoord, xlimx = xlimx, ylimy = ylimy,
                lwd = lwd, lwdenv = lwdenv, FontSize = FontSize,
                SizeAxesNum = SizeAxesNum, tag = tag, datatooltip = datatooltip,
                databrush = databrush, titl = titl, labx = labx, laby = laby,
                nameX = nameX, namey = namey, label = label, nargout = 0)
      render_figures(private$h)
      invisible(NULL)
    },

    #' @description Plot of the trajectories of leverage along the search
    #'   (FSDA `levfwdplot`). Produces a MATLAB figure.
    #' @param out Output of `FSReda`.
    #' @param standard Structure controlling the appearance of the plot.
    #' @param fground Structure controlling the trajectories in foreground.
    #' @param bground Structure controlling the trajectories in background.
    #' @param xground Trajectories to highlight in connection with the x axis.
    #' @param tag Plot tag. FSDA default: `"pl_levfwd"`.
    #' @param datatooltip Interactive clicking on the plot. FSDA default: 1.
    #' @param label Row labels for the units.
    #' @param databrush Interactive mouse brushing.
    #' @param nameX Labels of the predictors.
    #' @param namey Label of the response.
    #' @param msg Display the options used.
    #' @return Invisibly `NULL`.
    levfwdplot = function(out, standard = NULL, fground = NULL, bground = NULL,
                          xground = NULL, tag = NULL, datatooltip = NULL,
                          label = NULL, databrush = NULL, nameX = NULL,
                          namey = NULL, msg = NULL) {
      self$call("levfwdplot", out, standard = standard, fground = fground,
                bground = bground, xground = xground, tag = tag,
                datatooltip = datatooltip, label = label, databrush = databrush,
                nameX = nameX, namey = namey, msg = msg, nargout = 0)
      render_figures(private$h)
      invisible(NULL)
    },

    #' @description Plot of regression residuals against index number, with
    #'   confidence bands (FSDA `resindexplot`). Produces a MATLAB figure.
    #' @param residuals Vector of residuals, or a fitted structure that
    #'   contains them (e.g. the output of `LXS` or `FSR`).
    #' @param h Axes handle where the plot is drawn.
    #' @param x Values for the x axis instead of the index number.
    #' @param labx Label of the x axis.
    #' @param laby Label of the y axis.
    #' @param numlab Number of points to identify in the plot.
    #' @param conflev Confidence level of the horizontal bands.
    #'   FSDA default: 0.975.
    #' @param title Title of the plot.
    #' @param FontSize Size of the axes labels.
    #' @param SizeAxesNum Size of the axes numbers.
    #' @param xlimx Two-element vector, min and max of the x axis.
    #' @param ylimy Two-element vector, min and max of the y axis.
    #' @param lwdenv Line width of the bands.
    #' @param MarkerSize Size of the markers, in points.
    #' @param MarkerFaceColor Fill colour of the markers.
    #' @param databrush Interactive mouse brushing.
    #' @param tag Plot tag. FSDA default: `"pl_resindex"`.
    #' @param nameX Labels of the predictors.
    #' @param namey Label of the response.
    #' @return Invisibly `NULL`.
    resindexplot = function(residuals, h = NULL, x = NULL, labx = NULL,
                            laby = NULL, numlab = NULL, conflev = NULL,
                            title = NULL, FontSize = NULL, SizeAxesNum = NULL,
                            xlimx = NULL, ylimy = NULL, lwdenv = NULL,
                            MarkerSize = NULL, MarkerFaceColor = NULL,
                            databrush = NULL, tag = NULL, nameX = NULL,
                            namey = NULL) {
      self$call("resindexplot", residuals, h = h, x = x, labx = labx,
                laby = laby, numlab = numlab, conflev = conflev, title = title,
                FontSize = FontSize, SizeAxesNum = SizeAxesNum, xlimx = xlimx,
                ylimy = ylimy, lwdenv = lwdenv, MarkerSize = MarkerSize,
                MarkerFaceColor = MarkerFaceColor, databrush = databrush,
                tag = tag, nameX = nameX, namey = namey, nargout = 0)
      render_figures(private$h)
      invisible(NULL)
    },

    #' @description Scatterplot matrix with histograms or boxplots on the main
    #'   diagonal (FSDA `spmplot`). Produces a MATLAB figure.
    #' @param Y Data matrix, n x v.
    #' @param group Grouping variable, vector with n elements.
    #' @param plo Names, labels, colours and marker types.
    #' @param subsize x axis control in `malfwdplot` (used when brushing).
    #' @param selstep Position of the labels of brushed units in `malfwdplot`.
    #' @param selunit Unit labelling.
    #' @param datatooltip Interactive clicking on the plot.
    #' @param nameY Names of the variables.
    #' @param nameYrot Angle, in degrees, of the variable labels.
    #' @param nameYlength Maximum length of the variable labels.
    #' @param dispopt What to put on the main diagonal: `"hist"` or `"box"`.
    #'   FSDA default: `"hist"`.
    #' @param databrush Interactive mouse brushing.
    #' @param tag Plot tag. FSDA default: `"pl_spm"`.
    #' @param overlay What to superimpose on the panels off the main diagonal.
    #' @param undock Panels to undock and show separately.
    #' @param colorBackground Colour the background of each scatter.
    #' @param typespm Type of scatterplot matrix. FSDA default: `"full"`.
    #' @param order Order of the variables in the matrix.
    #' @return Invisibly `NULL`.
    spmplot = function(Y, group = NULL, plo = NULL, subsize = NULL,
                       selstep = NULL, selunit = NULL, datatooltip = NULL,
                       nameY = NULL, nameYrot = NULL, nameYlength = NULL,
                       dispopt = NULL, databrush = NULL, tag = NULL,
                       overlay = NULL, undock = NULL, colorBackground = NULL,
                       typespm = NULL, order = NULL) {
      self$call("spmplot", Y, group = group, plo = plo, subsize = subsize,
                selstep = selstep, selunit = selunit, datatooltip = datatooltip,
                nameY = nameY, nameYrot = nameYrot, nameYlength = nameYlength,
                dispopt = dispopt, databrush = databrush, tag = tag,
                overlay = overlay, undock = undock,
                colorBackground = colorBackground, typespm = typespm,
                order = order, nargout = 0)
      render_figures(private$h)
      invisible(NULL)
    },

    #' @description MM estimator of regression (FSDA `MMreg`). `MMreg` has no `msg`
    #'   option and errors on unknown options; use `Smsg` to silence the initial
    #'   S estimator.
    #' @param y Response, vector with n elements.
    #' @param X Predictors, n x (p-1) matrix (without the column of ones).
    #' @param intercept Include a constant term. FSDA default: `TRUE`.
    #' @param InitialEst Starting values: a list with `beta` and `scale`. FSDA default:
    #'   empty, meaning an S estimator is computed first.
    #' @param eff Nominal efficiency, between 0.5 and 0.99. FSDA default: 0.95.
    #' @param effshape 1 = efficiency refers to shape, otherwise to location.
    #'   FSDA default: 0.
    #' @param rhofunc Rho function: `"bisquare"`, `"optimal"`, `"hyperbolic"`,
    #'   `"hampel"`, `"mdpd"` or `"AS"`. FSDA default: `"bisquare"`.
    #' @param rhofuncparam Extra parameters for `rhofunc`.
    #' @param refsteps Maximum iterations in the MM loop. FSDA default: 100.
    #' @param tol Tolerance of the MM loop. FSDA default: 1e-7.
    #' @param conflev Confidence level to declare outliers. FSDA default: 0.975.
    #' @param plots 1 = plot of robust residuals against index number. FSDA default: 0.
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
                     Sminsctol = NULL, Srefstepsbestr = NULL,
                     Sreftolbestr = NULL, Sbdp = NULL, Srhofunc = NULL,
                     Srhofuncparam = NULL) {
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

    #' @description S estimator of regression (FSDA `Sreg`).
    #' @param y Response, vector with n elements.
    #' @param X Predictors, n x (p-1) matrix (without the column of ones).
    #' @param intercept Include a constant term. FSDA default: `TRUE`.
    #' @param nsamp Number of subsamples; 0 = all subsets. FSDA default: all subsets
    #'   if fewer than 1000, otherwise 1000.
    #' @param bdp Breakdown point, greater than 0 and at most 0.5. FSDA default: 0.5.
    #' @param refsteps Refining iterations in each subsample. FSDA default: 3.
    #' @param reftol Tolerance of the refining steps. FSDA default: 1e-6.
    #' @param refstepsbestr Refining iterations for each of the best subsets.
    #'   FSDA default: 50.
    #' @param reftolbestr Tolerance of the refining steps for the best subsets.
    #'   FSDA default: 1e-8.
    #' @param minsctol Tolerance for finding the minimum of the scale. FSDA default: 1e-7.
    #' @param bestr Number of best betas remembered from the subsamples. FSDA default: 5.
    #' @param rhofunc Rho function: `"bisquare"`, `"optimal"`, `"hyperbolic"`,
    #'   `"hampel"`, `"mdpd"` or `"AS"`. FSDA default: `"bisquare"`.
    #' @param rhofuncparam Extra parameters for `rhofunc`.
    #' @param conflev Confidence level to declare outliers. FSDA default: 0.975.
    #' @param plots 1 = plot of robust residuals against index number. FSDA default: 0.
    #' @param nocheck Skip the checks on `y` and `X`. FSDA default: `FALSE`.
    #' @param msg Display messages on the estimated computing time. FSDA default: `TRUE`.
    #' @param yxsave Save `y` and `X` in the output. FSDA default: 0.
    #' @return FSDA's `out` structure, as a named list.
    Sreg = function(y, X, intercept = NULL, nsamp = NULL, bdp = NULL,
                    refsteps = NULL, reftol = NULL, refstepsbestr = NULL,
                    reftolbestr = NULL, minsctol = NULL, bestr = NULL,
                    rhofunc = NULL, rhofuncparam = NULL, conflev = NULL,
                    plots = NULL, nocheck = NULL, msg = NULL, yxsave = NULL) {
      self$call("Sreg", y, X, intercept = intercept, nsamp = nsamp, bdp = bdp,
                refsteps = refsteps, reftol = reftol,
                refstepsbestr = refstepsbestr, reftolbestr = reftolbestr,
                minsctol = minsctol, bestr = bestr, rhofunc = rhofunc,
                rhofuncparam = rhofuncparam, conflev = conflev, plots = plots,
                nocheck = nocheck, msg = msg, yxsave = yxsave)
    },

    #' @description Forward search monitoring of the deletion t statistics of each
    #'   predictor (FSDA `FSRaddt`).
    #' @param y Response, vector with n elements.
    #' @param X Predictors, n x (p-1) matrix (without the column of ones).
    #' @param intercept Include a constant term. FSDA default: `TRUE`.
    #' @param DataVars Columns of `X` for which deletion t statistics are computed.
    #'   FSDA default: empty, meaning all columns.
    #' @param h Number of observations that determine the LTS estimator used to start
    #'   the search.
    #' @param nsamp Number of subsamples for the initial robust fit; 0 = all subsets.
    #' @param lms Initialisation: 1 = LMS, otherwise LTS; or a vector of unit numbers
    #'   to start the search from. FSDA default: 1.
    #' @param init Subset size where monitoring starts.
    #' @param ilr Apply the ilr transformation to compositional data in `X`.
    #'   FSDA default: `FALSE`.
    #' @param plots 1 = plot of the deletion t statistics. FSDA default: 0.
    #' @param nameX Labels of the predictors, used in the plot.
    #' @param lwdenv Line width of the envelopes. FSDA default: 2.
    #' @param quant Confidence quantiles of the envelopes. FSDA default: `c(0.005, 0.995)`.
    #' @param lwdt Line width of the deletion t statistics. FSDA default: 2.
    #' @param titl Title of the plot.
    #' @param labx Label of the x axis. FSDA default: `"Subset size m"`.
    #' @param laby Label of the y axis. FSDA default: `"Deletion t statistics"`.
    #' @param FontSize Font size of the labels. FSDA default: 12.
    #' @param SizeAxesNum Size of the numbers on the axes. FSDA default: 10.
    #' @param xlimx Two-element vector, min and max of the x axis.
    #' @param ylimy Two-element vector, min and max of the y axis.
    #' @param nocheck Skip the checks on `y` and `X`. FSDA default: `FALSE`.
    #' @param msg Display messages about the subset size. FSDA default: `TRUE`.
    #' @return FSDA's `out` structure, as a named list (`Tdel` holds the deletion
    #'   t statistics at each step).
    FSRaddt = function(y, X, intercept = NULL, DataVars = NULL, h = NULL,
                       nsamp = NULL, lms = NULL, init = NULL, ilr = NULL,
                       plots = NULL, nameX = NULL, lwdenv = NULL, quant = NULL,
                       lwdt = NULL, titl = NULL, labx = NULL, laby = NULL,
                       FontSize = NULL, SizeAxesNum = NULL, xlimx = NULL,
                       ylimy = NULL, nocheck = NULL, msg = NULL) {
      self$call("FSRaddt", y, X, intercept = intercept, DataVars = DataVars,
                h = h, nsamp = nsamp, lms = lms, init = init, ilr = ilr,
                plots = plots, nameX = nameX, lwdenv = lwdenv, quant = quant,
                lwdt = lwdt, titl = titl, labx = labx, laby = laby,
                FontSize = FontSize, SizeAxesNum = SizeAxesNum, xlimx = xlimx,
                ylimy = ylimy, nocheck = nocheck, msg = msg)
    },

    #' @description Score test for the Box-Cox transformation of the response
    #'   (FSDA `Score`). `y` must be positive.
    #' @param y Response, vector with n elements.
    #' @param X Predictors, n x (p-1) matrix (without the column of ones).
    #' @param intercept Include a constant term. FSDA default: `TRUE`.
    #' @param la Values of the transformation parameter lambda to test.
    #'   FSDA default: `c(-1, -0.5, 0, 0.5, 1)`.
    #' @param Lik Also return the likelihood of the augmented model. FSDA default: `FALSE`.
    #' @param tukey1df Also compute Tukey's one degree of freedom test for
    #'   non-additivity. FSDA default: `FALSE`.
    #' @param nocheck Skip the checks on `y` and `X`. FSDA default: `FALSE`.
    #' @return FSDA's output structure, as a named list (`Score` holds the score
    #'   test for each value of `la`).
    Score = function(y, X, intercept = NULL, la = NULL, Lik = NULL,
                     tukey1df = NULL, nocheck = NULL) {
      self$call("Score", y, X, intercept = intercept, la = la, Lik = Lik,
                tukey1df = tukey1df, nocheck = nocheck)
    },

    #' @description Linear regression with a model for the variance (FSDA `regressH`).
    #' @param y Response, vector with n elements.
    #' @param X Predictors in the regression equation, n x (p-1) matrix
    #'   (without the column of ones).
    #' @param Z Predictors in the skedastic equation: an n x r matrix, or a vector
    #'   of column numbers of `X`.
    #' @param typeH Skedastic function. `"har"`: Harvey's form,
    #'   `exp(gamma0 + gamma' z)`. Anything else (FSDA's default): `sigma^2 (1 +
    #'   exp(gamma0 + gamma' z))`; FSDA's help calls it `"arc"`, its code `"art"`.
    #' @param intercept Include a constant term. FSDA default: `TRUE`.
    #' @param initialbeta Initial estimate of beta, vector of length p. FSDA default:
    #'   least squares.
    #' @param initialgamma Initial estimate of gamma, vector of length r + 1.
    #' @param maxiter Maximum number of iterations. `maxiter = 1` gives the two-step
    #'   (FGLS) estimator.
    #' @param tol Tolerance for convergence.
    #' @param msgiter Output to display: 0 = nothing, 1 = final estimates and tests,
    #'   more than 1 = also each iteration.
    #' @return FSDA's `out` structure, as a named list.
    regressH = function(y, X, Z, typeH = NULL, intercept = NULL,
                        initialbeta = NULL, initialgamma = NULL,
                        maxiter = NULL, tol = NULL, msgiter = NULL) {
      self$call("regressH", y, X, Z, typeH = typeH, intercept = intercept,
                initialbeta = initialbeta, initialgamma = initialgamma,
                maxiter = maxiter, tol = tol, msgiter = msgiter)
    },

    #' @description Bayesian linear regression with a conjugate normal-gamma prior
    #'   (FSDA `regressB`).
    #' @param y Response, vector with n1 elements.
    #' @param X Predictors, n1 x (p-1) matrix (without the column of ones).
    #' @param beta0 Prior mean of beta, a p x 1 matrix such as `matrix(0, p, 1)`
    #'   (a plain R vector reaches MATLAB as a row and `regressB` fails).
    #' @param R p x p positive definite matrix for the prior covariance of beta
    #'   (think of it as `X0' X0` from n0 earlier observations).
    #' @param tau0 Prior estimate of tau = 1 / sigma^2.
    #' @param n0 Number of earlier observations the prior is based on.
    #' @param intercept Include a constant term. FSDA default: `TRUE`.
    #' @param bsb Units used to compute the posterior. FSDA default: all units.
    #' @param c Scalar in (0, 1] that weighs the prior information on beta.
    #' @param stats 1 = also compute Bayesian p-values and HPD intervals.
    #'   FSDA default: 0.
    #' @param conflev Confidence levels of the HPD intervals (used if `stats = 1`).
    #'   FSDA default: `c(0.95, 0.99)`.
    #' @param nocheck Skip the checks on `y` and `X`. FSDA default: `FALSE`.
    #' @return FSDA's `out` structure, as a named list.
    regressB = function(y, X, beta0, R, tau0, n0, intercept = NULL, bsb = NULL,
                        c = NULL, stats = NULL, conflev = NULL, nocheck = NULL) {
      self$call("regressB", y, X, beta0, R, tau0, n0, intercept = intercept,
                bsb = bsb, c = c, stats = stats, conflev = conflev,
                nocheck = nocheck)
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
