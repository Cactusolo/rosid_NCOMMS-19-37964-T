rm(list=ls())
library("scales")
# devtools::install_github("tomwenseleers/export")
library("export")

Orders <- c("Brassicales","Celastrales","Crossosomatales","Cucurbitales",
            "Fabales","Fagales","Geraniales","Huerteales","Malpighiales",
            "Malvales","Myrtales","Oxalidales","Picramniales","Rosales","Sapindales","Vitales","Zygophyllales")

Clade <- c(Orders, "rosid")

interpolation_5g <- readRDS("./results/interpolation_5g_tm_Netdiv.rds")

pdf("./results/FigS2.pdf", height = 10, width = 7)
par(mfrow = c(3, 2), mar = c(3,3.5,3.5,1), oma = c(0,0.5,0.5,0))

rateylab <- expression(paste("mean net diversification rate ( ","Myr"^"-1", ")"))
rateylab2 <- "log(mean net diversification rate)"

for (i in 1:length(Clade)){
# for (i in 1:3){
  if(i !=18){
    interpolation2 <- interpolation_5g[[i]]
    order <- names(interpolation_5g[i])
    print(order)
    
    plot(interpolation2$NetDivRate ~ interpolation2$corresponding_tempC_5pt, pch = 21, col=alpha("black", 0.4), bg=alpha("grey", 0.7), 
         cex.axis=0.8, xlab ="", ylab ="")
    title(paste0(order, "\n(linear model)"), line=0.6, cex.main=0.8)
    mtext(rateylab, cex=0.7, side=2, line=1.7)
    mtext("Temperature (°C)", cex=0.7, side=1, line=1.9)
    
    NDRate_temp_Linear_model2 <- lm(interpolation2$NetDivRate ~ interpolation2$corresponding_tempC_5pt)
    abline(NDRate_temp_Linear_model2, col="red")
    sqr3 <- summary(NDRate_temp_Linear_model2)$adj.r.squared
    Rlabel <- bquote(italic(R)^2 == .(format(sqr3, digits = 3)))
    text(mean(interpolation2$corresponding_tempC_5pt, na.rm = TRUE)*1.2, mean(interpolation2$NetDivRate, na.rm = TRUE)*1.3, col="red", cex=0.8, labels=Rlabel)
    
    AIC_NDRate_linear2 <- AIC(NDRate_temp_Linear_model2)
    Summ_NDRate_linear2 <- summary(NDRate_temp_Linear_model2)
    text(max(interpolation2$corresponding_tempC_5pt, na.rm = TRUE)*0.85, max(interpolation2$NetDivRate, 
                                                                             na.rm = TRUE)*0.85, col="red", cex=0.8, labels=paste0("AIC = ", round(AIC_NDRate_linear2, 2), sep=""))
    
    #diversification rate vs. temperature #5-locus
    plot(log(interpolation2$NetDivRate) ~ interpolation2$corresponding_tempC_5pt, pch = 21, col=alpha("black", 0.4), bg=alpha("grey", 0.7), 
         cex.axis=0.8, xlab ="", ylab ="")
    title(paste0(order, "\n(exponential model)"), line=0.6, cex.main=0.8)
    mtext(rateylab2, cex=0.7, side=2, line=1.7)
    mtext("Temperature (°C)", cex=0.7, side=1, line=1.9)
    
    NDRate_temp_model2 <- lm(log(interpolation2$NetDivRate) ~ interpolation2$corresponding_tempC_5pt) # Exponential model
    abline(NDRate_temp_model2, col="blue")
    sqr4 <- summary(NDRate_temp_model2)$adj.r.squared
    Rlabel <- bquote(italic(R)^2 == .(format(sqr4, digits = 3)))
    text(mean(interpolation2$corresponding_tempC_5pt, na.rm = TRUE), 
         mean(log(interpolation2$NetDivRate), na.rm = TRUE), col="blue", cex=0.8, labels=Rlabel)
    
    AIC_NDRate_log2 <- AIC(NDRate_temp_model2)
    Summ_NDRate_log2 <- summary(NDRate_temp_model2)
    text(max(interpolation2$corresponding_tempC_5pt, na.rm = TRUE)*0.85, max(log(interpolation2$NetDivRate)*1.1, 
                                                                             na.rm = TRUE), col="blue", labels=paste0("AIC = ", round(AIC_NDRate_log2, 2), sep=""))
    if(i ==3){
      mtext(c('a', 'aa'), outer = TRUE, line = -2.8, at = c(0.05,0.55), font=2)
      mtext(c('b', 'bb'), outer = TRUE, line = -28, at = c(0.05,0.55), font=2)
      mtext(c('c', 'cc'), outer = TRUE, line = -53.5, at = c(0.05,0.55), font=2)
    }
    if(i ==6){
      mtext(c('d', 'dd'), outer = TRUE, line = -2.8, at = c(0.05,0.55), font=2)
      mtext(c('e', 'ee'), outer = TRUE, line = -28, at = c(0.05,0.55), font=2)
      mtext(c('f', 'ff'), outer = TRUE, line = -53.5, at = c(0.05,0.55), font=2)
      
    }
    if(i ==9){
      mtext(c('g', 'gg'), outer = TRUE, line = -2.8, at = c(0.01,0.5), font=2)
      mtext(c('h', 'hh'), outer = TRUE, line = -28, at = c(0.01,0.5), font=2)
      mtext(c('i', 'ii'), outer = TRUE, line = -53.5, at = c(0.01,0.5), font=2)
      
    }
    if(i ==12){
      mtext(c('j', 'jj'), outer = TRUE, line = -2.8, at = c(0.05,0.55), font=2)
      mtext(c('k', 'kk'), outer = TRUE, line = -28, at = c(0.05,0.55), font=2)
      mtext(c('l', 'll'), outer = TRUE, line = -53.5, at = c(0.05,0.55), font=2)
      
    }
    if (i==15){
      mtext(c('m', 'mm'), outer = TRUE, line = -3, at = c(0.05,0.55), font=2)
      mtext(c('nn', 'nn'), outer = TRUE, line = -28, at = c(0.05,0.55), font=2)
      mtext(c('o', 'oo'), outer = TRUE, line = -53.5, at = c(0.05,0.55), font=2)
    }
    if (i==16){
      mtext(c('p', 'pp'), outer = TRUE, line = -3, at = c(0.05,0.55), font=2)
      mtext(c('q', 'qq'), outer = TRUE, line = -28, at = c(0.05,0.55), font=2)
    }
  }
  
}

dev.off()