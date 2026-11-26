% Generated for the R6 wrapper phase 1.
\name{Smult}
\alias{Smult}
\title{Multivariate S estimator (FSDA \code{Smult})}
\description{Called as \code{fsda$Smult(...)} on an \link{FSDA} object.}
\usage{NULL}
\arguments{
\item{Y}{Data matrix, n x v.}
\item{bdp}{Breakdown point.}
\item{nsamp}{Number of elemental subsets.}
\item{refsteps}{Refining iterations.}
\item{reftol}{Refining tolerance.}
\item{refstepsbestr}{Refining iterations for best subsets.}
\item{reftolbestr}{Tolerance for best subsets.}
\item{minsctol}{Minimum-scale iteration tolerance.}
\item{bestr}{Number of best solutions retained.}
\item{conflev}{Confidence level for outlier detection.}
\item{nocheck}{Skip input checks.}
\item{plots}{Plot control.}
\item{msg}{Display timing messages.}
\item{ysave}{Save Y in the output.}
}
\value{FSDA S-estimator structure as a named list.}
