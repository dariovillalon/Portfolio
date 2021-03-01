#sms spam classification

#Clean de variable environment
rm(list = ls(all = TRUE)) 

#Get the data from CSV
sms_raw <- read.csv("C:/Users/Administrator/Desktop/projects/machine-learning-brett-lantz/sms_spam.csv", stringsAsFactors = FALSE)

#get data frame structure
str(sms_raw)

#factor de class feature
sms_raw$type <- factor(sms_raw$type)
str(sms_raw$type)

table(sms_raw$type)

#install text mining package
install.packages("tm")
library("tm")

#create a collection of text documents(corpus)
sms_corpus <- Corpus(VectorSource(sms_raw$text))

#convert all text to lowercase
corpus_clean <- tm_map(sms_corpus, content_transformer(tolower))

corpus_clean <- tm_map(corpus_clean, PlainTextDocument)

#delete numbers
corpus_clean <- tm_map(corpus_clean, removeNumbers)

#delete stopwords e.g. and, i'd, why, to, not, some, so, than etc
corpus_clean <- tm_map(corpus_clean, removeWords, stopwords())

#remove punctuation
corpus_clean <- tm_map(corpus_clean, removePunctuation)

#remove multiple blank spaces
corpus_clean <- tm_map(corpus_clean, stripWhitespace)

#create a sparse matrix - it tokenizes words of sms
sms_dtm <- DocumentTermMatrix(corpus_clean)

#split training set and test set

#the raw data
sms_raw_train <- sms_raw[1:4169,]
sms_raw_test <- sms_raw[4170:5574,]

#the doc term matrix
sms_dtm_train <- sms_dtm[1:4169,]
sms_dtm_test <- sms_dtm[4170:5574,]

#the corpus clean data
sms_corpus_train <- corpus_clean[1:4169]
sms_corpus_test <- corpus_clean[4170:5574]

#check if subsets are representative
prop.table(table(sms_raw_train$type))
prop.table(table(sms_raw_test$type))


#visualize
install.packages("wordcloud")
library(wordcloud)

#build a wordcloud - most frequent words are larger than others
wordcloud(sms_corpus_train, min.freq = 40, random.order = FALSE)

#build wordcloud but as spam and ham separeted datasets
spam <- subset(sms_raw_train, type == "spam")
ham <- subset(sms_raw_train, type == "ham")

#rebuild wordclouds for spam and ham separately
wordcloud(spam$text, max.words = 40, scale = c(3, 0.5))
wordcloud(ham$text, max.words = 40)

#find and save words that appear at least 5 times
sms_dict <- findFreqTerms(sms_dtm_train, 5)


#limit our datasets to only use those terms we've just found 
sms_train <- DocumentTermMatrix(sms_corpus_train, list(dictionary = sms_dict))
sms_test <- DocumentTermMatrix(sms_corpus_test, list(dictionary = sms_dict))

#factor the document term matrix
convert_counts <- function(x) {
  
  x <- ifelse(x > 0, 1, 0) 
  x <- factor(x, levels = c(0,1), labels = c("No", "Yes"))
  
  return (x)
}


sms_train <- apply(sms_train, MARGIN = 2, convert_counts)
sms_test <- apply(sms_test, MARGIN = 2, convert_counts)

#install packages naive bayes
install.packages("e1071")
library(e1071)

#build model (laplace = 0 , 34 examples errouneosly classifed)
sms_classifier <- naiveBayes(sms_train, sms_raw_train$type)

#predict
sms_test_pred <- predict(sms_classifier, sms_test)

#evaluate model
CrossTable(sms_test_pred, sms_raw_test$type, prop.chisq = FALSE,
           prop.t = FALSE, dnn = c('predicted', 'actual'))


#model with laplace = 1 (35 examples errouneosly classifed)
sms_classifier1 <- naiveBayes(sms_train, sms_raw_train$type, laplace = 1)
sms_test_pred1 <- predict(sms_classifier1, sms_test)

CrossTable(sms_test_pred1, sms_raw_test$type, prop.chisq = FALSE,
           prop.t = FALSE, dnn = c('predicted', 'actual'))

#model with laplace = 2 (42 examples errouneosly classifed)
sms_classifier2 <- naiveBayes(sms_train, sms_raw_train$type, laplace = 2)
sms_test_pred2 <- predict(sms_classifier2, sms_test)

CrossTable(sms_test_pred2, sms_raw_test$type, prop.chisq = FALSE,
           prop.t = FALSE, dnn = c('predicted', 'actual'))






