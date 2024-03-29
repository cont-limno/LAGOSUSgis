% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query.R
\name{query_gis_}
\alias{query_gis_}
\title{Raw (non-vectorized) query of LAGOS GIS}
\usage{
query_gis_(
  gis_path = lagosusgis_path(),
  query,
  extent = character(0),
  crs = albers_conic()
)
}
\arguments{
\item{gis_path}{file path}

\item{query}{SQL string}

\item{extent}{apply an arbitrary extent using an sf bbox}

\item{crs}{coordinate reference system string or epsg code}
}
\description{
Raw (non-vectorized) query of LAGOS GIS
}
\examples{
\dontrun{
res <- query_gis_(query = "SELECT * FROM ws WHERE lagoslakeid IN ('7010')")

# query nested hucs
hu4  <- query_gis("hu4", "hu4_huc4", c("0415"))
hu8s <- query_gis_(query = "SELECT * FROM hu8 WHERE hu8_huc8 LIKE '0415\%'")

# query multiple nested hucs
hu4s  <- query_gis("hu4", "hu4_huc4", c("0415", "0414"))
hu8s  <- query_gis_(query = paste0("SELECT * FROM hu8 WHERE ",
  paste0("hu8_huc8 LIKE '", hu4s$hu4_huc4, "\%'", collapse = " OR ")))

# query lake polygon from coordinates using extent argument
lake_coordinates <- query_gis("LAGOS_US_All_Lakes_1ha_points",
  "lagoslakeid", "1")
lake_polygon <- query_gis_(query = "SELECT * FROM LAGOS_US_All_Lakes_1ha",
  extent = sf::st_bbox(lake_coordinates))
}

}
