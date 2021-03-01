#Chapter 6. Bayesian Classification Models

path <- "D:/Google Drive/projects/learning-Bayesian-models-with-R/chapter6/spamdata.txt"

spamdata <- read.table(path, sep = "\t",stringsAsFactors = default.stringsAsFactors(), quote = "", header = TRUE)
colnames(spamdata) <- c("type", "msg")


samp <- sample.int(nrow(spamdata),as.integer(nrow(spamdata)*0.2),replace=F)
spamTest <-spamdata[samp,]
spamTrain <-spamdata[-samp,]
ytrain<-as.factor(spamTrain[,1])
ytest<-as.factor(spamTest[,1])
xtrain<-as.vector(spamTrain[,2])
xtest<-as.vector(spamTest[,2])

install.packages("tm")
library(tm)
library(SnowballC)

xtrain <- VCorpus(VectorSource(xtrain))
xtest <- VCorpus(VectorSource(xtest))

#remove extra white space
xtrain <- tm_map(xtrain,stripWhitespace)
xtest <- tm_map(xtest,stripWhitespace)
#remove punctuation
xtrain <- tm_map(xtrain,removePunctuation)
xtest <- tm_map(xtest, removePunctuation)
#remove numbers
xtrain <- tm_map(xtrain,removeNumbers)
xtest <- tm_map(xtest,removeNumbers)
#changing to lower case
xtrain <- tm_map(xtrain,content_transformer(tolower))
xtest <- tm_map(xtest,content_transformer(tolower))
#removing stop words
xtrain <- tm_map(xtrain,removeWords,stopwords("english"))
xtest <- tm_map(xtest,removeWords,stopwords("english"))
#stemming the document
xtrain <- tm_map(xtrain,stemDocument)
xtest <- tm_map(xtest,stemDocument)

#creating Document-Term Matrix
xtrain <- as.data.frame.matrix(DocumentTermMatrix(xtrain))
xtest <- as.data.frame.matrix(DocumentTermMatrix(xtest))

#Model training and prediction

install.packages("e1071")
library(e1071)

#Training the Naive Bayes Model
nbmodel <- naiveBayes(xtrain,ytrain,laplace=3)
summary(nbmodel)

#Prediction using trained model
ypred.nb <- predict(nbmodel,xtest,type = "class",threshold = 0.075)

#Converting classes to 0 and 1 for plotting ROC
fconvert <- function(x){
    if(x == "spam"){ y <- 1}
    else {y <- 0}
    y
  } 

ytest1 <- sapply(ytest,fconvert,simplify = "array")
ypred1 <- sapply(ypred.nb,fconvert,simplify = "array")

install.packages("pROC")
library(pROC)

roc(ytest1,ypred1,plot = T)

#Confusion matrix
confmat <- table(ytest,ypred.nb)
confmat


tab <- nbmodel$tables
fham <- function(x){
  y <- x[1,1]
  y
}

hamvec <- sapply(tab,fham,simplify = "array")
hamvec <- sort(hamvec,decreasing = T)
fspam <- function(x){
  y <- x[2,1]
  y
}

spamvec <- sapply(tab,fspam,simplify = "array")
spamvec <- sort(spamvec,decreasing = T)
prb <- cbind(spamvec,hamvec)
print.table(prb)

head(prb)
tail(prb)

#----------------The BayesLogit R package
install.packages("BayesLogit")
library(BayesLogit)

PDdata <- read.table("https://archive.ics.uci.edu/ml/machine-learning-databases/parkinsons/parkinsons.data",
                     sep = ",", header = TRUE, row.names = 1)

rnames <- row.names(PDdata)
cnames <- colnames(PDdata,do.NULL = TRUE,prefix = "col")
colnames(PDdata)[17] <- "y"
PDdata$y <- as.factor(PDdata$y)
table(PDdata$y)

rnames.strip <- substr(rnames,10,12)
PDdata1 <- cbind(PDdata,rnames.strip)
rnames.unique <- unique(rnames.strip)
set.seed(123)

samp <- sample(rnames.unique,as.integer(length(rnames.unique)*0.2),replace=F)

PDtest <- PDdata1[PDdata1$rnames.strip %in% samp,-24]
PDtrain <- PDdata1[!(PDdata1$rnames.strip %in% samp),-24]

xtrain <- PDtrain[,-17]
ytrain <- PDtrain[,17]
xtest <- PDtest[,-17]
ytest<- PDtest[,17]

blmodel <- logit(ytrain, xtrain, n = rep(1, length(ytrain)), 
                 m0 = rep(0, ncol(xtrain)), 
                 P0 = matrix(0, nrow = ncol(xtrain),ncol = ncol(xtrain)),
                 samp = 1000, burn = 500)


summary(blmodel)

psi <- blmodel$beta %*% t(xtrain) # samp x n
p <- exp(psi) / (1 + exp(psi) ) # samp x n
ypred.bayes <- colMeans(p)

table(ypred.bayes,ytrain)
roc(ytrain,ypred.bayes,plot = T)
