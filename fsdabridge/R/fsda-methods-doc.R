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
