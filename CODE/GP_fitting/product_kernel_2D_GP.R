library("ggplot2")
library("plgp")
library("lhs") 

# kernel function
rbf_D <- function(X,l=1, eps = sqrt(.Machine$double.eps) ){
  D <- plgp::distance(X)
  Sigma <- exp(-D/l)^2 + diag(eps, nrow(X))
}

# prior
n = 40
eps = sqrt(.Machine$double.eps)
           
x1_star <- seq(0, 2, length = n)
x2_star <- seq(0, 4, length = n)
X12 <- expand.grid(x1_star, x2_star)
Sigma12 <- rbf_D(X12,l=2)
X21 <- expand.grid(x2_star, x1_star)
Sigma21 <- rbf_D(X21,l=2)
Sigma <- Sigma12 * Sigma21
Y_prior <- MASS::mvrnorm(1,rep(0,dim(Sigma)[1]), Sigma)
prior_plot <- data.frame(y=Y_prior,x1=X12[,1],x2=X12[,2])
ggplot(prior_plot, aes(x=x1, y=x2)) +
  geom_raster(aes(fill=y), interpolate = TRUE) +
  geom_contour(aes(z=y), bins = 12, color = "gray30", 
               size = 0.5, alpha = 0.5) +
  coord_fixed(ratio = max(x1.star)/max(x2.star)) +
  scale_x_continuous(expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) +
  scale_fill_viridis_c(option = "viridis")
# perspective plot
persp(x1_star,x2_star, matrix(Y_prior, ncol=n),
      theta=-50,phi=30,xlab="x1",ylab="x2",zlab="y")


# sim X data
X <- randomLHS(40, 2)
X[,1] <- (X[,1] - 0.5)*6 + 1
X[,2] <- (X[,2] - 0.5)*6 + 1
# sim Y from X
y <- X[,1] * exp(-X[,1]^2 - X[,2]^2)
# sim XX data
xx <- seq(-2,4, length=40)
XX <- expand.grid(xx, xx)

# k.xx
D <- distance(X)
Sigma <- exp(-D)
# k.xsxs
DXX <- distance(XX)
SXX <- exp(-DXX) + diag(eps, ncol(DXX))
# k.xsx and t(k.xsx) = k.xxs
DX <- distance(XX, X)
SX <- exp(-DX)
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
