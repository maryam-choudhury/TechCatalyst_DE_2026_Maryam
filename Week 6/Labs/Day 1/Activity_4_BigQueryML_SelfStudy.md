# Activity 4: BigQuery ML (BQML) Self-Study & Interactive Guide

Welcome to BigQuery ML (BQML). In this guided self-study lab, you will explore how Google Cloud BigQuery allows data engineers and analysts to build, evaluate, and operationalize Machine Learning models directly inside the data warehouse using standard **GoogleSQL** queries.

---

## 1. Why BigQuery ML?

Traditionally, machine learning requires exporting massive datasets out of data warehouses into specialized Python environments (such as scikit-learn, PyTorch, or TensorFlow), training models, and deploying inference pipelines. BigQuery ML flips this paradigm by bringing machine learning to where your data already lives.

### Key Benefits
1. **No Data Movement**: Train models directly on billions of rows without export overhead or egress costs.
2. **SQL Interface**: Train, evaluate, and predict using standard SQL statements (`CREATE MODEL`, `ML.EVALUATE`, `ML.PREDICT`, `ML.WEIGHTS`).
3. **Automated ML Pipelines**: Automatic feature scaling, missing value imputation, categorical one-hot encoding, and hyperparameter tuning.
4. **Speed and Scalability**: Leverages Google Cloud's distributed SQL engine for model training.

---

## 2. Prerequisites and Environment Setup

You can complete all exercises in this guide using the **BigQuery Sandbox** (no credit card required) or a standard Google Cloud project.

### Step 2.1: Create your Dataset
In the BigQuery Console SQL Editor, execute:

```sql
CREATE SCHEMA IF NOT EXISTS `ml`;
```

### Step 2.2: Prepare Raw CSV Datasets
Before starting Modules 2, 3, and 4, upload the following CSV files located in `Week 6/Labs/Day 1/datasets/` into your `ml` dataset using the BigQuery Console ("Create Table" -> "Upload CSV" -> Auto-detect schema):
- `milk_production.csv` (located in `datasets/timeseries/`) -> Table name: `ml.milk_production`
- `wholesale_customers.csv` (located in `datasets/clustering/`) -> Table name: `ml.wholesales_customers`

---

## 3. Module 1: Time-Series Forecasting with `ARIMA_PLUS` (Public Dataset)

Time-series forecasting predicts future sequential values based on historical time-stamped observations. BigQuery ML provides the `ARIMA_PLUS` model type, which automates complex time-series workflows:
- Automatic trend and seasonality detection
- Holiday effect modeling
- Handling missing timestamps and zero values
- Step change and spike adjustment

### Documentation Reference
[Google Cloud BigQuery ML ARIMA_PLUS Syntax](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-time-series)

### Step 3.1: Create a Prepared Daily Time-Series View
We query the public dataset `bigquery-public-data.covid19_open_data.covid19_open_data` to aggregate daily confirmed cases in France.

```sql
-- Create a clean view of daily new confirmed cases in France
CREATE OR REPLACE VIEW `ml.covid_fr_daily` AS
SELECT
  date,
  new_confirmed
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE country_name = 'France'
  AND new_confirmed IS NOT NULL
GROUP BY date, new_confirmed
ORDER BY date;
```

### Step 3.2: Train the Time-Series Model
We use `CREATE OR REPLACE MODEL` with `OPTIONS(model_type = 'ARIMA_PLUS')`.
- `time_series_timestamp_col`: Column containing sequential timestamps or dates.
- `time_series_data_col`: Column containing numeric metric values to forecast.

```sql
-- Train ARIMA_PLUS time-series model on daily COVID cases
CREATE OR REPLACE MODEL `ml.covid_fr_confirmed_ts`
OPTIONS(
  model_type = 'ARIMA_PLUS',
  time_series_timestamp_col = 'date',
  time_series_data_col = 'new_confirmed'
) AS
SELECT
  date,
  new_confirmed
FROM `ml.covid_fr_daily`
ORDER BY date;
```

### Step 3.3: Evaluate Model Performance
Use `ML.EVALUATE` to inspect fit statistics, best selected ARIMA order (p, d, q), Akaike Information Criterion (AIC), and log-likelihood.

