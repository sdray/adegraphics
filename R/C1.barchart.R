setClass(
  Class = "C1.barchart",
  contains = "ADEg.C1"
)


setMethod(
  f = "initialize",
  signature = "C1.barchart",
  definition = function(.Object, data = list(score = NULL, labels = NULL, at = NULL, frame = 0, storeData = TRUE), ...) {
    .Object <- callNextMethod(.Object, data = data, ...) ## ADEg.C1 initialize
    .Object@data$labels <- data$labels
    .Object@data$at <- data$at
    validObject(.Object)
    return(.Object)
  })


setMethod(
  f = "prepare",
  signature = "C1.barchart",
  definition = function(object) {
    nameobj <- deparse(substitute(object))
    
    ## pre-management of graphics parameters
    oldparamadeg <- adegpar()
    on.exit(adegpar(oldparamadeg))
    adegtot <- adegpar(object@adeg.par)
    
    if(object@data$storeData) {
      score <- object@data$score
      at <- object@data$at
    } else {
      score <- eval(object@data$score, envir = sys.frame(object@data$frame))
      at <- eval(object@data$at, envir = sys.frame(object@data$frame))
    }
    score <- as.matrix(score)[, 1]  ## to manage 'score' when it is a data.frame with only one column
    
    ## change default for some parameters
    if(adegtot$p1d$horizontal && is.null(object@adeg.par$plabels$srt))
      adegtot$plabels$srt <- 0
    else if(!adegtot$p1d$horizontal && is.null(object@adeg.par$plabels$srt))
      adegtot$plabels$srt <- 90
    if(is.null(object@adeg.par$plabels$boxes$draw))
      adegtot$plabels$boxes$draw <- FALSE
    adegtot$p1d$rug$draw <- FALSE
    
    ## object modification before calling inherited method
    object@adeg.par <- adegtot
    callNextMethod() ## prepare graph
    
    if(object@adeg.par$p1d$horizontal && is.null(object@g.args$ylim))
      object@g.args$ylim <- setlimits1D(min(at), max(at), 0, FALSE)
    if(!object@adeg.par$p1d$horizontal && is.null(object@g.args$xlim))
      object@g.args$xlim <- setlimits1D(min(at), max(at), 0, FALSE)
    
    assign(nameobj, object, envir = parent.frame())
  })


setMethod(
  f = "panel",
  signature = "C1.barchart",
  definition = function(object, x, y) {
    ## Drawing barchart
    ## x is the index
    ## y is the score
   
    ## get some parameters    
    pscore <- object@adeg.par$p1d
    ppoly <- lapply(object@adeg.par$ppolygons, FUN = function(x) {rep(x, length.out = length(x))})
    plabels <- lapply(object@adeg.par$plabels, FUN = function(x) {rep(x, length.out = length(x))})
    
    if(object@data$storeData)
      labels <- object@data$labels
    else
      labels <- eval(object@data$labels, envir = sys.frame(object@data$frame))
        
    ## manage string rotation
    srt <- 0
    if(is.numeric(plabels$srt[1]))
      srt <- plabels$srt[1]
    else {
      if(plabels$srt[1] == "horizontal")
        srt <- 0
      else if(plabels$srt[1] == "vertical")
        srt <- 90
    }
     
    ## reorder values and labels
    y <- y[order(x)]
    labels <- labels[order(x)]
    x <- sort(x)
    
    ## Starts the display
    ## depends on the parametres horizontal
    ## reverse and rug.draw are always considered as FALSE
    if(pscore$horizontal) {
      x.tmp <- y
      y.tmp <- x
    } else {
      x.tmp <- x
      y.tmp <- y
    }
    
    panel.barchart(x = x.tmp, y = y.tmp, horizontal = pscore$horizontal, box.width = 0.9, origin = 0, reference = FALSE,
                   border = ppoly$border, col = ppoly$col, lty = ppoly$lty, lwd = ppoly$lwd, alpha = ppoly$alpha)
    ## panel.text(x.tmp, y.tmp, labels)
    if(!is.null(labels)) {
      if(abs(sin(srt)) > sin(45)) {
        ## almost vertical labels
        if(pscore$horizontal)
          width <- stringWidth("h")
        else
          width <- stringWidth(labels) + stringWidth("h")
        
        width <- rep(plabels$cex, length.out = length(labels)) * convertUnit(width, "native", typeFrom = "dimension", axisFrom = "x", axisTo = "y", valueOnly = TRUE) / 2 
      } else {
        ## almost horizont labels
        if(pscore$horizontal)
          width <- stringWidth(labels) + stringWidth("h")
        else
          width <- stringWidth("h")
        
        width <- rep(plabels$cex, length.out = length(labels)) * convertUnit(width, "native", typeFrom = "dimension", axisFrom = "x", valueOnly = TRUE) / 2 
      }
      
      if(pscore$horizontal)
        adeg.panel.label(x = x.tmp + width * sign(x.tmp), y = y.tmp, labels = labels, plabels = plabels)
      else
        adeg.panel.label(x = x.tmp, y = y.tmp + width * sign(y.tmp), labels = labels, plabels = plabels)
    }
  })


s1d.barchart <- function(score, labels = NULL, at = 1:NROW(score), sort = FALSE, facets = NULL, plot = TRUE, storeData = TRUE, add = FALSE, pos = -1, ...) {
  
  ## evaluation of some parameters
  thecall <- .expand.call(match.call())
  score <- eval(thecall$score, envir = sys.frame(sys.nframe() + pos))
  
  ## parameters sorted
  sortparameters <- sortparamADEg(...)
  
  ## facets
  if(!is.null(facets)) {
    if(NCOL(score) == 1)
      object <- multi.facets.C1(thecall, sortparameters$adepar, samelimits = sortparameters$g.args$samelimits)
    else 
      stop("Facets are not allowed with multiple scores")
  }
  
  ## multiple scores
  else if(NCOL(score) > 1) {
    object <- multi.score.C1(thecall)
  }
  
  ## simple ADEg graphic
  else {
    
    # if score is sorted
    if(sort)
      at <- rank(score)
    
    if(length(sortparameters$rest))
      warning(c("Unused parameters: ", paste(unique(names(sortparameters$rest)), " ", sep = "")), call. = FALSE)
    
    ## creation of the ADEg object
    g.args <- c(sortparameters$g.args, list(sort = sort))
    if(storeData)
    	tmp_data <- list(score = score, labels = labels, at = at, frame = sys.nframe() + pos, storeData = storeData)
    else
      tmp_data <- list(score = thecall$score, labels = thecall$labels, at = thecall$at, frame = sys.nframe() + pos, storeData = storeData)
    object <- new(Class = "C1.barchart", data = tmp_data, adeg.par = sortparameters$adepar, trellis.par = sortparameters$trellis, g.args = sortparameters$g.args, Call = match.call())
    
    ## preparation
    prepare(object) 
    setlatticecall(object)
    if(add)
      object <- add.ADEg(object)
  }
  if(!add & plot)
    print(object)
  invisible(object)  
}
