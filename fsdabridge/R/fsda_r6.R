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

    #' @description Minimum Covariance Determinant estimator (FSDA `mcd`).
    #' @param Y Data matrix, n x v (observations in rows, variables in columns).
    #' @param bdp Breakdown point (default 0.5).
    #' @param bestr Number of best solutions retained (default 5).
    #' @param betathresh Use the mixture Beta/Rocke threshold instead of chi-squared.
    #' @param conflev Confidence level for outlier detection (default 0.975).
    #' @param conflevrew Confidence level for reweighting (defaults to `conflev`).
    #' @param msg Display timing messages.
    #' @param nocheck Skip input checks.
    #' @param nsamp Number of subsamples, 0 for all subsets.
    #' @param refsteps Refining iterations (default 3).
    #' @param refstepsbestr Refining iterations for best solutions (default 50).
    #' @param reftol Refining tolerance (default 1e-6).
    #' @param reftolbestr Refining tolerance for best solutions (default 1e-8).
    #' @param restrfactor Restriction factor (default Inf).
    #' @param smallsamplecor Apply the small-sample correction.
    #' @param modelT Student-t model degrees of freedom; 0 estimates them.
    #' @param tolMCD Tolerance for the MCD algorithm.
    #' @param ysaveRAW Save Y in the raw output.
    #' @param ysaveREW Save Y in the reweighted output.
    #' @param plots Plot control passed to FSDA.
    #' @return FSDA's RAW MCD structure as a named list.
    mcd = function(Y, bdp = NULL, bestr = NULL, betathresh = NULL,
                   conflev = NULL, conflevrew = NULL, msg = NULL,
                   nocheck = NULL, nsamp = NULL, refsteps = NULL,
                   refstepsbestr = NULL, reftol = NULL, reftolbestr = NULL,
                   restrfactor = NULL, smallsamplecor = NULL, modelT = NULL,
                   tolMCD = NULL, ysaveRAW = NULL, ysaveREW = NULL,
                   plots = NULL) {
      self$call("mcd", Y, bdp = bdp, bestr = bestr, betathresh = betathresh,
                conflev = conflev, conflevrew = conflevrew, msg = msg,
                nocheck = nocheck, nsamp = nsamp, refsteps = refsteps,
                refstepsbestr = refstepsbestr, reftol = reftol,
                reftolbestr = reftolbestr, restrfactor = restrfactor,
                smallsamplecor = smallsamplecor, modelT = modelT,
                tolMCD = tolMCD, ysaveRAW = ysaveRAW, ysaveREW = ysaveREW,
                plots = plots)
    },

    #' @description Forward search for multivariate outlier detection (FSDA `FSM`).
    #' @param Y Data matrix, n x v.
    #' @param bonflev Bonferroni threshold for the outlier signal.
    #' @param crit Criterion used by the signal detection procedure.
    #' @param init Initial subset size / monitoring start.
    #' @param m0 Initial subset size.
    #' @param msg Display progress messages.
    #' @param nocheck Skip input checks.
    #' @param rf Resuperimposition factor.
    #' @param plots Plot control (0 = no plots).
    #' @return FSDA's FSM result structure as a named list.
    FSM = function(Y, bonflev = NULL, crit = NULL, init = NULL, m0 = NULL,
                   msg = NULL, nocheck = NULL, rf = NULL, plots = NULL) {
      self$call("FSM", Y, bonflev = bonflev, crit = crit, init = init,
                m0 = m0, msg = msg, nocheck = nocheck, rf = rf, plots = plots)
    },

    #' @description Forward search in multivariate analysis for exploratory analysis (FSDA `FSMeda`).
    #' @param Y Data matrix, n x v.
    #' @param bsb Initial subset of row indices; 0 requests a random start.
    #' @param init Search initialization step.
    #' @param plots Plot control (0 = no plots).
    #' @param msg Display progress messages.
    #' @param scaled Use scaled Mahalanobis distances.
    #' @param nocheck Skip input checks.
    #' @return FSDA's FSMeda monitoring structure as a named list.
    FSMeda = function(Y, bsb = 0, init = NULL, plots = NULL, msg = NULL,
                      scaled = NULL, nocheck = NULL) {
      self$call("FSMeda", Y, bsb, init = init, plots = plots, msg = msg,
                scaled = scaled, nocheck = nocheck)
    },

    #' @description Multivariate S estimator of location and scatter (FSDA `Smult`).
    #' @param Y Data matrix, n x v.
    #' @param bdp Breakdown point (default 0.5).
    #' @param nsamp Number of elemental subsets; 0 uses all subsets.
    #' @param refsteps Refining iterations.
    #' @param reftol Refining tolerance.
    #' @param refstepsbestr Refining iterations for each best subset.
    #' @param reftolbestr Tolerance for refining best subsets.
    #' @param minsctol Tolerance for the minimum-scale iteration.
    #' @param bestr Number of best solutions retained.
    #' @param conflev Confidence level for outlier detection.
    #' @param nocheck Skip input checks.
    #' @param plots Plot control (0 = no plots).
    #' @param msg Display timing messages.
    #' @param ysave Save Y in the output structure.
    #' @return FSDA's S-estimator structure as a named list.
    Smult = function(Y, bdp = NULL, nsamp = NULL, refsteps = NULL,
                     reftol = NULL, refstepsbestr = NULL, reftolbestr = NULL,
                     minsctol = NULL, bestr = NULL, conflev = NULL,
                     nocheck = NULL, plots = NULL, msg = NULL, ysave = NULL) {
      self$call("Smult", Y, bdp = bdp, nsamp = nsamp, refsteps = refsteps,
                reftol = reftol, refstepsbestr = refstepsbestr,
                reftolbestr = reftolbestr, minsctol = minsctol,
                bestr = bestr, conflev = conflev, nocheck = nocheck,
                plots = plots, msg = msg, ysave = ysave)
    },

    #' @description Multivariate MM estimator using an auxiliary S-scale (FSDA `MMmult`).
    #' @param Y Data matrix, n x v.
    #' @param InitialEst Optional initial location, shape and scale structure.
    #' @param Snsamp Number of subsets for the initial S estimator.
    #' @param Sbdp Breakdown point for the initial S estimator.
    #' @param Sbestr Number of best initial S solutions.
    #' @param Sminsctol Tolerance for the initial S scale iteration.
    #' @param Smsg Display messages during the initial S estimator.
    #' @param Srefsteps Refining iterations for the initial S estimator.
    #' @param Sreftol Refining tolerance for the initial S estimator.
    #' @param Srefstepsbestr Refining iterations for best initial S solutions.
    #' @param Srhofunc Rho function used by the initial S estimator.
    #' @param Sreftolbestr Tolerance for best initial S solutions.
    #' @param eff Target efficiency.
    #' @param effshape Efficiency used for the shape estimate.
    #' @param refsteps Refining iterations for the MM estimator.
    #' @param tol Convergence tolerance.
    #' @param conflev Confidence level for outlier detection.
    #' @param plots Plot control (0 = no plots).
    #' @param nocheck Skip input checks.
    #' @param ysave Save Y in the output structure.
    #' @return FSDA's MM-estimator structure as a named list.
    MMmult = function(Y, InitialEst = NULL, Snsamp = NULL, Sbdp = NULL,
                      Sbestr = NULL, Sminsctol = NULL, Smsg = NULL,
                      Srefsteps = NULL, Srefstepsbestr = NULL,
                      Sreftol = NULL, Sreftolbestr = NULL, Srhofunc = NULL,
                      eff = NULL, effshape = NULL, refsteps = NULL,
                      tol = NULL, conflev = NULL, plots = NULL,
                      nocheck = NULL, ysave = NULL) {
      self$call("MMmult", Y, InitialEst = InitialEst, Snsamp = Snsamp,
                Sbdp = Sbdp, Sbestr = Sbestr, Sminsctol = Sminsctol,
                Smsg = Smsg, Srefsteps = Srefsteps,
                Srefstepsbestr = Srefstepsbestr, Sreftol = Sreftol,
                Sreftolbestr = Sreftolbestr, Srhofunc = Srhofunc,
                eff = eff, effshape = effshape, refsteps = refsteps,
                tol = tol, conflev = conflev, plots = plots,
                nocheck = nocheck, ysave = ysave)
    },

    #' @description Minimum Volume Ellipsoid estimator (FSDA `mve`).
    #' @param Y Data matrix, n x v.
    #' @param bdp Breakdown point (default 0.5).
    #' @param nsamp Number of elemental subsets (default 500).
    #' @param refsteps Refining iterations (default 3).
    #' @param reftol Refining tolerance (default 1e-6).
    #' @param conflev Confidence level for outlier detection (default 0.975).
    #' @param nocheck Skip input checks.
    #' @param plots Plot control (0 = no plots).
    #' @param msg Display timing messages.
    #' @param ysaveRAW Save Y in the raw output.
    #' @param ysaveREW Save Y in the reweighted output.
    #' @return FSDA's RAW MVE structure as a named list.
    mve = function(Y, bdp = NULL, nsamp = NULL, refsteps = NULL,
                   reftol = NULL, conflev = NULL, nocheck = NULL,
                   plots = NULL, msg = NULL, ysaveRAW = NULL, ysaveREW = NULL) {
      self$call("mve", Y, bdp = bdp, nsamp = nsamp, refsteps = refsteps,
                reftol = reftol, conflev = conflev, nocheck = nocheck,
                plots = plots, msg = msg, ysaveRAW = ysaveRAW, ysaveREW = ysaveREW)
    },

    #' @description Principal Component Analysis on raw data (FSDA `pcaFS`).
    #' @param Y Data matrix, n x p.
    #' @param biplot Launch the interactive biplot application.
    #' @param dispresults Display numerical results.
    #' @param Latitude Latitude values for observations.
    #' @param Longitude Longitude values for observations.
    #' @param NumComponents Number of principal components to retain.
    #' @param plots Plot control.
    #' @param robust Use robust PCA.
    #' @param ShapeFile Polygon shapefile for geographical data.
    #' @param smartEVchart Use the smart explained-variance chart.
    #' @param standardize Standardize variables before PCA.
    #' @param bsb Initial subset for robust PCA.
    #' @param bdp Breakdown point for robust PCA.
    #' @return FSDA's PCA result structure as a named list.
    pcaFS = function(Y, biplot = NULL, dispresults = NULL, Latitude = NULL,
                     Longitude = NULL, NumComponents = NULL, plots = NULL,
                     robust = NULL, ShapeFile = NULL, smartEVchart = NULL,
                     standardize = NULL, bsb = NULL, bdp = NULL) {
      self$call("pcaFS", Y, biplot = biplot, dispresults = dispresults,
                Latitude = Latitude, Longitude = Longitude,
                NumComponents = NumComponents, plots = plots, robust = robust,
                ShapeFile = ShapeFile, smartEVchart = smartEVchart,
                standardize = standardize, bsb = bsb, bdp = bdp)
    },

    #' @description Monitor minimum Mahalanobis distances in the multivariate forward search (FSDA `FSMmmd`).
    #' @param Y Data matrix, n x v.
    #' @param bsb Initial subset indices; 0 requests a random start.
    #' @param bsbsteps Steps at which to save subset membership.
    #' @param init Step where monitoring starts.
    #' @param msg Display progress messages.
    #' @param nocheck Skip input checks.
    #' @param plots Plot control (0 = no plots).
    #' @return Matrix monitoring the minimum Mahalanobis distance at each step.
    FSMmmd = function(Y, bsb = 0, bsbsteps = NULL, init = NULL,
                      msg = NULL, nocheck = NULL, plots = NULL) {
      self$call("FSMmmd", Y, bsb, bsbsteps = bsbsteps, init = init,
                msg = msg, nocheck = nocheck, plots = plots)
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
