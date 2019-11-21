# This script is used to check phylogeny signals between descreated traits and phylogeny

library("phytools")
library("geiger")

#TREE: 
tree <- read.tree("./Datasets/Rosid_Ultrametric_Trees/rosids_5g_whole_tree.tre")
tree$tip.label <- sub("^.(.*)ceae_", "", tree$tip.label)



####loading temperature layers####
An_Tm <- read.csv("./Datasets/Temperature_Data_Layers/Rosid_Annual_Tm_mean.csv", header = TRUE, stringsAsFactors = FALSE)
Trop.Koep <- read.csv("./Datasets/Temperature_Data_Layers/Rosid_Climatic_Tropics_binary.csv", header = TRUE, stringsAsFactors = FALSE)
Trop.Geo <- read.csv("./Datasets/Temperature_Data_Layers/Rosid_Geographic_Tropics_binary.csv", header = TRUE, stringsAsFactors = FALSE)



#Climatic_Tropics
kk <- Trop.Koep[Trop.Koep$Species %in% tree$tip.label, ]
Layer.k <- kk$Tropical
names(Layer.k) <- kk$Species
T.k.tre <- drop.tip(tree, setdiff(tree$tip.label, names(Layer.k)))
Test.k0 <- fitDiscrete(T.k.tre, Layer.k, model ="ER")
Test.k1 <- fitDiscrete(T.k.tre, Layer.k, model ="ER", transform="lambda")

P.v.k <- as.numeric(pchisq(2 * (Test.k1$opt$lnL - Test.k0$opt$lnL), df = 1, lower.tail = FALSE))

#Geographic_Tropics
gg <- Trop.Geo[Trop.Geo$Species %in% tree$tip.label, ]
Layer.g <- gg$T.binary
names(Layer.g) <- gg$Species
T.g.tre <- drop.tip(tree, setdiff(tree$tip.label, names(Layer.g)))
Test.g0 <- fitDiscrete(T.g.tre, Layer.g, model ="ER")
Test.g1 <- fitDiscrete(T.g.tre, Layer.g, model ="ER", transform="lambda")
P.v.g <- as.numeric(pchisq(2 * (Test.g1$opt$lnL - Test.g0$opt$lnL), df = 1, lower.tail = FALSE))

results <- list(Test.koep=c(Test.k0, Test.k1), Test.goe=c(Test.g0, Test.g1))
saveRDS(results, "pagle_lambda_phylogenetic_signals_between_descreated_traits_Koep_Geo.rds")

#mean Annual Temperature (continous trait)
aa <- An_Tm[An_Tm$Species %in% tree$tip.label, ]
Layer.t <- aa$Tm.mean
names(Layer.t) <- aa$Species
T.tre <- drop.tip(tree, setdiff(tree$tip.label, names(Layer.t)))

phylosig(T.tre, Layer.t, method = "lambda", test=TRUE)

P-value <- as.numeric(pchisq(2 * (logL1 - logL0), df = 1, lower.tail = FALSE))
