# Week 1 · Day 4 Stretch: Query Files in Place with Athena (AWS Mirror)

**Duration:** ~35 min  
**Format:** Individual stretch, for students who finished the GCS landing-zone lab early  
**Prerequisites:** Course **AWS account** and the AWS console. You create the S3 bucket `techcatalyst-de-2026-<your-username>-aws` in Part 1; no prior S3 step is required.

***

> [!NOTE]
> **This whole lab lives in the AWS Console** — you upload the file in the S3 console and query it in the Athena query editor (a web UI). There are no `aws` CLI commands here. The only thing you type is the SQL, and typing it is the point. (Athena's editor *is* the portal way to query; the CLI/SDK come later in the program.)

## Why this stretch

In the main lab you stored files in object storage. In the BigQuery Sandbox lab (Day 2) you queried data and watched a **cost meter** ("bytes processed"). This stretch joins those two ideas **on the other cloud**: you'll query a CSV that's sitting **in place in S3**, no database to load, using **Amazon Athena**, and watch *its* cost meter ("**Data scanned**").

The takeaway is multicloud literacy: BigQuery and Athena rhyme. Both run serverless SQL over data sitting in object storage, and both expose a per-byte-scanned cost signal you should watch. They are not the same service, though: BigQuery is also a managed data warehouse, while Athena queries data in place in S3 and other supported sources. Same core idea (serverless query over object storage), different role in each platform. This is the GCP and AWS translation from Day 2, made real with your own hands.

> [!WARNING]
> **AI-Free Zone (Weeks 1 to 4).** No Amazon Q / Copilot / LLM SQL generation. Type the DDL yourself, it's short, and reading the column definitions *is* the lesson.

> [!NOTE]
> **Cost:** Athena bills **per data scanned** (about $5 per TB). The file here is a few KB, so this costs effectively nothing, but the *habit* of watching "Data scanned" is what you're building.

***

## The data

You'll use the **NYC taxi zone lookup**, a real dimension table your team will need for the taxi pipeline (it maps `LocationID` → borough + zone). Download it once:

- **taxi_zone_lookup.csv** → https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv

Columns: `LocationID` (int), `Borough` (string), `Zone` (string), `service_zone` (string). Row 1 is a header.

## Part 1: Land the file in S3 (5 min)

1. Create the S3 bucket `techcatalyst-de-2026-<your-username>-aws` (or use the one your instructor assigned), then create **two** separate top-level prefixes (folders) in it with **Create folder**: `taxi_zones/` (the data) and `athena-results/` (where Athena writes query output — kept separate on purpose; see Part 2). A folder name can't contain `/`, so make each one separately.
2. Upload `taxi_zone_lookup.csv` into `s3://<your-bucket>/taxi_zones/` — and put **nothing else** in that prefix.

> [!TIP]
> Keep the CSV in its **own prefix** with nothing else in it. Athena reads **every object under the table's `LOCATION`**, so a folder with stray files will break or pollute your query.

## Part 2: Point Athena at it (15 min)

3. Open **Athena** in the AWS console. The landing page now offers **two** choices:

   - **Query your data in Amazon SageMaker Unified Studio** — the newer unified analytics experience. **Not** what we want today.
   - **Query your data in Athena** — *"Use Query editor to analyze data on S3, on premises, or on other clouds."* **Choose this one**, then open the **Query editor**.

   **Set the query-result location (one-time).** The editor shows a banner: *"Before you run your first query, you need to set up a query result location in Amazon S3."* Click **Edit settings** → under **Query result settings** click **Manage** → **Browse S3**, pick your bucket, then select the **`athena-results/`** prefix you created in Part 1 → **Choose** → **Save**. The picker won't *create* a folder — that's why you made `athena-results/` in S3 first.

   > [!IMPORTANT]
   > Athena writes a result file (and a small binary `.metadata` file) **for every query** to this location. It must be a **separate prefix from your data** — never `taxi_zones/`, and never the bucket root if your data sits there. Pointing results at (or overlapping) the data prefix is the **#1 cause of the garbled-output bug** in the Hints below.

   Back in the **Editor**, the left panel shows **Data source: AwsDataCatalog** (correct — that's the Glue Data Catalog) and a **Database** that may default to a sample like `sagemaker_sample_db`. You'll create your own database next and select it there.

4. In the query editor, create a database:

   ```sql
   CREATE DATABASE IF NOT EXISTS techcatalyst_<yourname>;
   ```

   Then select it in the **Database** dropdown on the left (replacing `sagemaker_sample_db` or whatever was pre-selected). Every statement after this runs against your database.
5. Define a table **over the file in place**, no data is copied, you're just describing what's already in S3:

   ```sql
   CREATE EXTERNAL TABLE IF NOT EXISTS taxi_zones (
     LocationID INT,
     Borough STRING,
     Zone STRING,
     service_zone STRING
   )
   ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
   WITH SERDEPROPERTIES ('separatorChar' = ',', 'quoteChar' = '"')
   LOCATION 's3://<your-bucket>/taxi_zones/'
   TBLPROPERTIES ('skip.header.line.count' = '1');
   ```

   **Q1:** Nothing got "loaded" anywhere. What does `EXTERNAL` + `LOCATION` mean about *where the data lives* versus *where the table definition lives*?

## Part 3: Query + the cost meter (10 min)

6. Run a first query and **read the "Data scanned" figure** under the results:

   ```sql
   SELECT Borough, COUNT(*) AS zones
   FROM taxi_zones
   GROUP BY Borough
   ORDER BY zones DESC;
   ```

   **Q2:** How many zones per borough? How much **data was scanned**? (It'll be tiny, note the number anyway.)
7. Run a `SELECT *` and compare:

   ```sql
   SELECT * FROM taxi_zones;
   ```

   **Q3:** Did `SELECT *` scan more than the grouped query? Connect this to the **exact same lesson** from the BigQuery Sandbox lab, what's the one-sentence rule about scanning columns you don't need? (CSV is row-based so the difference is small here; on **Parquet**, your taxi trip format, column pruning is huge. That's why your pipeline lands Parquet, not CSV.)

***

## Worksheet

Append **Q1 to Q3** to your `day4_lab.md`, plus this one-liner:

**Q4 (the multicloud point):** In one or two sentences, state the idea BigQuery and Athena share, and one way they differ. Shared: both run ______ SQL over data in ______ storage and bill per ______ scanned. Different: BigQuery is also a ______ (it stores and optimizes data internally), while Athena only ______ (it queries files that live in S3).

> [!NOTE]
> Be careful with strict one-to-one mappings. As a managed warehouse, BigQuery's closest AWS counterpart is **Amazon Redshift**, not Athena. Athena's closest GCP analogs are query-in-place services such as **BigLake / BigQuery Omni** or **Dataproc Serverless**. The clean parallel today is the shared pattern (serverless SQL over object storage, billed per byte scanned), not a product-for-product swap.

## Success Criteria

- [ ] CSV uploaded to its own `taxi_zones/` prefix in S3
- [ ] Athena query-result location set to a *separate* prefix
- [ ] `taxi_zones` external table created (no data copied)
- [ ] Both queries ran; you recorded the **Data scanned** figure
- [ ] Q1 to Q4 in `day4_lab.md`

## Hints

<details>
<summary>Hint 0: results start correct, then turn into binary/garbled rows (each counted once)</summary>

The clean rows (Manhattan, Queens, Brooklyn…) are your CSV; the garbled lines are Athena reading a **non-CSV object that also lives under the table's `LOCATION`**. Athena scans **every** object under `taxi_zones/`, and the OpenCSV SerDe parses any bytes it finds as text rows — so a binary file shows up as junk "Borough" values, each counted once.

The usual culprit is **Athena's own output**: a query-result `.csv` *and* a binary `.csv.metadata` file got written **into the data prefix** because the **query-result location was set to `taxi_zones/`** (or a prefix that overlaps it). Fix it:

1. **Settings → Manage** → set **Location of query result** to `s3://<your-bucket>/athena-results/` (a prefix that is **not** under `taxi_zones/`). Save.
2. In the S3 console, open `taxi_zones/` and **delete everything that isn't `taxi_zone_lookup.csv`** — any `*.csv`, `*.metadata`, result files, or stray uploads.
3. Re-run the query. The `taxi_zones/` prefix must contain **only** your one CSV.
</details>

<details>
<summary>Hint 1: "HIVE_BAD_DATA" or wrong values / header showing as a row</summary>

You probably missed `TBLPROPERTIES ('skip.header.line.count' = '1')`, or the OpenCSV SerDe line. The OpenCSV SerDe also reads every column as text, if `LocationID` looks odd, that's expected with this SerDe; the lesson is the query + cost, not perfect typing.
</details>

<details>
<summary>Hint 2: "Query results location not set"</summary>

Athena → **Settings** → **Manage** → set "Location of query result" to `s3://<your-bucket>/athena-results/`. Save, then re-run.
</details>

<details>
<summary>Hint 3: Table returns 0 rows or an error about the location</summary>

Check the `LOCATION` is the **prefix/folder** (`.../taxi_zones/`), not the file itself, and that the CSV is the only object under it.
</details>

## Stretch-of-the-stretch

- Re-upload the CSV converted to **Parquet** under a `taxi_zones_parquet/` prefix, define a second table over it, run the same `GROUP BY`, and compare **Data scanned**. This is the single clearest demo of why columnar formats win, and it foreshadows Week 5 (Parquet/Delta/Iceberg).
- Want JOIN practice too? Continue to [Activity_5_Athena_Joins.md](Activity_5_Athena_Joins.md) (~45 min).

## Cleanup

```sql
DROP TABLE IF EXISTS taxi_zones;
-- DROP DATABASE techcatalyst_<yourname>; -- only if you are done with Athena for now
```

The `taxi_zone_lookup.csv` in S3 can stay, your team will need it for the taxi pipeline later.
