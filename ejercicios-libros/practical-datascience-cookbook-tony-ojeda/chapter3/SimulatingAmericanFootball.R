#Simulating American Football Data

#Installing and including packages
list.of.packages <- c("XML", "RSQLite", "stringr", "ggplot2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(XML)
library(RSQLite)
library(stringr)
library(ggplot2)

##Getting OFFENSE data
year <- 2013
url <- paste("http://sports.yahoo.com/nfl/stats/byteam?group=Offense&
        cat=Total&conference=NFL&year=season_",year,"&sort=530&old_cat
        egory=Total&old_group=Offense")

offense <- readHTMLTable(url, encoding = "UTF-8",
                         colClasses="character")[[7]]

#Cleaning OFFENSE dataset
offense <- offense[,-c(2,4,6,8,10,12,14,16,18,20,22,24,26,28)]
offense[,1] <- as.character(offense[,1])
offense[,2:13] <- apply(offense[,2:13],2,as.numeric)
offense[,14] <- as.numeric(substr(offense[,14], 1, 2))*60 +
  as.numeric(substr(offense[,14], 4, 6))

#Getting DEFENSE data
url <- paste("http://sports.yahoo.com/nfl/stats/byteam?group=Defense&
        cat=Total&conference=NFL&year=season_",year,"&sort=530&old_cat
        egory=Total&old_group=Defense")

defense <- readHTMLTable(url, encoding = "UTF-8", colClasses="character")[[7]]

#Cleaning DEFENSE dataset
defense <- defense[,-c(2,4,6,8,10,12,14,16,18,20,22,24,26)]
defense[,1] <- as.character(defense[,1])
defense[,2:13] <- apply(defense[,2:13],2,as.numeric)

#Combine both datasets
combined <- merge(offense, defense, by.x="Team", by.y="Team")

#Data cleaning- delete redundant fields-change names
colnames(combined)[2] <- "Games"
colnames(combined)[3] <- "OffPPG"
colnames(combined)[4] <- "OffYPG"
colnames(combined)[5] <- "OffPassYPG"
colnames(combined)[6] <- "OffRushYPG"
combined$G.y <- NULL
colnames(combined)[15] <- "DefPPG"
colnames(combined)[16] <- "DefYPG"
colnames(combined)[17] <- "DefRushYPG"
colnames(combined)[18] <- "DefPassYPG"

#Exploring data

#let's create a histogram of offensive points per game by each team
plot1 <- hist(combined$OffPPG, breaks=10, main="Offensive Points Per Game", 
     xlab="Offensive PPG",ylab="Number of Teams")
plot1

mean(combined$OffPPG)
sd(combined$OffPPG)
max(combined$OffPPG)
min(combined$OffPPG)

#let's see how points allowed per game, a defensive statistic
#are distributed

plot2 <- hist(combined$DefPPG, breaks=10, main="Defensive Points Per
Game", xlab="Defensive PPG",ylab="Number of Teams")
plot2

plot3 <- hist(combined$"1stD/G", breaks=10, main="Offensive 1st Downs
Per Game", xlab="1st Downs/Game",ylab="Number of Teams")
plot3

#Let's start off by creating a bar chart for offensive points per game
ppg <- transform(combined,Team=reorder(Team,combined$OffPPG))

plot4 <- ggplot(ppg,aes(x=Team, y=OffPPG)) +
            geom_bar(stat='identity',color="black",fill="blue") +
            coord_flip() + labs(x="Team",y="Avg Points per Game") +
            ggtitle("Avg Points per Game") + theme(plot.title =
            element_text(size=18, face="bold"))
plot4

#let's try another bar graph for defense yards allowed per game
ypg <- transform(combined,Team=reorder(Team,-combined$DefYPG))

plot5 <- ggplot(ypg,aes(x=Team, y=DefYPG)) +
              geom_bar(stat='identity',color="black",fill="blue") +
              coord_flip() + labs(x="Team",y="Avg Yards Allowed per Game") +
              ggtitle("Avg Yards Allowed per Game") + theme(plot.title =
              element_text(size=18, face="bold"))
plot5

#let's see how offensive yards and offensive points per game
#are related
plot6 <- ggplot(combined, aes(x=combined$OffYPG, y=combined$OffPPG)) +
            geom_point(shape=5, size=2) + geom_smooth() +
            labs(x="Yards per Game",y="Points per Game") +
            ggtitle("Offense Yards vs. Points per Game") +
            theme(plot.title = element_text(size=18, face="bold"))
plot6

cor(combined$OffYPG,combined$OffPPG)

#Let's look at whether the same is true for defense for yards allowed
#and points allowed per game.
plot7 <- ggplot(combined, aes(x=combined$DefYPG, y=combined$DefPPG)) +
            geom_point(shape=5, size=2) + geom_smooth() +
            labs(x="Yards Allowed per Game",y="Points Alloed per Game") +
            ggtitle("Defense Yards vs. Points per Game") +
            theme(plot.title = element_text(size=18, face="bold"))
plot7

cor(combined$DefYPG, combined$DefPPG)

#we can scatter plot time of possession and offensive points per game

plot8 <- ggplot(combined, aes(x=combined$TOP, y=combined$OffPPG)) +
            geom_point(shape=5, size=2) + geom_smooth() +
            labs(x="Time of Possession (Seconds)",y="Points per Game") +
            ggtitle("Time of Possession vs. Points per Game") +
            theme(plot.title = element_text(size=18, face="bold"))
plot8

cor(combined$TOP,combined$OffPPG)

#calculate an offensive passing strength score
offense$OPassStrength <- max(offense[,5])-offense[,5]
offense$OPassStrength <- (1-(offense$OPassStrength/max(offense$OPassStrength)))*100


#calculate offensive rushing strength
offense$ORushStrength <- max(offense[,6])-offense[,6]
offense$ORushStrength <- (1-(offense$ORushStrength/max(offense$ORushStrength)))*100

# let's choose points and yards per game:
#took the average of each of the index values we
#calculated previously to come up with the offensive strength index
offense$OPPGStrength <- max(offense[,3])-offense[,3]
offense$OPPGStrength <- (1-(offense$OPPGStrength/max(offense$OPPGStrength)))*100
offense$OYPGStrength <- max(offense[,4])-offense[,4]
offense$OYPGStrength <- (1-(offense$OYPGStrength/max(offense$OYPGStrength)))*100
offense$OffStrength <- (offense$OPassStrength+offense$ORushStrength+offense$OPPGStrength+offense$OYPGStrength)/4

#calculating a passing defense strength index from the number of passing 
#yards allowed per game figures

defense$DPassStrength <- max(defense[,6])-defense[,6]
defense$DPassStrength <- defense$DPassStrength/max(defense$DPassStrength)*100

#we'll do the same thing with rushing defense strength
defense$DRushStrength <- max(defense[,5])-defense[,5]
defense$DRushStrength <- defense$DRushStrength/max(defense$DRushStrength)*100


#we will calculate indexes using points allowed per game and total
#yards allowed per game before averaging all four to arrive at an overall
#defensive strength index

defense$DPPGStrength <- max(defense[,3])-defense[,3]
defense$DPPGStrength <- defense$DPPGStrength/max(defense$DPPGStrength)*100
defense$DYPGStrength <- max(defense[,4])-defense[,4]
defense$DYPGStrength <- defense$DYPGStrength/max(defense$DYPGStrength)*100
defense$DefStrength <- (defense$DPassStrength+defense$DRushStrength+defense$DPPGStrength+defense$DYPGStrength)/4

#single game simulation---------------------------------

#we will do is designate which two teams will play
home_team <- "Chicago Bears"
away_team <- "New Orleans Saints"

#we will bring together the offensive and defensive strengths we calculated
off_game <- subset(offense,Team==home_team | Team==away_team)[,c(1,15,16,19)]
def_game <- subset(defense,Team==home_team | Team==away_team)[,c(1,14,15,18)]
game <- merge(off_game,def_game,by.x="Team",by.y="Team")


#determine which team is the stronger of the two 
game$Net_Pass[game$Team==home_team] <- game$OPassStrength[game$Team==home_team] -
  game$DPassStrength[game$Team==away_team]
game$Net_Pass[game$Team==away_team] <- game$OPassStrength[game$Team==away_team] -
  game$DPassStrength[game$Team==home_team]

#we will perform the exact same calculations for the rushing strength 
#of each team and for their total strength

game$Net_Rush[game$Team==home_team] <- game$ORushStrength[game$Team==home_team] -
  game$DRushStrength[game$Team==away_team]
game$Net_Rush[game$Team==away_team] <- game$ORushStrength[game$Team==away_team] -
  game$DRushStrength[game$Team==home_team]
game$Net_Total[game$Team==home_team] <- game$OffStrength[game$Team==home_team] -
  game$DefStrength[game$Team==away_team]
game$Net_Total[game$Team==away_team] <- game$OffStrength[game$Team==away_team] -
  game$DefStrength[game$Team==home_team]


# let's overwrite the values in the Net_Total column with the sum of
#the three differences

game$Net_Total <- game$Net_Pass + game$Net_Rush + game$Net_Total

if(game$Net_Total[game$Team==home_team] >= game$Net_Total[game$Team==away_team]){
  
  winner <- home_team
  loser <- away_team
}else{
  
  winner <- away_team
  loser <- home_team
}

print(paste(winner, "beat", loser))


#Simulating multiple games with outcomes decided by calculations

#create a schedule of games to know which teams are going to play each other.
games_per_team <- 50

for(week in 1:games_per_team){
  home_index <- sample(1:32, 16, replace=F)
  home_teams <- data.frame(HomeTeam=offense[home_index, 1])
  away_teams <- data.frame(AwayTeam=offense[-home_index, 1])
  
  if(week==1){
    schedule <- cbind(Week=week,HomeTeam=home_teams,AwayTeam=away_teams)
  }else{
    temp <- cbind(Week=week,HomeTeam=home_teams,AwayTeam=away_teams)
    schedule <- rbind(schedule,temp)
  }
}

#we will create a team record tracker that will track the number of wins
#and losses for each team
records <- data.frame(Team=offense$Team)
records$Wins <- 0
records$Losses <- 0

#we need to have our program play out each of the games in the schedule,
#and then update the Wins and Losses columns for the winning and losing 
#teams, respectively.
for(i in 1:nrow(schedule)){
  
  home_team <- schedule[i,2]
  away_team <- schedule[i,3]
  week <- schedule[i,1]
  
  off_game <- subset(offense,Team==home_team | Team==away_team)[,c(1,15,16,19)]
  def_game <- subset(defense,Team==home_team | Team==away_team)[,c(1,14,15,18)]
  game <- merge(off_game,def_game,by.x="Team",by.y="Team")
  
  game$Net_Pass[game$Team==home_team] <- game$OPassStrength[game$Team==home_team] - game$DPassStrength[game$Team==away_team]
  game$Net_Pass[game$Team==away_team] <- game$OPassStrength[game$Team==away_team] - game$DPassStrength[game$Team==home_team]
  game$Net_Rush[game$Team==home_team] <- game$ORushStrength[game$Team==home_team] - game$DRushStrength[game$Team==away_team]
  game$Net_Rush[game$Team==away_team] <- game$ORushStrength[game$Team==away_team] - game$DRushStrength[game$Team==home_team]
  game$Net_Total[game$Team==home_team] <- game$OffStrength[game$Team==home_team] - game$DefStrength[game$Team==away_team]
  game$Net_Total[game$Team==away_team] <- game$OffStrength[game$Team==away_team] - game$DefStrength[game$Team==home_team]
  
  game$Net_Total <- game$Net_Pass + game$Net_Rush + game$Net_Total
  
  if(game$Net_Total[game$Team==home_team] >= game$Net_Total[game$Team==away_team]){
    
    winner <- home_team
    loser <- away_team
  }else{
    
    winner <- away_team
    loser <- home_team
  }

  if(i==1){
    winnerdf <- data.frame(Winner=winner)
    loserdf <- data.frame(Loser=loser)
    results <- cbind(winnerdf,loserdf)
  }else{
    winnerdf <- data.frame(Winner=winner)
    loserdf <- data.frame(Loser=loser)
    temp <- cbind(winnerdf,loserdf)
    results <- rbind(results,temp)
  }
  records$Wins[records$Team==winner] <- as.numeric(records$Wins[records$Team==winner]) + 1
  records$Losses[records$Team==loser] <- as.numeric(records$Losses[records$Team==loser]) + 1
  print(paste("Week", week,":", winner, "beat", loser))
}

records <- records[order(-records$Wins),]











