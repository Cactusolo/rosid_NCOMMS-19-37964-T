#### Scripts for running HiSSE 24 models with rosid tree and temperature data ####

library("hisse")
library("parallel")
library("geiger")


SimFunction <- function(Trait){
  tree <- read.tree("./rosids_5g_whole_tree.tre")
  tree$tip.label <- sub("^.(.*)ceae_", "", tree$tip.label)
  
  if(Trait=="Koep"){
    DD <- read.csv("./Rosid_Climatic_Tropics_binary.csv", header = TRUE)
    row.names(DD) <- DD$Species
  }
  
  if(Trait=="Geo"){
    DD <- read.csv("./Rosid_Geographic_Tropics_binary.csv", header = TRUE)
    DD <- DD[, -2]
    names(DD) <- c("Species", "Tropical")
    row.names(DD) <- DD$Species
  }
  
  tree_trait <- treedata(tree, DD, sort=TRUE, warnings=FALSE)
  phy <- tree_trait$phy
  sim.dat <- cbind(names(tree_trait$data[,2]), as.numeric(tree_trait$data[,2]))
  
  xx <- sum(sum(as.numeric(tree_trait[[2]][,2])))/dim(tree_trait[[2]])[1]
  sampling.f <- c(1-xx,xx)
  
  # We ensure that the epsilon parameter, ϵ=μ/λ is constrained to be equal for both tropical and non-tropical state. We’ll also constrain transition rates to be equal, since it can be difficult to estimate those.

  #BiSSE model pars
	trans.rates.bisse <- TransMatMaker(hidden.states=FALSE)
	trans.rates.bisse <-  ParEqual(trans.rates.bisse, c(1, 2))
	
	#HiSSE model pars: the constrained transition rates and epsilon
	trans.rates.hisse <- TransMatMaker(hidden.states=TRUE)
	trans.rates.hisse <- ParDrop(trans.rates.hisse, c(3,5,8,10))
	trans.rates.hisse <- ParEqual(trans.rates.hisse, c(1,2,1,3,1,4,1,5,1,6,1,7,1,8))
	
	hisse.fit <- NA
	
	RunModel <- function(model.number, sampling.f){
	  #### bisse_full ####
		if(model.number==1){
			try(hisse.fit <- hisse(phy, sim.dat, f=sampling.f, hidden.states = FALSE, turnover.anc = c(1,2,0,0), eps.anc = c(1,1,0,0), trans.rate = trans.rates.bisse, output.type="raw"))	
		}
	  
	  #### bisse_null ####
		if(model.number==2){
			try(hisse.fit <- hisse(phy, sim.dat, f=sampling.f, hidden.states=FALSE, turnover.anc=c(1,1,0,0), eps.anc=c(1,1,0,0), trans.rate=trans.rates.bisse, output.type="raw"))
		}
	  
	  #### hisse_full ####
		if(model.number==3){
			try(hisse.fit <- hisse(phy, sim.dat, f=sampling.f, hidden.states=TRUE, turnover.anc=c(1,2,3,4), eps.anc=c(1,1,1,1), trans.rate=trans.rates.hisse, output.type="raw"))	
		}
	  
	  #### hisse_cid2 ####
	  # 2 state character independent diversification model
	  # We’ll use this as our null model by forcing the visible states (tropical or non-tropical) to have the same net turnover rates, while permitting the hidden states to vary freely 
	  
		if(model.number==4){
			try(hisse.fit <- hisse(phy, sim.dat, f=sampling.f, hidden.states=TRUE, turnover.anc=c(1,1,2,2), eps.anc=c(1,1,1,1), trans.rate=trans.rates.hisse, output.type="raw"))
		}
		
		save(phy, hisse.fit, file=paste(Trait, model.number, "Rsave", sep="."))
	}
	mclapply(1:4, RunModel, sampling.f, mc.cores=4)
}

SimFunction(Trait="Koep")
SimFunction(Trait="Geo")


