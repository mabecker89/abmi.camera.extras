
abmi.camera.extras
==================

> Functions for using ABMI camera data to estimate animal density

<!-- badges: start -->
[![Travis build status](https://travis-ci.org/mabecker89/abmi.camera.extras.svg?branch=master)](https://travis-ci.org/mabecker89/abmi.camera.extras) <!-- badges: end -->

**Warning: under development!**

Overview
--------

This package provides access to the Alberta Biodiversity Monitoring Institute's (ABMI) camera-level animal density estimates, which can be used to estimate the density (and associated confidence bounds) of various species in a user-defined area of interest. For more information on how the ABMI estimates animal density from camera data, visit this [repository](https://github.com/ABbiodiversity/mammals-camera) for a detailed explanation and code base.

This package currently contains ABMI camera data from:

-   2015
-   2016
-   2017
-   2018
-   2019 (*coming soon!*)

And includes the following species:

-   White-tailed Deer
-   Mule deer
-   Moose
-   Elk (wapiti)
-   Black Bear
-   Coyote
-   Pronghorn
-   Snowshoe Hare
-   Woodland Caribou
-   Canada Lynx
-   Gray Wolf

Current geographic coverage of sampling in the province can be seen in the map below:

<img src="./man/figures/map_deployments.png" alt="ABMI sites with camera deployments (2015-2018)" width="70%" />
<p class="caption">
ABMI sites with camera deployments (2015-2018)
</p>

Installation
------------

``` r
# Install the latest version from Github:
# install.packages("devtools")

# devtools::install_github("mabecker89/abmi.camera.extras")
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
sf_wmu <- sf::st_read(system.file("extdata/wmu_sample.shp", package = "abmi.camera.extras"), quiet = TRUE)

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

# Plot deployments
sf_wmu <- st_transform(sf_wmu, "+init=epsg:4326")
plot(df_deployments$geometry, pch = 21, cex = 0.7, col = "blue", bg = "gray80")
plot(sf_wmu$geometry, border = "gray20", col = NA, add = TRUE)
```

![](README_files/figure-markdown_github/unnamed-chunk-5-1.png)

Note that there are four cameras deployed at each ABMI site, 600-m apart. Each point on the plot represents a site, which has four deployments. See [here](https://www.abmi.ca/home/publications/551-600/565) for detailed explanation of remote camera trap protocols.

From here we can join density estimates for a species of interest in a given year for each deployment using the `join_dens()` function:

``` r
# Join density
df_dens <- join_dens(x = df_deployments,
                     species = c("Moose", "Mule deer"), # See ?join_dens for list of available species
                     # year = "2018" option to define specific year if desired
                     nest = FALSE)
```

The last step is to estimate the density of each of the species defined previously in the area of the interest, which can be done with the `summarise_dens()` function.

The output is a dataframe with the following attributes (beside the grouping variable, year, and species):

-   `occupied` - number of deployments with a individual of that species present
-   `n_deployments` - total number of deployments
-   `occupancy` - proportion of deployments occupied (not detection probability adjusted)
-   `density_avg` - estimated density for the area/year/species combination
-   `density_lci` - lower bounds of confidence interval (level specified in `conflevel` attribute)
-   `density_uci` - upper bounds of confidence interval

The precision of the density estimate is estimated using the [delta method](https://en.wikipedia.org/wiki/Delta_method).

``` r
# Summarise density
df_dens_summary <- summarise_dens(x = df_dens,
                                  group = WMUNIT_NAM, # to group deployments when evaluating multiple aoi
                                  agg.years = FALSE, # option to aggregate years together
                                  conflevel = 0.9) # for confidence interval - default 90%

knitr::kable(df_dens_summary)
```

| WMUNIT\_NAM  |  Year| common\_name |  occupied|  n\_deployments|  occupancy|  density\_avg|  density\_lci\_0.9|  density\_uci\_0.9|
|:-------------|-----:|:-------------|---------:|---------------:|----------:|-------------:|------------------:|------------------:|
| Amisk        |  2014| Moose        |         4|               4|  1.0000000|     4.6282195|          3.4287848|          6.0846451|
| Amisk        |  2014| Mule deer    |         0|               4|  0.0000000|     0.0000000|          0.0000000|          0.0000000|
| Amisk        |  2018| Moose        |         6|              15|  0.4000000|     0.5831947|          0.2793396|          0.9386811|
| Amisk        |  2018| Mule deer    |         1|              15|  0.0666667|     0.0102491|          0.0102491|          0.0102491|
| Beaver River |  2016| Moose        |         6|              21|  0.2857143|     0.1977091|          0.0845108|          0.3329653|
| Beaver River |  2016| Mule deer    |         3|              21|  0.1428571|     0.0153613|          0.0041559|          0.0308536|
| Beaver River |  2017| Moose        |         4|               4|  1.0000000|     1.1013434|          0.6220689|          1.7841760|
| Beaver River |  2017| Mule deer    |         0|               4|  0.0000000|     0.0000000|          0.0000000|          0.0000000|
| Beaver River |  2018| Moose        |         6|               9|  0.6666667|     1.7548748|          0.9470203|          2.6859702|
| Beaver River |  2018| Mule deer    |         0|               9|  0.0000000|     0.0000000|          0.0000000|          0.0000000|
| Crow Lake    |  2015| Moose        |         6|              15|  0.4000000|     0.4308492|          0.1988501|          0.7010855|
| Crow Lake    |  2015| Mule deer    |         0|              15|  0.0000000|     0.0000000|          0.0000000|          0.0000000|
| Crow Lake    |  2016| Moose        |        10|              24|  0.4166667|     0.5618590|          0.3252398|          0.8263949|
| Crow Lake    |  2016| Mule deer    |         0|              24|  0.0000000|     0.0000000|          0.0000000|          0.0000000|
| Crow Lake    |  2017| Moose        |         6|              24|  0.2500000|     0.3172357|          0.1283656|          0.5580521|
| Crow Lake    |  2017| Mule deer    |         0|              24|  0.0000000|     0.0000000|          0.0000000|          0.0000000|
| Crow Lake    |  2018| Moose        |         5|              15|  0.3333333|     0.3694796|          0.1466503|          0.6425632|
| Crow Lake    |  2018| Mule deer    |         0|              15|  0.0000000|     0.0000000|          0.0000000|          0.0000000|
| Lac La Biche |  2015| Moose        |        10|              22|  0.4545455|     1.1404262|          0.6547648|          1.7140894|
| Lac La Biche |  2015| Mule deer    |         1|              22|  0.0454545|     0.0003782|          0.0003782|          0.0003782|
| Lac La Biche |  2018| Moose        |         1|               3|  0.3333333|     0.1647509|          0.1647509|          0.1647509|
| Lac La Biche |  2018| Mule deer    |         0|               3|  0.0000000|     0.0000000|          0.0000000|          0.0000000|
