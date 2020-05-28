
# Author: Fergus Reig Gracia <http://fergusreig.es/>; Environmental Hydrology, Climate and Human Activity Interactions, Geoenvironmental Processes, IPE, CSIC <http://www.ipe.csic.es/hidrologia-ambiental/>
# Version: 1.0

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/> <http://www.gnu.org/licenses/gpl.txt/>.
#####################################################################

library(raster)
library(ncdf4)
library(rworldmap)
library(chron)
library(ncwebmapper)

nc_route <- "../viewer/nc"
out_route <- "../viewer/maps"
ncFile <- "NDVI_corregido_GIMMS.nc"
crs30 <- CRS("+proj=utm +zone=30 +ellps=intl +units=m +no_defs") #http://spatialreference.org/ref/epsg/ed50-utm-zone-30n/ "epsg:23030"
world = getMap()
world <- spTransform(world, crs30)


ncDates <- function(){
  start <- chron("7/1/1981")
  datesMonths <- seq(from = start, by="month", length=length(ndvitime)/2)
  dates <- array(NA, dim=c(length(datesMonths)*2)) # 1, 15
  dates[c(1:length(dates)%%2)==1] <- datesMonths
  dates[c(1:length(dates)%%2)==0] <- datesMonths+14
  return(dates)
}

ndvinc <- nc_open("../viewer/nc/NDVI_corregido_GIMMS.nc")
ndvilon <- ncvar_get(ndvinc, "lon")
ndvilat <- ncvar_get(ndvinc, "lat")
ndvitime <- ncvar_get(ndvinc, "time")
ndvidata <- ncvar_get(ndvinc, "NDVI", c(1, 1, 400), c(-1, -1, 1))

nc_close(ndvinc)

datos <- expand.grid(ndvilat, ndvilon)
colnames(datos) =  c('Latitud', 'Longitud')
coordinates(datos) <- c('Longitud', 'Latitud')
proj4string(datos) <- crs30

dates = ncDates()
dates = as.character(as.Date(dates, origin="1970-01-01"))

file <- file.path(nc_route, ncFile)
epsg <- "23030"
zoom <- 5
varmin <- -1
varmax <- 1
infoJs <- NA
folder <- "../viewer"
legend <- "NaN"
write <- TRUE
varTitle <- "varTitle"
title <- "Spain NDVI"
legendTitle <- "legendTitle"
index_tipes <- "index_tipes"
varNames <- "varNames"
menuNames <- "menuNames"

write_csv(file = file, folder = out_route, epsg = epsg, dates = dates)
write_csv_layer(file = file, folder = out_route, epsg = epsg, zoom = zoom)
write_data_layer(file = file, folder = out_route, epsg = epsg, maxzoom = zoom)
infoJs = config_web(file = file, folder = folder, infoJs = infoJs, maxzoom = zoom, epsg = epsg, dates = dates, varmin = varmin, varmax = varmax, legend = legend, write = write)
writeJs(folder = folder, infoJs = infoJs, varNames = varNames, varTitle = varTitle, menuNames = menuNames, title=title)
