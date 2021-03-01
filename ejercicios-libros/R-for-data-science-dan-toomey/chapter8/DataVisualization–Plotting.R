#Chapter 8: Data Visualization - Plotting

install.packages(c("car", "lattice", "gclus", "MASS", "ggplot2"))
library(car)
library(lattice)
library(gclus)
library(MASS)
library(ggplot2)

#Scatter plots
data <- iris
colnames(data) <- c("sepal_length", "sepal_width", "petal_length",
                    "petal_width", "species")

summary(data)

#scatter plot
plot(data$sepal_length, data$petal_length)

#step diagram
plot(data$sepal_length, data$petal_length, type="s")

#histogram
plot(data$sepal_length, data$petal_length, type="h")

#Regression line
plot(data$sepal_length, data$petal_length)
abline(lm(data$petal_length~data$sepal_length), col="red")

#A lowess line
lines(lowess(data$sepal_length,data$petal_length), col="blue")

#scatterplot with car
scatterplot(data$sepal_length, data$petal_length)

#Scatterplot matrices
pairs(data)

#splom - display matrix data
splom(data)
scatterplotMatrix(data)

#cpairs - plot matrix data
cpairs(data)
data.r <- abs(cor(data))
df <- subset(data, select = -c(species) )
df.r <- abs(cor(df))
df.col <- dmat.color(df.r)
df.o <- order.single(df.r)
cpairs(df, df.o, panel.colors=NULL)


#Density scatter plots
library(hexbin)
bin <- hexbin(data$sepal_length, data$petal_length)
summary(bin)

bin<-hexbin(data$sepal_length, data$petal_length, xbins=10)
summary(bin)
plot(bin)

#Bar charts and plots
#Bar plot

library(MASS)
summary(HairEyeColor)
counts <- table(HairEyeColor)
barplot(counts)

count <- table(Cars93$Cylinders)
barplot(count)

# want the number of cylinders by manufacturer
count <- table(Cars93$Cylinders, Cars93$Manufacturer)
barplot(count)

#Bar chart
# count the number of models by cylinder by manufacturer
count <- table(Cars93$Cylinders, Cars93$Manufacturer)
barplot(count)

#ggplot2
#need to load the ggplot2 library
library(ggplot2)

#call upon the qplot function for our chart
qplot(Cars93$Cylinders)





#-------------Word cloud
install.packages("tm")
install.packages("wordcloud")
library(tm)
library(wordcloud)

# read the web page text, line by line
download.file('http://finance.yahoo.com','test.html')
page <- readLines("D:/Google Drive/projects/R-for-data-science-dan-toomey/chapter8/yahoo-finance.txt")

# produce a corpus of the text
corpus = Corpus(VectorSource(page))

# convert all of the text to lower case (standard practice for text)
corpus <- tm_map(corpus, tolower)

# remove any punctuation
corpus <- tm_map(corpus, removePunctuation)

# remove numbers
corpus <- tm_map(corpus, removeNumbers)

# remove English stop words
corpus <- tm_map(corpus, removeWords, stopwords("english"))

# create a document term matrix
dtm <- TermDocumentMatrix(corpus)

# not sure why this occurs, but the next statement clears
#Error: inherits(doc, "TextDocument") is not TRUE

# reconfigure the corpus as a text document
corpus <- tm_map(corpus, PlainTextDocument)
dtm <- TermDocumentMatrix(corpus)

# convert the document matrix to a standard matrix for use in the cloud
m <- as.matrix(dtm)

# sort the data so we end up with the highest as biggest
v <- sort(rowSums(m), decreasing = TRUE)

# finally produce the word cloud
wordcloud(names(v), v, min.freq = 10)

















