# Week 1 · Day 4: Query Files in Place with BigQuery

**Estimated time:** 40 minutes
**Difficulty:** Beginner
**Format:** Individual or pairs
**Required file:** `Lab Resources/yellow_trip_sample.csv`

> [!NOTE]
> **You will work mostly in the Console today.** BigQuery's **SQL workspace** is a web UI — you point, click, and read results on screen, which is the easiest way to learn what an external table is. The few terminal commands here (checking access, peeking at the file, uploading it) appear as optional **💻 Also via CLI** boxes; the Console can do each of them too. The CLI and Python SDK get dedicated time in Week 2.
>
> **Run any CLI box in Cloud Shell** (the `>_` icon at the top-right of the console) — it's already signed in and has `gcloud`/`bq` preinstalled. Those commands will **not** work in a local or Codespaces terminal unless you install and authenticate the Google Cloud CLI there yourself.

## Purpose and Learning Outcomes

In this required activity, you will query a CSV where it already rests in Cloud Storage. You will not write SQL from scratch; copy the supplied statements, predict what BigQuery needs, and explain what you observe.

By the end, you can:

- explain **schema-on-read** and **query-in-place**;
- inspect a CSV and review or create a BigQuery external table;
- run a row preview and an aggregation, then record bytes processed;
- choose between an external table and a loaded, curated BigQuery table.

## Concept Checkpoint (3 minutes)

An **external table** stores table metadata in BigQuery while the data remains in Cloud Storage. BigQuery applies a schema when it reads the objects: this is **schema-on-read**. **Query-in-place** means querying those objects without first loading their rows into BigQuery-managed storage.

Before continuing, predict what the engine must know. Write one item in each blank:

1. Where is the data? `________________________________________`
2. What file format is it? `________________________________________`
3. How are columns identified and typed? `________________________________________`
4. Is there a header row to skip? `________________________________________`

## Before You Start (5 minutes)

You do everything in **your own project** — the same one you used in Activity 1. Two quick setup steps: put the sample CSV in your bucket, and create a BigQuery dataset to hold the table definition.

> [!IMPORTANT]
> Use only your assigned project. **If anything in this lab doesn't work, contact your instructor.**

1. **Upload the CSV to your bucket.** In the Console → **Cloud Storage → Buckets**, open your raw bucket from Activity 1 (`techcatalyst-de-2026-<username>-raw`). Click **Create folder**, name it `taxi`, open it, then **Upload → Upload files** and choose `yellow_trip_sample.csv` from the `Lab Resources/` folder. You should end up with:

   ```text
   gs://techcatalyst-de-2026-<username>-raw/taxi/yellow_trip_sample.csv
   ```

