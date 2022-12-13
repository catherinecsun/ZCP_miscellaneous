library(lubridate)
library(plyr)
library(dplyr)
library(tidyr)
library(stringr)
library(openxlsx)

#### what time frame do you want? ####
# this assumes you want everything in between
# if you want separate periods, run this script for each of those different periods
timeframe<-c(start="01-Jan-2022",end="31-Dec-2022")

#### download the google tabs/months you want and read them in ####
Kafue_2022_Master_DB_8Dec22_Jan_22 <- read.csv("From Google Drive/Kafue - 2022 - Master DB - 8Dec22 - Jan 22.csv")
Kafue_2022_Master_DB_8Dec22_Feb_22 <- read.csv("From Google Drive/Kafue - 2022 - Master DB - 8Dec22 - Feb 22.csv")
Kafue_2022_Master_DB_8Dec22_Mar_22 <- read.csv("From Google Drive/Kafue - 2022 - Master DB - 8Dec22 - Mar 22.csv")
Kafue_2022_Master_DB_8Dec22_Apr_22 <- read.csv("From Google Drive/Kafue - 2022 - Master DB - 8Dec22 - Apr 22.csv")
Kafue_2022_Master_DB_8Dec22_May_22 <- read.csv("From Google Drive/Kafue - 2022 - Master DB - 8Dec22 - May 22.csv")
Kafue_2022_Master_DB_8Dec22_Jun_22 <- read.csv("From Google Drive/Kafue - 2022 - Master DB - 8Dec22 - Jun 22.csv")

Kafue_2022_Master_DB_8Dec22_Jul_22 <- read.csv("From Google Drive/Kafue - 2022 - Master DB - 8Dec22 - Jul 22.csv")
Kafue_2022_Master_DB_8Dec22_Aug_22 <- read.csv("From Google Drive/Kafue - 2022 - Master DB - 8Dec22 - Aug 22.csv")
Kafue_2022_Master_DB_8Dec22_Sep_22 <- read.csv("From Google Drive/Kafue - 2022 - Master DB - 8Dec22 - Sep 22.csv")
Kafue_2022_Master_DB_8Dec22_Oct_22 <- read.csv("From Google Drive/Kafue - 2022 - Master DB - 8Dec22 - Oct 22.csv")
Kafue_2022_Master_DB_8Dec22_Nov_22 <- read.csv("From Google Drive/Kafue - 2022 - Master DB - 8Dec22 - Nov 22.csv")
Kafue_2022_Master_DB_8Dec22_Dec_22 <- read.csv("From Google Drive/Kafue - 2022 - Master DB - 8Dec22 - Dec 22.csv")

theFiles<-grep("Master_DB",names(.GlobalEnv),value=TRUE)

#### clean the data ####
#name the columns, remove the first 2 rows and sums from bottom from each, 
for(f in 1:length(theFiles)){
  tmp<-get(theFiles[f])
  colnames(tmp)<-trimws(paste(tmp[1,], tmp[2,]))
  colnames(tmp)[1]<-"Entered in DB?"
  tmp<-tmp[-c(1,2),]
  tmp<-tmp[tmp[,1]%in%c("Yes","No","YES","NO")==1,]
  assign(theFiles[f],tmp)
}



#make one big dataframe (can always subset back by month if needed)
masterDB_allMonths<-do.call(rbind.fill, mget(theFiles)) 
masterDB_allMonths$`total # animals`<-as.numeric(masterDB_allMonths$`total # animals`)
masterDB_allMonths$`#snarechecked`<-as.numeric(masterDB_allMonths$`#snarechecked`)

#fix dates
missingHyphens<-which(sapply("-",grepl,masterDB_allMonths$Date)==0)
if(length(missingHyphens)>0){
  masterDB_allMonths$Date[missingHyphens]<-paste0(substring(masterDB_allMonths$Date[missingHyphens],1,nchar(masterDB_allMonths$Date[missingHyphens])-5),"-",substring(masterDB_allMonths$Date[missingHyphens],nchar(masterDB_allMonths$Date[missingHyphens])-4,nchar(masterDB_allMonths$Date[missingHyphens])-2),"-",substring(masterDB_allMonths$Date[missingHyphens],nchar(masterDB_allMonths$Date[missingHyphens])-1,nchar(masterDB_allMonths$Date[missingHyphens])))
}
masterDB_allMonths$Date<-as.Date(masterDB_allMonths$Date,"%d-%b-%y")

