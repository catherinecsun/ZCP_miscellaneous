# Turning PPTs in a folder to PDFs
## *NOTE 1* : this requires LibreOffice on your computer
## *NOTE 2* : all powerpoints MUST BE IN PPTX, not ppt


#### load libraries #### 
# (installing if necessary)
list.of.packages <- list("dplyr","purrr","docxtractr","stringr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)>0) install.packages(new.packages)
do.call("require", list.of.packages)

#if the code above in Lines 8-11 dont work, can do this:
# library("dplyr")
# library("purrr")
# library("stringr")
# library("docxtractr")

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
if(length(toExclude)>1){
  ppts_toConvert<-files_inFolder[-toExclude]
}else{
  ppts_toConvert<-files_inFolder
}
ppts_toConvert

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
#sapply(ppts_toConvert,convert_to_pdf,new.names) # sapply is acting funny?
for(p in 1:length(ppts_toConvert)){
  print(ppts_toConvert[p])
  convert_to_pdf(ppts_toConvert[p],new.names[p])  
}

#and put them in a new separate folder called "PDF_versions"
dir.create("PDF_versions") 
file.rename(from=new.names,
            to=paste0("./PDF_versions",substring(new.names,2,nchar(new.names))))
