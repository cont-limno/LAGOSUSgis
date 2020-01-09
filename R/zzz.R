.onLoad <- function(lib, pkg){
  if(!has_7z()$yes){
    warning("The 7-zip program is needed to unpack NHD downloads (http://www.7-zip.org/).")
  }
}

.onLoad <- function(pkgname, libname) {
  query_wbd  <<- memoise::memoise(query_wbd)
  query_gis  <<- memoise::memoise(query_gis)
  query_gis_ <<- memoise::memoise(query_gis_)
}
