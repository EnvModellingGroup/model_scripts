suppressPackageStartupMessages(require(TCHazaRds))   # this package :)
suppressPackageStartupMessages(require(terra))       # spatial analysis
#> Warning: package 'terra' was built under R version 4.4.1
suppressPackageStartupMessages(require(rasterVis))   # enhanced raster visualization https://oscarperpinan.github.io/rastervis/
suppressPackageStartupMessages(require(sp))          # spatial methods and plotting
suppressPackageStartupMessages(require(knitr))       # formatted table
suppressPackageStartupMessages(require(raster))       # convert for raster plots
TC <- vect("~/work/projects/PalaeoTides/gbr_storms/data/ita_ibtracs.shp")
TC$PRES <- TC$BOM_PRES #different agencies each provide a PRES, you need to chose one. 
TC$STORM_SPD = TC$STORM_SPD/1.94 #provided as knots, convert to m/s
TC$thetaFm = 90-returnBearing(TC) #direction of the heading of the TC (Cartesian, clockwise from x axis)
TCi = TC[46]

paramsTable = read.csv(system.file("extdata/tuningParams/defult_params.csv",package = "TCHazaRds"))

r = rast(xmin = 142,xmax=160,ymin = -27,ymax = -9,resolution=.075)
values(r) = 0
land_v <- vect("~/work/projects/PalaeoTides/gbr_storms/data/Aus_land.shp")
land_r = rasterize(land_v,r,touches=TRUE,background=0)
inland_proximity = terra::costDist(land_r,target = 0,scale=1)
GEO_land = land_geometry(land_r,inland_proximity)


outdate = seq(strptime(TC$ISO_TIME[1],"%Y-%m-%d %H:%M:%S",tz="UTC"),
              strptime(rev(TC$ISO_TIME)[1],"%Y-%m-%d %H:%M:%S",tz="UTC"),
              1800)
HAZ = TCHazaRdsWindFields(outdate=outdate,GEO_land=GEO_land,TC=TC,paramsTable=paramsTable, outfile="test.nc", overwrite=T)
