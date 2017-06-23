# Author: Carson Farmer
# Date :  May 2017
# Version 0.1
# Licence GPL v3


AmysVersion <- function(x, y) {
  # Note, we don't do ANY checks... so be careful!
	rasters <- raster:::.makeRasterList(x, y, unstack=FALSE)
	nl <- sapply(rasters, nlayers)
	un <- unique(nl)
	outRaster <- brick(x, values=FALSE)

	format <- 'raster'
	overwrite <- raster:::.overwrite()
	progress <- raster:::.progress()
	datatype <- unique(dataType(x))

	filename <- rasterTmpFile()
	outRaster <- writeStart(outRaster, filename=filename,
	                        format=format, datatype=datatype,
	                        overwrite=overwrite)

	tr <- blockSize(outRaster, sum(nl))
	pb <- pbCreate(tr$n, label='cover', progress=progress)
	for (i in 1:tr$n) {
		v <- getValues( rasters[[1]], row=tr$row[i], nrows=tr$nrows[i] )
		v2 <- v
		for (j in 2:length(rasters)) {
			v2[] <- getValues(rasters[[j]], row=tr$row[i], nrows=tr$nrows[i])
			v[is.na(v)] <- v2[is.na(v)]
		}
		outRaster <- writeValues(outRaster, v, tr$row[i])
		pbStep(pb, i)
	}
	pbClose(pb)
	outRaster <- writeStop(outRaster)
	return(outRaster)
}

