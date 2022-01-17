library(tidyverse)

c <- function(n, alpha) {
    return(7 * qchisq(1-alpha, df=1) / (2*n))
}

under <- function(n, x, alpha) {
    return(x + c(n, alpha) - sqrt((2 * x * c(n, alpha)) + c(n, alpha)^2))
}

over <- function(n, x, alpha) {
    return(x + c(n, alpha) + sqrt((2 * x * c(n, alpha)) + c(n, alpha)^2))
}

binom.test(41, n=300, p=0.1, alternative="greater")
