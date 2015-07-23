#STEP 1
fileurl<- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile = "./Project.zip", mode="wb")
unzip("Project.zip", overwrite = TRUE, exdir=".")

#STEP 2
features <- read.table("./UCI HAR Dataset/features.txt")
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
Y_test <- read.table("./UCI HAR Dataset/test/Y_test.txt")
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
Y_train <- read.table("./UCI HAR Dataset/train/Y_train.txt")
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")

#STEP 3
datatest <- cbind(subject_test, Y_test, X_test)
datatrain <- cbind(subject_train, Y_train, X_train)
rawdata <- rbind(datatest, datatrain)

#STEP 4
colnames(rawdata)[1] <- "Subject"
colnames(rawdata)[2] <- "Activity"

#STEP 5
rawdata$Activity <- as.factor(rawdata$Activity)
levels(rawdata$Activity) <- activity_labels$V2
rawdata$Activity <- factor(rawdata$Activity, levels=(activity_labels$V2), ordered=TRUE)

#STEP 6
headfeatures <- as.character(features$V2)
colnames(rawdata)[-(1:2)] <- headfeatures

#STEP 7
mean_pos <- grepl("mean()", colnames(rawdata), fixed=TRUE)
sd_pos <- grepl("std()", colnames(rawdata), fixed=TRUE)
mean_sd_positions <- sort(c(1,2,which(mean_pos=="TRUE"), which(sd_pos=="TRUE")))
mean_sd_data <- rawdata[, mean_sd_positions]

#STEP 8
dir.create("R Packages")
install.packages("plyr", lib="./R Packages/")
install.packages("dplyr", lib="./R Packages/")
install.packages("lazyeval", lib="./R Packages/")
library("plyr", lib.loc="./R Packages/")
library("dplyr", lib.loc="./R Packages/")
library("lazyeval", lib.loc="./R Packages/")
groupdata <- group_by(mean_sd_data, Subject, Activity)
groupdata[,c(1)] <- as.integer(groupdata[,c(1)])
cleandata <- summarise_each(groupdata, funs(mean))

#STEP 9
write.table(cleandata, file = "final_results.txt", row.name=FALSE, sep=";")
