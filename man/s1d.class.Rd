\name{s1d.class}
\alias{s1d.class}

\title{1-D plot of a numeric score partitioned in classes (levels of a factor)}


\description{
  This function represents the link between scores values and their matching labeled classes.
}

\usage{
s1d.class(score, fac, wt = rep(1, NROW(fac)), labels = levels(fac), at = 0.5, 
  poslabel = c("regular", "value"), col = NULL, facets = NULL, plot = TRUE, 
  storeData = TRUE, add = FALSE, pos = -1, ...)
}

\arguments{
  \item{score}{a numeric vector (or a data frame) used to produce the plot}
  
  \item{fac}{a factor (or a matrix of factors) to split \code{score}}
  
  \item{wt}{a vector of weights for \code{score}}
  
  \item{labels}{the labels' names drawn for each class}
  
  \item{at}{a numeric vector used as an index}
  
  \item{poslabel}{the label position of each class (each level of \code{fac}), it can be \code{regular} or \code{value}. 
    If \code{regular}, labels are evenly spaced. 
    If \code{value}, labels are placed on the weighted mean of their class.}
  
  \item{col}{a color or a colors vector for points, labels and lines according to their factor level. 
    Colors are recycled whether there are not one color by factor level.}
  
  \item{facets}{a factor splitting \code{score} so that subsets
    of the data are represented on different sub-graphics}
    
  \item{plot}{a logical indicating if the graphics is displayed}
  
  \item{storeData}{a logical indicating if the data are stored in
    the returned object. If \code{FALSE}, only the names of the data
    arguments are stored}
    
  \item{add}{a logical. If \code{TRUE}, the graphic is superposed to the graphics
    already plotted in the current device}
    
  \item{pos}{an integer indicating the position of the
    environment where the data are stored, relative to the environment
    where the function is called. Useful only if 
    \code{storeData} is \code{FALSE}}
    
  \item{\dots}{additional graphical parameters (see
    \code{\link{adegpar}} and \code{\link[lattice]{trellis.par.get}})}
}

\details{
  The weighted means of class are available in the object slot \code{stats} using \code{object@stats$means}.
  Graphical parameters for rugs are available in \code{plines} of \code{adegpar}.
  Some appropriated graphical parameters in \code{p1d} are also available.
}

\value{
  An object of class \code{ADEg} (subclass \code{S1.class}) or \code{ADEgS} (if \code{add} is \code{TRUE} and/or 
  if facets or data frame for \code{score} or data frame for \code{fac} are used).\cr
  The result is displayed if \code{plot} is \code{TRUE}.
}

\author{Alice Julien-Laferriere, Aurelie Siberchicot \email{aurelie.siberchicot@univ-lyon1.fr} and Stephane Dray
}

\seealso{
  \code{\linkS4class{S1.class}}
  \code{\linkS4class{ADEg.S1}}
}

\examples{
data(meau, package = "ade4")
envpca <- ade4::dudi.pca(meau$env, scannf = FALSE)

g1 <- s1d.class(envpca$li[, 1], meau$design$season, poslabel = "value", col = 1:4, plot = FALSE)
g2 <- s1d.class(envpca$li[, 1], meau$design$season, poslabel = "regular", col = 1:6, 
  p1d.reverse = TRUE, plot = FALSE)
ADEgS(c(g1, g2), layout = c(2, 1))

g3 <- s1d.class(envpca$li[, 1], meau$design$season, poslabel = "value", col = 1:4, 
  plabels.cex = 0, key = list(space = "bottom"))
}

\keyword{aplot}
\keyword{hplot}
