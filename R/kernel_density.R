#' 2d kernel density estimation for raster data
#'
#' @param data.points SpatialPointsDataFrame object
#' @param y RasterLayer object to use as a template for the output of the
#' kernel density estimator, optional.
#' @param xcells number of grid cells in x dimension of output raster
#' @param ycells number of grid cells in y dimension of output raster
#' @return RasterLayer with KDE
#' @export
kernel_density2d <- function(data.points, y = NULL, xcells = NULL, ycells = NULL) {
  
  # get the coordinates
  coords <- sp::coordinates(data.points)
  
  # bandwidth selection
  selected.xbandwidth <- KernSmooth::dpik(coords[, 1])
  selected.ybandwidth <- KernSmooth::dpik(coords[, 2])
  
  # get dimensions to perform the estimation over from raster if supplied
  if (!is.null(y)) {
    ext <- raster::extent(y)
    xcells <- raster::ncol(y)
    ycells <- raster::nrow(y)
    
    # get dimensions to perform the estimation over from bbox of data.points
  } else {
    ext <- sp::bbox(data.points)
    
    if (is.null(xcells) | is.null(ycells)) {
      stop("Need to supply xcells and ycells if a raster object is not supplied")
    }
  }
  
  xmin <- ext[1, 1]
  xmax <- ext[1, 2]
  ymin <- ext[2, 1]
  ymax <- ext[2, 2]
  
  # compute the 2D binned kernel density estimate
  est <- KernSmooth::bkde2D(
    coords,
    bandwidth = c(selected.xbandwidth, selected.ybandwidth),
    gridsize = c(xcells, ycells),
    range.x = list(
      c(xmin, xmax),
      c(ymin, ymax)
    )
  )
  
  # create raster
  est.raster <- raster::raster(
    list(
      x = est$x1,
      y = est$x2,
      z = est$fhat
    )
  )
  raster::projection(est.raster) <- sp::CRS(data.points)
  
  return(est.raster)
}