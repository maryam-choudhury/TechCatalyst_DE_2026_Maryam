# Week 1 · Day 3: Lab

**Theme:** Developer foundations (Git and GitHub deep dive, plus VS Code, Codespaces, and Python environments)
**Format:** Three guided labs in pairs (navigator and driver, swap every 30 min). Labs A and B are quick for this cohort (~30–40 min each); Lab C is the team-workflow payload.

> **AI-Free Zone (Weeks 1 to 4).** Type every command yourself. No Copilot, no LLM-generated code, SQL, or Git commands. Read the errors; debug first.

## Lab Index

### Provided files

| File | What it is |
| :--- | :--- |
| [README.md](README.md) *(this file)* | Lab index, schedule, and deliverables |
| [Lab_A_Repo_and_Environment.md](Lab_A_Repo_and_Environment.md) | Lab A: repo, Codespace and budget, venv/pip, read data, the local Git cycle |
| [Lab_B_Local_Meets_Remote.md](Lab_B_Local_Meets_Remote.md) | Lab B: connect to GitHub, push, pull, clone, fetch/merge (with the 403 fix) |
| [Lab_C_Branch_PR_Merge.md](Lab_C_Branch_PR_Merge.md) | Lab C: branch, pull request, merge — the team workflow (Week 2 on-ramp) |
| [Lab_D_Profile_Page.md](Lab_D_Profile_Page.md) | Lab D (Fun Lab): build your GitHub profile / personal branding page |
| [Knowledge_Check.md](Knowledge_Check.md) | Ungraded 12-question check for the wrap-up |
| [Day3_Quiz_MarkdownMash.md](Day3_Quiz_MarkdownMash.md) | The same 12 questions in Markdown Mash format for the live game |
| [GitHub Troubleshooting.md](GitHub%20Troubleshooting.md) | Common auth, Codespace, and Git errors with fixes |
| [Student_Resources.md](Student_Resources.md) | VS Code, Codespaces budget, venv/pip/conda/uv, and Git references |
| [data/hartford_claims_sample.csv](data/hartford_claims_sample.csv) | 12-row sample of Hartford-style claims data for Lab A |
| [solutions/](solutions/) | Lab A and Lab B solution keys (instructor; shared after the labs). Lab C answers (Q1–Q5) are in the lab file. |

### Suggested timing

| Time | Block |
| :--- | :--- |
| 10:15 to 11:00 | Lab A: Your repo and your environment (about 40 min) |
| 1:00 to 1:45 | Lab B: Local meets remote (about 40 min) |
| 1:45 to 2:30 | Lab C: Branch, PR, and merge (about 30–40 min) |
| 2:30 to 3:00 | Lab D (Fun Lab): your GitHub profile page (about 20–30 min) |

*(Times are a guide. This cohort knows Git basics, so A and B run fast; let Lab C be the main hands-on event and close the day with the Lab D profile page.)*

### Deliverables

| # | Deliverable | Format | From | Due |
| :--- | :--- | :--- | :--- | :--- |
| 1 | Pushed `techcatalyst-2026-<yourname>` repo with `hello_data.py`, `data/hartford_claims_sample.csv`, `requirements.txt`, `.gitignore` | GitHub repo | Lab A + B | End of day |
| 2 | Completed Part 5 verification checklist committed into `README.md` | Markdown in repo | Lab A | End of day |
| 3 | At least 3 commits visible in `git log --oneline`, partner-verified | Git history | Lab A | End of day |
| 4 | A clone of your repo verified to match (`journal-clone`) | Git history | Lab B | End of day |
| 5 | About section merged into `main` via a pull request; branch deleted; Q1–Q5 noted | Notes + repo | Lab C | End of day |
| 6 | A GitHub profile page live at `github.com/<username>` (the `<username>/<username>` repo) | GitHub profile | Lab D | End of day |

---

## How the day fits together

Lab A is **entirely local** to your Codespace: you build and verify your environment and practice the solo Git cycle (status, add, diff, commit, log) without touching GitHub. Lab B then **connects local to remote**: push, pull, clone, and fetch/merge, so you understand that your machine and GitHub are two separate copies that only sync when you say so. Lab C steps up to the **team workflow** — branch, pull request, review, merge — on your own repo, the on-ramp to the shared-repo collaboration and merge conflicts you cover in full on Week 2 Day 1. Lab D (the Fun Lab) closes the day by turning everything you learned into your own **GitHub profile page** — a personal branding page you grow every week of the program.

## Troubleshooting

See `GitHub Troubleshooting.md` in this folder. The most common live issue is the Codespaces 403 on first push; both labs handle it with Path A (recommended) and Path B (PAT plus bypass). Stuck more than 10 minutes? Raise a hand; debugging together is the point, but so is finishing.
