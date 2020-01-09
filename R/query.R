#' Query LAGOS GIS
#'
#' @param layer character layer name
#' @param id_name selection column
#' @param ids feature ids to select
#' @param crs character projection info defaults to lagosusgis_path()
#' @param gis_path character path to LAGOSUS GIS gpkg
#'
#' @importFrom sf st_geometry st_geometry_type st_cast
#' @importFrom memoise memoise
#' @export
#'
#' @examples \dontrun{
#'
#' library(sf)
#' st_layers(lagosusgis_path())
#'
#' library(gdalUtils)
#' ogrinfo(lagosusgis_path(), "hu12", so = TRUE)
#'
#' states   <- query_gis("state")
#'
#' library(mapview)
#' state    <- query_gis("state", "state_name", "Michigan")
#' res_iws  <- query_gis("ws", "lagoslakeid", c(34352))
#' res_lake <- query_gis("LAGOS_US_All_Lakes_1ha", "lagoslakeid", 34352)
#' res_pnt  <- query_gis("LAGOS_US_All_Lakes_1ha_points", "lagoslakeid", 34352)
#' mapview(state) + mapview(res_iws) + mapview(res_lake) + mapview(res_pnt)
#'
#' res <- query_gis("ws", "lagoslakeid", c(7010))
#' res <- query_gis("hu12", "hu12_zoneid", c("hu12_1"))
#' res <- query_gis("hu8", "hu8_zoneid", c("hu8_100"))
#' res <- query_gis("hu4", "hu4_zoneid", c("hu4_5"))
#'
#' # query multiple feature ids
#' res <- query_gis("ws", "lagoslakeid", c(7010, 1))
#' }
query_gis <- function(layer, id_name = NULL, ids = NULL,
                                       crs = albers_conic(),
                                       gis_path = lagosusgis_path()){

  if(all(is.null(id_name), is.null(ids))){
    res <- sf::st_read(gis_path, layer = layer)
  }else{
    res <- query_gis_(gis_path,
               query = paste0("SELECT * FROM ", layer,
                              " WHERE ", id_name, " IN ('",
                              paste0(ids,
                                     collapse = "', '"), "')"), crs = crs)

    # sort items by ids
    res <- res[match(ids, data.frame(res[,id_name])[,id_name]),]
  }

  if(any(unique(sf::st_geometry_type(sf::st_geometry(res))) == "MULTISURFACE")){
    res <- sf::st_cast(res, "MULTIPOLYGON")
  }

  res
}

#' Raw (non-vectorized) query of LAGOS GIS
#'
#' @param gis_path file path
#' @param query SQL string
#' @param crs coordinate reference system string or epsg code
#'
#' @importFrom vapour vapour_read_geometry_text vapour_read_attributes
#' @importFrom dplyr mutate select
#' @importFrom sf st_as_sfc st_crs st_geometry st_zm
#' @importFrom rlang .data
#'
#' @export
#'
#' @examples \dontrun{
#' res <- query_gis_(query = "SELECT * FROM IWS WHERE lagoslakeid IN ('7010');")
#'
#' # query nested hucs
#' hu4  <- query_gis("HU4", "ZoneID", c("HU4_5"))
#' hu8s <- query_gis_(query = "SELECT * FROM HU8 WHERE HUC8 LIKE '0415%';")
#'
#' # query multiple nested hucs
#' hu4s  <- query_gis("HU4", "ZoneID", c("HU4_5", "HU4_6"))
#' hu8s  <- query_gis_(query = paste0("SELECT * FROM HU8 WHERE ",
#'             paste0("HUC8 LIKE '", hu4s$HUC4, "%'", collapse = " OR ")))
#' }
#'
query_gis_ <- function(gis_path = lagosusgis_path(), query, crs = albers_conic()){

  # error if extent is not NA and query is defined?

  # investigate specific layers
  # library(sf)
  # library(vapour)
  # crs <- LAGOSUSgis:::albers_conic()
  # gis_path <- "/home/jose/.local/share/LAGOS-GIS/lagos-ne_gis.gpkg"
  # st_layers(gis_path)
  # query <- "SELECT * FROM HU4 LIMIT 1"
  # as.data.frame(vapour_read_attributes(gis_path, sql = query),
  #                      stringsAsFactors = FALSE)

  # investigate extent argument
  # e <- as.numeric(st_bbox(dat))[c(1, 3, 2, 4)]
  # wkt <- vapour_read_geometry_text(gis_path, extent = e, sql = "SELECT * FROM IWS")
  # need to be able to set extent on vapour_read_attributes

  ###
  dat <- as.data.frame(vapour_read_attributes(gis_path, sql = query),
                       stringsAsFactors = FALSE)
  dat <- dplyr::mutate(dat,
                         wkt = vapour_read_geometry_text(gis_path,
                                                       sql = query, textformat = "wkt"))
  sf::st_geometry(dat) <- sf::st_as_sfc(dat$wkt)
  dat                  <- dplyr::select(dat, -.data$wkt)
  sf::st_crs(dat)      <- sf::st_crs(crs)

  if(any(unique(sf::st_geometry_type(sf::st_geometry(dat))) == "MULTISURFACE")){
    dat <- sf::st_cast(dat, "MULTIPOLYGON")
  }

  sf::st_zm(dat)
}