```sql
-- Evaluate model statistics and fitted parameters
SELECT *
FROM ML.EVALUATE(MODEL `ml.covid_fr_confirmed_ts`);
```

### Step 3.4: Generate Predictions with `ML.FORECAST`
`ML.FORECAST` requires a `STRUCT` specifying:
- `horizon`: Number of future time steps to predict (e.g. 15 days).
- `confidence_level`: Width of lower and upper prediction bounds (e.g. 0.90 for 90% confidence).

```sql
-- Forecast 15 days into the future with 90% confidence level
SELECT
  forecast_timestamp,
  forecast_value,
  prediction_interval_lower_bound,
  prediction_interval_upper_bound
FROM ML.FORECAST(
  MODEL `ml.covid_fr_confirmed_ts`,
  STRUCT(
    15 AS horizon,
    0.9 AS confidence_level
  )
);
```

---

## 4. Module 2: Advanced Time-Series Options, Forecast Explanations, & Anomaly Detection

Now let's explore fine-tuning time-series models using the `milk_production.csv` dataset. BQML provides explicit options to control frequency, holiday effects, and seasonality.

### Key Advanced `ARIMA_PLUS` Options
- `auto_arima = TRUE`: BQML tests multiple candidate hyperparameter combinations and selects the optimal model.
- `decompose_time_series = TRUE`: Splits signal into trend, seasonal, and holiday components.
- `adjust_step_changes = TRUE`: Detects abrupt baseline shifts in the time-series history.
- `holiday_region = 'US'`: Incorporates official public holidays for specified country code.
- `data_frequency = 'MONTHLY'`: Explicitly specifies timestamp interval ('DAILY', 'MONTHLY', 'YEARLY', etc.).
- `seasonalities = ['MONTHLY', 'YEARLY']`: Forces explicit seasonal periods.

### Step 4.1: Train the Advanced Milk Production Time-Series Model

```sql
-- Train ARIMA_PLUS model with full hyperparameter and seasonality options
CREATE OR REPLACE MODEL `ml.milk_daily_ts`
OPTIONS(
  MODEL_TYPE = 'ARIMA_PLUS',
  time_series_timestamp_col = 'month',
  time_series_data_col = 'production',
  auto_arima = TRUE,
  decompose_time_series = TRUE,
  adjust_step_changes = TRUE,
  holiday_region = 'US',
  data_frequency = 'MONTHLY',
  seasonalities = ['MONTHLY', 'YEARLY']
) AS
SELECT
  month,
  production
FROM `ml.milk_production`
ORDER BY month;
```

### Step 4.2: Evaluate Model Metrics

```sql
-- Evaluate the fitted ARIMA model
SELECT *
FROM ML.EVALUATE(MODEL `ml.milk_daily_ts`);
```

### Step 4.3: Generate 12-Month Forecast

```sql
-- Generate 12-month future forecast
SELECT
  forecast_timestamp,
  forecast_value,
  prediction_interval_lower_bound,
  prediction_interval_upper_bound
FROM ML.FORECAST(
  MODEL `ml.milk_daily_ts`,
  STRUCT(
    12 AS horizon,
    0.95 AS confidence_level
  )
);
```

### Step 4.4: Combining Historical Data and Forecast into Unified Table
In data engineering, analytics consumers often need a single unified dataset combining historical actuals and future predictions for visualization dashboards. We use `UNION ALL` to create `ml.milk_daily_with_forecast`.

```sql
-- Create unified table containing both actual historical records and 30-month forecasts
CREATE OR REPLACE TABLE `ml.milk_daily_with_forecast` AS
WITH hist AS (
  SELECT
    month AS date,
    production AS milk_liters,
    'actual' AS row_type
  FROM `ml.milk_production`
),
forecast AS (
  SELECT
    DATE(forecast_timestamp) AS date,
    forecast_value AS milk_liters,
    'forecast' AS row_type
  FROM ML.FORECAST(
    MODEL `ml.milk_daily_ts`,
    STRUCT(30 AS horizon, 0.95 AS confidence_level)
  )
)
SELECT * FROM hist
UNION ALL
SELECT * FROM forecast;

-- Inspect combined result
SELECT * FROM `ml.milk_daily_with_forecast` ORDER BY date;
```

