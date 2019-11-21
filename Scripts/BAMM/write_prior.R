library("BAMMtools")
library("ape")

Order <- read.tree("Order.tre")
setBAMMpriors(Order, total.taxa = Number, outfile = "Order_Priors.txt")
