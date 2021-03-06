#Create a dataset
set.seed(888)
library(glmnet)
x=matrix(rnorm(100*20),100,20)
cf <- sample(0:1, 20, replace=TRUE) #Select some columns
response1 <- x %*% cf*runif(20) #Apply random coefficients
response2 <- x %*% cf*runif(20)
y=cbind(response1, response2)

#Fit a single lasso model
#0 for ridge
#1 for lasso
#>0 & <1 for the elastic net (mix of ridge and lasoo)
fit1m=glmnet(x,y,family="mgaussian",alpha=1)
plot(fit1m,type.coef="2norm")

#Select lambda through cross validation
fit1m.cv <- cv.glmnet(x,y,family="gaussian",alpha=1) 
fit2.cv <- cv.glmnet(x,y,family="multin",alpha=1)
par(mfcol=c(1,1))
plot(fit1m.cv)
coef(fit1m.cv) #Show coefficients at the selected value of lambda


pred_P <- predict(fit1m, test)
test <- as.matrix(test)
#######################################################################
setwd('H:\\Machine Learning\\Afr-Soil-Prediction')
require(caret); require(hydroGOF); require(parcor); require(prospectr);library(glmnet)
load('data/datasets_all_01Oct2014.RData')

x <- as.matrix(train_P[,-c(1)])
y <- as.matrix(train_P$P)
#######################################################################
fit_P_cv <- cv.glmnet(x,y,family='gaussian',alpha=1,type.measure='mse',nfolds=20)
fit_P_cv$lambda.min
coef(fit_P_cv, s='lambda.min')
P <- predict(fit_P_cv, newx=x,s='lambda.min')
P <- predict(fit_P_cv, newx=as.matrix(test[,-c(1,3580)]),s='lambda.min')
plot(fit_P_cv)
plot(log(fit_P_cv$lambda), fit_P_cv$cvm, pch=19, col='blue')
rmse(as.vector(P), train_P$P)

submit <- read.csv('submissions/submission_03Oct2014.csv', sep=',')
head(submit)
head(P)
submit$P <- P
names(submit)[3]<-'P'
write.csv(submit, file='submissions/submission_05Oct2014.csv', row.names=F)
