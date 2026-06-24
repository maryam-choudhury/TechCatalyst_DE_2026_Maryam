# Week 1 · Day 4: Cloud Object Storage Landing-Zone Lab

**Module:** Data at Rest  
**Estimated time:** 100 minutes (core lab) + 45 minutes (team design activity)  
**Difficulty:** Beginner  
**Format:** Individual or paired core lab; small-group design activity  
**Status:** Required core Day 4 activity

> [!NOTE]
> **Three ways to work with the cloud — and the order we learn them.**
> Almost everything in this lab can be done three ways:
>
> 1. **Console (web portal)** — the easiest place to start. It is visual, it labels every option, and it shows you the notes, warnings, and settings you did not know existed. Best for **learning what a service does**.
> 2. **CLI** (`gcloud storage`) — faster once you already know what you want. No clicking or navigating; one typed command does the job. Best for **speed and repeatability**.
> 3. **SDK** (Python `google-cloud-storage`, or `boto3` on AWS) — for **automation**: doing the same thing from inside a program or pipeline.
>
> **Today we lead with the Console.** You will build the raw bucket by clicking, so you can see every control, then create the second bucket from the CLI **once** — just to feel the difference. The CLI and SDK get dedicated time later (the Linux/CLI day and the Python-to-GCS day in Week 2). Wherever you see a **💻 Also via CLI** box, it is optional: try it if you are curious or fast; skip it without missing the lesson.

> [!NOTE]
> **How to read this lab.**
> - **Numbered steps** are your main path — do them in the **Console** (the web portal at `console.cloud.google.com`). Just follow them in order.
> - A box marked **💻 Also via CLI (optional)** shows the *same action* done by typing commands instead. **You can skip every CLI box and still finish the lab.**
> - **Run CLI boxes in Cloud Shell, not your local or Codespaces terminal.** Open **Cloud Shell** (the `>_` icon at the top-right of the console). It is already signed in to your account and has `gcloud`/`bq`/`gsutil` preinstalled, so the commands just work. The same commands will **fail in a local or Codespaces terminal** unless *you* install and authenticate the Google Cloud CLI there first — we don't set that up today.
> - So when you see a `bash` block: it's optional, and it runs in **Cloud Shell**.

## Objective

Build and inspect a secure Google Cloud Storage landing zone. By the end, you can:

- create buckets with uniform bucket-level access and public access prevention;
- organize objects into zones and date-based prefixes;
- explain lifecycle and recovery controls without confusing their purposes;
- test authenticated and unauthenticated access safely;
- optionally translate the landing-zone design to Amazon S3 without requiring an AWS account.

## Files and Deliverables

Use the files in `Lab Resources/`: `coffee.jpg`, `hartford.jpeg`, and `intro.docx`.

> [!IMPORTANT]
> **First, make your lab worksheet.** `day4_lab.md` is a single Markdown file *you* create to record your work — answers to the questions, your Predict/Observe notes, and screenshots — as you go through the lab. Create it now (in VS Code, or any text editor) inside your course repo, and add to it whenever a step says "record" or "screenshot." You'll submit this one file at the end of the day.

| Deliverable | Required contents | Due |
| :--- | :--- | :--- |
| `day4_lab.md` | Answers to Q1 to Q7, four Predict/Observe responses, the lifecycle rules, and screenshots of the raw and processed buckets | End of day |
| Team storage convention | Required template items 1 to 7 and a 3-minute readout; item 8 is optional | End of day |

### Naming convention

You will type these names into the Console when you create resources (and reuse them in the optional CLI boxes). Replace `<username>` with your short username.

| Resource | Name |
| :--- | :--- |
| Assigned project | `YOUR_ASSIGNED_PROJECT_ID` (from your instructor) |
| Raw bucket | `techcatalyst-de-2026-<username>-raw` |
| Processed bucket | `techcatalyst-de-2026-<username>-processed` |

Bucket names are globally unique. If a name is taken, add the short suffix supplied by your instructor.

---

# Core Lab: 100 Minutes

## Part 0: Account and Project Preflight (10 minutes)

> [!IMPORTANT]
> Use only your assigned project, and don't change access settings or attach a personal billing account. **If anything in this lab doesn't work, contact your instructor** — it's an environment issue to resolve, not something for you to fix.

