#' ABMI camera deployments public locations
#'
#' This dataset provides the lat/long coordinates associated with the public
#' locations of ABMI camera deployments.
#'
#' @name abmi_deployment_locations
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
"abmi_deployment_locations"