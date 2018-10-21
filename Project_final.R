library(caret)# for faster Classification and Regression models
library(dplyr)# for faster data manipulation
library(ggplot2)# for visualization
library(mice)# for finding missing values and imputation
library(corrgram)# to create nice correlation visualization plots
library(klaR)#for using kmeans on categorical values called kmodes
library(earth)# to find important variables
library(reshape2)
library(klaR)# for using kmodes required for categorical kmeans
library(gam)
library(visreg)
library(leaps)
library(elasticnet)# for lasso and ridge regression
library(pls)


# reading in the data

game <- read.csv("football.wr.csv")

#--------------------Pre-processing---------------------------#
#removing variables that are constant, mostly empty and correlated(e.g. date and year or weight and height).
colSums(is.na(game))
games.filtered <- game[,c(2,3,5:47,51,64,65)]
colSums(is.na(games.filtered))

#Creating visualizations
m.earth <- earth(Fantasy.points ~ ., data=games.filtered) # finding important variables
ev <- evimp(m.earth)

m.earth.2 <- earth(game_won~., data=games.filtered)
ev2 <- evimp(m.earth.2)

game.vis <- games.filtered[,c(4,8,22:25,27,46:48)]

df.m <- melt(game.vis, id.var = "game_won")
p <- ggplot(data = df.m, aes(x=variable, y=value)) + geom_boxplot(aes(fill=game_won))
p + facet_wrap( ~ variable, scales="free")

matrix.model()
#fitlering the ourliers and standardizing all the variables
game.clean <- games.filtered %>% filter(age<35 & receiving_targets< 15
                                        & receiving_receptions<11 & receiving_yards <200
                                        & receiving_touchdowns<2& kick_return_yards<180) 
game.clean[1:4] <- lapply(game.clean[1:4],as.numeric)
game.clean[9:48] <- lapply(game.clean[9:48],as.numeric)
game.clean$game_won <- as.factor(game.clean$game_won)

#--------------------End of Pre-processing---------------------------#

#--------------------Clustering---------------------------------#

game.clust.data <- na.omit(game[,c(6,56,57,64,65)])
game.kmeans <- kmodes(game.clust.data, 3, iter.max = 10)
x <- game.clust.data[1,4,5]
ga.x <- kmeans(x,3)
plot((x), col = game.kmeans$cluster)
#grouping the records based on playerid
game.agg <- aggregate(game$Fantasy.points, by=list(game$player_id), FUN = sum)

game.data <- read.csv("profiles.csv")
game.data <- game.data[,c(2,3,6,11)]
games.data <- game[,c(2,6,48,56,64)]
#join is used as game.agg has only playerid and fantasy points
game.group2 <- left_join(game.agg,game.data,by=c("Group.1"="player_id"))

game.group2 <- na.omit(game.group2)
game.kmeans <- kmodes(game.group2, 3, iter.max = 10)

plot(game.group1,col = game.kmeans$cluster)
game.clust <- cbind(game.group2,game.kmeans$cluster)
write.csv(game.clust,"game_cluster.csv")

#--------------------End of Clustering---------------------------------#

#--------------------Regression modelling----------------------------#
set.seed(195)
train.index <- sample(nrow(game.clean), nrow(game.clean) * .8) #let keep 80% of data for training

#create test and traing data frames
game.train <- game.clean[train.index,] #model with this
game.test <- game.clean[-train.index,]

game.test.F <- game.test[,48]
game.test.NF <- game.test[,1:47]
 
#Linear Regression with Cross validation 5
ctrl5 <- trainControl(method = "cv", number=5)
game.tr.lm5 <- train(Fantasy.points~.,
                 data= game.train, method = "lm", trControl=ctrl5)

game.test.lm5 <- postResample(predict(game.tr.lm5, game.test.NF), game.test.F)

#Linear Regression with Cross validation 10
ctrl10 <- trainControl(method = "cv", number=10)
game.tr.lm10 <- train(Fantasy.points~.,
                     data= game.train, method = "lm", trControl=ctrl10)

game.test.lm10 <- postResample(predict(game.tr.lm10, game.test.NF), game.test.F)

#Linear Regression with Cross validation method bootstrap
ctrlB <- trainControl(method = "boot", number=5)

game.tr.lmB <- train(Fantasy.points~.,
                     data= game.train, method = "lm", trControl=ctrlB)
