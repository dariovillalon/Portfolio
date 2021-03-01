#Chapter 4: Data Analysis - Regression Analysis

#Simple regression
data <- iris
colnames(data) <- c("sepal_length", "sepal_width", "petal_length",
                    "petal_width", "species")


summary(data)
plot(data)
cor(data$petal_length,data$petal_width)
fit <- lm(data$petal_length ~ data$petal_width)
fit

par(mfrow=c(2,2)) # set the plot area to 2 plots by 2 plots
plot(fit)

summary(fit)

data2<- subset(data, data$species!='setosa')
plot(data2)

cor(data2$petal_length,data2$petal_width)
fit <- lm(data2$petal_length ~ data2$petal_width)
summary(fit)


#Multiple regression
#dataset not found

#Multivariate regression analysis
install.packages('chemometrics')
library(chemometrics)

data <- read.table("https://archive.ics.uci.edu/ml/machine-learning-databases/auto-mpg/auto-mpg.data")

colnames(data) <- c("mpg", "cylinders", "displacement",
                    "horsepower", "weight", "acceleration", "model.year", "origin", "car.name")

summary(data)

m <- lm(cbind(data$mpg,data$acceleration,data$horsepower) ~
          data$cylinders + data$displacement + data$weight + data$model.year)

summary(m)

mm <- manova(m)
mm

data$car.name<- NULL
data$horsepower[data$horsepower=='?'] <- NA
data$horsepower<- as.numeric(data$horsepower)

cor(data)
cov(data)

#Robust regression
data <- subset(data, select = -horsepower)
prcomp(data)

d1<- cooks.distance(m)
d1
head(d1)

library(MASS)
r <- stdres(m)
a <- cbind(data, d1, r)
a[d1> 4/398, ]

rlm(data$mpg ~ data$cylinders + data$displacement + data$weight +
      data$model.year)

m <- rlm(mpg ~ cylinders + displacement + weight + model.year, data)
m

#run 3 times
m2<- ltsreg(mpg ~ cylinders + displacement + weight + model.year,
            data)
m2


