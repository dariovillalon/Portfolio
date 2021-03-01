#Chapter 7. Bayesian Models for Unsupervised Learning

#The bgmm package for Bayesian mixture models
install.packages("bgmm")
library(bgmm)

path <- "D:/Google Drive/projects/learning-Bayesian-models-with-R/chapter7/HMP_Dataset/Brush_teeth"
setwd(path)

flist <- list.files(path = path, pattern = "*.txt")

all.data <- lapply(flist, read.table, sep = " ", header = FALSE)
combined.data <- as.data.frame(do.call(rbind,all.data))
combined.data.XZ <- combined.data[,c(1,3)]

modelbgmm <- unsupervised(combined.data.XZ, k = 4)
summary(modelbgmm)
plot.mModel(modelbgmm)


#-------------Latent Dirichlet allocation
install.packages("topicmodels")
library(topicmodels)
library(tm)



#creation of training corpus from reuters dataset
path <- "D:/Google Drive/projects/learning-Bayesian-models-with-R/chapter7/AlanCrosby-train"
dirsourcetrain <- DirSource(directory = path)

xtrain <- VCorpus(dirsourcetrain)
#remove extra white space
xtrain <- tm_map(xtrain,stripWhitespace)
#changing to lower case
xtrain <- tm_map(xtrain,content_transformer(tolower))
#removing stop words
xtrain <- tm_map(xtrain,removeWords,stopwords("english"))
#stemming the document
xtrain <- tm_map(xtrain,stemDocument)
#creating Document-Term Matrix
xtrain <- as.data.frame.matrix(DocumentTermMatrix(xtrain))

path <- "D:/Google Drive/projects/learning-Bayesian-models-with-R/chapter7/AlanCrosby-test"
dirsourcetrain <- DirSource(directory = path)

xtest <- VCorpus(dirsourcetrain)
#remove extra white space
xtest <- tm_map(xtest,stripWhitespace)
#changing to lower case
xtest <- tm_map(xtest,content_transformer(tolower))
#removing stop words
xtest <- tm_map(xtest,removeWords,stopwords("english"))
#stemming the document
xtest <- tm_map(xtest,stemDocument)
#creating Document-Term Matrix
xtest <- as.data.frame.matrix(DocumentTermMatrix(xtest))


#training lda model
ldamodel <- LDA(xtrain, 10, method = "VEM")

#computation of perplexity, on training data (only with VEM method)
perp <- perplexity(ldamodel)
perp

#A value of perplexity around 100 indicates a good fit. 
#In this case, we need to add more training data or change the value 
#of K to improve perplexity.

#extracting topics from test data)
options(scipen = 999)
postprob <- posterior(ldamodel,xtest)
postprob$topics

#-------------The lda package
install.packages("lda")
library(lda)
