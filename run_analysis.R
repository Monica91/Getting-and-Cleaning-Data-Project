# GETTING AND CLEANING DATA
# COURSE PROJECT

install.packages("data.table")
install.packages("reshape2")

library(data.table)
library(reshape2)

# READ DATA

# Read activity_label.txt - Links the class labels with their activity name. 
# The useful information is in the 2nd column
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
activity_labels <- activity_labels[,2]

# Read features.txt - List of all features. 
# The useful information is in the 2nd column
features <- read.table("./UCI HAR Dataset/features.txt")
features <- features[,2]

# Read X_test.txt - Test set. 
# We should extract only the measurements on the mean and standard deviation for each measurement.
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
# The variable "features" contains the name of the columns of X_test
names(X_test)=features
# The features which contain the substring std or std are related to mean and standard deviation. 
# So, they are the measurements we are interested in.
useful_features <- grepl("mean|std", features)
X_test <- X_test[,useful_features]

# Read Y_test.txt - Test labels.
Y_test <- read.table("./UCI HAR Dataset/test/Y_test.txt")
activity_labels = activity_labels[Y_test[,1]]
Y_test[,2] = activity_labels[Y_test[,1]]
names(Y_test)=c("ID_Activity","Activity_Label")

# Read subject.txt - 
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
names(subject_test) = "subject"
subject_test <- as.data.table(subject_test)

# Bind test data
test_data <- cbind(subject_test, Y_test, X_test)


# Now, we should do the same with the train data

# Read X_train.txt - Training set.
# We should extract only the measurements on the mean and standard deviation for each measurement.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
# The variable "features" contains the name of the columns of X_test
names(X_train)=features
# The features which contain the substring std or std are related to mean and standard deviation. 
# So, they are the measurements we are interested in.
X_train <- X_train[,useful_features]

#Read Y_train - Training labels.
Y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
Y_train[,2] = activity_labels[Y_train[,1]]
names(Y_train)=c("ID_Activity","Activity_Label")

# Read subject_train.txt - 
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
names(subject_train) = "subject"
subject_train <- as.data.table(subject_train)


# Bind train data
train_data <- cbind(subject_train, Y_train, X_train)

# Bind test and train data
data_set = rbind(test_data, train_data)

id_labels   = c("subject", "ID_Activity", "Activity_Label")
data_labels = setdiff(colnames(data_set), id_labels)
melt_data      = melt(data_set, id = id_labels, measure.vars = data_labels)
# Apply mean function to dataset
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)
write.table(tidy_data, file = "./tidy_data.txt")
