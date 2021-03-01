#Chapter 5: Data Analysis - Correlation
path <- "D:/Google Drive/projects/R-for-data-science-dan-toomey/chapter5"
setwd(path)

data <- read.csv(choose.files(), header = TRUE, sep = ";", 
                 col.names = c("Year", "SP500", "TBill3Mos", "TBond10Year"),
                 stringsAsFactors = FALSE, dec = ",")

summary(data)

library(lattice)
splom(~data[2:4])

library(car)
scatterplotMatrix(data)

cor(data)

#Visualizing correlations
install.packages("corrgram")
library(corrgram)

corrgram(data)
plot(data$SP500,data$TBill3Mos)
abline(lm(data$TBill3Mos ~ data$TBond10Year))

install.packages("PerformanceAnalytics")
library(PerformanceAnalytics)

chart.Correlation(cor(data), histogram=TRUE)

#Covariance
cov(data)
cor.test(data$SP500, data$TBill3Mos)


pairs(data)


#Pearson correlation
install.packages("Hmisc")
library(Hmisc)

rcorr(as.matrix(data))


#Polychoric correlation
install.packages("psych")
library(psych)

data <- read.table("poly.csv", sep="\t", header = TRUE, stringsAsFactors = TRUE)

result <- polychoric(data)
plot(data$Q1, data$Q2)
hist(data$Q1)
hist(data$Q2)

install.packages("polycor")
library(polycor)

cor(data$Q1, data$Q2)
polychor(data$Q1, data$Q2)

polychor(data$Q1, data$Q2, ML=TRUE, std.err=TRUE)

#Tetrachoric correlation
data <- read.csv("titanic3.csv")
summary(data)

library(psych)
library(polycor)

nrow(subset(data, survived==1 & sex=='male'))
nrow(subset(data, survived==1 & sex=='female'))
nrow(subset(data, survived==0 & sex=='male'))
nrow(subset(data, survived==0 & sex=='female'))

tetrachoric(matrix(c(161,339,682,127),2,2))

draw.tetra(-0.75, 0.37, -0.30)

#A heterogeneous correlation matrix
set.seed(12345)
R <- matrix(0, 4, 4)
R[upper.tri(R)] <- runif(6)
R
diag(R) <- 1
R
R <- cov2cor(t(R) %*% R)
round(R, 4)

install.packages("mvtnorm")
library(mvtnorm)

data <- rmvnorm(1000, rep(0, 4), R)
round(cor(data), 4)
x1 <- data[,1]
x2 <- data[,2]
y1 <- cut(data[,3], c(-Inf, .75, Inf))
y2 <- cut(data[,4], c(-Inf, -1, .5, 1.5, Inf))
data <- data.frame(x1, x2, y1, y2)
hetcor(data)
hetcor(x1, x2, y1, y2, ML=TRUE)


#Partial correlation
install.packages('ggm')
library(ggm)

pcor(c("SP500","TBill3Mos"),var(data))