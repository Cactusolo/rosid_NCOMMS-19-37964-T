#--------------------------------------------------
# Trait dependent tests using ES-SIM
#  Harvey and Rabosky 2017, Methods Ecol. Evol. 
#  https://doi.org/10.1111/2041-210X.12949
# 
#
rm(list=ls())

library("ape")
library("mvtnorm")
library("phytools")
library("geiger")
library("tidyverse")

# import function
source("./essim.R")

# parameter for the function
# Trait dependent tests using ES-SIM
#  Harvey and Rabosky 2017, Methods Ecol. Evol. 
#  https://doi.org/10.1111/2041-210X.12949
options(scipen=9999)
options( warn = -1 )

###################Extract_table_function#############################

extract_table <- function(var, Rate){
  var.tmp <- var[which(var$Species %in% Rate$Tip_lable),]
  var.tmp <- var.tmp[order(var.tmp$Species),]
  Rate.tmp <- Rate[which(Rate$Tip_lable %in% var.tmp$Species),]
  Rate.tmp <- Rate.tmp[order(Rate.tmp$Tip_lable),]
  names(Rate.tmp) <- c("Species", "DR_rates")
  
  data <- left_join(var.tmp, Rate.tmp, by="Species")
  return(data)
}


#loading temperature layers

An_Tm <- read.csv("./Datasets/Temperature_Data_Layers/Rosid_Annual_Tm_mean.csv", header = TRUE, stringsAsFactors = FALSE)
Trop.Koep <- read.csv("./Datasets/Temperature_Data_Layers/Rosid_Climatic_Tropics_binary.csv", header = TRUE, stringsAsFactors = FALSE)
Trop.Geo <- read.csv("./Datasets/Temperature_Data_Layers/Rosid_Geographic_Tropics_binary.csv", header = TRUE, stringsAsFactors = FALSE)



ESSIM_Test <- function(clade){
  # if used for clade analyses please uncomment below line
  # tree <- read.tree(paste0("./Datasets/Rosid_Ultrametric_Trees/", clade,"_5g.tre", sep=""))
  tree <- read.tree("./Datasets/Rosid_Ultrametric_Trees/rosids_5g_whole_tree.tre")
  tree$tip.label <- sub("^.(.*)ceae_", "", tree$tip.label)
  
  
  #Rate
  # if used for clade analyses please uncomment below line
  # Rate <- read.csv(paste0("data/Tm_tropical_DR/rosid_5g_", clade, "_DR.csv", sep=""), header = TRUE)
  
  #Psedu-code
  Rate <- read.csv("Path to rates file", header = TRUE, stringsAsFactors = FALSE)
  Rate$Tip_label <- sub("^.(.*)ceae_", "", Rate$Tip_label)
  
  
  An_tm.sub <- extract_table(An_Tm, Rate)
  
  row.names(An_tm.sub) <- An_tm.sub$Species
  
  An_Tm.vector <-  treedata(tree, An_tm.sub)
  
  Tm <- as.numeric(An_Tm.vector$data[,2])
  names(Tm) <- rownames(An_Tm.vector$data)
  # as.numeric(levels(An_Tm.vector.data$Tm.mean))[An_Tm.vector.data$Tm.mean]
  
  DR <- as.numeric(An_Tm.vector$data[,3])
  names(DR) <- rownames(An_Tm.vector$data)
  
  essim(An_Tm.vector$phy, Tm, nsim= 3000, is = DR)
}

#clade
Order <- read.csv("Order", header=F)
Order <- as.character(Order$V1)

for(i in 1:length(Order)){
  clade <- Order[i]
  result <- ESSIM_Test(clade)
  print(paste0(clade, result, sep=","))
}


################whole 5g tree###############
clade <- "rosids_5g"
result <- ESSIM_Test(clade)
print(paste0(clade, result, sep=","))

