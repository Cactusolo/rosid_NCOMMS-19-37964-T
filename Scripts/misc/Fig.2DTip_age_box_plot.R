rm(list=ls())
library("dplyr")

tip_age <- read.csv("./results/rosid_5g_tip_age_cloest-node.csv", header=TRUE)
Keop_trop <- read.csv("./Datasets/Temperature_Data_Layers/Rosid_Climatic_Tropics_binary.csv", header = TRUE)
Geo_trop <- read.csv("./Datasets/Temperature_Data_Layers/Rosid_Geographic_Tropics_binary.csv", header = TRUE)

#Keop_trop-age
Tropic_age <- tip_age[tip_age$Species %in% Keop_trop[Keop_trop$Tropical=="1",]$Species,]
Tropic_age$Tropical <- rep("1", dim(Tropic_age)[1])

nontropic_age <- tip_age[tip_age$Species %in% Keop_trop[Keop_trop$Tropical=="0",]$Species,]

nontropic_age$Tropical <- rep("0", dim(nontropic_age)[1])

tip_age_tropical <- rbind.data.frame(Tropic_age, nontropic_age)
write.csv(tip_age_tropical, "./results/rosid_5g_tip_age_keop_tropicality.csv", quote = F, row.names = F)
#Geo_trop-age
Tropic_age.geo <- tip_age[tip_age$Species %in% Geo_trop[Geo_trop$T.binary=="1",]$Species,]
Tropic_age.geo$Tropical <- rep("1", dim(Tropic_age.geo)[1])

nontropic_age.geo <- tip_age[tip_age$Species %in% Geo_trop[Geo_trop$T.binary=="0",]$Species,]

nontropic_age.geo$Tropical <- rep("0", dim(nontropic_age.geo)[1])

tip_age_tropical.geo <- rbind.data.frame(Tropic_age.geo, nontropic_age.geo)
write.csv(tip_age_tropical.geo, "./results/rosid_5g_tip_age_geo_tropicality.csv", quote = F, row.names = F)

#remove outlior function
outlier <- function(x) {
  xx <- x[!x %in% boxplot.stats(x)$out]
  return(xx)
}

qrange <- c(0.05, 0.95)
width <- 0.4
color <- c("orange", "blue", "orange", "blue")

dat <- list("tropical.k"=Tropic_age$Age, "nontropical.k"=nontropic_age$Age, "tropical.g"=Tropic_age.geo$Age, "nontropical.g"=nontropic_age.geo$Age)

yrange <- c(0, quantile(unlist(sapply(dat, function(x) x)), 0.985))

pdf("./results/rosid_tip_age_tropical_vs_non_tropical_boxplot.pdf", width=6, height=4)
plot.new()
plot.window(xlim = c(1, 5), ylim = yrange)
axis(1, at = c(1, seq(1.5,5, by=1)), labels = NA)
axis(1, at = c(1, seq(1.5,5, by=1)), tick=FALSE, labels = c(NA,c("Tropical", "Non-tropical", "Tropical", "Non-tropical")), lwd=0, mgp = c(3, 0.7, 0), cex.axis =0.75, xpd=NA)

axis(2, at = c(0, axTicks(2)), cex.axis = 1, mgp = c(3, 0.7, 0))

for (j in 1:length(dat)) {
  jj <- j + 0.5
  
  if(quantile(dat[[j]],  qrange[2], na.rm=TRUE) > yrange[2]){
    dat[[j]] <- outlier(dat[[j]])
  }
  qStats <- quantile(dat[[j]], c(qrange[1], 0.25, 0.5, 0.75, qrange[2]), na.rm=TRUE)
  rect(jj - width/2, qStats[2], jj + width/2, qStats[4], col=alpha(color[j], 0.85))
  segments(jj, qStats[1], jj, qStats[2], lty=2, lend=1)
  segments(jj, qStats[4], jj, qStats[5], lty=2, lend=1)
  segments(jj - width/3, qStats[1], jj + width/3, qStats[1], lend=1)
  segments(jj - width/3, qStats[5], jj + width/3, qStats[5], lend=1)
  segments(jj - width/3, qStats[3], jj + width/3, qStats[3], lwd=2, lend=1)
}
abline(v = 3, lty=2, col="gray70")

title(main = "Climatic         Geographic", cex=0.8, line = -0.5)
mtext("Age (Myr)", side = 2, line = 2)

dev.off()

#### Climatic ####
t.test(Tropic_age$Age, nontropic_age$Age, alternative="greater")
#p-value < 2.2e-16

####Geo####
t.test(Tropic_age.geo$Age, nontropic_age.geo$Age, alternative="greater")
#p-value < 2.2e-16
