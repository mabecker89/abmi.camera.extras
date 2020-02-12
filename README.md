# abmi.camera.extras

<!-- badges: start -->
[![Travis build status](https://travis-ci.org/mabecker89/abmi.camera.extras.svg?branch=master)](https://travis-ci.org/mabecker89/abmi.camera.extras)
<!-- badges: end -->

Extra functions and data to make use of ABMI camera deployment data

**Warning: under development!**

Only Github version available now:

```r
devtools::install_github("mabecker89/abmi.camera.extras")
```

### Upcoming features

- Select ABMI deployments in a user-defined area of interest

```r
library(abmi.camera.extras)
library(sf)

# aoi as sf object
wmu_sample <- st_read(system.file("extdata/wmu_sample.shp", package = "abmi.camera.extras"))

# Find deployments in aoi
wmu_sample_deployments <- get_cam_within_aoi(wmu_sample, cols = "WMUNIT_NAM", keep.all = FALSE)
```

- Join individual deployment [density estimates](https://github.com/ABbiodiversity/mammals-camera) to subset of deployments, by species and year

```r
# Append density estimates of Moose in 2015
df_density <- join_density(wmu_sample_deployments, species = "Moose", year = "2015")
```

- Estimate density for an aoi (upcoming)
