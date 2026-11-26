% Generated for the R6 wrapper phase 1.
\name{mve}
\alias{mve}
\title{Minimum Volume Ellipsoid estimator (FSDA \code{mve})}
\description{Called as \code{fsda$mve(...)} on an \link{FSDA} object. Returns the raw MVE structure.}
\usage{NULL}
\arguments{
\item{Y}{Data matrix, n x v.}
\item{bdp}{Breakdown point.}
\item{nsamp}{Number of elemental subsets.}
\item{refsteps}{Refining iterations.}
\item{reftol}{Refining tolerance.}
\item{conflev}{Confidence level for outlier detection.}
\item{nocheck}{Skip input checks.}
\item{plots}{Plot control.}
\item{msg}{Display timing messages.}
\item{ysaveRAW}{Save Y in the raw output.}
\item{ysaveREW}{Save Y in the reweighted output.}
}
\value{FSDA raw MVE structure as a named list.}
