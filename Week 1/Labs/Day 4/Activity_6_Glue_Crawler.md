# Week 1 · Day 4 Optional: Auto-Discover Schema with an AWS Glue Crawler

**Duration:** ~35–40 min
**Format:** Individual optional / backup, **after** the Athena labs
**Prerequisites:** Course **AWS account**; ideally `Activity_4_Athena_Query_in_Place.md` and/or `Activity_5_Athena_Joins.md` done, so `taxi_zone_lookup.csv` and `yellow_trip_sample.csv` already sit in your `techcatalyst-de-2026-<username>-aws` bucket. (If not, upload them first — Part 0.)

> [!NOTE]
> **Why this lab exists.** In the Athena labs you wrote `CREATE EXTERNAL TABLE` **by hand**. A **Glue Crawler** does that *for* you: it scans your S3 files, infers the schema, and writes the table into the **Glue Data Catalog** automatically. This lab shows the Crawler producing the **same table you typed by hand** — then steps back to ask the real question: *when is a Crawler worth it, and when is manual DDL the better call?*

> [!WARNING]
> **AI-Free Zone (Weeks 1 to 4).** This lab is console clicks plus a little SQL — type the SQL yourself. No Amazon Q / Copilot.

---

## 🎯 Goal

By the end you can:

- create and run a **Glue Crawler** that auto-discovers schema from S3 and registers tables in the **Glue Data Catalog**;
- query a crawler-created table in Athena and confirm it matches your hand-written one;
- explain **what Athena actually needs** (a metastore), and **when a Crawler is worth it vs. manual DDL** and other alternatives.

## 🧠 The one idea

**Athena does not query S3 directly out of thin air — it needs a *table definition* (schema + location) in a metastore, the AWS Glue Data Catalog.** You can put a table in that catalog three main ways: write the DDL by hand (the Athena labs), let a **Glue Crawler** discover it, or use other approaches (partition projection, federation). The Crawler is automation for the *cataloging* step — nothing more, nothing less.

---

## Part 0: Make sure the data is in S3 (skip if you did the Athena labs)

In the **S3 console**, open your `techcatalyst-de-2026-<username>-aws` bucket and upload each file into its **own prefix**:

- `taxi_zone_lookup.csv` → `taxi_zones/`
- `yellow_trip_sample.csv` (from the course repo `Lab Resources/`) → `trip_sample/`

Keeping each file in its own prefix matters: the Crawler catalogs them as **two separate tables**.

> [!NOTE]
> **💻 Also via CLI (optional).** From **AWS CloudShell** (already signed in; won't work in a local or Codespaces terminal unless you set up the `aws` CLI yourself):
>
> ```bash
> export USERNAME="YOUR_SHORT_USERNAME"
> export BUCKET="techcatalyst-de-2026-${USERNAME}-aws"
> aws s3 cp taxi_zone_lookup.csv "s3://${BUCKET}/taxi_zones/taxi_zone_lookup.csv"
> aws s3 cp "Lab Resources/yellow_trip_sample.csv" "s3://${BUCKET}/trip_sample/yellow_trip_sample.csv"
> aws s3 ls "s3://${BUCKET}/" --recursive
> ```

## Part 1: A Glue service role (5 min)

A Crawler runs as an IAM role that can read your S3 data and write to the Glue catalog.

- **Preferred:** your instructor provides a Glue service role ARN (e.g. `AWSGlueServiceRole-TechCatalyst`). Use it and skip to Part 2.
- **If you must create one yourself** (CloudShell), see the **Appendix** at the bottom; it creates `AWSGlueServiceRole-TechCatalyst-<initials>` with read access to your bucket.

## Part 2: Create the Crawler (10 min)

1. Console → **AWS Glue** → left nav **Data Catalog → Crawlers** → **Create crawler**.
2. **Name:** `techcatalyst-<initials>-crawler`. Next.
3. **Data source:** *Not yet* mapped to Glue tables → **Add a data source** → **S3** → **In this account**. Point the crawler at your **two data prefixes** (not the whole bucket) — add them as **two** S3 data sources, each with **Crawl all sub-folders**, clicking **Add an S3 data source** after each:

   - `s3://techcatalyst-de-2026-<username>-aws/taxi_zones/`
   - `s3://techcatalyst-de-2026-<username>-aws/trip_sample/`

   Then **Next**.

   > [!IMPORTANT]
   > **Don't point the crawler at the bucket root.** That bucket also holds `athena-results/` (Athena's query output). Crawling the root would catalog those result and binary `.metadata` files as an **extra junk table** — the same "it scans *everything* under the path" trap you saw with the Athena `LOCATION`. Scoping to the two data prefixes avoids it. (If you must use the bucket root, add an **Exclude pattern** of `athena-results/**`.)
