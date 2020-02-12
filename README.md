
``` r
library(knitr)
# Set knitr chunk options
opts_chunk$set(include=TRUE, echo=TRUE, message=FALSE, warning=FALSE, eval=TRUE)
```

abmi.camera.extras
------------------

> Functions for using ABMI camera data to estimate animal density

<!-- badges: start -->
[![Travis build status](https://travis-ci.org/mabecker89/abmi.camera.extras.svg?branch=master)](https://travis-ci.org/mabecker89/abmi.camera.extras) <!-- badges: end -->

**Warning: under development!**

Overview
--------

This package provides access to the Alberta Biodiversity Monitoring Institute's (ABMI) camera-level animal density estimates, which can be used to estimate the density (and associated confidence bounds) of various species in a user-defined area of interest. For more information on how the ABMI estimates animal density from camera data, visit this [repository](https://github.com/ABbiodiversity/mammals-camera) for a detailed explanation and code base.

This package currently contains ABMI camera data from: + 2015 + 2016 + 2017 + 2018 + 2019 (*coming soon!*) And includes the following species: + White-tailed Deer + Mule deer + Moose + Elk (wapiti) + Black Bear + Coyote + Pronghorn + Snowshoe Hare + Woodland Caribou + Canada Lynx + Gray Wolf

Current geographic coverage of sampling in the province:

<img src="./man/figures/map_deployments.png" alt="ABMI sites with camera deployments (2015-2018)" width="70%" />
<p class="caption">
ABMI sites with camera deployments (2015-2018)
</p>

Installation
------------

``` r
# Install the latest version from Github:
# install.packages("devtools")

devtools::install_github("mabecker89/abmi.camera.extras")
```

Features
--------

The primary objective of this package is to allow users to estimate the density of a species of interest in an area of interest. For this objective, three steps are neccessary:

-   Spatially subset ABMI camera deployments by a user-supplied area of interest (or multiple);
-   Join pre-processed individual deployment density estimates to the this spatial subset;
-   Summarise density for the area of interest as a whole, including confidence bounds.

Usage
-----

``` r
# Load package
library(abmi.camera.extras)

# Load packages for working with spatial data
library(sf)
# Note: sp objects will also work.
# library(sp)
```

The first step is to define an area of interest, such as a Wildlife Management Unit, Municipality, Land Use Planning Region, etc. Below, this is done using the `sf` package to read in a shapefile of four WMUs - Crow Lake (code 512), Lac La Biche (503), Beaver River (502), and Amisk (504) - all of which are located in the central-east part of Alberta.

``` r
# Define aoi
sf_wmu <- sf::st_read(system.file("extdata/wmu_sample.shp", package = "abmi.camera.extras"))
```

    ## Reading layer `wmu_sample' from data source `C:\Users\mabec\Documents\R\win-library\3.6\abmi.camera.extras\extdata\wmu_sample.shp' using driver `ESRI Shapefile'
    ## Simple feature collection with 4 features and 5 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 632139.5 ymin: 5997019 xmax: 776266.6 ymax: 6209376
    ## epsg (SRID):    NA
    ## proj4string:    +proj=tmerc +lat_0=0 +lon_0=-115 +k=0.9992 +x_0=500000 +y_0=0 +datum=NAD83 +units=m +no_defs

``` r
# Take a look at structure and attributes
tibble::glimpse(sf_wmu)
```

    ## Observations: 4
    ## Variables: 6
    ## $ OBJECTID   <dbl> 25, 34, 49, 50
    ## $ WMUNIT_NAM <fct> Crow Lake, Lac La Biche, Beaver River, Amisk
    ## $ WMUNIT_COD <fct> 00512, 00503, 00502, 00504
    ## $ Shape_STAr <dbl> 8018929846, 3220514507, 3585827617, 2704241428
    ## $ Shape_STLe <dbl> 476404.3, 355774.1, 293530.4, 252285.2
    ## $ geometry   <POLYGON [m]> POLYGON ((754560.7 6209247,..., POLYGON ((713202...

Next, we subset ABMI camera deployments spatially with the `get_cam()` function:

``` r
# Retrieve deployments in aoi as dataframe
df_deployments <- get_cam(aoi = sf_wmu,
                          cols = "WMUNIT_NAM", # Maintain WMU name attribute in output
                          keep.all = FALSE)
```

From here we can join density estimates for a species of interest in a given year for each deployment using the `join_dens()` function:

``` r
# Join density
df_dens <- join_dens(x = df_deployments,
                     species = c("Moose", "Mule deer"), # See ?join_dens for list of available species
                     # year = "2018" option to define specific year if desired
                     nest = FALSE)
```

The last step is to estimate the density of each of the species defined previously in the area of the interest, which can be done with the `summarise_dens()` function.

``` r
# Summarse density
df_dens_summary <- summarise_dens(x = df_dens,
                                  group = WMUNIT_NAM, # to group deployments when evaluating multiple aoi
                                  agg.years = FALSE, # option to aggregate years together
                                  conflevel = 0.9) # for confidence interval - default 90%
```
