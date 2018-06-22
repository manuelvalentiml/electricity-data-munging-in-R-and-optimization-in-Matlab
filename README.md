# data-munging-electricity-data-in-R
Coordinating cross-border electricity interconnection investments and trade in market coupled regions

This project contains several files with the following folder structure:

  Data/RawData/
  Empty folder where raw data should be placed.
  
  Data/MungedData/
  Empty folder where processed data is stored.
  
  Statistics/
  Files to process data and estimate regression parameters.  
  
  Optimization/
  Files to run optimization model.
  
Step 1: Obtaining the data files
Considering the size of the data files (over 600 MB when extracted), they must be downloaded to run the Statistics module. We provide stable links to the relevant compressed data files. The following files should be downloaded and extracted to the ‘Data/RawData/’ folder:
http://www.omie.es/datosPub/curva_pbc_uof/curva_pbc_uof_201301.zip http://www.omie.es/datosPub/curva_pbc_uof/curva_pbc_uof_201302.zip http://www.omie.es/datosPub/curva_pbc_uof/curva_pbc_uof_201303.zip http://www.omie.es/datosPub/curva_pbc_uof/curva_pbc_uof_201304.zip http://www.omie.es/datosPub/curva_pbc_uof/curva_pbc_uof_201305.zip http://www.omie.es/datosPub/curva_pbc_uof/curva_pbc_uof_201306.zip http://www.omie.es/datosPub/curva_pbc_uof/curva_pbc_uof_201307.zip http://www.omie.es/datosPub/curva_pbc_uof/curva_pbc_uof_201308.zip http://www.omie.es/datosPub/curva_pbc_uof/curva_pbc_uof_201309.zip http://www.omie.es/datosPub/curva_pbc_uof/curva_pbc_uof_201309.zip http://www.omie.es/datosPub/curva_pbc_uof/curva_pbc_uof_201310.zip http://www.omie.es/datosPub/curva_pbc_uof/curva_pbc_uof_201311.zip http://www.omie.es/datosPub/curva_pbc_uof/curva_pbc_uof_201312.zip

Step 2: Running the Statistics module
The module ‘Statistics/regressions.R’ must be run under RStudio, Version 0.99.484 for Mac OS X or similar. It collects the raw data files and processes them into new files, stored in ‘Data/MungedData/’. These files are then used in the regression, whose parameters are stored as ‘Optimization/parameters.csv’.

Step 3: Running the Optimization module
After obtaining ‘Optimization/parameters.csv’, the optimization module ‘Optimization/ITEPMCR.m’ must be used to solve the quadratic programming model (Equations (50)-(53)) and compute the remaining variables (Equations (41), (42), (48) and (49)). We used MATLAB R2014B 64-Bit for Mac OS X together with CVX: Software for Disciplined Convex Programming, Version 2.1 for Mac OS X. Among its outputs are the 7 figures included in the paper.
