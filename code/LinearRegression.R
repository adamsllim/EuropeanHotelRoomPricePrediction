# MATH 4322 Final Project
# Adam Mills

# Forecasting Hotel Prices using linear Regression

#------------ LOAD DATA & LIBRARIES ------------#
# Load libraries
library(corrplot)
library(boot)

# Load data
hotel_data <- read.csv("~/Downloads/Hotel.csv") # replace with your file name

#------------ FEATURE ENGINEERING ------------#
str(hotel_data)
summary(hotel_data)
colSums(is.na(hotel_data))

# Remove ID (not a predictor)
hotel_data$ID <- NULL

# Drop rows with missing avg_room_price
hotel_data <- hotel_data[!is.na(hotel_data$avg_room_price), ]

# Convert categorical variables to factors
hotel_data$month <- as.factor(hotel_data$month)
hotel_data$room_type <- as.factor(hotel_data$room_type)
hotel_data$market_segment <- as.factor(hotel_data$market_segment)
hotel_data$meal_plan <- as.factor(hotel_data$meal_plan)
hotel_data$repeated_guest <- as.factor(hotel_data$repeated_guest)
hotel_data$status <- as.factor(hotel_data$status)

# Check final structure
str(hotel_data)

#------------ LINEAR REGRESSION MODEL ------------#
hotel_data.lm <- lm(avg_room_price~., data = hotel_data)
summary(hotel_data.lm)

# BIC 
BIC(hotel_data.lm) # 327509.2

#------------ FEATURE SELECTION ------------#

#--- CORRELATION PLOT ---#
numeric_features <- hotel_data[sapply(hotel_data, is.numeric)]

# Compute correlation matrix
cor_matrix <- cor(numeric_features, use = "complete.obs")

# Plot correlation heatmap
corrplot(cor_matrix, method = "color", type = "upper", tl.col = "black",
         tl.cex = 0.8, addCoef.col = "black", number.cex = 0.6)

#--- STEPWISE FUNCTION ---#
step_backward <- step(hotel_data.lm, direction = "backward")

#------------ NEW LINEAR REGRESSION MODEL ------------#
#  New model with important features
reduced_model.lm <- lm(avg_room_price~. -date, data=hotel_data)
summary(reduced_model.lm)

# BIC 
BIC(reduced_model.lm) # 327498.7

#------------ PLOTS ------------#
# create diagnostic plot
par(mfrow = c(2,2))
plot(reduced_model.lm)

#------------ CALCULATIONS ------------#
#--- SPLIT DATA ---#
MSE = rep(0,10)
for (i in 1:10){
  set.seed(i)
  
  train_index = sample(1:nrow(hotel_data),.8*nrow(hotel_data))
  train = hotel_data[train_index, -c(2,4)]
  test = hotel_data[-train_index, -c(2,4)]
  
  hotel_data.lm=lm(avg_room_price~., data=train)
  yhat=predict(hotel_data.lm, newdata=test)
  
  MSE[i]= mean((yhat-test$avg_room_price)^2)}

MSE

#--- MEAN TEST MSE ---#
mean_testMSE <- mean(MSE) 
mean_testMSE # 492.9383

#--- RMSE ---#
rmse <- sqrt(mean_testMSE)
rmse # 22.20221

#--- CROSS VALIDATION ---#
set.seed(1)
K <- 10
folds <- sample(rep(1:K, length.out = nrow(hotel_data)))

cv_mse <- rep(0, K)

for (k in 1:K) {
  train_data <- hotel_data[folds != k, ]
  test_data  <- hotel_data[folds == k, ]
  
  model_k <- lm(avg_room_price~. - date, data = train_data)
  
  preds <- predict(model_k, newdata = test_data)
  
  cv_mse[k] <- mean((preds - test_data$avg_room_price)^2)
}

mean(cv_mse) # 484.3507
sqrt(mean(cv_mse)) # 22.00797

