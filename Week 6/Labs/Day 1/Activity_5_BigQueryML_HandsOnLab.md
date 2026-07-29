# Activity 5: BigQuery ML (BQML) Student Activity Lab: Building 4 ML Models

Welcome to the BigQuery ML Hands-On Activity Lab. In this lab, you will apply the BigQuery ML skills you practiced in the self-study walkthrough to build, evaluate, examine, and deploy four distinct machine learning models directly inside Google Cloud BigQuery using standard SQL queries:

1. **Forecasting**: Predict future airline passenger counts using `ARIMA_PLUS`.
2. **Regression**: Predict vehicle fuel efficiency (`mpg`) using `LINEAR_REG`, examine feature weights (`ML.WEIGHTS`), and apply L1 regularization (`l1_reg`).
3. **Classification**: Predict loan approval decisions (`approve` vs `deny`) using `LOGISTIC_REG`, examine feature weights, and analyze ROC curves (`ML.ROC_CURVE`).
4. **Clustering**: Group breakfast cereals by nutritional profile using `KMEANS` and inspect cluster profiles (`ML.CENTROIDS`).

---

## Environment Setup & Data Ingestion

All tasks run in **BigQuery Studio / BigQuery Sandbox**. Ensure your target dataset `ml` exists:

```sql
CREATE SCHEMA IF NOT EXISTS `ml`;
```

### Required Datasets
Before starting, upload the following CSV datasets from `Week 6/Labs/Day 1/datasets/` into your `ml` dataset using the BigQuery Console ("Create Table" -> "Upload CSV" -> Auto-detect schema):
- `air_passenger.csv` (`datasets/timeseries/`) -> Table name: `ml.air_passengers`
- `mpg.csv` (`datasets/regression/`) -> Table name: `ml.car_mpg`
- `loans.csv` (`datasets/classification/`) -> Table name: `ml.loan_applications`
- `cereal.csv` (`datasets/clustering/`) -> Table name: `ml.cereal_nutrition`

---

## Task 1: Time-Series Forecasting with `ARIMA_PLUS` (`air_passengers`)

### Objective
Build a time-series model on historical monthly airline passenger records (`ml.air_passengers`) to forecast passenger totals for the next 12 months.

### Instructions
1. Write a `CREATE OR REPLACE MODEL` query named `ml.air_passenger_model` using `model_type = 'ARIMA_PLUS'`.
2. Specify `time_series_timestamp_col = 'date'` (using `PARSE_DATE('%Y-%m-%d', date)` if needed) and `time_series_data_col = 'passengers'`.
3. Run `ML.EVALUATE` to view fitted ARIMA parameters (AIC, log-likelihood).
4. Run `ML.FORECAST` to generate a 12-month future forecast with a 95% confidence level (`STRUCT(12 AS horizon, 0.95 AS confidence_level)`).

### Stretch Challenge
- Run `ML.EXPLAIN_FORECAST` on `ml.air_passenger_model` for 12 months to analyze trend vs seasonal additive components.
- Run `ML.DETECT_ANOMALIES` with a 0.8 probability threshold to check if any historical months were flagged as abnormal.

### SQL Workspace
```sql
-- Task 1.1: Train ARIMA_PLUS model on ml.air_passengers


-- Task 1.2: Evaluate model with ML.EVALUATE


-- Task 1.3: Generate 12-month forecast using ML.FORECAST


-- Stretch Challenge 1.4: Explain forecast components using ML.EXPLAIN_FORECAST

```

---

## Task 2: Continuous Value Regression & Feature Weight Examination (`car_mpg`)

### Objective
Predict vehicle fuel efficiency (`mpg`) using physical vehicle attributes (`cylinders`, `displacement`, `horsepower`, `weight`, `acceleration`). Examine learned feature weights and test L1 regularization.

### Instructions
1. Write a `CREATE OR REPLACE MODEL` query named `ml.car_mpg_model` using `model_type = 'LINEAR_REG'`.
2. Set `input_label_cols = ['mpg']` and `data_split_method = 'AUTO_SPLIT'`.
3. Select all feature columns plus `mpg` from `ml.car_mpg`.
4. Run `ML.EVALUATE` to inspect regression evaluation metrics: $R^2$, Mean Absolute Error (MAE), and Mean Squared Error (MSE).
5. Run `ML.WEIGHTS(MODEL ml.car_mpg_model)` to inspect feature coefficients. Which physical vehicle attributes have the strongest negative impact on fuel efficiency?
6. Use `ML.PREDICT` to predict `mpg` on test input rows.

