require("MASS")
require("plyr")
require("reshape2")
require("ggplot2")

# Set a seed for repeatable plots
set.seed(12345)

# 	a covariance matrix
calcSigma <- function(X1,X2,l=5,s=0.5) {
  Sigma <- matrix(rep(0, length(X1)*length(X2)), nrow=length(X1))
  for (i in 1:nrow(Sigma)) {
    for (j in 1:ncol(Sigma)) {
      Sigma[i,j] <- exp(-s*(abs(X1[i]-X2[j])/l)^2)
    }
  }
  return(Sigma)
}

# Define the points at which we want to define the functions
x.star <- seq(1,50,len=100)
# Calculate the covariance matrix
sigma <- calcSigma(x.star,x.star)

# Generate a number of functions from the process
n.samples <- 10
values <- matrix(rep(0,length(x.star)*n.samples), ncol=n.samples)
for (i in 1:n.samples) {
  # Each column represents a sample from a multivariate normal distribution
  # with zero mean and covariance sigma
  values[,i] <- mvrnorm(1, rep(0, length(x.star)), sigma)
}
values <- cbind(x=x.star,as.data.frame(values))
values <- melt(values,id="x")

# Plot the result
ggplot(values,aes(x=x,y=value)) +
  geom_rect(xmin=-Inf, xmax=Inf, ymin=-2, ymax=2, 
            fill="grey90", alpha = 0.5) +
  geom_line(aes(group=variable)) +
  theme_bw() +
  scale_y_continuous(lim=c(-2.5,2.5), name="output, f(x)") +
  xlab("input, x")

# 2. Now let's assume that we have some known data points;
# this is the case of Figure 2.2(b). In the book, the notation 'f'
# is used for f$y below.  I've done this to make the ggplot code
# easier later on.
f <- data.frame(x=c(1,2,3,4,5,6,7),
                y=c(0,0.2,0.4,-0.3,0,0.3,0.4))

# Calculate the covariance matrices
# using the same x.star values as above
x <- f$x
k.xx <- calcSigma(x,x)
k.xxs <- calcSigma(x,x.star)
k.xsx <- calcSigma(x.star,x)
k.xsxs <- calcSigma(x.star,x.star)

# These matrix calculations correspond to equation (2.19)
# in the book.
f.star.bar <- k.xsx%*%solve(k.xx)%*%f$y
cov.f.star <- k.xsxs - k.xsx%*%solve(k.xx)%*%k.xxs

# This time we'll plot more samples.  We could of course
# simply plot a +/- 2 standard deviation confidence interval
# as in the book but I want to show the samples explicitly here.
n.samples <- 50
values <- matrix(rep(0,length(x.star)*n.samples), ncol=n.samples)
for (i in 1:n.samples) {
  values[,i] <- mvrnorm(1, f.star.bar, cov.f.star)
}
values <- cbind(x=x.star,as.data.frame(values))
values <- melt(values,id="x")

# Plot the results including the mean function
# and constraining data points
ggplot() +
  geom_line(data=values, aes(x=x,y=value, group=variable), colour="grey80") +
  geom_line(data=NULL,aes(x=x.star,y=f.star.bar[,1]),colour="red", size=1) + 
  geom_point(data=f,aes(x=x,y=y)) +
  theme_bw() +
  # scale_y_continuous(lim=c(-3,3), name="output, f(x)") +
  xlab("input, x")

# 3. Now assume that each of the observed data points have some
# normally-distributed noise.

# The standard deviation of the noise AS VECTOR! length(f$y)
sigma.n <- c(0.1,0.1,0.3,0.3,0.5,0.7,0.85)

# Recalculate the mean and covariance functions
f.bar.star <- k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%f$y
cov.f.star <- k.xsxs - k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%k.xxs

# Recalulate the sample functions
values <- matrix(rep(0,length(x.star)*n.samples), ncol=n.samples)
for (i in 1:n.samples) {
  values[,i] <- mvrnorm(1, f.bar.star, cov.f.star)
}
values <- cbind(x=x.star,as.data.frame(values))
values <- melt(values,id="x")

ggplot() + 
  geom_line(data=values, aes(x=x,y=value,group=variable), colour="grey80") +
  geom_line(data=NULL,aes(x=x.star,y=f.bar.star[,1]),colour="red", size=1) + 
  geom_errorbar(data=f,aes(x=x,y=NULL,ymin=y-2*sigma.n, ymax=y+2*sigma.n), width=0.2) +
  geom_point(data=f,aes(x=x,y=y)) +
  theme_bw() +
  # scale_y_continuous(lim=c(-3,3), name="output, f(x)") +
  xlab("input, x")




# Recalculate the mean and covariance functions
f.bar.star <- k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%f$y
cov.f.star <- k.xsxs - k.xsx%*%solve(k.xx + sigma.n^2*diag(1, ncol(k.xx)))%*%k.xxs

