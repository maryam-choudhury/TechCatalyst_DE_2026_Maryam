# W1D2 Cloud Fundamentals Deck Update Design

## Objective

Update `Week 1/Slides/W1D2 - Cloud Fundamentals.pptx` so Week 1 learners receive:

- an equal-weight introduction to core data engineering capabilities on Google Cloud and AWS;
- a 25–30 minute conceptual deep dive into Google Cloud Storage and Amazon S3;
- a clear distinction between general-purpose object storage, a governed data lake, and managed Apache Iceberg tables;
- a current, beginner-safe introduction to Amazon S3 Tables and Google Cloud Apache Iceberg managed tables;
- slide-level transitions into the revised BigQuery Sandbox and cloud-architecture activities.

The source deck remains unchanged. Deliver the edited copy as:

`Week 1/Slides/W1D2 - Cloud Fundamentals - Updated.pptx`

## Audience and Scope

- Audience: fresh graduates and junior data engineers on Week 1 Day 2.
- GCP and AWS receive equal visual and instructional weight.
- The service landscape is awareness-level, not product training.
- Object storage receives the only conceptual deep dive.
- BigQuery receives the day's first concrete service experience through Activity 1.
- Detailed SQL, lakehouse implementation, Iceberg internals, and table maintenance remain for later weeks.

## Narrative

Use the approved sequence: **Map → Foundation → Specialization**.

1. Establish the core DE capability map across both clouds.
2. Show how those capabilities form a pipeline.
3. Introduce object storage as the common landing-zone foundation.
4. Compare the common capabilities and meaningful differences of GCS and S3.
5. Explain why a bucket alone is not a complete data lake.
6. Distinguish files/objects from analytical tables.
7. Introduce managed Iceberg options without implying they replace object storage.
8. Move from awareness into the BigQuery Sandbox activity.
9. End with the architecture-scenario synthesis.

## Final Slide Sequence

The source deck has 21 slides. The updated deck has approximately 28 slides.

| Output | Source Pattern | Action |
| ---: | ---: | :--- |
| 1 | 1 | Preserve title slide |
| 2 | 2 | Update agenda for the expanded storage block and Activity 1 → Activity 2 order |
| 3–12 | 3–12 | Preserve existing cloud/service-model content |
| 13 | 13 | Rewrite as equal-weight core DE capability map |
| 14 | 14 | Rewrite as equal-weight cloud data-pipeline capability map |
| 15 | 9 | Add: Object storage is the cloud landing zone |
| 16 | 14 | Add: GCS and S3 share the same foundation |
| 17 | 13 | Add: Meaningful GCS/S3 differences |
| 18 | 14 | Add: A bucket alone is not a data lake |
| 19 | 6 | Add: Objects/files are not analytical tables |
| 20 | 6 | Add: Managed Iceberg on both clouds |
| 21–25 | 15–19 | Preserve IAM/cost section; update console-demo wording where needed |
| 26 | 20 | Add: Activity 1 — BigQuery Sandbox, 60 minutes |
| 27 | 20 | Rewrite: Activity 2 — You're the Architect, 75 minutes |
| 28 | 21 | Update recap to include object storage and managed-table distinctions |

Every output slide must be mapped to and cloned from an existing source slide. New content edits inherited objects rather than overlaying a parallel design.

## New and Revised Slide Content

### Slide 13 — Core DE Capabilities Across Two Clouds

Equal columns, no “primary/secondary” labels.

| Capability | Google Cloud | AWS |
| :--- | :--- | :--- |
| Object storage | Cloud Storage | Amazon S3 |
| Warehouse / serverless SQL | BigQuery | Redshift / Athena |
| Messaging / events | Pub/Sub | Kinesis / SNS / SQS |
| Batch and stream processing | Dataflow | Glue / Kinesis Data Firehose |
| Managed Spark | Dataproc | EMR |
| Orchestration | Cloud Composer | MWAA / Step Functions |
| Catalog and governance | Knowledge Catalog | Glue Data Catalog / Lake Formation |
| AI and ML | Vertex AI / Gemini | SageMaker / Bedrock |

Teaching boundary: learners recognize capabilities and translations; they do not memorize every product.

### Slide 14 — How the Capabilities Form a Pipeline

Show a simple capability flow:

**Sources → ingest/events → object storage → process/transform → warehouse/query → consumers**

IAM, governance/catalog, orchestration, and cost controls span the flow. Use paired GCP/AWS labels with equal visual weight.

### Slide 15 — Object Storage Is the Cloud Landing Zone

Teach:

- bucket/container;
- object = data + metadata;
- key/name and prefix;
- any file format, including CSV, JSON, Parquet, images, and documents;
- elastic capacity and managed durability;
- object storage is not a mounted disk or relational database.

### Slide 16 — GCS and S3 Share the Same Foundation

Six shared capabilities:

1. buckets and objects;
2. storage classes/tiering;
3. IAM and private-by-default access patterns;
4. encryption;
5. lifecycle management;
6. recovery, retention, replication, and event integration.

Avoid claiming implementation equivalence. The mental model is shared; names and controls differ.

