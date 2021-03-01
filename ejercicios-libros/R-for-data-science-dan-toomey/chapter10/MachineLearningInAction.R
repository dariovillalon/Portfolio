#Chapter 10: Machine Learning in action

housing <- read.table("https://archive.ics.uci.edu/ml/machine-learning-databases/housing/housing.data")
colnames(housing) <- c("CRIM","ZN","INDUS","CHAS","NOX","RM","AGE","DIS","RAD","TAX","PRATIO","B","LSTAT","MDEV")

summary(housing)
plot(housing)

install.packages("corrplot")
library(corrplot)
corrplot(cor(housing), method="number", tl.cex=0.5)

#Data partitioning
install.packages("caret")
library(caret)

housing <- housing[order(housing$MDEV),]
set.seed(3277)

trainingIndices <- createDataPartition(housing$MDEV, p=0.75,
                                       list=FALSE)

housingTraining <- housing[trainingIndices,]
housingTesting <- housing[-trainingIndices,]

#Model
#Linear model

linearModel <- lm(MDEV ~ CRIM + ZN + INDUS + CHAS + NOX + RM + AGE +
                    DIS + RAD + TAX + PRATIO + B + LSTAT, data=housingTraining)

summary(linearModel)

#Prediction
predicted <- predict(linearModel,newdata=housingTesting)
summary(predicted)
summary(housingTesting$MDEV)
plot(predicted,housingTesting$MDEV)

sumofsquares <- function(x) {
  return(sum(x^2))
  }

sumofsquares(1:5)

diff <- predicted - housingTesting$MDEV
sumofsquares(diff)

#Logistic regression
lr <- glm(MDEV ~ CRIM + ZN + INDUS + CHAS + NOX + RM + AGE + DIS +
            RAD + TAX + PRATIO + B + LSTAT, data=housingTraining)

summary(lr)
predicted <- predict(lr,newdata=housingTesting)
summary(predicted)
plot(predicted,housingTesting$MDEV)
diff <- predicted - housingTesting$MDEV
sumofsquares(diff)

#Residuals
plot(resid(linearModel))

#Least squares regression
x <- housingTesting$MDEV
Y <- predicted

b1 <- sum((x-mean(x))*(Y-mean(Y)))/sum((x-mean(x))^2)
b0 <- mean(Y)-b1*mean(x)

c(b0, b1)
plot(x, Y)
abline(c(b0,b1),col="blue",lwd=2)

#Relative importance
install.packages("relaimpo")
library(relaimpo)

calc.relimp(linearModel,type=c("lmg","last","first","pratt"),
            rela=TRUE)

#Stepwise regression
library("MASS")

step <- stepAIC(linearModel, direction="both")

#The k-nearest neighbor classification
library("class")
knnModel <- knn(train=housingTraining, test=housingTesting,
                cl=housingTraining$MDEV)

summary(knnModel)
plot(knnModel)

#Naïve Bayes
install.packages("e1071")
library(e1071)

nb <- naiveBayes(MDEV ~ CRIM + ZN + INDUS + CHAS + NOX + RM + AGE +
                   DIS + RAD + TAX + PRATIO + B + LSTAT, data=housingTraining)


summary(nb)

nb$tables$TAX
plot(nb$apriori)

#generic methods
#train
#predict

#Support vector machines
pima <- read.csv("https://archive.ics.uci.edu/ml/machine-learning-databases/pima-indians-diabetes/pima-indians-diabetes.data")
colnames(pima) <- c("pregnancies","glucose","bp","triceps","insulin","bmi","pedigree","age","class")
summary(pima)

set.seed(3277)

library(caret)

pimaIndices <- createDataPartition(pima$class, p=0.75, list=FALSE)
pimaTraining <- pima[pimaIndices,]
pimaTesting <- pima[-pimaIndices,]

library(kernlab)

bootControl <- trainControl(number = 200)
svmFit <- train(pimaTraining[,-9], pimaTraining[,9],
                  method="svmRadial", tuneLength=5, trControl=bootControl, scaled=FALSE)
svmFit

predicted <- predict(svmFit$finalModel,newdata=pimaTesting[,-9])
plot(pimaTesting$class,predicted)

table(pred = predicted, true = pimaTesting[,9])

svmFit$finalModel

#K-means clustering
irisIndices <- createDataPartition(iris$Species, p=0.75, list=FALSE)
irisTraining <- iris[irisIndices,]
irisTesting <- iris[-irisIndices,]

bootControl <- trainControl(number = 20)
km <- kmeans(irisTraining[,1:4], 3)
km

install.packages("clue")
library(clue)
cl_predict(km,irisTesting[,-5])

irisTesting[,5]

#Decision trees
library(rpart)
set.seed(3277)
housing <- read.table("https://archive.ics.uci.edu/ml/machine-learning-databases/housing/housing.data")
colnames(housing) <- c("CRIM","ZN","INDUS","CHAS","NOX","RM","AGE","DIS","RAD","TAX","PRATIO","B","LSTAT","MDEV")

housing <- housing[order(housing$MDEV),]
trainingIndices <- createDataPartition(housing$MDEV, p=0.75, list=FALSE)
housingTraining <- housing[trainingIndices,]
housingTesting <- housing[-trainingIndices,]

housingFit <- rpart(MDEV ~ CRIM + ZN + INDUS + CHAS + NOX + RM +
                    AGE + DIS + RAD + TAX + PRATIO + B + LSTAT, method="anova",
                    data=housingTraining)

housingFit
plot(housingFit)
text(housingFit, use.n=TRUE, all=TRUE, cex=.8)

treePredict <- predict(housingFit,newdata=housingTesting)

diff <- treePredict - housingTesting$MDEV
sumofsquares <- function(x) {return(sum(x^2))}
sumofsquares(diff)

#AdaBoost
install.packages("ada")
library(ada)
adaModel <- ada(x=pimaTraining[,-9],y=pimaTraining$class,test.x=pimaTesting[,-9],test.y=pimaTesting$class)
adaModel

#Neural network
install.packages('neuralnet')
library("neuralnet")

nnet <- neuralnet(MDEV ~ CRIM + ZN + INDUS + CHAS + NOX + RM + AGE +
                  DIS + RAD + TAX + PRATIO + B + LSTAT,housingTraining, hidden=10,
                  threshold=0.01)


nnet <- neuralnet(MDEV ~ CRIM + ZN + INDUS + CHAS + NOX + RM + AGE +
                    DIS + RAD + TAX + PRATIO + B + LSTAT,housingTraining)
plot(nnet, rep="best")

results <- compute(nnet, housingTesting[,-14])
diff <- results$net.result - housingTesting$MDEV
sumofsquares(diff)

#Random forests
install.packages("randomForest")
library(randomForest)

forestFit <- randomForest(MDEV ~ CRIM + ZN + INDUS + CHAS + NOX + RM +
                          AGE + DIS + RAD + TAX + PRATIO + B + LSTAT, data=housingTraining)

forestFit
forestPredict <- predict(forestFit,newdata=housingTesting)

diff <- forestPredict - housingTesting$MDEV
sumofsquares(diff)

#Errors from models tested
#3555 from the linear regression
#3926 from the decision tree
#11016 from the neural net
#2464 from the forest






