4. **IAM role:** select your Glue service role (instructor-provided or your Appendix role). Next.
5. **Output → Add database:** create `techcatalyst_<initials>_db`. Back on the crawler page, refresh and select it as the **Target database**.
6. **Frequency:** **On demand**. Next → **Create crawler**.

**Q1:** The Crawler has not run yet. Where will the **table definitions** it creates be stored — in S3 next to the CSVs, or somewhere else? (Name the service.)

## Part 3: Run it and read the catalog (10 min)

1. Select your crawler → **Run crawler**. Wait for status **Completed** (1–2 min).
2. Left nav **Data Catalog → Tables**. You should see two new tables (named after the prefixes, e.g. `taxi_zones` and `trip_sample`).
3. Open one and inspect the **schema** the Crawler inferred (column names + types) and the **classification** (csv) it detected.

**Q2:** Look at the inferred column **types**. Did the Crawler guess `LocationID` as an integer? Where did it get the column *names* from (hint: the CSV header)?

## Part 4: Query it in Athena and compare to your hand-written table (10 min)

1. Console → **Athena** → Query editor. Set **Database** = `techcatalyst_<initials>_db`.
2. Query the crawler-created table:

   ```sql
   SELECT borough, COUNT(*) AS zones
   FROM taxi_zones
   GROUP BY borough
   ORDER BY zones DESC;
   ```

3. Compare schemas. Run `DESCRIBE` on the **crawler** table and (if you still have it) your **hand-written** table from `Activity_4_Athena_Query_in_Place.md`:

   ```sql
   DESCRIBE taxi_zones;            -- crawler-created
   -- DESCRIBE taxi_zones_manual;  -- your hand-written one, if you renamed it to keep both
   ```

**Q3:** Are the schemas essentially the same? State the lesson in one sentence: a Glue Crawler **automates the creation of** the same _______ that you can also write by hand with `CREATE EXTERNAL TABLE`.

> 💡 The Crawler and your DDL both produce a **Glue Data Catalog table**. The catalog is the metastore; Athena reads it to know *what columns exist and where the files live*. The Crawler just filled it in for you.

---

## 🤔 Do you even need a Crawler? (read this — it's the point)

**Athena never needs Glue *Crawlers*; it needs a *metastore* (the Glue Data Catalog) that tells it column names, types, and file locations.** A Crawler is one way to populate that metastore. The alternatives:

| Approach | What it is | Reach for it when |
| :--- | :--- | :--- |
| **Manual `CREATE EXTERNAL TABLE`** | You write the DDL and point at the S3 prefix (the Athena labs) | Schema is known and stable; one or a few tables; you want full control and zero moving parts |
| **Glue Crawler** | Auto-infers schema and writes/updates catalog tables | **Large/complex datasets, many folders, schemas that change, or new partitions arriving** — the Crawler keeps the catalog current without manual SQL |
| **Partition Projection** | Athena computes partition values from a pattern, no per-partition catalog entries | Highly partitioned data (e.g. `year=/month=/day=/`) where running a crawler or `MSCK REPAIR` on every new partition is painful |
| **Athena Query Federation** | Athena queries RDS, DynamoDB, Redis, etc. via connectors | The data isn't in S3 at all and you don't want to copy it there |

**Rule of thumb for this course:** for a handful of known files (Week 1), **manual DDL** is clearer and teaches you what's really happening. Crawlers earn their keep when the catalog would otherwise be a maintenance burden — many tables, evolving schemas, or a steady stream of new partitions. We use the catalog and discovery tooling for real in **Week 3 (Knowledge Catalog / governance)**.