#' Query watershed boundary for LAGOS lakes
#'
#' @param lagoslakeid numeric
#' @param gis_path file.path to LAGOSUS GIS gpkg
#' @param crs projection string or epsg code
#' @param utm logical convert crs to utm
#'
#' @importFrom sf st_union st_geometry<- st_crs<- st_buffer
#' @importFrom memoise memoise
#' @export
#' @examples \dontrun{
#' library(mapview)
#' res <- query_wbd(lagoslakeid = c(7010))
#' res <- query_wbd(lagoslakeid = c(7010, 34352))
#' res <- query_wbd(lagoslakeid = c(34352))
#' mapview(res)
#'
#' res <- query_wbd(lagoslakeid = c(2057, 3866, 1500, 3386, 2226,
#' 1637, 6874, 7032, 1935, 6970, 5331, 34352))
#' res <- res[res$lagoslakeid == 34352,]
#' mapview::mapview(res)
#'
#' }
query_wbd <- function(lagoslakeid, gis_path = lagosusgis_path(),
                      crs = albers_conic(), utm = FALSE){

  iws           <- query_gis("ws", "lagoslakeid", lagoslakeid)
  lake_boundary <- query_gis("LAGOS_US_All_Lakes_1ha", "lagoslakeid", lagoslakeid)

  res <- lapply(seq_len(nrow(iws)), function(x) {
          iws_dissolve  <- st_buffer(do.call(c, st_geometry(iws)[x]), 0)
          lake_dissolve <- st_buffer(do.call(c, st_geometry(lake_boundary)[x]), 0.001)

          st_geometry(st_union(iws_dissolve, lake_dissolve))
          })

  res <- do.call(c, res)
  st_crs(res) <- crs
  st_geometry(iws) <- res

  if(utm){
    toUTM(iws)
  }else{
    iws
  }
}

#' Query polygon outline for LAGOS lakes
#'
#' @param lagoslakeid numeric
#' @param gis_path file.path to LAGOSUS GIS gpkg
#' @param crs projection string or epsg code
#' @param utm logical convert crs to utm
#'
#' @export
#'
#' @examples \dontrun{
#' res <- query_lake_poly(c(474805, 474803))
#' }
query_lake_poly <- function(lagoslakeid, gis_path = lagosusgis_path(),
                      crs = albers_conic(), utm = FALSE){

  res <- query_gis("LAGOS_US_All_Lakes_1ha", "lagoslakeid", lagoslakeid)

  if(utm){
    toUTM(res)
  }else{
    res
  }
}
