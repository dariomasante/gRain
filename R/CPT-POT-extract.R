#' @title Extract conditional probabilities and clique potentials from
#'     data.
#' 
#' @description Extract list of conditional probability tables and
#'     list of clique potentials from data.
#'
#' @name extract-cpt
#' 
#' @details If \code{smooth} is non--zero then \code{smooth} is added
#'     to all cell counts before normalization takes place.
#' 
#' @aliases extractCPT extractCPT.table extractCPT.data.frame
#'     extractPOT extractPOT.table extractPOT.data.frame
#' @param data_ A named array or a dataframe.
#' @param graph A graphNEL object or a list or formula which can be
#'     turned into a graphNEL object by calling \code{ug} or
#'     \code{dag}. For extractCPT, graph must be/define a DAG while for
#'     extractPOT, graph must be/define undirected triangulated graph.
#' @param smooth See 'details' below.
#' @return extractCPT: A list of conditional probability tables
#'     extractPOT: A list of clique potentials.
#' @author Søren Højsgaard, \email{sorenh@@math.aau.dk}
#' @seealso \code{\link{compileCPT}}, \code{\link{compilePOT}},
#'     \code{\link{grain}}
#' @references Søren Højsgaard (2012). Graphical Independence Networks
#'     with the gRain Package for R. Journal of Statistical Software,
#'     46(10), 1-26.  \url{http://www.jstatsoft.org/v46/i10/}.
#' @keywords utilities
#' @examples
#' 
#' 
#' ## Asia (chest clinic) example:
#' 
#' ## Version 1) Specify conditional probability tables.
#' yn <- c("yes","no")
#' a    <- cptable(~asia, values=c(1,99), levels=yn)
#' t.a  <- cptable(~tub+asia, values=c(5,95,1,99), levels=yn)
#' s    <- cptable(~smoke, values=c(5,5), levels=yn)
#' l.s  <- cptable(~lung+smoke, values=c(1,9,1,99), levels=yn)
#' b.s  <- cptable(~bronc+smoke, values=c(6,4,3,7), levels=yn)
#' e.lt <- cptable(~either+lung+tub,values=c(1,0,1,0,1,0,0,1), levels=yn)
#' x.e  <- cptable(~xray+either, values=c(98,2,5,95), levels=yn)
#' d.be <- cptable(~dysp+bronc+either, values=c(9,1,7,3,8,2,1,9), levels=yn)
#' plist <- compileCPT(list(a, t.a, s, l.s, b.s, e.lt, x.e, d.be))
#' pn1 <- grain(plist)
#' q1 <- querygrain(pn1)
#' 
#' ## Version 2) Specify DAG and data
#' data(chestSim100000, package="gRbase")
#' dgf   <- ~asia + tub * asia + smoke + lung * smoke +
#'          bronc * smoke + either * tub * lung +
#'          xray * either + dysp * bronc * either
#' dg    <- dag(dgf)
#' pp    <- extractCPT(chestSim100000, dg)
#'
#' pn2   <- grain(pp)
#' ## Same as:
#' cpp2  <- compileCPT(pp)
#' pn2   <- grain(cpp2)
#' 
#' q2    <- querygrain(pn2)
#' 
#' ## Version 2) Specify triangulated undirected graph and data
#' ugf <- list(c("either", "lung", "tub"), c("either", "lung", "bronc"), 
#'     c("either", "xray"), c("either", "dysp", "bronc"), c("smoke", 
#'     "lung", "bronc"), c("asia", "tub"))
#' gg    <- ug(ugf)
#' pp    <- extractPOT(chestSim100000, gg)
#'
#' pn3   <- grain(pp)
#' ## Same as:
#' cpp3  <- compilePOT(pp)
#' pn3   <- grain(cpp3)
#'
#' q3    <- querygrain(pn3)
#' 
#' ## Compare results:
#' str(q1)
#' str(q2[names(q1)])
#' str(q3[names(q1)])
#' 
#' @rdname extract-cpt

extractCPT <- function(data_, graph, smooth=0){

    .extractCPT_ <- function(data_, vpa, smooth=0){
        
        is.df <- is.data.frame(data_)
        
        out <- lapply(vpa, function(ss){.dataMarg(data_, ss, is.df)})
        
        ## FIXME : Get rid of this parray stuff (at least as a class)
        ## NOTE: Normalization takes place here
        out <- lapply(out, as.parray, normalize="first", smooth=smooth)
        
        chk <- unlist(lapply(out, function(zz) any(is.na(zz))))
        nnn <- names(chk)[which(chk)]
        if (length(nnn) > 0){
            cat(sprintf("NAs found in conditional probability table(s) for nodes: %s\n",
                        toString(nnn)))
            cat(sprintf("  ... consider using the smooth argument\n"))
        }
        out
    }
    

    .is.valid.data(data_)

    if (inherits(graph, c("formula", "list")))
        graph <- dag(graph)

    if (!is.DAG(graph)) stop("'graph' not a DAG")

    vpa <- vpar(graph)
    out <- .extractCPT_(data_, vpa=vpa, smooth=smooth)
    ##FIXME: Should any info be stored in the output? vpa for example?
    class(out) <- "cpt_rep"
    out
}

