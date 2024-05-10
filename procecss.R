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
  dat <- unique(dat[, .(lat=round(min(lat),3), lon=round(min(lon),3), 
    feet=round(min(feet)), km=round(min(km),2), 
    meters=round(min(meters))), by=miles])

  return(dat[, .(lat, lon, miles, km, feet=round(feet), meters=round(meters), event=event_name)])
}

ac <- process_gpx("/Users/johnsugden/Downloads/7th_AC100_3rd_place_.gpx", 101.2, event_name="Angeles Crest 100")
at <- process_gpx("/Users/johnsugden/Downloads/AT100.gpx", 100, event_name="Arkansas Traveler 100")
bandera <- process_gpx("/Users/johnsugden/Downloads/Bandera_2023.gpx", 62, event_name="Bandera 100K")
bc <- process_gpx("/Users/johnsugden/Downloads/Bryce_Canyon_100.gpx", 100, event_name="Bryce Canyon 100")
bear <- process_gpx("/Users/johnsugden/Downloads/Bear_100_.gpx", 100, event_name="The Bear 100")
bighorn <- process_gpx("/Users/johnsugden/Downloads/Bighorn_100.gpx", 100, event_name="Bighorn 100")
boston <- process_gpx("/Users/johnsugden/Downloads/2024_Boston_Marathon.gpx", rescale=26.2, event_name="Boston Marathon")
can <- process_gpx("/Users/johnsugden/Downloads/CANYONLANDS_100.gpx", 100, event_name="Canyonlands 100")
canyons <- process_gpx("/Users/johnsugden/Downloads/Canyons_100_M_.gpx", 100, event_name="Canyons 100")
cc <- process_gpx("/Users/johnsugden/Downloads/Cascade_Crest_1st_overall_.gpx", 100, event_name="Cascade Crest 100")
cj <- process_gpx("/Users/johnsugden/Downloads/Cruel_Jewel_100.gpx", 105.9, event_name="Cruel Jewel")
dp <- process_gpx("/Users/johnsugden/Downloads/DC_Peaks_50_.gpx", 50, event_name="DC Peaks 50")
es <- process_gpx("/Users/johnsugden/Downloads/Eastern_States_100_5th_Place_.gpx", 100, event_name="Eastern States")
grindstone <- process_gpx("/Users/johnsugden/Downloads/Grindstone_100_miler_.gpx", 100, event_name="Grindstone 100")
hardrock_cw <- process_gpx("/Users/johnsugden/Downloads/HR100-Course-Clockwise.gpx", 100, event_name="Hardrock CW")
hb <- process_gpx("/Users/johnsugden/Downloads/Hellbender_2023.gpx", 100, event_name="Hellbender 100")
hl <- process_gpx("/Users/johnsugden/Downloads/Dream_come_true_sub_24_and_at_HL100.gpx", 100, event_name="High Lonesome 100")
imtuf <- process_gpx("/Users/johnsugden/Downloads/IMTUF_100.gpx", 100, event_name="IMTUF 100")
jav <- process_gpx("/Users/johnsugden/Downloads/Javelina_Jundred.gpx", 100, event_name="Javelina Jundred")
leadville <- process_gpx("/Users/johnsugden/Downloads/Leadville 100 Run.gpx", rescale=100, event_name="Leadville 100")
millwood <- process_gpx("/Users/johnsugden/Downloads/Millwood_100_FKT_ (2).gpx", 100, event_name="Millwood 100")
mm <- process_gpx("/Users/johnsugden/Downloads/Mogollon_Monster_100_FTW_.gpx", rescale=100, event_name="Mogollon Monster 100")
od <- process_gpx("/Users/johnsugden/Downloads/Old_Dominion_100.gpx", 100, event_name="Old Dominion 100")
ouray <- process_gpx("/Users/johnsugden/Downloads/Ouray_100_Mile_Endurance_Run_2023.gpx", 100, event_name="Ouray 100")
rrr <- process_gpx("/Users/johnsugden/Downloads/Run_Rabbit_Run_1st_Place_Tortoise.gpx", 100, event_name="Run Rabbit Run 100")
scout <- process_gpx("/Users/johnsugden/Downloads/Mix_103_69_FM.gpx", 100, smoothing_factor=0.025, event_name="Scout Mountain 100")
sp <- process_gpx("/Users/johnsugden/Downloads/SP50.gpx", 50, event_name="Snow Peaks 50")
tushars <- process_gpx("/Users/johnsugden/Downloads/Tushars_100k_.gpx", 62, smoothing_factor=0.025, event_name="Tushars 100K")
utmb <- process_gpx("/Users/johnsugden/Downloads/UTMB_2023.gpx", 106, smoothing_factor=0.025, event_name="UTMB")
vermont <- process_gpx("/Users/johnsugden/Downloads/VT_.gpx", 100, smoothing_factor=0.025, event_name="Vermont 100")
wasatch <- process_gpx("/Users/johnsugden/2022-Course-and-Points-and-Elevation-5Sept22_GPX.gpx", 100, vert_units="feet", event_name="Wasatch 100")
ws <- process_gpx("/Users/johnsugden/Downloads/WESTERN_STATES_100_.gpx", 100, smoothing_factor=0.025, event_name="Wyoming Range 100")
wy <- process_gpx("/Users/johnsugden/Downloads/Wyoming_Range_100.gpx", 100, smoothing_factor=0.025, event_name="Western States")
zion <- process_gpx("/Users/johnsugden/Downloads/Zion_100_Miler_6th_place.gpx", 100, event_name="Zion 100")
#ggplot(jav, aes(x=miles, y=feet)) + geom_line() + theme_minimal()
bigfoot200 <- process_gpx("/Users/johnsugden/Downloads/Bigfoot_200.gpx", 200, event_name="Bigfoot 200")
tahoe200 <- process_gpx("/Users/johnsugden/Downloads/Tahoe_200.gpx", 200, event_name="Tahoo 200")
moab240 <- process_gpx("/Users/johnsugden/Downloads/Moab_240.gpx", 240, event_name="Moab 240")
coco250 <- process_gpx("/Users/johnsugden/Downloads/Cocodona_250.gpx", 250, event_name="Cocodona 250")

extract <- data.table(
  dplyr::bind_rows(
    ac, at, bandera, bc, bear, 
    bighorn, boston, can, canyons, cc, 
    cj, dp, es, grindstone, hardrock_cw, 
    hb, hl, imtuf, jav, leadville, 
    millwood, mm, od, ouray, rrr, 
    scout, sp, tushars, utmb, vermont, 
    wasatch, wy, ws, zion, 
    bigfoot200, coco250, moab240, tahoe200))
write.csv(extract, "races.csv", row.names=F)
extract[, .N, by=event]
