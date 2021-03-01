#Chapter 3. Introducing Bayesian Inference

set.seed(100)
age_samples <- rnorm(10000,mean = 5.5,sd=0.5)
plot(age_samples)


#Calculate the posteriori distribution
age_mean <- function(n){
  mu0 <- 5
  sd0 <- 1
  mus <- mean(age_samples[1:n])
  sds <- sd(age_samples[1:n])
  mu_n <- (sd0^2/(sd0^2 + sds^2/n)) * mus + (sds^2/n/(sd0^2 + sds^2/n)) * mu0
  mu_n
}

samp <- c(25,50,100,200,400,500,1000,2000,5000,10000)
mu <- sapply(samp, age_mean, simplify = "array")

plot(samp,mu,type="b",col="blue",ylim=c(5.3,5.7),xlab="no of samples",ylab="estimate of mean")
abline(5.5,0)

#This time we will estimate the posterior distribution by using the Metropolis-Hasting
#algorithm.

#function to compute log likelihood
loglikelihood <- function(x,mu,sigma){
    singlell <- dnorm(x,mean = mu,sd = sigma,log = T)
    sumll <- sum(singlell)
    sumll
}

#function to compute prior distribution for mean on log scale
d_prior_mu <- function(mu){
  dnorm(mu,0,10,log=T)
}

#function to compute prior distribution for std dev on log scale
d_prior_sigma <- function(sigma){
  dunif(sigma,0,5,log=T)
}

#function to compute posterior distribution on log scale
d_posterior <- function(x,mu,sigma){
  loglikelihood(x,mu,sigma) + d_prior_mu(mu) + d_prior_sigma(sigma)
}

#function to make transition moves
tran_move <- function(x,dist = .1){
    x + rnorm(1,0,dist)
}


num_iter <- 10000
posterior <- array(dim = c(2,num_iter))
accepted <- array(dim=num_iter - 1)
theta_posterior <-array(dim=c(2,num_iter))
values_initial <- list(mu = runif(1,4,8),sigma = runif(1,1,5))
theta_posterior[1,1] <- values_initial$mu
theta_posterior[2,1] <- values_initial$sigma
for (t in 2:num_iter){
  #proposed next values for parameters
  theta_proposed <- c(tran_move(theta_posterior[1,t-1]),tran_move(theta_posterior[2,t-1]))
  p_proposed <- d_posterior(age_samples,mu = theta_proposed[1],sigma = theta_proposed[2])
  p_prev <- d_posterior(age_samples,mu = theta_posterior[1,t-1],sigma = theta_posterior[2,t-1])
  eps <- exp(p_proposed - p_prev)
  # proposal is accepted if posterior density is higher w/theta_proposed
  # if posterior density is not higher, it is accepted with probability eps
  accept <- rbinom(1,1,prob = min(eps,1))
  accepted[t - 1] <- accept
  if (accept == 1){
    theta_posterior[,t] <- theta_proposed
  } else {
    theta_posterior[,t] <- theta_posterior[,t-1]
  }
}


install.packages("sm")
library(sm)

x <- cbind(c(theta_posterior[1,1:num_iter]),c(theta_posterior[2,1:num_iter]))
xlim <- c(min(x[,1]),max(x[,1]))
ylim <- c(min(x[,2]),max(x[,2]))
zlim <- c(0,max(1))

sm.density(x, xlab = "mu",ylab="sigma", zlab = " ",zlim = zlim,
           xlim = xlim ,ylim = ylim,col="white")

title("Posterior density")
