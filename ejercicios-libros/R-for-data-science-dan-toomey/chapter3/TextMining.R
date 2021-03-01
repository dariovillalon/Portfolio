#Chapter 3: Text Mining
install.packages("tm")
library(tm)

path <- "state-of-the-union.txt"
text <- readLines(choose.files(), encoding="UTF-8")

vs <- VectorSource(text)
elem <- getElem(stepNext(vs))
result <- readPlain(elem, "en", "id1")
txt <- Corpus(vs)

#Creating a corpus
#Converting text to lowercase

txtlc <- tm_map(txt, tolower)
inspect(txt[1])
inspect(txtlc[1])

#Removing punctuation
txtnp <- tm_map(txt, removePunctuation)
inspect(txt[1])
inspect(txtnp[1])

#Removing numbers
txtnn <- tm_map(txt, removeNumbers)
inspect(txt[49])

#Removing words
txtns <- tm_map(txt[1], removeWords, stopwords("english"))
inspect(txtns)
inspect(txt[1])

#Removing whitespaces
txtnw <- tm_map(txt[30], stripWhitespace)
inspect(txtnw)

#Word stems
inspect(txt[86])
txtstem <- tm_map(txt, stemDocument)
inspect(txtstem[86])
txtcomplete <- tm_map(txtstem, stemCompletion, dictionary=txt)
inspect(txtcomplete[86])

#Document term matrix

dtm <- DocumentTermMatrix(txt)
dtm


txt <- tm_map(txt, removeWords, stopwords("english"))
dtm <- DocumentTermMatrix(txt)
dtm

dtm2 <- removeSparseTerms(dtm, 0.94)
inspect(dtm2)

findAssocs(dtm, "work", 0.15)

#Using VectorSource

#Text clusters
library(stats)
mymeans <- kmeans(dtm,5)
mymeans

summary(mymeans)
freq <- findFreqTerms(dtm,10)
freq

#dendogram
m2 <- as.matrix(dtm)
dm <- dist(scale(m2))
fit <- hclust(dm, method="ward.D")
plot(fit)

#Word graphics
source("http://bioconductor.org/biocLite.R")
biocLite("Rgraphviz")
plot(dtm, terms = findFreqTerms(dtm, lowfreq = 5)[1:10],
     corThreshold = 0.5)

install.packages("ggplot2")
library(ggplot2)

p <- ggplot(subset(wf, freq>10), aes(word,freq))
p <- p + geom_bar(stat="identity")
p <- p + theme(axis.text.x=element_text(angle=45, hjust=1))
p

install.packages("wordcloud")
library(wordcloud)
wordcloud(names(wf), freq, min.freq=10)


#Analyzing the XML text
install.packages("XML")
library(XML)

url <- "books.xml"
data <- xmlParse(choose.files())

df <- xmlToDataFrame(data)
colnames(df)

mean(as.numeric(df$price))

#example2
data <- xmlParse(choose.files())
root <- xmlRoot(data)
root[1]

fields <- xmlApply(root, names)
fields
table(sapply(fields, identical, fields[[1]]))
unique(unlist(fields))
unique(xpathSApply(data,"//*/level",xmlValue))
table(xpathSApply(data,"//*/level",xmlValue))
instructors <- table(xpathSApply(data,"///*/instructor",xmlValue))
instructors
which.max(instructors)
which.min(instructors)
sections <- table(xpathSApply(data,"//*/section_listing",xmlValue))
which.max(sections)
credits <- table(xpathSApply(data,"//credits",xmlValue))
credits
xpathSApply(data,"//*[credits=12]",xmlValue)


