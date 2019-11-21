# library("devtools")
# devtools::install_github("hmorlon/PANDA", dependencies = TRUE)

#clean running env
rm(list=ls())

#loading packages
library("RPANDA")
library("ape")
library("phytools")


#######RPANDA_Models##################


#define a fucntion evaluate all the models for given tree and pars

fit.multi.rpanda <- function(tree, par, Tem.C, Order, NN, dof, file1) {
  #initial values
  # par <- list(c(0.09), c(0.09, 0.005), c(0.05, 0.01), c(0.05, 0.01), c(0.05, 0.01, 0.005), c(0.09, 0.001, 0.005), c(0.05, 0.005, 0.01), 
  #             c(0.05, 0.005, 0.001), c(0.05, 0.01, 0.005, 0.0001))
  
  # caculate crown age
  tot_time <- max(node.age(tree)$ages)
  
  # caculate fraction

  fraction <- length(tree$tip.label)/NN
  
#Nine time-dependent models
  
  #1)	Pure birth model, no extinction rate (mu, µ = 0), and constant speciation rate (lambda, λ; hereafter bcst.d0.t)
  # t is time
  # y is a vector of initial values feeding to the functions of λ and µ
  f.lamb.t = function(t, y){y[1]}
  f.mu.t = function(t, y){0}
  
  model <- "bcst.d0.t"
  bcst.d0.t <- fit_bd(tree, tot_time, f.lamb.t, f.mu.t, lamb_par=par[[1]][1], mu_par=c(), f=fraction, cst.lamb=TRUE, fix.mu=TRUE, cond="crown", dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bcst.d0.t$lamb_par, ",NA,0,NA,", bcst.d0.t$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #2)	Birth-death model with constant speciation and extinction (here as bcst.dcst.t)
  f.lamb.t = function(t, y){y[1]}
  f.mu.t = function(t, y){y[1]}
  
  model <- "bcst.dcst.t"
  bcst.dcst.t <- fit_bd(tree, tot_time, f.lamb.t, f.mu.t, lamb_par=par[[2]][1], mu_par=par[[2]][2], cst.lamb=TRUE, cst.mu=TRUE, cond="crown", f=fraction, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bcst.dcst.t$lamb_par, ",NA,", bcst.dcst.t$mu_par, ",NA,", bcst.dcst.t$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #3)	Pure birth model with exponential variation in speciation rate (here as bvar.d0.t)
  f.lamb.t = function(t, y){y[1] * exp(y[2] * t)}
  f.mu.t = function(t, y){0}
  
  model <- "bvar.d0.t"
  bvar.d0.t <- fit_bd(tree, tot_time, f.lamb.t, f.mu.t, lamb_par=par[[3]][c(1,2)], mu_par=c(), expo.lamb=TRUE, fix.mu=TRUE, cond="crown", f=fraction, dt=1e-3)
  
  write.table(paste0(Order, ",", model, ",", bvar.d0.t$lamb_par[1], ",", bvar.d0.t$lamb_par[2], ",0,NA,", bvar.d0.t$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #4)	Pure birth model with linear variation in speciation rate (here as bvar.l.d0.t)
  f.lamb.t = function(t, y){y[1] + y[2] * t}
  f.mu.t = function(t, y){0}
  
  model <- "bvar.l.d0.t"
  bvar.l.d0.t <- fit_bd(tree, tot_time, f.lamb.t, f.mu.t, lamb_par=par[[4]][c(1,2)], mu_par=c(), fix.mu=TRUE, f=fraction, cond="crown", dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bvar.l.d0.t$lamb_par[1], ",", bvar.l.d0.t$lamb_par[2], ",0,NA,", bvar.l.d0.t$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #5)	Birth-death model with exponential variation in speciation rate and constant extinction (here as bvar.dcst.t)
  f.lamb.t = function(t, y){y[1] * exp(y[2] * t)}
  f.mu.t = function(t, y){y[1]}
  
  model <- "bvar.dcst.t"
  bvar.dcst.t <- fit_bd(tree, tot_time, f.lamb.t, f.mu.t, lamb_par=par[[5]][c(1,2)], mu_par=par[[5]][3], expo.lamb=TRUE, cst.mu=TRUE,cond="crown", f=fraction, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bvar.dcst.t$lamb_par[1], ",", bvar.dcst.t$lamb_par[2], ",", bvar.dcst.t$mu_par, ",NA,", bvar.dcst.t$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #6)	Birth-death model with linear variation in speciation rate and constant extinction (here as bvar.l.dcst.t)
  f.lamb.t = function(t, y){y[1] + y[2] * t}
  f.mu.t = function(t, y){y[1]}
  
  model <- "bvar.l.dcst.t"
  bvar.l.dcst.t <- fit_bd(tree, tot_time, f.lamb.t, f.mu.t, lamb_par=par[[6]][c(1,2)], mu_par=par[[6]][3], cst.mu=TRUE, cond="crown", f=fraction, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bvar.l.dcst.t$lamb_par[1], ",",  bvar.l.dcst.t$lamb_par[2], ",", bvar.l.dcst.t$mu_par, ",NA,", bvar.l.dcst.t$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #7)	Birth-death model with a constant speciation rate and exponential variation in extinction (here as bcst.dvar.t)
  f.lamb.t = function(t, y){y[1]}
  f.mu.t = function(t,y){y[1] * exp(y[2] * t)}
  
  model <- "bcst.dvar.t"
  bcst.dvar.t <- fit_bd(tree, tot_time, f.lamb.t, f.mu.t, lamb_par=par[[7]][1], mu_par=par[[7]][c(2,3)], cst.lamb=TRUE, expo.mu=TRUE, cond="crown", f=fraction, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bcst.dvar.t$lamb_par, ",NA,", bcst.dvar.t$mu_par[1], ",", bcst.dvar.t$mu_par[2], ",", bcst.dvar.t$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #8)	Birth-death model with a constant speciation rate and linear variation in extinction (here as bcst.dvar.l.t)
  f.lamb.t = function(t, y){y[1]}
  f.mu.t = function(t,y){y[1] + y[2] * t}
  
  model <- "bcst.dvar.l.t"
  bcst.dvar.l.t <- fit_bd(tree, tot_time, f.lamb.t, f.mu.t, lamb_par=par[[8]][1], mu_par=par[[8]][c(2,3)], cst.lamb=TRUE, cond="crown", f=fraction, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bcst.dvar.l.t$lamb_par, ",NA,", bcst.dvar.l.t$mu_par[1], ",", bcst.dvar.l.t$mu_par[2], ",", bcst.dvar.l.t$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #9)	Birth-death model with exponential variation in speciation and extinction (here as bvar.dvar.t)
  f.lamb.t = function(t, y){y[1] * exp(y[2] * t)}
  f.mu.t = function(t,y){y[1] * exp(y[2] * t)}
  
  model <- "bvar.dvar.t"
  bvar.dvar.t <- fit_bd(tree, tot_time, f.lamb.t, f.mu.t, lamb_par=par[[9]][c(1,2)], mu_par=par[[9]][c(3,4)], expo.lamb=TRUE, expo.mu=TRUE, cond="crown", f=fraction, dt=1e-3)
  
  write.table(paste0(Order, ",", model, ",", bvar.dvar.t$lamb_par[1], ",", bvar.dvar.t$lamb_par[2], ",", bvar.dvar.t$mu_par[1], ",", bvar.dvar.t$mu_par[2], ",", bvar.dvar.t$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #return results as a list
  result.t <- (list("bcst.d0.t"=bcst.d0.t, "bcst.dcst.t"=bcst.dcst.t, "bvar.d0.t"=bvar.d0.t, "bvar.l.d0.t"=bvar.l.d0.t, "bvar.dcst.t"=bvar.dcst.t, "bvar.l.dcst.t"=bvar.l.dcst.t, "bcst.dvar.t"=bcst.dvar.t, "bcst.dvar.l.t"=bcst.dvar.l.t, "bvar.dvar.t"=bvar.dvar.t))
  
  newname <- unlist(strsplit(file1, split="[.]"))[1]
  saveRDS(result.t, file=paste0(newname, "_", Order, "Time.rds", sep=""))
  

  
  ############environmental birth-death model x=temperature##############
  #Nine temperature-dependent models
  
  #We also tested nine environmental-dependent diversification models inferred from oxygen isotopes (δ18O) covering major changes of global temperature since the Late Cretaceous ( ~ 113 Myr to present; Cramer et al., 2009; Condamine et al., 2013).
  
  #10)	No extinction rate (mu, µ = 0), and constant speciation rate with temperature (x) (lambda, λ; hereafter bcst.d0.x)
  # t is time
  # x is temperature
  # y is a vector of initial values feeding to the functions of λ and µ
  f.lamb.x = function(t,x,y){y[1]*x}
  f.mu.x = function(t,x,y){0}

  model <- "bcst.d0.x"
  bcst.d0.x <- fit_env(tree, Tem.C, tot_time, f.lamb.x, f.mu.x, lamb_par=par[[1]][1], mu_par=c(), f=fraction, cst.lamb=TRUE, fix.mu=TRUE, cond="crown", df=dof, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bcst.d0.x$lamb_par[1], ",NA,0,NA,", bcst.d0.x$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #11)	Constant speciation and extinction with temperature (x) (here as bcst.dcst.x)
  f.lamb.x = function(t,x,y){y[1]*x}
  f.mu.x = function(t,x,y){y[1]*x}

  model <- "bcst.dcst.x"
  bcst.dcst.x <- fit_env(tree, Tem.C, tot_time, f.lamb.x, f.mu.x, lamb_par=par[[2]][1], mu_par=par[[2]][2], cst.lamb=TRUE, cst.mu=TRUE, cond="crown", f=fraction, df=dof, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bcst.dcst.x$lamb_par[1], ",NA,", bcst.dcst.x$mu_par[1], ",NA,", bcst.dcst.x$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #12)	Exponential variation in speciation rate with temperature (x) (here as bvar.d0.x)
  f.lamb.x = function(t,x,y){y[1] * exp( y[2] * x)}
  f.mu.x = function(t,x,y){0}

  model <- "bvar.d0.x"
  bvar.d0.x <- fit_env(tree, Tem.C, tot_time, f.lamb.x, f.mu.x, lamb_par=par[[3]][c(1,2)], mu_par=c(), expo.lamb=TRUE, fix.mu=TRUE, cond="crown", f=fraction, df=dof, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bvar.d0.x$lamb_par[1], ",",  bvar.d0.x$lamb_par[2], ",0,NA,", bvar.d0.x$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #13)	Linear variation in speciation rate with temperature (x) (here as bvar.l.d0.x)
  f.lamb.x = function(t,x,y){y[1] + y[2]*x}
  f.mu.x = function(t,x,y){0}

  model <- "bvar.l.d0.x"
  bvar.l.d0.x <- fit_env(tree, Tem.C, tot_time, f.lamb.x, f.mu.x, lamb_par=par[[4]][c(1,2)], mu_par=c(), fix.mu=TRUE, f=fraction, cond="crown", df=dof, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bvar.l.d0.x$lamb_par[1], ",", bvar.l.d0.x$lamb_par[2], ",0,NA,", bvar.l.d0.x$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #14)	 Exponential variation in speciation rate with temperature (x) and constant extinction with temperature (x) (here as bvar.dcst.x)
  f.lamb.x = function(t,x,y){y[1] * exp( y[2] * x)}
  f.mu.x = function(t,x,y){y[1]*x}
  
  model <- "bvar.dcst.x"
  bvar.dcst.x <- fit_env(tree, Tem.C, tot_time, f.lamb.x, f.mu.x, lamb_par=par[[5]][c(1,2)], mu_par=par[[5]][3], expo.lamb=TRUE, cst.mu=TRUE,cond="crown", f=fraction, df=dof, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bvar.dcst.x$lamb_par[1], ",", bvar.dcst.x$lamb_par[2], ",", bvar.dcst.x$mu_par[1], ",NA,", bvar.dcst.x$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #15)	Linear variation in speciation rate with temperature (x) and constant extinction with temperature (x) (here as bvar.l.dcst.x)
  f.lamb.x = function(t,x,y){y[1] + y[2]*x}
  f.mu.x = function(t,x,y){y[1]*x}

  model <- "bvar.l.dcst.x"
  bvar.l.dcst.x <- fit_env(tree, Tem.C, tot_time, f.lamb.x, f.mu.x, lamb_par=par[[6]][c(1,2)],mu_par=par[[6]][3], cst.mu=TRUE, cond="crown", f=fraction, df=dof, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bvar.l.dcst.x$lamb_par[1], ",", bvar.l.dcst.x$lamb_par[2], ",", bvar.l.dcst.x$mu_par[1], ",NA,", bvar.l.dcst.x$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #16)	Constant speciation rate with temperature (x) and exponential variation in extinction with temperature (x) (here as bcst.dvar.x)
  f.lamb.x = function(t,x,y){y[1]*x}
  f.mu.x = function(t,x,y){y[1] * exp(y[2] * x)}
  
  model <- "bcst.dvar.x"
  bcst.dvar.x <- fit_env(tree, Tem.C, tot_time, f.lamb.x, f.mu.x, lamb_par=par[[7]][1], mu_par=par[[7]][c(2,3)], cst.lamb=TRUE, expo.mu=TRUE, cond="crown", f=fraction, df=dof, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bcst.dvar.x$lamb_par[1], ",NA,", bcst.dvar.x$mu_par[1], ",", bcst.dvar.x$mu_par[2], ",", bcst.dvar.x$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #17)	Constant speciation rate with temperature (x) and linear variation in extinction with temperature (x) (here as bcst.dvar.l.x)
  f.lamb.x = function(t,x,y){y[1]*x}
  f.mu.x = function(t,x,y){y[1] + y[2]*x}

  model <- "bcst.dvar.l.x"
  bcst.dvar.l.x <- fit_env(tree, Tem.C, tot_time, f.lamb.x, f.mu.x, lamb_par=par[[8]][1], mu_par=par[[8]][c(2,3)], cst.lamb=TRUE, cond="crown", f=fraction, df=dof, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bcst.dvar.l.x$lamb_par[1], ",NA,", bcst.dvar.l.x$mu_par[1], ",", bcst.dvar.l.x$mu_par[2], ",", bcst.dvar.l.x$aicc, sep=""), file=file1, row.names=F, col.names=F, quote=F, append=T)
  
  #18)	Exponential variation both in speciation and extinction rates with temperature (x) (here as bvar.dvar.x)
  f.lamb.x = function(t,x,y){y[1] * exp( y[2] * x)}
  f.mu.x = function(t,x,y){y[1] * exp(y[2] * x)}

  model <- "bvar.dvar.x"
  bvar.dvar.x <- fit_env(tree, Tem.C, tot_time, f.lamb.x, f.mu.x, lamb_par=par[[9]][c(1,2)], mu_par=par[[9]][c(3,4)], expo.lamb=TRUE, expo.mu=TRUE, cond="crown", f=fraction, df=dof, dt=1e-3)
  write.table(paste0(Order, ",", model, ",", bvar.dvar.x$lamb_par[1], ",", bvar.dvar.x$lamb_par[2], ",", bvar.dvar.x$mu_par[1], ",", bvar.dvar.x$mu_par[2], ",", bvar.dvar.x$aicc, sep=""), file1, row.names=F, col.names=F, quote=F, append=T)
  
  #return results as a list
  result.x <- (list("bcst.d0.x"=bcst.d0.x, "bcst.dcst.x"=bcst.dcst.x, "bvar.d0.x"=bvar.d0.x, "bvar.l.d0.x"=bvar.l.d0.x, "bvar.dcst.x"=bvar.dcst.x, "bvar.l.dcst.x"=bvar.l.dcst.x, "bcst.dvar.x"=bcst.dvar.x, "bcst.dvar.l.x"=bcst.dvar.l.x, "bvar.dvar.x"=bvar.dvar.x))
  
  newname <- unlist(strsplit(file1, split="[.]"))[1]
  saveRDS(result.x, file=paste0(newname, "_", Order, "Temp.rds", sep=""))

}

#################running_panel#####################
######################################
#loading temperature data

Tem.C <- read.csv("./data/Temperature_Data_Layers/Global_paleo-temperature.csv", header = TRUE)



order.list <- c("Brassicales", "Celastrales", "Crossosomatales", "Cucurbitales", "Fabales", "Fagales", 
                "Geraniales", "Huerteales", "Malpighiales", "Malvales", "Myrtales", "Oxalidales", "Picramniales", "Rosales", 
                "Sapindales", "Zygophyllales", "Vitales")

par <- list(c(0.09), c(0.05, 0.01), c(0.05, 0.01), c(0.05, 0.01), c(0.05, 0.01, 0.005), c(0.09, 0.001, 0.005), c(0.05, 0.005, 0.01), 
            c(0.05, 0.005, 0.001), c(0.05, 0.01, 0.005, 0.0001))

dir.create("result")


dataset <- "5g"
#output table file name
file1 <- paste0("result/RPANDA_model_", dataset, ".csv", sep="")
#table header
cat("Clade,Model,lamda,rate_change,mu,rate_change,AICc\n", file = file1)

#read the whole tree
Total.tree <- read.tree(paste0("data/Rosid_Ultrametric_Trees/rosids_", dataset, "_whole_tree.tre", sep=""))
NN <- length(Total.tree$tip.label)
dof<-smooth.spline(Tem.C[,1], Tem.C[,2])$df


for (i in 1:length(order.list)){
  
  tryCatch({
    
    Order <- order.list[i]
    
    #read tree
    tree <- read.tree(paste("./data/Rosid_Ultrametric_Trees/", Order, "_", dataset, ".tre", sep=""))
    if(is.ultrametric(tree)){
      cat(paste0(Order, "\t", "TRUE", sep=""), sep = "\n")
    }else{
      tree <- force.ultrametric(tree, method="extend") #just make sure the tree is ultrametric
    }
    
    print(Order)
    fit.multi.rpanda(tree, par, Tem.C, Order, NN, dof, file1)
  })
}

