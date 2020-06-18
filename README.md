
<!-- README.md is generated from README.Rmd. Please edit that file -->

# LAGOSUSgis

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/LAGOSUSgis)](https://cran.r-project.org/package=LAGOSUSgis)
[![Travis build
status](https://travis-ci.org/cont-limno/LAGOSUSgis.svg?branch=master)](https://travis-ci.org/cont-limno/LAGOSUSgis)
[![DOI](https://zenodo.org/badge/106293356.svg)](https://zenodo.org/badge/latestdoi/106293356)

Extra functions to interact with the GIS module of LAGOSUS.

## Features

  - **Easy**: Convenience functions allow for straight-forward
    subsetting.

  - **Fast**: Queries are optimized for speed to avoid loading the
    entirety of massive layers.

  - **Flexible** : Custom queries can be constructed using `SQL`
    statements.

## Installation

``` r
remotes::install_github("cont-limno/LAGOSUSgis")
```

## Usage

``` r
library(LAGOSUSgis)
```

### Download data

Until data is posted publicly, place the `LAGOSUSgis` geodatabase file
in the location returned by `lagosusgis_path()`

### List available GIS layers

``` r
library(sf)
sf::st_layers(LAGOSUSgis::lagosusgis_path())
```

<details closed>

<summary> <span title="Click to Expand"> layers </span> </summary>

``` r



name                                    driver         features   fields
--------------------------------------  ------------  ---------  -------
TIGER_Coastline                         OpenFileGDB        4245        3
US_Box                                  OpenFileGDB           1        2
County_Coastline                        OpenFileGDB        5756       19
Derived_Land_Borders                    OpenFileGDB           7        3
US_Countybased_Clip_Polygon             OpenFileGDB           1        3
simple_bailey                           OpenFileGDB         165       15
simple_mlra                             OpenFileGDB         226       14
simple_wwf                              OpenFileGDB          44       12
simple_state                            OpenFileGDB          49       15
simple_hu4                              OpenFileGDB         202       13
simple_hu8                              OpenFileGDB        2105       13
simple_county                           OpenFileGDB        3106       16
simple_neon                             OpenFileGDB          17       12
LAGOS_US_All_Lakes_1ha_AUSTIN20190521   OpenFileGDB      479950       21
NHD_Combined_Regions                    OpenFileGDB           1        2
state                                   OpenFileGDB          49       18
bailey                                  OpenFileGDB         165       19
mlra                                    OpenFileGDB         226       18
neon                                    OpenFileGDB          17       16
wwf                                     OpenFileGDB          44       16
hu12                                    OpenFileGDB       83108       16
hu8                                     OpenFileGDB        2105       16
hu4                                     OpenFileGDB         202       17
county                                  OpenFileGDB        3106       20
omernik3                                OpenFileGDB          87       22
epanutr                                 OpenFileGDB           9       13
nws                                     OpenFileGDB       27138       27
ws                                      OpenFileGDB      478749       30
LAGOS_limno_linked_merged_20191118      OpenFileGDB       81618       15
simple_epanutr                          OpenFileGDB           9       13
simple_omernik3                         OpenFileGDB          87       22
flatbuff100                             OpenFileGDB      635747        3
buff100_unflat                          OpenFileGDB      833684        2
simple_hu12                             OpenFileGDB       83108       16
flatbuff500                             OpenFileGDB     1533137        3
buff500_unflat                          OpenFileGDB     4333832        2
Great_Lakes                             OpenFileGDB          31       13
simple_buff100                          OpenFileGDB      479950        3
simple_buff500                          OpenFileGDB      479950        3
LAGOS_US_All_Lakes_1ha_No_Islands       OpenFileGDB      479950        4
simple_nws                              OpenFileGDB       27138       11
simple_ws                               OpenFileGDB      478749       12
buff100                                 OpenFileGDB      479950        6
buff500                                 OpenFileGDB      479950        6
lake_as_point                           OpenFileGDB      479950        3
LAGOS_US_All_Lakes_1ha_points           OpenFileGDB      479950       71
LAGOS_US_All_Lakes_1ha                  OpenFileGDB      479950       77
```

</details>

<br>

### Query a lake polygon

``` r
res_lake <- query_lake_poly(34352)
```

### Query from a specfic layer

``` r
res_iws  <- query_gis(layer = "ws", 
                      id_name = "lagoslakeid", ids = c(34352))
res_lake <- query_gis(layer = "LAGOS_US_All_Lakes_1ha", 
                      id_name = "lagoslakeid", ids = 34352)
res_pnt  <- query_gis(layer = "LAGOS_US_All_Lakes_1ha_POINTS", 
                      id_name = "lagoslakeid", ids = 34352)
```

### Query a combined watershed and lake polygon

``` r
res <- query_wbd(lagoslakeid = c(7010))
```

### Flexible queries using `SQL` statements

``` r
res <- query_gis_(query = "SELECT * FROM ws WHERE lagoslakeid IN ('7010')")
res <- query_gis_(query = paste0("SELECT * FROM LAGOS_US_All_Lakes_1ha_points WHERE lake_centroidstate LIKE '", "RI", "' AND lake_totalarea_ha > 4"))
```

## References

Soranno P., K. Cheruvelil. 2017. LAGOS-NE-GIS v1.0: A module for
LAGOS-NE, a multi-scaled geospatial and temporal database of lake
ecological context and water quality for thousands of U.S. Lakes:
2013-1925. Environmental Data Initiative.
<http://dx.doi.org/10.6073/pasta/fb4f5687339bec467ce0ed1ea0b5f0ca>.
Dataset accessed 9/26/2017.
