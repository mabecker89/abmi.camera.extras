#' Subset ABMI camera deployments by a specified spatial area of interest
#'
#' @param x The area of interest as an sf, sfc, or sp (SpatialPolygonsDataFrame) object
#' @param cols character; indicates which columns (attributes) from x to be appended to the deployments dataframe
#' @param keep.all logical; if TRUE all deployments are kept, otherwise only those within x are kept
#' @import sf
#' @export
#' @examples
#' library(sf)
#' # Example aoi of four Wildlife Management Units (WMUs) in Alberta:
#' wmu_sample <- st_read(system.file("extdata/wmu_sample.shp", package = "abmi.camera.extras"))
#' # Obtain ABMI deployments in sample WMUs, keeping unit name
#' wmu_sample_deployments <- get_cam_within_aoi(wmu_sample, cols = "WMUNIT_NAM")
#' # Plot results
#' wmu_sample <- st_transform(wmu_sample, "+init=epsg:4326")
#' plot(wmu_sample_deployments$geometry, pch = 21, cex = 0.7, col = "blue", bg = "gray80")
#' plot(wmu_sample$geometry, border = "gray20", col = NA, add = TRUE)
#' @return a dataframe of deployments within the supplied area of interest
#' @author Marcus Becker

# Obtain camera deployments within an area of interest:
get_cam_within_aoi <- function(x, cols = NULL, keep.all = FALSE) {

  # Check to make sure x is a spatial (sf, sfc, sp) object
  stopifnot(inherits(x, "sf") || inherits(x, "sfc") || inherits(x, "SpatialPolygonsDataFrame"))

  # Convert sp to sf
  if (is(x, "SpatialPolygonsDataFrame"))
    x <- st_as_sf(x)
  else
    x

  # Transform coordinates of x to epsg:4326
  x <- st_transform(x, "+init=epsg:4326")

  # Prepare deployment locations data into sf object
  data("abmi_deployment_locations", envir = environment())
  locations <- st_as_sf(abmi_deployment_locations,
                        coords = c("Public_Long", "Public_Lat"), crs = 4326)

  # Spatially join deployments with x
  df <- st_join(locations, x[cols], left = keep.all)

  return(df)

}