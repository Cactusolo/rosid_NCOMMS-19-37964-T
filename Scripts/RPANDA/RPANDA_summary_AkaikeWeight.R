rm(list=ls())

library("tidyverse")

# defined a function for caculate AkaikeWeight
AKW <- function(x){
  Delta.AIC <- x -min(x)
  AkaikeWeight <- BMhyd::AkaikeWeight(Delta.AIC)
  return(AkaikeWeight)
}

#defined a function to read a dataset, and output a table with AkaikeWeight and best model based on AkaikeWeight
sum_result <- function(data){
  
  table <- data
  table.new <- table %>% group_by(Clade) %>% mutate(AW=AICc) %>% mutate_at("AW", AKW)
  
  write.csv(table.new, "RPANDA_model_5-locus_17_order_Rate_AkaikeWeight.csv", row.names = FALSE, quote=F)
  
  sum_result <- table %>% group_by(Clade) %>% mutate(AW=AICc) %>% mutate_at("AW", AKW) %>%
    filter(AW==max(AW))
  
  write.csv(sum_result, "RPANDA_bestmodel_5-locus_17_order_AkaikeWeight.csv", row.names = FALSE, quote=F)
}

#apply the function to the results generated from "RPANDA.R" script

data <- read_csv("result/RPANDA_model_5g.csv", col_names = T)

sum_result(data)
