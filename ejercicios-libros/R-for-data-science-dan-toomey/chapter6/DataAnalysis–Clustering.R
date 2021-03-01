#Chapter 6: Data Analysis - Clustering

data <- read.csv("https://archive.ics.uci.edu/ml/machine-learning-databases/wine-quality/winequality-white.csv", sep=";")

summary(data)
plot(data)

kmeans(data, 20)

#Optimal number of clusters
install.packages("NbClust")
library(NbClust)

set.seed(2365)
#data.scaled <- scale(data)

data[,12] <- sapply(data[,12], as.numeric)

nc <- NbClust(data, min.nc=2, max.nc=4, method="kmeans")
#nc.scaled <- NbClust(data.scaled, min.nc=2, max.nc=5, method="kmeans")
hist(nc$Best.nc[1,])

#Medoids clusters
install.packages("fpc")
library(fpc)

best <- pamk(data)
best

library(cluster)
plot(pam(data, best$nc))

#The cascadeKM function
install.packages("vegan")
library(vegan)

fit <- cascadeKM(scale(data, center=TRUE, scale=TRUE), 10, 15)
plot(fit, sortg=TRUE, grmts.plot=TRUE)


#Selecting clusters based on Bayesian information
library(mclust)
d <- Mclust(as.matrix(data), G=10:15)
plot(d)
summary(d)

#Affinity propagation clustering
install.packages("apcluster")
library(apcluster)
neg <- negDistMat(data, r=2)
ap <- apcluster(neg)
ap
summary(ap)

#Gap statistic to estimate the number of clusters
library(cluster)
clusGap(data, kmeans, 15, B=100, verbose=interactive())

#Hierarchical clustering
install.packages("pvclust")
library(pvclust)

pv <- pvclust(data)
pv

plot(pv)



































