
# Change this if you would like to run this script:
setwd('~/git/GettingAndCleaningDataAssignment/')

## Read the datasets

# data.table contains the method fread, similar to read.table
library('data.table')

# directory containing the dataset
datasetPath <- file.path(getwd(), "UCI HAR Dataset")

# read the datasets called 'subject'
subjectTrain <- fread(file.path(datasetPath, "train", "subject_train.txt"))
subjectTest  <- fread(file.path(datasetPath, "test" , "subject_test.txt" ))

# read the datasets called 'label'
labelTrain <- fread(file.path(datasetPath, "train", "Y_train.txt"))
labelTest  <- fread(file.path(datasetPath, "test" , "Y_test.txt" ))

# read the data files
xTrain <- data.table(read.table(file.path(datasetPath, "train", "X_train.txt")))
xTest  <- data.table(read.table(file.path(datasetPath, "test" , "X_test.txt" )))

## Merge the datasets

# now merge training and test sets using rbind for concatenation
subjectMerged = rbind(subjectTrain, subjectTest)
labelMerged = rbind(labelTrain, labelTest)
xMerged = rbind(xTrain, xTest)

# make sure the merged sets have decent keys before merging them into 1 table
setnames(subjectMerged, "V1", "subject")
setnames(labelMerged, "V1", "activityNumber")

# merge column wise into 1 table
mergedData = cbind(cbind(subjectMerged, labelMerged), xMerged)

# add the key, not sure if this is really needed
setkey(mergedData, subject, activityNumber)

## Keep only the mean and standard deviation

# features.txt contains the names of the columns. We need only the ones that contain mean() or std()

# load the file
featuresLabels <- fread(file.path(datasetPath, "features.txt"))
setnames(featuresLabels, c("V1", "V2"), c("featureNumber", "featureLabel"))

# use grepl to create a logical vector of all the rows that have mean or std label
# It's not enough to match 'mean' because that also matches lines that do not end on 'mean()'
selectedFeaturesLabels <- featuresLabels[grepl("mean\\(\\)|std\\(\\)", featureLabel)]

# the column names resemble 'V<number>' => create a new column with correct column names
selectedFeaturesLabels$columnName <- selectedFeaturesLabels[, paste0("V", featureNumber)]

# now only select the columns with the 
meanAndStdData = mergedData[, c("subject","activityNumber", selectedFeaturesLabels$columnName), with=FALSE]

## Load descriptive activity names and use them as labels

# descriptions are stored in activity_labels.txt
activityLabels <- fread(file.path(datasetPath, "activity_labels.txt"))

# as before: set decent column names
setnames(activityLabels, names(activityLabels), c("activityNumber", "activityLabel"))

meanAndStdDataWithLabels <- merge(meanAndStdData, activityLabels, by="activityNumber", all.x=TRUE)

# Creates a second, independent tidy data set with the average of each variable for each activity and each subject.


