library("rgl")
library("lhs") 
library("ggplot2")

eps <- sqrt(.Machine$double.eps) ## defining a small number
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

open3d()
bg3d("white")
material3d(col = "black")
z <- matrix(YY2, nrow = length(xx))
persp3d(xx,xx, z, aspect = c(1, 1, 0.5), col="lightgray", smooth=TRUE)
spheres3d(X[,1],X[,2],y,col="red", radius = 0.1)



# library("lattice")
# pnts_dat <- data.frame(x = X[,1], y = X[,2], z = y)
# lattice_dat <- data.frame(z = YY2, x1 = xx, x2 = xx)
# lattice::wireframe(z ~ x1 * x2, data = lattice_dat, drape = TRUE,
#                    colorkey = FALSE,
#                    screen = list(z = -60, x = -60), pts = pnts_dat,
#                    panel.3d.wireframe = function(x, y, z, pnts, ...) {
#                      panel.3dwire(x = x, y = y, z = z, ...)
#                      panel.3dscatter(x = x,
#                                      y = y,
#                                      z = z,
#                                      ...)
#                    })
