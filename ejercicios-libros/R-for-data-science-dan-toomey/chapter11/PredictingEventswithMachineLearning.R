#Chapter 11: Predicting Events with Machine Learning
install.packages("pear")
library(pear)

fraser <- Fraser
plot(fraser, type = "p")
head(fraser)

fraserc <- decompose(fraser)
stl(fraser)

fraser.ts <- ts(fraser, frequency=12, start=c(1913,3))
fraser.ts

fraser.stl <- stl(fraser.ts, s.window="periodic")
fraser.stl
summary(fraser.stl)

monthplot(fraser.stl)

install.packages("forecast")
library(forecast)
seasonplot(fraser.ts)

#plot various components 
plot(fraser.stl)


#The SMA function

#smoothing
install.packages("TTR")
library(TTR)
fraser.SMA3 <- SMA(fraser,n=12)
plot(fraser.SMA3)

#stretching out to 5 years
fraser.SMA60 <- SMA(fraser,n=60)
plot(fraser.SMA60)

#The decompose function
#extracting specific seasonality

fraser.components <- decompose(fraser.ts)
fraser.adjusted <- fraser - fraser.components$season
plot(fraser.adjusted)

#Exponential smoothing
#short-term forecast with Holt-Winters filtering

fraser.forecast <- HoltWinters(fraser.ts, beta=FALSE)
fraser.forecast
#alpha is de smoothing factor
#beta value used is a flag whether to use exponential filtering or
#not-in our case, yes.
#gamma value is the calculated seasonality component.


#sum of squared error SSE
fraser.forecast$SSE
plot(fraser.forecast)

fraser.forecast$fitted

#Forecast
library(forecast)
fraser.forecast2 <- forecast.HoltWinters(fraser.forecast, h=8)
fraser.forecast2

plot.forecast(fraser.forecast2)

#Correlogram
#acf computes and plots the autocorrelation of data

acf(fraser.forecast2$residuals,lag.max=20)
#blue dotted line is 0.95 confidence interval

#Box test
Box.test(fraser.forecast2$residuals,lag=20,type="Ljung-Box")

plot.ts(fraser.forecast2$residuals)

#Holt exponential smoothing
sleep <- read.table("http://www.physionet.org/physiobank/database/santa-fe/b2.txt")
colnames(sleep) <- c("heart","chest","oxygen")
head(sleep)

sleepts <- ts(sleep)
plot.ts(sleepts)

heart.ts <- ts(sleep$heart)
heart.forecast <- HoltWinters(heart.ts, gamma=FALSE)
heart.forecast
#heart rate average at 58
#slight downward trend
plot(heart.forecast)

chest.ts <- ts(sleep$chest)
chest.forecast <- HoltWinters(chest.ts, gamma=FALSE)
chest.forecast
plot(chest.forecast)

oxygen.ts <- ts(sleep$oxygen)
oxygen.forecast <- HoltWinters(oxygen.ts, gamma=FALSE)
oxygen.forecast
plot(oxygen.forecast)


#Automated forecasting
#ets function automatically select exponential and ARIMA models

fraser.ets <- ets(fraser.ts)
summary(fraser.ets)

plot(fraser.ets)


#ARIMA
fraser.arima <- arima(fraser.ts, order=c(2,0,0))
summary(fraser.arima)
tsdisplay(arima.errors(fraser.arima))

#forecast with arima
fraser.farima <- forecast(fraser.arima, h=8)
summary(fraser.farima)
plot(fraser.farima)


#Automated ARIMA forecasting
fraser.aarima <- auto.arima(fraser.ts)
summary(fraser.aarima)
plot(fraser.aarima)

fraser.arima3 <- arima(fraser.ts, order=c(4,0,1),
                       seasonal=list(order=c(2,0,0), period=12))
summary(fraser.arima3)
fraser.farima3 <- forecast(fraser.arima3, h=8)
plot(fraser.farima3)
