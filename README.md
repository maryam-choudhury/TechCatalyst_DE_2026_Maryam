# TechCatalyst DE 2026: Proposed Curriculum

This repository documents the proposed 8-week Data Engineering Bootcamp curriculum for **TechCatalyst DE 2026**, with a stronger focus on **Google Cloud (GCP)**, **dbt**, and **Looker**.

---

## Week 1 — Data & Cloud Foundations

**Theme:** Set the stage — what is data engineering and why does cloud matter?

| Day   | Topics                                                       |
| ----- | ------------------------------------------------------------ |
| Day 1 | Data Primer: Types of data, data pipelines, the modern data stack, roles in DE |
| Day 2 | Cloud Fundamentals: IaaS/PaaS/SaaS, GCP vs AWS conceptual overview, IAM, billing |
| Day 3 | DataOps: CI/CD for data, data quality principles, observability, version control intro |
| Day 4 | Hands-on Lab: Spin up GCP project, navigate GCP console, explore Cloud Storage vs S3 |
| Day 5 | Review + Mini-project: Design a simple data flow diagram using Draw.io |

**Deliverable:** Conceptual data pipeline design doc

---

## Week 2 — Architecture, Linux, Python & GenAI Intro

**Theme:** Developer foundations — how data engineers actually work day-to-day

| Day   | Topics                                                       |
| ----- | ------------------------------------------------------------ |
| Day 1 | Fundamentals of Data Architecture: Batch vs Streaming, Lambda/Kappa architectures, medallion architecture |
| Day 2 | Introduction to Linux/Terminal: Shell basics, file system, pipes, grep, cron |
| Day 3 | **GitHub Fundamentals** (alongside Linux): git init/clone/commit/push, branches, PRs, GitHub UI |
| Day 4 | Data Integration with Python: pandas, requests, REST APIs; intro to GenAI libraries (LangChain, google-generativeai, OpenAI SDK) at a high level |
| Day 5 | AWS Orientation (Serverless concepts): Lambda, API Gateway, S3 triggers — conceptual + demo only |

**Deliverable:** Python script that pulls data from a public API and lands it in GCP Cloud Storage

---

## Week 3 — Modern Data Engineering on GCP (Primary) + AWS (Secondary)

**Theme:** Cloud-native data engineering with GCP as the workhorse

| Day   | Topics                                                       |
| ----- | ------------------------------------------------------------ |
| Day 1 | Modern Data Engineering overview: ELT vs ETL, orchestration, data lakehouse |
| Day 2 | **GCP: BigQuery** — datasets, tables, partitioning, clustering, cost optimization (hands-on lab) |
| Day 3 | **GCP: Dataflow** — batch + streaming pipelines with Apache Beam (lab); **Pub/Sub** — event streaming intro (lab) |
| Day 4 | **GCP: Vertex AI** — what it is, managed notebooks, AutoML overview (demo + light lab) |
| Day 5 | **GitHub Collaboration**: branching strategies, merging, PRs, GitHub Actions for automation; AWS Equivalents: Redshift, Glue, SageMaker (demo, no labs) |

**Deliverable:** End-to-end mini-pipeline: Pub/Sub → Dataflow → BigQuery

---

## Week 4 — Snowflake, dbt & Advanced Snowflake ML/AI

> [!note]
> Cover cost vs performance and how to pick the right solution for the right problem.
> Be conscious of the right solution, e.g., compute warehouse sizes and different types of tables.

**Theme:** The warehouse layer — transformation, modeling, and AI-native features

| Day   | Topics                                                       |
| ----- | ------------------------------------------------------------ |
| Day 1 | Introduction to Snowflake: architecture, virtual warehouses, databases, schemas, roles |
| Day 2 | **dbt Core**: models, sources, tests, documentation; dbt + Snowflake integration (hands-on lab) |
| Day 3 | Advanced dbt: incremental models, macros, seeds, snapshots   |
| Day 4 | **Advanced Snowflake (NEW)**: Snowpark, ML features (CLASSIFICATION, ANOMALY_DETECTION), Cortex AI functions |
| Day 5 | Snowflake GenAI: Cortex LLM functions (COMPLETE, SUMMARIZE, TRANSLATE), Document AI; Lab: build an LLM-powered data enrichment pipeline |

**Deliverable:** dbt project on Snowflake with at least one Cortex AI-enriched model

---

## Week 5 — NLP, LLMs, GenAI & GitHub Copilot

**Theme:** AI Engineering in the context of Data Engineering

