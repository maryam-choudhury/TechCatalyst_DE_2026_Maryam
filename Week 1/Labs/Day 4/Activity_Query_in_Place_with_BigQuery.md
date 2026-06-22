# Week 1 · Day 4 — Query Files in Place with BigQuery

**Estimated time:** 40 minutes
**Difficulty:** Beginner
**Format:** Individual or pairs
**Required file:** `Lab Resources/yellow_trip_sample.csv`

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

## Permission Preflight and Fallback (5 minutes)

Use only your assigned course project. Do not attach personal billing or change IAM policies.

Choose the route assigned by your instructor. Do not mix the routes.

### Route A: instructor-prepared read-only table

Use this exact fully qualified table ID (FQID) placeholder unless the instructor gives you a different project ID:

```text
INSTRUCTOR_PROJECT_ID.day4_external.yellow_trip_sample
```

The instructor also supplies `INSTRUCTOR_BUCKET_NAME` so you can inspect `gs://INSTRUCTOR_BUCKET_NAME/raw/taxi/yellow_trip_sample.csv` in Part 1.

Required permissions are:

- `bigquery.jobs.create` in the project that runs your query (typically **BigQuery Job User**);
- `bigquery.tables.get` and `bigquery.tables.getData` on the prepared table/dataset (typically **BigQuery Data Viewer**);
- `storage.buckets.get`, `storage.objects.get`, and `storage.objects.list` on the external source (the instructor may supply these through a scoped classroom role; **Storage Object Viewer** covers the object actions).

You do **not** create or replace a table on this route. Set `TABLE_FQID` in the later SQL to `INSTRUCTOR_PROJECT_ID.day4_external.yellow_trip_sample`.

In Cloud Shell, set the prepared bucket name and confirm that object access works:

```bash
export BUCKET_NAME="INSTRUCTOR_BUCKET_NAME"
gcloud auth list
gcloud storage ls "gs://$BUCKET_NAME/raw/taxi/yellow_trip_sample.csv"
```

### Route B: learner-created external table

Required permissions are:

- `bigquery.jobs.create` in your assigned project (typically **BigQuery Job User**);
- `bigquery.tables.create`, `bigquery.tables.getData`, `bigquery.tables.update`, and `bigquery.tables.updateData` on the `day4_external` dataset (typically **BigQuery Data Editor**);
- `bigquery.datasets.create` only if the instructor has not already created the dataset;
- `storage.buckets.get`, `storage.objects.get`, and `storage.objects.list` on the source bucket (the instructor may supply these through a scoped classroom role; **Storage Object Viewer** covers the object actions);
- `storage.objects.create` only if you must upload the object (typically **Storage Object Creator**).

The BigQuery dataset and Cloud Storage bucket must use compatible locations. Set `TABLE_FQID` in later SQL to `YOUR_ASSIGNED_PROJECT_ID.day4_external.yellow_trip_sample`.

For Route B, set the values supplied by your instructor and check access:

```bash
export PROJECT_ID="YOUR_ASSIGNED_PROJECT_ID"
export BUCKET_NAME="YOUR_DAY4_BUCKET_NAME"

gcloud auth list
gcloud config set project "$PROJECT_ID"
gcloud config get-value project
gcloud storage ls "gs://$BUCKET_NAME/raw/taxi/yellow_trip_sample.csv"
bq show --project_id="$PROJECT_ID" "day4_external"
```

If the object is not present and you have upload permission, use the Cloud Shell **Upload** command to upload `Lab Resources/yellow_trip_sample.csv`. The upload initially lands at `$HOME/yellow_trip_sample.csv`; stage it at the exact path below, then upload it to Cloud Storage:

```bash
mkdir -p "$HOME/day4"
mv "$HOME/yellow_trip_sample.csv" "$HOME/day4/yellow_trip_sample.csv"
export LOCAL_CSV="$HOME/day4/yellow_trip_sample.csv"
test -f "$LOCAL_CSV"

gcloud storage cp "$LOCAL_CSV" \
  "gs://$BUCKET_NAME/raw/taxi/yellow_trip_sample.csv"
```

If the instructor already staged the file at `$HOME/day4/yellow_trip_sample.csv`, skip the `mv` command and begin with `export LOCAL_CSV=...`.

**Stop on `PERMISSION_DENIED`, a missing dataset you cannot create, or a location error.** Switch to Route A if the instructor has granted all three prepared-table permission groups above. If not, use the fully self-contained **No-Permission Observation Fallback** below and complete every prediction and decision question.

## Part 1 — Inspect the Stored CSV (5 minutes)