game.test.lmB <- postResample(predict(game.tr.lmB, game.test.NF), game.test.F)


game.tr.glm <- train(Fantasy.points~.,
                      data= game.train, method = "glm", trControl=ctrl5)

game.test.glm <- postResample(predict(game.tr.glm, game.test.NF), game.test.F)


#PCA analysis
game.num <- as.data.frame(model.matrix(Fantasy.points~.,data=game.clean))
game.num <- cbind(game.num,game.clean$Fantasy.points)
colnames(game.num)[124] <- "Fantasy.points"
games.pca.model <- prcomp(game.num[1:123])

games.p <- as.data.frame(predict(games.pca.model,game.num[1:123]))
games.p <- cbind(games.p, game.num$Fantasy.points)
colnames(games.p)[124] <- "Fantasy.points"

train.indexp <- sample(nrow(games.p), nrow(games.p) * .8) #let keep 80% of data for training
game.trainp <- games.p[train.index,] #model with this
game.testp <- games.p[-train.index,]

game.testp.F <- game.testp[,124]
game.testp.NF <- game.testp[,1:123]

game.tr.pca <- train(Fantasy.points ~ PC1+PC2+PC3+PC4+PC5+PC6+PC7+PC8,
                  data= game.trainp, method = "lm", trControl=ctrl5)
game.test.pca <- postResample(predict(game.tr.pca, game.testp.NF), game.testp.F)

#view biplot of first two components
biplot(games.pca.model)

#variance explained by each component, squaring standard deviation 
pca.var<- games.pca.model$sdev^2

#proportion of variance explained
pve<- pca.var/ sum(pca.var)

#scree plot, variance explained by component
plot(pve, xlab="PCA", ylab="Prop of Variance Explained", ylim=c(0,1), type='b')

#cumulative variance explained
#scree plot, variance explained by component
plot(cumsum(pve), xlab="PCA", ylab="Cumulative Prop of Variance Explained", ylim=c(0,1), type='b')

#Linear Models Comparison
models.L<- list( "Linear.CV10" = game.tr.lm5,"Linear.PCA" = game.tr.pca
                 ,"GLM" = game.tr.glm,"PLS"=game.pls)

game.resamples.L<- resamples(models.L)
summary(game.resamples.L)

#plot performances of above models
bwplot(game.resamples.L, metric="RMSE")
bwplot(game.resamples, metric="Rsquared")
bwplot(game.resamples, metric="MAE")

#removing near zero variance variables

position <- nearZeroVar(game.num[1:123])
game.nzv <- game.num[,-(position)]
train.indexn <- sample(nrow(game.nzv), nrow(game.nzv) * .8) #let keep 80% of data for training
game.train.nzv <- game.nzv[train.indexn,] #model with this
game.test.nzv <- game.nzv[-train.indexn,]

game.testn.F <- game.test.nzv[,16]
game.testn.NF <- game.test.nzv[,1:15]

game.tr.nzv <- train(Fantasy.points~.,
                     data= game.train.nzv, method = "lm", trControl=ctrl5)

game.test.nzv <- postResample(predict(game.tr.nzv, game.testn.NF), game.testn.F)

#trying non linear models
game.poly.resd <- rep(NA,12)
for (i in 1:12) {
  game.poly <- lm(Fantasy.points~ poly(age,i) + poly(weight,i) + poly(kick_return_yards,i) + poly(rushing_attempts,i)+
                    poly(receiving_targets,i), data = game.clean)
  
  game.poly.resd[i] <- sqrt(mean(game.poly$residuals^2))
  
}

game.glmnet <- train(Fantasy.points~.,
                     data= games.p, method = "glmnet",Length=10, trControl=ctrl5)


game.gam <- gam(Fantasy.points~ s(age,2) + s(weight,3) + s(kick_return_yards,4) + s(rushing_attempts,5)+
                 s(receiving_targets,6), data = game.clean)
game.gam.rmse <- sqrt(mean(game.gam$residuals^2))

#Step regression
game.step.resd <- rep(NA,14)
for (i in 2:15) {
  game.step <- lm(Fantasy.points~ cut(age,i) + cut(weight,i) + cut(kick_return_yards,i) + cut(rushing_attempts,i)+
                    cut(receiving_targets,i), data = game.clean)
  
  game.step.resd[i-1] <- sqrt(mean(game.step$residuals^2))
  
}
game.step.3 <- lm(Fantasy.points~ + cut(kick_return_yards,6) , data = game.clean)
visreg(game.step.3)


