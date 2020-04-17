#' Summarise animal density within an area of interest
#'
#' @param x a dataframe of deployments of interest with associated density estimates
#' @param group_id column name (variable) to group by if x contains multiple areas; defaults to NULL (for when a single area is supplied)
#' @param agg_samp_per logical; if FALSE, the default, density is summarised by sampling period; if TRUE, all sampling periods are aggregated
#' @param samp_per_col column name holding sampling period id; defaults to 'samp_per'; not required if agg_samp_per is set to TRUE
#' @param species_col column name holding species id; defaults to 'common_name'
#' @param dens_col column name holding density values for individual camera deployments; defaults to 'density'
#' @param conflevel level of confidence for the confidence interval; defaults to 0.9 (90 percent CI)
#' @import dplyr tidyr sf purrr
#' @importFrom rlang quo_is_null .data
#' @export
#' @examples
#' library(dplyr)
#' library(sf)
#' # Example aoi of four Wildlife Management Units (WMUs) in Alberta:
#' wmu_sample <- st_read(system.file("extdata/wmu_sample.shp", package = "abmi.camera.extras"))
#' # Obtain ABMI deployments in sample WMUs, keeping unit name
#' wmu_sample_deployments <- ace_get_cam(wmu_sample, group_id = WMUNIT_NAM)
#' wmu_sample_deployments_dens <- ace_join_dens(wmu_sample_deployments,
#'                                              species = c("Moose", "Mule deer"),
#'                                              nest = FALSE)
#' # Summarise density by WMU and sampling period
#' wmu_densities <- ace_summarise_dens(x = wmu_sample_deployments_dens,
#'                                     group_id = WMUNIT_NAM,
#'                                     agg_samp_per = FALSE,
#'                                     conflevel = 0.9)
#' @return A dataframe with estimated density by species, area, and sampling period, along with associated confidence interval.

# Summarise density
ace_summarise_dens <- function(x,
                               group_id,
                               agg_samp_per = TRUE,
                               samp_per_col,
                               species_col = common_name,
                               dens_col = density,
                               conflevel = 0.9) {

  # If present, drop geometry
  if("geometry" %in% names(x)) {
    x <- sf::st_set_geometry(x, NULL)
  }

  # Ensure`species_col` and `dens_col` are column names
  sc <- dplyr::enquo(species_col) %>% dplyr::quo_name()
  dc <- dplyr::enquo(dens_col) %>% dplyr::quo_name()
  if(!(sc %in% names(x) & dc %in% names(x))) {
    stop("the `species_col` and `dens_col` arguments must both refer to columns in x")
  }

  # Ensure `group_id` is a column name, and group if supplied
  if(!rlang::quo_is_missing(enquo(group_id))) {
    gr_id <- dplyr::enquo(group_id) %>% dplyr::quo_name()
    if(!gr_id %in% names(x)) {
      stop("the `group_id` argument must refer to a column in x")
    }
    x <- x %>% dplyr::group_by({{ group_id }})
  } else {
    x
  }

  # Ensure `samp_per_col` is a column name, and group if supplied and `agg_samp_per` is FALSE
  if(!rlang::quo_is_missing(enquo(samp_per_col))) {
    spc <- dplyr::enquo(samp_per_col) %>% dplyr::quo_name()
    if(!spc %in% names(x)) {
      stop("the `samp_per_col` argument must refer to a column in x")
    }
    if(agg_samp_per == FALSE) {
      x <- x %>% dplyr::group_by({{ samp_per_col }}, add = TRUE)
    } else {
      x
      warning("Even though the `samp_per_col` argument was provided, sampling period has been aggregated in output. Change `agg_samp_per` to FALSE if this is not the desired output.")
    }
  } else {
    # Use default 'samp_per' if `samp_per_col` is not supplied but `agg_samp_per` is FALSE
    if("samp_per" %in% names(x)) {
      if(agg_samp_per == FALSE) {
        x <- x %>% dplyr::group_by(samp_per, add = TRUE)
      } else {
        x
      }
    } else {
      # Return an error if the default does not exist
      if(agg_samp_per == FALSE) {
        stop("cannot group by sampling period if argument `sample_per_col` is not supplied and the default column of `samp_per` does not exist. Either set `agg_samp_per` to TRUE, or supply a column to signal the sampling period to group on.")
      }
    }
  }

  # Last but not least, group by species
  x <- x %>% dplyr::group_by({{ species_col }}, add = TRUE)

  occupied <- n_deployments <- prop_occupied <- agp <- agp.se <- density_avg <- NULL

  # Summarise density
  df <- x %>%
    dplyr::summarise(
      occupied = sum({{ dens_col }} > 0, na.rm = TRUE),
      n_deployments = dplyr::n(),
      prop_occupied = occupied / n_deployments,
      agp = mean({{ dens_col }}[{{ dens_col }} > 0]),
      agp.se = sd({{ dens_col }}[{{ dens_col }} > 0]) / sqrt(occupied)) %>%
    dplyr::mutate(
      agp = ifelse(agp == "NaN", 0, agp),
      density_avg = prop_occupied * agp)

  sim <- density_uci <- density_lci <- NULL

  # Simulate for CI
  df <- df %>%
    dplyr::group_by({{ species_col }}, add = TRUE) %>%
    tidyr::nest() %>%
    dplyr::mutate(
      agp.se = purrr::map(.x = data, .f = ~ purrr::pluck(.x[["agp.se"]])),
      sim = purrr::map_if(.x = data,
                          .p = !is.na(agp.se),
                          .f = ~ simul_ci(prob = .x$prop_occupied,
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