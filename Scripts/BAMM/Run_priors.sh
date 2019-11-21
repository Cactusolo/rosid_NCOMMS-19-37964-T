#!/bin/bash

File=$1

module load R

#start from 2 to skip header
for i in {2..18}
	do
		Order=$(head -n $i rosid_17_order_sampling_fraction.csv|tail -1|cut -f1 -d',')
		#echo $Order
		Number=$(head -n $i rosid_17_order_sampling_fraction.csv|tail -1|cut -f2 -d',')
		#echo $Number
		sed -e "s/Order/$Order/g;s/Number/$Number/g" write_prior.R >${Order}_prior.R
		Rscript ${Order}_prior.R --no-save
done