### Stretch Challenge
Train a second model `ml.car_mpg_l1` incorporating L1 regularization (`l1_reg = 0.5`). Run `ML.WEIGHTS` on both models and compare how L1 regularization shrinks or zeroing out less influential feature weights.

### SQL Workspace
```sql
-- Task 2.1: Train LINEAR_REG model on ml.car_mpg


-- Task 2.2: Evaluate model performance with ML.EVALUATE


-- Task 2.3: Inspect feature weights with ML.WEIGHTS


-- Task 2.4: Predict mpg on test rows with ML.PREDICT


-- Stretch Challenge 2.5: Train L1-regularized LINEAR_REG model (l1_reg = 0.5) and inspect weights

```

---

## Task 3: Binary Classification & ROC Analysis (`loan_applications`)

### Objective
Predict whether an applicant's loan status will be approved (`approve`) or denied (`deny`) based on financial indicators (`assets`, `liabilities`, `income`, `credit_score`, `mortgage`). Examine feature influence and evaluate ROC curves.

### Instructions
1. Write a `CREATE OR REPLACE MODEL` query named `ml.loan_approval_model` using `model_type = 'LOGISTIC_REG'`.
2. Set `input_label_cols = ['status']` and `auto_class_weights = TRUE`.
3. Run `ML.EVALUATE` to inspect Precision, Recall, Accuracy, F1-score, and ROC AUC.
4. Run `ML.WEIGHTS` to determine which financial factors most strongly increase loan approval probability.
5. Use `ML.PREDICT` to generate predicted class labels (`predicted_status`) and class probabilities for applicants.

### Stretch Challenge
Run `ML.ROC_CURVE(MODEL ml.loan_approval_model)` to inspect false positive rate vs true positive rate across different classification decision thresholds.

### SQL Workspace
```sql
-- Task 3.1: Train LOGISTIC_REG model on ml.loan_applications


-- Task 3.2: Evaluate classification metrics with ML.EVALUATE


-- Task 3.3: Inspect feature weights with ML.WEIGHTS


-- Task 3.4: Run ML.PREDICT to generate predictions and class probabilities


-- Stretch Challenge 3.5: Run ML.ROC_CURVE to analyze threshold trade-offs

```

---

## Task 4: Unsupervised Customer/Product Clustering (`cereal_nutrition`)

### Objective
Segment breakfast cereals into 3 distinct clusters based on nutritional content (`Calories`, `Protein (g)`, `Fat`, `Sugars`, `Vitamins and Minerals`).

### Instructions
1. Query `ml.cereal_nutrition`. Note: Column names with spaces and special characters must be enclosed in backticks `` ` `` or aliased (e.g. `` `Protein (g)` AS protein_g ``).
2. Write a `CREATE OR REPLACE MODEL` query named `ml.cereal_clusters` using `model_type = 'KMEANS'`, `num_clusters = 3`, `distance_type = 'cosine'`, and `standardize_features = TRUE`.
3. Use `ML.CENTROIDS` with `ARRAY_AGG(STRUCT(...))` to inspect average nutritional features for each cluster centroid.
4. Use `ML.EVALUATE` to measure the Davies-Bouldin index quality.
5. Use `ML.PREDICT` to assign each cereal to a cluster ID and save results to `ml.cereal_clustered_results`.

### Stretch Challenge
Train a 5-cluster model (`num_clusters = 5`) and check whether the Davies-Bouldin index improves (lower value = tighter, better-separated clusters).

### SQL Workspace
```sql
-- Task 4.1: Train KMEANS model with num_clusters = 3 on ml.cereal_nutrition


-- Task 4.2: Inspect cluster profiles with ML.CENTROIDS


-- Task 4.3: Evaluate Davies-Bouldin index using ML.EVALUATE


-- Task 4.4: Predict cluster IDs and persist table ml.cereal_clustered_results


-- Stretch Challenge 4.5: Compare num_clusters = 5 Davies-Bouldin index

```

---

## Deliverables Checklist

- [ ] Task 1: Time-series model trained, evaluated, and 12-month forecast generated.
- [ ] Task 2: Linear regression model trained, $R^2$ evaluated, feature weights inspected (`ML.WEIGHTS`), and predicted.
- [ ] Task 3: Logistic regression model trained, ROC AUC evaluated, feature weights inspected, and predictions generated.
- [ ] Task 4: K-Means clustering model trained, centroid profiles inspected (`ML.CENTROIDS`), Davies-Bouldin index evaluated, and results persisted to `ml.cereal_clustered_results`.
- [ ] Stretch challenges attempted for extra credit.
