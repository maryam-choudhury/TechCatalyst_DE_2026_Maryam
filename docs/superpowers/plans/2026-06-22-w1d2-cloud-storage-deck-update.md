# W1D2 Cloud Storage Deck Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce a visually verified 28-slide update of the Week 1 Day 2 Cloud Fundamentals deck with equal-weight GCP/AWS service awareness, a six-slide object-storage deep dive, and revised BigQuery/architecture activity slides.

**Architecture:** Treat the existing PPTX as the sole template. Inspect and duplicate source slides into a 28-slide starter deck, then edit inherited objects with `@oai/artifact-tool`; preserve the original deck and export an adjacent `- Updated.pptx` copy. Store all scripts, renders, maps, layouts, and QA evidence in the external presentation scratch workspace.

**Tech Stack:** Node.js ES modules, `@oai/artifact-tool`, bundled presentation template-following scripts, PowerPoint/PPTX, official AWS and Google Cloud documentation.

---

## File Structure

- Source, preserve: `Week 1/Slides/W1D2 - Cloud Fundamentals.pptx`
- Final deliverable: `Week 1/Slides/W1D2 - Cloud Fundamentals - Updated.pptx`
- Approved design: `docs/superpowers/specs/2026-06-22-w1d2-cloud-storage-deck-update-design.md`
- This plan: `docs/superpowers/plans/2026-06-22-w1d2-cloud-storage-deck-update.md`
- Scratch root: `$TMPDIR/codex-presentations/manual-w1d2-cloud-storage/w1d2-cloud-fundamentals/tmp`
- Authoring module: `$TMP_DIR/build_w1d2_cloud_storage.mjs`
- Template map: `$TMP_DIR/template-frame-map.json`
- Template audit: `$TMP_DIR/template-audit.txt`
- Intentional changes: `$TMP_DIR/deviation-log.txt`
- Sources and claim ledger: `$TMP_DIR/source-notes.txt`
- Starter: `$TMP_DIR/template-starter.pptx`
- Final renders: `$TMP_DIR/preview/final/`
- Final layout JSON: `$TMP_DIR/layout/final/`
- QA ledger: `$TMP_DIR/qa/final-qa.txt`

### Task 1: Establish Source and Acceptance Baseline

**Files:**
- Read: `Week 1/Slides/W1D2 - Cloud Fundamentals.pptx`
- Read: `docs/superpowers/specs/2026-06-22-w1d2-cloud-storage-deck-update-design.md`
- Create: `$TMP_DIR/qa/baseline-check.txt`

- [ ] **Step 1: Record the source checksum and assert the source has 21 slides**

Run:

```bash
SOURCE="$PWD/Week 1/Slides/W1D2 - Cloud Fundamentals.pptx"
FINAL="$PWD/Week 1/Slides/W1D2 - Cloud Fundamentals - Updated.pptx"
shasum -a 256 "$SOURCE" > "$TMP_DIR/qa/source.sha256"
jq -e '.slideCount == 21' "$TMP_DIR/template-inspect/template-manifest.json"
test ! -e "$FINAL"
```

Expected: `jq` prints `true`; the final-file assertion succeeds.

- [ ] **Step 2: Write an executable acceptance check before authoring**

Create `$TMP_DIR/check_final.mjs`:

```js
import fs from "node:fs/promises";
import { FileBlob, PresentationFile } from "@oai/artifact-tool";

const finalPath = process.argv[2];
const deck = await PresentationFile.importPptx(await FileBlob.load(finalPath));
const required = [
  "Core DE capabilities across two clouds",
  "Object storage is the cloud landing zone",
  "A bucket alone is not a data lake",
  "Managed Iceberg on both clouds",
  "Activity 1: BigQuery Sandbox",
  "Activity 2: You're the architect",
];
const inventory = await deck.inspect({ kind: "slide,textbox,table,notes", maxChars: 50000 });
const text = inventory.ndjson;
if (deck.slides.items.length !== 28) throw new Error(`Expected 28 slides, received ${deck.slides.items.length}`);
for (const phrase of required) {
  if (!text.toLowerCase().includes(phrase.toLowerCase())) throw new Error(`Missing required phrase: ${phrase}`);
}
console.log("PASS: 28 slides and all required content markers found");
```

