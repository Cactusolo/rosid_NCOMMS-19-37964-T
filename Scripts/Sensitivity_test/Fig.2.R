#clean running env
rm(list=ls())

# this script will combined all the plots from sensitivity test of species richness, tip age, and tip rates from DR and BAMM forming a 4-panel plot.

#loading packages
library(dggridR)
library(dplyr)
library(ape)
# devtools::install_github("kassambara/ggpubr")
library(ggpubr)


####Species_richness####
#Construct a global grid with cells approximately 322km (200 miles) across
#increased hex size
dggs <- dgconstruct(spacing=200, metric=FALSE, resround='down')

#Load rosid distribution data set
rosid_occ <- read.csv("./Datasets/Species_Distribution_Data/rosid_18269_species_occ.csv", header = F)

names(rosid_occ) <- c("Species", "Lon", "Lat")

#Get the corresponding grid cells for each rosid species epicenter (lat-long pair)
rosid_occ$cell <- dgGEO_to_SEQNUM(dggs,rosid_occ$Lon, rosid_occ$Lat)$seqnum

#Converting SEQNUM to GEO gives the center coordinates of the cells
cellcenters <- dgSEQNUM_to_GEO(dggs,rosid_occ$cell)

#Get the number of species in each cell
cell.sp.counts <- rosid_occ %>% group_by(cell) %>% filter(length(unique(Species)) >3) %>% summarise(count=n_distinct(Species))

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
p.sr<- ggplot() + 
  geom_polygon(data=countries, aes(x=long, y=lat, group=group), fill=NA, color="black")   +
  xlim(-200, 200) +
  geom_polygon(data=grid, aes(x=long, y=lat, group=group, fill=count), alpha=0.8)    +
  # theme_minimal() +
  theme(axis.title.x=element_blank(), axis.title.y=element_blank()) +
  scale_fill_gradientn(colours=c("deepskyblue", "yellow", "red"), na.value = "grey50", guide = "colourbar", aesthetics = "fill")
# ggsave("./results/Fig.S1.pdf", width = 7, height = 4)
####tip_age####
#Tree
# tree <- read.tree("./Datasets/Rosid_Ultrametric_Trees/rosids_5g_whole_tree.tre")
# tree$tip.label <- sub("^.(.*)ceae_", "", tree$tip.label)

# The age of each tip species was estimated from the most close node to it

# Date <- branching.times(tree)
# tip_age <- data.frame(matrix(nrow=length(tree$tip.label), ncol=3))
# colnames(tip_age) <- c("Species", "NodeID", "Age")
# for (i in 1:length(tree$tip.label)){
#   Species <- tree$tip.label[i]
#   Index <- as.character(tree$edge[match(i, tree$edge[, 2]),][1])
#   Age <- Date[Index][[1]]
#   tip_age[i,] <- cbind(Species, Index, Age)
# }

# tip_age <- tip_age %>% arrange(Species)
# write.csv(tip_age, "./results/rosid_5g_tip_age_cloest-node.csv", quote = F, row.names = F)

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
# p.ta<- ggplot() + 
#   geom_polygon(data=countries, aes(x=long, y=lat, group=group), fill=NA, color="black")   +
#   xlim(-200, 200) +
#   geom_polygon(data=grid, aes(x=long, y=lat, group=group, fill=median.age), alpha=0.8)    +
#    theme_minimal() +
#   theme(axis.title.x=element_blank(), axis.title.y=element_blank()) +
# 
#   # colorblind-friendly palette
#   # "skyblue"="#56B4E9"
#   # "Bluish green"="#009E73"
#   # "red"="#D55E00"
#   # "grey"="#999999"
#   # "orange"="#E69F00"
#   scale_fill_gradientn(colours=c("#009E73", "#56B4E9", "#E69F00"), na.value = "#999999", guide = "colourbar", aesthetics = "fill")

