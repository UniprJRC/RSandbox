% Generated for the R6 wrapper phase 1.
\name{pcaFS}
\alias{pcaFS}
\title{Principal Component Analysis on raw data (FSDA \code{pcaFS})}
\description{Called as \code{fsda$pcaFS(...)} on an \link{FSDA} object.}
\usage{NULL}
\arguments{
\item{Y}{Data matrix, n x p.}
\item{biplot}{Launch the interactive biplot application.}
\item{dispresults}{Display numerical results.}
\item{Latitude}{Latitude values for observations.}
\item{Longitude}{Longitude values for observations.}
\item{NumComponents}{Number of components to retain.}
\item{plots}{Plot control.}
\item{robust}{Use robust PCA.}
\item{ShapeFile}{Polygon shapefile for geographical data.}
\item{smartEVchart}{Use the smart explained-variance chart.}
\item{standardize}{Standardize variables before PCA.}
\item{bsb}{Initial subset for robust PCA.}
\item{bdp}{Breakdown point for robust PCA.}
}
\value{FSDA PCA result structure as a named list.}