- [ ] **Step 3: Run the acceptance check and verify the red state**

Run:

```bash
node "$TMP_DIR/check_final.mjs" "$FINAL"
```

Expected: failure because the final PPTX does not exist.

### Task 2: Complete Template Inventory and Mapping

**Files:**
- Read: `$TMP_DIR/template-inspect/template-inspect.ndjson`
- Read: `$TMP_DIR/template-inspect/layouts/source-slide-*.layout.json`
- Create: `$TMP_DIR/template-audit.txt`
- Create: `$TMP_DIR/template-frame-map.json`
- Create: `$TMP_DIR/deviation-log.txt`
- Create: `$TMP_DIR/source-notes.txt`

- [ ] **Step 1: Audit source layouts and inherited objects**

Record these reuse decisions in `$TMP_DIR/template-audit.txt`:

```text
Source slide 2: agenda table; rewrite agenda rows only.
Source slide 6: equal two-column comparison; reuse for slides 19 and 20.
Source slide 9: three-stage concept layout; reuse for slide 15.
Source slide 13: three-column capability table; reuse for slides 13 and 17.
Source slide 14: six-card capability grid; reuse for slides 14, 16, and 18.
Source slide 20: activity brief; reuse for slides 26 and 27.
Source slide 21: numbered recap; rewrite storage/activity takeaways.
All other source slides: preserve content and inherited chrome.
Typography: Trebuchet MS headings/body as inherited; do not shrink text.
Chrome: preserve red top rail, footer, and page-number structure.
```

- [ ] **Step 2: Create the full 28-slide frame map**

Create `$TMP_DIR/template-frame-map.json` with this source sequence:

```json
{
  "outputSlides": [
    {"outputSlide":1,"sourceSlide":1,"narrativeRole":"title","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":2,"sourceSlide":2,"narrativeRole":"agenda","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":3,"sourceSlide":3,"narrativeRole":"why cloud","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":4,"sourceSlide":4,"narrativeRole":"landscape","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":5,"sourceSlide":5,"narrativeRole":"service models","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":6,"sourceSlide":6,"narrativeRole":"service model contrast","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":7,"sourceSlide":7,"narrativeRole":"service model visual","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":8,"sourceSlide":8,"narrativeRole":"service model visual","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":9,"sourceSlide":9,"narrativeRole":"shared responsibility","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":10,"sourceSlide":10,"narrativeRole":"service model visual","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":11,"sourceSlide":11,"narrativeRole":"service model visual","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":12,"sourceSlide":12,"narrativeRole":"gcp aws section","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":13,"sourceSlide":13,"narrativeRole":"core capability map","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":14,"sourceSlide":14,"narrativeRole":"pipeline capability map","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":15,"sourceSlide":9,"narrativeRole":"object storage foundation","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":16,"sourceSlide":14,"narrativeRole":"shared object storage capabilities","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":17,"sourceSlide":13,"narrativeRole":"gcs s3 differences","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":18,"sourceSlide":14,"narrativeRole":"data lake components","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":19,"sourceSlide":6,"narrativeRole":"objects versus tables","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":20,"sourceSlide":6,"narrativeRole":"managed iceberg comparison","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":21,"sourceSlide":15,"narrativeRole":"iam section","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":22,"sourceSlide":16,"narrativeRole":"iam","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":23,"sourceSlide":17,"narrativeRole":"billing","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":24,"sourceSlide":18,"narrativeRole":"cost mistakes","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":25,"sourceSlide":19,"narrativeRole":"console orientation","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":26,"sourceSlide":20,"narrativeRole":"bigquery activity","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":27,"sourceSlide":20,"narrativeRole":"architecture activity","reuseMode":"duplicate-slide","editTargets":[]},
    {"outputSlide":28,"sourceSlide":21,"narrativeRole":"recap","reuseMode":"duplicate-slide","editTargets":[]}
  ],
  "omittedSourceSlides": []
}
```

