rm(list=ls())
library("ape")
library("tidyverse")

#read in tables
Annual_Tm <- read.csv("Rosid_Annual_Tmmean.csv", header=T)
bio1 <-   read.csv("bio1_associations_species_summary.csv", header = F)
Occ_records <- read.csv("Occredords_associations_species_summary.csv", header = F)

Koep <- read.csv("KoeppenTropics_associations_species_summary.csv", header = F)

Geo <- read.csv("Rosid_Latmean_tropica_binary.csv", header = T)
koep.bin <- read.csv("Rosid_KoeppenTropics_binary.csv", header = T)

#order list

order.list <- c("Brassicales", "Celastrales", "Crossosomatales", "Cucurbitales", "Fabales", "Fagales", 
                "Geraniales", "Huerteales", "Malpighiales", "Malvales", "Myrtales", "Oxalidales", "Picramniales", "Rosales", 
                "Sapindales", "Zygophyllales", "Vitales")

file1="Table_S1._rosid_17_order_richness_and_bio_Tm_layer_summary.csv"
cat("Order,Species_Richness,Ann_Tm,Occ_rec,Kope_rec,P.k.temp,P.k.trop,P.g.temp,P.g.trop\n",file=file1,sep="")

for(i in 1:length(order.list)){
  
  Order <- order.list[i]
  
  #read tree
  tree <- read.tree(paste("../../rosid_3rd/BAMM/data/5g/", Order, "/", Order, ".tre", sep=""))
  tree$tip.label <- sub("^.(.*)ceae_", "", tree$tip.label)
  
  N.bio <- sum(bio1[bio1$V1 %in% tree$tip.label,]$V2)
  N.occ <- sum(Occ_records[Occ_records$V1 %in% tree$tip.label,]$V2)
  N.Koep <- sum(Koep[Koep$V1 %in% tree$tip.label,]$V2)
  
  #caculate percentage for binary
  #koep
  trait.k <- koep.bin[koep.bin$Species %in% tree$tip.label, ]
  dat <- trait.k %>% count(Tropical)
  P.k.temp <- as.numeric(round(dat[dat$Tropical=="0",2]/sum(dat$n),4))
  P.k.trop <- as.numeric(round(dat[dat$Tropical=="1",2]/sum(dat$n),4))
  
  #geo
  
  trait.g <- Geo[Geo$Species %in% tree$tip.label, ]
  dat2 <- trait.g %>% count(T.binary)
  P.g.temp <- as.numeric(round(dat2[dat2$T.binary=="0",2]/sum(dat2$n),4))
  P.g.trop <- as.numeric(round(dat2[dat2$T.binary=="1",2]/sum(dat2$n),4))
  
  #write table
  #set species richness as "NA" for now, since it has been already summraized 
  cat(paste0(Order, ",NA,", N.bio, ",", N.occ, ",", N.Koep, ",", P.k.temp, ",", P.k.trop, ",",
             P.g.temp, ",", P.g.trop, sep=""), file=file1, sep="\n", append = TRUE)
}