Your assigned project already has the access you need. These quick checks just confirm you're in the right place. Do them in the **Console** — it shows each fact on a labeled screen.

1. Open the Google Cloud Console (`console.cloud.google.com`) and sign in with your **assigned classroom account** (top-right avatar shows the email).
2. Confirm all four readiness conditions from the portal:

   - **Active account:** the avatar (top-right) shows your assigned classroom account.
   - **Active project:** the **project picker** in the top blue bar shows the assigned project ID — not just *a* project. This is the one that matters: being signed in does not tell you which project your actions will land in.
   - **Billing:** open the navigation menu → **Billing**. It shows the project is linked to an active billing account. If your classroom role cannot see billing, ask the instructor to confirm — do not attach your own billing account or payment method.
   - **APIs enabled:** navigation menu → **APIs & Services → Enabled APIs & services**. Confirm **Cloud Storage API** is enabled (BigQuery API is also needed for the next required activity).
   - The instructor confirms you have a course role that can create and manage lab buckets and objects (normally a scoped Storage Admin role).

3. Record the active account, project ID, billing confirmation, and enabled APIs in `day4_lab.md` (a screenshot of the project picker plus the Enabled APIs page is fine). Do not record access tokens or credentials.

> [!NOTE]
> **💻 Also via CLI (optional).** The same checks, faster, from **Cloud Shell** (the `>_` icon in the console top bar). This is what you will use by default after the Week 2 CLI day.
>
> **Doing the CLI boxes?** Open Cloud Shell and paste this block **once** at the start of your session. It only defines the names that later CLI boxes reuse — replace the two placeholder values with yours. (Staying in the Console? Skip this entirely.)
>
> ```bash
> export PROJECT_ID="YOUR_ASSIGNED_PROJECT_ID"
> export USERNAME="YOUR_SHORT_USERNAME"
> export RAW_BUCKET="techcatalyst-de-2026-${USERNAME}-raw"
> export PROCESSED_BUCKET="techcatalyst-de-2026-${USERNAME}-processed"
> ```
>
> Then run the checks:
>
> ```bash
> gcloud auth list                      # which account am I?
> gcloud config set project "$PROJECT_ID"
> gcloud config get-value project       # which project will commands target?
> gcloud services list --enabled \
>   --filter='name:(storage.googleapis.com OR bigquery.googleapis.com)'
> ```

**Q1:** Which signal proves your work will target the **assigned project**, not just that you are signed in? Name where you see it in the Console (and, if you used it, which CLI command shows the same thing). Why is the correct signed-in email alone insufficient?

## Part 1: Create and Secure the Raw Bucket (25 minutes)

1. In the Console, open the navigation menu (**☰**, top-left) → **Cloud Storage → Buckets**, then click **Create**.
2. Fill in the create form:

   - **Name your bucket:** `techcatalyst-de-2026-<your-username>-raw` (use your short username). Click **Continue**.
   - **Choose where to store your data:** the form defaults to **Multi-region** — **click `Region` instead**, then select **`us-east1`** from the dropdown. (We use a single region so it lines up with BigQuery later and keeps costs predictable.) Click **Continue**.
   - **Choose a storage class:** leave **Standard** (the default). Click **Continue**.
   - **Choose how to control access:** leave **Uniform** selected (the default), and leave **Prevent public access** checked. Click **Continue**.
   - **Choose how to protect data:** leave the defaults for now.

3. Click **Create**. A dialog pops up — *"Public access will be prevented… Enforce public access prevention on this bucket."* Leave that box **checked** and click **Confirm**. Your new (empty) bucket opens.

### Upload a file and test access

4. Upload `coffee.jpg` to the bucket root: click **Upload**, then choose **Upload files** (not *Upload folder*), and select `coffee.jpg` from the `Lab Resources/` folder.
5. Click the file name **`coffee.jpg`**. This opens the **Object details** screen — you'll see the image preview plus two links: a **Public URL** and an **Authenticated URL**.

**Predict:** Before clicking either link, write what you think will happen when you open the **Public URL** in an incognito window (where you are *not* signed in), and say which control or identity your prediction depends on.

