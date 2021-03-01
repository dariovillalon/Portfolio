#Chapter 12: Supervised and Unsupervised Learning

#-----------------------Supervised learning

#Decision trees
library(rattle)
View(weather)
summary(weather)

weather2 <- subset(weather,select=-c(RISK_MM))

install.packages("rpart")
library(rpart)
model <- rpart(formula=RainTomorrow ~ .,data=weather2, method="class")
summary(model)

library(rpart.plot)
fancyRpartPlot(model, main = "Rain Tomorrow", sub = "Chapter 12")

#Regression
forestfires <- read.csv("https://archive.ics.uci.edu/ml/machine-learning-databases/forest-fires/forestfires.csv")
summary(forestfires)

model <- lm(formula = area ~ month + temp + wind + rain,
            data=forestfires)

summary(model)
#without temperatura
model <- lm(formula = area ~ month + wind + rain, data=forestfires)
summary(model)
plot(model)

#Neural network
bupa <- read.csv("https://archive.ics.uci.edu/ml/machine-learning-databases/liver-disorders/bupa.data")
colnames(bupa) <- c("mcv","alkphos","alamine","aspartate","glutamyl","drinks","selector")
summary(bupa)

install.packages("neuralnet")
library(neuralnet)
nn <- neuralnet(selector ~ mcv + alkphos + alamine + aspartate + glutamyl 
                + drinks,
                data=bupa, linear.output=FALSE, hidden=2)
nn$result.matrix
plot(nn)

#Instance-based learning
data <- read.table("https://archive.ics.uci.edu/ml/machine-learning-databases/auto-mpg/auto-mpg.data", na.strings = "?")

colnames(data) <- c("mpg","cylinders","displacement","horsepower",
                      "weight","acceleration","model.year","origin","car.name")

summary(data)

library(class)
library(caret)
training <- createDataPartition(data$mpg, p=0.75, list=FALSE)
trainingData <- data[training,]
testData <- data[-training,]
model <- knn(train=trainingData, test=testData, cl=trainingData$mpg)
completedata <- data[complete.cases(data),]
drops <- c("car.name")
completeData2 <- completedata[,!(names(completedata) %in% drops)]
training <- createDataPartition(completeData2$mpg, p=0.75,list=FALSE)
trainingData <- completeData2[training,]
testData <- completeData2[-training,]
model <- knn(train=trainingData, test=testData, cl=trainingData$mpg)

plot(model)

#using kknn
install.packages("kknn")
library(kknn)
model <- kknn(formula = formula(mpg~.), train = trainingData, 
              test = testData, k = 3, distance = 1)
fit <- fitted(model)
plot(testData$mpg, fit)
cor(testData$mpg, fit) ^ 2
abline(a=0, b=1, col=3)

#Ensemble learning

#Support vector machines
library(kernlab)
data("spam")
summary(spam)

table(spam$type)
prop.table(table(spam$type))*100

index <- 1:nrow(spam)
testindex <- sample(index, trunc(length(index)/3))
testset <- spam[testindex,]
trainingset <- spam[-testindex,]

library(e1071)
model <- svm(type ~ ., data = trainingset, 
             method = "C-classification", 
             kernel = "radial", cost = 10, gamma = 0.1)

summary(model)

pred <- predict(model, testset)
table(pred, testset$type)

#Bayesian learning
install.packages("MCMCpack")
library(MCMCpack)
install.packages("statLib")
library(StatLib)

transplants <- read.table("D:/Google Drive/projects/R-for-data-science-dan-toomey/chapter12/transplant.txt")
colnames(transplants) <- c("obs", "expected", "actual", "transplants")
transplants$obs <- NULL
summary(transplants)

model <- MCMCregress(expected ~ actual + transplants,
                     data=transplants)
summary(model)
plot(model)

#------------------------------Unsupervised learning
#Cluster analysis


wheat <- read.csv("https://archive.ics.uci.edu/ml/machine-learning-databases/00236/seeds_dataset.txt", sep="\t")
colnames(wheat) <- c("area", "perimeter", "compactness", "length",
                     "width", "asymmetry", "groove", "undefined")

head(wheat)
wheat <- subset(wheat, select = -c(undefined) )
head(wheat)

fit <- kmeans(wheat, 5)
wheat <- wheat[complete.cases(wheat),]

plot(wheat)

fit <- kmeans(wheat, 5)
fit

fit <- kmeans(wheat, 10)
fit

#Density estimation

sunspots <- read.csv("http://vincentarelbundock.github.io/Rdatasets/csv/datasets/sunspot.month.csv")
summary(sunspots)

d <- density(sunspots$sunspot.month)
d
plot(d)

N <- 1000
sunspots.new <- rnorm(N, sample(sunspots$sunspot.month, size=N,
                                  replace=TRUE))

lines(density(sunspots.new), col="blue")

#Expectation-maximization
library(mclust)

colnames(iris) <- c("SepalLength","SepalWidth","PetalLength",
                    "PetalWidth","Species")
modelName <- "EEE"
head(iris)

data = iris[,-5]
z <- unmap(iris[,5])

msEst <- mstep(modelName, data, z)

em(modelName, data, msEst$parameters)


#Hidden Markov models
install.packages("HMM")
library(HMM)

hmm <- initHMM(c("Rainy","Sunny"), c('walk', 'shop', 'clean'),
               c(.6,.4), matrix(c(.7,.3,.4,.6),2), matrix(c(.1,.4,.5,.6,.3,.1),3))

hmm

future <- forward(hmm, c("walk","shop","clean"))
future

#Blind signal separation
install.packages("FactoMineR")
library(FactoMineR)
data(decathlon)

summary(decathlon)
head(decathlon)

res.pca <- PCA(decathlon[,1:10], scale.unit=TRUE, ncp=5, graph=T)