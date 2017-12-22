set.seed(1234)
n = 50 #No. test points
Xtest = seq(-5, 5, length.out = n)   #Test points: 50 points between -5 and +5: -5, -4.79, -4.59,..., 4.59, 4.79, 5

kernel = function(a,b, param){                                   # Defining a function the Gaussian process is exp{-1/2 abs(x_1 - x_2)^2}
  #GP squared exponential kernel:
  #Leaving aside the abs value, (x_1 - x_2)^2 = a^2 + b^2 - 2 ab. And making the matrices congruous:
  sqdist = outer(a^2,b^2,FUN=`+`) - 2 * (a %*% t(b))
  exp(-.5 * (1/param) * sqdist) # This is the kernel: when distance is inf. the exponential becomes 1/e^inf =0, when dist=0, k =1
}

param = 1                                    
K_test = kernel(Xtest, Xtest, param)                       #Kernel at test points: all the points against each other.

# Draw samples from the prior at our test points:
samples = 10
Ch_test = chol(K_test + 1e-10 * diag(n)) # Square root of the kernel values (the Cholesky)
m = matrix(rnorm(n * samples), ncol = samples)
f_prior = t(m) %*% Ch_test # Generating multivariate normals through the Cholesky representing the kernels

values <- cbind(x=Xtest,as.data.frame(t(f_prior)))
values <- melt(values,id="x")

ggplot(values,aes(x=x,y=value)) +
  geom_rect(xmin=-Inf, xmax=Inf, ymin=-2, ymax=2, fill="grey80") +
  geom_line(aes(group=variable)) +
  theme_bw() +
  scale_y_continuous(lim=c(-2.5,2.5), name="output, f(x)") +
  xlab("input, x")



### From this post: http://stats.stackexchange.com/q/232959/67822
# https://github.com/RInterested/SIMULATIONS_and_PROOFS/blob/master/Gaussian%20Process%20Chunk%202

########## Chol is not stable ########

# Noiseless training data:
Xtrain = c(-4,-3, -2, -1, 1)
ytrain = sin(Xtrain)

# Apply the kernel function to our training points:
K_train = kernel(Xtrain, Xtrain, param)

Ch_train = chol(K_train + 0.00005 * diag(length(Xtrain)))

# Compute the mean at our test points:

K_trte = kernel(Xtrain, Xtest, param)
core = solve(Ch_train) %*% K_trte
temp = solve(Ch_train) %*% ytrain
mu = t(core) %*% temp

# Compute the standard deviation:

tempor = colSums(core^2)

# Notice that all.equal(diag(t(Lk) %*% Lk), colSums(Lk^2)) TRUE

s2 = diag(K_test) - tempor
# stdv = sqrt(s2)

# Draw samples from the posterior at our test points:

Ch_post_gener = chol(K_test + 1e-6 * diag(n) - (t(core) %*% core))
m_prime = matrix(rnorm(n * 3), ncol = 3)
sam = Ch_post_gener %*% m_prime
f_post = as.vector(mu) + sam



colors=c(2, "darkred","blue")
plot(Xtest,f_post[,1], type="l", lwd = 2, col='darkorange', 
     ylim=c(-2.5,2.5),
     xlab='',ylab='') 
title(main="Three samples from the GP Posterior
      Training points added",
      cex.main=0.85)

abline(h = 0)

for(i in 2:3){
  lines(Xtest, f_post[,i], type = 'l', lwd=2, col=colors[i]) # Plotting
}
points(Xtrain, ytrain, pch = 20, cex=2)