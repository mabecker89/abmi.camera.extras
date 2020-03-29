#' Join estimated single-deployment density values
#'
#' @param x a dataframe of deployments of interest, including at minimum the deployment id and year
#' @param species character; vector of species of interest (common name). If left blank, all species available will be returned.
#' @param year character; vector of years of interest (2013-2018). If left blank, all years available will be returned.
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
#' @import dplyr tidyr
#' @export
#' @examples
#' library(dplyr)
#' # Dataframe of deployments and year
#' df <- data.frame(Deployment = c("ABMI-633-NE",
#'                                 "ABMI-633-NW",
#'                                 "ABMI-633-SE",
#'                                 "ABMI-633-SW"),
#'                  Year = c(2015, 2015, 2015, 2015)) %>%
#'                  mutate_if(is.factor, as.character)
#' # Join density estimates (e.g. Moose in 2015)
#' df_densities <- ace_join_dens(df, species = "Moose", year = "2015", nest = FALSE)
#' @return Tidy dataframe of deployments in year(s) specified with two appended columns: species and estimated density.

# Join density estimates
ace_join_dens <- function(x, species, year, nest = FALSE) {

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

  # Possible years
  yr <- c("2013", "2014", "2015", "2016", "2017", "2018")

  # Create default values for species and year
  if(missing(species)) {
    species <- sp
  } else {
    species
  }

  if(missing(year)) {
    year <- yr
  } else {
    year
  }

  # Stop call if species or year is not within range of possible values
  if(all(!species %in% sp)) {
    stop("A valid species must be supplied. See ?ace_join_dens for list of possible values", call. = TRUE)
  }
  if(all(!year %in% yr)) {
    stop("A valid year must be supplied. See ?ace_join_dens for a list of possible values", call. = TRUE)
  }

  # Subset density by species and year
  d <- density_adj %>% dplyr::filter(common_name %in% species,
                                 Year %in% year)

  df <- x %>%
    dplyr::left_join(d, by = c("Deployment", "Year")) %>%
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