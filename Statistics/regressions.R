#Call libraries
library(plyr)
library(lubridate)

##############################################################
# Additional functions
##############################################################

factor.as.numeric <- function(x) {
	x <- gsub("\\.","", x)
	return(as.numeric(gsub(",",".", x)))
}

supply.equilibrium <- function (supply, demand) {
  for (S in 1:nrow(supply)) {
    for (D in 1:nrow(demand)) {
      if (supply[S,"Power"] > demand[D,"Power"] & supply[S,"Price"] > demand[D,"Price"]) {
        return(S - 1)
      }
    }
  } 
  return(0)
}

demand.equilibrium <- function (supply, demand) {
  for (S in 1:nrow(supply)) {
    for (D in 1:nrow(demand)) {
      if (supply[S,"Power"] > demand[D,"Power"] & supply[S,"Price"] > demand[D,"Price"]) {
        return(D - 1)
      }
    }
  }
  return(0)
}

supply.demand.regress <- function(M, W, off.peak) {
  
  results <- c("ES-PT", M, W, off.peak)
  
  for (C in c("ES", "PT")){
    supply <- read.csv(paste(paste(C, "S", M, W, off.peak, sep="-"),".csv", sep=""), sep=";", dec=",", stringsAsFactors=FALSE)
    demand <- read.csv(paste(paste(C, "D", M, W, off.peak, sep="-"),".csv", sep=""), sep=";", dec=",", stringsAsFactors=FALSE)
    colnames(supply) <- c("Power", "Price", "Power0", "Price0", "Code")
    colnames(demand) <- c("Power", "Price", "Power0", "Price0", "Code")
    
    supply$Power <- as.numeric(supply$Power)
    supply$Price <- as.numeric(supply$Price)
    supply$Power0 <- as.numeric(supply$Power0)
    supply$Price0 <- as.numeric(supply$Price0)
    demand$Power <- as.numeric(demand$Power)
    demand$Price <- as.numeric(demand$Price)
    demand$Power0 <- as.numeric(demand$Power0)
    demand$Price0 <- as.numeric(demand$Price0)
    
    temp <- NULL
    temp$Power0 <- c(supply$Power0, demand$Power0)
    temp$Price0 <- c(supply$Price0, demand$Price0)
    temp <- as.data.frame(temp)
    temp <- unique(temp)
    Point <- colMeans(temp)
    
    regsupply <- lm (I(Price - Point[2]) ~ I(Power - Point[1]) + 0, data= supply)
    regdemand <- lm (I(Price - Point[2]) ~ I(Power - Point[1]) + 0, data= demand)
    
    delta <- as.numeric(regsupply[1])
    beta <- -(as.numeric(regdemand[1]))
    alpha <- Point[1] * beta + Point[2]
    gamma <- Point[1] * delta - Point[2]
    
    results <- c(results, alpha, beta, gamma, delta)
  }
}

number.hours <- function(Y, M, W, off.peak) {
  H <- 0
  D <- 1
  if (M != 12){
    Dmax <- as.integer(as.Date(paste(Y, M+1, D, sep="-"))-as.Date(paste(Y, M, D, sep="-")))
  } else {
    Dmax <- as.integer(as.Date(paste(Y+1, 1, D, sep="-"))-as.Date(paste(Y, M, D, sep="-")))
  }
  
  
  for( D in (1:Dmax)){
    if((weekdays(as.Date(paste(Y, M, D, sep="-")), abbreviate = TRUE)) == W)
      H <- H +  1
  }
  
  if (off.peak == "Peak"){
    H <- H * 9
  }
  if (off.peak == "OffP"){
    H <- H * 15
  }
  
  return(H)
}

##############################################################
# Main Code
##############################################################

##############################################################
## Step 1: Create files for regression
##############################################################
#Open files and join all bid files into a single dataframe

codelist <- read.csv("codelist.csv", sep=";")

#Remove unnecessary information from list of codes and change names of remaining columns

codelist$DESCRIPCION <- NULL
codelist$AGENTE.PROPIETARIO <- NULL
codelist$PORCENTAJE.PROPIEDAD <- NULL
codelist$TIPO.UNIDAD <- NULL
codelist$ESTADO <- NULL

