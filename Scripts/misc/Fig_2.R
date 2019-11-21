rm(list=ls())
library("BAMMtools") 
library("mapplots")
library("RPANDA")
library("strap")
source("plotRateThroughtTime2.R")
library("scales")
#Tm data

InfTemp <- read.csv("../../data/Temperature_Data_Layers/Global_paleo-temperature.csv", header = TRUE)

smoothingSpline <-  smooth.spline(InfTemp$Temp_C ~ InfTemp$Age, spar=0.35)

#Koep tropical binary data
Tropical <- read.csv("rosid_17order_binary_Trop.Koep.traits_sppercentage.csv", header = TRUE, stringsAsFactors = F)
#rosid clades
Clade_list<- c("Brassicales","Celastrales","Crossosomatales","Cucurbitales",
               "Fabales","Fagales","Geraniales","Huerteales","Malpighiales",
               "Malvales","Myrtales","Oxalidales","Picramniales","Rosales", "Sapindales","Vitales","Zygophyllales")


col=c("chocolate4","darkmagenta","paleturquoise4", "green4", "blue", "yellow3","palevioletred1","mediumturquoise",
      "sienna1","magenta1","lawngreen","khaki4","orangered4","red","slateblue4","yellow", "plum")




pdf("Fig_2.Rosid_17order_Net_Diversification_Rate_Against_Tm_Koep.pdf", height = 10, width = 10)
par(mfrow = c(3, 3), mar = c(3,3.5,1,3.5), oma = c(0,0.5,0.5,0))
for (i in 1:length(Clade_list)){
  Order <- Clade_list[i]
  rate_matrix <- readRDS(paste0("./data/5g_rtt_mtx/", Order, "_RateThroughTimeMatrix.rds", sep=""))

# par(mar=c(1, 0.5, 1, 5))
#rateylab <- expression(paste("Rate (","Myr"^"-1", ")"))

plotRateThroughtTime_modified(rate_matrix, ratetype = "netdiv", useMedian=TRUE, intervals=c(0.05,0.95), mar = c(3, 3.5, 3, 3.5), intervalCol='gray70', avgCol=col[i], opacity=1, cex.lab = 0.7, xline=2, yline=2, cex.axis=0.7)

par(new=TRUE)

plot(smoothingSpline, col='skyblue', axes = F, xlim=c(max(rate_matrix$times),0), type = "l", lwd=2, xlab="", ylab="")

axis(4, cex.axis=0.7)
mtext("Temperature (°C)", line=1.8, side=4, cex=0.7)

# if(i%%3==0 | i==17){mtext("Temperature (°C)", line=1.8, side=4)}
legend(max(rate_matrix$times)/2, 4, legend=c(Clade_list[i], "Historical Tm"), 
         col=c(col[i], "skyblue"), cex=0.7, lty=1, bty = "n")

#pie data
PP <- as.numeric(Tropical[i,-1])

# pct <- round(PP/sum(PP)*100, 2)
# labels=c("Temperate", "Tropical")
# lbls <- paste(labels, paste0(pct, "%", sep=""), sep="\n") # add percents to labels 
# 

par(new=TRUE)
# add.pie(PP, x=max(rate_matrix$times)/5, y=18, radius=1.4, labels=lbls, col=c(alpha("light green", 0.6), alpha("coral2", 0.6)), cex=0.5)
add.pie(PP, x=max(rate_matrix$times)/5, y=18, radius=1.4, labels="", col=c(alpha("blue", 0.6), alpha("orange", 0.6)), cex=0.5)
if(i ==9){
  mtext(c('(a)', '(b)', '(c)'), outer = TRUE, line = -2.8, at = c(0.01,0.36,0.7), font=2)
  mtext(c('(d)', '(e)', '(f)'), outer = TRUE, line = -28.5, at = c(0.01,0.36,0.69), font=2)
  mtext(c('(g)', '(h)', '(i)'), outer = TRUE, line = -53, at = c(0.01,0.365,0.69), font=2)
  
}
if (i==17){
  mtext(c('(j)', '(k)', '(l)'), outer = TRUE, line = -3, at = c(0.01,0.37,0.695), font=2)
  mtext(c('(m)', '(n)', '(o)'), outer = TRUE, line = -28, at = c(0.01,0.36,0.7), font=2)
  mtext(c('(p)', '(q)'), outer = TRUE, line = -54.5, at = c(0.01,0.36), font=2)
}

}
dev.off()