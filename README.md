# rosid_NCOMMS-19-37964-T

_Scripts and documentation are provided here with an assumption that users have basic knowledge of UNIX shell, R and python, including changing the working directory, and pointing to the input and output path linking data to properly execute the scripts. In order to fully reproduce the results in our study, high performance computing clusters ([HiPerGator](https://www.rc.ufl.edu/) at University of Florida) must be used._  

_For the logic integrity of the data analyses conducted in present study, we layout below each of our scripts based on the order of the workflow as described in the main text. All the scripts and their relative folders are descriptively named based on their primary functionalities in the analyses, and detailed under each highlighted bullet point._


## Datasets


  + **Rosid Ultrametric Trees**  
  As described in the main text, all analyses were run in parallel across 17 subclades corresponding to all rosid orders recognized in [APG IV (2016)](https://onlinelibrary.wiley.com/doi/10.1111/boj.12385); for DR related analyses, we also used the total tree, since it was computationally feasible to use semi-parametric methods (see details in the main text).  

+ **Species Distribution Data**  
  We queried all rosid species sampled in our tree from iDigBio and GBIF using R packages rgbif v1.3.0 and ridigbio v0.3.5 on June 4th, 2019. No further taxonomic name resolution has been done for these rosid names, since all rosid species names in our tree were validated and reconciled by The Plant List and OpenTree databases in [Sun et al. (2019)](https://www.biorxiv.org/content/10.1101/694950v2.full).


+ **Temperature Data Layers**  
  We used four datasets to assess the relationship of temperature and rosid diversification.
    - Rosid_Annual_Tm_mean.csv  
    
      _continuous trait_  
      _Note: this data was directly downloaded from WorldClim website, then associated with rosid species distribution data using `python script` described below._  
      
    - Rosid_Climatic_Tropics_binary.csv  
    - Rosid_Geographic_Tropics_binary.csv  
      _Derived from **Species Distribution Data** mentioned above, and detailed in the materials and methods section and Supplementary files, as well as scripts list below._  
    - Global_paleo-temperature.csv  
      _Historical oxygen isotope (δ18O) data were derived from [Cramer et al. (2009)](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2008PA001683)_  

## Scripts  

_**Note:** Please modify and confirm the input and output path before executing these scripts. All the file names here assigned for the specific purpose._  

+ **Subset 17 Rosid Subclades**  
  	- _**extract_Order_tree.sh**_  
  		Usage: bash extract_Order_tree.sh rosids_5g_whole_tree.tre  
  		_Note: keep "Order_MRCA.txt" file at the same dir as the bash script_  
  		 
+ **Assembly of Species Distribution Data**  
    - _**Download_rosid_distribution_from_gbif_idigbio_ed.R**_  
        This R script querys iDigBio and GBIF databases with name validated rosid species sampled in the phylogeny and excluding any coordinates with zero latitude and longitude.  
    
    - _**rosid_samples_associate_with_distribution_and_traits_cleaning.py**_  
        This python scipt (python3) is modified from [Folk et al. (2019)](https://www.pnas.org/content/116/22/10874), which is able to assocciate tmeperature traits data sets with rosid distribution data, remove pixelwise duplicates, and output files with a standard clean format.  For more details see comments inside the script.  
        
        _This Script also used for association Climatic Tropics data ( [Owens et al. (2017)](https://onlinelibrary.wiley.com/doi/full/10.1111/geb.12672) ) with rosid distribution data._  
        
    - _**Extra_point_associate_bio1_cluster_job.sbatch**_  
        UF HiPerGator Slurm job script, contains the example usage of the python script above 
        
    - _**Species_occurrence_clean_sdv_rm-integer.R**_  
      For each individual species, we used this R script to calculate the geographic centroid and the Euclidean distance from each species occurrence to this centroid, then removing any geographic outliers beyond three standard deviations distant, as well as suspect integer latitude and longitude.  
    
+ **Assembly of Temperature Data Layers**  
    - _**Mean_annual_Climatic_Geographic_Temperature_layers_assembling.R**_  
        This script assembled mean of annual temperature (bio.1) for each of sampled rosid species into one csv table, and scored the binary geographic and climatic tropicality datasets, and outputing `csv` file, respectively  
        
        _See first three datasets from **Temperature Data Layers** above_
        
+ **Diversification Analyses**  
    - **DR**  
        + _**DR_statistic.R**_  
          This script conducts DR statistic for the rosid whole tree and each ordinal tree. The method was described by [Jetz et al. (2012)](https://www.nature.com/articles/nature11631), and the script was derived from [Harvey et al. (2016)](https://www.pnas.org/content/114/24/6328)
    
    - **RPANDA**  
        + _**RPANDA.R**_  
          This script fit **9** time- and **9** temperature-dependent likelihood diversification birth-death [models](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12526) to rosid 17 subclades, outputing a summary table of parameters and values estimaed from each model for each rosid subclade.  
          
        + _**RPANDA_summary_AkaikeWeight.R**_  
          This scipt reads in the summary table generated above, the selected the model with the smallest Akaike Information Criterion (AIC; [Akaike, 1974](https://ieeexplore.ieee.org/document/1100705)) value and largest [Akaike weights](https://www.ncbi.nlm.nih.gov/pubmed/15117008) as the best diversification model for eahc rosid subclade, then output into a table (see **Table S6**).
    
    - **BAMM**  
        - _**Run_priors.sh**_  
          This bash script is used for “setBAMMpriors” for BAMM analyses; combing information from `rosid_17_order_sampling_fraction.csv` and `write_prior.R`  
          
        - _**write_prior.R**_  
          This dummy script is used by `Run_priors.sh` and will output parameters for each order to feed `BAMM_diversification.config`  
          
        - _**BAMM_diversification.config**_  
            BAMM control file for diversification analyses, contains replacible paramters, which would be modified by `Run_config.sh` script below for each specific order.
            
            If not converged, this file will be modified again, then loading event data from previous run; more details see [BAMM website](http://bamm-project.org/quickstart.html)  
            
        - _**Run_config.sh**_  
         This bash script will replace those ambiguous letters (e.g., XXX) to specific values (`rosid_17_order_sampling_fraction.csv`) corresponding to each rosid order, as well as parameters produced by `Run_priors.sh` script. After this step, the BAMM configure file is ready to run   
         
        - _**BAMM_postrun_analyses_Order_Batch.R**_   
          This script evaluate mcmc convergence of BAMM runs for each order (`Order`), and also summarize `tip rate`, `mean lambda`, and `rate-through-time matrix` ect for downstream analyses.  Also save event data as `.rds` file for readin efficiency.  

+ **Rates and Traits Correlation Test**  
    - _**essim.R**_  
      This script is inside function sourced by `ES_SIM_Test.R`; more details and usage see author's github [page](https://github.com/mgharvey/ES-sim).  
      
    - _**traitDependent_functions.R**_  
        This script is inside function sourced by  `Fisse_test.R`; more details, examples and usage see [here](https://github.com/macroevolution/fisse).  
        
    - _**ES_SIM_Test.R**_  
      Testing trait-dependent (i.e., continuous mean annual temperature dataset) diversification using tip rate correlation for rosid subclades and whole tree (see **Table S3**) 
      
    - _**Fisse_test.R**_  
      Testing state-dependent (i.e., two binary tropicality datasets) diversification using FiSSE for rosid subclades and whole tree (see **Table S3**)    
      
    - _**Tm_traits_STRAPP.R**_  
      Testing correlation between tip rates and all three temperature data layers using STRAPP in BAMMtools for 17 rosid ordinal subtrees (see **Table S4**)  
      
    - _**Pagle_lambda_test.R**_  
      This scipt is used for testing the presence of phylogenetic niche conservatism in the three contemporary temperature niche datasets via the lambda transform and likelihood ratio test (see **Table S2**).  
      
    - _**P_value_adjust_familywise.R**_  
      This script is used for _p-value_ family-wise adjust among 17 rosid subclades for each trait and each test analyses (see **Tables S3, S4**)  
      
    
+ **Sensitivity Test**  
    - _**sensitivity_test1_rosid_distribution_region_bias.R**_  
      This script conducts spatial analysis of the distribution pattern for sampled rosid species richness mapped golbally (see **Figure S2**).  
      
    - _**sensitivity_test2_drop_temp_species_Tm_traits_STRAPP.R**_  
      Given evidence for over-representation in some non-tropical areas (results from script above), we implemented a sensitivity analysis by randomly dropping 10%, 30%, or 50% of non-tropical species, then reran STRAPP analyses above and assessed the impact on estimated tip rates and downstream phylogenetic correlation (see **Table S5**).
      
+ **Regression Model Test**  
    - _**./misc/Fig_S1.DiverRate_TM_linear_and_exponential_regression_models_plot.R**_  
    This script is plotting the assessment in the relationship of diversification rate from BAMM and global paleo-temperature, we fit linear and exponential regression models, using AIC for model choice and reporting correlation for the best-fit model for each rosid order (see **Figure S1**). 
    
+ **misc**  
    - _**summary_datalayers_tropical_nontropical_percentage.R**_  
    This script summary species richness and distribution data, and all the temperature layes for each of 17 rosid roders (see **Table S1**).  
  
    - _**rosid_17order_tmep_trop_precentage_calc.R**_  
      This script calculate tropical and non-tropical species percentage among each of 17 rosid order (see piechart in **Fig_2**)  
    - _**Fig_1.R and Fig_2.R**_  
      These scripts used to generate two figures (see **Fig_1** and **Fig_2**) respectively.  
      
    
## Requirements
+ **R V.3.5.3**  
+ **Python3**  
+ **Bash** 
+ **[gdal](https://gdal.org/)**  
  _The link with installation and mannual_
+ **[Newick Utilities](http://cegg.unige.ch/newick_utils)**  
  _The link with installation and mannual_  
  
  _The data analyses in this study was conducted in MAC OS laptop and Linux cluster system in [HiPerGator](https://www.rc.ufl.edu/)._  
  
  
  
_**If you found these codes are useful, please cite our work/or this repo.**_