.is.valid.data <- function(data_){
    if ( !(is.data.frame(data_) || is.named.array(data_)) )
        stop("'data_' must be dataframe or array.")
}






#' @rdname extract-cpt
extractPOT <- function(data_, graph, smooth=0){

    .extractPOT_primitive <- function(data_, cliq, seps=NULL, smooth=0){        
        
        .normalize <- function(tt, sp){
            if (length(sp) > 0) tabDiv0(tt, tabMarg(tt, sp))
            else tt / sum(tt)        
        }
        
        out <- vector("list", length(cliq))
        is.df <- is.data.frame(data_)
        for ( i  in seq_along(cliq)){
            cq   <- cliq[[ i ]]
            sp   <- seps[[ i ]]
            t.cq <- .dataMarg(data_, cq, is.df) + smooth       
            ##str(list(cq=cq, sp=sp))
            out[[i]] <- .normalize(t.cq, sp)
        }
        out
    }
    
    .is.valid.data(data_)

    if (inherits(graph, c("formula", "list")))
        graph <- ug(graph)
    
    if (!is.TUG(graph)) stop("'graph' not undirected and triangulated")
    rip_  <- rip( graph )
    
    out <- .extractPOT_primitive(data_, rip_$cliques, rip_$sep, smooth=smooth)
    attr(out, "rip")     <- rip_
    class(out) <- "pot_rep"
    out
}



#' @rdname extract-cpt
extractMARG <- function(data_, graph, smooth=0){

    .extractMARG_primitive <- function(data_, cliq, seps=NULL, smooth=0){        
        out <- vector("list", length(cliq))
        is.df <- is.data.frame(data_)
        
        for (i in seq_along(cliq)){
            cq   <- cliq[[ i ]]
            t.cq <- .dataMarg(data_, cq, is.df) + smooth       
            out[[i]] <- t.cq / sum(t.cq)
        }
        out
    }

    .is.valid.data(data_)
    if (!is.TUG(graph))
        stop("'graph' not undirected and triangulated")
    
    rip_  <- rip(graph)

    out <- .extractMARG_primitive(data_, rip_$cliques, rip_$sep, smooth=smooth)
    attr(out, "rip")     <- rip_      
    class(out) <- "marg_rep"
    out
}


#' @rdname extract-cpt
data2cpt <- extractCPT

#' @rdname extract-cpt
data2pot <- extractPOT

#' @rdname extract-cpt
data2marg <- extractMARG



#' @rdname extract-cpt
#' @param mg An object of class \code{marg_rep}
marg2pot <- function(mg){
    if (!inherits(mg, "marg_rep")) stop("'mg' not a marg_rep object\n")
    rip_ <- attr(mg, "rip")
    seps <- rip_$separators
    pt <- lapply(seq_along(rip_$cliques),
                 function(i){
                     if (length(seps[[i]]) == 0)
                         mg[[i]]
                     else
                         tabDiv0(mg[[i]], tabMarg(mg[[i]], seps[[i]]))               
                 })
    attr(pt, "rip") <- rip_
    class(pt) <- "pot_rep"
    pt
}

#' @rdname extract-cpt
#' @param pt An object of class \code{pot_rep}
pot2marg <- function(pt){
    if (!inherits(pt, "pot_rep")) stop("'pt' not a pot_rep object\n")    
    mg <- pt
    rip_ <- attr(pt, "rip")
    seps <- rip_$separators
    par  <- rip_$parents
    
    for (i in 2:length(rip_$cliques)){
        if (par[i] > 0){
            mg[[i]] <- tabMult(mg[[i]], tabMarg(mg[[par[i]]], seps[[i]]))
        }
    }
    class(mg) <- "MARG_rep"
    mg
}






## helper function; can possibly be made faster
.dataMarg <- function(data_, cq, is.df=NULL){

    ## .dfMarg can possibly be made faster
    .dfMarg <- function(data_, cq){
        xtabs(~., data=data_[ , cq, drop=FALSE])
    }

    if (is.null(is.df))
        is.df <- is.data.frame(data_)

    if (is.df) .dfMarg(data_, cq)
    else tabMarg(data_, cq)
        
}












