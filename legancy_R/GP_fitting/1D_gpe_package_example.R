# library(devtools)
# install_github('goldingn/gpe')
library("gpe")
library("tidyverse")

# make a fake 'true' function
f <- function(x) 2 * sin(x)

# make a fake dataset
x_fit <- seq(-2,2,length.out=10)
y <- rpois(length(x_fit), exp(f(x1)))
train_df <- data.frame(y, x1 = x_fit)
x_test <- c(-3.5,-3,x_fit,2.5,3.2)
test_df <- data.frame(x1 = x_test) #data.frame(x = seq(min(df$x1), max(df$x1), len = 500))

x1_k <- rbf('x1')
x1_k <- setParameters(x1_k, sigma = 3, l = 1.6)
# fit a Poisson GP model with an rbf kernel
m <- gp(y ~ x1_k, data = train_df, family = poisson)

# predict from it
lambda <- predict(m, test_df, type = 'response', sd = TRUE)
test_df$y_hat <- lambda$fit
test_df$y_hat_low  <- test_df$y_hat-2*sqrt(lambda$sd)
test_df$y_hat_high <- test_df$y_hat+2*sqrt(lambda$sd)
ggplot() +
  geom_line(data = test_df, aes(x=x1,y=y_hat), color = "blue") +
  geom_line(data = test_df, aes(x=x1,y=y_hat_low), color = "lightblue") +
  geom_line(data = test_df, aes(x=x1,y=y_hat_high), color = "lightblue") +
  geom_point(data = test_df, aes(x=x1,y=y_hat), color = "blue") +
  geom_line(data = train_df, aes(x=x1,y=y), color = "red") +
  geom_point(data = train_df, aes(x=x1,y=y), color = "red") +
  theme_bw()


