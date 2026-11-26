# Standalone help pages for each FSDA$<method>, so `?LXS` (etc.) works
# without the `FSDA$` prefix. @usage NULL because the real call is
# `fsda$LXS(...)`, not a bare `LXS(...)` function -- there is nothing for
# roxygen2 to generate a usage line from, and the true signature is already
# documented on `?FSDA`.

#' Least Median / Least Trimmed Squares regression (FSDA `LXS`)
#'
#' Called as `fsda$LXS(...)` on an [FSDA] object; documented here separately
#' so `?LXS` also finds it. See `?FSDA` for the full argument list.
#'
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
#' @param bonflevoutX Bonferroni level to exclude remote units in the X space
#'   from the subsets. FSDA default: empty (no check).
#' @param SmallSampleCor Small sample correction for the reweighting step (0-4).
#'   FSDA default: 0.
#' @return FSDA's `out` structure, as a named list.
#' @name LXS
#' @usage NULL
NULL

#' Monitor several quantities at each step of the forward search (FSDA `FSReda`)
#'
#' Called as `fsda$FSReda(...)` on an [FSDA] object; documented here
#' separately so `?FSReda` also finds it. See `?FSDA` for the full argument
#' list.
#'
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
#' @name FSReda
#' @usage NULL
NULL

#' Forward search in linear regression for outlier detection (FSDA `FSR`)
#'
#' Called as `fsda$FSR(...)` on an [FSDA] object; documented here separately
#' so `?FSR` also finds it. See `?FSDA` for the full argument list.
#'
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
#' @name FSR
#' @usage NULL
NULL

#' Plot of the monitoring of residuals along the search (FSDA `resfwdplot`)
#'
#' Called as `fsda$resfwdplot(...)` on an [FSDA] object; documented here
#' separately so `?resfwdplot` also finds it. See `?FSDA` for the full
#' argument list. Produces a MATLAB figure and returns nothing.
#'
#' @param out Output of `FSReda` (only `RES` is strictly needed; `Un` too
#'   when `datatooltip` is on).
#' @param datatooltip Interactive clicking on the plot. FSDA default: 1.
#' @param label Row labels for the units.
#' @param nameX Labels of the predictors.
#' @param namey Label of the response.
#' @param msg Display the options used.
#' @param tag Plot tag. FSDA default: `"pl_resfwd"`.
#' @return Invisibly `NULL`.
#' @name resfwdplot
#' @usage NULL
NULL

#' Plot of the minimum deletion residual along the search (FSDA `mdrplot`)
#'
#' Called as `fsda$mdrplot(...)` on an [FSDA] object; documented here
#' separately so `?mdrplot` also finds it. See `?FSDA` for the full
#' argument list. Produces a MATLAB figure and returns nothing.
#'
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
#' @name mdrplot
#' @usage NULL
NULL

#' Plot of the trajectories of leverage along the search (FSDA `levfwdplot`)
#'
#' Called as `fsda$levfwdplot(...)` on an [FSDA] object; documented here
#' separately so `?levfwdplot` also finds it. See `?FSDA` for the full
#' argument list. Produces a MATLAB figure and returns nothing.
#'
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
#' @name levfwdplot
#' @usage NULL
NULL

#' Plot of regression residuals against index number (FSDA `resindexplot`)
#'
#' Called as `fsda$resindexplot(...)` on an [FSDA] object; documented here
#' separately so `?resindexplot` also finds it. See `?FSDA` for the full
#' argument list. Produces a MATLAB figure and returns nothing.
#'
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
#' @name resindexplot
#' @usage NULL
NULL

#' Scatterplot matrix with histograms or boxplots on the diagonal (FSDA `spmplot`)
#'
#' Called as `fsda$spmplot(...)` on an [FSDA] object; documented here
#' separately so `?spmplot` also finds it. See `?FSDA` for the full
#' argument list. Produces a MATLAB figure and returns nothing.
#'
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
#' @name spmplot
#' @usage NULL
NULL

#' Minimum Covariance Determinant estimator (FSDA `mcd`)
#'
#' Called as `fsda$mcd(...)` on an [FSDA] object. Returns the raw MCD estimate;
#' use the MATLAB function directly through `fsda$call()` when additional
#' MATLAB output arguments are required.
#'
#' @param Y Data matrix, n x v.
#' @param bdp Breakdown point.
#' @param bestr Number of best solutions retained.
#' @param betathresh Use the Beta/Rocke outlier threshold.
#' @param conflev Confidence level for outlier detection.
#' @param conflevrew Confidence level for reweighting.
#' @param msg Display timing messages.
#' @param nocheck Skip input checks.
#' @param nsamp Number of subsamples.
#' @param refsteps Refining iterations.
#' @param refstepsbestr Refining iterations for best solutions.
#' @param reftol Refining tolerance.
#' @param reftolbestr Refining tolerance for best solutions.
#' @param restrfactor Restriction factor.
#' @param smallsamplecor Apply the small-sample correction.
#' @param modelT Student-t model degrees of freedom.
#' @param tolMCD MCD tolerance.
#' @param ysaveRAW Save Y in the raw output.
#' @param ysaveREW Save Y in the reweighted output.
#' @param plots Plot control.
#' @return FSDA's RAW MCD structure as a named list.
#' @name mcd
#' @usage NULL
NULL

