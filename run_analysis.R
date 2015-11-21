# read the text files in the train folder.
# This should only be launched when the run_analysis.R
# file is in the UCI HAR Daataset folder

Xtrain<-read.table("train/X_train.txt")

# the previous command may take some time to run

# we can check for completness the dimension of the 
# loaded table

dim(Xtrain)

ytrain<-read.table("train/y_train.txt")
subjectrain<-read.table("train/subject_train.txt")

# read the text files in the test folder.
# This should only be launched when the run_analysis.R
# file is in the UCI HAR Daataset folder

Xtest<-read.table("test/X_test.txt")

# the previous command may take some time to run

ytest<-read.table("test/y_test.txt")
subjectest<-read.table("test/subject_test.txt")

# merging the training and test features
# (using rbind is important, as merge may re-order the data)

mergetraintest<-rbind(Xtrain,Xtest)

# loading the names of the different variables

labels<-read.table("features.txt")

#labeling the merge variables (2nd column of labels)
names(mergetraintest)<-labels$V2

# selectionning only the variables mean and std
# We voluntarily exclude the variable names containing
# Mean, as they represent angles between mean variables, not means

mergetraintest<-mergetraintest[,grep("mean|std",labels$V2)]

# we now clean a little the variable names, using only lowercases, 
# and no -,(,) characters

names(mergetraintest)<-gsub("-","",tolower(names(mergetraintest)))
names(mergetraintest)<-gsub("\\()","",names(mergetraintest))

# since t means time and f frequency, we make that explicit

names(mergetraintest)<-gsub("^f","frequency",names(mergetraintest))
names(mergetraintest)<-gsub("^t","time",names(mergetraintest))

# we can now add the subjects and activity to our merge table

subject<-rbind(subjectrain,subjectest)
activity<-rbind(ytrain,ytest)

# convert subject into a categorical variable

subject$V1<-factor(subject$V1)
names(subject)<-"subject"

# load the names of the activity, and convert them
# in lowercase and no _

labelsactivity<-read.table("activity_labels.txt")
labelsactivity$V2<-tolower(gsub("_","",labelsactivity$V2))

# replacing the numbers in activity by their corresponding activity names

activity$V1<-labelsactivity$V2[activity$V1]
names(activity)<-"activity"

# finally merging the features, activities and subjects

tidydata<-cbind(subject,activity,mergetraintest)

# average the different features for each activity and each subject

tidydataavg<-aggregate(tidydata[,3:81],by=list(tidydata$subject,tidydata$activity), mean)

#arrange by individuals, then by activity (alphabetic order)

names(tidydataavg)[1]<-"subject"
names(tidydataavg)[2]<-"activity"
library(dplyr)
tidydataavg<-arrange(tidydataavg,subject,activity)

# saving the tidy data set with the averages!

write.table(tidydataavg,file="tidyaverage.txt", row.name=FALSE)
