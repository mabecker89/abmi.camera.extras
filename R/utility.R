#' Utility functions
#'
#' @param prob the occupancy rate
#' @param trials the number of deployments
#' @param adj the number of occupied sites
#' @param agp abundance given presence
#' @param agp.se the standard error of the abundance given presence
#' @importFrom stats rbinom rnorm sd
#' @return numeric of type double with length of 10000 (the number of simulations)
#' @keywords internal
#' @author Marcus Becker

# Create simulation for confidence interval
simul_ci <- function(prob, trials, adj, agp, agp.se) {

  # Simulate presence as binomial distribution
  pa.sim <- rbinom(n = 10000,
                   size = trials,
                   prob = prob)
  pa.sim <- pa.sim / trials

  # Adjustment
  if(adj > 0) {
    s <- sqrt(adj)
  } else
    s <- 1

  # Simulate abundance given presence as log-normal distribution
  agp.sim <- exp(rnorm(n = 10000,
                       mean = log(agp),
                       sd = (sqrt(agp.se ^ 2 / agp ^ 2)) / s))

  # Multiply together
  full.sim <- pa.sim * agp.sim

}