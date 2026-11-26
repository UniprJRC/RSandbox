% Generated for the R6 wrapper phase 1.
\name{FSMmmd}
\alias{FSMmmd}
\title{Minimum Mahalanobis-distance monitoring (FSDA \code{FSMmmd})}
\description{Called as \code{fsda$FSMmmd(...)} on an \link{FSDA} object.}
\usage{NULL}
\arguments{
\item{Y}{Data matrix, n x v.}
\item{bsb}{Initial subset indices; 0 requests a random start.}
\item{bsbsteps}{Steps at which to save subset membership.}
\item{init}{Step where monitoring starts.}
\item{msg}{Display progress messages.}
\item{nocheck}{Skip input checks.}
\item{plots}{Plot control.}
}
\value{Matrix with the forward-search index and minimum Mahalanobis distance.}