| Day   | Topics                                                       |
| ----- | ------------------------------------------------------------ |
| Day 1 | GenAI Fundamentals: Generative AI landscape, foundation models, tokenization, embeddings, prompt basics |
| Day 2 | LLM Deep Dive: LLM architecture overview, use cases for data engineers (data cleaning, summarization, schema generation) |
| Day 3 | Applied NLP + Google Vertex AI GenAI: Gemini API, text generation, classification, embeddings via Vertex AI (hands-on lab) |
| Day 4 | Advanced LLM Concepts: Fine-tuning, RAG, Agentic RAG, Agentic AI/Automation — conceptual + demos with LangChain |
| Day 5 | **GitHub Copilot**: setup, modes (inline, chat, agent mode), best practices for DE workflows; **Prompt/Context Engineering** for code generation |

**Deliverable:** LLM-powered pipeline component — e.g., auto-tagging or summarizing ingested records using Gemini/Vertex AI

---

## Week 6 — Governance, Best Practices, Analytics & CI/CD

**Theme:** Production-grade data engineering — quality, governance, and automation

| Day   | Topics                                                       |
| ----- | ------------------------------------------------------------ |
| Day 1 | Data Engineering Best Practices: code quality, testing strategies, documentation standards |
| Day 2 | Data Governance & Cost Management: data cataloging (Dataplex on GCP), access controls, lineage, tagging |
| Day 3 | **GitHub for DE: CI/CD** — GitHub Actions workflows for dbt runs, data tests, auto-deploy pipelines |
| Day 4 | Data Analytics: analytical SQL (window functions, CTEs), building analytical views in BigQuery/Snowflake |
| Day 5 | Presenting Data Visually: principles of data storytelling, choosing the right chart type, audience-first thinking |

**Deliverable:** GitHub Actions workflow that runs dbt tests + deploys on merge to main

---

## Week 7 — BI Tools: Looker, Thoughtspot & Tableau

> [!note]
> There is a chance we may introduce **Strategy**.

**Theme:** From data to decisions — business intelligence and self-service analytics

| Day   | Topics                                                       |
| ----- | ------------------------------------------------------------ |
| Day 1 | **Introduction to Looker** (Primary): LookML basics, explores, dashboards, connecting to BigQuery |
| Day 2 | Looker Lab: build a dashboard from a BigQuery dataset using LookML |
| Day 3 | **Introduction to Thoughtspot**: AI-powered search analytics, connecting to Snowflake/BigQuery, SpotIQ |
| Day 4 | **Working with Tableau**: connecting to data sources, calculated fields, dashboard design best practices |
| Day 5 | A Peek at the Capstone: project brief, dataset reveal, team formation, initial exploration |

**Deliverable:** BI dashboard in Looker connected to BigQuery data from Week 3 pipeline

---

## Week 8 — End-to-End Capstone: Insurance Use Case

**Theme:** Real-world integration of everything — GCP + Snowflake + BI + GenAI

| Day   | Topics                                                       |
| ----- | ------------------------------------------------------------ |
| Day 1 | Capstone Kickoff: Insurance dataset deep-dive, architecture design session, role assignments |
| Day 2 | Pipeline Build Sprint: GCP ingestion layer (Cloud Storage → Dataflow/BigQuery) |
| Day 3 | Transformation Sprint: Snowflake + dbt models, data quality checks, governance tagging |
| Day 4 | Analytics + GenAI Layer: Cortex AI enrichment, Looker/Tableau dashboards |
| Day 5 | **Final Presentations**: end-to-end demo, architecture walkthrough, lessons learned |

**Deliverable:** End-to-end insurance analytics pipeline — GCP ingestion → Snowflake transformation → Looker/Tableau BI, with a GenAI-enriched layer

---

## Technology Stack Summary

| Category       | Primary (GCP-First)                | Secondary (AWS)    |
| -------------- | ---------------------------------- | ------------------ |
| Storage        | Cloud Storage                      | S3                 |
| Warehouse      | **BigQuery** + Snowflake           | Redshift           |
| Pipelines      | **Dataflow, Pub/Sub**              | Glue               |
| AI/ML Platform | **Vertex AI, Cortex AI**           | SageMaker, Bedrock |
| Orchestration  | **dbt** + GitHub Actions           | —                  |
| BI             | **Looker**, Tableau, Thoughtspot   | —                  |
| Coding Tools   | **GitHub Copilot**, **Gemini API** | —                  |
| Languages      | Python, SQL, Bash                  | —                  |
