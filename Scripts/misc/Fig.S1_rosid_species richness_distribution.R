#clean running env
rm(list=ls())

#loading packages
library(dggridR)
library(dplyr)

#Construct a global grid with cells approximately 322km (200 miles) across
#increased hex size
dggs <- dgconstruct(spacing=200, metric=FALSE, resround='down')

#Load rosid distribution data set
rosid <- read.csv("./Datasets/Species_Distribution_Data/rosid_18269_species_occ.csv", header = F)

names(rosid) <- c("Species", "Lon", "Lat")

#Get the corresponding grid cells for each rosid species epicenter (lat-long pair)
rosid$cell <- dgGEO_to_SEQNUM(dggs,rosid$Lon,rosid$Lat)$seqnum

#Converting SEQNUM to GEO gives the center coordinates of the cells
cellcenters <- dgSEQNUM_to_GEO(dggs,rosid$cell)

#Get the number of species in each cell
cell.sp.counts <- rosid %>% group_by(cell) %>% summarise(count=n_distinct(Species))

# Get the grid cell boundaries for cells with rosid species
grid <- dgcellstogrid(dggs, cell.sp.counts$cell, frame=TRUE, wrapcells=TRUE)


#Update the grid cells' properties to include the number of rosid species
#in each cell
grid <- merge(grid, cell.sp.counts, by.x="cell", by.y="cell")

#Make adjustments so the output is more visually interesting
#actual count, no log
# grid$count <- log(grid$count)
cutoff <- quantile(grid$count,0.9)
grid <- grid %>% mutate(count=ifelse(count>cutoff,cutoff,count))

#Get polygons for each country of the world
countries <- map_data("world")


#Plot everything on a flat map
p<- ggplot() + 
  geom_polygon(data=countries, aes(x=long, y=lat, group=group), fill=NA, color="black")   +
  xlim(-200, 200) +
  geom_polygon(data=grid, aes(x=long, y=lat, group=group, fill=count), alpha=0.8)    +
  # geom_path(data=grid, aes(x=long, y=lat, group=group), alpha=0.4, color="white") +
  # geom_point(aes(x=cellcenters$lon_deg, y=cellcenters$lat_deg), size=0.001) +
  theme_minimal() +
  scale_fill_gradientn(colours=c("deepskyblue", "yellow", "red"), na.value = "grey50", guide = "colourbar", aesthetics = "fill")

p

ggsave("./results/rosid_diversity_distribution_plot.pdf")