### Slide 17 — Meaningful Differences

Compare, without declaring a winner:

- resource hierarchy and policy tools;
- uniform bucket-level access/managed folders versus bucket policies, access points, and Block Public Access;
- GCS Autoclass versus S3 Intelligent-Tiering;
- flat/default namespace behavior and specialized hierarchy options;
- native analytics and operational ecosystem integration;
- terminology and URI formats: `gs://bucket/object` versus `s3://bucket/key`.

### Slide 18 — A Bucket Alone Is Not a Data Lake

Use a progressive model:

- objects and efficient formats;
- deliberate layout/partitioning;
- schema and catalog metadata;
- compute and query engines;
- IAM, governance, quality, lifecycle, and cost controls.

Key line: “Object storage is the foundation; architecture and operating practices make it a usable data lake.”

### Slide 19 — Objects Are Not Analytical Tables

Contrast:

| Files/objects | Analytical table layer |
| :--- | :--- |
| Opaque bytes and metadata | Schema and table metadata |
| Application manages file layout | Table format tracks data files |
| Rewrites can create inconsistency | Atomic commits and snapshots |
| Small files hurt query performance | Compaction and optimization |
| No native table history | Snapshot history / time travel |

Introduce Apache Iceberg as an open table format, not a storage service.

### Slide 20 — Managed Iceberg on Both Clouds

Use the approved equal-comparison treatment.

**AWS S3 Tables**

- specialized S3 table buckets;
- Apache Iceberg tables;
- automated compaction, snapshot management, and unreferenced-file removal;
- Glue Data Catalog integration;
- query through Athena, Redshift, and Iceberg-compatible Spark engines.

**Google Cloud Apache Iceberg managed tables in BigQuery**

- Apache Iceberg table format with data in Cloud Storage;
- automatic storage optimization, including file sizing/clustering, garbage collection, and metadata optimization;
- BigQuery management with open-engine interoperability.

Required callout: “A specialized managed table layer — not a replacement for general-purpose GCS or S3.”

### Slides 26–27 — Activities

Slide 26 introduces `Activity_1_BigQuery_Sandbox_First_Query.md`:

- 60 minutes;
- individual with peer support;
- inspect public Citi Bike data;
- run provided SQL;
- compare bytes processed;
- connect managed infrastructure to cost.

Slide 27 introduces `Activity_2_Cloud_Architecture_Scenarios.md`:

- 75 minutes;
- groups of 3–4;
- assigned primary scenario;
- map capabilities to both clouds;
- identify trigger, cost risk, security/PII control, and rejected alternative;
- five-minute readout with every member contributing.

## Visual Design

Use the source deck as the only visual reference.

- Preserve its red top rail, off-white card fills, dark text, green secondary accent, Trebuchet typography, spacing, footer, and page-number treatment.
- Use equal column widths and equal information density for Google Cloud and AWS.
- Do not use vendor-colored mini-themes as a proxy for equal weight.
- Prefer existing table, two-column, three-step, and six-card source layouts.
- Keep body text at the inherited template size. Split or shorten content rather than shrinking fonts.
- Use native inherited shapes only; no decorative stock imagery is required.

## Speaker Notes

For every new storage slide, add:

1. **Teaching point** — the single mental model learners should retain.
2. **Learner question** — one short prediction or comparison prompt.
3. **Skip/deeper-detail guidance** — what can be skipped when time is short and what belongs in Weeks 3 or 5.
4. **Sources** — official AWS and Google Cloud documentation supporting current product claims.

Preserve existing notes on inherited slides unless the revised slide content makes them stale.

## Sources

Use current official documentation only:

- Amazon S3 overview: https://docs.aws.amazon.com/AmazonS3/latest/userguide/
- S3 general-purpose buckets: https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingBucket.html
- S3 Tables: https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables.html
- S3 Tables maintenance: https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-maintenance.html
- Google Cloud Storage overview: https://docs.cloud.google.com/storage/docs/introduction
- Cloud Storage lifecycle management: https://docs.cloud.google.com/storage/docs/lifecycle
- Cloud Storage object versioning: https://docs.cloud.google.com/storage/docs/object-versioning
- BigQuery Apache Iceberg managed tables: https://docs.cloud.google.com/bigquery/docs/biglake-iceberg-tables-in-bigquery

## QA and Acceptance Criteria

- Final PPTX opens and contains approximately 28 slides.
- Original PPTX remains unchanged.
- Every output slide maps to an inherited source slide.
- No unintended overlap, clipping, overflow, broken wrapping, or unfilled placeholders.
- GCP and AWS receive equal visual weight in overview and storage comparisons.
- S3 Tables is described as specialized managed Iceberg storage, not a replacement for S3.
- GCP's current “Apache Iceberg managed tables” naming is used, with the former BigLake naming omitted from learner-facing copy.
- Agenda, demo, activity order, durations, filenames, and recap match the revised Day 2 labs.
- New product claims are supported by official URLs in speaker notes.
- Every slide is rendered and visually inspected at full size before delivery.
- Template fidelity, final layout inspection, and placeholder checks pass.
