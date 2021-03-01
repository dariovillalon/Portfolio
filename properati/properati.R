library(treemapify)

#Numero de habitaciones segùn tipo de propiedad
aux <- subset(df, rooms < 8)  #Filtramos como màximo 8 habitaciones
rooms_by_proptype <- as.data.frame(table(aux$rooms, aux$property_type))
names(rooms_by_proptype) <- cols <- c('rooms', 'property_type', 'freq')

require(devtools)
install_github('jbryer/multilevelPSA', force = TRUE)
install_github('jbryer/pisa', force = TRUE)

library(multilevelPSA)
library(pisa)


library(sp)
library(rgdal)
library(maptools)






#-----------------titulo y descrpicion por ubicacion
temp <- df
temp$text <- paste(temp$title, temp$description, collapse = " ")
aux <- aggregate(text ~ place_name, data = temp, paste, collapse = " ")
aux$title <- gsub(' [a-z]\\/', " ", aux$title)

#text mining
myReader <- readTabular(mapping=list(content="title", id="place_name"))
corpus_clean <- VCorpus(DataframeSource(aux), readerControl=list(reader=myReader))

for (i in 1:length(corpus_clean)) {
  attr(corpus_clean[[i]], "place_name") <- aux$place_name[i]
}

es_words <- readLines("D:/Google Drive/portfolio/words.txt")
skip_es_words <- function(x) removeWords(x, es_words)
funcs <- list(content_transformer(tolower), removePunctuation, removeNumbers, stripWhitespace, skip_es_words)
corpus_clean <- tm_map(corpus_clean, FUN = tm_reduce, tmFuns = funcs)
corpus_clean <- tm_map(corpus_clean, removeWords, stopwords('es'))
corpus_clean <- tm_map(corpus_clean, removeWords, c("alquilo", "alquiler", "alq", 'depto', 'dpto', 'casa', 'departamento', 'ambientes', 'local', 'ambiente', 'excelente', 'apto'))

ul <- unlist(strsplit(aux$place_name, "\\s+|[[:punct:]]"))
ul <- unique(ul)
ul <- tolower(ul)
ul <- removeNumbers(ul)

corpus_clean <- tm_map(corpus_clean, removeWords, ul)

dtm <- DocumentTermMatrix(corpus_clean, control = list(wordLengths = c(4,17)))
inspect(dtm[266:270,31:40])

findFreqTerms(dtm, lowfreq=300)
findAssocs(dtm, 'galpón', 0.9)

writeLines(as.character(corpus_clean[450]))

show(dtm)
str(dtm)


rowTotals <- apply(dtm , 1, sum)
dtm <- dtm[rowTotals > 0, ] 

colTotals <- apply(dtm, 2, sum)
dtm <- dtm[,colTotals > 20]

tst <- apply(dtm, 1, function(x) unlist(dtm[["dimnames"]][2], use.names = FALSE)[x == max(x)])
idx <- grep('subte', tst)
tst[idx]

tst$Chacarita
  
freqterms <- findFreqTerms(dtm, lowfreq = 30)[1:20]
plot(dtm, terms = freqterms, corThreshold = 0.7)

tmp <- as.data.frame(as.matrix(dtm))

wordcloud(corpus_clean, min.freq = 10)

cols <- apply(dtm, 1, max)

barrios <- readLines('C:/Users/Administrator/Desktop/barrios.txt')

tst[barrios]

library(stringr)

aux$count <- str_count(aux$title, "monoambiente")
g <- subset(aux, count > 0)

aux[!aux$place_name %in% barrios, ]




