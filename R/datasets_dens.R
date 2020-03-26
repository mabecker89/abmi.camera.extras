#' Mammal density estimations at ABMI deployments
#'
#' This dataset provides estimated density calculations using the REST method for
#' 11 common mammal species at each ABMI deployment from 2015-2018.
#'
#' @name density
#' @docType data
#' @keywords data
#' @seealso \url{https://github.com/ABbiodiversity/mammals-camera}
#' @format A data.frame with 4 columns
#' \describe{
#' \item{Deployment}{The camera deployment ID. Format is <Project Code>-<Site>-<Station>, e.g. ABMI-1-NE.}
#' \item{Year}{The year that the camera was deployed.}
#' \item{common_name}{The species common name.}
#' \item{density}{Estimated density in individuals per km-square}
#' }
#' @source Alberta Biodiversity Monitoring Institute
#'
"density"