Preview the object without downloading the entire file:

```bash
gcloud storage cat \
  "gs://$BUCKET_NAME/raw/taxi/yellow_trip_sample.csv" | head -n 6
```

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

## Part 2 — Review or Create the External Table (8 minutes)

Open **BigQuery > SQL workspace**.

- **Route A:** open `INSTRUCTOR_PROJECT_ID.day4_external.yellow_trip_sample`, review its **Details** and **Schema**, and compare its source URI and options with the statement below. Do not run the `CREATE OR REPLACE` statement.
- **Route B:** replace `PROJECT_ID` and `BUCKET_NAME`, then run the statement.

```sql
CREATE OR REPLACE EXTERNAL TABLE `PROJECT_ID.day4_external.yellow_trip_sample`
OPTIONS (
  format = 'CSV',
  uris = ['gs://BUCKET_NAME/raw/taxi/yellow_trip_sample.csv'],
  skip_leading_rows = 1
);
```

No column list appears between the table name and `OPTIONS`. For this supported CSV external-table DDL, omitting that schema tells BigQuery to autodetect column names and types from the source. `autodetect` is not an option in this GoogleSQL statement.

If `day4_external` does not exist and you have dataset-creation permission, create it in the Console in the instructor-specified location, then rerun the statement. Do not guess the location.

**Before running:** What do the three options control, and what omitted DDL element causes schema autodetection? `________________________________________`

**After running or reviewing:** Record the schema shown by BigQuery.

| Column | BigQuery type | Does it match your prediction? |
| :--- | :--- | :--- |
| `PULocationID` |  |  |
| `fare_amount` |  |  |
| `trip_date` |  |  |

Checkpoint: the CSV did not gain a stored database schema. BigQuery inferred and saved table metadata, then will apply that metadata while reading the object.

## Part 3 — Run the Supplied Queries (9 minutes)

Replace `TABLE_FQID` in both queries with the exact Route A or Route B FQID, leaving the backticks in place.

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

## Part 4 — Compare the Scan Signal and Limitations (4 minutes)

Complete the comparison:

| Observation | Query A | Query B |
| :--- | :--- | :--- |
| Rows returned |  |  |
| Bytes processed |  |  |
| Did fewer output rows guarantee fewer input bytes? |  |  |

For external tables, the validator/dry-run value may be `0 B`, unavailable, or a lower bound; do not treat it as the actual scan. The completed job's **bytes processed** is the primary observation. Bytes processed is still not a complete price quote: cache state, billing minimums, and the pricing model can make bytes billed differ.

Compare the two limitations you recorded. Which one would matter most for a repeated production workload, and why? `________________________________________`

Examples to consider: CSV is row-oriented; autodetection can infer an unwanted type; malformed or changed files can break a stable interpretation; repeated external queries can be slower than queries against optimized managed tables.

## Part 5 — External or Loaded Curated Table? (3 minutes)

Use this decision rule:

- **Query in place** when data is exploratory, infrequently queried, shared with another engine, or not yet ready for curation.
- **Load or transform into a managed warehouse table** when queries repeat, performance matters, governance requires a stable schema, or downstream BI depends on consistent results.

Choose one option for each case and give one reason:

1. A new partner CSV needs a one-time quality check: **external / loaded**, because `____________________`.
2. A daily executive dashboard needs predictable performance and stable fields: **external / loaded**, because `____________________`.

BigQuery external tables and Amazon Athena both support serverless SQL over external data and expose scan-related cost signals. They are not the same service: **BigQuery is also a managed analytical data warehouse**, while **Athena primarily queries data in Amazon S3 and other supported sources**.

## No-Permission Observation Fallback

Use this section only when you cannot inspect or query the classroom resources. Treat the schema and rows as representative evidence from the supplied CSV. Because no query job ran on this route, it does not invent an actual bytes-processed value.

### Representative external-table definition and schema

| Setting | Representative value |
| :--- | :--- |
| Source URI | `gs://CLASS_BUCKET/raw/taxi/yellow_trip_sample.csv` |
| Format | CSV |
| Header rows skipped | 1 |
| Schema mode | Autodetected because the DDL omits a column list |

| Column | Representative inferred type |
| :--- | :--- |
| `PULocationID` | `INT64` |
| `fare_amount` | `FLOAT64` |
| `trip_date` | `DATE` |

### Representative query output

Query A begins with the ten rows shown below:

```text
161 | 14.50 | 2025-01-15
162 |  9.25 | 2025-01-15
163 | 22.00 | 2025-01-16
164 | 11.75 | 2025-01-16
236 | 18.30 | 2025-01-17
237 |  7.50 | 2025-01-17
238 | 25.00 | 2025-01-18
239 | 12.00 | 2025-01-18
142 | 16.80 | 2025-01-19
143 |  8.90 | 2025-01-19
```

