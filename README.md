# rosid_NCOMMS-19-37964-T
_Scripts and documentation are provided here with an assumption that users have basic knowledge of UNIX shell, R and Python, including changing the working directory, and pointing to the input and output path to link data and properly execute the scripts. In order to fully reproduce the results in our study, high performance computing clusters ([HiPerGator](https://www.rc.ufl.edu/) at University of Florida) must be used._  

_To outline the logic of the data analyses conducted in the present study, we lay out below each of our scripts based on the order of the workflow as described in the main text. All the scripts and their relative folders are descriptively named based on their primary functionalities in the analyses, and detailed under each highlighted bullet point._


## Datasets


  + **Rosid Ultrametric Trees**  
  As described in the main text, all analyses were run in parallel across 17 subclades corresponding to all rosid orders recognized in [APG IV (2016)](https://onlinelibrary.wiley.com/doi/10.1111/boj.12385); for DR related analyses, we also used the total tree, since it was computationally feasible to use semi-parametric methods at this data scale (see details in the main text).  

+ **Species Distribution Data**  
  We queried iDigBio and GBIF for all rosid species sampled in our tree using R packages rgbif v1.3.0 and ridigbio v0.3.5 on June 4th, 2019. No further taxonomic name resolution was performed for these rosid names, since all rosid species names in our tree were validated and reconciled by The Plant List and OpenTree databases in [Sun et al. (2019)](https://www.biorxiv.org/content/10.1101/694950v2.full).
  Usage:
    See "readme.txt" inside the folder.


+ **Temperature Data Layers**  
  We used four datasets to assess the relationship of temperature and rosid diversification.
    - Rosid_Annual_Tm_mean.csv  
    
      _A continuous trait representing mean annual temperature, directly downloaded from the WorldClim website, then associated with species distribution data using the python script described below._  
      
    - Rosid_Climatic_Tropics_binary.csv  
      _A binary trait representing tropicality under the Köppen climate classification, as calculated by [Owens et al. (2017)](https://onlinelibrary.wiley.com/doi/full/10.1111/geb.12672) and associated with species distribution data using the python script described below._  
      
    - Rosid_Geographic_Tropics_binary.csv  
      _A binary trait representing tropicality under a geographic definition, as described in the main text and calculated directly from species distribution data._
      
    - Global_paleo-temperature.csv  
      _Historical oxygen isotope (δ18O) data derived from [Cramer et al. (2009)](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2008PA001683)._  
      
+ **Rate_Through_Time_Matrix**  
  Two types of diversification rate throught time matrix generated from BAMM kept here. One is regular "RateThroughTimeMatrix" from each of 17 orders, and the other is subsetted by tropical and non-tropical Köppen climate tropicality. These data are used to generate Fig. 3.  
  
## Scripts  

_**Note:** Please modify and confirm the input and output path before executing these scripts. All the file names here descriptively denote the specific purpose and follow the order of the main text (which see); further explanatory notes are selectively given below._  

+ **Subset 17 Rosid Subclades**  
  	- _**extract_Order_tree.sh**_  
  		Usage: bash extract_Order_tree.sh rosids_5g_whole_tree.tre  
  		_Note: Keep the "Order_MRCA.txt" file in the same directory as the bash script_  
  		 
+ **Assembly of Species Distribution Data**  
    - _**Download_rosid_distribution_from_gbif_idigbio_ed.R**_  
        This R script queries iDigBio and GBIF databases with name-validated rosid species sampled in the phylogeny and excluding any coordinates with zero latitude and longitude.  
    
    - _**rosid_samples_associate_with_distribution_and_traits_cleaning.py**_  
        This python script (python3) is a high-throughput workflow modified from [Folk et al. (2019)](https://www.pnas.org/content/116/22/10874) to assocciate data from a raster layer with distribution data, remove pixelwise duplicates, and output files with a standard cleaned format. For more details see comments inside the script.  
        
        _This script was used for the mean annual temperature and Köppen climate datasets described above._  
        
    - _**Extra_point_associate_bio1_cluster_job.sbatch**_  
        UF HiPerGator Slurm job script, containing example usage of the python script above in a high-performance computing environment.
        
    - _**Species_occurrence_clean_sdv_rm-integer.R**_  
      For each individual species, we used this R script to calculate the geographic centroid, and then the Euclidean distance from each species occurrence to this centroid, finally removing any geographic outliers beyond three standard deviations distance. Finally, we removed any occurrence records with suspect integer latitudes and longitudes (this type of reporting would suggest either a low-accuracy georeference or a deliberately obscured locality).  
    
+ **Assembly of Temperature Data Layers**  
    - _**Mean_annual_Climatic_Geographic_Temperature_layers_assembling.R**_  
        This script assembles means of mean annual temperature (bio.1) for each of sampled rosid species into one csv table, and scores the binary geographic and climatic tropicality datasets (criteria in main text), and outputs a `csv` file, respectively,
        
        _See the first three datasets from **Temperature Data Layers** above for which this script was used._
        
+ **Diversification Analyses**  
    - **DR**  
        + _**DR_statistic.R**_  
          This script computes the DR statistic for the entire rosid tree and each ordinal tree (note that a tip rate for the same species calculated with these two trees will differ somewhat in scaling by including a tree root-to-tip path of greater or lesser length). The method was described by [Jetz et al. (2012)](https://www.nature.com/articles/nature11631), and the script was derived from [Harvey et al. (2016)](https://www.pnas.org/content/114/24/6328).
    
    - **RPANDA**  
        + _**RPANDA.R**_  
          This script fits **9** time- and **9** temperature-dependent likelihood diversification birth-death [RPANDA models](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12526) to rosid 17 subclades, and outputs a summary table of parameters and values estimated from each model for each rosid subclade.  
          
        + _**RPANDA_summary_AkaikeWeight.R**_  
          This scipt reads in the summary table generated above, and then selects the model with the smallest Akaike Information Criterion (AIC; [Akaike, 1974](https://ieeexplore.ieee.org/document/1100705)) value and largest [Akaike weight](https://www.ncbi.nlm.nih.gov/pubmed/15117008) as the best diversification model for eahc rosid subclade, then outputs these values into a table (see **Supplementary Table 6**).
    
    - **BAMM**  
        - _**Run_priors.sh**_  
          This bash script is used for “setBAMMpriors” in BAMM analyses; combining information from `rosid_17_order_sampling_fraction.csv` and `write_prior.R`  
          
        - _**write_prior.R**_  
          This dummy script is used by `Run_priors.sh` and will output parameters for each order to feed `BAMM_diversification.config`  
          
        - _**BAMM_diversification.config**_  
            BAMM control file for diversification analyses, containing a replaceable parameter template, which would be modified by `Run_config.sh` script below for each specific order.
            
            If not converged, this file should be modified again to load event data from previous run with additional generations; for more details see [BAMM website](http://bamm-project.org/quickstart.html). 
            
        - _**Run_config.sh**_  
         This bash script will replace parameter templates (above; denoted XXX) with specific values (`rosid_17_order_sampling_fraction.csv`) corresponding to each rosid order, as well as parameters produced by `Run_priors.sh` script. After this step, the BAMM configure file is ready to run   
         
        - _**BAMM_postrun_analyses_Order_Batch.R**_   
          This script evaluate MCMC convergence of BAMM runs for each order (`Order`), and also extracts summaries of `tip rates`, `mean lambda`, `rate-through-time matrices`, etc. for downstream analyses. It also saves event data as an `.rds` file for read-in efficiency.  

+ **Rates and Traits Correlation Test**  
    - _**essim.R**_  
      This script is a function sourced by `ES_SIM_Test.R`; for more details and usage see this script's author's GitHub [page](https://github.com/mgharvey/ES-sim); this script is redistributed here for convenience but users are advised to check the source repository for the most up-to-date version.
      
    - _**traitDependent_functions.R**_  
        This script is a function sourced by `Fisse_test.R`; for more details, examples and usage, see [here](https://github.com/macroevolution/fisse); this script is redistributed here for convenience but users are advised to check the source repository for the most up-to-date version. 
        
    - _**ES_SIM_Test.R**_  
      Run script for testing trait-dependent diversification using tip rate correlations with the continuous mean annual temperature dataset  for rosid subclades and the whole tree (see **Table 1**) 
      
    - _**Fisse_test.R**_  
      Run script for testing state-dependent diversification with the two binary tropicality datasets using FiSSE for rosid subclades and the whole tree (see **Table 2**)    
      
    - _**Tm_traits_STRAPP.R**_  
      Run script for testing the correlation between tip rates and all three temperature data layers using STRAPP in BAMMtools for the 17 rosid ordinal subtrees (see **Supplementary Table 3**)  
      
    - _**Pagle_lambda_test.R**_  
      This script is used for testing the presence of phylogenetic niche conservatism in the three contemporary temperature niche datasets via the lambda transform and likelihood ratio test (see **Supplementary Table 2**).  
      
    - _**P_value_adjust_familywise.R**_  
      This script is used for computing family-wise adjusted _p-values_ for each trait and each statistical test type among the 17 rosid subclades  (see **Tables 1, 2 and Supplementary Table 3**)  
      
    - _**HiSSE_Runs.R**_  
      This script is used to run compared the fit of four different models: (one BiSSE-like model, one BiSSE-like null model, one HiSSE full model, and one HiSSE 2-state null model). All models and parameters are described in Table S4 (also see Supplementary Information Method 3).  
      The purpose of this analysis is to test for associations between tropicality and diversification rate, and to test for potential unobserved diversification drivers.  
      
    
+ **Sensitivity Test**  
    - _**sensitivity_test1_rosid_distribution_region_bias.R**_  
      This script computes and maps per-site species richness for sampled rosid species (see **Supplementary Fig.1**). The same as "_Fig.S1.R_" in **misc** folder.
      
    - _**sensitivity_test2_drop_temp_species_Tm_traits_STRAPP.R**_  
      Given evidence for over-representation in some non-tropical areas (results from the previous script; see main text), we implemented a sensitivity analysis by randomly dropping 10%, 30%, or 50% of non-tropical species, then rerunning STRAPP analyses and assessing the impact on estimated tip rates and downstream phylogenetic correlation (see **Supplementary Table 5**).  
      
    - _**sensitivity_test3_rosid_distribution_tiprates_bias.R**_     
      The purpose of this analyses is plotting all the rates in a gridded world map, showing a global/spatial pattern of diversifications rate, echoing another line of evidence for observed pattern (see Fig. 2a,b). It services as a sensitivity test, because it visually and directly indicates the data is biased or not.     
      
    - _**sensitivity_test4_rosid_distribution_tip-age.R**_    
    We defined the age of the closest node for any given tip as species tip age; then plot median species age into the grid cell median, displaying a spatial pattern of ages of rosid tropical and non-tropical community (see Fig. 2c). It services as another sensitivity test, because it visually and directly indicates the data is biased or not.   
      
+ **Regression Model Test**  
    - _**./misc/Fig.S2.R**_  
    This script plots the relationship of diversification rates from BAMM with global paleo-temperatures, fits linear and exponential regression models, and uses model choice via AIC to report correlation for the best-fit model for each rosid order (see **Supplementary Fig.2**). 
    
+ **misc**  
    - _**Fig.1.R, Fig.2.abc.R and Fig.2d.R, Fig.3.R, Fig.S1.R, Fig.S2.R and Fig.S3.R**_  
    As you see from the script name, these scripts are corresponding to the figures used in our study. Please see details in the study. But additional explaination as below:          
    
        1. Fig.1.R was plot the circle tree first then edit with Inkscape and adding botnaical figure.  
        2. Fig.2.abc.R and Fig.2d.R, these two script comprise of the four panels of Figure 2.  
        3. Fig.S3.R is used to generate ridge plots of the age distribution of diversification rate shift for each rosid order and boxplot shows a summary of overall ages of each diversification shift detected across all 17 orders(see **Supplementary Fig.3**).  
      
    - _**summary_datalayers_tropical_nontropical_percentage.R**_  
    This script summary species richness and distribution data, and all the temperature layers for each of 17 rosid roders (see **Supplementary Table 1**).  
  
    - _**rosid_17order_tmep_trop_precentage_calc.R**_  
      This script calculates tropical and non-tropical species percentages for each of 17 rosid order (see piechart in **Fig.3**)  
      
    - _**plotRateThroughTime_function_modified.R**_  
    This script is modified from BAMMtools for our own plotting purpuse. It will be "sourced" from _Fig.3.R_ script.  
      
    - _**rosid_species_count_0-10_zone_vs_30-40_lat_zone.R and species_occ_tropical_nontropical_check.R**_  
      Two scripts are to used respond reviewers' questions about 1) species richness in tropical zone and temperate zone, respectively; 2) how many species has their occurance data both ranging in tropical and non-tropical zones.  
      
    
## Requirements
+ **R V.3.5.3**  
+ **Python3**  
+ **Bash** 
+ **[gdal](https://gdal.org/)**  
  _The link with installation and mannual_
+ **[Newick Utilities](http://cegg.unige.ch/newick_utils)**  
  _The link with installation and mannual_  
  
  _The data analyses in this study were conducted either on a MacBook Pro laptop (OS-X) or on a Linux cluster system ([HiPerGator](https://www.rc.ufl.edu/))._  
  
  
  
_**If you found this repository useful, please cite our work and/or this repo: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3843441.svg)](https://doi.org/10.5281/zenodo.3843441)**_  
Citation:
Sun et al. (2020, May 25). Cactusolo/rosid_NCOMMS-19-37964-T: Code and data for rosid_NCOMMS-19-37964 (Version V.1.0). Zenodo. http://doi.org/10.5281/zenodo.3843441  