### Step 4.5: Explain Forecast Factors with `ML.EXPLAIN_FORECAST`
`ML.EXPLAIN_FORECAST` breaks down the forecast into individual additive terms: baseline, trend, seasonal component, holiday effect, and step changes.

```sql
-- Inspect decomposed components driving future predictions
SELECT *
FROM ML.EXPLAIN_FORECAST(
  MODEL `ml.milk_daily_ts`,
  STRUCT(
    12 AS horizon,
    0.95 AS confidence_level
  )
);
```

### Step 4.6: Detect Outliers with `ML.DETECT_ANOMALIES`
`ML.DETECT_ANOMALIES` uses the fitted time-series model to flag historical data points that deviate significantly from expected normal patterns.

```sql
-- Detect historical anomalies using 80% probability threshold
SELECT *
FROM ML.DETECT_ANOMALIES (
  MODEL `ml.milk_daily_ts`,
  STRUCT(0.8 AS anomaly_prob_threshold)
);
```

---

## 5. Module 3: Unsupervised Learning with K-Means Clustering

Clustering groups unlabeled data points into clusters based on feature similarity. Unlike supervised learning, there are no target labels provided during training.

### Documentation Reference
[Google Cloud BigQuery ML K-Means Syntax](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-kmeans)

### Key K-Means Model Options
- `model_type = 'KMEANS'`: Instructs BQML to build a K-Means clustering model.
- `num_clusters = 4`: Number of cluster centroids to compute ($k=4$).
- `distance_type = 'cosine'`: Distance metric used to calculate proximity ('EUCLIDEAN' or 'COSINE'). Cosine distance measures direction/ratio similarity regardless of magnitude.
- `standardize_features = false`: Disables automatic feature standardization if variables are pre-scaled or should retain raw ratios.

### Step 5.1: Train K-Means Clustering Model on Wholesale Customers
We cluster wholesale customers based on spending across spending categories: `Fresh`, `Milk`, `Grocery`, `Frozen`, `Detergents_and_Paper`, `Delicatessen`, and sales `Channel`.

```sql
-- Train K-Means model with 4 clusters using cosine distance metric
CREATE OR REPLACE MODEL `ml.kmeans_wholesales`
OPTIONS (
  model_type = 'KMEANS',
  num_clusters = 4,
  distance_type = 'cosine',
  standardize_features = false
) AS
SELECT
  Fresh,
  Milk,
  Grocery,
  Frozen,
  `Detergents and Paper` AS Detergents_and_Paper, -- Rename column to avoid spaces in BigQuery
  Delicatessen,
  Channel
FROM `ml.wholesales_customers`;
```

### Step 5.2: Profile Clusters with `ML.CENTROIDS`
`ML.CENTROIDS` returns feature values for each centroid. We aggregate feature values per centroid to understand what characteristics define each customer segment.

```sql
-- Inspect centroid profiles across all 4 clusters
SELECT
  centroid_id,
  ARRAY_AGG(STRUCT(feature AS feature_name, ROUND(numerical_value, 2) AS value)
    ORDER BY centroid_id) AS cluster_profile
FROM ML.CENTROIDS(MODEL `ml.kmeans_wholesales`)
GROUP BY centroid_id
ORDER BY centroid_id;
```

### Step 5.3: Evaluate Clustering Quality with `ML.EVALUATE`
For unsupervised clustering, `ML.EVALUATE` calculates:
- **Davies-Bouldin Index**: Lower values indicate better-separated and more compact clusters.
- **Mean Squared Distance**: Average squared distance from data points to their assigned cluster centroid.

```sql
-- Evaluate Davies-Bouldin index and cluster compactness
SELECT *
FROM ML.EVALUATE(MODEL `ml.kmeans_wholesales`);
```

### Step 5.4: Predict Cluster Assignments with `ML.PREDICT`
`ML.PREDICT` assigns each customer record to its closest cluster (`CENTROID_ID`).

