rm(list=ls())
library("BAMMtools") 
library("coda")

# assuming event data and mcmc out files generated by BAMM
# are store under folder named by each of 17 orders
# e.g. "working_dir/Rosales/Rosales_event_data_final.txt"
# e.g. "working_dir/Rosales/Rosales_mcmc_out_final.txt"

cladelist <- read.csv("./Scripts/BAMM/Order", header=F)

Order <- as.character(cladelist$V1)

#define a file with header for caculated the effective sample size (ESS)
cat("clade\tlogLik\tN_shift\n", file="../Rosids_17Order_ESS_convergence.txt")

for(i in 1:length(Order)){
  
  if(!dir.exists("results")){
    dir.create("results")
  }
  
  clade <- Order[i]
  
  basepath <- as.character(getwd())
  
  setwd(paste(basepath, clade, sep=""))
  
  tree <- read.tree(file = paste(clade, "_5g.tre", sep=""))
  
  #BAMM object
  edata <- getEventData(tree, paste(clade, "_event_data_final.txt", sep=""), burnin = 0.1)
  summary(edata)
  saveRDS(edata, file=paste("results/", clade, "_edata.rds", sep=""))
  #edata <- readRDS(file=paste("results/", clade, "_edata.rds", sep=""))
  
  #Assessing MCMC convergence
  mcmc <- read.csv(paste(clade, "_mcmc_out_final.txt", sep=""), header=T)
  pdf(paste("results/", clade, "_MCMC_convergent.pdf", sep=""))
  plot(mcmc$logLik ~ mcmc$generation)
  dev.off()
  
  burnstart <- floor(0.1*nrow(mcmc))
  postburn <- mcmc[burnstart:nrow(mcmc), ]#postburn is the generations left after burning
  
  #next caculate the effective sample size (ESS), which should be greater than 200 if our analysis
  # ran long enough
  logLik <- effectiveSize(postburn$logLik) # calculates autocorrelation function
  N_shift <- effectiveSize(postburn$N_shift) #effective sample size on N-shifts
  ESSample <- cbind.data.frame(clade, logLik, N_shift)
  
  write.table(ESSample, "../Rosids_17Order_ESS_convergence.txt", row.names=F, quote=F, append=T, sep="\t")
  
  #tip rates
  TR <- getTipRates(edata, returnNetDiv = FALSE, statistic = "median")
  file <- paste0("results/", clade, "_BAMM_TipRates.csv", sep="")
  cat("Tip_label,Rate\n", file=file)
  write.table(TR$lambda.avg, sep=",", file=file, col.names = FALSE, quote=FALSE, append = TRUE)
  
  ##### Prepare Mean Rate Matrix ####
  rtt <- getRateThroughTimeMatrix(edata)
  Mean.lamda <- apply(rtt$lambda, 2, quantile,  c(0.5))
  Mean.mu <- apply(rtt$mu, 2, quantile,  c(0.5))
  mean.netdiv <- Mean.lamda - Mean.mu
  
  Mean.Rate.Matrix <- cbind.data.frame(rtt$times, Mean.lamda, Mean.mu, mean.netdiv)
  write.csv(Mean.Rate.Matrix, paste("results/", clade, "_Mean_Rate_Matrix.csv", sep=""), row.names = FALSE, quote=FALSE)
  
  saveRDS(rtt, paste("./results/", clade, "_RateThroughTimeMatrix.rds", sep=""))
}



