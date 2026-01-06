# library(devtools)
# install_github('goldingn/gpe')
library("gpe")

# Create an rbf kernel which acts on some variable named temperature
k1 <- rbf('temperature')
# look at the parameters
summary(k1)
# plot covariance
plot(k1)
# look at some GPs drawn from this kernel
demoKernel(k1)

# create a linear kernel
k2 <- lin('temperature')
# change a parameter
k2 <- setParameters(k2, sigma = 0.5)
# plot draws from it
demoKernel(k2)
# a GP model with a linear kernel is the same as (Bayesian) linear regression

# add the two together
k3 <- k1 + k2
# and visualise them
demoKernel(k3)
# this is the same as adding the random draws together

# multiply this by a periodic kernel
k4 <- k3 * per('temperature')
# visualise this one
plot(k4)
demoKernel(k4)

# make a fake 'true' function
f <- function(x) 2 * sin(x)

# make a fake dataset
x1 <- seq(-2,2,length.out=10)
x2 <- seq(-2,2,length.out=10)
xx <- expand.grid(x1,x2)
y <- rpois(nrow(xx), exp(f(xx[,1])) + exp(f(xx[,2])))
df <- data.frame(y, x1 = xx[,1], x2 = xx[,2] )

x1_k <- rbf('x1')
x1_k <- setParameters(x1_k, sigma = 1, l = 0.5)
x2_k <- rbf('x2')
x3 <- x1_k * x2_k

# fit a Poisson GP model with an rbf kernel
m <- gp(y ~ x3, data = df, family = poisson)

# predict from it
pred_df <- df[,c("x1","x2")] #data.frame(x = seq(min(df$x1), max(df$x1), len = 500))
lambda <- predict(m, pred_df, type = 'response', sd = TRUE)
df$y_hat <- lambda$fit
df$y_hat_low  <- df$y_hat-2*sqrt(lambda$sd)
df$y_hat_high <- df$y_hat+2*sqrt(lambda$sd)
library("tidyverse")
ggplot(df, aes(x=x1,y=x2,fill=y_hat)) +
  geom_point() +
  geom_raster()
# 
# library("rgl")
# open3d()
# bg3d("white")
# material3d(col = "black")
z      <- matrix(df$y_hat, nrow = length(x1))
z_high <- matrix(df$y_hat_high, nrow = length(x1))
z_low  <- matrix(df$y_hat_low, nrow = length(x1))
persp3d(x1, x2, z, aspect = c(1, 1, 0.5), col="lightgray", smooth=TRUE)
surface3d(x1, x2, z_high, aspect = c(1, 1, 0.5), col="orange", smooth=TRUE, alpha = 0.35)
surface3d(x1, x2, z_low, aspect = c(1, 1, 0.5), col="blue", smooth=TRUE, alpha = 0.35)
spheres3d(x = pred_df[,1], y = pred_df[,2], z = df$y, radius = 0.06, color = "red")
# movie3d(spin3d(axis = c(0,0,1), rpm = 8), duration=7.5,  fps = 20,
#         type = "png", dir = "~/Documents/tmp")

