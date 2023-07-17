# Turning PPTs in a folder to PDFs
#this requires LibreOffice on your computer

#### load libraries #### 
# (installing if necessary)
list.of.packages <- list("dplyr","purrr","docxtractr","stringr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

# You have to show the way to the LibreOffice 
set_libreoffice_path("C:/Program Files/LibreOffice/program/soffice.exe")

# Where are the PPTs on your computer ####
# They should all be in the same folder.
# If they are not, move/or copy them into a single folder.
#  You can have sub-folders and other non-PPT files in this folder
loc_of_PPTs<-"D:/Kafue 2023/ID Kits/ZCP ID Kits 11Jul23/Lion"

# Point this script to that location, by setting the working directory
setwd(loc_of_PPTs)

### list the files that are in the folder ####
files_inFolder<-list.files(recursive=FALSE,full.names = TRUE)
files_inFolder

# exclude temporary ~$ files 
toExclude<-c(which(grepl("./~$", files_inFolder, fixed = TRUE)))
ppts_toConvert<-files_inFolder[-toExclude]

#and only include the pptx's because that's all docxtractr::convert_to_pdf can use
toInclude<-which(grepl(".pptx", ppts_toConvert, fixed = TRUE))
ppts_toConvert<-ppts_toConvert[toInclude]
ppts_toConvert

### this runs through each PPT and creates a PDF version 
##### uses the same name (but pdf) and puts it in the same folder
new.names<-str_replace(ppts_toConvert[1:2],".pptx",".pdf")

#this is what you'll be getting 
new.names

#so do it
sapply(ppts_toConvert,convert_to_pdf,new.names)
