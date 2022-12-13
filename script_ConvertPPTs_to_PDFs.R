# Turning PPTs in a folder to PDFs
#this requires LibreOffice on your computer

#### load libraries #### 
# (installing if necessary)
list.of.packages <- list("dplyr","purrr","docxtractr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
do.call("require", list(list.of.packages)) 

# You have to show the way to the LibreOffice 
set_libreoffice_path("C:/Program Files/LibreOffice/program/soffice.exe")

# Where are the PPTs on your computer ####
# They should all be in the same folder.
# If they are not, move/or copy them into a single folder.
#  You can have sub-folders and other non-PPT files in this folder
loc_of_PPTs<-"C:/Users/cathe/Documents/ZCP/Manuals, Protocols, Etc/Identifications/ID Kits/ZCP ID Kits 21Jun22/Wild Dog/ID KITS"

# Point this script to that location, by setting the working directory
setwd(loc_of_PPTs)

### list the ppts that are in the folder ####
ppts_toConvert<-list.files(recursive=FALSE,full.names = TRUE)

# may need to exclude temporary ~$ files too
toExclude<-c(which(grepl(".ppt", ppts_toConvert, fixed = TRUE)==FALSE),
             which(grepl("./~$", ppts_toConvert, fixed = TRUE)))

ppts_toConvert<-ppts_toConvert[-toExclude]

### this runs through each PPT and creates a PDF version 
##### uses the same name and puts it in the same folder
new.names<-str_replace(ppts_toConvert[1:2],".pptx",".pdf")
sapply(ppts_toConvert[1:2],convert_to_pdf,new.names)