Before validation, populate `editTargets` for every rewritten inherited textbox/table/placeholder using the `aid` values from the corresponding source layout JSON. Mark unchanged objects as `keep`, rewritten objects as `rewrite`, and obsolete inherited content as `delete`.

- [ ] **Step 3: Validate the frame map**

Run:

```bash
node "$SKILL_DIR/template_following_scripts/validate_template_plan.mjs" \
  --workspace "$TMP_DIR" \
  --map "$TMP_DIR/template-frame-map.json"
```

Expected: exit code 0 with every rewrite target resolved to a source element.

### Task 3: Build and Inspect the 28-Slide Starter

**Files:**
- Create: `$TMP_DIR/template-starter.pptx`
- Create: `$TMP_DIR/template-starter-preview/`
- Create: `$TMP_DIR/template-starter-layout/`

- [ ] **Step 1: Generate the starter deck from mapped source slides**

Run:

```bash
node "$SKILL_DIR/template_following_scripts/prepare_template_starter_deck.mjs" \
  --workspace "$TMP_DIR" \
  --pptx "$SOURCE" \
  --map "$TMP_DIR/template-frame-map.json" \
  --out "$TMP_DIR/template-starter.pptx" \
  --preview-dir "$TMP_DIR/template-starter-preview" \
  --layout-dir "$TMP_DIR/template-starter-layout" \
  --contact-sheet "$TMP_DIR/template-starter-contact-sheet.png"
```

Expected: a 28-slide starter, 28 PNGs, 28 layout JSON files, and a contact sheet.

- [ ] **Step 2: Inspect starter slide count and inherited placeholders**

Run:

```bash
test "$(find "$TMP_DIR/template-starter-preview" -name '*.png' | wc -l | tr -d ' ')" = 28
rg -n 'Click to add|Slide Number|Date|Footer' "$TMP_DIR/template-starter-layout" && exit 1 || true
```

Expected: 28 renders and no visible default placeholder prompts.

### Task 4: Author Revised Overview and Storage Slides

**Files:**
- Create: `$TMP_DIR/build_w1d2_cloud_storage.mjs`
- Modify via export: `Week 1/Slides/W1D2 - Cloud Fundamentals - Updated.pptx`

- [ ] **Step 1: Implement inherited-object editing helpers**

The module must:

```js
import fs from "node:fs/promises";
import { FileBlob, PresentationFile } from "@oai/artifact-tool";

const starterPath = process.env.STARTER_PPTX;
const outputPath = process.env.FINAL_PPTX;
const deck = await PresentationFile.importPptx(await FileBlob.load(starterPath));

function replaceAll(target, replacements) {
  for (const [from, to] of Object.entries(replacements)) target.text.replace(from, to);
}

function requireSlide(number) {
  const slide = deck.slides.items[number - 1];
  if (!slide) throw new Error(`Missing slide ${number}`);
  return slide;
}

async function save() {
  const pptx = await PresentationFile.exportPptx(deck);
  await pptx.save(outputPath);
}
```

Resolve objects by stable inherited `aid`/shape IDs recorded in the validated frame map. Do not search and blank all text-bearing shapes.

- [ ] **Step 2: Rewrite slides 13–14**

Use the exact capability names and pipeline sequence from the approved design spec. Slide 13 must use headers `Capability`, `Google Cloud`, and `AWS`; it must not contain `primary` or `secondary`. Slide 14 must show the capability order:

```text
Sources → Ingest / events → Object storage → Process / transform → Warehouse / query → Consumers
```

Include IAM, governance/catalog, orchestration, and cost as cross-cutting controls using inherited card slots.

- [ ] **Step 3: Author slides 15–20**

Use the exact learner-facing content in the approved design spec:

