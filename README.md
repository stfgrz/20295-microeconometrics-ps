# 20295 — Microeconometrics Problem Sets (A.Y. 2024/2025)

Microeconometrics problem sets for the academic year 2024/2025.

- Repository: [stfgrz/20295-microeconometrics-ps](https://github.com/stfgrz/20295-microeconometrics-ps)
- License: MIT
- Primary language: Stata
- Last updated: 2025-05-15

---

## Table of contents

- [Overview](#overview)
- [Languages and tooling](#languages-and-tooling)
- [Getting started](#getting-started)
- [Running the analyses](#running-the-analyses)
  - [Stata (.do) workflows](#stata-do-workflows)
  - [R scripts](#r-scripts)
  - [LaTeX reports](#latex-reports)
  - [JavaScript utilities/visualizations](#javascript-utilitiesvisualizations)
- [Data layout and paths](#data-layout-and-paths)
- [Reproducibility notes](#reproducibility-notes)
- [Project structure (suggested)](#project-structure-suggested)
- [Contributing](#contributing)
- [Contributors](#contributors)
- [License](#license)

---

## Overview

This repository collects code and materials used to solve and document microeconometrics problem sets. The code base is Stata-first, with some complementary R scripts, LaTeX sources for write-ups, and occasional JavaScript utilities (e.g., for simple, static visualizations or helper tooling).

If you are taking or reviewing the course, you can use this repository to:
- Reproduce analyses for each problem set.
- Inspect and adapt Stata and R code for similar exercises.
- Compile accompanying reports from LaTeX sources.

> Note: The repository content may evolve during the course; please pull regularly for updates.

---

## Languages and tooling

Measured by bytes of code in the repository:
- Stata ≈ 66.8%
- JavaScript ≈ 24.0%
- R ≈ 5.4%
- TeX ≈ 3.7%

Recommended tooling:
- Stata (SE/MP; recent version recommended)
- R (≥ 4.0) with CRAN packages as indicated in individual scripts
- A LaTeX distribution (e.g., TeX Live, MikTeX, or TinyTeX) to build reports
- Optional: Node.js (if you plan to run any JavaScript-based utilities locally)

---

## Getting started

1. Clone the repository:
   ```
   git clone https://github.com/stfgrz/20295-microeconometrics-ps.git
   cd 20295-microeconometrics-ps
   ```

2. Ensure you have Stata installed. If you plan to run R parts, install R and RStudio (optional but convenient). For LaTeX, ensure `latexmk` or `pdflatex` is available on your PATH.

3. Review the header comments of the relevant scripts/do-files for:
   - Required packages or ado files
   - Expected data locations
   - Any run order or prerequisites

---

## Running the analyses

### Stata (.do) workflows

**✨ NEW: Improved Path Management**
All Stata scripts now use automatic path detection - no need to edit paths!

From within Stata (GUI):
```
cd "PATH/TO/20295-microeconometrics-ps"
do "ps1/20295-ps1_g1.do"      // For PS1
do "ps2/20295-ps2_g1.do"      // For PS2  
do "ps3/20295-ps3_g1.do"      // For PS3
```

From the command line (example for Unix-like systems; adjust `stata-mp`/`stata-se` to your edition):
```
stata-mp -b do path/to/the/problemset.do
```

General tips:
- Set your working directory to the repository root or a folder that the do-files expect.
- Many projects use a top-level “master” or “run_all” do-file; if present, prefer running that to orchestrate sub-steps.
- If ado dependencies are needed, scripts may auto-install them via `ssc install ...`; otherwise, install them manually in Stata.

### R scripts

Run from R/RStudio:
```r
# Set working directory to the repo root
setwd("PATH/TO/20295-microeconometrics-ps")

# Install packages as needed (check the script header)
# install.packages(c("data.table", "dplyr", "ggplot2"))  # example

source("path/to/script.R")
```

If the repository uses a project-local package manager (e.g., `renv`), initialize it before running:
```r
install.packages("renv")
renv::init()     # or renv::restore() if a lockfile is present
```

### LaTeX reports

Compile with `latexmk` (recommended):
```
cd PATH/TO/20295-microeconometrics-ps
latexmk -pdf path/to/report.tex
```

Or with `pdflatex` (may need multiple passes):
```
pdflatex path/to/report.tex
bibtex   path/to/report     # if bibliography is used
pdflatex path/to/report.tex
pdflatex path/to/report.tex
```

### JavaScript utilities/visualizations

If a `package.json` is present in a subfolder:
```
cd path/to/js/folder
npm install
npm run build   # or `npm start` depending on the script definitions
```

For static HTML/JS visualizations, you can serve the folder locally (e.g., with Python):
```
python -m http.server 8000
# then visit http://localhost:8000/path/to/index.html
```

---

## Data layout and paths

The repository now follows a standardized layout for better organization:

```
data/
  raw/        # unmodified source data (not committed if sensitive/large)
  interim/    # intermediate files created by scripts
  processed/  # cleaned/analysis-ready data
outputs/
  figures/    # plots, graphs, and visualizations
  tables/     # analysis results and summary tables
  logs/       # analysis logs and computational outputs
scripts/      # reusable utilities and templates
  stata/      # Stata utilities and templates
    utils.do      # path management and common functions
    template.do   # standardized template for new scripts
  r/          # R utilities and templates
    template.R    # standardized template for R scripts
reports/      # LaTeX sources and compiled reports
ps1/, ps2/, ps3/  # individual problem set files and data
```

### Path Management

All problem set scripts now use **automatic path detection** instead of hardcoded paths:

```stata
* In Stata scripts - this replaces user-specific hardcoded paths
do "../scripts/stata/utils.do"
init_paths 1  // Replace 1 with problem set number

* Now you can use standardized globals:
use "${ps_data}/dataset.dta", clear
esttab using "${ps_output}/results.tex", replace
```

Guidelines:
- **No more hardcoded paths**: Scripts automatically detect the project root
- **Portable scripts**: Code works on any system without modification
- **Standardized outputs**: All outputs go to designated directories
- **Use relative paths**: All paths are relative to the project root

---

## Reproducibility notes

- Stata: consider setting the RNG version and seed at the top of do-files:
  ```
  version 18.0
  set seed 123456
  ```
- R: set a seed where simulations/bootstraps are used:
  ```r
  set.seed(123456)
  ```
- Capture package versions (e.g., `about` in Stata; `sessionInfo()` in R) into logs to help reproduce historical runs.
- Keep data transformations scripted; avoid manual “point-and-click” steps.

---

## Project structure (suggested)

Below is a suggested structure if you are extending the repository. Use or adapt as needed.

```
20295-microeconometrics-ps/
├─ scripts/
│  ├─ stata/
│  │  ├─ ps01.do
│  │  ├─ ps02.do
│  │  └─ utils.do
│  ├─ r/
│  │  ├─ helpers.R
│  │  └─ diagnostics.R
│  └─ js/
│     └─ (optional utilities)
├─ data/
│  ├─ raw/         (not tracked if sensitive/large)
│  ├─ interim/
│  └─ processed/
├─ outputs/
│  ├─ figures/
│  ├─ tables/
│  └─ logs/
├─ reports/
│  ├─ ps01-report.tex
│  └─ ps02-report.tex
├─ .gitignore
├─ LICENSE
└─ README.md
```

---

## Contributing

- Open an issue to propose changes, report bugs, or request clarifications.
- For code changes, create a feature branch and open a pull request. Please include:
  - A short description and motivation
  - Any relevant references (papers, lecture notes)
  - Reproducibility steps (how to run your changes)
- Keep scripts idempotent where possible (re-running should not break)

---

## Contributors

- Stefano Graziosi
- Gabriele Molè
- Sofia Briozzo

---

## License

This project is released under the MIT License. See the [LICENSE](LICENSE) file for details.
