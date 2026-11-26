% Generated for the R6 wrapper phase 1.
\name{MMmult}
\alias{MMmult}
\title{Multivariate MM estimator (FSDA \code{MMmult})}
\description{Called as \code{fsda$MMmult(...)} on an \link{FSDA} object.}
\usage{NULL}
\arguments{
\item{Y}{Data matrix, n x v.}
\item{InitialEst}{Optional initial estimator structure.}
\item{Snsamp}{Number of subsets for the initial S estimator.}
\item{Sbdp}{Breakdown point for the initial S estimator.}
\item{Sbestr}{Number of best initial S solutions.}
\item{Sminsctol}{Initial S minimum-scale tolerance.}
\item{Smsg}{Initial S messages.}
\item{Srefsteps}{Initial S refining iterations.}
\item{Srefstepsbestr}{Initial S best-subset refining iterations.}
\item{Sreftol}{Initial S refining tolerance.}
\item{Sreftolbestr}{Initial S best-subset tolerance.}
\item{Srhofunc}{Initial S rho function.}
\item{eff}{Target efficiency.}
\item{effshape}{Efficiency for the shape estimate.}
\item{refsteps}{MM refining iterations.}
\item{tol}{Convergence tolerance.}
\item{conflev}{Confidence level.}
\item{plots}{Plot control.}
\item{nocheck}{Skip input checks.}
\item{ysave}{Save Y in the output.}
}
\value{FSDA MM-estimator structure as a named list.}
