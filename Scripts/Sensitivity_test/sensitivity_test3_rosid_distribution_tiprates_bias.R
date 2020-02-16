#clean running env
rm(list=ls())

#loading packages
library(dggridR)
library(dplyr)

#Construct a global grid with cells approximately 322km (200 miles) across
#increased hex size
dggs <- dgconstruct(spacing=200, metric=FALSE, resround='down')

#Load rosid distribution data set
rosid_occ <- read.csv("./Datasets/Species_Distribution_Data/rosid_18269_species_occ.csv", header = FALSE)
names(rosid_occ) <- c("Species", "Lon", "Lat")
# rosid_occ <- na.omit(rosid_occ)
# write.csv(rosid_occ, "./Datasets/Species_Distribution_Data/rosid_18269_species_occ.csv")

# BAMM tip.rates
rosid_rate.bamm <- read.csv("./results/rosids_5g_tipRates_BAMM.csv", header = TRUE)
rosid_rate.bamm$Tip_label <- sub("^.(.*)ceae_", "", rosid_rate.bamm$Tip_label)
rosid_rate.bamm <- rosid_rate.bamm %>% arrange(Tip_label)
names(rosid_rate.bamm) <- c("Species", "bamm.rate")

# DR tip.rates
rosid_rate.dr <- read.csv("./results/rosids_5g_tipRates_DR.csv", header = TRUE)
rosid_rate.dr$Tip_label <- sub("^.(.*)ceae_", "", rosid_rate.dr$Tip_label)
rosid_rate.dr <- rosid_rate.dr %>% arrange(Tip_label)
names(rosid_rate.dr) <- c("Species", "dr.rate")

# combined distribution data, BAMM and DR tip rates
tmp <- left_join(rosid_occ,rosid_rate.bamm, by="Species")
rosid <- left_join(tmp, rosid_rate.dr, by="Species")

#Get the corresponding grid cells for each rosid species epicenter (lat-long pair)
rosid$cell <- dgGEO_to_SEQNUM(dggs,rosid$Lon,rosid$Lat)$seqnum

#Converting SEQNUM to GEO gives the center coordinates of the cells
cellcenters <- dgSEQNUM_to_GEO(dggs,rosid$cell)

#Get median BAMM tip rate from rosid species in each cell
cell.sp.bamm.rate <- rosid %>% group_by(cell) %>% summarise(md.rate=median(as.numeric(bamm.rate), na.rm = TRUE))

# Get the grid cell boundaries for cells with rosid species BAMM median rate
grid <- dgcellstogrid(dggs, cell.sp.bamm.rate$cell, frame=TRUE, wrapcells=TRUE)


#Update the grid cells' properties to include the number of rosid species
#in each cell
grid <- merge(grid, cell.sp.bamm.rate, by.x="cell", by.y="cell")

#Make adjustments so the output is more visually interesting

cutoff <- quantile(grid$md.rate,0.9, na.rm = TRUE)
grid <- grid %>% mutate(md.rate=ifelse(md.rate>cutoff,cutoff,md.rate))

#Get polygons for each country of the world
countries <- map_data("world")


#Plot everything on a flat map
p<- ggplot() + 
  geom_polygon(data=countries, aes(x=long, y=lat, group=group), fill=NA, color="black")   +
  xlim(-200, 200) +
  geom_polygon(data=grid, aes(x=long, y=lat, group=group, fill=md.rate), alpha=0.8)    +
  theme_minimal() +
  scale_fill_gradientn(colours=c("blue", "skyblue", "red"), na.value = "grey50", guide = "colourbar", aesthetics = "fill")

p

ggsave("./results/rosid_species_BAMM_tiprates_distribution_plot.pdf", width = 7, height = 4)

#DR

#Get median DR tip rate from rosid species in each cell
cell.sp.dr.rate <- rosid %>% group_by(cell) %>% summarise(md.dr.rate=median(as.numeric(dr.rate), na.rm = TRUE))

# Get the grid cell boundaries for cells with rosid species BAMM median rate
grid2 <- dgcellstogrid(dggs, cell.sp.dr.rate$cell, frame=TRUE, wrapcells=TRUE)


#Update the grid cells' properties to include the number of rosid species
#in each cell
grid2 <- merge(grid2, cell.sp.dr.rate, by.x="cell", by.y="cell")

#Make adjustments so the output is more visually interesting

cutoff2 <- quantile(grid2$md.dr.rate,0.9, na.rm = TRUE)
grid2 <- grid2 %>% mutate(md.dr.rate=ifelse(md.dr.rate>cutoff2,cutoff2,md.dr.rate))

#Plot everything on a flat map
p2<- ggplot() + 
  geom_polygon(data=countries, aes(x=long, y=lat, group=group), fill=NA, color="black")   +
  xlim(-200, 200) +
  geom_polygon(data=grid2, aes(x=long, y=lat, group=group, fill=md.dr.rate), alpha=0.8)    +
  theme_minimal() +
  scale_fill_gradientn(colours=c("blue", "skyblue", "red"), na.value = "grey50", guide = "colourbar", aesthetics = "fill")

p2

ggsave("./results/rosid_species_DR_tiprates_distribution_plot.pdf", width = 7, height = 4)
