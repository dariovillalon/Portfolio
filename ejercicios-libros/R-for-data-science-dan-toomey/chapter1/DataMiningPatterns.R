#Chapter 1: Data mining patterns

#Clustering
x <- rbind(matrix(rnorm(100, sd = 0.3), ncol = 2),
           matrix(rnorm(100, mean = 1, sd = 0.3), ncol = 2))
plot(x)


fit <- kmeans(x, centers = 10)
fit

results <- matrix(nrow=14, ncol=2, dimnames=list(2:15,c("clusters","sumsquares")))

for(i in 2:15) {
  fit <- kmeans(x, centers = i)
  results[i-1,1] <- i
  results[i-1,2] <- fit$tot.withinss
}

plot(results, type = "l")


#k-medoid clustering
Object <- 1:9
x <- c(1, 2, 1, 2, 1, 3, 2, 2, 3)
y <- c(10, 11, 10, 12, 4, 5, 6, 5, 6)
df <- data.frame(x, y, Object)

plot(df)

#load pam function
library(cluster)

result <- pam(df, 2, FALSE, "euclidean")
result
summary(result)

plot(result$data, col = result$clustering)


#Hierarchical clustering
dat <- matrix(rnorm(100), nrow=10, ncol=10)

hc <- hclust(dist(dat))
plot(hc)

#Expectation-maximization
install.packages("mclust")
library(mclust)

data <- iris

fit <- Mclust(data)
fit
summary(fit)
plot(fit)

#Density estimation
d <- density(data$Sepal.Length)
d
plot(d)

#Anomaly detection
#Show outliers
y <- rnorm(100)
boxplot(y)
identify(rep(1, length(y)), y, labels = seq_along(y))


x <- rnorm(100)
plot(x)
summary(x)
boxplot.stats(x)$out
boxplot(x)

boxplot(mpg~cyl,data=mtcars, xlab="Cylinders", ylab="MPG")


#Another anomaly detection example
x <- rnorm(1000)
y <- rnorm(1000)
f <- data.frame(x,y)
a <- boxplot.stats(x)$out
b <- boxplot.stats(y)$out
list <- union(a,b)
plot(f)
px <- f[f$x %in% a,]
py <- f[f$y %in% b,]
p <- rbind(px,py)
par(new=TRUE)
plot(p$x, p$y,cex=2,col=2)


#Calculating anomalies
data <- iris
outliers <- function(data, low, high) {
  outs <- subset(data, data$Sepal.Length < low | data$Sepal.Length > high)
  return(outs)
}

outliers(data, 4.5, 7.5)

#Example2
install.packages("DMwR")
library(DMwR)

nospecies <- data[,1:4]
scores <- lofactor(nospecies, k=3)

plot(density(scores))

#Association rules
install.packages("arules")
library(arules)

data <- read.csv("http://www.salemmarafi.com/wp-content/uploads/2014/03/groceries.csv", header = FALSE)
rules <- apriori(data)
rules
inspect(rules)
rules <- apriori(data, parameter = list(supp = 0.001, conf = 0.8))
inspect(rules)












