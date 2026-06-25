# Week 1 · Day 4 Optional: Bucket Lock and Retention (Compliance)

**Duration:** ~25 min  
**Format:** Individual optional, after Part 3 of the core GCS lab  
**Prerequisites:** Course GCP project with billing; Cloud Shell or authenticated `gcloud`

> [!IMPORTANT]
> **Use a separate demo bucket**, do not lock retention on your `-raw` landing-zone bucket. Retention lock is **permanent** once applied. This lab uses `techcatalyst-de-2026-<your-username>-retention-demo`.

> [!NOTE]
> **Console first, here too.** Each step below leads with the **Console** (the Protection tab is where retention, lock, and holds live). A **💻 Also via CLI** box follows each one — and for this lab the CLI is genuinely handy because the demo uses a 60-second retention you can watch expire. Use whichever you prefer; the concepts are identical. **Run the CLI boxes in Cloud Shell** (already signed in, `gcloud` preinstalled) — they won't work in a local or Codespaces terminal unless you set up the CLI yourself.

***

## Why this optional lab exists

Part 3's lifecycle rule (Q6) handles *cost-driven* tiering and deletion timing. **Bucket Lock** handles *compliance-driven* immutability, regulators can require that records cannot be deleted early, even by an admin.

At The Hartford, raw claims and policy files often have **7-year minimum retention**. Lifecycle rules move data to cheaper classes; retention policies **prevent premature deletion**. Both can apply to the same bucket.

This is optional because it is a specialization on top of today's landing-zone lab, not required for the Day 4 deliverable.

***

## Concepts and real-world use cases (read first, ~4 min)

Four related controls show up in this lab. They are easy to confuse, so here is what each one does and *when a data engineer actually reaches for it*.

**Retention policy — the time-based floor.** A retention policy sets a *minimum age* an object must reach before anyone can delete or overwrite it. It applies to **every object in the bucket** and is purely time-based. You reach for it whenever a rule says "keep these records for at least N years." Insurance examples: closed claim files and policy documents often carry a 7–10 year minimum; financial records under SOX are typically 7 years; medical records under HIPAA have their own multi-year floors. Without a retention policy, a mistaken script or a hurried admin could delete records that the business is legally required to keep.

**Bucket Lock — making that floor immutable.** Setting a retention policy is reversible: while unlocked, an admin can shorten or remove it. **Locking** the policy makes it permanent — the duration can only ever be *extended*, never reduced or removed, **not even by a project owner or by Google**. This is the control auditors care about, because it proves that *nobody* can quietly delete records early. It is how you satisfy WORM ("Write Once, Read Many") requirements such as SEC Rule 17a-4 and FINRA/CFTC record-keeping rules. The trade-off is real: you can never walk it back, and you cannot delete the bucket until every object has aged past its retention. So you lock only when the compliance requirement is firm.

**Temporary hold — the "legal hold" / "litigation hold" pattern.** A temporary hold freezes a **specific object** so it cannot be deleted or overwritten until you *explicitly release it* — regardless of whether its retention period has already expired. The common industry term for this is a **legal hold** or **litigation hold**: when a lawsuit, regulatory investigation, or audit is reasonably anticipated, you must preserve the relevant records even if their normal retention has lapsed; destroying them anyway can count as *spoliation of evidence*. Google Cloud Storage implements this pattern with a temporary hold (indefinite, manually released). Example: a dispute arises over claim `claim_001` — Legal asks you to preserve everything related to it until the case closes, so you place a temporary hold on those objects and release it only when cleared.

**Event-based hold — start the clock on a business event (bonus).** Sometimes retention should begin not at upload, but when something *happens* — a policy is cancelled, a loan is paid off, an employee leaves. An event-based hold pauses the retention countdown until that event fires. It is niche; we only mention it.

