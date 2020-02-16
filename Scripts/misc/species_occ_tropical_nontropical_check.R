library("dplyr")

rosid_occ <- read.csv("./Datasets/Species_Distribution_Data/rosid_18269_species_occ.csv", header=F)
names(rosid_occ) <- c("Species", "Lon", "Lat")

files <- list.files("Clean_data", pattern=".csv$", full.names=TRUE)

Table <- NULL

for(i in 1:length(files)){
  
  #extract species name
  Species <- gsub(".csv", "", basename(files[i]))
  data <- read.csv(files[i], header = T)
  
  # get mean latitude value for each species
  Lat.mean <- mean(data$y)
  
  # define Geographic tropicality 
  # if this value fell between the Tropics of Cancer and Capricorn (23.43677°N and 23.43677°S)
  # assigned value "1"
  # and non-tropical (i.e. temperate + polar) if it fell outside this interval.
  # assigned value "0"
  T.binary <- ifelse(Lat.mean > -23.43677 & Lat.mean < 23.43677, "1", "0")
  dd <- c(Species, Lat.mean, T.binary)
  Table <- rbind(dd,Table)
}

Table <- as.data.frame(Table)
names(Table) <- c("Species", "Lat.mean", "T.binary")
