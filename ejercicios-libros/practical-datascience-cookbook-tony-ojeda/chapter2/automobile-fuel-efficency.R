#Automobile fuel efficency

#Attributes description
#http://www.fueleconomy.gov/feg/ws/index.shtml#vehicle

#Installing and including packages
list.of.packages <- c("plyr", "ggplot2", "reshape2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(plyr)
library(ggplot2)
library(reshape2)

#Load dataset
vehicles <- read.csv(choose.files(), stringsAsFactors = F, header = T)

#Explore dataset
head(vehicles)

#Check attributes description
labels <- do.call(rbind, strsplit(readLines(choose.files()), " - "))
head(labels)

names(vehicles)

table(vehicles$fuelType1)

#check transmision and change to NA if transmision is not set
vehicles$trany[vehicles$trany == ""] <- NA


#creates a new column only with kind of transmision manual or auto
vehicles$trany2 <- ifelse(substr(vehicles$trany, 1, 4) == "Auto", "Auto", "Manual")
vehicles$trany2 <- as.factor(vehicles$trany2)
table(vehicles$trany2)

with(vehicles, table(sCharger, year))

class(vehicles$sCharger)
unique(vehicles$sCharger)

class(vehicles$tCharger)
unique(vehicles$tCharger)

# Let's start by looking at whether there is an overall trend of how MPG
#changes over time on an average.

mpgByYr <- ddply(vehicles, ~year, summarise, avgMPG =
                   mean(comb08), avgHghy = mean(highway08), avgCity =
                   mean(city08))

plot1 <- ggplot(mpgByYr, aes(year, avgMPG)) + geom_point() +
              geom_smooth() + xlab("Year") + ylab("Average MPG") +
              ggtitle("All cars")
plot1

table(vehicles$fuelType1)

#Lets just check gas type cars
gasCars <- subset(vehicles, fuelType1 %in% c("Regular", "Gasoline", 
                                             "Premium Gasoline",
                                             "Midgrade Gasoline") &
                    fuelType2 == "" & atvType != "Hybrid")


mpgByYr_Gas <- ddply(gasCars, ~year, summarise, avgMPG =
                       mean(comb08))


plot2 <- ggplot(mpgByYr_Gas, aes(year, avgMPG)) + geom_point() +
                geom_smooth() + xlab("Year") + ylab("Average MPG") +
                ggtitle("Gasoline cars")
plot2

#let's verify whether cars with larger engines have worse fuel efficiency.
typeof(gasCars$displ)
gasCars$displ <- as.numeric(gasCars$displ)

plot3 <- ggplot(gasCars, aes(displ, comb08)) + geom_point() +
            geom_smooth()
plot3
#smaller cars tend to be more fuel-efficient

#let's see whether more small cars were made in later years, 
#which can explain the drastic increase in fuel efficiency:

avgCarSize <- ddply(gasCars, ~year, summarise, avgDispl = mean(displ))

plot4 <- ggplot(avgCarSize, aes(year, avgDispl)) + geom_point() +
            geom_smooth() + xlab("Year") + ylab("Average engine
              displacement (l)")
plot4

#To get a better sense of the impact this might have had on fuel efficiency,
#we can put both MPG and displacement by year on the same graph.

byYear <- ddply(gasCars, ~year, summarise, avgMPG =
                  mean(comb08), avgDispl = mean(displ))
head(byYear)

#we convert from wide format to a long format
byYear2 <- melt(byYear, id = "year")
levels(byYear2$variable) <- c("Average MPG", "Avg engine
                              displacement")

plot5 <- ggplot(byYear2, aes(year, value)) + geom_point() +
                geom_smooth() + facet_wrap(~variable, ncol = 1, scales =
                "free_y") + xlab("Year") + ylab("")
plot5

#let's see whether automatic or manual transmissions are more efficient
#for four cylinder engines, and how the efficiencies have changed over time

gasCars4 <- subset(gasCars, cylinders == "4")

plot6 <- ggplot(gasCars4, aes(factor(year), comb08)) + 
            geom_boxplot() + facet_wrap(~trany2, ncol = 1) +
            theme(axis.text.x = element_text(angle = 45)) +
            labs(x = "Year", y = "MPG")
plot6


# let's look at the change in proportion of manual cars available 
#each year

plot7 <- ggplot(gasCars4, aes(factor(year), fill = factor(trany2))) +
              geom_bar(position = "fill") + 
              labs(x = "Year", y = "Proportion of cars", fill = "Transmission") +
              theme(axis.text.x = element_text(angle = 45)) + 
              geom_hline(yintercept = 0.5,linetype = 2)

plot7


#let's look at the frequency of the makes and models of cars available 
#in the US over this time and concentrate on four-cylinder cars


carsMake <- ddply(gasCars4, ~year, summarise, numberOfMakes = length(unique(make)))

plot8 <- ggplot(carsMake, aes(year, numberOfMakes)) + geom_point() +
              labs(x = "Year", y = "Number of available makes") + 
              ggtitle("Four cylinder cars")
plot8

uniqMakes <- dlply(gasCars4, ~year, function(x) unique(x$make))
commonMakes <- Reduce(intersect, uniqMakes)
commonMakes

#How have these manufacturers done over time with respect to fuel efficiency? 
carsCommonMakes4 <- subset(gasCars4, make %in% commonMakes)
avgMPG_commonMakes <- ddply(carsCommonMakes4, ~year + make,
                            summarise, avgMPG = mean(comb08))

plot9 <- ggplot(avgMPG_commonMakes, aes(year, avgMPG)) + geom_line() +
  facet_wrap(~make, nrow = 3)

plot9