p.ta<- ggplot() +
  geom_polygon(data=countries, aes(x=long, y=lat, group=group), fill=NA, color="black")   +
  xlim(-200, 200) +
  geom_polygon(data=grid, aes(x=long, y=lat, group=group, fill=median.age), alpha=0.8)    +
  theme_minimal() +
  # theme(axis.title.x=element_blank(), axis.title.y=element_blank()) +
  scale_fill_gradientn(colours=c("#009E73", "#56B4E9", "#E69F00"), na.value = "#999999", guide = "colourbar", aesthetics = "fill")
# ggsave("./results/Fig2_new.pdf", width = 9, height = 4.5)
# 
# ggsave("./results/Fig.R2B.pdf", width = 7, height = 4)


#### BAMM tip.rates ####
rosid_rate.bamm <- read.csv("./results/rosids_5g_tipRates_BAMM.csv", header = TRUE)
rosid_rate.bamm$Tip_label <- sub("^.(.*)ceae_", "", rosid_rate.bamm$Tip_label)
rosid_rate.bamm <- rosid_rate.bamm %>% arrange(Tip_label)
names(rosid_rate.bamm) <- c("Species", "bamm.rate")

#### DR tip.rates ####
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
#remove outlior cells with species number <3
cell.sp.bamm.rate <- rosid %>% group_by(cell) %>% filter(length(unique(Species)) >3) %>% summarise(md.rate=median(as.numeric(bamm.rate), na.rm = TRUE))

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
p.bamm<- ggplot() + 
  geom_polygon(data=countries, aes(x=long, y=lat, group=group), fill=NA, color="black")   +
  xlim(-200, 200) +
  geom_polygon(data=grid, aes(x=long, y=lat, group=group, fill=md.rate), alpha=0.8)    +
  theme_minimal() +
  scale_fill_gradientn(colours=c("blue", "skyblue", "red"), na.value = "grey50", guide = "colourbar", aesthetics = "fill")

# ggsave("./results/Fig.R3A.pdf", width = 7, height = 4)

#### DR plot####

#Get median DR tip rate from rosid species in each cell
#remove outlior cells with species number <3
cell.sp.dr.rate <- rosid %>% group_by(cell) %>% filter(length(unique(Species)) >3) %>% summarise(md.dr.rate=median(as.numeric(dr.rate), na.rm = TRUE))

# Get the grid cell boundaries for cells with rosid species BAMM median rate
grid2 <- dgcellstogrid(dggs, cell.sp.dr.rate$cell, frame=TRUE, wrapcells=TRUE)


#Update the grid cells' properties to include the number of rosid species
#in each cell
grid2 <- merge(grid2, cell.sp.dr.rate, by.x="cell", by.y="cell")

#Make adjustments so the output is more visually interesting

cutoff2 <- quantile(grid2$md.dr.rate,0.9, na.rm = TRUE)
grid2 <- grid2 %>% mutate(md.dr.rate=ifelse(md.dr.rate>cutoff2,cutoff2,md.dr.rate))

#Plot everything on a flat map
p.dr<- ggplot() + 
  geom_polygon(data=countries, aes(x=long, y=lat, group=group), fill=NA, color="black")   +
  xlim(-200, 200) +
  geom_polygon(data=grid2, aes(x=long, y=lat, group=group, fill=md.dr.rate), alpha=0.8)    +
  theme_minimal() +
  scale_fill_gradientn(colours=c("blue", "skyblue", "red"), na.value = "grey50", guide = "colourbar", aesthetics = "fill")
# ggsave("./results/Fig.R3B.pdf", width = 7, height = 4)

#### Plot all ####
# ggarrange(p.sr+rremove("xlab"), p.ta, p.bamm, p.dr + rremove("ylab"), labels = c("A", "B", "C", "D"), ncol = 2, nrow = 2)

ggarrange(p.ta + rremove("xlab"), p.sr, p.bamm, p.dr + rremove("ylab"), labels = c("A", "B", "C", "D"), ncol = 2, nrow = 2)

ggsave("./results/Fig2_new2.pdf", width = 9, height = 4.5)
