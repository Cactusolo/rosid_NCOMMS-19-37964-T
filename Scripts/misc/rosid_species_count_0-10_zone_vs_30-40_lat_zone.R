library("dplyr")

rosid_occ <- read.csv("./Datasets/Species_Distribution_Data/rosid_18269_species_occ.csv", header=F)
names(rosid_occ) <- c("Species", "Lon", "Lat")

# 0-10-degree latitude zone

# 30-40-degree latitude zone

D0_10 <- rosid_occ %>% filter(between(Lat, -10, 10)) %>% group_by(Species) %>% summarise(count=n())
D30_40 <- rosid_occ %>% filter(xor(between(Lat, 30, 40), between(Lat, -40, -30))) %>% group_by(Species) %>% summarise(count=n())



