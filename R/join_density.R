#' Join estimated density values to deployments
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
#' df_densities <- join_density(df, species = "Moose", year = "2015", nest = FALSE)
#' @return Tidy dataframe of deployments in year(s) specified with two appended columns: species and estimated density.
#' @author Marcus Becker

# Join density estimates
join_density <- function(x, species, year, nest = FALSE) {

  # Prepare density data
  data("density", envir = environment())

  # Create default values from species and year
  if(missing(species)) {
    species <- c("White-tailed Deer",
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
  } else {
    species
  }

  if(missing(year)) {
    year <- c("2013", "2014", "2015", "2016", "2017", "2018")
  } else {
    year
  }

  # Subset density by species and year
  d <- density %>% dplyr::filter(common_name %in% species,
                                 Year %in% year)

  df <- x %>%
    dplyr::left_join(d, by = c("Deployment", "Year")) %>%
    dplyr::filter(!is.na(density))


  # Nesting
  if(nest == TRUE) {
    df <- df %>% dplyr::group_by(common_name) %>% tidyr::nest()
  } else {
    df
  }

  return(df)

}