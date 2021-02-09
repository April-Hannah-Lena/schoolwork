c <- function(n) {
  return( 0.5*qchisq(0.95, n) - 0.5*n*log(2) )
}
betaD <- function(n) {
  return( 0.2 - pchisq(0.5*log(2)*n + log(c(n)), n) )
}

uniroot(betaD, lower = 1, upper = 30)
betaD(7)
betaD(8)
