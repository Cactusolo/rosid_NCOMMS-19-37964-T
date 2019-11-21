# Load the rData package with edata pre-loaded will improve the efficency

# required to comment or uncomment correspondingl lines
# if need to run analyses for different traits


rm(list=ls())

library("phytools")
library("ape")
library("coda")
library("BAMMtools")
library("geiger") # For drop.tips
# library("parallel")

########loading temperature layers ###########
#loading mean annual Tm
An_Tm <- read.csv("./Datasets/Temperature_Data_Layers/Rosid_Annual_Tm_mean.csv", header=TRUE)
An_Tm.vector <-  as.numeric(An_Tm$Tm.mean)
names(An_Tm.vector) <- An_Tm$Species

# #loading Koeppen-Geiger tropical data
Trop.Koep <- read.csv("./Datasets/Temperature_Data_Layers/Rosid_Climatic_Tropics_binary.csv", header = TRUE)
Trop.Koep.vector <-  as.numeric(Trop.Koep$Tropical)
names(Trop.Koep.vector) <- Trop.Koep$Species

#loading Geo tropical data
Trop.Geo <- read.csv("./Datasets/Temperature_Data_Layers/Rosid_Geographic_Tropics_binary.csv", header = TRUE)
Trop.Geo.vector <-  as.numeric(Trop.Geo$T.binary)
names(Trop.Geo.vector) <- Trop.Geo$Species

#Geo 
Trop.Geo.lat.vector <-  as.numeric(abs(Trop.Geo$Lat.mean))
names(Trop.Geo.lat.vector) <- Trop.Geo$Species

Table  <- NULL

strapp_var <- function(clade, file){

  tryCatch({
  print(clade)
    
  #loading tree
  tree <- read.tree(paste0("./Datasets/Rosid_Ultrametric_Trees/", clade, "_5g.tre", sep=""))
  
  # eventdata -posedu-code
  # event data is too large to upload to github
  edata <- getEventData(tree, paste0("path to event data", clade, "_event_data_final.txt",  sep=""), burnin = 0.8)
  # edata <- readRDS(paste0("data/5g/", clade, "/", clade, "_edata.rds", sep=""))
  
  edata$tip.label <- sub("^.(.*)ceae_", "", edata$tip.label)
  tree$tip.label <- sub("^.(.*)ceae_", "", tree$tip.label)
  
  #assoicate Mean Annual Tm
  # trait.vector1 <-  treedata(tree, An_Tm.vector)$data
  # An_Tm.vector <- trait.vector1[,1]
  # 
  # tips <- intersect(tree$tip.label, names(An_Tm.vector))
  # edata.sub1 <- subtreeBAMM(edata, tips = tips)
  # 
  # #Koeppen-Geiger tropical data
  # trait.vector2 <-  treedata(tree, Trop.Koep.vector)$data
  # Trop.Koep.vector <- trait.vector2[,1]
  # edata.sub2 <- subtreeBAMM(edata, tips = names(Trop.Koep.vector))
  # 
  # #Latitudinal tropical data
  # trait.vector3 <-  treedata(tree, Trop.Geo.vector)$data
  # Trop.Geo.vector <- trait.vector3[,1]
  # edata.sub3 <- subtreeBAMM(edata, tips = names(Trop.Geo.vector))
  # 
  #abs mean Latitude data
  trait.vector4 <-  treedata(tree, Trop.Geo.lat.vector)$data
  Trop.Geo.lat.vector <- trait.vector4[,1]
  edata.sub4 <- subtreeBAMM(edata, tips = names(Trop.Geo.lat.vector))
  # 
  # 
  # ####run correlation
  # Corr_An_Tm_Rate <-  traitDependentBAMM(edata.sub1, An_Tm.vector, 1000, return.full = FALSE, method = "spearman", logrates = TRUE, two.tailed = TRUE, traitorder = NA) 
  # Pmat <- Corr_An_Tm_Rate$p.value
  # # Corr_An_Tm_Rate1 <-  traitDependentBAMM(edata.sub1, An_Tm.vector, 1000, return.full = FALSE, method = "Pearson", logrates = TRUE, two.tailed = TRUE, traitorder = NA)
  # 
  # Corr_Trop.Koep_Rate <-  traitDependentBAMM(edata.sub2, Trop.Koep.vector, 1000, return.full = FALSE, method = "mann-whitney", logrates = TRUE, two.tailed = TRUE, traitorder = NA) 
  # Ptkoe <- Corr_Trop.Koep_Rate$p.value
  # 
  # Corr_Trop.Geo_Rate <-  traitDependentBAMM(edata.sub3, Trop.Geo.vector, 1000, return.full = FALSE, method = "mann-whitney", logrates = TRUE,  two.tailed = TRUE, traitorder = NA) 
  # Ptgeo <- Corr_Trop.Geo_Rate$p.value
  # 
  Corr_Trop.Geo.lat_Rate <-  traitDependentBAMM(edata.sub4, Trop.Geo.lat.vector, 1000, return.full = FALSE, method = "spearman", logrates = TRUE,  two.tailed = TRUE, traitorder = NA) 
  Ptgeo.lat <- Corr_Trop.Geo.lat_Rate$p.value
  
  #print(c(clade, Ptgeo.lat))
  cat(paste0(clade,",", Ptgeo.lat, sep=""), file=file, sep="\n", append = T)
  
  result <- data.frame(clade, Pmat, Ptkoe, Ptgeo, Ptgeo.lat)
  return(result)
  })
}

Order <- read.csv("Order", header=F)
Order <- as.character(Order$V1)

file="BAMM_rates_test_with_abs(meanlat).csv"
cat("Clade,Ptgeo.abs(Lat)\n", file=file)



for(i in 1:length(Order)){
  clade <- Order[i]
  # print(clade)
  strapp_var(clade, file)
  # Table <- rbind(Table, dd)
}

# write.table(Table, "rosid_traits_strapp.csv", sep=",", row.names = F, quote = F, append = T)
