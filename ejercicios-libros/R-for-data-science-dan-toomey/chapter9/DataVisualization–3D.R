#Chapter 9: Data Visualization - 3D

install.packages(c("car", "copula", "lattice", "rgl", "vrmlgen", "Rcpp", "swirl"))
library(car)
library(copula)
library(lattice)
library(rgl)
library(vrmlgen)
library(Rcpp)
library(swirl)

#Generating 3D graphics
example("persp")

gc <- gumbelCopula(1.5, dim=2)
persp(gc, dCopula, col="red")

summary(women)
fun <- function(x,y) {x * y}
persp(x=women$height, y=women$weight, z=outer(women$height,women$weight,fun))

#Lattice Cloud - 3D scatterplot
mydata <- read.table("https://archive.ics.uci.edu/ml/machine-learning-databases/auto-mpg/auto-mpg.data")

colnames(mydata) <- c("mpg","cylinders","displacement","horsepower",
                      "weight","acceleration","model.year","origin","car.name")

cloud(mpg~cylinders*weight, data=mydata)

#scatterplot3d
install.packages("scatterplot3d")
library(scatterplot3d)

scatterplot3d(mydata$mpg~mydata$cylinders*mydata$weight)

#scatter3d
plot3d(mydata$mpg~mydata$cylinders*mydata$weight)
#rgl.snapshot("0860OS_9_8.png")

#cloud3d
cloud3d(mydata$mpg~mydata$cylinders*mydata$weight,filename="out.wrl")

#RgoogleMaps
size <- "small"
col <- "red"
char <- ""
library(RgoogleMaps)
lat <- c(44.26,44.28)
lon <- c(-71.2,-71.4)
mymarkers <- cbind.data.frame(lat, lon, size, col, char)
terrain_close <- GetMap.bbox(lonR= range(lon), latR= range(lat),
                               destfile= "terrclose.png", markers= mymarkers, zoom=13,
                               maptype="hybrid")


#vrmlgenbar3D
data("uk_topo")
bar3d(uk_topo, autoscale = FALSE, cols = "blue", space = 0, 
      showaxis = FALSE, filename = "example6.wrl", htmlout = "example6.html")


#Big Data

#pbdR
#Distribute data across nodes

install.packages("pbdDEMO")
library(pbdDEMO)

N.gbd <- 5 * (comm.rank() * 2)
X.gbd <- rnorm(N.gbd * 3)
dim(X.gbd) <- c(N.gbd, 3)

bal.info <- balance.info(X.gbd)

new.X.gbd <- load.balance(X.gbd, bal.info)

org.X.gbd <- unload.balance(new.X.gbd, bal.info)

#Distribute a matrix across nodes

#bigmemory
install.packages("bigmemory")
library(bigmemory)
x <- big.matrix(5, 2, type="integer", init=0,dimnames=list(NULL, c("alpha", "beta")))
options(bigmemory.allow.dimnames=TRUE)

#pdbMPI
library(pbdMPI)
#mpiexec -np 2 Rscriptsome_code.r

#Rcpp
library(Rcpp)
cppFunction('int add(int x, int y, int z) {
              + int sum = x + y + z;
              + return sum;
              + }')

add(1, 2, 3)

#microbenchmark
library(ggplot2)
install.packages("microbenchmark")
library(microbenchmark)
tm <- microbenchmark(rnorm(100),rnorm(1000),rnorm(10000), times=1000L)
autoplot(tm)

#pipes
install.packages("babynames")
library(babynames) # data package
library(dplyr) # provides data manipulating functions.
library(magrittr) # pipes
library(ggplot2) # for graphics
babynames %>%
  + filter(name %>% substr(1, 3) %>% equals("Dan")) %>%
  + group_by(year, sex) %>%
  + summarize(total = sum(n)) %>%
  + qplot(year, total, color = sex, data = ., geom = "line") %>%
  + add(ggtitle('Names starting with "Dan"')) %>%
  + print