```js
const storageSlides = {
  15: {
    title: "Object storage is the cloud landing zone",
    concepts: ["Bucket", "Object + metadata", "Key / prefix"],
    takeaway: "Store any format at elastic scale — but object storage is not a disk or relational database.",
  },
  16: {
    title: "GCS and S3 share the same foundation",
    concepts: ["Buckets & objects", "Storage classes", "IAM", "Encryption", "Lifecycle", "Recovery & retention"],
  },
  17: {
    title: "Same mental model, different controls",
    headers: ["Decision", "Google Cloud Storage", "Amazon S3"],
  },
  18: {
    title: "A bucket alone is not a data lake",
    concepts: ["Objects & formats", "Layout & partitioning", "Schema & catalog", "Compute & query", "Governance & quality", "Lifecycle & cost"],
  },
  19: {
    title: "Objects are not analytical tables",
    left: "Files / objects",
    right: "Analytical table layer",
  },
  20: {
    title: "Managed Iceberg on both clouds",
    left: "AWS S3 Tables",
    right: "GCP Iceberg managed tables",
    takeaway: "A specialized managed table layer — not a replacement for general-purpose GCS or S3.",
  },
};
```

Populate the inherited tables/cards with the complete comparisons from the design spec. Maintain equal column widths and equivalent information density.

- [ ] **Step 4: Add speaker notes and source URLs to slides 15–20**

Each slide note must contain these headings:

```text
Teaching point:
Learner question:
Skip / deeper detail:
Sources:
```

Use only these official URLs:

```text
https://docs.aws.amazon.com/AmazonS3/latest/userguide/
https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingBucket.html
https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables.html
https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-tables-maintenance.html
https://docs.cloud.google.com/storage/docs/introduction
https://docs.cloud.google.com/storage/docs/lifecycle
https://docs.cloud.google.com/storage/docs/object-versioning
https://docs.cloud.google.com/bigquery/docs/biglake-iceberg-tables-in-bigquery
```

- [ ] **Step 5: Export the first authored deck**

Run:

```bash
STARTER_PPTX="$TMP_DIR/template-starter.pptx" \
FINAL_PPTX="$FINAL" \
node "$TMP_DIR/build_w1d2_cloud_storage.mjs"
```

Expected: exit code 0 and a new final PPTX; source checksum remains unchanged.

### Task 5: Align Agenda, Demo, Activities, and Recap

**Files:**
- Modify through `$TMP_DIR/build_w1d2_cloud_storage.mjs`: output slides 2, 25–28
- Read: `Week 1/Labs/Day 2/Activity_1_BigQuery_Sandbox_First_Query.md`
- Read: `Week 1/Labs/Day 2/Activity_2_Cloud_Architecture_Scenarios.md`

- [ ] **Step 1: Rewrite the agenda on slide 2**

The agenda must list the expanded core-service/storage block, IAM/cost, console orientation, BigQuery Sandbox Activity 1 (60 minutes), and architecture Activity 2 (75 minutes) in delivery order.

- [ ] **Step 2: Update slide 25 to console orientation**

Remove the instruction to run the BigQuery query during the demo. Keep project picker, navigation/search, IAM location, billing reports, and finding BigQuery; the learner query runs in Activity 1.

- [ ] **Step 3: Create Activity 1 on slide 26**

Use:

```text
ACTIVITY 1
First query in BigQuery Sandbox
60 min
Goal — experience a managed cloud warehouse and connect query choices to bytes processed.
1. Enable Sandbox with no billing account.
2. Inspect the NYC Citi Bike public table.
3. Run the provided station query and map the result.
4. Compare one-column and SELECT * estimates; predict before changing LIMIT.
Deliverable: Q1–Q7, validator estimates, and the exit ticket in your lab notes.
```

- [ ] **Step 4: Rewrite Activity 2 on slide 27**

Use:

```text
ACTIVITY 2
You're the architect
75 min
Goal — map business requirements to capabilities and defend GCP/AWS service choices.
1. Receive one primary scenario and assign team roles.
2. Decide batch, streaming, or separate paths; connect services in execution order.
3. Identify the trigger, provider-managed responsibilities, cost risk, and PII control.
4. Reject one plausible alternative and prepare a five-minute readout; everyone speaks.
Deliverable: completed worksheet, team readout, and one peer challenge.
```

