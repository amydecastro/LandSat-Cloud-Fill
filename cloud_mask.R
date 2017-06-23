# Author: Amy DeCastro  
# Date : June 2017

##CLOUD MASKING##
### creates two masked collections (same scene location, different dates)

library(raster)

## grab layers for bands 1,2,3,4,5,7 from the first scene by first subsetting to only the .tif files for the scene, 
## then stacking just those bands

LS5_035_035_2008_09_10 <- list.files("/Users/amsh3926/Desktop/subset/LT050350352008091001T1-SC20170526100718", 
                                     pattern = glob2rx("*band*.tif$"), full.names = T) 
# subset and stack bands 1,2,3,4,5,7
LS5_035_035_2008_09_10 <- stack(LS5_035_035_2008_09_10[5:10])


## repeat for the second date
LS5_035_035_2008_09_26 <- list.files("/Users/amsh3926/Desktop/subset/LT050350352008092601T1-SC20170526091605", 
                                     pattern = glob2rx("*band*.tif$"), full.names = T) 

LS5_035_035_2008_09_26 <- stack(LS5_035_035_2008_09_26[5:10])


## crop because extents may not be the same
LS5_035_035_2008_09_10 <- crop(LS5_035_035_2008_09_10, LS5_035_035_2008_09_26)
LS5_035_035_2008_09_26 <- crop(LS5_035_035_2008_09_26, LS5_035_035_2008_09_10)

# grab the cloud_qa file for the first date

qa1 <- list.files("/Users/amsh3926/Desktop/subset/LT050350352008091001T1-SC20170526100718", 
                  pattern = glob2rx("*_qa*.tif$"), full.names = T) 

cloud_qa1 <- stack(qa1[3]) #may need to check that cloud_qa file is third -R does not read them in order

## crop this extent as well
cloud_qa1 <- crop(cloud_qa1, LS5_035_035_2008_09_26)

## repeat for the second date
qa2 <- list.files("/Users/amsh3926/Desktop/subset/LT050350352008092601T1-SC20170526091605", 
                  pattern = glob2rx("*_qa*.tif$"), full.names = T) 

cloud_qa2 <- stack(qa2[3])

cloud_qa2 <- crop(cloud_qa2, LS5_035_035_2008_09_26)


## create cloud mask

# set all values in layer that are not "fill" (meaning clear landcover) to NA
cloud_qa1[cloud_qa1 > 0] <- NA
cloud_qa2[cloud_qa2 > 0] <- NA

## mask each scene
date1_mask <- mask(LS5_035_035_2008_09_10, mask = cloud_qa1)
date2_mask <- mask(LS5_035_035_2008_09_26, mask = cloud_qa2)



