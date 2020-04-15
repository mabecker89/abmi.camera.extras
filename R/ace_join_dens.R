#' Join estimated ABMI single-deployment density values
#'
#' @param x a dataframe of deployments of interest, including at minimum the deployment id and year
#' @param species character; vector of species of interest (common name). If left blank, all species available will be returned.
#' @param samp_per character; vector of sampling period of interest. Available periods include the years 2013-2018, inclusive. If left blank, estimates from all available sampling periods will be returned.
#' @param nest logical; if TRUE, a dataframe nested by species (common name) is returned.
#' @details valid values for argument \code{species} currently are:
#' \itemize{
#'  \item White-tailed Deer
#'  \item Mule deer
#'  \item Moose
#'  \item Elk (wapiti)
#'  \item Black Bear
#'  \item Coyote
#'  \item Pronghorn
#'  \item Snowshoe Hare
#'  \item Woodland Caribou
#'  \item Canada Lynx
#'  \item Gray Wolf
#'  }
#' @details valid values for argument \code{samp_per} currently are:
#' \itemize{
#'  \item 2013
#'  \item 2014
#'  \item 2015
#'  \item 2016
#'  \item 2017
#'  \item 2018
#'  }
#' @import dplyr tidyr
#' @export
#' @examples
#' library(dplyr)
#' # Dataframe of deployments and year
#' df <- data.frame(deployment = c("ABMI-633-NE",
#'                                 "ABMI-633-NW",
#'                                 "ABMI-633-SE",
#'                                 "ABMI-633-SW"),
#'                  samp_per = c(2015, 2015, 2015, 2015)) %>%
#'                  mutate_if(is.factor, as.character)
#' # Join density estimates (e.g. Moose in 2015)
#' df_densities <- ace_join_dens(df, species = "Moose", samp_per = "2015", nest = FALSE)
#' @return Tidy dataframe of deployments in sampling period(s) specified with two appended columns: species and estimated density.

# Join density estimates
ace_join_dens <- function(x, species, samp_per, nest = FALSE) {

  # Prepare density data
  data("density_adj", envir = environment())

  # Possible species
  sp <- c("White-tailed Deer",
          "Mule deer",
          "Moose",
          "Elk (wapiti)",
          "Black Bear",
          "Coyote",
          "Pronghorn",
          "Snowshoe Hare",
          "Woodland Caribou",
          "Canada Lynx",
          "Gray Wolf")

  # Possible sampling periods
  all_samp_per <- c("2013", "2014", "2015", "2016", "2017", "2018")

  # Create default values for species and year
  if(missing(species)) {
    species <- sp
  } else {
    species
  }

  if(missing(samp_per)) {
    sample_period <- samp_per <- all_samp_per
  } else {
    sample_period <- samp_per
  }

  # Stop call if species or sampling period is not within range of possible values
  if(all(!species %in% sp)) {
    stop("A valid species must be supplied. See ?ace_join_dens for list of possible values", call. = TRUE)
  }
  if(all(!samp_per %in% all_samp_per)) {
    stop("A valid sampling period must be supplied. See ?ace_join_dens for a list of possible values", call. = TRUE)
  }

  # Subset density by species and year
  d <- density_adj %>% dplyr::filter(common_name %in% species, samp_per %in% sample_period)

  df <- x %>%
    dplyr::left_join(d, by = c("deployment", "samp_per")) %>%
    dplyr::filter(!is.na(density_adj)) %>%
    dplyr::rename(density = density_adj)


  # Nesting
  if(nest == TRUE) {
    df <- df %>% dplyr::group_by(common_name) %>% tidyr::nest()
  } else {
    df
  }

  return(df)

}