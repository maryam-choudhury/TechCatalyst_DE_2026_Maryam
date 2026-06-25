# Week 1 · Day 4: Cloud Object Storage Landing-Zone Lab — AWS S3 Mirror

**Module:** Data at Rest
**Estimated time:** ~75 minutes
**Difficulty:** Beginner
**Format:** Individual or paired
**Status:** Optional AWS mirror of the required GCS landing-zone lab

> [!NOTE]
> **This is the same lab as `Activity_1_Cloud_Object_Storage.md`, done on AWS S3 instead of Google Cloud Storage.** Same files, same zones, same controls, same questions — only the cloud changes. Do the GCS lab first (it is the required one); use this to *see how the identical design is expressed on AWS*. Wherever it helps, this file points back to the matching GCS step so you can compare them side by side.

> [!NOTE]
> **Same three ways to work, same order.** Like the GCS lab, almost everything here can be done in the **Console** (web portal — visual, labeled, best for learning), the **CLI** (`aws s3` / `aws s3api` — faster once you know what you want), or an **SDK** (Python `boto3` — for automation). **We lead with the Console.** You will create and secure the raw bucket by clicking, then create the processed bucket from the CLI once to feel the difference. Each **💻 Also via CLI** box is optional — try it or skip it without missing the lesson.

> [!NOTE]
> **How to read this lab.**
> - **Numbered steps** are your main path — do them in the **AWS Console** (the web portal). Just follow them in order.
> - A box marked **💻 Also via CLI (optional)** shows the *same action* done by typing commands instead. **You can skip every CLI box and still finish the lab.**
> - **Run CLI boxes in AWS CloudShell, not your local or Codespaces terminal.** Open **AWS CloudShell** (the `>_` icon in the console top bar). It is already signed in to your account and has the `aws` CLI preinstalled, so the commands just work. The same commands will **fail in a local or Codespaces terminal** unless *you* install and configure the AWS CLI there first — we don't set that up today.
> - So when you see a `bash` block: it's optional, and it runs in **CloudShell**.

## Objective

Build and inspect a secure Amazon S3 landing zone. By the end, you can:

- create buckets with **Block Public Access** and **ACLs disabled (Bucket owner enforced)**;
- organize objects into zones and date-based prefixes;
- explain lifecycle and recovery controls without confusing their purposes;
- test authenticated and unauthenticated access safely;
- map every GCS concept from the main lab to its S3 equivalent.

## Files and Deliverables

Use the same files from `Lab Resources/`: `coffee.jpg`, `hartford.jpeg`, and `intro.docx`.

| Deliverable | Required contents | Due |
| :--- | :--- | :--- |
| `day4_s3_lab.md` | Answers to Q1 to Q7, four Predict/Observe responses, the lifecycle rule, and screenshots of the raw and processed buckets | End of day |

### Naming convention

You will type these names into the Console when you create resources (and reuse them in the optional CLI boxes). Replace `<username>` with your short username.

| Resource | Name |
| :--- | :--- |
| Assigned account | `YOUR_ASSIGNED_ACCOUNT_ID` (from your instructor) |
| Region | `us-east-1` |
| Raw bucket | `techcatalyst-de-2026-<username>-raw` |
| Processed bucket | `techcatalyst-de-2026-<username>-processed` |

Bucket names are **globally unique across all of AWS**. If a name is taken, add the short suffix supplied by your instructor.

> [!WARNING]
> **AI-Free Zone (Weeks 1 to 4).** No Amazon Q / Copilot / LLM-generated commands or SQL. Work in the Console, and whenever you do drop into the CLI, type the commands yourself and read the errors (the `AccessDenied` from the anonymous access test is the lesson).

---

# Core Lab: ~75 Minutes

## Part 0: Account and Identity Preflight (10 minutes)

*(Mirrors GCS Part 0. On GCP you confirmed the project; on AWS you confirm the account and region.)*

> [!IMPORTANT]
> Use only your assigned AWS account, and don't change access settings or use a personal account. **If anything in this lab doesn't work, contact your instructor** — it's an environment issue to resolve, not something for you to fix.

