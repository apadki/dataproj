## Load libraries assume they are installed
library("data.table")
library("reshape2")
library("plyr2")
## set working directory the direcotry in which the files are downloaded
## it is commented out 
#setwd("proj3")

## Read training data 
traindf = read.table("train/X_train.txt")

## Read Test data
testdf = read.table("test/X_test.txt");

## merge test and train
combined = rbind(testdf, traindf)

## extract feature names
features =  read.table("features.txt",stringsAsFactors=FALSE)[[2]]

#colnames(combined) = featur
# xtract desired feature names i.e. containing mean and std
extNames = features
extNames = extNames[grep("std|mean", extNames)]
## First adding col names to combined and then select the desired columns

colnames(combined) <- features
combined = combined[,grep("mean|std|activityLabel",features)]

## View(combined) View (combined)
activityLabels = read.table("activity_labels.txt",stringsAsFactors=FALSE)
colnames(activityLabels) <- c("activityID","activityLabel")


# Work on activities join all and label
testActivities <- read.table("test/y_test.txt",stringsAsFactors=FALSE)
trainActivities <- read.table("train/y_train.txt",stringsAsFactors=FALSE)
allActivities <- rbind(testActivities,trainActivities)

# add Col name to all activities to give it a name so that we can join it
colnames(allActivities)[1] <- "activityID"
activities <- join(allActivities,activityLabels,by="activityID")
# Now add the column to combined 
combined <- cbind(activity=activities[,"activityLabel"],combined)

# Now get all subjects
testSubjects <- read.table("test/subject_test.txt",stringsAsFactors=FALSE)
trainSubjects <- read.table("train/subject_train.txt",stringsAsFactors=FALSE)
allSubjects<- rbind(testSubjects,trainSubjects)
# Assign col name and bind subject col to combined
colnames(allSubjects) <- "subject"

# Now add the subject column to combined and order by sub and activity
combined <- cbind(allSubjects,combined)

combined <- combined[order(combined$subject,combined$activity),]

#View(combined)

molt <- melt(combined,id.vars= c("subject","activity"))
 
sactivity <- dcast(molt, subject+activity ~ variable, fun.aggregate=mean)
## write to txt

write.table(sactivity, file = "tidydata.txt", row.names=FALSE)
