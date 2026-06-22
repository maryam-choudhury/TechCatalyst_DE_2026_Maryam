# Week 1 · Day 4 — Student Resources

> **AI-Free Zone (Weeks 1–4):** Type the `gcloud storage` commands yourself and read the errors (especially the AccessDenied one — that error *is* the lesson). The required query lab supplies its SQL so you can focus on prediction and observation.

Reference links for today's data-at-rest work. Keep these open in tabs during the labs.

## Required Activity Order

1. [Cloud Object Storage Landing-Zone Lab](Activity_Cloud_Object_Storage.md) — required core lab, 100 minutes
2. [Query Files in Place with BigQuery](Activity_Query_in_Place_with_BigQuery.md) — required guided lab, 40 minutes
3. Team storage-convention activity in the landing-zone lab — required, 45 minutes
4. [Query Files in Place with Athena](Activity_Stretch_Athena_over_S3.md) — optional AWS mirror
5. [Athena JOINs](Activity_Optional_Athena_Joins.md) — optional SQL extension
6. [Bucket Lock and Retention](Activity_Optional_Bucket_Lock.md) — optional compliance extension

Use the BigQuery lab's no-permission fallback when the assigned account cannot inspect or query the prepared resources. The Athena and Bucket Lock activities are extensions, not substitutes for required work.

## Core Documentation