Your assigned account already has the access you need. These quick checks just confirm you're in the right place. Do them in the **Console** — every fact is in the top navigation bar.

1. Open the AWS Console and sign in with your **assigned classroom account**.
2. Confirm the readiness conditions from the portal:

   - **Account + identity:** click the **account menu (top-right)**. It shows the **account ID** (match it to your assigned `$AWS_ACCOUNT_ID`) and the role/user you are signed in as — confirm it is your assigned course role, not a personal account.
   - **Region:** the **Region selector (top-right)** shows the assigned lab region (`us-east-1` here). The region matters: buckets and the console view are region-scoped.
   - The instructor confirms your course role can create and manage lab buckets and objects (a scoped S3 access policy).

3. Record the account ID, signed-in role, and region in `day4_s3_lab.md` (a screenshot of the account menu is fine). **Do not record access keys or session tokens.**

> [!NOTE]
> **💻 Also via CLI (optional).** The same identity check from **AWS CloudShell** (the `>_` icon in the console top bar).
>
> **Doing the CLI boxes?** Open CloudShell and paste this block **once** at the start of your session. (Staying in the Console? Skip this entirely.)
>
> **What this block is — and isn't.** It only sets a few **shell variables** (plain text strings) so the later CLI boxes can write `$RAW_BUCKET` instead of making you retype the full name each time. **It does not create or touch anything in AWS** — `export RAW_BUCKET=...` just stores the *name* you'll create later in Part 1 (raw) and Part 2 (processed). It's completely fine that those buckets don't exist yet; you're defining the names up front so the rest of the session is less error-prone. Replace the placeholder values with yours, and if your CloudShell session times out, just paste the block again.
>
> ```bash
> export AWS_ACCOUNT_ID="YOUR_ASSIGNED_ACCOUNT_ID"
> export USERNAME="YOUR_SHORT_USERNAME"
> export AWS_REGION="us-east-1"
> export RAW_BUCKET="techcatalyst-de-2026-${USERNAME}-raw"          # created in Part 1
> export PROCESSED_BUCKET="techcatalyst-de-2026-${USERNAME}-processed"  # created in Part 2
> ```
>
> Then run the identity check (these two commands need no buckets — they just report who and where you are):
>
> ```bash
> aws sts get-caller-identity        # Account + ARN of who you are
> aws configure list | grep region   # which region commands target
> ```

**Q1:** Which result proves that subsequent commands target the assigned **account**? Name where you see it in the Console (and the CLI command that shows the same thing). Why is a familiar IAM user/role name alone insufficient? *(Same idea as the GCS Q1: identity ≠ target context.)*

## Part 1: Create and Secure the Raw Bucket (20 minutes)

