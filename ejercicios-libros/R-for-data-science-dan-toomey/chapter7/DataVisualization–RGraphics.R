#Chapter 7: Data Visualization - R Graphics

#Interactive graphics
install.packages("playwith")
library("playwith")

url <- "https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-white.csv"
data <- read.csv(url, sep=";")

plot(data$fixed.acidity)

playwith(plot(data$fixed.acidity))

#The latticist package
install.packages("latticist")
library(latticist)

latticist(data$fixed.acidity)

#Bivariate binning display
install.packages("hexbin")
library(hexbin)

data <- read.csv("http://faculty.washington.edu/kenrice/sisg-adv/airportlocations.csv")
summary(data)

bin <- hexbin(data$Latitude,data$Longitude)
summary(bin)
plot(bin)

#Mapping
install.packages("mapdata")
library(mapdata)

map(database="usa", col="gray90", fill=TRUE)

#Plotting points on a map
install.packages("maptools")
install.packages("classInt")
setwd("D:/Google Drive/projects/R-for-data-science-dan-toomey/chapter7")
install.packages("gpclib_1.5-5.tar.gz", repos = NULL, type = "source")

library(maps)
library(maptools)
library(RColorBrewer)
library(classInt)
library(gpclib)
library(mapdata)

#Plotting points on a world map
map("worldHires")
points(data$Longitude,data$Latitude,pch=16,col="red",cex=1)
require(graphics)

#earthquakes
head(quakes)
mean(quakes$mag)

map()
points(quakes$long,quakes$lat,pch=".",col="red",cex=1)

lon <- mean(quakes$lon)
lat <- mean(quakes$lat)
orient <- c(lat,lon,0)
x <- c(min(quakes$lon)/2,max(quakes$lon)*1.5)
y <- c(min(quakes$lat)-10,max(quakes$lat)+10)
map(database= "world", ylim=y, xlim=x, col="grey80", fill=TRUE)
points(quakes$long,quakes$lat,pch=".",col="red",cex=quakes$mag/2)

#Google Maps
install.packages("RgoogleMaps")
library(RgoogleMaps)
terrain <- GetMap(center=c(lat,lon),zoom=5,maptype="terrain",destfile="terrain.png")

markers <- cbind.data.frame(quakes$lat,quakes$long,"small","red","")
names(markers) <- c("lat","lon","size","col","char")

terrain <- GetMap.bbox(center=c(lat,lon),zoom=5,maptype="terrain",
            destfile="terrain2.png",lonR=range(quakes$long),latR=range(quakes$lat),markers=markers)

#The ggplot2 package
install.packages("ggplot2")
library(ggplot2)

qplot(lat,long,data=quakes,color=mag)
qplot(lat,long,data=quakes,color=mag,size=depth)
qplot(lat,long,data=quakes,color=mag,size=depth, alpha=0.5)

qplot(height,weight,data=women,geom="line")

install.packages("MASS")
library(MASS)
qplot(School,data=painters,geom="bar")

data <- read.csv(url, sep=";")
ggplot(data, aes(x=residual.sugar, y=alcohol))

sa <- ggplot(data, aes(x=residual.sugar, y=alcohol))
sa <- sa + geom_line()
sa
sa + facet_grid(. ~ quality)

sa + facet_grid(quality ~ .)

sa <- ggplot(data, aes(x=residual.sugar, y=alcohol))
sa <- sa + geom_line()
sa <- sa + geom_smooth()
sa

ggplot(data, aes(x=residual.sugar)) + geom_histogram(binwidth=.5)

#density graph
ggplot(data, aes(x=residual.sugar)) + geom_density()

#boxplot
bp <- ggplot(data, aes(x=residual.sugar, y=alcohol))
bp <- bp + geom_boxplot()
bp + facet_grid(. ~ quality)



