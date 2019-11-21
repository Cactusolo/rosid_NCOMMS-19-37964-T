#!/bin/bash

#start from 2, so skip the table header
for i in {2..18}
	do
		Order=$(head -n $i rosid_17_order_sampling_fraction.csv|tail -1|cut -f1 -d',')
		mkdir $Order
		#echo $Order
		Fraction=$(head -n $i rosid_17_order_sampling_fraction.csv|tail -1|cut -f2 -d',')
		#echo $Number
		Shifts=$(grep "expectedNumberOfShifts" ${Order}_Priors.txt|cut -f3 -d' ')
		Lambda=$(grep "lambdaInitPrior" ${Order}_Priors.txt|cut -f3 -d' ')
		lambdaShift=$(grep "lambdaShiftPrior" ${Order}_Priors.txt|cut -f3 -d' ')
		muInitPrior=$(grep "muInitPrior" ${Order}_Priors.txt|cut -f3 -d' ')
		sed -e "s/XXX/$Order/g;s/VVV/$RANDOM/g;s/TTT/$Fraction/g;s/RRR/$Shifts/g;s/YYY/$Lambda/g;s/ZZZ/$lambdaShift/g;s/UUU/$muInitPrior/g" diversification.config >./${Order}/${Order}_diversification.config
		mv ${Order}_5g.tre ${Order}_Priors.txt ./${Order}/
done