| Control | What it does | Time-based? | When you reach for it |
| :--- | :--- | :--- | :--- |
| **Retention policy** | Minimum age before delete/overwrite, bucket-wide | Yes | A regulation says "keep for ≥ N years" |
| **Bucket Lock** | Makes the retention policy permanent/immutable | Yes (locked) | Auditor needs proof records can't be deleted early (WORM) |
| **Temporary hold** | Freezes one object until manually released | No | Legal/litigation hold during a dispute or audit |
| **Event-based hold** | Starts retention when a business event occurs | Triggered | Retention should begin on cancel/payoff, not upload |

These controls **stack**: lifecycle rules (from the core lab) manage *cost*, a retention policy sets the *legal floor*, Bucket Lock makes that floor *immutable*, and holds add *case-by-case* overrides on individual objects. The same claims bucket at The Hartford could use all four at once.

***

## Part 1: Create a demo bucket (~5 min)

In the Console: **Cloud Storage → Buckets → Create**, then:

1. **Name** the bucket `techcatalyst-de-2026-<your-username>-retention-demo`.
2. **Location type:** Region → **`us-east1`**.
3. **Access control:** **Uniform**.
4. **Leave every other option at its default** (storage class, public-access prevention, protection tools, etc.) — we only call out the settings that matter for this lab. Click **Create**.

Now add the test object. The Console upload dialog has **no "prefix" field**, so create the folder first, then upload into it:

5. Open the new bucket. Click **Create folder**, name it `records`, and **Create**.
6. Open the `records/` folder, then **Upload → Upload files** and choose `Lab Resources/intro.docx`. It lands at `records/intro.docx`.
7. Rename it: next to the uploaded object, open the **⋮ (action menu) → Rename**, set the new name to `claim_001.docx`, and confirm. (In Cloud Storage, "rename" performs a copy + delete behind the scenes — fine here.)

You should end up with the object at `records/claim_001.docx`. Note this path; you'll reference it in the rest of the lab.

> [!NOTE]
> **💻 Also via CLI (optional) — in Cloud Shell.**
>
> ```bash
> export DEMO_BUCKET=techcatalyst-de-2026-<your-username>-retention-demo
> gcloud storage buckets create gs://${DEMO_BUCKET} \
>   --location=us-east1 --uniform-bucket-level-access
> gcloud storage cp "Lab Resources/intro.docx" gs://${DEMO_BUCKET}/records/claim_001.docx
> ```

## Part 2: Set a retention policy (~10 min)

Regulators often require multi-year retention. For the lab we use **60 seconds** so you can see expiration without waiting years.

In the Console: open the bucket you created in Part 1 (`techcatalyst-de-2026-<your-username>-retention-demo`) → **Protection** tab. Scroll to the **Retention (for compliance)** section, and under **Bucket retention policy** click **+ Set retention policy**. In the pop-up window, set **Duration** to **60** and keep the unit as **Seconds**. Click **Save**.

**Q1:** What does the Protection tab show for the retention period and its effective time? In plain English: when can this object be deleted?

Now try to delete `claim_001.docx` **before** it expires: open the object (or select it in the list) → **Delete**. It should be blocked.

**Q2:** What error/message do you get? Paste it into `day4_lab.md`.

> [!NOTE]
> **💻 Also via CLI (optional)** — and the easiest way to read the exact expiration timestamp:
>
> ```bash
> gcloud storage buckets update gs://${DEMO_BUCKET} --retention-period=60s
> gcloud storage buckets describe gs://${DEMO_BUCKET} --format="yaml(retention_policy)"
> gcloud storage ls -L gs://${DEMO_BUCKET}/records/claim_001.docx   # look for Retention Expiration
> gcloud storage rm gs://${DEMO_BUCKET}/records/claim_001.docx       # blocked before expiry
> ```

## Part 3: Lock the policy (~5 min)

While **unlocked**, you can shorten or remove a retention policy. **Locking** is permanent, the duration can only be *extended*, never reduced or removed.

In the Console: open your `-retention-demo` bucket → **Protection** tab → scroll back to **Bucket retention policy**. You'll now see **Edit**, **Delete**, and **Lock** options for the policy. Click **Lock**, read the warning carefully, and confirm (this is irreversible).

