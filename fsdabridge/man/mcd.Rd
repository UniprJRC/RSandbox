% Generated for the R6 wrapper phase 1.
\name{mcd}
\alias{mcd}
\title{Minimum Covariance Determinant estimator (FSDA \code{mcd})}
\description{Called as \code{fsda$mcd(...)} on an \link{FSDA} object. Returns the raw MCD structure.}
\usage{NULL}
\arguments{
\item{Y}{Data matrix, n x v.}
\item{bdp}{Breakdown point.}
\item{bestr}{Number of best solutions retained.}
\item{betathresh}{Use the Beta/Rocke outlier threshold.}
\item{conflev}{Confidence level for outlier detection.}
\item{conflevrew}{Confidence level for reweighting.}
\item{msg}{Display timing messages.}
\item{nocheck}{Skip input checks.}
\item{nsamp}{Number of subsamples.}
\item{refsteps}{Refining iterations.}
\item{refstepsbestr}{Refining iterations for best solutions.}
\item{reftol}{Refining tolerance.}
\item{reftolbestr}{Refining tolerance for best solutions.}
\item{restrfactor}{Restriction factor.}
\item{smallsamplecor}{Apply the small-sample correction.}
\item{modelT}{Student-t model degrees of freedom.}
\item{tolMCD}{MCD tolerance.}
\item{ysaveRAW}{Save Y in the raw output.}
\item{ysaveREW}{Save Y in the reweighted output.}
\item{plots}{Plot control.}
}
\value{FSDA raw MCD structure as a named list.}
