
#### mean latitude + Tropical binary ####
# this folder containing all cleaned distribution data from each rosid species 
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

write.csv(Table, "Rosid_Geographic_Tropics_binary.csv", quote = FALSE, row.names = FALSE)

#### mean annual Tm (bio1) ####
rm(list=ls())

files <- list.files("rosid_no_missing_data_bio1_associations/", pattern=".csv$", full.names=TRUE)

Table <- NULL

for(i in 1:length(files)){
  Species <- gsub("bio_1_pno_|\\.csv", "", basename(files[i]))
  data <- read.csv(files[i], header = T)
  Tm.mean <- mean(data[,2], na.rm=TRUE)
  dd <- c(Species, Tm.mean)
  Table <- rbind(dd,Table)
}

Table <- as.data.frame(Table)
names(Table) <- c("Species", "Tm.mean")

write.csv(Table, "Rosid_Annual_Tmmean.csv", quote = FALSE, row.names = FALSE)

#### KoeppenTropics ####

rm(list=ls())


#mode function

getmode <- function(v, na.rm = FALSE) {
  if(na.rm){
    v = v[!is.na(v)]
  }
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

#####
files <- list.files("rosid_no_missing_data_KoeppenTropics_associations", pattern=".csv$", full.names=TRUE)

Table <- NULL

for(i in 1:length(files)){
  Species <- gsub("KoeppenTropics_pno_|\\.csv", "", basename(files[i]))
  data <- read.csv(files[i], header = T)
  
  # previously calculated based on the Köppen-Geiger climatic tropics definition by Owens et al. (2017; that is, defining as tropical those regions with year-round monthly mean temperatures of > 18 °C)
  # This data is already a binary file get the mode as tropical status for each species
  Tropical <- getmode(data[,2], na.rm=TRUE)
  dd <- c(Species, Tropical)
  Table <- rbind(dd,Table)
}

Table <- as.data.frame(Table)
names(Table) <- c("Species", "Tropical")

write.csv(Table, "Rosid_KoeppenTropics_binary.csv", quote = FALSE, row.names = FALSE)

