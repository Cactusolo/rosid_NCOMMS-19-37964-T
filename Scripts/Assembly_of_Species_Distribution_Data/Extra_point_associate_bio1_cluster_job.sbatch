#!/bin/sh
#SBATCH --job-name=OYO    #Job name
#SBATCH --mail-type=ALL   # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=xxxx@ufl.edu   # Where to send mail	
#SBATCH --mem-per-cpu=12gb   # Per processor memory
#SBATCH -t 96:00:00    # Walltime hrs:min:sec
#SBATCH -o ExtracptVlue_%j.out	   # Name output file 
#SBATCH --qos=soltis-b

#loading modules
ml gdal python3

date 

mkdir rosid_no_missing_data_point_associations
python3 rosid_samples_associate_with_distribution_and_traits_cleaning.py bio_1.asc -l *.csv

date
# Note:
# bio_1.asc is the annual mean temperature data from 1970-2000 using WorldClim.
# `*.csv` will capture all the rosid species distribution data files