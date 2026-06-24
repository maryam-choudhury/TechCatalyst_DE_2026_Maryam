# Week 1 · Day 3: Student Resources

> **AI-Free Zone (Weeks 1 to 4):** Today is where the rule gets real: type every command yourself. No Copilot autocompleting your Git, venv, or environment steps. Building this muscle memory now is what lets you trust (and challenge) AI suggestions in Week 6.

Reference links and cheat sheets for today's tools. Keep these bookmarked; you will use them all summer.

## Core Documentation

| Resource | Why it helps |
| :--- | :--- |
| [GitHub Codespaces docs](https://docs.github.com/en/codespaces) | Your dev environment for the whole program; start here |
| [About billing for Codespaces](https://docs.github.com/en/billing/managing-billing-for-your-products/managing-billing-for-github-codespaces/about-billing-for-github-codespaces) | 120 core-hours and 15 GB per month; know why you stop your Codespace |
| [Python venv docs](https://docs.python.org/3/library/venv.html) | The authoritative reference on isolated environments |
| [pip user guide](https://pip.pypa.io/en/stable/user_guide/) | How install, freeze, and requirements.txt actually work |
| [uv documentation](https://docs.astral.sh/uv/) | The fast all-in-one tool: projects, add vs sync, lock files |
| [conda docs](https://docs.conda.io/projects/conda/en/stable/) | Environments plus packages, including non-Python binaries |
| [Git cheat sheet (GitHub Education)](https://education.github.com/git-cheat-sheet-education.pdf) | One page with every command you need for four weeks |
| [.gitignore templates](https://github.com/github/gitignore) | Use `Python.gitignore` so `.venv/` never gets committed |

---

## VS Code

**Keyboard shortcuts (PDF):** [Linux/Windows](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf) · [macOS](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf)

The three you need today: `Ctrl/Cmd+Shift+P` (command palette), `Ctrl+backtick` (terminal), `Ctrl/Cmd+P` (quick open file). Learn five more per week.

**VS Code docs:** https://code.visualstudio.com/docs (start with "User Interface" and "Python"). The Source Control panel does add, commit, and diff with buttons: the same Git you type, a different steering wheel.

---

## GitHub Codespaces and budget

**Codespaces docs:** https://docs.github.com/en/codespaces

**Billing and free-tier limits:** https://docs.github.com/en/billing/managing-billing-for-your-products/managing-billing-for-github-codespaces/about-billing-for-github-codespaces
Personal accounts get 120 core-hours and 15 GB of storage per month free. A 2-core Codespace uses those hours in about 60 hours of active time; a 4-core in about 30. **Stop your Codespace when you are not using it.** Stopping keeps your state (and still uses storage); deleting frees storage but loses uncommitted work, so push first. The billing page shows where your hours and storage go.

**Codespace lifecycle (stop, restart, delete):** https://docs.github.com/en/codespaces/getting-started/the-codespace-lifecycle

---

## Python environments

You saw four tools today. Two axes: isolate the environment, and manage the packages.

| Tool | Isolates env | Manages packages | Reach for it when |
| :--- | :--- | :--- | :--- |
| venv | Yes | No | Always available; the standard-library way to isolate |
| pip | No | Yes | Installing from PyPI into the active environment |
| conda | Yes | Yes | You need non-Python or scientific binaries |
| uv | Yes | Yes | You want one fast tool plus a lock file |

**Python venv (official):** https://docs.python.org/3/library/venv.html
**Real Python venv primer:** https://realpython.com/python-virtual-environments-a-primer/ (read this before Week 2 if venvs felt shaky)
**pip user guide:** https://pip.pypa.io/en/stable/user_guide/

**uv (Astral):** https://docs.astral.sh/uv/
Why it is gaining adoption: it is fast (compiled and parallelized), it is one tool instead of several (venv, pip, pip-tools), and it locks dependencies by default for reproducibility. Key ideas: `uv add` records a new dependency and relocks; `uv sync` makes your machine match the lock file exactly; `uv.lock` pins every direct and transitive version; `uv run` executes inside the environment without manual activation. See [Projects](https://docs.astral.sh/uv/concepts/projects/) and [Locking and syncing](https://docs.astral.sh/uv/concepts/projects/sync/).

**conda:** https://docs.conda.io/projects/conda/en/stable/ and [conda-forge](https://conda-forge.org/). conda manages both environments and packages, including non-Python system libraries that pip cannot install. Packages come from channels (conda-forge is the big community one). Mixing conda and pip works but needs care: install conda packages first, then pip, and do not double-install the same package.

> **Course baseline:** we use venv plus pip plus requirements.txt across the program. conda and uv are for breadth and modern awareness; the optional Lab A stretch lets you try uv.

---

## Git and GitHub

**Git cheat sheet (PDF):** https://education.github.com/git-cheat-sheet-education.pdf (print it or keep it open)
**Git official reference:** https://git-scm.com/docs (look up exactly what a command does)
**Pro Git book (free):** https://git-scm.com/book/en/v2 (chapters 2 and 3 cover everything in today's deep dive)
**"Git and GitHub for Beginners" (freeCodeCamp video, about 1 hour):** https://www.youtube.com/watch?v=RGOj5yH7evk (watch the first 30 minutes tonight if today felt fast)
**.gitignore templates:** https://github.com/github/gitignore (copy `Python.gitignore`)
**Removing sensitive data from a repo:** https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository (the answer to a leaked secret is rotate first)
**Conventional commits:** https://www.conventionalcommits.org/ (not required this week; we adopt it in the longitudinal project from Week 3)

---

## Troubleshooting

**Course guide:** see `GitHub Troubleshooting.md` in this folder (auth errors, Codespace boot failures, common Git mistakes). The most common live issue is the 403 on first push from a blank Codespace; Lab B handles it two ways.
**GitHub status page:** https://githubstatus.com (if Codespaces will not launch and nothing else explains it, check here first).

---

## Lab Deliverable Checklist

| ✓ | Deliverable |
| :--- | :--- |
| ☐ | `techcatalyst-2026-<yourname>` repo created with a README (name, cohort, bio) |
| ☐ | Codespace starts and stops; you know where the stop button is |
| ☐ | `.venv` activated (prompt shows `(.venv)`); `requirements.txt` lists pandas and requests |
| ☐ | `hello_data.py` reads the sample CSV and prints per-state totals and a `200` |
| ☐ | `.venv/` is git-ignored and does not appear in `git status` |
| ☐ | At least 3 commits visible in `git log --oneline` |
| ☐ | Repo published to GitHub; a clone verified to match (Lab B) |
| ☐ | Partner has verified every checklist item on your machine |
