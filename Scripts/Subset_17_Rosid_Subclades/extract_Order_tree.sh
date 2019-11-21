#!/bin/bash
#This script is used to extract 17 order-level subtrees from Whole Rosid 5-gene dated tree under newickutils module
# for successful execution, either install [Newick Utilities](http://cegg.unige.ch/newick_utils)
# or running on UF HiPerGator

#usage: bash extract_Order_tree.sh tree-file

#keep "Order_MRCA.txt" file at the same dir as the bash script

Tree=$1

#read infor of each order is defined by MRCA of two tips on the whole tree

module load newickutils

for i in {1..17}
	do 
		Order=$(head -n $i Order_MRCA.txt|tail -1|cut -f1 -d',')
		TipA=$(head -n $i Order_MRCA.txt|tail -1|cut -f2 -d',')
		TipB=$(head -n $i Order_MRCA.txt|tail -1|cut -f3 -d',')
		#subset and ladderize the tree
		nw_clade $Tree $TipA $TipB|nw_order -c n - > ${Order}.tre
		echo -e "$Order tree is done!\n"
done
