#--------------------------------------------------
# FiSSE: A simple nonparametric test for the
# effects of a binary character on lineage diversification rates
#  Daniel L. Rabosky and Emma E. Goldberg 2016, Evolution. 
#  https://doi.org/doi:10.1111/evo.13227
# 
#
rm(list=ls())

library("ape")
library("mvtnorm")
library("phytools")
library("geiger")
library("phangorn")
library("diversitree")
#import function
source("./traitDependent_functions.R")

# parameter for the function
# FiSSE: A simple nonparametric test for the
# effects of a binary character on lineage diversification rates
#  Daniel L. Rabosky and Emma E. Goldberg 2016, Evolution. 
#  https://doi.org/doi:10.1111/evo.13227
# 
options(scipen=9999)
options( warn = -1 )

########################## 


#loading temperature layers

Trop.Koep <- read.csv("./Datasets/Temperature_Data_Layers/Rosid_Climatic_Tropics_binary.csv", header = TRUE)
Trop.Geo <- read.csv("./Datasets/Temperature_Data_Layers/Rosid_Geographic_Tropics_binary.csv", header = TRUE)

# Batch processing function for all 17 orders

runAnalyses <- function(clade, trait, bisse_opt = 5){
  
  tree <- read.tree(paste0("./Datasets/Rosid_Ultrametric_Trees/", clade, "_5g.tre", sep=""))
  tree$tip.label <- sub("^.(.*)ceae_", "", tree$tip.label)
  
  trait <- trait[trait$Species %in% tree$tip.label, ]
  states <- trait[,2] # commnent this if run Trop.Geo
  # states <- trait[,3] # commnent this if run Trop.Koep
  names(states) <- as.character(trait[,1])
  
  v <- drop.tip(tree, setdiff(tree$tip.label, names(states)))
  v <- check_and_fix_ultrametric(v)

  
  ff <- FISSE.binary(v, states, reps=1000)

  bisse <- fitDiversitree_allmodels(v, states, nopt=bisse_opt)
  
  ntips = length(v$tip.label)
  f0 <- sum(states == 0) / ntips
  f1 <- sum(states == 1) / ntips
  
  
  fisse <- c(ntips=ntips, f0=f0, f1=f1, unlist(ff))
  res <- list(id=clade, traits=trait, fisse=fisse, bisse=bisse)
  return(res)
}

Order <- read.csv("Order", header=F)
Order <- as.character(Order$V1)
# trait <- Trop.Koep

trait <- Trop.Geo

#preset table for output
file="rosid_17_order_binary_Trop.Geo.traits_fisse.csv"
cat("Clade,lambda0,lambda1,pval\n", file=file)


for(i in 1:length(Order)){

  tryCatch({
  clade <- Order[i]
  results <- runAnalyses(clade, trait)
  cat(paste0(results$id, ",", results$fisse[4], ",", results$fisse[5], ",",
             results$fisse[6], sep=""), file=file, sep="\n", append = TRUE)

  })
}