names(codelist)[1] <- paste("Unit")
names(codelist)[2] <- paste("Region")

#Load all raw data file names obtained in www.omie.es and saved in *ROOT*/Data/RawData
#Note that the file extension of these files is ".1"

current.path <- strsplit(getwd(), split="/")[[1]]
home.path <- paste(current.path[1:length(current.path)-1], collapse="/")
rawdata.path <- paste(home.path, "Data/RawData", sep="/")

files <- list.files(path = rawdata.path, pattern = ".1", recursive = TRUE)

# Open each bid file

for (i in 1:length(files)) {

  #Load bids data
  
	bids <- read.table(paste(paste(home.path, "Data/RawData", files[i], sep="/")), sep = ";", header = TRUE, skip = 2)

	#Rename columns of bids dataframe, obtain day, month, year, and weekday, and remove unnecessary data
	
	names(bids)[1] <- paste("Hour")
	names(bids)[2] <- paste("Day")
	names(bids)[3] <- paste("Country")
	names(bids)[4] <- paste("Unit")
	names(bids)[5] <- paste("Type")
	names(bids)[6] <- paste("Power")
	names(bids)[7] <- paste("Price")
	names(bids)[8] <- paste("Dispatch")

	D <- as.numeric(substr(bids$Day[1], 1, 2))
	M <- as.numeric(substr(bids$Day[1], 4, 5))
	Y <- as.numeric(substr(bids$Day[1], 7, 10))
	W <- weekdays(as.Date(paste(Y, M, D, sep="-")), abbreviate = TRUE)
  
	bids$Day <- NULL
	bids$Country <- NULL
	bids$X <- NULL
	bids$Price <- factor.as.numeric(bids$Price)
	bids$Power <- factor.as.numeric(bids$Power)
	
	# Merge data from unit list to bids in order to identify the region of each bid

	bids <- join(bids, codelist, by = "Unit")

	#Remove bids in case they have no corresponding region (just to make sure nothing is missing and no empty lines are considered)

	bids.na <- subset(bids, is.na(bids$Region))

	#Repeat for every hour of operation (cannot be fixed due to daylight savings)
	
	for (H in unique(bids$Hour[!is.na(bids$Hour)])) {
		
	  #Create dataframes for supply and demand of a particular hour and eliminate 
		demand <- NULL
		supply <- NULL

		demand <- subset(bids, Hour == H & Type == "C" & Dispatch == "O")
		supply <- subset(bids, Hour == H & Type == "V" & Dispatch == "O")

		demand$Hour     <- NULL
		demand$Unit     <- NULL
		demand$Type     <- NULL
		demand$Dispatch <- NULL

		supply$Hour     <- NULL
		supply$Unit     <- NULL
		supply$Type     <- NULL
		supply$Dispatch <- NULL
    
		#Order dataframe to calculate cummulative power
		
		demand <- demand[with(demand , order(-Price, -Power)), ]
		supply <- supply[with(supply, order(Price, -Power)), ]

		#Subset dataframes for the Portuguese and Spanish Regions, and remove Region column
		
		demand.PT <- subset(demand, Region == "ZONA PORTUGUESA")
		supply.PT <- subset(supply, Region == "ZONA PORTUGUESA")
		demand.ES <- subset(demand, Region != "ZONA PORTUGUESA")
		supply.ES <- subset(supply, Region != "ZONA PORTUGUESA")

		demand.PT$Region <- NULL
		supply.PT$Region <- NULL
		demand.ES$Region <- NULL
		supply.ES$Region <- NULL

		#Initialization of cummulative power calculation
		
		powerDemand.PT <- demand.PT$Power[1]
		powerSupply.PT <- supply.PT$Power[1]
		powerDemand.ES <- demand.ES$Power[1]
		powerSupply.ES <- supply.ES$Power[1]

    #Calculate cummulative power for supply and demand of PT and ES and substitute marginal power by cummulative power
		
		for (x in 2:nrow(demand.PT)) {
			powerDemand.PT <- rbind(powerDemand.PT, powerDemand.PT[x-1] + demand.PT$Power[x])
		}

		for (x in 2:nrow(supply.PT)) {
			powerSupply.PT <- rbind(powerSupply.PT, powerSupply.PT[x-1] + supply.PT$Power[x])
		}

		for (x in 2:nrow(demand.ES)) {
			powerDemand.ES <- rbind(powerDemand.ES, powerDemand.ES[x-1] + demand.ES$Power[x])
		}

		for (x in 2:nrow(supply.ES)) {
			powerSupply.ES <- rbind(powerSupply.ES, powerSupply.ES[x-1] + supply.ES$Power[x])
		}

		demand.PT$Power <- powerDemand.PT
		supply.PT$Power <- powerSupply.PT
		demand.ES$Power <- powerDemand.ES
		supply.ES$Power <- powerSupply.ES
		
		#Find equilibrium Price and add findings to dataframe
		
    demand.PT$Power0 <- demand.PT$Power[demand.equilibrium(supply.PT, demand.PT)]
		supply.PT$Power0 <- supply.PT$Power[supply.equilibrium(supply.PT, demand.PT)]
		demand.ES$Power0 <- demand.ES$Power[demand.equilibrium(supply.ES, demand.ES)]
		supply.ES$Power0 <- supply.ES$Power[supply.equilibrium(supply.ES, demand.ES)]
		
		demand.PT$Price0 <- demand.PT$Price[demand.equilibrium(supply.PT, demand.PT)]
		supply.PT$Price0 <- supply.PT$Price[supply.equilibrium(supply.PT, demand.PT)]
		demand.ES$Price0 <- demand.ES$Price[demand.equilibrium(supply.ES, demand.ES)]
		supply.ES$Price0 <- supply.ES$Price[supply.equilibrium(supply.ES, demand.ES)]

		#Check if Hour is Peak or Off Peak
		
		off.peak <- "OffP"
		if (H > 8 & H <= 22) {
			off.peak <- "Peak"
		}
		
		demand.PT$Code <- paste("PT", "D", M, W, off.peak, sep="-")
    supply.PT$Code <- paste("PT", "S", M, W, off.peak, sep="-")
    demand.ES$Code <- paste("ES", "D", M, W, off.peak, sep="-")
    supply.ES$Code <- paste("ES", "S", M, W, off.peak, sep="-")

    #Append data to dataframe
    
		if (nrow(demand.PT) > 0){ write.table(as.data.frame(demand.PT), file = paste(home.path, "Data/MungedData", paste(paste("PT", "D", M, W, off.peak, sep="-"),".csv", sep=""), sep="/"), append = TRUE , col.names = FALSE, row.names = FALSE, sep =";") }
		if (nrow(demand.ES) > 0){ write.table(as.data.frame(demand.ES), file = paste(home.path, "Data/MungedData", paste(paste("ES", "D", M, W, off.peak, sep="-"),".csv", sep=""), sep="/"), append = TRUE , col.names = FALSE, row.names = FALSE, sep =";") }
		if (nrow(supply.PT) > 0){ write.table(as.data.frame(supply.PT), file = paste(home.path, "Data/MungedData", paste(paste("PT", "S", M, W, off.peak, sep="-"),".csv", sep=""), sep="/"), append = TRUE , col.names = FALSE, row.names = FALSE, sep =";") }
		if (nrow(supply.ES) > 0){ write.table(as.data.frame(supply.ES), file = paste(home.path, "Data/MungedData", paste(paste("ES", "S", M, W, off.peak, sep="-"),".csv", sep=""), sep="/"), append = TRUE , col.names = FALSE, row.names = FALSE, sep =";") }

    print(paste(Y,M,D,H, sep="-"))
	}
}

##############################################################
## Step 2: Obtain regression parameters
##############################################################

setwd(paste(home.path, "Data/MungedData", sep="/"))

Y <- 2013
parameters <- NULL
for (M in 1:12) {
  for (W in c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")) {	
    for (off.peak in c("Peak", "OffP")) {
      parameters <- rbind(parameters, c(supply.demand.regress(M, W, off.peak), number.hours(Y, M, W, off.peak)))
      print(paste(M,W,off.peak, sep="-"))
    }}}

setwd(paste(home.path, "Optimization", sep="/"))
write.table(as.data.frame(parameters), file = "parameters.csv", col.names = FALSE, row.names = FALSE, sep =";", quote = FALSE)