| Resource | Why it helps |
| :--- | :--- |
| [GCS documentation home](https://cloud.google.com/storage/docs) | The authoritative reference — How-to guides cover every lab step |
| [Storage classes](https://cloud.google.com/storage/docs/storage-classes) | Standard vs Nearline vs Coldline vs Archive — read before lifecycle rules |
| [Lifecycle management](https://cloud.google.com/storage/docs/lifecycle) | Configure transitions/deletions; compare the JSON to the console UI |
| [Uniform bucket-level access](https://cloud.google.com/storage/docs/uniform-bucket-level-access) | Why uniform access is the right default — enforced org-wide at The Hartford |
| [`gcloud storage` CLI reference](https://cloud.google.com/sdk/gcloud/reference/storage) | Every subcommand you'll run in Part 2 |
| [BigQuery external tables](https://docs.cloud.google.com/bigquery/docs/external-tables) | How table metadata points to data stored outside BigQuery |
| [BigQuery over Cloud Storage](https://docs.cloud.google.com/bigquery/docs/external-data-cloud-storage) | Supported formats, setup, locations, and external-query behavior |

---

## Google Cloud Storage

**GCS documentation home**
https://cloud.google.com/storage/docs
The authoritative reference. The "How-to guides" section covers every operation in today's lab.

**Storage classes explained**
https://cloud.google.com/storage/docs/storage-classes
When to use Standard vs Nearline vs Coldline vs Archive, including the minimum storage duration and retrieval fee for each. Read before writing lifecycle rules.

**Lifecycle management**
https://cloud.google.com/storage/docs/lifecycle
How to configure automatic transitions and deletions. Includes the JSON format — compare it to what the console UI generates when you set a rule.

**Object versioning**
https://cloud.google.com/storage/docs/object-versioning
How generations work, how to list them, and how to restore. The `gcloud storage ls -a` output makes more sense after reading the "Listing object versions" section.

**Uniform bucket-level access**
https://cloud.google.com/storage/docs/uniform-bucket-level-access
Why uniform access is the right default (and why per-object ACLs create audit headaches). The Hartford enforces this org-wide — now you know why.

**Signed URLs**
https://cloud.google.com/storage/docs/access-control/signed-urls
How to create time-limited links to objects without giving someone an IAM role. Useful for sharing data with vendors or external auditors.

---

## The `gcloud storage` CLI

**`gcloud storage` reference**
https://cloud.google.com/sdk/gcloud/reference/storage
Every subcommand: `buckets`, `cp`, `ls`, `rm`, `mv`, `sign-url`, etc. Bookmark the `buckets create` and `cp` pages — you'll use them constantly.

**Quick reference — commands you'll use today:**

```bash
# Create a bucket
gcloud storage buckets create gs://BUCKET_NAME \
  --location=us-east1 \
  --uniform-bucket-level-access

# Upload a file (with prefix)
gcloud storage cp FILE.parquet gs://BUCKET_NAME/raw/2026/06/

# List recursively with sizes
gcloud storage ls -l gs://BUCKET_NAME/raw/**

# List all object versions (when versioning is on)
gcloud storage ls -a gs://BUCKET_NAME/OBJECT_NAME

# Copy between buckets
gcloud storage cp gs://SOURCE_BUCKET/PREFIX/* gs://DEST_BUCKET/staging/

# Enable versioning
gcloud storage buckets update gs://BUCKET_NAME --versioning

# Delete a specific generation
gcloud storage rm gs://BUCKET_NAME/OBJECT_NAME#GENERATION_NUMBER
```

---

## GCS ↔ S3 comparison

**Official AWS-to-GCS migration guide**
https://cloud.google.com/storage/docs/aws-simple-migration
Google's own comparison of GCS and S3 concepts, CLI commands, and permission models. Use this for the stretch activity.

**S3 storage class comparison**
https://aws.amazon.com/s3/storage-classes/
The S3 equivalent of the GCS storage classes table. Standard / Standard-IA / Glacier Instant / Glacier Flexible / Glacier Deep Archive → map these to their GCS counterparts.

---

## Bucket naming and design

**GCS bucket naming requirements**
https://cloud.google.com/storage/docs/buckets#naming
Global uniqueness, character restrictions, and conventions. The course convention is `techcatalyst-de-2026-<your-username>-raw` and `techcatalyst-de-2026-<your-username>-processed`.

**Organizing data with prefixes (best practices)**
https://cloud.google.com/storage/docs/best-practices#naming
Why `year=2026/month=06/` prefix style (Hive-compatible partitioning) matters for BigQuery external tables and Spark (you'll see this pay off in Weeks 3 and 5).

---

## Retention and compliance context

**Data retention at The Hartford (general awareness)**
Insurance companies operate under state and federal data retention requirements. A Cloud Storage **retention policy** enforces a minimum retention period; **Bucket Lock** makes that policy irreversible when a formally approved compliance requirement calls for it. Archive storage and lifecycle rules manage access patterns and cost, but they do not enforce minimum retention. Any lifecycle deletion rule must be configured so it cannot delete regulated data before the required retention period expires.

---

## Day 4 Glossary

| Term | Concise meaning |
| :--- | :--- |
| **external table** | Table metadata whose underlying data remains outside the query engine's managed storage, such as a BigQuery table over Cloud Storage objects. |
| **schema-on-read** | Applying a declared or inferred structure when data is read rather than enforcing it when the file first lands. |
| **prefix** | The leading part of an object name used to organize and filter objects; it can look like a folder but is part of the name. |
| **lifecycle** | Automated transitions or deletion based on conditions such as object age; commonly discussed as hot, warm, cold, and archive stages. |
| **soft delete** | A recovery control that keeps recently deleted Cloud Storage objects recoverable for a configured period. |
| **versioning** | Retaining noncurrent object generations after overwrite or deletion so an earlier generation can be restored. |
| **retention** | A minimum period during which an object must be kept and cannot be normally deleted or replaced. |
| **data lake** | Scalable storage for varied raw and processed data, often in object storage, before every use is known. |
| **lakehouse** | Lake storage plus table semantics, governance, and reliable update capabilities for analytical workloads. |
| **data warehouse** | Curated, governed analytical tables optimized for SQL, reporting, and repeatable performance. |
| **data mart** | A focused analytical subset for one team, department, or business domain. |

---

## Lab Deliverable Checklist

| ✓ | Deliverable |
| :--- | :--- |
| ☐ | `techcatalyst-de-2026-<your-username>-raw` bucket created (region, uniform access, public access prevention) |
| ☐ | Q1–Q7 answered in `day4_lab.md` (including the AccessDenied explanation) |
| ☐ | Second `-processed` bucket created via CLI; objects copied between buckets |
| ☐ | Lifecycle rule added (Nearline @30d, delete @365d) + the 7-year rewrite saved |
| ☐ | Versioning enabled, original `coffee.jpg` generation restored |
| ☐ | Screenshots of both buckets committed to the course repo |
| ☐ | Required BigQuery query-in-place submission completed (live, prepared-table, or fallback path) |
| ☐ | Team storage convention one-pager completed |
| ☐ | (Optional) Athena, Athena JOINs, or Bucket Lock extension completed |
