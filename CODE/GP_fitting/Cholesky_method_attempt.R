##########################
# Fits, but still not working right. RMSE ~ 1, whereas other analytical methods is ~ 0.5
##########################

# testing algorithm 2.3 pg 19. Rass & Willi 2006
L_c2 = t(chol(K)+ sigma_n^2 * diag(1, ncol(K)))
a_c2 = backsolve(t(L_c2), forwardsolve(L_c2, (ytrain-muFn(Xtrain[,1]))))
postMu_c2  = muFn(Xtest[,1]) + tKstar %*% a_c2  
# checks out against postMu sort of; range(postMu-postMu_c2); sqrt(mean(postMu - postMu_c2)^2)
v_c2 = solve(L_c2, Kstar)
postCov_c2 = Kstarstar - t(v_c2) %*% v_c2 
# checks out against postMu sort of; range(postCov-postCov_c2); sqrt(mean(postCov - postCov_c2)^2)
y2_c2 = data.frame(t(mvrnorm(npostpred, mu=postMu_c2, Sigma=postCov_c2)))

xt_df <- data.frame(Xtrain, y = round(ytrain,3))
xtt_df <- data.frame(y_hat = round(y2_c2[,1],3), Var1 = as.double(Xtest[,1]),
                     Var2 = as.double(Xtest[,2]))
preds <-  left_join(xtt_df,xt_df) %>%
  as.tibble() %>%
  mutate(err = (y-y_hat)^2,
         rmse = sqrt(mean(err)))
sqrt(mean(preds$err))

gdat = melt(data.frame(x1=Xtest[,1], x2=Xtest[,2], y=y2_c2[,2], selower=postMu-2*sqrt(s2), seupper=postMu+2*sqrt(s2)),
            id=c('x1', 'x2', 'selower', 'seupper'))
ggplot(data = gdat, aes(x=x1,y=x2)) +
  geom_raster(aes(fill=value), interpolate = TRUE) +
  geom_contour(aes(z=value), bins = 12, color = "gray30", 
               size = 0.5, alpha = 0.5) +
  geom_point(aes(size = value)) +
  coord_equal() +
  scale_x_continuous(expand=c(0,0)) +
  scale_y_continuous(expand=c(0,0)) +
  scale_fill_viridis_c(option = "viridis")
