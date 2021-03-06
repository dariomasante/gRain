% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/CPT-POT-compile.R
\name{compile_potentials}
\alias{compile_potentials}
\alias{compile_cpt}
\alias{compileCPT}
\alias{summary.cpt_spec}
\alias{compilePOT}
\alias{print.cpt_spec}
\alias{compile_pot}
\alias{parse_cpt}
\alias{parse_cpt.cptable_class}
\alias{parse_cpt.xtabs}
\alias{parse_cpt.default}
\alias{compile.pot_rep}
\alias{compile.cpt_rep}
\title{Compile conditional probability tables / cliques potentials.}
\usage{
compile_cpt(x, forceCheck = TRUE)

compile_pot(x)

compileCPT(x, forceCheck = TRUE)

compilePOT(x)

parse_cpt(xi)

\method{parse_cpt}{cptable_class}(xi)

\method{parse_cpt}{xtabs}(xi)

\method{parse_cpt}{default}(xi)

\method{compile}{pot_rep}(object, ...)

\method{compile}{cpt_rep}(object, ...)
}
\arguments{
\item{x}{To \code{compileCPT} x is a list of conditional
probability tables; to \code{compilePOT}, x is a list of clique
potentials.}

\item{forceCheck}{Controls if consistency checks of the probability
tables should be made.}

\item{xi}{Conditional probability table}

\item{object}{A list of potentials or of CPTs.}

\item{...}{Additional arguments; currently not used.}
}
\value{
\code{compileCPT} returns a list of class 'cptspec'
    \code{compilePOT} returns a list of class 'potspec'
}
\description{
Compile conditional probability tables / cliques
    potentials as a preprocessing step for creating a graphical
    independence network
}
\references{
Søren Højsgaard (2012). Graphical Independence Networks
    with the gRain Package for R. Journal of Statistical Software,
    46(10), 1-26.  \url{http://www.jstatsoft.org/v46/i10/}.
}
\seealso{
\code{\link{extractCPT}}, \code{\link{extractPOT}}
}
\author{
Søren Højsgaard, \email{sorenh@math.aau.dk}
}
\keyword{utilities}
