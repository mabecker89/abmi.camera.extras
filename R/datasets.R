#' ABMI camera deployments public locations
#'
#' This dataset provides the lat/long coordinates associated with the public
#' locations of ABMI camera deployments.
#'
#' @name public_locations
#' @docType data
#' @keywords data
#' @seealso \url{https://www.abmi.ca/home/data-analytics/DA-top-about-data/About-ABMI-Data/Survey-Site-Locations.html}
#' @format A data.frame with 5 columns
#' \describe{
#' \item{Deployment}{The camera deployment ID. Format is <Project Code>-<Site>-<Station>, e.g. ABMI-1-NE.}
#' \item{NearestSite}{The corresponding nearest ABMI sampling site.}
#' \item{Year}{The year the camera was deployed.}
#' \item{Public_Lat}{The public latitude}
#' \item{Public_Long}{The public longitude}
#' }
#' @source Alberta Biodiversity Monitoring Institute
#'
"public_locations"

#' Mammal density estimations at ABMI deployments, adjusted for lure status.
#'
#' This dataset provides estimated density calculations using the REST method for 11 common mammal species at each ABMI deployment from 2015-2019. The estimates are lure-adjusted.
#'
#' @name density_adj
#' @docType data
#' @keywords data
#' @seealso \url{https://github.com/ABbiodiversity/mammals-camera}
#' @format A data.frame with 4 columns
#' \describe{
#' \item{Deployment}{The camera deployment ID. Format is <Project Code>-<Site>-<Station>, e.g. ABMI-1-NE.}
#' \item{Year}{The year that the camera was deployed.}
#' \item{common_name}{The species common name.}
#' \item{density_adj}{Estimated density in individuals per km-square, adjusted for lure status of the deployment.}
#' }
#' @source Alberta Biodiversity Monitoring Institute
#'
"density_adj"

#' Mammal species included in this package.
#'
#' Eleven (11) common mammal species for which density estimates are provided as part of this package
#'
#' @name species
#' @docType data
#' @keywords data
#' @seealso \url{https://github.com/ABbiodiversity/mammals-camera}
#' @format A character vector
#' @source Alberta Biodiversity Monitoring Institute
#'
"species"