
rm(list=ls())
library("phytools")
library("ape")


tree <- read.tree("./data/rosids_5g.tre")
tree$tip.label <- sub("^.(.*)ceae_", "", tree$tip.label)

An_Tm <- read.csv("./data/Rosid_Annual_Tmmean.csv", header=TRUE, stringsAsFactors = FALSE)
Trobi <- read.csv("./data/Rosid_KoeppenTropics_binary.csv", header=TRUE, stringsAsFactors = FALSE)

aa <- An_Tm[An_Tm$Species %in% tree$tip.label, ]
Layer.t <- aa$Tm.mean/10
names(Layer.t) <- aa$Species
T.tre <- drop.tip(tree, setdiff(tree$tip.label, names(Layer.t)))

TT.tre <- ladderize(T.tre)

#define color of the outline rim based on Koep tropicality
color <- NULL

for(i in 1:length(TT.tre$tip.label)){ifelse(bb$Tropical[i]=="0", color[i] <- "blue", color[i] <- "orange")}

redblue<-colorRampPalette(c("blue", "blue", "skyblue", "red"), interpolate ="linear")

pdf("Fig_1.Rosid_annual_Tm_Koep_tmp_x3.pdf", height = 10, width = 10)

plotBranchbyTrait(TT.tre, Layer.t, "tips", palette=redblue, type="fan", 
                  show.tip.label=FALSE, legend=3, edge.width=0.5)
#TT <- rep("|", length(TT.tre$tip.label))
# tiplabels(TT, col=color, adj=0, frame="n", offset =0, cex=1)
dev.off()

#Note the final figure is edited and embellished by iTOL v5 (https://itol.embl.de/) and Inkscape outside R script.

