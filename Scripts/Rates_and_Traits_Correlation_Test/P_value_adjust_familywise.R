rm(list=ls())
library("tidyverse")

#read in p-value of ES-SIM test for each rosid order
files <- list.files("New_test_data_rosids_17", pattern = ".csv$", full.names = T)
essim <- read_csv(files[3], col_names = T)

# create a "dd" function to fo p.adjust
dd <- function(x){
  z <- p.adjust(x, method="hochberg")
}

essim.new <- essim %>% mutate(pv.adjust=dd(`P-value`))

#read in p-value of FiSSE from each order (binary traits)

fisse.Koep <- read_csv(files[2], col_names = T)
fisse.Koep.new <- fisse.Koep %>% mutate(pv.adjust=dd(pval))


fisse.Geo <- read_csv(files[1], col_names = T)
fisse.Geo <- fisse.Geo[,-5]
fisse.Geo.new <- fisse.Geo %>% mutate(pv.adjust=dd(pval))

#read in p-value generated from STRAPP in BAMMtools
strapp <- read_csv(files[4], col_names = T)

strapp.new <- strapp %>% mutate(pv.adjust.mat=dd(Pmat), 
                                pv.adjust.koe=dd(Ptkoe),
                                pv.adjust.geo=dd(Ptgeo))

results <- cbind.data.frame(essim.new[,-2], fisse.Geo.new[,4:5], fisse.Koep.new[,4:5],
                            strapp.new[,2], strapp.new[,5], strapp.new[,3], strapp.new[,6],
                            strapp.new[,4], strapp.new[,7])

#name the header of table
names(results) <- c("Clade", "P.essim", "P.ess.adjust", "P.fis.geo", "P.fis.geo.adjust",
                    "P.fis.koep", "P.fis.koep.adjust", "P.str.mat", "P.str.mat.adjust", "P.str.koe", "P.str.koe.adjust",
                    "P.str.geo", "P.str.geo.adjust")

#output
write.csv(results, "New_test_data_rosids_17/rosid_17order_traist_pvalue_adjuest.csv", row.names=F, quote=F)

