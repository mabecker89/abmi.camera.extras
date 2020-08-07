#' abmi.camera.extras: Functions and data to make use of ABMI camera deployment data
#'
#' This packages provides some functionality to interact with and explore ABMI camera data.
#' It includes some sample data, important lookup tables, and a few functions to serve basic needs.
#'
#' @author Marcus Becker \email{mabecker@ualberta.ca}
#' @docType package
#' @name abmi.camera.extras
"_PACKAGE"

# Define global variables
utils::globalVariables(c("public_locations", "data", "is", "density_adj", "species", "density", "common_name", "samp_per"))