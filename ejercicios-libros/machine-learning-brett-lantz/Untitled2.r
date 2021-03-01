
## Machine Learning with R by Brett Lantz
## Chapter 11: Improving model performance

#Creating a simple tuned model
credit <- read.csv("credit.csv")
credit$default <- as.factor(credit$default)
install.packages("caret", repos = "https://cran.r-project.org")
library(caret)
install.packages("C50", repos = "https://cran.r-project.org")
library(C50)

set.seed(300)
m <- train(default ~ ., data = credit, method = "C5.0")

m

p <- predict(m, credit)
table(p, credit$default)

head(predict(m, credit))


