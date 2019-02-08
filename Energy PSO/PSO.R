rm(list=ls())
# Funci?n de MAPE para una recta ####

mape_recta <- function(X){
  n <- length(y)
  #print(paste("n= ",n))
  x <- seq(from = 1, to = n,by = 1)
  #print(paste("length of x= " , length(x)))
  #M <- X[,1]
  #print(paste("length of M= " , length(M)))
  #B <- X[,2]
  #print(paste("length of B= ", length(B)))
  y_hat <- X[,1]%*%t(x)+X[,2]%*%t(rep(1,n))
  #print(paste("dim of y_hat= ",dim(y_hat)))
  ym <- rep(1,length(X[,1]))%*%t(y)
  #print(paste("dim of ym= ", dim(ym)))
  mape_error <- 1/n*rowSums(abs((ym-y_hat)/
                                  ym))
  #print(paste("dim of mape_error= ",dim(mape_error)))
  return(-mape_error)
}


# Creaci?n de la recta con ruido ####
x<-seq(from = 1, to = 100,by = 1)

n <- length(x)

b <- 8

m <- 3

z<- runif(n,min=-1,max=1)*20

y<- m*x + b + z

plot(y)





# Con paqueter?a "psoptim" ####
if (!require("psoptim")) install.packages("psoptim")
library(psoptim)

s <- 1000
m.l <- 1000
w <- 0.5
c1 <- 0.1
c2 <- 0.1
xmin <- c(1, 7)
xmax <- c(4, 10)
vmax <- c(4, 4)


pso_psoptim<- psoptim(FUN=mape_recta, n=s, max.loop=m.l, w=w, c1=c1, c2=c2,
                      xmin=xmin, xmax=xmax, vmax=vmax, seed =
                        sample(c(1:1000),1), anim=FALSE)

print(pso_psoptim)

y2<- pso_psoptim$sol[1]*x + pso_psoptim$sol[1]

plot(y)
lines(y2,type="l",col="red")

# #Con paqueter?a "metaheuristicOpt" ####
# 
# if (!require("metaheuristicOpt")) install.packages("metaheuristicOpt")
# library(metaheuristicOpt)
# 
# numvar <- 5
# ci <- 0.1
# cg <- 0.1
# numpop <- 1000
# rangeVar <- matrix(c(-10,10), nrow=2)
# vmax <- 2
# w <- 0.5
# maxiter <- 1000
# 
# pso_meta <- PSO(mape_recta, optimType = "MIN", numVar = numvar, 
#                 numPopulation = numpop, maxIter = maxiter,rangeVar, 
#                 Vmax = vmax, ci = ci, cg = cg, w = w)
# # Error in X[, 1] : incorrect number of dimensions


#Con paqueter?a "pso" ####
# detach("package:psoptim", unload=TRUE)
# 
# if (!require("pso")) install.packages("pso")
# library(pso)
# 
# 
# pso_pso <- psoptim(rep(NA,2), fn =  mape_recta,lower = 0, 
#                  upper =  20,control = list(trace=1,
#                                  REPORT=1, trace.stats=TRUE, s=2000) )
# 
# 
# 

# Prueba de la funcion ####
# X <- matrix(c(runif(n,min = 2.5,max = 3.5),
#               runif(n,min = 7.5, max = 8.5)),ncol = 2)
# M <- X[,1]
# 
# B <- X[,2]
# 
# y_hat <- M%*%t(x)+B%*%t(rep(1,n))
# 
# ym <- y%*%t(rep(1,n))
# 
# mape_error <- 1/n*rowSums(
#   abs((ym-y_hat)/
#         (ym)))
# 
# which.min(mape_error)






# Modelo de regresi?n lineal MCO-OLS ####
# 
# lin <- lm(y~x)
# 
# summary(lin)
# 
# abline(lin)
# 
# y_mco <- lin$coefficients[2]*x + lin$coefficients[1]
# 
# 
# # Aplicar el mape a la regresi?n de MCO-OLS
# 
# print(mape_recta(lin$coefficients[2],lin$coefficients[1],x,y))




