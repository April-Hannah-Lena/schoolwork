library(tidyverse)
set.seed(323)

n <- 40
theta <- 1
x <- runif(100*n, 0, theta)
y <- c()
for (i in 1:100) {
  y <- append(y, rep(i, 40))
}

stichproben <- tibble(
  proben=x,
  i=y
)
stichproben <- stichproben %>% 
  group_by(i) %>%
  mutate(x_bar=2*mean(proben)) %>%
  mutate(var_x_bar=(1/(n-1))*sum((proben-x_bar)^2)) %>%
  mutate(x_max=((n+1)/n)*max(proben)) %>%
  mutate(var_x_max=(1/(n-1))*sum((proben-x_max)^2))

var_x_bar <- stichproben %>% pull(var_x_bar) %>% mean()
var_x_max <- stichproben %>% pull(var_x_max) %>% mean()


library(mvtnorm)
mu <- c(3, 1, 1)
sigma <- matrix(data=c(c(6.0, 1.0, 0.47),
                c(1.0, 5.0, -0.2), 
                c(0.47, -0.2, 2.0)), 
                ncol=3, byrow=TRUE)

pmvnorm(lower=c(2.0, 3.0, -Inf), upper=c(Inf, 100.0, 50.0), mean=mu, sigma=sigma)


