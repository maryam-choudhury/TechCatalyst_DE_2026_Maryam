# Week 1 · Day 4 Optional: Athena JOINs on NYC Taxi Data

**Duration:** ~45 min  
**Format:** Individual optional, after [Activity_4_Athena_Query_in_Place.md](Activity_4_Athena_Query_in_Place.md)  
**Prerequisites:** Course **AWS account**, S3 bucket `techcatalyst-de-2026-<your-username>-aws`, Athena query-result location already set

> [!NOTE]
> You define both table schemas by hand with `CREATE EXTERNAL TABLE`. Auto-discovery tools like AWS Glue Crawler come later in the program, here you practice schema-on-read by typing the column definitions yourself.

> [!WARNING]
> **AI-Free Zone (Weeks 1 to 4).** Type the DDL yourself.

> [!NOTE]
> **All in the AWS Console:** upload the files in the S3 console, run everything else in the Athena query editor. No `aws` CLI here — the only thing you type is SQL.

***

## Resource naming

Use these names consistently:

| Resource | Name |
| :--- | :--- |
| S3 bucket | `techcatalyst-de-2026-<your-username>-aws` |
| Athena database | `techcatalyst_<yourname>` |
| Query results prefix | `s3://techcatalyst-de-2026-<your-username>-aws/athena-results/` |
| Zone data prefix | `s3://techcatalyst-de-2026-<your-username>-aws/taxi_zones/` |
| Trip sample prefix | `s3://techcatalyst-de-2026-<your-username>-aws/trip_sample/` |

Use the **primary** Athena workgroup and set your query-result location once under **Settings** if you have not already.

***

## What you will do

The stretch lab queries one file in place. This optional lab adds a **JOIN across two files** in S3, still no data loaded into a database.

- **Dimension:** `taxi_zone_lookup.csv` (borough + zone names)
- **Fact sample:** `yellow_trip_sample.csv` (pickup location + fare, 20 rows in `Lab Resources/`)

***

## Part 1: Land both files (~10 min)

Use the bucket from the S3 mirror / Athena stretch.

1. Download the zone lookup (if you have not already):

   ```
   https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv
   ```

2. Copy the trip sample from the course repo: `Lab Resources/yellow_trip_sample.csv`

3. Upload each file to its **own prefix** (Athena reads everything under `LOCATION`):

   ```
   s3://techcatalyst-de-2026-<your-username>-aws/taxi_zones/taxi_zone_lookup.csv
   s3://techcatalyst-de-2026-<your-username>-aws/trip_sample/yellow_trip_sample.csv
   ```

4. Confirm Athena's query-result location is a **separate** prefix (e.g. `s3://.../athena-results/`). Never point results at your data prefixes — pointing results at `taxi_zones/` or `trip_sample/` makes Athena scan its own output as rows (the garbled-output bug from [Activity 4](Activity_4_Athena_Query_in_Place.md), Hint 0).

## Part 2: Create both external tables (~15 min)

5. Open **Athena** → Query editor. (First time in Athena? On the landing page choose **Query your data in Athena** — *not* SageMaker Unified Studio — then set the query-result location to your `athena-results/` prefix; see [Activity 4](Activity_4_Athena_Query_in_Place.md), Part 2.) In the left panel, select database `techcatalyst_<yourname>` (create it first if you skipped the stretch; the dropdown may default to a sample like `sagemaker_sample_db`).

6. Create the **zones** table (skip if you already created `taxi_zones` in the stretch, just verify it exists):

   ```sql
   CREATE EXTERNAL TABLE IF NOT EXISTS taxi_zones (
     LocationID INT,
     Borough STRING,
     Zone STRING,
     service_zone STRING
   )
   ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
   WITH SERDEPROPERTIES ('separatorChar' = ',', 'quoteChar' = '"')
   LOCATION 's3://techcatalyst-de-2026-<your-username>-aws/taxi_zones/'
   TBLPROPERTIES ('skip.header.line.count' = '1');
   ```

7. Create the **trips** table:

   ```sql
   CREATE EXTERNAL TABLE IF NOT EXISTS yellow_trip_sample (
     pulocationid INT,
     fare_amount DOUBLE,
     trip_date STRING
   )
   ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
   WITH SERDEPROPERTIES ('separatorChar' = ',', 'quoteChar' = '"')
   LOCATION 's3://techcatalyst-de-2026-<your-username>-aws/trip_sample/'
   TBLPROPERTIES ('skip.header.line.count' = '1');
   ```

   **Q1:** You now have two tables pointing at two S3 prefixes. Where does Athena store the table *definitions*? (Hint: not in S3 next to the CSVs.)

8. Sanity-check each table:

   ```sql
   SELECT * FROM taxi_zones LIMIT 5;
   SELECT * FROM yellow_trip_sample LIMIT 5;
   ```

## Part 3: JOIN + cost meter (~15 min)

9. Run a JOIN, pickups by borough:

   ```sql
   SELECT
     z.Borough,
     COUNT(*) AS trips,
     ROUND(SUM(t.fare_amount), 2) AS total_fares
   FROM yellow_trip_sample t
   JOIN taxi_zones z ON t.pulocationid = z.LocationID
   GROUP BY z.Borough
   ORDER BY total_fares DESC;
   ```

   **Q2:** How many boroughs appear? Record the **Data scanned** figure Athena shows after the query.

10. Run a single-table version for comparison:

    ```sql
    SELECT COUNT(*) AS trips, ROUND(SUM(fare_amount), 2) AS total_fares
    FROM yellow_trip_sample;
    ```

    **Q3:** Did the JOIN scan more data than the single-table query? In one sentence, why do JOINs over object storage cost more than filtering one file?

**Q4:** What AWS service catalog would auto-generate these table definitions from S3 files if you did not write the DDL yourself? (One phrase is enough, you will use catalog and governance tools later in the program.)

## Success criteria

- [ ] Both CSVs in separate S3 prefixes
- [ ] Both external tables created manually
- [ ] JOIN query ran; **Data scanned** recorded for Q2 and Q3
- [ ] Q1 to Q4 appended to `day4_lab.md`

## Cleanup

```sql
DROP TABLE IF EXISTS yellow_trip_sample;
-- Keep taxi_zones if your team will reuse it; otherwise:
-- DROP TABLE IF EXISTS taxi_zones;
```