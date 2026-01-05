#------------ LOAD DATA & LIBRARIES ------------#
library(rpart)
library(dplyr)
library(rpart.plot)

# Load data
hotel_data <- read.csv("~/Downloads/Hotel.csv") # replace with your file name

# Convert relevant columns to factors
hotel_data$month          <- as.factor(hotel_data$month)
hotel_data$room_type      <- as.factor(hotel_data$room_type)
hotel_data$market_segment <- as.factor(hotel_data$market_segment)

# Select relevant columns for the decision tree models
seasonal_data <- hotel_data %>%
  select(avg_room_price, month, room_type, market_segment)

#------------ SINGLE DECISION TREE (UNPRUNED) ------------#

MSE_single <- rep(0, 10)  # store MSE for each iteration

for (i in 1:10) {
  set.seed(i * 42)  # Ensures reproducibility with a unique seed for each iteration
  
  # Randomly select 80% of the data for training
  train_index <- sample(1:nrow(seasonal_data), size = 0.8 * nrow(seasonal_data))
  train_data  <- seasonal_data[train_index, ]
  test_data   <- seasonal_data[-train_index, ]
  
  # Build the decision tree model
  seasonal_price_tree <- rpart(
    avg_room_price ~ month + room_type + market_segment,
    data   = train_data,
    method = "anova"
  )
  
  # Visualize the decision tree
  plot(seasonal_price_tree,
       main = paste("Decision Tree - Iteration", i),
       cex  = 0.7)
  text(seasonal_price_tree, pretty = 0, cex = 0.7)
  
  # Predict avg_room_price on the test data and calculate MSE
  predictions <- predict(seasonal_price_tree, newdata = test_data)
  MSE_single[i] <- mean((test_data$avg_room_price - predictions)^2)
}

# Average MSE across all iterations (single tree)
mean_MSE_single <- mean(MSE_single)
print(mean_MSE_single)  # 658.6132


#------------ PRUNED DECISION TREE (WITH CROSS-VALIDATION) ------------#

MSE_pruned <- rep(0, 10)  # store MSE for each iteration

for (i in 1:10) {
  set.seed(i * 42)  # Ensures reproducibility with a unique seed for each iteration
  
  # Randomly select 80% of the data for training
  train_index <- sample(1:nrow(seasonal_data), size = 0.8 * nrow(seasonal_data))
  train_data  <- seasonal_data[train_index, ]
  test_data   <- seasonal_data[-train_index, ]
  
  # Build the decision tree model with cross-validation for optimal cp
  seasonal_price_tree <- rpart(
    avg_room_price ~ month + room_type + market_segment,
    data    = train_data,
    method  = "anova",
    control = rpart.control(cp = 0.001)  # Start with a low cp
  )
  
  # Cross-validation to find the optimal tree size
  cv_tree <- printcp(seasonal_price_tree)  # Displays cp table and cross-validation error
  
  # Plot the complexity parameter against the model's error
  plotcp(seasonal_price_tree)  # This plots the cross-validation results
  
  # Prune the tree to the optimal size based on cross-validation results
  best_cp <- seasonal_price_tree$cptable[
    which.min(seasonal_price_tree$cptable[, "xerror"]),
    "CP"
  ]
  pruned_tree <- prune(seasonal_price_tree, cp = best_cp)
  
  # Adjust margins and plot the pruned decision tree
  par(xpd = NA, mar = c(4, 4, 4, 4))  # Adjust margins to prevent text cutoff
  plot(pruned_tree,
       main   = paste("Pruned Decision Tree - Iteration", i),
       uniform = TRUE,   # Uniform vertical spacing
       margin  = 0.2,    # Add extra space around the plot
       cex     = 0.7)    # Adjust node text size
  
  # Add text labels to the tree
  text(pruned_tree, pretty = 0, cex = 0.7)  # Ensure all labels are visible
  
  # Predict avg_room_price on the test data and calculate MSE
  predictions_pruned <- predict(pruned_tree, newdata = test_data)
  MSE_pruned[i] <- mean((test_data$avg_room_price - predictions_pruned)^2)
}

# Average MSE across all iterations (pruned tree)
mean_MSE_pruned <- mean(MSE_pruned)
print(mean_MSE_pruned) # 611.8217