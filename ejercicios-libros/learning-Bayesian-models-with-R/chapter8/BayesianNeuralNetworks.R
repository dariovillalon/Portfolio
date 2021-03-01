#Chapter 8. Bayesian Neural Networks

#The brnn R package

install.packages("brnn")
library(brnn)

mpgdataall <- read.table("https://archive.ics.uci.edu/ml/machine-learning-databases/auto-mpg/auto-mpg.data")

colnames(mpgdataall) <- c("mpg", "cylinders", "displacement",
                    "horsepower", "weight", "acceleration", "model.year", "origin", "car.name")

mpgdata <- mpgdataall[,c(1,3,5,6)]

#Fitting Bayesian NN Model
ytrain <- mpgdata[1:100,1]
xtrain <- as.matrix(mpgdata[1:100,2:4])
mpg_brnn <- brnn(xtrain,ytrain,neurons=2,normalize = TRUE,epochs = 1000)

summary(mpg_brnn)

#Prediction using trained model
ytest <- mpgdata[101:150,1]
xtest <- as.matrix(mpgdata[101:150,2:4])
ypred_brnn <- predict.brnn(mpg_brnn,xtest)

plot(ytest, ypred_brnn)
err <- ytest - ypred_brnn
summary(err)

cor(ytest, ypred_brnn) ^ 2


#_-----------------Deep belief networks

#The darch R packag
install.packages("darch")
library(darch)

darch <- newDArch(c(2,4,1),batchSize = 2,genWeightFunc = generateWeights)


inputs <- matrix(c(0,0,0,1,1,0,1,1),ncol=2,byrow=TRUE)
outputs <- matrix(c(0,1,1,0),nrow=4)

darch <- preTrainDArch(darch,inputs,maxEpoch=1000)

getLayerWeights(darch,index=1)

layers <- getLayers(darch)

for(i in length(layers):1){
  layers[[i]][[2]] <- sigmoidUnitDerivative
}

setLayers(darch) <- layers
rm(layers)

setFineTuneFunction(darch) <- backpropagation
darch <- fineTuneDArch(darch,inputs,outputs,maxEpoch=1000)

darch <- getExecuteFunction(darch)(darch,inputs)
outputs_darch <- getExecOutputs(darch)
outputs_darch[[2]]