```sql
-- Assign cluster IDs to customer records
SELECT
  CENTROID_ID AS cluster,
  Fresh,
  Milk,
  Grocery,
  Frozen,
  Detergents_and_Paper,
  Delicatessen,
  Channel
FROM ML.PREDICT(
  MODEL `ml.kmeans_wholesales`,
  (SELECT 
    Fresh,
    Milk,
    Grocery,
    Frozen,
    `Detergents and Paper` AS Detergents_and_Paper,
    Delicatessen,
    Channel
   FROM `ml.wholesales_customers`)
);
```

### Step 5.5: Persist Clustered Data for Downstream Analytics
Save cluster assignments into a permanent table for BI tools or downstream pipeline consumption.

```sql
-- Persist cluster assignments to production table ml.wholesale_customers_clustered
CREATE OR REPLACE TABLE `ml.wholesale_customers_clustered` AS
SELECT
  CENTROID_ID AS cluster,
  *
FROM ML.PREDICT(
  MODEL `ml.kmeans_wholesales`,
  (SELECT 
    Fresh,
    Milk,
    Grocery,
    Frozen,
    `Detergents and Paper` AS Detergents_and_Paper,
    Delicatessen,
    Channel
   FROM `ml.wholesales_customers`)
);

-- Verify persisted table
SELECT * FROM `ml.wholesale_customers_clustered` LIMIT 10;
```

---

## 6. Module 4: Supervised Learning with Generalized Linear Models (GLM)

Generalized Linear Models (GLM) encompass Linear Regression (for predicting continuous numerical values) and Logistic Regression (for binary or multi-class classification).

