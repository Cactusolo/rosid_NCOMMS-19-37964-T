# Script to automatically download from a species list
# NOTE the restrictive limit of 500 records -- change as needed
#clean running env

rm(list=ls())

#loading packages
library(ape)
library(rgbif)
library(ridigbio)

#here provide tips from rosids_5g_whole_tree.tre
Tree <- read.tree("./data/Rosid_Ultrametric_Trees/rosids_5g_whole_tree.tre")
#remove prefix family names
Tree$tip.label <- sub("^.(.*)ceae_", "", Tree$tip.label)
specieslist <- as.character(Tree$tip.label)


for	(i in specieslist) {
# Must try catch for species with no occurrence data
tryCatch({ 

print("Downloading GBIF data.")
item_gbif = occ_search(scientificName = i, return = "data", limit = 500, hasCoordinate = TRUE)
item_gbif = data.frame(item_gbif)
item_gbif_reduced = subset(item_gbif, select = c(species, decimalLongitude, decimalLatitude))
item_gbif_reduced_cleaned = item_gbif_reduced[(item_gbif_reduced$decimalLatitude != 0) & (item_gbif_reduced$decimalLongitude != 0),]

print("Downloading iDigBio data.")
item_idigbio = idig_search_records(rq=list(scientificname = i, geopoint = list(type="exists")), limit = 500)
item_idigbio = data.frame(item_idigbio)
item_idigbio_reduced = subset(item_idigbio, select = c(scientificname, geopoint.lon, geopoint.lat))
item_idigbio_reduced_cleaned = item_idigbio_reduced[(item_idigbio_reduced$geopoint.lat != 0) & (item_idigbio_reduced$geopoint.lon != 0),]

# Combine the data
combined_lon = c(item_gbif_reduced_cleaned$decimalLongitude, item_idigbio_reduced_cleaned$geopoint.lon)
combined_lat = c(item_gbif_reduced_cleaned$decimalLatitude, item_idigbio_reduced_cleaned$geopoint.lat)
species_name = rep(item_gbif_reduced_cleaned$species[1], length(combined_lon))
combined = data.frame(species_name, combined_lon, combined_lat)

print(head(combined))

write.table(combined, file = paste0("./results/", gsub(" ", "_", i), ".csv", sep = ""), sep = ",", quote = FALSE, row.names = FALSE)

}, error=function(e){cat("ERROR :",conditionMessage(e), "\n")})
}


