#breast cancer classification

#Clean de variable environment
rm(list = ls(all = TRUE)) 

#Get the data from CSV
cancer <- read.csv("C:/Users/Administrator/Desktop/projects/machin-learning-brett-lantz/wisc_bc_data.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)

#exclude id feature / not important
cancer <- cancer[-1]

#check proportions of labels
table(cancer$diagnosis)
cancer$diagnosis <- factor(cancer$diagnosis, levels = c("B", "M"), labels = c("Benign", "Malignant"))
round(prop.table(table(cancer$diagnosis)) * 100, digit = 1)

#check summary of a few features
summary(cancer[c("radius_mean", "area_mean", "smoothness_mean")])

#plot some histograms
hist(cancer$radius_mean)
hist(cancer$area_mean)
hist(cancer$smoothness_mean)

#function to normalize features' values
normalize <- function(x) {
  
  range <- max(x) - min(x)
  return ((x - min(x)) / range)
}

#apply normalization function to dataset
cancer_norm <- as.data.frame(lapply(cancer[2:31], normalize))

#split into training set and test set
cancer_train <- cancer_norm[1:469,]
cancer_test <- cancer_norm[470:569,]

#build label vectors for training and test set

cancer_train_label <- cancer[1:469, 1]
cancer_test_label <- cancer[470:569, 1]

#install package class which performs some classification functions
install.packages("class")
library(class)


#implement knn

cancer_test_pred <- knn(train = cancer_train, test = cancer_test,
                   cl = cancer_train_label, 21)


#evaluating model performance

install.packages("gmodels")
library("gmodels")

CrossTable(x = cancer_test_label, y = cancer_test_pred, prop.chisq = FALSE)

#-------------------------------------------------------------
#scaling features using scale function

cancer_z <- as.data.frame(scale(cancer[-1]))

#split into training set and test set
cancer_train <- cancer_z[1:469,]
cancer_test <- cancer_z[470:569,]

#build label vectors for training and test set

cancer_train_label <- cancer[1:469, 1]
cancer_test_label <- cancer[470:569, 1]

#install package class which performs some classification functions
install.packages("class")
library(class)


#implement knn

cancer_test_pred <- knn(train = cancer_train, test = cancer_test,
                        cl = cancer_train_label, 15)


#evaluating model performance

#install.packages("gmodels")
#library("gmodels")

CrossTable(x = cancer_test_label, y = cancer_test_pred, prop.chisq = FALSE)










