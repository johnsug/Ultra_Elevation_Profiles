library(data.table)
library(ggplot2)
library(XML)
library(geosphere)

process_gpx <- function(gpx_file, rescale=NULL, vert_units="meters", smoothing_factor=0.025, event_name=""){

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

  ## smooth vert
  dat[, vert:=round(modelbased::smoothing(vert, method = "loess", strength = smoothing_factor),1)]

  ## miles
  dat[, miles:=round(dist,1)]

  ## feet
  if(vert_units=="feet"){
    dat[, feet:=round(vert)]
  }
  if(vert_units=="meters"){
    dat[, feet:=vert*3.28084]
  }

  ## km and meters
  dat[, km:=miles*1.60934]
  dat[, meters:=feet*3.28084]

  ## reduce
  dat <- unique(dat[, .(lat=round(min(lat),3), lon=round(min(lon),3), 
                        feet=round(min(feet)), km=round(min(km),2), 
                        meters=round(min(meters))), by=miles])

  return(dat[, .(lat, lon, miles, km, feet=round(feet), meters=round(meters), event=event_name)])
}

tushars <- process_gpx("/gpx_files/Tushars_100k_.gpx", 62, smoothing_factor=0.025, event_name="Tushars 100K")
tushars24 <- process_gpx("/gpx_files/2024_Tushars_100K.gpx", 63, smoothing_factor=0.025, event_name="Tushars 2024")
ccc <- process_gpx("/gpx_files/CCC_100k_2024_.gpx", 62, smoothing_factor=0.025, event_name="CCC")

events <- rbind(tushars24, ccc) ## tushars
events[, .(avg=round(mean(feet))), by=event]

## plot
ggplot(events, aes(x=miles, y=feet, color=event)) + 
  geom_line(linewidth=2) + 
  theme_minimal() + 
  geom_hline(yintercept=mean(ccc$feet), color="#00bbf9", linetype="dotted") + 
  geom_text(aes(x=55, y=mean(ccc$feet)+1000, 
                label=paste("avg:", prettyNum(round(mean(ccc$feet)), big.mark=","), "ft")), color="#00bbf9") + 
  geom_hline(yintercept=mean(tushars24$feet), color="#ee9b00", linetype="dotted", color="#00bbf9") + 
  geom_text(aes(x=55, y=mean(tushars24$feet)+1200, 
                label=paste("avg:", prettyNum(round(mean(tushars24$feet)), big.mark=","), "ft")), color="#ee9b00") + 
  scale_color_manual(values = c("#00bbf9", "#ee9b00")) + 
  scale_y_continuous(label=scales::comma, limits=c(0, max(tushars$feet))) + 
  labs(x="Distance", y="Elevation", color="Event") + 
  theme(legend.position="top")


