library(data.table)
library(ggplot2)
library(XML)

## https://appsilon.com/r-gpx-files/
process_gpx <- function(gpx_file, rescale=NULL, vert_units="feet"){

  ## read in
  dat <- htmlTreeParse(file=gpx_file, useInternalNodes=TRUE)

  ## parse
  wpt <- xpathSApply(doc=dat, path="//wpt", fun=xmlAttrs)
  wptn <- xpathSApply(doc=dat, path="//wpt/name", fun=xmlValue)
  coords <- xpathSApply(doc=dat, path="//trkpt", fun=xmlAttrs)
  vert <- xpathSApply(doc=dat, path="//trkpt/ele", fun=xmlValue)

  ## convert
  dat <- data.table(
    lat = as.numeric(coords["lat", ]),
    lon = as.numeric(coords["lon", ]),
    vert = as.numeric(vert)) ## already in feet

  ## find distance
  dat[, lat2:=shift(lat,1)]
  dat[, lon2:=shift(lon,1)]
  dat[, dist2:=distHaversine(matrix(c(lon, lat), ncol=2), matrix(c(lon2, lat2), ncol=2), 6378137*0.000621371)] ## default in m; 6378137*0.000621371 converts to miles
  dat[is.na(dist2), dist2:=0]
  dat[, dist2:=cumsum(dist2)]
  ## scale to exact mileage, if indicator is present
  if(length(rescale)>0)
    dat[, dist:=dist2*rescale/max(dat$dist2)]  
  else 
    dat[, dist:=dist2]
  dat[, c("lat2", "lon2", "dist2"):=NULL]
  ## convert feet to meters
  if(vert_units=="meters"){
    dat$vert <- dat$vert * 3.28084
  }

  return(dat)
}

wasatch <- process_gpx("gpx_files/2022-Course-and-Points-and-Elevation-5Sept22_GPX.gpx", rescale=100)
boston <- process_gpx("gpx_files/2024_Boston_Marathon.gpx", rescale=26.2)
leadville <- process_gpx("gpx_files/Leadville 100 Run.gpx", rescale=100, vert_units="meters")
ws <- process_gpx("gpx_files/WESTERN_STATES_100_.gpx", 100)
utmb <- process_gpx("gpx_files/UTMB_2023.gpx", 106)
hardrock_cw <- process_gpx("gpx_files/HR100-Course-Clockwise.gpx", 100)
jav <- process_gpx("gpx_files/Javelina_Jundred.gpx", 100)

wasatch$event <- "Wasatch 100"
boston$event <- "Boston Marathon"
leadville$event <- "Leadville 100"
ws$event <- "Western States"
utmb$event <- "UTMB"
hardrock_cw$event <- "Hardrock CW"
jav$event <- "Javelina Jundred"

extract <- data.table(dplyr::bind_rows(wasatch, 
                                       boston, 
                                       leadville, 
                                       ws, 
                                       utmb, 
                                       hardrock_cw, 
                                       jav))
write.csv(extract, "races.csv", row.names=F)