### Documentation Reference
[Google Cloud BigQuery ML GLM Syntax](https://docs.cloud.google.com/bigquery/docs/reference/standard-sql/bigqueryml-syntax-create-glm)

---

## 7. Deep Dive: Feature Selection, Engineering, & Regularization

Understanding how BigQuery ML processes raw columns into model inputs is essential for data engineers.

### 7.1 Automated Feature Engineering in BQML
When you pass columns into `CREATE MODEL`, BQML automatically performs pre-processing steps:
1. **One-Hot Encoding**: Categorical string columns (e.g. state names, channel types) are automatically converted into binary indicator vectors.
2. **Missing Value Imputation**: Numerical missing values are replaced with feature means; categorical missing values are assigned to a distinct `NULL` category.
3. **Feature Standardization**: Enabled by default (`STANDARDIZE_FEATURES = TRUE`), BQML scales numerical features to zero mean and unit variance ($z = \frac{x - \mu}{\sigma}$), ensuring large numbers (e.g. income $100,000) do not overpower smaller scales (e.g. credit score 700).

---

### 7.2 The Concept of Regularization (`l1_reg` and `l2_reg`)
In machine learning, **overfitting** occurs when a model learns noise and fine details in the training dataset rather than true generalizable relationships. Regularization adds a mathematical penalty to feature weights to keep the model simple and robust.

```
Total Loss = Empirical Prediction Loss + Regularization Penalty
```

#### 1. L1 Regularization (Lasso, `l1_reg`)
- **Penalty**: Adds the sum of absolute values of feature weights: $\lambda_1 \sum |w_i|$.
- **Behavior**: Forces weights of weak or redundant features **exactly to zero**.
- **DE Takeaway**: L1 regularization acts as **automated feature selection**. If you pass 50 raw columns into a model, L1 zeroing out 35 of them indicates those 35 columns contribute no predictive power.

#### 2. L2 Regularization (Ridge, `l2_reg`)
- **Penalty**: Adds the sum of squared values of feature weights: $\lambda_2 \sum w_i^2$.
- **Behavior**: Shrinks weights close to zero without making them exactly zero.
- **DE Takeaway**: L2 handles **multicollinearity** (when input features are highly correlated with each other, such as `annual_income` and `monthly_salary`). It distributes credit smoothly across correlated features and prevents wildly unstable weight swings.

#### 3. Elastic Net Regularization
Combining both options in BQML:

```sql
CREATE OR REPLACE MODEL `ml.sample_elastic_net`
OPTIONS(
  model_type = 'LINEAR_REG',
  input_label_cols = ['target_value'],
  l1_reg = 0.2, -- Automated feature selection penalty
  l2_reg = 0.5  -- Multicollinearity variance reduction penalty
) AS
SELECT * FROM `ml.training_table`;
```

---

## 8. How to Examine and Interpret BQML Model Outputs

Once a model is trained, a data engineer must evaluate its metrics and inspect learned parameters before promoting it to production.

### 8.1 Examining Feature Weights with `ML.WEIGHTS`
Use `ML.WEIGHTS` to inspect the coefficient assigned to each feature by GLM models:

```sql
SELECT
  processed_input,
  weight,
  category_weights
FROM ML.WEIGHTS(MODEL `ml.sample_glm_model`);
```

- **Positive Weight**: Higher feature values increase the predicted label value or classification probability.
- **Negative Weight**: Higher feature values decrease the predicted label value or probability.
- **Zero Weight**: Feature was zeroed out by L1 regularization (irrelevant feature).

---

### 8.2 Interpreting Evaluation Metrics (`ML.EVALUATE`)

#### Regression Metrics (`LINEAR_REG`)
- **R-squared ($R^2$)**: Percentage of variance in the target variable explained by the features (0.0 to 1.0; higher is better).
- **Mean Absolute Error (MAE)**: Average absolute difference between predicted and actual values (in raw units, e.g. dollars or miles per gallon).
- **Root Mean Squared Error (RMSE)**: Penalizes larger prediction errors more heavily than MAE.

#### Classification Metrics (`LOGISTIC_REG`)
- **Precision**: Out of all instances predicted as positive, how many were actually positive? $\frac{TP}{TP + FP}$
- **Recall (Sensitivity)**: Out of all actual positive instances, how many did the model correctly identify? $\frac{TP}{TP + FN}$
- **Accuracy**: Overall fraction of correct predictions across all classes.
- **F1-Score**: Harmonic mean of Precision and Recall ($2 \times \frac{\text{Precision} \times \text{Recall}}{\text{Precision} + \text{Recall}}$).
- **ROC AUC**: Area Under the Receiver Operating Characteristic Curve (0.5 = random guessing, 1.0 = perfect classifier). Measures how well the model separates classes regardless of threshold.

---

## 9. Summary: BigQuery ML SQL Function Reference

| SQL Statement / Function | Purpose | Typical Usage |
|---|---|---|
| `CREATE OR REPLACE MODEL` | Trains and compiles a machine learning model | `OPTIONS(model_type='...', ...)` |
| `ML.EVALUATE` | Calculates evaluation metrics on test/holdout data | `SELECT * FROM ML.EVALUATE(MODEL model_name)` |
| `ML.PREDICT` | Runs inference on new inputs (Regression, Classification, Clustering) | `SELECT * FROM ML.PREDICT(MODEL model_name, (SELECT ...))` |
| `ML.WEIGHTS` | Inspects feature coefficients and learned weights | `SELECT * FROM ML.WEIGHTS(MODEL model_name)` |
| `ML.FORECAST` | Generates future forecasts for ARIMA time series models | `SELECT * FROM ML.FORECAST(MODEL model_name, STRUCT(12 AS horizon))` |
| `ML.EXPLAIN_FORECAST` | Decomposes forecasts into trend, seasonal, and holiday components | `SELECT * FROM ML.EXPLAIN_FORECAST(MODEL model_name, STRUCT(...))` |
| `ML.DETECT_ANOMALIES` | Flags historical outliers based on probabilistic thresholds | `SELECT * FROM ML.DETECT_ANOMALIES(MODEL model_name, STRUCT(...))` |
| `ML.CENTROIDS` | Extracts feature coordinates of K-Means cluster centers | `SELECT * FROM ML.CENTROIDS(MODEL model_name)` |
| `ML.ROC_CURVE` | Generates threshold tradeoffs for binary classification | `SELECT * FROM ML.ROC_CURVE(MODEL model_name)` |

---

**Congratulations!** You have completed the BigQuery ML Self-Study walkthrough. You are now ready to apply these paradigms in the student activity lab.
