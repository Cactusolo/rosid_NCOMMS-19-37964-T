rm(list=ls())
library("tidyverse")

Trop.Koep <- read_csv("data/Tm_tropical_DR/Rosid_KoeppenTropics_binary.csv", col_names = TRUE)
Trop.Geo <- read_csv("data/Tm_tropical_DR/Rosid_Latmean_tropica_binary.csv", col_names = TRUE)

Tropical_sp_per <- function(clade, trait, qq, ff, xx){
  if(xx){
    tree <- read.tree("./5g_subclade/rosids_5g.tre")
    tree$tip.label <- sub("^.(.*)ceae_", "", tree$tip.label)
  } else{
    tree <- read.tree(paste0("./data/5g/", clade, "/", clade, ".tre", sep=""))
    tree$tip.label <- sub("^.(.*)ceae_", "", tree$tip.label)
  }
  
  if(qq){
    trait <- trait[trait$Species %in% tree$tip.label, ]
    dat <- trait %>% count(T.binary)
    P.temp <- round(dat[dat$T.binary=="0",2]/sum(dat$n),4)
    P.trop <- round(dat[dat$T.binary=="1",2]/sum(dat$n),4)
    cat(paste0(clade, ",", P.temp, ",",  P.trop, sep=""), file=ff, sep="\n", append = TRUE)
  }else{
    trait <- trait[trait$Species %in% tree$tip.label, ]
    dat <- trait %>% count(Tropical)
    P.temp <- round(dat[dat$Tropical=="0",2]/sum(dat$n),4)
    P.trop <- round(dat[dat$Tropical=="1",2]/sum(dat$n),4)
    cat(paste0(clade, ",", P.temp, ",",  P.trop, sep=""), file=ff, sep="\n", append = TRUE)
  }
}




f1="rosid_17order_binary_Trop.Geo.traits_sppercentage.csv"
f2="rosid_17order_binary_Trop.Koep.traits_sppercentage.csv"
f3="rosid_5g_binary_Trop.Geo&Koep.traits_sppercentage.csv"
# cat("Clade,Per.temp,Per.trop\n", file=f3)


Order <- read.csv("Order", header=F)
Order <- as.character(Order$V1)
# trait <- Trop.Geo
# qq <- TRUE
# ff <- f1

# trait <- Trop.Koep
# qq <- FALSE
# ff <- f2

for(i in 1:length(Order)){
  tryCatch({
    clade <- Order[i]
    Tropical_sp_per(clade, trait, qq, ff)
  })
}

################whole 5g tree###############
clade <- "rosid_5g"
# trait <- Trop.Geo
trait <- Trop.Koep
# qq <- TRUE
qq <- FALSE
ff <- f3
xx <- TRUE
Tropical_sp_per(clade, trait, qq, ff, xx)