6. **Copy** the **Public URL** straight from the Object details page (don't type it) and open it in a new **incognito/private** browser window (not signed in). Do **not** change any access setting. You should get an **AccessDenied** error — *"Anonymous caller does not have storage.objects.get access…"*. Now try the **Authenticated URL**: it asks you to sign in, because it carries *your* identity instead of serving the file publicly.

   The two links even use different hosts: the **Public URL** is on `storage.googleapis.com` (the anonymous endpoint), while the **Authenticated URL** is on `storage.cloud.google.com` (the signed-in endpoint).

**Observe and explain:** Record the AccessDenied response from the Public URL. Contrast the two links: the **Public URL** is an anonymous request (blocked by public access prevention), while the **Authenticated URL** only works for your signed-in identity.

**Q2:** Why did opening the file inside the console (and the Authenticated URL) work, while the Public URL in incognito failed?

7. Now add two files **inside a prefix** (a folder-like path). The **Upload files** button drops files into whichever folder you are currently viewing — it does **not** ask where to put them — so first build the path with **Create folder**, then upload into it.

   With the bucket open, click **Create folder** in the toolbar **above the file list** (not the three-dots menu next to the bucket name), and type the whole path in one go:

   ```text
   source=classroom/year=2026/month=06/day=22/
   ```

   The console creates all the nested folders at once. (No `raw/` level needed — the bucket *is* your raw zone, so a `raw/` prefix inside a `-raw` bucket would just be redundant.) Open the deepest folder (`day=22`), then click **Upload → Upload files** and select `hartford.jpeg` and `intro.docx`. They land under the prefix.

   > [!TIP]
   > Notice one slashed name created the whole tree — that's because these "folders" aren't real directories, just a text prefix on each object's name. The CLI box does the same thing in a single `gcloud storage cp`.

**Q3:** Did Cloud Storage create real folders? What does the console tree represent?

8. Grant a partner read access. Open the bucket → **Permissions** tab → **Grant access**. In **New principals**, enter your assigned partner's classroom email; under **Role**, pick **Cloud Storage → Storage Object Viewer**; click **Save**. Have the partner open or list the objects while signed in.

   This grant is bucket-scoped. With uniform bucket-level access, the `raw/...` prefix is **not** a separate IAM resource. If two zones need different readers or writers, separate buckets are clearer than pretending a prefix is an access boundary.

9. Verify the bucket's controls in the Console: open the bucket → **Configuration** tab and confirm **Access control: Uniform** and **Public access prevention: Enforced**. (The **Permissions** tab confirms the partner grant you just added.)

**Q4:** Why is a bucket-level viewer grant consistent with public access prevention?

## Part 2: Build the Processed Zone — Now Try the CLI (20 minutes)

You built the raw bucket by **clicking**. Now build the second bucket from the **CLI** to feel the other way of working. Notice that one typed command does what several clicks did — that is exactly why engineers reach for the terminal once they know what they want. Open **Cloud Shell** (the `>_` icon in the console top bar) and run these.

1. Create a second bucket with the same access-control posture:

   ```bash
   gcloud storage buckets create "gs://${PROCESSED_BUCKET}" \
     --project="${PROJECT_ID}" \
     --location=us-east1 \
     --uniform-bucket-level-access \
     --public-access-prevention
   ```

2. Copy the two source objects into a staging prefix:

   ```bash
   gcloud storage cp \
     "gs://${RAW_BUCKET}/source=classroom/year=2026/month=06/day=22/*" \
     "gs://${PROCESSED_BUCKET}/staging/"
   ```

3. List the processed bucket recursively with sizes:

   ```bash
   gcloud storage ls -l "gs://${PROCESSED_BUCKET}/**"
   ```

4. Take one screenshot showing each bucket and its object/prefix layout (the Console bucket view is fine).

> [!TIP]
> **Prefer clicking? You can do all of Part 2 in the Console too.** Create the bucket with the same **Create** flow as Part 1 (Region `us-east1`, Uniform access, Public access prevention enforced). To copy objects, open the raw bucket, navigate into `source=classroom/year=2026/month=06/day=22/`, select the two files, choose **Copy**, and set the destination to `gs://<processed-bucket>/staging/`. Same result — just more clicks. Doing it once each way is the point.

**Q5:** In the CLI listing, what does `**` match that `*` may not match? (If you only used the Console, note how the bucket view shows nested prefixes instead.)

## Part 3: Lifecycle and Recovery Controls (35 minutes)

These controls solve different problems. Copy this table into your notes before configuring anything.

| Control | Primary purpose | Can normal deletion still occur? | Typical use |
| :--- | :--- | :--- | :--- |
| Lifecycle rule | Automate transition or deletion | Yes | Cost and housekeeping |
| Soft delete | Recover recently deleted objects | Deletion creates recoverable state | Accidental deletion recovery |
| Versioning | Preserve overwritten/deleted generations | Yes, with versions retained | Change recovery |
| Retention policy | Prevent deletion before an age | No | Minimum retention |
| Bucket Lock | Make retention policy irreversible | No | Regulated/compliance data |

Soft delete is a bucket recovery window for deleted objects. Versioning retains noncurrent generations created by overwrite or deletion. Neither is a substitute for a retention policy, and Bucket Lock is an irreversible compliance action that is not performed in this core lab.

### A. Add a lifecycle rule

**Predict:** Will saving a “Nearline after 30 days” rule move today's objects immediately? What object property will the rule evaluate?

1. In the raw bucket, open the **Lifecycle** tab → **Add a rule**.
2. **Select an action.** This first screen asks *what* the rule should do:

   - **Set storage class to Nearline / Coldline / Archive** — move matching objects to a cheaper, cooler tier. Rough guide: **Nearline** for data read less than monthly, **Coldline** less than quarterly, **Archive** less than yearly. (Cooler tiers cost less to *store* but more to *read*, and have minimum-storage durations — and, as the note on that screen says, objects already in Coldline/Archive won't be moved to Nearline.)
   - **Delete object** — permanently remove objects that meet the condition.
   - **Delete multi-part upload** — housekeeping that clears unfinished/idle multipart uploads; it does not touch your finished objects.

   Choose **Set storage class to Nearline**, then **Continue**.
3. **Select object conditions.** This screen shows many optional filters — you only need one:

   - Under **Set Rule Scopes**, leave **Object name matches prefix/suffix** *unchecked* (so the rule applies to every object).
   - Under **Set Conditions**, check **only `Age`** and enter **30**. Leave all the other conditions (Created before, Storage class matches, Number of newer versions, Live state, etc.) *unchecked*.

   Click **Continue**, then **Create** the rule.
4. Add the second rule: **Add a rule** → action **Delete object** → **Continue** → again leave the scopes unchecked, check **only `Age`** and enter **365** → **Continue** → **Create**.
5. The **Lifecycle** tab now lists both rules — screenshot it for `day4_lab.md`.

> [!NOTE]
> **💻 Also via CLI (optional).** To capture the rules as the exact JSON the platform stores (a good habit — this is what you would commit to version control), paste this output instead of a screenshot:
>
> ```bash
> gcloud storage buckets describe "gs://${RAW_BUCKET}" \
>   --format='json(lifecycle)'
> ```

**Observe and explain:** Inspect `coffee.jpg` immediately after saving (its **Storage class** is shown in the object list / object details). Record its current storage class and explain why it did or did not change.

**Q6:** Regulatory raw data must be retained for seven years. Why is a 365-day lifecycle deletion rule unsafe, and which control prevents early deletion rather than merely scheduling deletion?

### B. Enable versioning and overwrite an object

1. In the Console, open the raw bucket → **Protection** tab. Record what it shows for **Soft delete policy** and **Object versioning** (versioning is normally off by default).
2. On the same **Protection** tab, turn **Object versioning** on. Wait until the tab shows it as enabled before continuing.

**Predict:** When `coffee.jpg` is overwritten, will the original version disappear, or be kept? What do you expect the new live version to contain?

3. Upload a *different* image using the exact object name `coffee.jpg` (drag it into the bucket root and confirm the overwrite).
4. View the versions: in the bucket's object list, turn on **Show deleted data** (the toggle above the list) to reveal noncurrent versions. Each row for `coffee.jpg` shows its **generation** number, creation time, and whether it is the **live** version.

**Observe and explain:** Record the versions you see. Identify which one is live and which is noncurrent, and explain how this differs from a bucket with versioning disabled (where the overwrite would have destroyed the original).

> [!NOTE]
> **💻 Also via CLI (optional) — and here the CLI is genuinely sharper.** Generation numbers are exact and scriptable from the terminal:
>
> ```bash
> gcloud storage ls -a "gs://${RAW_BUCKET}/coffee.jpg"            # all generations
> gcloud storage objects describe "gs://${RAW_BUCKET}/coffee.jpg" \
>   --format='yaml(name,generation,size,updated)'                 # the live one
> ```
>
> `ls -a` lists generation-qualified names but does **not** label them live or noncurrent. The unqualified `objects describe` returns the current live generation. Match that number to the `ls -a` list: the match is live; the others are noncurrent.

### C. Restore the original generation

**Predict:** Will restoring an old generation erase the newer generation, or create another live generation? Write your prediction first.

5. In the Console, with **Show deleted data** still on, find the **original** noncurrent generation of `coffee.jpg`, open its row action menu (⋮), and choose **Restore**. Confirm.
6. Refresh the object list. Note the new live version and confirm the intervening generation is still listed as noncurrent.

**Observe and explain:** Open the live object, then state what became live and whether the intervening generation remains available.

> [!NOTE]
> **💻 Also via CLI (optional) — exact and repeatable.** Restoring by generation number is the cleanest in the terminal. Copy the original generation from the `ls -a` listing in Part B, then:
>
> ```bash
> gcloud storage cp \
>   "gs://${RAW_BUCKET}/coffee.jpg#ORIGINAL_GENERATION" \
>   "gs://${RAW_BUCKET}/coffee.jpg"
> gcloud storage ls -a "gs://${RAW_BUCKET}/coffee.jpg"
> gcloud storage objects describe "gs://${RAW_BUCKET}/coffee.jpg" \
>   --format='yaml(name,generation,size,updated)'
> ```
>
> Restoring copies the old generation back as a **new** live generation — it does not delete history.

**Q7:** How do unique append-only object names reduce the value of versioning on a high-volume raw zone, and why can deletions or operational mistakes still create billable recovery data? Name one bounded recovery control.

## Part 4: Document and Check Your Work (10 minutes)

1. Confirm that `day4_lab.md` contains:

   - preflight evidence and any fallback note;
   - commands run or observed;
   - answers to Q1 to Q7;
   - all four Predict and Observe responses;
   - lifecycle JSON and both bucket screenshots.

2. Optionally compare the services without creating an AWS account:

   | Concept | Google Cloud | AWS |
   | :--- | :--- | :--- |
   | Object storage service | Cloud Storage | Amazon S3 |
   | URI | `gs://bucket/key` | `s3://bucket/key` |
   | Default secure posture used here | Public access prevention + uniform bucket IAM | Block Public Access + bucket/IAM policies |
   | CLI example | `gcloud storage ls gs://bucket/**` | `aws s3 ls s3://bucket/ --recursive` |

**Optional S3 reflection:** Name one concept that transfers directly from GCS to S3 and one implementation detail that changes. This is not part of the required submission.

### Classroom ownership and cleanup

The course project and its buckets belong to the classroom environment. Follow the instructor's retention decision because these buckets may be reused by later pipeline activities. Do not delete buckets, disable soft delete, or shorten recovery or retention settings unless the instructor explicitly directs it. Noncurrent generations and soft-deleted objects can remain billable, so leaving test data indefinitely is not free; lifecycle actions are also not immediate cleanup.

If you granted partner access, revoke it after the observation: open the bucket → **Permissions** tab, find your partner's **Storage Object Viewer** entry, and click the trash/remove icon next to it.

If the instructor directs full cleanup, do it from the Console:

- **Delete the folders/objects:** in each bucket, tick the **checkbox** next to the folder (or the objects), then click **Delete** in the toolbar above the list and confirm.
- **Delete the buckets:** go to **Cloud Storage → Buckets**, tick the **checkbox** next to each lab bucket, and click **Delete**.

> [!IMPORTANT]
> Only do this if the instructor says so — these buckets may be reused by later pipeline activities. Soft delete may keep recoverable copies (and storage charges) during its recovery window, so don't change soft-delete or retention settings yourself. If anything refuses to delete, that's expected — tell your instructor rather than forcing it.

## Optional Extension: Signed URL (10 minutes)

Signed URLs are **not required** for the core lab. They grant time-limited access to a specific object without making the bucket anonymous or changing public access prevention.

Signing requires suitable credentials. In classroom environments this commonly means an approved service account whose signer can use the `iam.serviceAccounts.signBlob` capability; user credentials alone may not be ready to sign.

**Instructor readiness check:** Before offering this extension, confirm that an approved service account exists, the learner can impersonate or use it as intended, the signer has permission to sign blobs, and the object reader permissions are correct. Do not create keys during class merely to complete this extension.

If the instructor confirms readiness, generate a 10-minute URL using the supplied classroom command or console workflow, test it in incognito, and record when this is preferable to a durable bucket IAM grant.

## Success Criteria

- Both buckets enforce uniform bucket-level access and public access prevention.
- Objects use a source and Hive-style date prefix rather than simulated ad hoc folders.
- Authenticated access succeeds and unauthenticated incognito access fails as predicted.
- Lifecycle, soft delete, versioning, retention, and Bucket Lock are explained distinctly.
- The original object generation is restored and the observed result is documented.
- `day4_lab.md` contains all required evidence and answers.

## Hints

<details>
<summary>A command still points at the wrong project</summary>

Run `gcloud config get-value project`, then repeat `gcloud config set project "$PROJECT_ID"`. Also check whether `${PROJECT_ID}` still contains the placeholder.
</details>

<details>
<summary>The partner cannot inspect objects</summary>

Check that the grant is on the bucket, the full classroom email is correct, and the partner is authenticated as that account. Do not weaken the bucket's public-access controls.
</details>

<details>
<summary>The generation restore command fails</summary>

Copy the numeric generation exactly from `gcloud storage ls -a`. Keep `#GENERATION` inside the quoted URI so the shell passes it literally.
</details>

---

# Team Design Activity: Taxi Storage Convention (45 Minutes)

Design the storage convention your team could use for the eight-week NYC Taxi pipeline. Submit one page; a list, table, or diagram is acceptable, but every decision needs a one-sentence reason.

## Required Team Template

1. **Zones:** Define `raw`, `quarantine`, `processed`, and `curated` locations. Decide whether access or lifecycle differences justify separate buckets.
2. **Keys:** Give one complete Hive-style example using `year=YYYY/month=MM/day=DD` and state how source and taxi type appear in the key.
3. **Formats:** Choose an expected file format for every zone.
4. **Exceptions:** State what happens to late, duplicate, and malformed files. Include how an operator can trace each file.
5. **Lifecycle:** Define hot, warm, cold, and archive transitions or explain why a zone skips a tier. Include deletion timing.
6. **Access:** Name who can read and write each zone; do not treat prefixes as IAM boundaries unless your proposed platform explicitly supports that design.
7. **Consumption:** Give one query-in-place use case and one use case that should load curated data into a warehouse.
8. **Optional translation:** State how the same design maps from GCS to S3 without changing its architectural intent. This item is not required for the team deliverable.

**Deliverable:** One-page convention plus a 3-minute readout. Every team member must be able to explain one design choice and its trade-off.

---

# Instructor Answer key and Reference Design

## Core Questions

**Q1:** The **active project** signal proves it — the project picker in the Console top bar showing the assigned project ID (or, via CLI, `gcloud config get-value project` returning that same ID). Authentication only identifies the caller, and one account can access several projects, so the signed-in email does not prove which project — or which billing/IAM context — your actions will land in.

**Q2:** The console request includes the learner's authenticated identity and succeeds through IAM. Incognito has no authorized identity, and public access prevention blocks anonymous exposure, so the direct request returns an access error (the exact wording may vary).

**Q3:** No filesystem folders were created. Object names are flat keys; the console groups shared name prefixes to display a folder-like tree.

**Q4:** Public access prevention blocks access granted to anonymous/public principals. A named partner with `Storage Object Viewer` is an authenticated principal receiving an explicit bucket-level IAM grant.

**Q5:** `*` matches within one path segment in this use; `**` recursively matches objects beneath nested prefixes. (Console equivalent: the bucket view already shows nested prefixes as an expandable tree, so you "see" the recursion instead of expressing it with a wildcard.)

**Q6:** A 365-day deletion action conflicts with a seven-year minimum. A retention policy prevents deletion before the required age; locking it with Bucket Lock makes that policy irreversible and should only follow formal compliance approval. A lifecycle rule alone automates an action but does not impose a minimum-retention barrier.

**Q7:** With unique append-only names, normal ingestion does not overwrite an existing object, so versioning adds little protection to that normal path while retaining extra generations when mistakes do overwrite or delete data. Deletions, accidental overwrites, reruns that reuse a name, and later cleanup can still leave billable noncurrent or soft-deleted data. A bounded soft-delete window can provide recovery while controlled writers and unique immutable names reduce overwrite risk; it does not eliminate deletion or cost risk.

**Optional S3 reflection:** Transferable concepts include buckets, object keys, prefixes, IAM, lifecycle, version history, and storage tiers. Details that change include URI schemes, CLI syntax, IAM/policy mechanics, tier names, and provider-specific recovery defaults.

## Expected Predict and Observe Responses

- **Access test:** Predict denial because the browser has no authorized identity. Observe an access error in incognito while the authenticated console succeeds.
- **Lifecycle:** Predict no immediate transition because new objects have not reached the age condition. Observe that `coffee.jpg` remains Standard immediately after the rule is saved.
- **Overwrite:** Predict that the previous live generation becomes noncurrent and a new live generation appears. Observe at least two generation numbers, then match the unqualified object's described generation to infer which one is live.
- **Restore:** Predict that copying an old generation creates a new live generation rather than deleting history. Match the unqualified object's new generation to the listing and observe that intervening history remains available.

## Plausible Team Reference Design

| Zone | Example location and format | Handling and access | Lifecycle |
| :--- | :--- | :--- | :--- |
| Raw | `gs://taxi-raw/source=nyc-tlc/type=yellow/year=2026/month=06/day=22/yellow_2026-06-22_001.parquet` (source format accepted; Parquet preferred when supplied) | Ingestion service writes; engineers read; immutable names include source/checksum metadata | Standard (hot) 30 days → Nearline (warm) to day 365 → Coldline (cold) to year 2 → Archive through year 7 → delete after 7 years only when retention permits and approval exists |
| Quarantine | `gs://taxi-quarantine/reason=schema/year=2026/month=06/day=22/...` (original file + JSON error report) | Validator writes; operators read/write; analysts denied | Standard (hot) 30 days → Nearline (warm) to day 180 → delete at day 180 unless held; skip cold/archive because investigation data is short-lived and later-tier minimum-duration/retrieval costs add little value |
| Processed | `gs://taxi-processed/type=yellow/year=2026/month=06/day=22/part-*.parquet` | Pipeline writes; engineers and approved query engines read | Standard (hot) 90 days → Nearline (warm) to year 1 → Coldline (cold) to year 3 → Archive through year 7 → delete at year 7 after approved reproducibility window |
| Curated | `gs://taxi-curated/dataset=trips/type=yellow/year=2026/month=06/day=22/part-*.parquet` | Release pipeline writes; analysts/query engines read | Standard (hot) 180 days → Nearline (warm) to year 1 → Coldline (cold) to year 3 → Archive older snapshots through year 7 → delete snapshots at year 7; retain or rebuild the current published dataset |

Late files land under their event date with an ingestion timestamp in metadata and trigger a targeted partition rerun. Duplicate detection uses source ID plus checksum; duplicates go to quarantine with a reason record. Malformed files go to quarantine unchanged with validation output and a trace/correlation ID.

Query-in-place is suitable for an engineer validating a newly processed partition before promotion. Repeated dashboards and governed business metrics should use curated warehouse tables for predictable performance, metadata, and access controls. Optionally, the team can translate the design to S3: the bucket/key layout and responsibilities stay the same while `gs://` becomes `s3://`, GCS IAM becomes AWS IAM/bucket policy design, and lifecycle/storage-class names use S3 equivalents.

## Common Mistakes and Debrief

- Learners confuse a prefix with a folder or security boundary.
- Learners assume lifecycle rules protect data from manual deletion.
- Learners call soft delete and versioning interchangeable.
- Learners interpret an authenticated console preview as anonymous access.

Debrief prompt: **Which control manages cost, which supports recovery, and which enforces a minimum retention period? Why might one bucket need more than one of them?**