*(Mirrors GCS Part 1. GCS "uniform bucket-level access + public access prevention" = S3 "ACLs disabled + Block Public Access," which are the **defaults** for new buckets — you'll verify them rather than toggle them.)*

1. In the S3 console left nav, make sure you're on the **General purpose buckets** page, then choose **Create bucket**.

   > [!IMPORTANT]
   > **Pick the right bucket type — the S3 console now offers four.** The Create-bucket page (and the S3 left nav) lists **General purpose**, **Directory**, **Table**, and **Vector** buckets. For this lab — and for the vast majority of object-storage / data-lake work — you want **General purpose buckets**. Make sure **Bucket type = General purpose** is selected before continuing. The other three are specialized and out of scope today:
   > - **General purpose** — the original, all-purpose S3 bucket. Any object, all storage classes, multi-AZ. *This is what a landing zone uses.*
   > - **Directory** — single-AZ, ultra-low-latency tier (S3 Express One Zone) for hot, high-request workloads.
   > - **Table** — managed Apache Iceberg tables for analytics/ML (S3 Tables). We mention S3 Tables conceptually in Week 5.
   > - **Vector** — stores embedding vectors with similarity-search indexes for AI/ML; relevant to Week 6 GenAI, not here.

2. Create `techcatalyst-de-2026-<your-username>-raw` with:

   - Bucket type: **General purpose**
   - AWS Region: **us-east-1**
   - Object Ownership: **ACLs disabled (Bucket owner enforced)** — the default
   - Block Public Access: **Block *all* public access** — the default; leave it on
   - Bucket Versioning: **Disabled** for now (you enable it in Part 3)
   - Default encryption: leave the default (**SSE-S3**)
   - **Leave every other option at its default** — we only call out the settings that matter for this lab.

3. Upload `coffee.jpg` to the bucket root. Open the bucket, click **Upload**, then **Add files**, choose `coffee.jpg`, and click **Upload**. Wait for the status to read **Succeeded**, then **Close**.

4. Click the object name **`coffee.jpg`** to open its **object detail page**. This page is the object's *metadata*, not the image itself. Note the fields you'll reuse later:

   - **S3 URI** — `s3://<bucket>/coffee.jpg`. Used by AWS tools and SDKs (`aws s3`, boto3); **not** a web address — a browser cannot open `s3://`.
   - **Amazon Resource Name (ARN)** — `arn:aws:s3:::<bucket>/coffee.jpg`. Used inside IAM and bucket policies.
   - **Object URL** — `https://<bucket>.s3.us-east-1.amazonaws.com/coffee.jpg`. An HTTPS link a browser *can* request (whether it's *allowed* is a separate question — that's the next test).
   - Plus **Size**, **Type**, **Last modified**, and **Storage class**.

   To actually view the image while signed in, click **Open** (or **Download**). It works even though the bucket is private because the console issues a short-lived **presigned** request that carries your identity.

### Access test

**Predict:** Before testing, write whether the **Object URL** will open in an incognito window, and identify which control or identity your prediction depends on.

5. Copy the **Object URL** — the `https://...` link from the detail page. **Do not use the S3 URI:** `s3://` is not a web address and will not open in a browser. Open the Object URL in an incognito window where you are **not** signed in. Do **not** change any access setting.

**Observe and explain:** Record the exact response or error (you should get **AccessDenied**). Compare the identity used by the console (**Open**) request with the identity used by the incognito request.

**Q2:** Why did the authenticated console action work while the incognito request failed? *(Same answer shape as GCS Q2: authenticated IAM principal vs anonymous caller blocked by Block Public Access.)*

> [!NOTE]
> **So what would it take to make that Object URL load publicly? (concept — do NOT do this to the lab bucket.)** The `AccessDenied` is the *correct, secure* default. Making the object world-readable takes **two** deliberate changes, because S3 protects you at two layers:
> 1. **Turn off the relevant Block Public Access settings** on the bucket (Permissions → Block public access → Edit). These are on by default specifically to stop accidental exposure.
> 2. **Grant anonymous read.** Because this bucket uses **ACLs disabled (Bucket owner enforced)**, you do this with a **bucket policy**, not an object ACL — allow `s3:GetObject` to `Principal: "*"` on `arn:aws:s3:::<bucket>/*`.
>
> Only then does the Object URL return the image to an anonymous browser. **To undo:** delete the public bucket policy and re-enable **Block all public access**. In production you almost never make a raw/claims bucket public — you serve files through presigned URLs or a CDN (CloudFront) with Origin Access Control instead. Do this only on a throwaway demo bucket, and only if your instructor asks you to.

6. Place `hartford.jpeg` and `intro.docx` under this prefix:

   ```text
   raw/source=classroom/year=2026/month=06/day=22/
   ```

   You **cannot paste that whole path into Create folder** — the Console rejects a slash with *"Folder names can't contain `/`."* A folder name is a single key segment; the `/` is what separates segments (see the [S3 object key naming rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-keys.html)). Build the prefix one of two ways:

   - **Console — repeat Create folder per level.** Click **Create folder**, name it `raw`, **Create**; open `raw`, **Create folder** `source=classroom`; open it, **Create folder** `year=2026`; then `month=06`; then `day=22`. Open the deepest folder and **Upload → Add files** to add `hartford.jpeg` and `intro.docx` there. (Each *Create folder* writes a zero-byte placeholder object whose key ends in `/`.)
   - **CLI — far easier (one command builds the whole key path):**

     ```bash
     aws s3 cp hartford.jpeg "s3://${RAW_BUCKET}/raw/source=classroom/year=2026/month=06/day=22/hartford.jpeg"
     aws s3 cp intro.docx     "s3://${RAW_BUCKET}/raw/source=classroom/year=2026/month=06/day=22/intro.docx"
     ```

     Uploading with a key prefix creates the "folders" implicitly — and writes **no** placeholder objects.

**Q3:** Did S3 create real folders? What does the console tree represent? **How can you verify it?** *(Same as GCS Q3 — keys are flat; the console groups shared prefixes.)*

   To check: open `hartford.jpeg` and read its **Key** / **S3 URI** on the detail page — it's the single flat string `raw/source=classroom/year=2026/month=06/day=22/hartford.jpeg`; the slashes are *inside the key*, not nested directories. Via CLI, `aws s3api list-objects-v2 --bucket "$RAW_BUCKET" --query 'Contents[].Key'` lists flat key strings. The expandable tree in the Console is just the UI grouping keys by their shared prefix up to each `/`. (If you used **Create folder**, you'll also see zero-byte `.../` placeholder keys — those are the only "directory-like" objects, and they're optional.)

7. Verify the bucket's secure posture in the Console: open the bucket → **Permissions** tab. Confirm **Block all public access: On** (all four settings) and **Object Ownership: Bucket owner enforced (ACLs disabled)**.

> [!NOTE]
> **💻 Also via CLI (optional).** The same posture as text:
>
> ```bash
> aws s3api get-public-access-block --bucket "$RAW_BUCKET"
> aws s3api get-bucket-ownership-controls --bucket "$RAW_BUCKET"
> ```
>
> You should see all four `PublicAccessBlockConfiguration` flags `true`, and `ObjectOwnership: BucketOwnerEnforced`.

8. *(Optional, instructor-gated — partner read access.)* On GCS you granted a partner **Storage Object Viewer** with one bucket-scoped IAM binding. On AWS the cleanest classroom equivalent is a **bucket policy** granting a specific IAM principal `s3:GetObject` and `s3:ListBucket`. Because this requires your partner's IAM **role/user ARN** (AWS has no "share with a Google account" shortcut), only do this if the instructor provides partner ARNs:

   ```bash
   # Instructor provides PARTNER_ARN, e.g. arn:aws:iam::<acct>:role/TechCatalystLabRole-partner
   cat > /tmp/partner-read.json <<EOF
   {
     "Version": "2012-10-17",
     "Statement": [{
       "Sid": "PartnerRead",
       "Effect": "Allow",
       "Principal": { "AWS": "PARTNER_ARN" },
       "Action": ["s3:GetObject", "s3:ListBucket"],
       "Resource": [
         "arn:aws:s3:::${RAW_BUCKET}",
         "arn:aws:s3:::${RAW_BUCKET}/*"
       ]
     }]
   }
   EOF
   aws s3api put-bucket-policy --bucket "$RAW_BUCKET" --policy file:///tmp/partner-read.json
   ```

**Q4:** Why is a named-principal bucket-policy grant consistent with Block Public Access still being on? *(Same idea as GCS Q4: Block Public Access stops **anonymous/public** grants; an authenticated IAM principal named in a policy is not public.)*

## Part 2: Build the Processed Zone — Now Try the CLI (15 minutes)

*(Mirrors GCS Part 2.)*

You created the raw bucket by **clicking**. Build the second one from the **CLI** to feel the other way of working — one command does what several clicks did. Open **CloudShell** and run these.

1. Create a second bucket with the same secure defaults:

   ```bash
   aws s3api create-bucket \
     --bucket "$PROCESSED_BUCKET" \
     --region "$AWS_REGION"
   # us-east-1 needs no LocationConstraint; other regions do:
   #   --create-bucket-configuration LocationConstraint="$AWS_REGION"

   # New buckets are already Block-Public-Access + ACLs-disabled by default; confirm:
   aws s3api get-public-access-block --bucket "$PROCESSED_BUCKET"
   ```

2. Copy the two source objects into a staging prefix:

   ```bash
   aws s3 cp \
     "s3://${RAW_BUCKET}/raw/source=classroom/year=2026/month=06/day=22/" \
     "s3://${PROCESSED_BUCKET}/staging/" \
     --recursive
   ```

3. List the processed bucket recursively with sizes:

   ```bash
   aws s3 ls "s3://${PROCESSED_BUCKET}/" --recursive --human-readable
   ```

4. Take one screenshot showing each bucket and its object/prefix layout (the Console bucket view is fine).

> [!TIP]
> **Prefer clicking? You can do all of Part 2 in the Console too.** Use **Create bucket** (same secure defaults as Part 1). To copy objects, open the raw bucket, select the two files under `raw/...`, choose **Actions → Copy**, and set the destination to `s3://<processed-bucket>/staging/`. Same result, more clicks.

**Q5:** GCS distinguished `*` (one path segment) from `**` (recursive). The AWS CLI has **no `**` glob** — how do you list everything beneath a prefix instead, and what is the trade-off of recursion being a *flag* (`--recursive`) rather than a wildcard? *(This is the S3 counterpart to GCS Q5.)*

## Part 3: Lifecycle and Recovery Controls (25 minutes)

*(Mirrors GCS Part 3. The controls solve different problems — copy this S3 table into your notes before configuring anything.)*

| Control | Primary purpose | Can normal deletion still occur? | GCS equivalent |
| :--- | :--- | :--- | :--- |
| Lifecycle rule | Automate transition or expiration | Yes | Lifecycle rule |
| Versioning (+ delete markers) | Recover overwritten/deleted objects | Yes, prior versions retained | Versioning **and** soft delete |
| Object Lock — Governance mode | Block deletes unless you hold an override permission | No (without override) | Retention policy |
| Object Lock — Compliance mode | Make retention irreversible for everyone, incl. root | No | Bucket Lock |
| Legal Hold | Indefinite hold until explicitly removed | No | Temporary / event-based hold |

> **Note on S3 vs GCS recovery:** GCS has a separate *soft delete* default **plus** optional versioning. S3 folds both jobs into **versioning**: deleting a versioned object writes a **delete marker** and the prior version stays recoverable. There is no separate "soft delete" toggle. **Object Lock** (the retention/Bucket-Lock analog) can only be enabled **at bucket creation**, so it is explained here, not performed in this core lab.

### A. Add a lifecycle rule

**Predict:** Will a "Standard-IA after 30 days" rule move today's objects immediately? What object property will the rule evaluate?

1. In the S3 console, open the raw bucket → **Management** tab → **Create lifecycle rule**. Name it `raw-tiering-and-expiry`, apply to **all objects** in the bucket, then add:

   - **Transition current versions** to **Standard-IA** after **30 days**.
   - **Expire current versions** after **365 days**.

   Save. The **Management** tab now lists the rule — screenshot it for `day4_s3_lab.md`.

> [!NOTE]
> **💻 Also via CLI (optional).** The console form above builds this exact JSON behind the scenes; applying it directly is one command:
>
> ```bash
> cat > /tmp/lifecycle.json <<'EOF'
> {
>   "Rules": [
>     {
>       "ID": "raw-tiering-and-expiry",
>       "Status": "Enabled",
>       "Filter": { "Prefix": "" },
>       "Transitions": [ { "Days": 30, "StorageClass": "STANDARD_IA" } ],
>       "Expiration": { "Days": 365 }
>     }
>   ]
> }
> EOF
> aws s3api put-bucket-lifecycle-configuration \
>   --bucket "$RAW_BUCKET" --lifecycle-configuration file:///tmp/lifecycle.json
> aws s3api get-bucket-lifecycle-configuration --bucket "$RAW_BUCKET"   # read it back
> ```

**Observe and explain:** Inspect `coffee.jpg` immediately after saving (its **Storage class** is shown in the object list / object details). Record its current storage class and explain why it did or did not change.

**Q6:** Regulatory raw data must be retained for **seven years**. Why is a 365-day expiration rule unsafe, and which control prevents early deletion rather than merely scheduling deletion? *(Same answer shape as GCS Q6: a lifecycle rule automates deletion, it does not impose a minimum-retention barrier — that is **Object Lock**, the S3 analog of a locked retention policy.)*

### B. Enable versioning and overwrite an object

1. In the Console, open the raw bucket → **Properties** tab → **Bucket Versioning → Edit → Enable → Save**. The Properties tab now shows versioning **Enabled**.

**Predict:** When `coffee.jpg` is overwritten, will the original version disappear, or be kept? What will the new latest version contain?

2. Upload a *different* image using the exact key `coffee.jpg` (drag it into the bucket root and confirm the overwrite).
3. View all versions: in the bucket's object list, turn on the **Show versions** toggle (top of the list). Each `coffee.jpg` version shows its **Version ID**, **Last modified**, **Size**, and which one is the **current** (latest) version.

**Observe and explain:** Record the versions. S3 marks the current version as the latest — note which **Version ID** is current and explain how this differs from a bucket with versioning disabled (where the overwrite would have destroyed the original).

> [!NOTE]
> **💻 Also via CLI (optional).** Version IDs are exact and scriptable from the terminal:
>
> ```bash
> aws s3api put-bucket-versioning --bucket "$RAW_BUCKET" \
>   --versioning-configuration Status=Enabled        # if you skipped the toggle
> aws s3 cp some_other_image.jpg "s3://${RAW_BUCKET}/coffee.jpg"   # overwrite
> aws s3api list-object-versions --bucket "$RAW_BUCKET" --prefix coffee.jpg \
>   --query 'Versions[].{VersionId:VersionId,IsLatest:IsLatest,Size:Size}' \
>   --output table
> ```
>
> `IsLatest: true` marks the current version; the others are prior versions.

### C. Restore the original version

**Predict:** Will restoring the old version erase the newer version, or create another latest version? Write your prediction first.

The goal is to make the original image current **without losing history**. The clean way is to write the old version back onto the key as a *new* latest version (rather than deleting the newer one).

4. In the Console, with **Show versions** on, select the **original** version of `coffee.jpg` → **Download** it. Then **Upload** that same file back to the bucket root as `coffee.jpg`. This adds a new current version; the intervening version stays in the list.
5. Confirm in the version list: a **new** Version ID is now current, and the intervening version still appears (history preserved).

**Observe and explain:** Open the current object, then confirm the newest Version ID is current and the intervening version is still listed.

> [!NOTE]
> **💻 Also via CLI (optional) — exact and one step.** Copy the original version back onto the key by Version ID; no download/re-upload needed:
>
> ```bash
> aws s3api copy-object \
>   --bucket "$RAW_BUCKET" --key coffee.jpg \
>   --copy-source "${RAW_BUCKET}/coffee.jpg?versionId=ORIGINAL_VERSION_ID"
> aws s3api list-object-versions --bucket "$RAW_BUCKET" --prefix coffee.jpg \
>   --query 'Versions[].{VersionId:VersionId,IsLatest:IsLatest,Size:Size}' \
>   --output table
> ```

**Q7:** How do unique, append-only object keys reduce the value of versioning on a high-volume raw zone, and why can deletions or operational mistakes still create billable recovery data? Name one bounded recovery control. *(Same answer as GCS Q7, with the S3 mapping: noncurrent versions and delete markers stay billable; bound them with a **lifecycle rule on noncurrent versions**, e.g. `NoncurrentVersionExpiration`.)*

## Part 4: Document and Compare to GCS (5 minutes)

1. Confirm `day4_s3_lab.md` contains: preflight evidence + any fallback note; commands run or observed; answers to Q1–Q7; all four Predict/Observe responses; lifecycle JSON; and both bucket screenshots.

2. Fill in this mapping from memory (the answer key has the full version):

   | Concept | Google Cloud (main lab) | AWS (this lab) |
   | :--- | :--- | :--- |
   | Object storage service | Cloud Storage | Amazon S3 |
   | URI scheme | `gs://bucket/key` | `s3://bucket/key` |
   | Block anonymous access | Public access prevention | Block Public Access |
   | Disable per-object ACLs | Uniform bucket-level access | ACLs disabled (Bucket owner enforced) |
   | Recursive list | `gcloud storage ls gs://b/**` | `aws s3 ls s3://b/ --recursive` |
   | Tiering/expiry | Lifecycle rules | Lifecycle rules |
   | Recover overwrites/deletes | Soft delete + versioning | Versioning (+ delete markers) |
   | Lock minimum retention | Retention policy + Bucket Lock | Object Lock (Governance/Compliance) |

**Q (multicloud point):** In one sentence, name one concept that transfers directly from GCS to S3 and one implementation detail that changes.

### Classroom ownership and cleanup

These buckets belong to the classroom environment. Do not delete buckets or weaken protections unless the instructor directs it. Versioned/noncurrent objects remain billable, so leaving test data indefinitely is not free.

If the instructor directs full cleanup (versioned buckets need every version removed before the bucket will delete):

```bash
# Remove the partner policy if you added one:
aws s3api delete-bucket-policy --bucket "$RAW_BUCKET" 2>/dev/null || true

# Empty a versioned bucket (all versions + delete markers), then delete it:
aws s3 rm "s3://${PROCESSED_BUCKET}/" --recursive
aws s3api delete-bucket --bucket "$PROCESSED_BUCKET"

# For the versioned raw bucket, the console "Empty bucket" button is the simplest
# way to purge all versions and delete markers; do this only with instructor approval.
```

## Optional Extension: Presigned URL (10 minutes)

*(S3 analog of the GCS signed URL.)* A presigned URL grants time-limited access to one object without making the bucket public:

```bash
aws s3 presign "s3://${RAW_BUCKET}/coffee.jpg" --expires-in 600   # 10 minutes
```

Open the printed URL in incognito (works), wait past expiry or change the object, and note when a presigned URL is preferable to a durable bucket-policy grant.

## Success Criteria

- Both buckets show Block Public Access (all four flags true) and ACLs disabled.
- Objects use a `source=` + Hive-style date prefix rather than ad hoc folders.
- Authenticated access succeeds and anonymous incognito access fails as predicted.
- Lifecycle, versioning, Object Lock, and Legal Hold are explained distinctly.
- The original object version is restored and the observed result is documented.
- `day4_s3_lab.md` contains all required evidence and answers.

## Hints

<details>
<summary>create-bucket fails with IllegalLocationConstraintException</summary>

You are not in `us-east-1`. Either set `--region us-east-1`, or add `--create-bucket-configuration LocationConstraint=<your-region>` for any other region (us-east-1 is the one region that must **not** have a LocationConstraint).
</details>

<details>
<summary>The incognito URL returns AccessDenied even though you expected to "see" the file</summary>

That is the **correct** result — Block Public Access blocks anonymous reads. The console **Open** button worked because it builds a presigned, authenticated request, not a public one.
</details>

<details>
<summary>The version restore command fails</summary>

Copy the `VersionId` exactly from `list-object-versions`, and keep the `?versionId=...` attached to the `--copy-source` value (format: `bucket/key?versionId=ID`).
</details>

<details>
<summary>Bucket won't delete: "The bucket you tried to delete is not empty"</summary>

Versioned buckets keep every version **and** delete markers; an ordinary `rm` leaves them. Use the console **Empty bucket** action (or delete each version), then delete the bucket — and only with instructor approval.
</details>

---

# Instructor Answer Key

**Q1:** `aws sts get-caller-identity` returns the **Account** ID; matching it to the assigned `$AWS_ACCOUNT_ID` proves later commands target the right account. A familiar IAM role/user name is not enough — the same principal can be used across accounts, and the ARN/account is what scopes resource creation and billing.

**Q2:** The console **Open** action issues a request carrying the learner's authenticated IAM identity (a short-lived presigned request), which IAM allows. The incognito request is anonymous; with Block Public Access enabled and no public policy, S3 denies it (`AccessDenied`).

**Q3:** No real folders. S3 keys are flat strings; the console renders a folder-like tree by grouping shared key prefixes (the `/` characters).

**Q4:** Block Public Access blocks grants to **anonymous/public** principals (and public ACLs/policies). A bucket policy that names a specific IAM principal ARN grants an **authenticated** principal, which is not "public," so it coexists with Block Public Access.

**Q5:** Use `aws s3 ls s3://bucket/ --recursive` (recursion is a CLI flag, not a path wildcard; the AWS CLI does not support a `**` glob). Trade-off: a flag is simpler but less expressive — you cannot match "one segment only" vs "all nested segments" the way GCS `*` vs `**` can; you filter with `--recursive` plus prefix/`--exclude`/`--include` patterns instead.

**Q6:** A 365-day expiration conflicts with a seven-year minimum and would delete data early. A lifecycle rule only **schedules** actions; it imposes no minimum-retention barrier. **S3 Object Lock** (Governance or, for irreversibility, Compliance mode) enforces a minimum retention that blocks deletion — the S3 equivalent of a locked GCS retention policy. Object Lock must be enabled at bucket creation.

**Q7:** With unique append-only keys, normal ingestion never overwrites an existing object, so versioning adds little to the happy path while still retaining extra versions when mistakes overwrite or delete data. Deletions (which write delete markers), accidental overwrites, and reruns that reuse a key can still leave billable noncurrent versions. Bound the exposure with a lifecycle rule on **noncurrent versions** (`NoncurrentVersionExpiration`) and/or controlled writers with immutable keys; this reduces but does not eliminate cost/recovery risk.

## Expected Predict and Observe Responses

- **Access test:** Predict denial (no authorized identity in incognito). Observe `AccessDenied` anonymously while the authenticated console **Open** succeeds.
- **Lifecycle:** Predict no immediate transition because the object has not reached 30 days. Observe `coffee.jpg` stays **STANDARD** right after saving the rule.
- **Overwrite:** Predict the previous version becomes a noncurrent version and a new latest appears. Observe two `VersionId`s with `IsLatest: true` on the newer one.
- **Restore:** Predict that copying the old version creates a new latest version rather than deleting history. Observe a third `VersionId` now `IsLatest: true`, with the intervening version still listed.

## Full GCS → S3 Concept Map (key)

| Concept | Google Cloud Storage | Amazon S3 |
| :--- | :--- | :--- |
| Service / URI | Cloud Storage · `gs://` | Amazon S3 · `s3://` |
| Block anonymous access | Public access prevention (enforced) | Block Public Access (4 flags) |
| Per-object ACLs off | Uniform bucket-level access | ACLs disabled / Bucket owner enforced |
| CLI | `gcloud storage …` | `aws s3 …` / `aws s3api …` |
| Recursive list | `ls gs://b/**` | `ls s3://b/ --recursive` |
| Warm/cold tiers | Nearline / Coldline / Archive | STANDARD_IA / GLACIER_IR / GLACIER / DEEP_ARCHIVE |
| Recover deleted/overwritten | Soft delete + Versioning | Versioning + delete markers |
| Minimum retention (lockable) | Retention policy + Bucket Lock | Object Lock (Governance / Compliance) |
| Per-object hold | Temporary / event-based hold | Legal Hold |
| Time-limited object link | Signed URL | Presigned URL |

## Common Mistakes and Debrief

- Confusing a prefix with a folder or a security boundary.
- Assuming a lifecycle rule protects data from manual deletion (it does not — Object Lock does).
- Treating versioning and Object Lock as interchangeable (recovery vs enforced retention).
- Reading an authenticated console preview as anonymous/public access.

**Debrief prompt:** Which S3 control manages **cost**, which supports **recovery**, and which enforces a **minimum retention**? Why might one bucket need more than one of them? *(Lifecycle = cost; Versioning = recovery; Object Lock = retention.)*