Top three rows from Query B:

| `trip_date` | `trip_count` | `total_fare` |
| :--- | ---: | ---: |
| 2025-01-23 | 2 | 38.50 |
| 2025-01-18 | 2 | 37.00 |
| 2025-01-21 | 2 | 34.40 |

### Representative per-query observations

| Query | Result schema | Pre-run estimate observation | Post-run actual bytes processed | Example external-CSV limitation |
| :--- | :--- | :--- | :--- | :--- |
| Query A: ordered preview | `PULocationID INT64`, `fare_amount FLOAT64`, `trip_date DATE` | May be `0 B`, unavailable, or a lower bound for external data. | `Not available — fallback evidence used; no job ran.` | `LIMIT` reduces returned rows, but does not guarantee fewer CSV bytes read. |
| Query B: aggregation | `trip_date DATE`, `trip_count INT64`, `total_fare FLOAT64` | May be `0 B`, unavailable, or a lower bound for external data. | `Not available — fallback evidence used; no job ran.` | A row-oriented CSV cannot provide the same column-pruning benefit as a columnar format, and every row must be interpreted for this aggregation. |

Now complete all prediction questions, record a schema observation, bytes observation, and limitation for **each** query, and make both architecture choices in Part 5. Mark the submission as **fallback evidence used**.

## Submission and Recap (3 minutes)

Submit one Markdown file or form response containing:

1. the four concept-checkpoint answers;
2. the observed or fallback schema;
3. Query A and B results, each with a result-schema and bytes-processed observation;
4. one external-CSV limitation for each query, plus the Part 4 comparison;
5. both Part 5 decisions and reasons;
6. `live execution`, `prepared table`, or `fallback evidence used`.

## Success Criteria

- You can point to the URI, format, header rule, and schema as the metadata needed for schema-on-read.
- Both supplied queries have observed or fallback result-schema and bytes notes.
- Each query has a limitation that describes external CSV behavior rather than a SQL syntax issue.
- Your external-versus-loaded choices use workload needs, not vendor preference.

# Instructor Answer Key

1. **Concept checkpoint:** the Cloud Storage URI; CSV; a declared or inferred schema; and one header row to skip.
2. **File inspection:** comma delimiter, header present, and plausible inferred types `INT64`, `FLOAT64`, and `DATE`. A nonnumeric `fare_amount` can cause inference drift, a null/error depending on schema and parsing options, or inconsistent results across files.
3. **Definition metadata:** `uris` locates the object, `format` identifies CSV, and `skip_leading_rows` excludes the header from data rows. The omitted column list causes BigQuery to autodetect the external schema; there is no `autodetect` option in this GoogleSQL DDL.
4. **Query A:** deterministically returns the first ten rows ordered by `trip_date`, then `PULocationID`, with source columns `PULocationID INT64`, `fare_amount FLOAT64`, and `trip_date DATE`. `LIMIT` controls output, but a row-oriented external CSV may still require scanning the file; this is an appropriate Query A limitation.
5. **Query B:** returns `trip_date DATE`, `trip_count INT64`, and `total_fare FLOAT64`. All rows contribute. The greatest total is `38.50` on `2025-01-23`; the next totals are `37.00` on `2025-01-18` and `34.40` on `2025-01-21`. A suitable Query B limitation is that every row must be interpreted for the aggregation and CSV does not offer columnar pruning.
6. **Bytes:** an external-table validator/dry run may show `0 B`, no estimate, or a lower bound. Grade the completed job's **Job information > bytes processed** as the primary live observation. For the no-execution fallback, accept `Not available — fallback evidence used`; never substitute a fabricated actual value. Do not grade bytes processed as though they equal bytes billed.
7. **Other accepted limitations:** schema inference/drift, malformed-row sensitivity, weaker repeated-query performance, or dependency on the external object's availability and permissions. Require one relevant limitation after each query; the same limitation may be used twice only when the learner explains its relevance to both.
8. **Decisions:** the one-time partner quality check is a strong external-table case; the repeated executive dashboard is a strong loaded/curated managed-table case.

## Official References

- [BigQuery external tables](https://docs.cloud.google.com/bigquery/docs/external-tables)
- [Query Cloud Storage data with BigQuery](https://docs.cloud.google.com/bigquery/docs/external-data-cloud-storage)
- [BigQuery locations](https://docs.cloud.google.com/bigquery/docs/locations)
