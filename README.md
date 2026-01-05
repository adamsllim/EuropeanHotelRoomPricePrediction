# European Hotel Room Price Prediction

## Overview...
This project forecasts average hotel room prices using over 36,000 booking records from the Kaggle “Hotel Booking” dataset. The dataset includes 19 variables describing booking behavior, guest characteristics, room types, and time‑related factors. The project applies two predictive modeling approaches — Linear Regression and Decision Trees — to understand how customer attributes and booking timing influence hotel pricing.

The goal of the project is to provide data‑driven insights into hotel pricing dynamics, helping customers make informed booking decisions and helping analysts understand which factors most strongly influence room price variation.

## Objectives...
- Forecast average room price using statistical and machine‑learning models
- Identify which booking, customer, and time‑related features most strongly influence pricing
- Compare Linear Regression and Decision Tree performance
- Evaluate model generalization using repeated train/test splits and cross‑validation
- Provide interpretable insights into hotel pricing behavior

Methodology...
1. Data Cleaning & Preparation
- Removed irrelevant identifiers (e.g., ID)
- Converted categorical variables into factors
- Checked for missing values and cleaned inconsistencies
- Created training/testing splits and cross‑validation folds
- Prepared reduced and full feature sets for model comparison

2. Exploratory Data Analysis (EDA)
- Examined distributions of room prices
- Investigated seasonal patterns (month, year)
- Analyzed guest characteristics (adults, children)
- Explored booking behavior (lead time, cancellations, special requests)
- Identified multicollinearity and redundant features

3. Modeling
#### Linear Regression
- Fit full model with all predictors
- Performed backward stepwise selection
- Identified “date” as non‑informative and removed it
- Fit reduced model with 17 predictors
- Evaluated assumptions using diagnostic plots
- Assessed generalization using:
  - 10 repeated train/test splits
  - 10‑fold cross‑validation

#### Decision Trees
- Fit regression trees using month, room_type, and market_segment
- Evaluated complexity using CP table
- Performed repeated train/test evaluation (10 iterations)
- Pruned the tree to reduce overfitting
- Analyzed variable importance and split structure

4. Interpretation
- Identified strongest predictors of room price
- Compared linear vs non‑linear modeling behavior
- Summarized seasonal, behavioral, and customer‑driven pricing patterns

## Key Findings...
#### Linear Regression Findings
- Reduced model explains ~60.8% of price variation (Adjusted R² = 0.6076)
- RMSE ≈ 22 euros, consistent across training, testing, and cross‑validation
- Strongest predictors include:
  - n_adults, n_children
  - meal_plan
  - room_type
  - lead_time
  - year
  - month (March–December highly significant)
- “date” (day of month) has no predictive value
- Longer lead times → lower prices
- Prices increase significantly in peak‑season months

Conclusion:
- Linear Regression provides stable, interpretable predictions with strong generalization.

#### Decision Tree Findings
- Primary split: room_type (strongest predictor)
- Secondary split: market_segment
- Tertiary split: month
- Repeated train/test MSE ≈ 658.61, indicating higher error than Linear Regression
- Tree required pruning to avoid overfitting
- Captures non‑linear interactions and threshold effects

Conclusion:
- Decision Trees reveal important interactions but are less accurate than Linear Regression for forecasting price.

## Error Analysis...
- Linear Regression shows mild heteroscedasticity but acceptable residual behavior
- Decision Trees overfit without pruning
- Market segment categories vary widely in predictive strength
- Some categorical levels (e.g., Corporate, Offline) show minimal influence
- Outliers and high‑variance room types introduce noise
- Seasonal patterns create strong non‑linear effects captured better by trees

## Future Work...
- Incorporate external data to improve accuracy
- Explore ensemble different models
- Add interaction terms to Linear Regression
- Apply regularization for feature stability
- Build an interactive dashboard for price forecasting
- Integrate geospatial analysis for region‑specific pricing insights
