####Extracting data from bio-oracle#########
#The data available in Bio-ORACLE are documented in two peer reviewed articles that you should cite:
  
#  Tyberghein L, Verbruggen H, Pauly K, Troupin C, Mineur F, De Clerck O (2012) Bio-ORACLE: A global environmental 
#dataset for marine species distribution modelling.  Global Ecology and Biogeography, 21, 272-281.

#Assis, J., Tyberghein, L., Bosh, S., Verbruggen, H., Serrão, E. A., & De Clerck, O. (2017). 
#Bio-ORACLE v2.0: Extending marine data layers for bioclimatic modelling. Global Ecology and Biogeography.

######### for use in Dispersal in the sea ms #################
#Robert Dunn, August 2019

#install.packages("sdmpredictors")
#install.packages("leaflet")

library(sdmpredictors)
library(leaflet)

###Example of what these packages can do############
# Explore datasets in the package
list_datasets()
# Explore layers in a dataset
list_layers()
# Download specific layers to the current directory
bathy <- load_layers(c("BO_bathymin", "BO_bathymean", "BO_bathymax"))
# Check layer statistics
layer_stats()
# Check Pearson correlation coefficient between layers
layers_correlation() 

# Easy download of raster file (Maximum Temperature at the sea bottom)
temp.max.bottom <- load_layers("BO2_tempmax_bdmax")
# Crop raster to fit the North Atlantic
ne.atlantic.ext <- extent(-100, 45, 30.75, 72.5)
temp.max.bottom.crop <- crop(temp.max.bottom, ne.atlantic.ext)
# Generate a nice color ramp and plot the map
my.colors = colorRampPalette(c("#5E85B8","#EDF0C0","#C13127"))
plot(temp.max.bottom.crop,col=my.colors(1000),axes=FALSE, box=FALSE)
title(cex.sub = 1.25, sub = "Maximum temperature at the sea bottom (ºC)") 

##Extract environmental info for a set of sites
layers.bio2 <- list_layers( datasets="Bio-ORACLE" )
layers.bio2
# Download environmental data layers (Max. Temperature, Min. Salinity and Min. Nitrates at the sea bottom)
environment.bottom <- load_layers( layercodes = c("BO2_tempmax_bdmean" , "BO2_salinitymin_bdmean", "BO2_nitratemin_bdmean") , 
                                   equalarea=FALSE, rasterstack=TRUE)
# Download bathymetry
bathymetry <- load_layers("BO_bathymean")
# Generate a data.frame with the sites of interest
my.sites <- data.frame(Name=c("Faro, Portugal, NE Atlantic" , "Maspalomas, Spain, NE Atlantic" , 
                              "Guadeloupe, France, Caribbean Sea" , "Havana, Cuba, Caribbean Sea") , 
                       Lon=c(-7.873,-15.539,-61.208,-82.537) , Lat=c(37.047, 27.794,15.957,23.040 ) )
my.sites
# Visualise sites of interest in google maps
m <- leaflet()
m <- addTiles(m)
m <- addMarkers(m, lng=my.sites$Lon, lat=my.sites$Lat, popup=my.sites$Name)
m
# Extract environmental values from layers
my.sites.environment <- data.frame(Name=my.sites$Name , depth=extract(bathymetry,my.sites[,2:3]) , extract(environment.bottom,my.sites[,2:3]) )
my.sites.environment 

##Future conditions
future <- list_layers_future(terrestrial = FALSE) 
# available scenarios 
unique(future$scenario) 
unique(future$year)
get_layers_info(c("BO_calcite","BO_B1_2100_sstmax","MS_bathy_21kya"))$common
get_future_layers(c("BO_sstmax", "BO_salinity"), scenario = "B1", year = 2100)$layer_code 

#########################################
##Actual data for Dispersal manuscript###
#########################################
##Temperature and Salinity##
#For San Diego & Lizard Island ##
sites <- data.frame(Name=c("San Diego, CA, USA, Temperate Pacific" , "Lizard Island, Australia, Tropical Pacific") , 
                       Lon=c(-117.3477,145.4736) , Lat=c(32.9501, -14.655 ) )
sites
#Visualize sites to confirm correct input
d<-leaflet()
d<-addTiles(d)
d<-addMarkers(d,lng=sites$Lon, lat=sites$Lat, popup=my.sites$Name)
d
#Now get temperature and salinity for both sites for year 2100, climate scenario = RCP6.0
get_future_layers(c("BO2_tempmean_ss", "BO2_salinitymean_ss"), scenario = "RCP60", year = 2100)$layer_code 

tempNsalin<-load_layers(layercodes=c("BO2_RCP60_2100_salinitymean_ss" ,"BO2_RCP60_2100_tempmean_ss"), #sea surface mean temp and mean salinity
                        equalarea=FALSE, rasterstack=TRUE)
bathymetry <- load_layers("BO_bathymean")#get bathymetry  ###turns out don't need this since we're using surface layers
#Now extract environmental values for those two sites
SD.Lizard.tempNsalin2100 <- data.frame(Name=sites$Name , #depth=extract(bathymetry,sites[,2:3]) , 
                                   extract(tempNsalin, sites[,2:3]) )
SD.Lizard.tempNsalin2100

##################################
###Oxygen projection for 2100?###
get_future_layers(c("BO2_dissoxmean_ss"),  scenario= , year=2100)$layer_code
#No future layer for dissolved o2
