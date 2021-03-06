% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/grain-setcpt.R
\name{cpt-update}
\alias{cpt-update}
\alias{setcpt<-}
\alias{setcpt<-.grain}
\alias{setCPT}
\alias{setCPT.grain}
\title{Update components of Bayesian network}
\usage{
setcpt(object) <- value

\method{setcpt}{grain}(object) <- value

setCPT(object, value)

\method{setCPT}{grain}(object, value)
}
\arguments{
\item{object}{A grain object}

\item{value}{A named list}
}
\description{
Update components of Bayesian network.
}
\examples{

yn   <- c("yes","no")
a    <- cptable(~asia,        values=c(1,99), levels=yn)
t.a  <- cptable(~tub + asia,  values=c(5,95,1,99), levels=yn)

plist <- compileCPT(list(a, t.a )) 
bn    <- grain(plist)
bnc   <- compile(bn, propagate=FALSE)
bncp  <- compile(bn, propagate=TRUE)

## New p(tub | asia)
z <- c(20, 80, 1, 99) 

bn2   <- setCPT(bn, list(tub=z))
bnc2   <- setCPT(bnc, list(tub=z))
bncp2   <- setCPT(bncp, list(tub=z))

}
\references{
Søren Højsgaard (2012). Graphical Independence
    Networks with the gRain Package for R. Journal of Statistical
    Software, 46(10), 1-26.
    \url{http://www.jstatsoft.org/v46/i10/}.
}
\seealso{
\code{\link{grain}}, \code{\link[gRbase]{propagate}},
    \code{\link[gRbase]{triangulate}}, \code{\link[gRbase]{rip}},
    \code{\link[gRbase]{junctionTree}}
}
\author{
Søren Højsgaard, \email{sorenh@math.aau.dk}
}
\keyword{models}
\keyword{utilities}
