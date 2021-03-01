#Used Cars

#Clean de variable environment
rm(list = ls(all = TRUE)) 

#Get the data from CSV
cars_data <- read.csv("C:/Users/Administrator/Desktop/projects/machin-learning-brett-lantz/usedcars.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)

#Check cars_data structure
str(cars_data)

#Get some statistics
summary(cars_data[c("year", "price", "mileage")])
        
#Get range of price
rang <- diff(range(cars_data$price))

#Get interquartile range
IQR(cars_data$price)

#Boxplot price and mileage
boxplot(cars_data$price, main  = "Boxplot of Used Cars Prices", ylab = "Prices ($)")
boxplot(cars_data$mileage, main  = "Boxplot of Used Cars Mileages", ylab = "Mileage")

#Plot histograms
hist(cars_data$price, main = "Histogram of Used Car Prices",
     xlab = "Price ($)")


hist(cars_data$mileage, main = "Histogram of Used Car Mileage",
     xlab = "Odometer (mi.)")

#compute variance
var(cars_data$price)
var(cars_data$mileage)

#compute standard deviation
sd(cars_data$price)
sd(cars_data$mileage)

#categorical data treatment

#tables
table(cars_data$year)
table(cars_data$model)
table(cars_data$transmission)
table(cars_data$color)

#proportions

round(prop.table(table(cars_data$year)) * 100, digits = 2)
round(prop.table(table(cars_data$model)) * 100, digits = 2) 

#draw scatterplot 
plot(cars_data$price,cars_data$mileage)
plot(cars_data$mileage,cars_data$price)

#check relations among categorical features
install.packages("gmodels")
library("gmodels")

cars_data$consevative <- cars_data$color %in% c("Black", "Gray", 
                                                "Silver", "White")

CrossTable(x = cars_data$model, y = cars_data$consevative, chisq = TRUE)








