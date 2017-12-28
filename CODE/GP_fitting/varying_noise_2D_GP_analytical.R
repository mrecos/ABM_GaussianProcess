########################################################################################
### 'Noise-free' gaussian process demo.  The matrix labeling is in keeping with      ###
### Murphy 2012 and Rasmussen and Williams 2006.  See those sources for more detail. ###
### Murphy's matlab code can be found here: https://code.google.com/p/pmtk3/, though ###
### the relevant files are housed alongside this code.                               ###
###                                                                                  ###
### The goal of this code is to plot samples from the prior and posterior predictive ###
### of a gaussian process in which y = sin(x). It will reproduce figure 15.2 in      ###
### Murphy 2012 and 2.2 in Rasmussen and Williams 2006.                              ###
########################################################################################

########## MDH - THIS IS (SO FAR) THE BEST WORKING 2D CODE I HAVE ##########################

#################
### Functions ###
#################

# the mean function; in this case mean=0
muFn = function(x){
  x = sapply(x, function(x) x=0)
  x
}

# The covariance function; here it is the squared exponential kernel.
# l is the horizontal scale, sigmaf is the vertical scale.
# See ?covSEiso in the gpr package for example, which is also based on Rasmussen and
# Williams Matlab code (gpml Matlab library)

Kfn = function(x, l=1, sigmaf=1){
  sigmaf * exp( -(1/(2*l^2)) * as.matrix(dist(x, upper=T, diag=T)^2) )
}

rbf_D <- function(X, Y = NULL, sigmaf = 1, l=1, eps = sqrt(.Machine$double.eps), diag = TRUE){
  if(is.null(Y)){
    D <- plgp::distance(X)
  } else {
    D <- plgp::distance(X, Y)
  }
  sigmaf * exp( -(1/(2*l^2)) * as.matrix(D^2) )
}

#####################
### Preliminaries ###
#####################

l = 0.1          # for l, sigmaf, see note at covariance function
sigmaf = 5      
keps = 1e-8     # see note at Kstarstar
nprior = 5      # number of prior draws
npostpred = 2  # number of posterior predictive draws

##################
### Prior plot ###
##################

# data setup
require(MASS)
xg1 = seq(-5, 5, .2)
yg1 = mvrnorm(nprior, mu=muFn(xg1), Sigma=Kfn(xg1, l=l, sigmaf=sigmaf)) 

# plot prior
library(ggplot2); library(reshape2)

# reshape data for plotting
gdat = melt(data.frame(x=xg1, y=t(yg1), sd=apply(yg1, 2, sd)), id=c('x', 'sd'))
# head(gdat) # inspect if desired

g1 = ggplot(aes(x=x, y=value), data=gdat) + 
  geom_line(aes(group=variable), color='#FF5500', alpha=.5) +
  labs(title='Prior') +
  theme_bw()
# g1

#########################################
### generate noise-less training data ###
#########################################

########### WORK IN PROGRESS TO GET 2D HERE````````````

# Xtrain = c(-4, -3, -2, -1, 1)
# ytrain = sin(Xtrain)
Xtrain_seq = seq(-5, 5, 0.2)
Xtrain = as.matrix(expand.grid(Xtrain_seq, Xtrain_seq))  # N
ytrain <- rnorm(nrow(Xtrain),0,0.1)
ytrain[which(Xtrain[,1] == 0 & Xtrain[,2] == 0)] <- 2.5
nTrain = nrow(Xtrain)

Xtest_seq = seq(-5, 5, 1)
Xtest <- as.matrix(expand.grid(Xtest_seq, Xtest_seq))    # N*
nTest = nrow(Xtest)

# The standard deviation of the noise AS VECTOR! length(Xtrain)
# sigma_n <- rep(0.2, nrow(Xtrain))
sigma_n <- sample(seq(0.1,0.9,0.05), nrow(Xtrain), replace = TRUE)

#####################################
### generate posterior predictive ###
#####################################

########### WORK IN PROGRESS TO GET 2D HERE````````````

# Create K, K*, and K** matrices as defined in the texts
K = Kfn(Xtrain, l=l, sigmaf=sigmaf)                                            # Dim N x N
K_ = Kfn(rbind(Xtrain, Xtest), l=l, sigmaf=sigmaf)                                 # initial matrix
# K_ <- rbf_D(Xtrain, Xtest, l=l, sigmaf = sigmaf)
Kstar = K_[1:nTrain, (nTrain+1):ncol(K_)]                                      # dim = N x N*
tKstar = t(Kstar)                                                              # dim = N* x N
Kstarstar = K_[(nTrain+1):nrow(K_), (nTrain+1):ncol(K_)] + keps*diag(nTest)    # dim = N* x N*; the keps part is for positive definiteness
Kinv = solve(K + sigma_n^2 * diag(1, ncol(K)))

# calculate posterior mean and covariance
postMu = muFn(Xtest[,1]) + tKstar %*% Kinv %*% (ytrain-muFn(Xtrain[,1])) # (N x N*) %*% (N x N) %*% N
postCov = Kstarstar - t(Kstar) %*% Kinv %*% Kstar
s2 = diag(postCov)
# R = chol(postCov)  
# L = t(R)      # L is used in alternative formulation below based on gaussSample.m

# generate draws from posterior predictive
y2 = data.frame(t(mvrnorm(npostpred, mu=postMu, Sigma=postCov)))
# y2 = data.frame(replicate(npostpred, postMu + L %*% rnorm(postMu))) # alternative


#################################
### Posterior predictive plot ###
#################################

# reshape data for plotting
gdat = melt(data.frame(x1=Xtest[,1], x2=Xtest[,2], y=y2[,1], selower=postMu-2*sqrt(s2), seupper=postMu+2*sqrt(s2)),
            id=c('x1', 'x2', 'selower', 'seupper'))

g2 <- ggplot(data = gdat, aes(x=x1,y=x2)) +
  geom_raster(aes(fill=value), interpolate = TRUE) +
  geom_contour(aes(z=value), bins = 12, color = "gray30", 
               size = 0.5, alpha = 0.5) +
  geom_point(aes(size = value)) +
  coord_equal() +
  scale_x_continuous(expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) +
  scale_fill_viridis_c(option = "viridis")
# g2

####################################################
### Plot prior and posterior predictive together ###
####################################################

library(gridExtra)
grid.arrange(g1, g2, ncol=2)

############# NOT 100% sure which of test and train goes where to make this useful just yet #######
library("rgl")
open3d()
bg3d("white")
material3d(col = "black")
z <- matrix(y2[,1], nrow = length(Xtest_seq))
persp3d(Xtest_seq, Xtest_seq, z, aspect = c(1, 1, 0.5), col="lightgray", smooth=TRUE)
spheres3d(x = Xtest[,1], y = Xtest[,2], z = y2[,1], radius = 0.1, color = "red")

