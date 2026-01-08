## Status: product kernel prior section works. multiple lenght scale, varying index, 3d plot, all works
## Need to work through section where we fit data. and make it all work with one kernel function
## kernel has sigma in it now, but not same form as exp(-s*(abs(X1[i]-X2[j])/l)^2); ^2 is different
### works for prior, but sigma acts in the opposite as I thought it should; smaller = less wiggle. look into
### hyperparams not working for conditioning on data

library("ggplot2") # plotting
library("plgp")    # for distance() function
library("lhs")     # for siulating new data

# kernel function
rbf_D <- function(X, X_prime = NULL, s = 0.5, l=5, eps = sqrt(.Machine$double.eps), diag = TRUE){
  if(is.null(X_prime)){
    D <- plgp::distance(X)
  } else if(!is.null(X_prime)){
    D <- plgp::distance(X, X_prime)
  }
  Sigma <- exp(s*(-D/l))^2
  if(!isTRUE(diag)){
    return(Sigma)
  } else {
    Sigma <- Sigma + diag(eps, nrow(X))
    return(Sigma)
  }
  # Sigma <- exp(-D/l)^2 + diag(eps, nrow(X)) # works, hold on to for a moment
  
}

# prior
n = 40
eps = sqrt(.Machine$double.eps)
           
x1_star <- seq(0, 4, length = n)
x2_star <- seq(0, 4, length = n)
X12 <- expand.grid(x1_star, x2_star)
Sigma12 <- rbf_D(X12,l=0.5)
X21 <- expand.grid(x2_star, x1_star)
Sigma21 <- rbf_D(X21,l=10)
Sigma <- Sigma12 * Sigma21 # product kernel
Y_prior <- MASS::mvrnorm(1,rep(0,dim(Sigma)[1]), Sigma)
prior_plot <- data.frame(y=Y_prior,x1=X12[,1],x2=X12[,2])
ggplot(prior_plot, aes(x=x1, y=x2)) +
  geom_raster(aes(fill=y), interpolate = TRUE) +
  geom_contour(aes(z=y), bins = 12, color = "gray30", 
               size = 0.5, alpha = 0.5) +
  coord_fixed(ratio = max(x1_star)/max(x2_star)) +
  scale_x_continuous(expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) +
  scale_fill_viridis_c(option = "viridis")
# perspective plot
persp(x1_star,x2_star, matrix(Y_prior, ncol=n), 
      theta=-50,phi=30,xlab="x1",ylab="x2",zlab="y")

# library("rgl")
# open3d()
# bg3d("white")
# material3d(col = "black")
# z <- matrix(Y_prior, nrow = n)
# persp3d(x1_star,x2_star, z, aspect = c(1, 1, 0.5), col="lightgray", smooth=TRUE)

# sim X data
Xn = 15
X <- randomLHS(Xn, 2)
X[,1] <- (X[,1] - 0.5)*6 + 1
X[,2] <- (X[,2] - 0.5)*6 + 1
# sim Y from X
y <- X[,1] * exp(-X[,1]^2 - X[,2]^2)
# sim XX data (the domain of the model)
xx <- seq(-2,4, length = n)
XX <- expand.grid(xx, xx)

# k.xx
Sigma <- rbf_D(X, s=1, l=1, diag = FALSE)
# k.xsxs
SXX <- rbf_D(XX, s=1, l=1, diag = TRUE)
# k.xsx and t(k.xsx) = k.xxs
SX <- rbf_D(X = XX, X_prime = X, s=1, l=1, diag = FALSE)
# k.xx^-1
Si <- solve(Sigma)
# fit
mup <- SX %*% Si %*% y # k.xsx%*%solve(k.xx)%*%f$y
Sigmap <- SXX - SX %*% Si %*% t(SX) # k.xsxs - k.xsx%*%solve(k.xx)%*%k.xxs
sdp <- sqrt(diag(Sigmap))
YY2 <- MASS::mvrnorm(1,mup,Sigmap)

pp <- data.frame(y=YY2,x1=XX[,1],x2=XX[,2])
ggplot(data = pp,aes(x=x1,y=x2)) +
  geom_raster(aes(fill=y), interpolate = TRUE) +
  geom_contour(aes(z=y), bins = 12, color = "gray30", 
               size = 0.5, alpha = 0.5) +
  geom_point(data = data.frame(x1=X[,1], x2=X[,2], y = y), 
             aes(x=x1,y=x2, size = y)) +
  coord_equal() +
  scale_x_continuous(expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) +
  scale_fill_viridis_c(option = "viridis")

open3d()
bg3d("white")
material3d(col = "black")
z <- matrix(YY2, nrow = length(xx))
persp3d(xx,xx, z, aspect = c(1, 1, 0.5), col="lightgray", smooth=TRUE)
spheres3d(X[,1],X[,2],y,col="red", radius = 0.1)