# fix species names
masterDB_allMonths$Species<-str_replace_all(masterDB_allMonths$Species, fixed(" "), "")
lions<-which(masterDB_allMonths$Species%in%c("Lion","lion","LION","LI","Li","li"))
leopards<-which(masterDB_allMonths$Species%in%c("Leopard","leopard","LEOPARD","LE","Le","le"))
cheetah<-which(masterDB_allMonths$Species%in%c("Cheetah","cheetah","CHEETAH","CH","Ch","ch"))
hyena<-which(masterDB_allMonths$Species%in%c("Hyena","hyena","HYENA","HY","Hy","hy"))
wildDog<-which(masterDB_allMonths$Species%in%c("Wilddog","WildDog","wilddog","WILDDOG",
                                               "WD","Wd","wd"))
if(length(lions)>0){
  masterDB_allMonths$Species[lions]<-"Lion"
}
if(length(leopards)>0){
  masterDB_allMonths$Species[leopards]<-"Leopard"
}
if(length(cheetah)>0){
  masterDB_allMonths$Species[cheetah]<-"Cheetah"
}
if(length(hyena)>0){
  masterDB_allMonths$Species[hyena]<-"Hyena"
}
if(length(wildDog)>0){
  masterDB_allMonths$Species[wildDog]<-"WildDog"
}

#### subset to the period you want ####
timeframe_asDates<-dmy(timeframe)
timeframe_asDates<-timeframe_asDates[1] %--% timeframe_asDates[2]

masterDB_dateSubset<-masterDB_allMonths[masterDB_allMonths$Date %within% timeframe_asDates ,]

#### the species in this time subset ####
species<-unique(masterDB_dateSubset$Species)
species

#create a separate subset of the dataframe per species
for(s in 1:length(species)){
  print(species[s])
  tmp<-masterDB_dateSubset[masterDB_dateSubset$Species==species[s],]
  
  #unique animals
  tmp_animals<-c()
  for(i in 1:nrow(tmp)){
    tmp_animals<-paste(tmp_animals,tmp$`ID #`[i],",")
  }
  
  theInds<-unlist(strsplit(tmp_animals, "\\,|\\+| "))
  theInds<-theInds[-which(theInds=="")]
  
  tmp_wIDs<-c(which(startsWith(theInds,"K")&nchar(theInds)>4), # has a K in name
              which(nchar(as.numeric(theInds))>2) )# is a 3-4 digit number
  theInds_wIDs<-unique(theInds[tmp_wIDs]) 
  
  #remove sex info
  theInds<-str_replace_all(theInds,"F","")
  theInds<-str_replace_all(theInds,"M","")
  
  #remove species acronyms preceding id number
  tmp_removeDash<-c(which(unlist(lapply(strsplit(theInds,"_"),length))>1), which(unlist(lapply(strsplit(theInds,"-"),length))>1))
  for(r in 1:length(tmp_removeDash)){
    theInds[tmp_removeDash[r]]<-strsplit(theInds[tmp_removeDash[r]],"\\_|\\-| ")[[1]][2]
  }
  theInds_wIDs<-unique(theInds_wIDs)
  
  tmp_woIDs_a<-theInds[-tmp_wIDs]
  tmp_woIDs_a<-as.numeric(tmp_woIDs_a[which(!is.na(as.numeric(tmp_woIDs_a)))])
  
  tmp_woIDs_b<-tmp$`total # animals`[which(!is.na(match(tmp$`ID #`, c("Unknown","unknown","UNK","unk","Unk"))))]
  
  
  #summary dataframe 
  tmp_summary<-data.frame("Stat"=c("Total sightings",
                                   "Total observers",
                                   "Unique groups",
                                   "Total animals",
                                   "Total snare checked",
                                   "Total unique IDed individuals",
                                   "Total un'IDed animals"),
                          "Count"=c(nrow(tmp),
                                    sum(sapply(tmp$Observer,str_count,","),
                                        na.rm=TRUE)+nrow(tmp) ,
                                    length(unique(tmp$Group)) ,
                                    sum(tmp$`total # animals`,na.rm=TRUE) ,
                                    sum(tmp$`#snarechecked`,na.rm=TRUE) ,
                                    length(theInds_wIDs),
                                    sum(c(tmp_woIDs_a,tmp_woIDs_b))))
  
  list_of_datasets <- list("Sightings" = tmp,
                           "Summary" = tmp_summary,
                           "Tally_of_Groups" = table(tmp$Group),
                           "Tally_of_IDed_Inds" = table(theInds[tmp_wIDs]))
  
write.xlsx(list_of_datasets, file=paste0(str_replace_all(species[s]," ", ""),"_",paste(timeframe,collapse='_'),".xlsx"))
}