**Q3:** What changed on the Protection tab after locking? Why would a compliance officer want this locked state?

> [!NOTE]
> **💻 Also via CLI (optional) — in Cloud Shell.**
>
> ```bash
> gcloud storage buckets update gs://${DEMO_BUCKET} --lock-retention-period
> gcloud storage buckets describe gs://${DEMO_BUCKET} --format="yaml(retention_policy)"
> ```

## Part 4: Temporary hold (~5 min)

A **temporary hold** is set on the **object** and is **independent of the bucket's retention policy**. It's fine that you locked the 60-second policy in Part 3 — a hold is a separate control. Its whole point is that it blocks deletion **even after the retention period has expired**, which is what makes it useful for pausing deletion during an audit.

> [!IMPORTANT]
> **Don't use the "Default event-based hold" toggle** near the bottom of the **Protection** tab — that's a *bucket-level default* that applies an event-based hold to objects uploaded later, not the per-object temporary hold we want here. Leave it disabled.

In the current Console, object holds are set by **selecting the object's checkbox**, not from the object's ⋮ menu:

1. Open your `-retention-demo` bucket, then open the `records/` folder so you can see `claim_001.docx`.
2. **Select the checkbox** to the left of `claim_001.docx`. A **Manage holds** button appears in the toolbar above the object list — click it.
3. In the **Manage holds** window, turn on **Temporary hold**, then click **Save hold settings**.
4. Try to **Delete** `claim_001.docx` — it's blocked while the hold is active. (Capture the message if you like.)
5. Re-open **Manage holds**, turn **Temporary hold** off, and click **Save hold settings** to release it.

**Q4:** How is a **temporary hold** different from a **retention policy**? One sentence each.

> [!NOTE]
> **💻 Also via CLI (optional) — in Cloud Shell.**
>
> ```bash
> gcloud storage objects update gs://${DEMO_BUCKET}/records/claim_001.docx --temporary-hold
> gcloud storage rm gs://${DEMO_BUCKET}/records/claim_001.docx          # blocked while held
> gcloud storage objects update gs://${DEMO_BUCKET}/records/claim_001.docx --no-temporary-hold
> ```

> [!NOTE]
> **Event-based holds** (start retention countdown when a loan is "paid off," etc.) exist but are niche. Read about them in [GCS object holds](https://cloud.google.com/storage/docs/object-holds) if curious, not required for Day 4.

## Success criteria

- [ ] Demo bucket created (separate from `-raw`)
- [ ] 60s retention policy set and verified
- [ ] Early delete blocked (Q2 error captured)
- [ ] Retention policy locked
- [ ] Temporary hold demonstrated
- [ ] Q1 to Q4 in `day4_lab.md`

## Cleanup

Wait 60+ seconds after releasing any holds (so the retention period has expired), then delete the object and the bucket.

**In the Console:**

1. Open your `-retention-demo` bucket, select `claim_001.docx`, and **Delete** it (confirm).
2. Go back to the **Buckets** list, select your `-retention-demo` bucket, and click **Delete** (or open the bucket and use the **Delete bucket** button).
3. A confirmation window appears — **type `DELETE`** to confirm, then delete.

> [!NOTE]
> **💻 Also via CLI (optional) — in Cloud Shell.**
>
> ```bash
> gcloud storage rm gs://${DEMO_BUCKET}/records/claim_001.docx
> gcloud storage buckets delete gs://${DEMO_BUCKET}
> ```

> [!WARNING]
> You **cannot** delete a bucket that still has objects under an active retention period. If cleanup fails, wait 60+ seconds for the retention period to expire, then retry. **Never** apply retention lock to your `-raw` landing-zone bucket.

## How this connects to the core lab

| Core lab (Part 3) | This optional lab |
| :--- | :--- |
| Lifecycle: move to Nearline / delete after N days | Retention: *cannot delete* until period ends |
| Q6: 7-year regulatory rewrite | Bucket Lock: make that retention **immutable** |
| Versioning (Part 3) | Retention: protect specific objects from overwrite/delete |