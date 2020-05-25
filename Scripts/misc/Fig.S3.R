rm(list=ls())

library(scales)

shifts <- read.csv("./results/rosid_5g_BAMM_diversification_shifts_age_for_major_clades.csv", header=TRUE)

Orders <- names(shifts)[3:length(names(shifts))]

shift_age_table <- data.frame(matrix(ncol=3, nrow=0))

for(i in 1:length(Orders)){
  OO <- Orders[i]
  if(length(na.omit(shifts[,i+2]))!=0){
    for (j in 1:length(na.omit(shifts[,i+2]))){
      Index <- paste(OO, "_", j, sep="")
      aa <- shifts[,i+2][j]
      dat <- cbind.data.frame(OO, Index, aa)
      shift_age_table <- rbind.data.frame(shift_age_table, dat)
    }
  }
}
colnames(shift_age_table) <- c("Order", "Shift", "Age")


for(i in 1:length(Orders)){
  OO <- Orders[i]
  if(length(na.omit(shifts[,i+2]))!=0){
    Age <- na.omit(shifts[,i+2])
    Index <- 1:length(na.omit(shifts[,i+2]))
    dd <- cbind.data.frame(Index,Age)
    if(i==1){
      plot(dd, pch=20, col=alpha("gray", 0.75))
    }else{
      points(dd, pch=20, col=alpha("gray", 0.75))
    }
  }
}

#############
library(ggridges)
library(ggplot2)
library(dplyr)
# Data from Order "Geraniales" and "Vitales" were removed for , because only 1 shift was detected ridges plot.
# No shifts were detected in Order "Crossosomatales", "Huerteales", "Oxalidales", "Picramniales", and "Zygophyllales" 

shift_age_table <- shift_age_table %>% group_by(Order) %>% filter(length(Age)>1) %>% arrange(Order)
Colors <- c("chocolate4", "darkmagenta", "green4", "blue", "yellow3", "sienna1", "magenta1", "lawngreen", "red", "slateblue4")

p1 <- ggplot(shift_age_table, aes(x = Age, y = Order, fill = Order)) +
  geom_density_ridges2(alpha = 0.95) +
  theme_ridges(grid = FALSE, center_axis_labels = TRUE) + 
  theme(axis.line.x = element_line(colour = "black"),legend.position = "none") +
  scale_fill_manual(values = Colors) +
  labs(x ="Age (Myr)") 

p2 <- ggplot(shift_age_table, aes(y=Age)) +
  geom_boxplot(fill = "lightgray", color = alpha("black", 0.5)) + labs(y ="Age (Myr)") +
  theme_bw() +
  theme(
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(), 
        axis.title.y.left = element_text(size=8))
  

pp <- p1 + annotation_custom(ggplotGrob(p2), xmin = 82, xmax = 125, 
                       ymin = 1.2, ymax = 4.8) +
  annotate("text", x=-20, y=11, label= "a", size = 5) + 
  annotate("text", x = 82, y=4.6, label = "b", size = 5)

ggsave("./results/Fig.S3.pdf", width = 6, height = 6)