---

## ☁️ The same pattern on GCP

This isn't an AWS-only idea. GCP has the same two layers:

- **Discovery / catalog:** **BigQuery automatic discovery** (and **Knowledge Catalog**, formerly **Dataplex**) scans **Cloud Storage** and auto-creates **BigLake/external tables** with inferred schema — the direct analog of a Glue Crawler populating the Glue Data Catalog.
- **Query engine over object storage:** **BigQuery** (via external/BigLake tables) queries files **in place** in GCS, just as **Athena** queries files in place in S3.

You met the manual side of this on GCP in `Activity_2_Query_in_Place_with_BigQuery.md` (you defined an external table by hand). The auto-discovery side is the Week 3 governance story.

---

## Success Criteria

- [ ] Crawler created and run to **Completed**
- [ ] Two tables visible in the Glue Data Catalog with inferred schemas
- [ ] Queried a crawler-created table in Athena
- [ ] Can state, in one sentence, what Athena actually needs (a metastore) and one case where a Crawler beats manual DDL
- [ ] Q1–Q3 appended to `day4_lab.md`

## Cleanup

```sql
-- in Athena, drop the crawler-created tables if you won't reuse them
DROP TABLE IF EXISTS taxi_zones;
DROP TABLE IF EXISTS trip_sample;
```

In the Glue console you can also delete the crawler and the `techcatalyst_<initials>_db` database. Leave the S3 files; your team reuses them.

## Hints

<details>
<summary>An extra, unwanted table appeared (e.g. <code>athena_results</code>)</summary>

Your crawler's S3 path included `athena-results/` — almost always because you pointed it at the **bucket root** instead of the two data prefixes. The crawler catalogs Athena's own output (result CSVs + binary `.metadata`) as a table. Fix: re-scope the crawler to just `taxi_zones/` and `trip_sample/` (or add an **Exclude pattern** `athena-results/**`), delete the junk table in the Glue **Tables** list, and re-run.
</details>

<details>
<summary>Crawler finishes but creates 0 tables</summary>

The S3 path must point at a **prefix that contains objects** (or the bucket root with "crawl all sub-folders"). An empty prefix, or pointing at a single file instead of its folder, yields no tables.
</details>

<details>
<summary>Athena can't see the crawler tables</summary>

In the Athena query editor, set the **Database** dropdown to the same `techcatalyst_<initials>_db` you chose as the crawler's target, and make sure your Athena query-result location is set (Settings → Manage).
</details>

<details>
<summary>Column types look wrong (everything a string)</summary>

The Crawler's CSV classifier infers types from sampled values; quoted CSVs or mixed values can make it choose `string`. That's expected — and it's exactly why a known schema is sometimes better defined by hand. The lesson is the *workflow*, not perfect typing.
</details>

---

## Appendix: create a Glue service role yourself (only if not instructor-provided)

In CloudShell (replace `<initials>` and `<bucket>`):

```bash
cat > trust-policy.json <<'EOF'
{ "Version":"2012-10-17",
  "Statement":[{ "Effect":"Allow",
    "Principal":{ "Service":"glue.amazonaws.com" },
    "Action":"sts:AssumeRole" }] }
EOF

cat > s3access-policy.json <<EOF
{ "Version":"2012-10-17",
  "Statement":[{ "Effect":"Allow",
    "Action":["s3:GetObject","s3:ListBucket"],
    "Resource":[
      "arn:aws:s3:::techcatalyst-de-2026-${USERNAME}-aws",
      "arn:aws:s3:::techcatalyst-de-2026-${USERNAME}-aws/*"] }] }
EOF

aws iam create-role --role-name AWSGlueServiceRole-TechCatalyst-<initials> \
  --assume-role-policy-document file://trust-policy.json
aws iam put-role-policy --role-name AWSGlueServiceRole-TechCatalyst-<initials> \
  --policy-name Glue-S3Read --policy-document file://s3access-policy.json
aws iam attach-role-policy --role-name AWSGlueServiceRole-TechCatalyst-<initials> \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole
```

> This grants the Crawler **read** on your bucket plus the managed Glue service policy. Follow least privilege; do not add write/delete it doesn't need.
