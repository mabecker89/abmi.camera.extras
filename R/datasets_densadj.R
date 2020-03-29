#' Mammal density estimations at ABMI deployments, adjusted for lure status.
#'
#' This dataset provides estimated density calculations using the REST method for
#' 11 common mammal species at each ABMI deployment from 2015-2018.
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