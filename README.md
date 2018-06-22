# data-munging-electricity-data-in-R
Coordinating cross-border electricity interconnection investments and trade in market coupled regions

We use daily bid data retrieved from OMIE, the daily and intraday Iberian electricity market operator1, for the whole year of 2013, with approximately 15.7 million buy and sell bids. The bids are separated for Portugal and Spain, and to simplify, all bids from France and Morocco are assumed to be Spanish.
For each hourly slot throughout the year, we sort the bids by price and quantity to obtain hourly supply curves and demand curves, as well as equilibrium points. These data are then grouped in a total of 168 distinct operating conditions for different months, weekdays and peak/off-peak periods (the peak occurs between 9 a.m. and 10 p.m.).
For each operating condition, we obtain linear regressions for the supply and the demand from all the points in the supply and demand curves, respectively, constrained to pass through the average of the equi- librium points of all the operating condition’s hourly slots. This allows us to avoid, for instance, negative equilibrium points, which may result from considering independent supply regressions and demand regressions.

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
