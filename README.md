---
title: "README"
output: html_document
---

This Readme file goes alongside with the run_analysis.R file, used to tidy the data for the project 
of th Getting and Cleaning data MOOC. One should also consult the codebook to understand the variables
contained in the final text file. 

First I read the text files in the train folder. This can only be done if
the run_analysis.R file is in the UCI HAR Daataset folder


```{r}
Xtrain<-read.table("train/X_train.txt")
```

 the previous command may take some time to run, as it is a large table.
 One can convince himself that this is the case by inspecting the dimension of the  loaded table
 
```{r}
dim(Xtrain)
```

We then load the remaining training files
 
```{r}
ytrain<-read.table("train/y_train.txt")
subjectrain<-read.table("train/subject_train.txt")
```


Then I read the text files in the test folder. This can only be done if
the run_analysis.R file is in the UCI HAR Daataset folder

```{r}
Xtest<-read.table("test/X_test.txt")
```

Again this may take some time to run. Loading the rest

```{r}
ytest<-read.table("test/y_test.txt")
subjectest<-read.table("test/subject_test.txt")
```

I then merge the training and test features. Using rbind is important, as merge may re-order the data

```{r}
mergetraintest<-rbind(Xtrain,Xtest)
```

I load the names of the different features

```{r}
labels<-read.table("features.txt")
```

and I label the merge features (2nd column of labels needed)

```{r}
names(mergetraintest)<-labels$V2
```

I then selection only the variables mean and std. 
I voluntarily exclude the variable names containing Mean,
(with an uppercase) as they represent angles between mean variables, not real means.
Thus:

```{r}
mergetraintest<-mergetraintest[,grep("mean|std",labels$V2)]
```


I now clean a little the variable names, using only lowercases,  and no -,(,) characters

```{r}
names(mergetraintest)<-gsub("-","",tolower(names(mergetraintest)))
names(mergetraintest)<-gsub("\\()","",names(mergetraintest))
```

 Reading the README provided, t means time and f frequency, so I make that explicit

```{r}
names(mergetraintest)<-gsub("^f","frequency",names(mergetraintest))
names(mergetraintest)<-gsub("^t","time",names(mergetraintest))
```

I can now add the subjects and activity to my merge table.
First I merge the train and the test

```{r}
subject<-rbind(subjectrain,subjectest)
activity<-rbind(ytrain,ytest)
```
I then convert the subject into a categorical variable

```{r}
subject$V1<-factor(subject$V1)
names(subject)<-"subject"
```
I load the names of the activities, and convert them in lowercase
without special character

```{r}
labelsactivity<-read.table("activity_labels.txt")
labelsactivity$V2<-tolower(gsub("_","",labelsactivity$V2))
```
I replace the number in activity by their corresponding activity name

```{r}
activity$V1<-labelsactivity$V2[activity$V1]
names(activity)<-"activity"
```

I finally merge the features, activities and subjects

```{r}
tidydata<-cbind(subject,activity,mergetraintest)
```

I average the different features for each activity and each subject

```{r}
tidydataavg<-aggregate(tidydata[,3:81],by=list(tidydata$subject,tidydata$activity), mean)
```
I arrange by individuals, then by activity (alphabetic order)

```{r}
names(tidydataavg)[1]<-"subject"
names(tidydataavg)[2]<-"activity"
library(dplyr)
tidydataavg<-arrange(tidydataavg,subject,activity)
```

And I finally save the tidy data set with the averages

```{r}
write.table(tidydataavg,file="tidyaverage.txt", row.name=FALSE)
```

The final text file contains 81 variables(79 means and st as well as 2 columns for 
the subjects and activities) for 180 rows(corresponding to 30 subjects * 6 activities)