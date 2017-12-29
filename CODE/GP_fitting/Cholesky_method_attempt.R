# testing algorithm 2.3 pg 19. Rass & Willi 2006
L_c2 = t(chol(K)+ sigma_n^2 * diag(1, ncol(K)))
a_c2 = solve(t(L), solve(L_c2, (ytrain-muFn(Xtrain[,1]))))
postMu_c2  = muFn(Xtest[,1]) + tKstar %*% a_c2             # checks out against postMu; range(postMu-postMu_c2)
v_c2 = solve(L, Kstar)
postCov_c2 = Kstarstar - t(v_c2) %*% v_c2     # in proximity of postCov; range(postCov-postCov_c2)
y2_c2 = data.frame(t(mvrnorm(npostpred, mu=postMu_c2, Sigma=postCov_c2))) # not Positive Definite!?

##### checked on a number of sources to confirm this approach and it seems to check out
## The eigen values of the last few columns of the postCov_c2 Cov matrix go negative and therefore not Positive Definite.
## Using Cholesky and the solves() is a bit faster, but not stable as I have it here.