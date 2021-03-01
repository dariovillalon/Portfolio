#Chapter 2: Data Mining Sequences

#Eclat
install.packages("arules")
library(arules)

data("Adult")
dim(Adult)
summary(Adult)

#Finding frequent items in a dataset
itemsets <- eclat(Adult)
itemsets.sorted <- sort(itemsets)
inspect(itemsets.sorted[1:5])

#An example focusing on highest frequency
itemsets <- eclat(Adult, parameter=list(minlen=9))
inspect(itemsets)

#arulesNBMiner
install.packages("arulesNBMiner")
library(arulesNBMiner)

data("Agrawal")
summary(Agrawal.db)
summary(Agrawal.pat)

#Mining the Agrawal data for frequent sets
mynbparameters <- NBMinerParameters(Agrawal.db)
mynbminer <- NBMiner(Agrawal.db, parameter = mynbparameters)
summary(mynbminer)

#Apriori
#Evaluating associations in a shopping basket

tr <- read.transactions("http://fimi.ua.ac.be/data/retail.dat",
                        format="basket")

summary(tr)
itemFrequencyPlot(tr, support=0.1)
rules <- apriori(tr, parameter=list(supp=0.5,conf=0.5))
summary(rules)
inspect(rules)
interestMeasure(rules, c("support", "chiSquare", "confidence",
                         "conviction", "cosine", "leverage", "lift", "oddsRatio"), tr)

#Determining sequences using TraMineR

#Determining sequences in training and careers
install.packages("TraMineR")
library(TraMineR)
data(mvad)
summary(mvad)

myseq <- seqdef(mvad, 17:86)

seqiplot(myseq)
seqfplot(myseq)
seqdplot(myseq)
seqHtplot(myseq)

myturbulence <- seqST(myseq)
hist(myturbulence)

#Similarities in the sequence
data(famform)
seq <- seqdef(famform)
seqLLCP(seq[3,],seq[4,])
seqLLCS(seq[1,],seq[2,])
cost <- seqsubm(seq, method="CONSTANT", cval=2)
cost

















