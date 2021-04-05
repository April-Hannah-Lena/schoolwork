# keine zusätzlichen Module gebraucht

coverage_interval <- function(x, alpha) {
    quant <- qnorm(1-(alpha/2))
    Cup <- mean(x) - ((5*quant)/sqrt(length(x)))
    Cdown <- mean(x) + ((5*quant)/sqrt(length(x)))
    return(c(Cdown, Cup))
}

proben <- rnorm(2000, mean=0, sd=25)
i <- 2
coverage <- coverage_interval(proben[1:2], 0.1)

while ( abs(coverage[[1]]-coverage[[2]]) > 1.25 ) {
  coverage <- coverage_interval(proben[1:i], 0.1)
  #print(coverage)
  i <- i+1
}

i2 <- 0
coverage <- coverage_interval(proben[1:200], i2)

while( abs(coverage[[1]]-coverage[[2]]) > 1.15 ) {
  coverage <- coverage_interval(proben[1:200], i2)
  #print(coverage)
  i2 <- i2 + 0.0001
}

coverage <- coverage_interval(proben[1:150], 0.2)
int <- coverage[[1]] - coverage[[2]]

results <- data.frame(
  a=i,
  b=i2,
  c=int
)

print(results)



c <- qnorm(0.95)
d <- (26 - 25) / (3 / 7)
pnorm(c - (2 * 7/3))
fqnorm(0.05) * (3/7) + 27
qnorm(0.975)


g <- function(n) {
  return( n - 64*(qnorm(0.975)^2) )
}
uniroot(g, lower = 1, upper = 1000)
g(245)
g(246)
