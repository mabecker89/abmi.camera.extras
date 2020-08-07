# Set root
root <- "G:/Shared drives/ABMI Camera Mammals/"

library(readr)
library(dplyr)
library(tidyr)
library(stringr)

# Available species
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

# Load lure adjusted density estimates
density_adj <- read_csv(paste0(root, "results/density/Marcus/abmi-all-years_density-lure-adj_2020-07-30.csv")) %>%
  # Just core sites, nothing funky in terms of camera models, off-grid, etc
  filter(str_detect(name_year, "ABMI"),
         !str_detect(name_year, "HF2|CUDDE|HP2X|OG|-b_")) %>%
  # Subset of species
  filter(common_name %in% species) %>%
  # 2014-2019 for now
  separate(name_year, into = c("name", "samp_per"), sep = "_") %>%
  # filter(samp_per >= 2015) %>%
  # Remove deployment/season combos that were operational for less than 10 days
  filter(total_season_days >= 10) %>%
  # Summarise by deployment, year
  group_by(name, samp_per, common_name) %>%
  summarise(density = mean(density_km2_lure_adj, na.rm = TRUE)) %>%
  # Remove NaN's
  filter(!density == "NaN") %>%
  ungroup()

# Load deployment locations
public_locations <- read_csv(paste0(root, "data/lookup/locations/all-cam-public-locations_2020-07-31.csv")) %>%
  # Just core sites, from 2014 onwards
  filter(str_detect(name, "ABMI"),
         !str_detect(name, "HF2|CUDDE|HP2X|OG|-b_"),
         year >= 2014) %>%
  rename(samp_per = year)

# Camera deployments represented in the density data
cams <- density_adj %>%
  select(name) %>%
  distinct() %>%
  pull()

# Filter out camera deployments that are not represented
public_locations <- public_locations %>%
  filter(name %in% cams)

usethis::use_data(species, density_adj, public_locations, overwrite = TRUE)
