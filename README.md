## Overview

This repository is the replication of Hilton, Bell, and Marinov’s ASE 2018 paper *A large-scale study of test coverage evolution*. 

### 1. Project Title and Overview

- **Paper Title**: A large-scale study of test coverage evolution
- **Authors**: Michael Hilton (Carnegie Mellon University), Jonathan Bell (George Mason University), Darko Marinov (University of Illinois Urbana–Champaign)
- **Replication Team**: Pragya, Rabeya
- **Course**: CS-UH 3260 Software Analytics, NYUAD
- **Brief Description**:
  - The paper analyzes a large dataset of per-commit code coverage for Java and JavaScript projects on GitHub. It studies how patch-level coverage relates to overall coverage, how patches affect coverage of unchanged code, and how often “occluded” changes occur (coverage barely moves at the project level while many lines still change covered/uncovered status).
  - This replication uses the CSVs in `datasets/` and the R scripts in `replication_scripts/` to rebuild the paper’s main figures (RQ1–RQ3), Table 1 (LaTeX), and a comparison table (`outputs/tables/rq1_rq2_rq3_comparison.csv`) against the statistics reported in the ASE’18 paper.

### 2. Repository Structure

```
.
├── README.md
├── datasets/
├── replication_scripts/
├── outputs/
│   ├── figures/              # RQ1–RQ3 PDFs (current BuildEntirePaper.R run)
│   ├── tables/               # PatchSizeSummary.tex, rq1_rq2_rq3_comparison.csv
│   ├── coverage_sparklines/  # optional: per-project sparkline .tex (PatchSummaryTable.R)
│   └── coverage_rq123/       # extra copy: figures + PatchSizeSummary from an earlier run
└── logs/                     # optional evidence (e.g. console screenshot)
```

- **`README.md`** — Course-style documentation (this file).

- **`datasets/`** — Static CSV inputs. `BuildEntirePaper.R` reads, among others: `coverage_EOL.csv` and `coverage_jacoco_EOL.csv` (per-build coverage rows), `upTo1000PerLang.rand.csv` and `projects_jacoco.csv` (project lists), `shaOrders.csv` (commit order), `project_sources.csv`, and `flapping_coveralls.csv` / `flapping_jacoco.csv` (combined in-script for flapping-line samples). Also present: `coverage.csv` and `coverage_jacoco.csv` (broader/raw tables). `find_latest_dates.py` reads `coverage.csv` and writes `latest_dates.csv`; that path is separate from `BuildEntirePaper.R`. `ShaAndTime.csv` and `branches_uniq.csv` are in the repo but not wired into the current `BuildEntirePaper.R` merge (related lines are commented out in the script).

- **`replication_scripts/`** — All executable analysis code. **`BuildEntirePaper.R`** loads and merges data into `allData`, filters projects, then `source()`s the rest in order: **`PatchSummaryTable.R`** (Table 1 → `outputs/tables/PatchSizeSummary.tex`), **`coverageOfNewLines.R`** (RQ1 → `outputs/figures/coverageofnewlines.pdf`), **`patchImpactOnOverallCoverage.R`** (RQ2 → `outputs/figures/patchImpact.pdf`), **`occluded_changes_barplot.R`** (RQ3 → `outputs/figures/occludedImpact.pdf`), **`corrolatePatchCovWithChange.R`** (Kendall correlation printout), **`comparison_to_paper.R`** (comparison table → `outputs/tables/rq1_rq2_rq3_comparison.csv`). **`find_latest_dates.py`** is a small Python helper for date metadata, not part of the main `Rscript BuildEntirePaper.R` chain. If you plot from the R console, R may create **`Rplots.pdf`** here; it is not required for the replication.

- **`outputs/`** — Generated artifacts only; safe to delete and recreate by rerunning the pipeline. **`figures/`** holds the three main PDFs. **`tables/`** holds the LaTeX table and the RQ1–RQ3 comparison CSV. **`coverage_sparklines/`** appears when `PatchSummaryTable.R` writes sparklines. **`coverage_rq123/`** duplicates figures (and a `PatchSizeSummary.tex`) from a previous run; kept for reference but not special-cased by the scripts.

- **`logs/`** — Not read by any script; use for screenshots or saved terminal output.

### 3. Setup Instructions

- **Prerequisites**: Required software, tools, and versions
  - **OS**: macOS, Linux, or Windows. No Docker or database is required; everything is file-based under `datasets/`.
  - **R**: Version **4.x** is what we used. Older 3.x may work but is untested. You need a writable repo checkout (several hundred MB with CSVs).
  - **R packages** (install from CRAN): **`readr`**, **`plyr`**, **`reshape2`**, **`ggplot2`**, **`stringr`**, **`dplyr`**, **`xtable`**. **`parallel`** ships with R and is loaded via `library(parallel)` / `require(parallel)` in some scripts; no extra install step beyond a normal R build.
  - **Other**: No API keys, tokens, or environment variables. A PDF viewer helps to inspect `outputs/figures/*.pdf`.

- **Installation Steps**: Step-by-step instructions to set up the environment
  1. Clone or unzip the repository.
  2. Start R and install dependencies once, for example:
     ```r
     install.packages(c("readr", "plyr", "reshape2", "ggplot2", "stringr", "dplyr", "xtable"))
     ```
  3. In a terminal, run the full analysis from **`replication_scripts/`** (this matters: all paths are `../datasets/...` and `../outputs/...` relative to that folder):
     ```bash
     cd replication_scripts
     Rscript BuildEntirePaper.R
     ```
    The script prints build/project counts, writes figures under `../outputs/figures/`, tables under `../outputs/tables/`, and may create `../outputs/coverage_sparklines/` when sparklines are generated.
4. **`replication_scripts/`** 
  5. **Paths / settings**: Do not rename `datasets/` or `outputs/`. Do not set `R_LIBS`. Interactive use: if you `source("BuildEntirePaper.R")` from R, `setwd(".../replication_scripts")` first.

### 4. GenAI Usage

**GenAI Usage**: Rabeya: I used Claude to undertsnad the datasets and the replication scripts. Since I did not know R from before, I had to understand the language syntax. how it works and I needed AI for that. And I also used cursor IDE and took help with writing the comparison (for Syntax and usages of R) using claude in it. 
