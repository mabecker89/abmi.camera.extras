#' Subset camera deployments by a specified spatial area of interest
#'
#' @param aoi The area of interest as an sf, sfc, or sp (SpatialPolygonsDataFrame) object
#' @param group_id If aoi contains multiple polygons, name of the attribute to be appended to the output dataframe as identifier
#' @param dep A dataframe of camera deployment locations as coordinate points; defaults to NULL, in which case ABMI camera deployment locations are used.
#' @param coords If dep is specified, names of the of numeric columns holding coordinates
#' @param crs coordinate reference system; integer with the EPSG code, or character with proj4string; defaults to 4326.
#' @import sf dplyr
#' @importFrom rlang quo_is_null .data
#' @export
#' @examples
#'
#' library(sf)
#' # Example aoi of four Wildlife Management Units (WMUs) in Alberta:
#' wmu_sample <- st_read(system.file("extdata/wmu_sample.shp", package = "abmi.camera.extras"))
#' # Obtain ABMI deployments in sample WMUs, keeping unit name
#' wmu_sample_deployments <- ace_get_cam(wmu_sample, group_id = WMUNIT_NAM)
#' # Plot results
#' wmu_sample <- st_transform(wmu_sample, "+init=epsg:4326")
#' plot(wmu_sample_deployments$geometry, pch = 21, cex = 0.7, col = "blue", bg = "gray80")
#' plot(wmu_sample$geometry, border = "gray20", col = NA, add = TRUE)
#'
#' @return A dataframe of camera deployments within the supplied area of interest (aoi)

# Obtain camera deployments within an area of interest:
ace_get_cam <- function(aoi, group_id = NULL, dep = NULL, coords = NULL, crs = 4326) {

  # Check to make sure aoi is a spatial (sf, sfc, sp) object
  stopifnot(inherits(aoi, "sf") || inherits(aoi, "sfc") || inherits(aoi, "SpatialPolygonsDataFrame"))

  # Check that id is in aoi
  if(!rlang::quo_is_null(dplyr::enquo(group_id))) {
    grid <- dplyr::enquo(group_id) %>% dplyr::quo_name()
    if(all(!grid %in% names(aoi))) {
      stop("the `aoi` object must contain the attribute specified in `id`")
    }
  }

  # Convert sp to sf
  if (is(aoi, "SpatialPolygonsDataFrame"))
    aoi <- sf::st_as_sf(aoi)
  else
    aoi

  # Apply crs to aoi
  aoi <- sf::st_transform(aoi, crs)
  # Select only id variable
  aoi <- aoi %>% dplyr::select({{ group_id }})

  if (is.null(dep)) {
    # Prepare abmi deployment locations into sf object with 4326 as crs, then transform to y
    data("abmi_deployment_locations", envir = environment())
    sf_abmi_dep <- abmi_deployment_locations %>%
      sf::st_as_sf(coords = c("public_long", "public_lat"),
                   crs = 4326) %>%
      sf::st_transform(crs)

    # Spatial join sf_abmi_dep with aoi
    df <- sf::st_join(sf_abmi_dep, aoi, left = FALSE)

  } else {
    # Check if coords are specified
    if(missing(coords)) {
      stop("Please use `coords` to define a vector that specifies which columns in `dep` refer to the long/lat coordinates, respectively.")
    }
    # Prepare dep into sf object with 4326 as crs, then transform to y
    sf_dep <- sf::st_as_sf(dep, coords = coords, crs = 4326) %>%
      sf::st_transform(crs)

    # Spatial join sf_dep with aoi
    df <- sf::st_join(sf_dep, aoi, left = FALSE)

  }

  return(df)

}