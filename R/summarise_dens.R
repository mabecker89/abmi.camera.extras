#' Summarise animal density within an area of interest
#'
#' @param x a dataframe of deployments of interest with associated density estimates
#' @param group variable to group by if x contains multiple areas; defaults to NULL (for when a single area is supplied)
#' @param agg.years logical; if FALSE, the default, density is summarised by year; if TRUE all years are aggregated
#' @param conflevel level of confidence for the confidence interval; defaults to 0.9 (90% CI)
#' @details valid values for argument \code{species} currently are:
#' @import dplyr tidyr sf rlang purrr
#' @export
#' @examples
#' library(dplyr)
#' library(sf)
#' # Example aoi of four Wildlife Management Units (WMUs) in Alberta:
#' wmu_sample <- st_read(system.file("extdata/wmu_sample.shp", package = "abmi.camera.extras"))
#' # Obtain ABMI deployments in sample WMUs, keeping unit name
#' wmu_sample_deployments <- get_cam(wmu_sample, cols = "WMUNIT_NAM")
#' wmu_sample_deployments_dens <- join_dens(wmu_sample_deployments, species = c("Moose", "Mule deer"), nest = FALSE)
#' # Summarise density by WMU and year
#' wmu_densities <- summarise_dens(x = wmu_sample_deployments_dens,
#'                                 group = WMUNIT_NAM,
#'                                 agg.years = FALSE,
#'                                 conflevel = 0.9)
#' @return A dataframe with estimated density and associated confidence interval
#' @author Marcus Becker

summarise_dens <- function(x, group = NULL, agg.years = FALSE, conflevel = 0.9) {

  # If present, drop geometry
  if("geometry" %in% names(x)) {
    x <- sf::st_set_geometry(x, NULL)
  }

  # Ensure `group` is a column name
  if(!rlang::quo_is_null(enquo(group))) {
    group1 <- dplyr::enquo(group)
    name <- dplyr::quo_name(group1)
    if(!name %in% names(x)) {
      stop("the `group` argument must refer to a column in x")
    }
    x <- x %>% dplyr::group_by({{ group }})
  } else {
    x
  }

  # Option to aggregate years
  if(agg.years == TRUE) {
    x <- x %>% dplyr::group_by(common_name, add = TRUE)
  } else {
    x <- x %>% dplyr::group_by(Year, common_name, add = TRUE)
  }

  # Summarise density
  df <- x %>%
    dplyr::summarise(
      occupied = sum(density > 0, na.rm = TRUE),
      n_deployments = dplyr::n(),
      occupancy = occupied / n_deployments,
      agp = mean(density[density > 0]),
      agp.se = sd(density[density > 0]) / sqrt(occupied)) %>%
    dplyr::mutate(
      agp = ifelse(agp == "NaN", 0, agp),
      density_avg = occupancy * agp)

  # Simulate for CI
  df <- df %>%
    dplyr::group_by(common_name, add = TRUE) %>%
    tidyr::nest() %>%
    dplyr::mutate(
      agp.se = purrr::map(.x = data, .f = ~ purrr::pluck(.x[["agp.se"]])),
      sim = purrr::map_if(.x = data,
                          .p = !is.na(agp.se),
                          .f = ~ simul_ci(prob = .x$occupancy,
                                          trials = .x$n_deployments,
                                          adj = .x$occupied,
                                          agp = .x$agp,
                                          agp.se = .x$agp.se),
                          .else = ~ ifelse(is.na(agp.se), NA, sim)),
      sim = purrr::map2(.x = sim,
                        .y = data,
                        .f = ~ .x * .y$density_avg / mean(.x))) %>%
    dplyr::mutate(
      density_lci = purrr::map_dbl(.x = sim,
                                   .f = ~ quantile(.x, probs = (1 - conflevel) / 2, na.rm = TRUE)),
      density_uci = purrr::map_dbl(.x = sim,
                                   .f = ~ quantile(.x, probs = conflevel + ((1 - conflevel) / 2), na.rm = TRUE))) %>%
    dplyr::select(-c(sim, agp.se)) %>%
    tidyr::unnest_wider(data) %>%
    dplyr::mutate(
      density_lci = tidyr::replace_na(density_lci, 0),
      density_uci = tidyr::replace_na(density_uci, 0),
      density_lci = ifelse(occupied == 1, density_avg, density_lci),
      density_uci = ifelse(occupied == 1, density_avg, density_uci)) %>%
    dplyr::rename_at(.vars = c("density_lci", "density_uci"),
                     .funs = list(~ paste(., conflevel, sep = "_"))) %>%
    dplyr::select(-c(agp, agp.se))

  return(df)

}