#' Forward search for multivariate outlier detection (FSDA `FSM`)
#'
#' Called as `fsda$FSM(...)` on an [FSDA] object.
#'
#' @param Y Data matrix, n x v.
#' @param bonflev Bonferroni threshold.
#' @param crit Signal detection criterion.
#' @param init Initial subset size / monitoring start.
#' @param m0 Initial subset size.
#' @param msg Display progress messages.
#' @param nocheck Skip input checks.
#' @param rf Resuperimposition factor.
#' @param plots Plot control.
#' @return FSDA's FSM result structure as a named list.
#' @name FSM
#' @usage NULL
NULL

#' Forward search in multivariate analysis for exploratory analysis (FSDA `FSMeda`)
#'
#' Called as `fsda$FSMeda(...)` on an [FSDA] object.
#'
#' @param Y Data matrix, n x v.
#' @param bsb Initial subset indices; 0 requests a random start.
#' @param init Search initialization step.
#' @param plots Plot control.
#' @param msg Display progress messages.
#' @param scaled Use scaled Mahalanobis distances.
#' @param nocheck Skip input checks.
#' @return FSDA's FSMeda monitoring structure as a named list.
#' @name FSMeda
#' @usage NULL
NULL

#' Multivariate S estimator of location and scatter (FSDA `Smult`)
#'
#' Called as `fsda$Smult(...)` on an [FSDA] object.
#'
#' @param Y Data matrix, n x v.
#' @param bdp Breakdown point.
#' @param nsamp Number of elemental subsets.
#' @param refsteps Refining iterations.
#' @param reftol Refining tolerance.
#' @param refstepsbestr Refining iterations for best subsets.
#' @param reftolbestr Tolerance for best subsets.
#' @param minsctol Minimum-scale iteration tolerance.
#' @param bestr Number of best solutions retained.
#' @param conflev Confidence level for outlier detection.
#' @param nocheck Skip input checks.
#' @param plots Plot control.
#' @param msg Display timing messages.
#' @param ysave Save Y in the output.
#' @return FSDA's S-estimator structure as a named list.
#' @name Smult
#' @usage NULL
NULL

#' Multivariate MM estimator using an auxiliary S-scale (FSDA `MMmult`)
#'
#' Called as `fsda$MMmult(...)` on an [FSDA] object.
#'
#' @param Y Data matrix, n x v.
#' @param InitialEst Optional initial estimator structure.
#' @param Snsamp Number of subsets for the initial S estimator.
#' @param Sbdp Breakdown point for the initial S estimator.
#' @param Sbestr Number of best initial S solutions.
#' @param Sminsctol Initial S minimum-scale tolerance.
#' @param Smsg Initial S messages.
#' @param Srefsteps Initial S refining iterations.
#' @param Srefstepsbestr Initial S best-subset refining iterations.
#' @param Sreftol Initial S refining tolerance.
#' @param Sreftolbestr Initial S best-subset tolerance.
#' @param Srhofunc Initial S rho function.
#' @param eff Target efficiency.
#' @param effshape Efficiency for the shape estimate.
#' @param refsteps MM refining iterations.
#' @param tol Convergence tolerance.
#' @param conflev Confidence level.
#' @param plots Plot control.
#' @param nocheck Skip input checks.
#' @param ysave Save Y in the output.
#' @return FSDA's MM-estimator structure as a named list.
#' @name MMmult
#' @usage NULL
NULL

#' Minimum Volume Ellipsoid estimator (FSDA `mve`)
#'
#' Called as `fsda$mve(...)` on an [FSDA] object. Returns the raw MVE estimate.
#'
#' @param Y Data matrix, n x v.
#' @param bdp Breakdown point.
#' @param nsamp Number of elemental subsets.
#' @param refsteps Refining iterations.
#' @param reftol Refining tolerance.
#' @param conflev Confidence level for outlier detection.
#' @param nocheck Skip input checks.
#' @param plots Plot control.
#' @param msg Display timing messages.
#' @param ysaveRAW Save Y in the raw output.
#' @param ysaveREW Save Y in the reweighted output.
#' @return FSDA's RAW MVE structure as a named list.
#' @name mve
#' @usage NULL
NULL

#' Principal Component Analysis on raw data (FSDA `pcaFS`)
#'
#' Called as `fsda$pcaFS(...)` on an [FSDA] object.
#'
#' @param Y Data matrix, n x p.
#' @param biplot Launch the interactive biplot application.
#' @param dispresults Display numerical results.
#' @param Latitude Latitude values for observations.
#' @param Longitude Longitude values for observations.
#' @param NumComponents Number of components to retain.
#' @param plots Plot control.
#' @param robust Use robust PCA.
#' @param ShapeFile Polygon shapefile for geographical data.
#' @param smartEVchart Use the smart explained-variance chart.
#' @param standardize Standardize variables before PCA.
#' @param bsb Initial subset for robust PCA.
#' @param bdp Breakdown point for robust PCA.
#' @return FSDA's PCA result structure as a named list.
#' @name pcaFS
#' @usage NULL
NULL

#' Monitor minimum Mahalanobis distances in the multivariate forward search (FSDA `FSMmmd`)
#'
#' Called as `fsda$FSMmmd(...)` on an [FSDA] object. Returns the monitoring
#' matrix for minimum Mahalanobis distance; optional additional MATLAB outputs
#' can be requested with `fsda$call()`.
#'
#' @param Y Data matrix, n x v.
#' @param bsb Initial subset indices; 0 requests a random start.
#' @param bsbsteps Steps at which to save subset membership.
#' @param init Step where monitoring starts.
#' @param msg Display progress messages.
#' @param nocheck Skip input checks.
#' @param plots Plot control.
#' @return Matrix with the forward-search index and minimum Mahalanobis distance.
#' @name FSMmmd
#' @usage NULL
NULL
