#clean running env
rm(list=ls())

#loading packages
library(dggridR)
library(dplyr)
library(ape)

#Tree
tree <- read.tree("./Datasets/Rosid_Ultrametric_Trees/rosids_5g_whole_tree.tre")
tree$tip.label <- sub("^.(.*)ceae_", "", tree$tip.label)
# The age of each tip species was estimated from the most close node to it

Date <- branching.times(tree)
tip_age <- data.frame(matrix(nrow=length(tree$tip.label), ncol=3))
colnames(tip_age) <- c("Species", "NodeID", "Age")
for (i in 1:length(tree$tip.label)){
  Species <- tree$tip.label[i]
  Index <- as.character(tree$edge[match(i, tree$edge[, 2]),][1])
  Age <- Date[Index][[1]]
  tip_age[i,] <- cbind(Species, Index, Age)
}

#Construct a global grid with cells approximately 322km (200 miles) across
#increased hex size
dggs <- dgconstruct(spacing=200, metric=FALSE, resround='down')

#Load rosid distribution data set
rosid_occ <- read.csv("./Datasets/Species_Distribution_Data/rosid_18269_species_occ.csv", header = FALSE)
names(rosid_occ) <- c("Species", "Lon", "Lat")

#combind data

tip_age <- tip_age %>% arrange(Species)
write.csv(tip_age, "./results/rosid_5g_tip_age_cloest-node.csv", quote = F, row.names = F)

tip_age <- read.csv("./results/rosid_5g_tip_age_cloest-node.csv", header = T)

rosid <- left_join(rosid_occ, tip_age, by="Species")

#Get the corresponding grid cells for each rosid species epicenter (lat-long pair)
rosid$cell <- dgGEO_to_SEQNUM(dggs,rosid$Lon,rosid$Lat)$seqnum

#Converting SEQNUM to GEO gives the center coordinates of the cells
cellcenters <- dgSEQNUM_to_GEO(dggs,rosid$cell)

#Get median BAMM tip rate from rosid species in each cell
# cell.sp.age <- rosid %>% group_by(cell) %>% summarise(median.age=median(as.numeric(Age), na.rm = TRUE))

#remove outlior cells with species number <3 

cell.sp.age <- rosid %>% group_by(cell) %>% filter(length(unique(Species)) >3) %>% summarise(median.age=median(as.numeric(Age), na.rm = TRUE))
# Get the grid cell boundaries for cells with rosid species BAMM median rate
grid <- dgcellstogrid(dggs, cell.sp.age$cell, frame=TRUE, wrapcells=TRUE)


#Update the grid cells' properties to include the number of rosid species
#in each cell
grid <- merge(grid, cell.sp.age, by.x="cell", by.y="cell")

#Make adjustments so the output is more visually interesting

cutoff <- quantile(grid$median.age, 0.9, na.rm = TRUE)
grid <- grid %>% mutate(median.age=ifelse(median.age>cutoff, cutoff, median.age))

#Get polygons for each country of the world
countries <- map_data("world")


#Plot everything on a flat map
p<- ggplot() + 
  geom_polygon(data=countries, aes(x=long, y=lat, group=group), fill=NA, color="black")   +
  xlim(-200, 200) +
  geom_polygon(data=grid, aes(x=long, y=lat, group=group, fill=median.age), alpha=0.8)    +
  theme_minimal() +
  # colorblind-friendly palette
  # "skyblue"="#56B4E9"
  # "Bluish green"="#009E73"
  # "red"="#D55E00"
  # "grey"="#999999"
  # "orange"="#E69F00"
  scale_fill_gradientn(colours=c("#009E73", "#56B4E9", "#E69F00"), na.value = "#999999", guide = "colourbar", aesthetics = "fill")

p

ggsave("./results/rosid_species_tip-age_distribution_plot.pdf", width = 7, height = 4)
