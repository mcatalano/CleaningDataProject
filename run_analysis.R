## Load packages
library(dplyr)

## Create directory for data storage
if(!file.exists("./project data")) {dir.create("./project data")}

## Download file and unzip
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./project data/Data.zip", method = 'curl')
unzip(zipfile = "./project data/Data.zip", exdir = "./project data")

## Create object with data file path
path <- file.path("./project data", "UCI HAR Dataset")

## Read data
featureNames <- read.table(file.path(path, 'features.txt'))
activityNames <-read.table(file.path(path, 'activity_labels.txt'))
    
activityTest <- read.table(file.path(path, 'test', 'y_test.txt'))
activityTrain <- read.table(file.path(path, 'train', 'y_train.txt'))

subjectTest <- read.table(file.path(path, 'test', 'subject_test.txt'))
subjectTrain <- read.table(file.path(path, 'train', 'subject_train.txt'))

featuresTest <- read.table(file.path(path, 'test', 'X_test.txt'))
featuresTrain <- read.table(file.path(path, 'train', 'X_train.txt'))

## Combine test and train datasets
activity <- rbind(activityTest, activityTrain)
subject <- rbind(subjectTest, subjectTrain)
features <- rbind(featuresTest, featuresTrain)

## Add names to columns of each data frame
names(activity) <- c('activity')
names(subject) <- c('subject')
names(features) <- featureNames$V2

## Combine into one data table
subData <- cbind(subject, activity)
data <- cbind(subData, features)

## Get column numbers for columns in 'data' that containt 'mean' and 'std';
## combine column numbers into one sorted vector
meanCols <- grep('mean', names(data))
stdCols <- grep('std', names(data))
cols <- sort(c(meanCols, stdCols))

## Subset 'data' by columns 1, 2, and 'cols'
msData <- data[ ,c(1, 2, cols)]

## Create factor of activity names
actNames <- activityNames$V2

## Replace each 'activity' index with its associated name from 'actNames' 
msData2 <- mutate(msData, activity = actNames[activity])

## Change variable names:
## Replace "-" with "_" separator and remove "()"
## Replace abbreviations, e.g., "Acc" with the more descriptive names given in the README.txt file
names(msData2) <- gsub("-", "_", names(msData2), fixed = T)
names(msData2) <- gsub("()", "", names(msData2), fixed = T)
names(msData2) <- gsub("Mag", "Magnitude", names(msData2))
names(msData2) <- gsub("Acc", "Accelerometer", names(msData2))
names(msData2) <- gsub("Gyro", "Gyroscope", names(msData2))
names(msData2) <- gsub("Freq", "Frequency", names(msData2))
names(msData2) <- gsub("BodyBody", "Body", names(msData2))
names(msData2) <- gsub("^t", "time", names(msData2))
names(msData2) <- gsub("^f", "frequency", names(msData2))

## Aggregate data frame -- compute mean of each variable in terms of 'subject' and 'activity'
avgData <- aggregate(. ~ subject + activity, msData2, mean)

## Write tidy dataset to file called 'tidydata.txt'
write.table(avgData, file = "tidydata.txt", row.name = F)