- [ ] **Step 5: Update slide 28 recap**

The five takeaways must include:

```text
1. Learn capabilities, then translate product names across clouds.
2. Object storage is the common landing-zone foundation: GCS and S3 share a mental model.
3. A bucket needs formats, layout, catalog, governance, and compute to become a usable data lake.
4. S3 Tables and GCP Iceberg managed tables add a managed Iceberg table layer; they do not replace object storage.
5. IAM, cost controls, and deliberate query/storage choices remain your responsibility.
```

- [ ] **Step 6: Re-export and run the acceptance check**

Run:

```bash
STARTER_PPTX="$TMP_DIR/template-starter.pptx" FINAL_PPTX="$FINAL" node "$TMP_DIR/build_w1d2_cloud_storage.mjs"
node "$TMP_DIR/check_final.mjs" "$FINAL"
```

Expected: `PASS: 28 slides and all required content markers found`.

### Task 6: Render and Repair Every Slide

**Files:**
- Create: `$TMP_DIR/preview/final/slide-*.png`
- Create: `$TMP_DIR/layout/final/slide-*.layout.json`
- Create: `$TMP_DIR/preview/final-contact-sheet.png`
- Create: `$TMP_DIR/qa/final-qa.txt`

- [ ] **Step 1: Render all final slides and layout JSON**

Use an artifact-tool QA module to import `$FINAL`, iterate over all slides, export PNG and layout JSON, and export a montage/contact sheet.

Expected: 28 PNG files and 28 layout JSON files.

- [ ] **Step 2: Run automated layout scans**

Run checks for:

```text
text overflow or clipping
unexpected overlaps
empty inherited placeholders
default prompt text
title wrapping
font substitutions
missing footer/page markers
unequal GCP/AWS comparison geometry
```

Record results per slide in `$TMP_DIR/qa/final-qa.txt`.

- [ ] **Step 3: Visually inspect all 28 slides**

Inspect the contact sheet, then open each revised slide (2, 13–20, 25–28) at full size. Correct content length, wrapping, spacing, and visual hierarchy in the authoring module; re-export and re-render after every repair batch.

- [ ] **Step 4: Verify template fidelity**

Run:

```bash
node "$SKILL_DIR/template_following_scripts/check_template_fidelity.mjs" \
  --workspace "$TMP_DIR" \
  --starter-pptx "$TMP_DIR/template-starter.pptx" \
  --final-pptx "$FINAL" \
  --map "$TMP_DIR/template-frame-map.json" \
  --starter-layout-dir "$TMP_DIR/template-starter-layout" \
  --final-layout-dir "$TMP_DIR/layout/final" \
  --edit-dir "$TMP_DIR"
```

Expected: pass with only deviations recorded in `$TMP_DIR/deviation-log.txt`.

### Task 7: Final Verification and Delivery

**Files:**
- Verify: `Week 1/Slides/W1D2 - Cloud Fundamentals - Updated.pptx`
- Verify: `$TMP_DIR/qa/source.sha256`
- Verify: `$TMP_DIR/qa/final-qa.txt`

- [ ] **Step 1: Run all final gates from a clean import**

Run:

```bash
node "$TMP_DIR/check_final.mjs" "$FINAL"
shasum -a 256 -c "$TMP_DIR/qa/source.sha256"
test "$(find "$TMP_DIR/preview/final" -name 'slide-*.png' | wc -l | tr -d ' ')" = 28
test "$(find "$TMP_DIR/layout/final" -name 'slide-*.layout.json' | wc -l | tr -d ' ')" = 28
test -s "$TMP_DIR/qa/final-qa.txt"
```

Expected: all commands exit 0; original checksum reports `OK`.

- [ ] **Step 2: Inspect repository status without staging unrelated work**

Run:

```bash
git status --short
```

Expected: the updated PPTX is visible alongside the user's existing unrelated changes. Do not stage or revert unrelated files.

- [ ] **Step 3: Deliver the verified PPTX**

Report the final absolute path, slide count, major additions, official source families used, and QA result. Cite only the final PPTX in the user-facing response.
