library(LAGOSUSgis)
llid <- 34352

res_iws  <- query_gis("ws", "lagoslakeid", llid)
res_lake <- query_gis("LAGOS_US_All_Lakes_1ha", "lagoslakeid", llid)
res_pnt  <- query_gis("LAGOS_US_All_Lakes_1ha_POINTS", "lagoslakeid", llid)

gis_34352 <- list(res_iws = res_iws, res_lake = res_lake, res_pnt = res_pnt)
use_data(gis_34352, overwrite = TRUE)
