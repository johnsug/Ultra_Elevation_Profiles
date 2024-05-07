library(data.table)
library(ggplot2)
library(XML)

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
  dat <- unique(dat[, .(lat=round(min(lat),3), lon=round(min(lon),3), feet=min(feet), km=min(km), meters=min(meters)), by=miles])

  return(dat[, .(lat, lon, miles, km, feet, meters, event=event_name)])
}

ac <- process_gpx("/Users/johnsugden/Downloads/7th_AC100_3rd_place_.gpx", 101.2, event_name="Angeles Crest 100")
bear <- process_gpx("/Users/johnsugden/Downloads/Bear_100_.gpx", 100, event_name="The Bear 100")
bighorn <- process_gpx("/Users/johnsugden/Downloads/Bighorn_100.gpx", 100, event_name="Bighorn 100")
boston <- process_gpx("/Users/johnsugden/Downloads/2024_Boston_Marathon.gpx", rescale=26.2, event_name="Boston Marathon")
canyons <- process_gpx("/Users/johnsugden/Downloads/Canyons_100_M_.gpx", 100, event_name="Canyons 100")
cc <- process_gpx("/Users/johnsugden/Downloads/Cascade_Crest_1st_overall_.gpx", 100, event_name="Cascade Crest 100")
es <- process_gpx("/Users/johnsugden/Downloads/Eastern_States_100_5th_Place_.gpx", 100, event_name="Eastern States")
grindstone <- process_gpx("/Users/johnsugden/Downloads/Grindstone_100_miler_.gpx", 100, event_name="Grindstone 100")
hardrock_cw <- process_gpx("/Users/johnsugden/Downloads/HR100-Course-Clockwise.gpx", 100, event_name="Hardrock CW")
imtuf <- process_gpx("/Users/johnsugden/Downloads/IMTUF_100.gpx", 100, event_name="IMTUF 100")
jav <- process_gpx("/Users/johnsugden/Downloads/Javelina_Jundred.gpx", 100, event_name="Javelina Jundred")
leadville <- process_gpx("/Users/johnsugden/Downloads/Leadville 100 Run.gpx", rescale=100, event_name="Leadville 100")
mm <- process_gpx("/Users/johnsugden/Downloads/Mogollon_Monster_100_FTW_.gpx", rescale=100, event_name="Mogollon Monster 100")
od <- process_gpx("/Users/johnsugden/Downloads/Old_Dominion_100.gpx", 100, event_name="Old Dominion 100")
ouray <- process_gpx("/Users/johnsugden/Downloads/Ouray_100_Mile_Endurance_Run_2023.gpx", 100, event_name="Ouray 100")
scout <- process_gpx("/Users/johnsugden/Downloads/Mix_103_69_FM.gpx", 100, smoothing_factor=0.025, event_name="Scout Mountain 100")
tushars <- process_gpx("/Users/johnsugden/Downloads/Tushars_100k_.gpx", 62, smoothing_factor=0.025, event_name="Tushars 100K")
utmb <- process_gpx("/Users/johnsugden/Downloads/UTMB_2023.gpx", 106, smoothing_factor=0.025, event_name="UTMB")
vermont <- process_gpx("/Users/johnsugden/Downloads/VT_.gpx", 100, smoothing_factor=0.025, event_name="Vermont 100")
wasatch <- process_gpx("/Users/johnsugden/2022-Course-and-Points-and-Elevation-5Sept22_GPX.gpx", 100, vert_units="feet", event_name="Wasatch 100")
ws <- process_gpx("/Users/johnsugden/Downloads/WESTERN_STATES_100_.gpx", 100, smoothing_factor=0.025, event_name="Wyoming Range 100")
wy <- process_gpx("/Users/johnsugden/Downloads/Wyoming_Range_100.gpx", 100, smoothing_factor=0.025, event_name="Western States")
#ggplot(jav, aes(x=miles, y=feet)) + geom_line() + theme_minimal()

extract <- data.table(dplyr::bind_rows(ac, bear, bighorn, boston, canyons,
                                       cc, es, grindstone, hardrock_cw, imtuf, 
                                       jav, leadville, mm, od, ouray, scout, 
                                       utmb, vermont, wasatch, wy, ws))
write.csv(extract, "races.csv", row.names=F)
extract[, .N, by=event]

