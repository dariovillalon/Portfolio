#Chapter 9. Bayesian Modeling at Big Data Scale

#The parallel R package

nsquare <- function(n){return(n*n)}
range <- c(1:100000)
system.time(lapply(range,nsquare))

library(parallel) 

numCores<-detectCores( ) #to find the number of cores in the machine
system.time(mclapply(range,nsquare,mc.cores=numCores))

#The foreach R package

install.packages("foreach")#one time
install.packages("doParallel")#one time
library(foreach)
library(doParallel)

system.time(foreach(i=1:100000) %do% i^2) #for executing sequentially
system.time(foreach(i=1:100000) %dopar% i^2) #for executing in parallel

#another example
qsort<- function(x) {
  n <- length(x)
  if (n == 0) {
    x
  } else {
    p <- sample(n,1)
    smaller <- foreach(y=x[-p],.combine=c) %:% when(y <= x[p]) %do% y
    larger <- foreach(y=x[-p],.combine=c) %:% when(y > x[p]) %do% y
    c(qsort(smaller),x[p],qsort(larger))
  }
}

qsort(runif(12))








