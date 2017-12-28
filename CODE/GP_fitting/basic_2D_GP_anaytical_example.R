# http://bobby.gramacy.com/teaching/rsm/lect6.html#1
library("ggplot2")
library("plgp") 
library("viridis")

n <- 100
X <- matrix(seq(0, 10, length=n), ncol=1)
library(plgp, quietly=TRUE)
D <- distance(X)
eps <- sqrt(.Machine$double.eps) ## defining a small number
Sigma <- exp(-D + diag(eps, n))  ## for numerical stability
library(mvtnorm, quietly=TRUE)
Y <- rmvnorm(1, sigma=Sigma)
plot(X, Y, type="l")

Y <- rmvnorm(6, sigma=Sigma)
matplot(X, t(Y), type="l", ylab="Y")

n <- 8
X <- matrix(seq(0,2*pi,length=n), ncol=1)
y <- sin(X)
D <- distance(X)
Sigma <- exp(-D)
XX <- matrix(seq(-0.5, 2*pi+0.5, length=100), ncol=1)
DXX <- distance(XX)
SXX <- exp(-DXX) + diag(eps, ncol(DXX))
DX <- distance(XX, X)
SX <- exp(-DX)
Si <- solve(Sigma)
mup <- SX %*% Si %*% y
Sigmap <- SXX - SX %*% Si %*% t(SX)
YY <- rmvnorm(100, mup, Sigmap)
q1 <- mup + qnorm(0.05, 0, sqrt(diag(Sigmap)))
q2 <- mup + qnorm(0.95, 0, sqrt(diag(Sigmap)))
matplot(XX, t(YY), type="l", col="gray", lty=1, xlab="x", ylab="y")
points(X, y, pch=20, cex=2)
lines(XX, mup, lwd=2); lines(XX, sin(XX), col="blue")
lines(XX, q1, lwd=2, lty=2, col=2); lines(XX, q2, lwd=2, lty=2, col=2)


nx <- 20
x <- seq(0,2,length=nx)
X <- expand.grid(x, x)
D <- distance(X)
Sigma <- exp(-D) + diag(eps, nrow(X))
Y <- rmvnorm(2, sigma=Sigma)
par(mfrow=c(1,2), mar=c(1,0.5,0.5,0.5))
persp(x,x, matrix(Y[1,], ncol=nx), theta=-80,phi=10,xlab="x1",ylab="x2",zlab="y")
persp(x,x, matrix(Y[2,], ncol=nx), theta=-30,phi=30,xlab="x1",ylab="x2",zlab="y")

library("lhs") 
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
Sigma <- exp(-D)                        # dim = X x X
# k.xsxs
DXX <- distance(XX)  
SXX <- exp(-DXX) + diag(eps, ncol(DXX)) # dim = XX x XX
# k.xsx and t(k.xsx) = k.xxs
DX <- distance(XX, X)
SX <- exp(-DX)                          # dim = XX x X
# k.xx^-1
Si <- solve(Sigma)                      # dim = xx x xx
# fit
mup <- SX %*% Si %*% y # k.xsx%*%solve(k.xx)%*%f$y # (N* x N) %*% (N x N) %*% N
Sigmap <- SXX - SX %*% Si %*% t(SX) # k.xsxs - k.xsx%*%solve(k.xx)%*%k.xxs
sdp <- sqrt(diag(Sigmap))
YY2 <- MASS::mvrnorm(1,mup,Sigmap)
# par(mfrow=c(1,2)); cols <- heat.colors(128)
# image(xx,xx, matrix(sdp, ncol=length(xx)), xlab="x1",ylab="x2", col=cols)
# points(X[,1], X[,2])
# image(xx,xx, matrix(YY2, ncol=length(xx)), xlab="x1",ylab="x2", col=cols)
# points(X[,1], X[,2])
# 
# par(mar=c(1,0.5,0,0.5))
# persp(xx,xx, matrix(mup, ncol=40), theta=-30,phi=30,xlab="x1",ylab="x2",zlab="y")
# image(xx,xx, matrix(mup, ncol=length(xx)), xlab="x1",ylab="x2", col=cols)
# points(X[,1], X[,2])

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