2. **Create a BigQuery dataset.** In the Console → **BigQuery**. In the **Explorer** panel, click the **⋮ (View actions)** next to your project → **Create dataset**. Set **Dataset ID** = `day4_external`, **Location type** = **Region** → **`us-east1`** (it must match your bucket's region), then **Create dataset**.

Throughout the SQL in this lab, your table is `YOUR_PROJECT_ID.day4_external.yellow_trip_sample` — replace `YOUR_PROJECT_ID` with your own project ID (you'll see it in the project picker).

> [!NOTE]
> **💻 Also via CLI (optional).** The upload and dataset from Cloud Shell:
>
> ```bash
> export PROJECT_ID="YOUR_ASSIGNED_PROJECT_ID"
> export BUCKET_NAME="techcatalyst-de-2026-<username>-raw"
> gcloud storage cp "$HOME/yellow_trip_sample.csv" "gs://$BUCKET_NAME/taxi/yellow_trip_sample.csv"
> bq --location=us-east1 mk --dataset "$PROJECT_ID:day4_external"
> ```

## Part 1: Inspect the Stored CSV (5 minutes)

Look at the first few rows of the file. Easiest: open `Lab Resources/yellow_trip_sample.csv` from the course repo in your editor (it is the same file). In the Console you can also click the object in the bucket and use **Download** to view it.

> [!NOTE]
> **💻 Also via CLI (optional).** Peek at the object without downloading the whole thing:
>
> ```bash
> gcloud storage cat \
>   "gs://$BUCKET_NAME/taxi/yellow_trip_sample.csv" | head -n 6
> ```

Expected beginning:

```text
PULocationID,fare_amount,trip_date
161,14.50,2025-01-15
162,9.25,2025-01-15
163,22.00,2025-01-16
164,11.75,2025-01-16
236,18.30,2025-01-17
```

Record:

1. Delimiter: `____________`
2. Header present? `____________`
3. Your predicted types for the three columns: `________________________________________`
4. What could go wrong if a later file contains `unknown` in `fare_amount`? `________________________________________`

## Part 2: Review or Create the External Table (8 minutes)

Open **BigQuery → SQL workspace** and click **Compose new query**. Paste the statement below, replacing `YOUR_PROJECT_ID` and `<username>` with yours, then click **Run**. This creates the external table over the CSV in your bucket (it copies no data — it just stores a pointer plus the schema).

```sql
CREATE OR REPLACE EXTERNAL TABLE `YOUR_PROJECT_ID.day4_external.yellow_trip_sample`
OPTIONS (
  format = 'CSV',
  uris = ['gs://techcatalyst-de-2026-<username>-raw/taxi/yellow_trip_sample.csv'],
  skip_leading_rows = 1
);
```

No column list appears between the table name and `OPTIONS`. For this supported CSV external-table DDL, omitting that schema tells BigQuery to autodetect column names and types from the source. `autodetect` is not an option in this GoogleSQL statement.

**Before running:** What do the three options control, and what omitted DDL element causes schema autodetection? `________________________________________`

**After running or reviewing:** Record the schema shown by BigQuery.

| Column | BigQuery type | Does it match your prediction? |
| :--- | :--- | :--- |
| `PULocationID` | | |
| `fare_amount` | | |
| `trip_date` | | |

Checkpoint: the CSV did not gain a stored database schema. BigQuery inferred and saved table metadata, then will apply that metadata while reading the object.

## Part 3: Run the Supplied Queries (9 minutes)

Replace `TABLE_FQID` in both queries with your table's FQID, `YOUR_PROJECT_ID.day4_external.yellow_trip_sample`, leaving the backticks in place.

The pre-run validator/dry-run estimate for an external table may show `0 B`, omit an estimate, or provide only a lower bound because the data is external. Record it as a secondary observation. After **Run**, open **Job information** and use the completed job's actual **bytes processed** as the primary scan observation.

### Query A: preview rows

**Predict:** Does `LIMIT 10` mean BigQuery can stop scanning a row-oriented CSV after exactly ten rows? Why or why not?

```sql
SELECT *
FROM `TABLE_FQID`
ORDER BY trip_date, PULocationID
LIMIT 10;
```

- Result schema observation (column names and types): `________________________________________`
- Estimated bytes before Run: `________________________________________`
- Bytes processed after Run: `________________________________________`
- One external-CSV limitation revealed or relevant to this query: `________________________________________`

### Query B: aggregate by date

**Predict:** What data must BigQuery read to calculate the count and total for every date?

```sql
SELECT
  trip_date,
  COUNT(*) AS trip_count,
  ROUND(SUM(fare_amount), 2) AS total_fare
FROM `TABLE_FQID`
GROUP BY trip_date
ORDER BY total_fare DESC;
```

- Date with the greatest `total_fare`: `________________________________________`
- Result schema observation (column names and types): `________________________________________`
- Estimated bytes before Run: `________________________________________`
- Bytes processed after Run: `________________________________________`
- One external-CSV limitation revealed or relevant to this query: `________________________________________`

## Part 4: Compare the Scan Signal and Limitations (4 minutes)

Complete the comparison:

| Observation | Query A | Query B |
| :--- | :--- | :--- |
| Rows returned | | |
| Bytes processed | | |
| Did fewer output rows guarantee fewer input bytes? | | |

For external tables, the validator/dry-run value may be `0 B`, unavailable, or a lower bound; do not treat it as the actual scan. The completed job's **bytes processed** is the primary observation. Bytes processed is still not a complete price quote: cache state, billing minimums, and the pricing model can make bytes billed differ.

Compare the two limitations you recorded. Which one would matter most for a repeated production workload, and why? `________________________________________`

Examples to consider: CSV is row-oriented; autodetection can infer an unwanted type; malformed or changed files can break a stable interpretation; repeated external queries can be slower than queries against optimized managed tables.

## Part 5: External or Loaded Curated Table? (3 minutes)

Use this decision rule:

- **Query in place** when data is exploratory, infrequently queried, shared with another engine, or not yet ready for curation.
- **Load or transform into a managed warehouse table** when queries repeat, performance matters, governance requires a stable schema, or downstream BI depends on consistent results.

Choose one option for each case and give one reason:

1. A new partner CSV needs a one-time quality check: **external / loaded**, because `____________________`.
2. A daily executive dashboard needs predictable performance and stable fields: **external / loaded**, because `____________________`.

BigQuery external tables and Amazon Athena both support serverless SQL over external data and expose scan-related cost signals. They are not the same service: **BigQuery is also a managed analytical data warehouse**, while **Athena primarily queries data in Amazon S3 and other supported sources**.

## Submission and Recap (3 minutes)

Submit one Markdown file or form response containing:

1. the four concept-checkpoint answers;
2. the observed schema;
3. Query A and B results, each with a result-schema and bytes-processed observation;
4. one external-CSV limitation for each query, plus the Part 4 comparison;
5. both Part 5 decisions and reasons.

## Success Criteria

- You can point to the URI, format, header rule, and schema as the metadata needed for schema-on-read.
- Both supplied queries have observed result-schema and bytes notes.
- Each query has a limitation that describes external CSV behavior rather than a SQL syntax issue.
- Your external-versus-loaded choices use workload needs, not vendor preference.

# Instructor Answer Key

1. **Concept checkpoint:** the Cloud Storage URI; CSV; a declared or inferred schema; and one header row to skip.
2. **File inspection:** comma delimiter, header present, and plausible inferred types `INT64`, `FLOAT64`, and `DATE`. A nonnumeric `fare_amount` can cause inference drift, a null/error depending on schema and parsing options, or inconsistent results across files.
3. **Definition metadata:** `uris` locates the object, `format` identifies CSV, and `skip_leading_rows` excludes the header from data rows. The omitted column list causes BigQuery to autodetect the external schema; there is no `autodetect` option in this GoogleSQL DDL.
4. **Query A:** deterministically returns the first ten rows ordered by `trip_date`, then `PULocationID`, with source columns `PULocationID INT64`, `fare_amount FLOAT64`, and `trip_date DATE`. `LIMIT` controls output, but a row-oriented external CSV may still require scanning the file; this is an appropriate Query A limitation.
5. **Query B:** returns `trip_date DATE`, `trip_count INT64`, and `total_fare FLOAT64`. All rows contribute. The greatest total is `38.50` on `2025-01-23`; the next totals are `37.00` on `2025-01-18` and `34.40` on `2025-01-21`. A suitable Query B limitation is that every row must be interpreted for the aggregation and CSV does not offer columnar pruning.
6. **Bytes:** an external-table validator/dry run may show `0 B`, no estimate, or a lower bound. Grade the completed job's **Job information > bytes processed** as the primary observation. Do not grade bytes processed as though they equal bytes billed.
7. **Other accepted limitations:** schema inference/drift, malformed-row sensitivity, weaker repeated-query performance, or dependency on the external object's availability and permissions. Require one relevant limitation after each query; the same limitation may be used twice only when the learner explains its relevance to both.
8. **Decisions:** the one-time partner quality check is a strong external-table case; the repeated executive dashboard is a strong loaded/curated managed-table case.

## Official References

- [BigQuery external tables](https://docs.cloud.google.com/bigquery/docs/external-tables)
- [Query Cloud Storage data with BigQuery](https://docs.cloud.google.com/bigquery/docs/external-data-cloud-storage)
- [BigQuery locations](https://docs.cloud.google.com/bigquery/docs/locations)
