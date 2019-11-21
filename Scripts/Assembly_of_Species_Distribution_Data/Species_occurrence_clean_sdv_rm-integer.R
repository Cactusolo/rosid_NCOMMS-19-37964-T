#clean running env
rm(list=ls())

library(raster)
# library(tidyverse)

if (!dir.exists("Clean_data")) {
  dir.create("Clean_data")
}

sp_inter <- "species_coor_integer.csv"

files <- list.files("species_distribution_data_folder", pattern=".csv$", full.names=TRUE)

for(i in 1:length(files)){

  Species <- gsub(".csv", "", basename(files[i]))
  
  data <- read.csv(files[i], header = T)
  
  #center point
  Center_x <- mean(data$combined_lon) 
  Center_y <- mean(data$combined_lat) 
  
  #3 times stdv
  Stdev_x <- sd(data$combined_lon)*3
  Stdev_y <- sd(data$combined_lat)*3
  
  stdev_distance <-  pointDistance(c(Center_x + Stdev_x, Center_y + Stdev_y), c(Center_x, Center_y), lonlat = TRUE)/1000
  
  clean_data <- NULL
  for(j in 1:dim(data)[1]){
    
    ddistance <- pointDistance(c(data[j,2], data[j,3]), c(Center_x, Center_y), lonlat = TRUE)/1000

    if((ddistance < stdev_distance) & !is.na(ddistance) & !is.na(stdev_distance)){
      tt <- cbind(data[j,], ddistance)
    }
    clean_data <- rbind(clean_data, tt)
  }
    clean_data <- as.data.frame(clean_data)
    
    write.csv(clean_data, paste0("Clean_data/", Species, "_clean_data.csv", sep=""), quote = FALSE, row.names = FALSE)
    
    #further clean layer
    qq <- clean_data[, 1:3]
    names(qq) <- c("species", "x", "y")
    
    #remove integer
    if(sum(qq$x%%1==0 & qq$y%%1==0) > 0){
      qq <- qq[-which(qq$x%%1==0 & qq$y%%1==0),]
      qq <- unique(qq)
      cat(Species, file=sp_inter, sep="\n", append = TRUE)
    }else{
      qq <- unique(qq)
    }
    write.csv(qq, paste0("Clean_data/", Species, ".csv", sep=""), quote = FALSE, row.names = FALSE)

}