model.NL <- c(Polynomial= mean(game.poly.resd),Step=mean(game.step.resd),
              GAM = game.gam.rmse)

plot(model.NL)

#Modelling with feature selection
#lasso running for NZV
game.tr.lasso <- train(Fantasy.points~.,
                       data= game.train.nzv, method = "lasso", tuneLength=10, trControl=ctrl5)
game.test.lasso <- postResample(predict(game.tr.lasso, game.testn.NF), game.testn.F)

game.tr.lasso.rmse <- mean(game.tr.lasso$results$RMSE)

game.tr.ridge <- train(Fantasy.points~.,
                       data= game.train.nzv, method = "ridge", tuneLength=10, trControl=ctrl5)
game.test.ridge <- postResample(predict(game.tr.ridge, game.testn.NF), game.testn.F)

game.tr.ridge.rmse <- mean(game.tr.ridge$results$RMSE)


ctrl <- trainControl(method = "cv", number=5)

#lcv on forward
set.seed(195) #SEED
game.tfwd <- train(Fantasy.points~.,
                   data= game.nzv, method = "leapForward", tuneLength=10, trControl=ctrl)
game.tfwd

#lcv on backword
set.seed(195) #SEED
game.tbwd <- train(Fantasy.points~.,
                data= game.nzv, method = "leapBackward", tuneLength=10, trControl=ctrl)
game.tbwd

game.ridge <- train(Fantasy.points~.,
                 data= game.nzv, 
                 preProcess=c("scale"), #units of coefficients are equivalent
                 method = "ridge", tuneLength=10, trControl=ctrl)
game.ridge
plot(game.ridge)

game.lasso <- train(Fantasy.points~.,
                    data= game.nzv, 
                 method = "lasso", tuneLength=10, trControl=ctrl)
game.lasso
plot(game.lasso)

game.pcr <- train(Fantasy.points~.,
                  data= game.nzv, method = "pcr", tuneLength=10, trControl=ctrl)
game.pcr
plot(game.pcr)

game.pls <- train(Fantasy.points~.,
                  data= game.nzv, method = "pls", tuneLength=10, trControl=ctrl)
game.pls

# #lets gather all the above models
# models<- list("Forward"=game.tfwd, "Backword" = game.tbwd,
#               "Ridge" = game.ridge, "Lasso"=game.lasso,
#               "PCR" = game.pcr,
#               "PLS" = game.pls)
# 
# game.resamples<- resamples(models)
# summary(game.resamples)
# 
# #plot performances of above models
# bwplot(game.resamples, metric="RMSE")
# bwplot(game.resamples, metric="Rsquared")
# bwplot(game.resamples, metric="MAE")


#All Models Comparison
models.L<- list( "Linear.PCA" = game.tr.pca
                 ,"GLM" = game.tr.glm,"Forward"=game.tfwd, "Backword" = game.tbwd,
                 "Ridge" = game.ridge,"Linear.CV10" = game.tr.lm5, "Lasso"=game.lasso,
                 "PCR" = game.pcr,
                 "PLS" = game.pls)

game.resamples.L<- resamples(models.L)
summary(game.resamples.L)

#plot performances of above models
bwplot(game.resamples.L, metric="RMSE")
bwplot(game.resamples.L, metric="Rsquared")
bwplot(game.resamples.L, metric="MAE")


#non linear models comparison

model.NL <-c(Polynomial= mean(game.poly.resd),Step=mean(game.step.resd),
              GAM = game.gam.rmse)
model.NL <- as.data.frame(model.NL)
plot(model.NL)

a <- c(mean(game.poly.resd),mean(game.step.resd),game.gam.rmse)
b <- c("Polynomial", "Step","GAM")
c <- data.frame(model=b,RMSE=a)
c
Model <- c$model
RMSE <- c$RMSE

qplot(Model,RMSE,c, method=lm, color=RMSE)+ theme_bw()+
  theme(axis.title=element_text(face="bold.italic", 
           size="16", color="brown"), legend.position="top")



#--------------------End of Regression modelling----------------------------#



