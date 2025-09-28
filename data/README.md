# Data Directory

This directory contains all datasets used in the 20295 Microeconometrics course problem sets.

## Structure:

- **`raw/`**: Original, unmodified datasets
  - Should contain source data files as downloaded/received
  - Large or sensitive files should be added to `.gitignore`
  - Document data sources and acquisition dates

- **`interim/`**: Intermediate processed datasets
  - Partially cleaned or transformed data
  - Files created during multi-step data processing workflows

- **`processed/`**: Final analysis-ready datasets
  - Fully cleaned and prepared data for analysis
  - These files should be directly usable by analysis scripts

## Guidelines:

1. **Raw data preservation**: Never modify files in `raw/` - always create copies for processing
2. **Documentation**: Include data dictionaries and source information
3. **Reproducibility**: All data transformations should be scripted and documented
4. **Size management**: Large files (>100MB) should be stored externally or added to `.gitignore`

## Current Problem Set Data:

Problem set-specific data remains in the individual `ps*/ps*_data/` directories for convenience, but consider migrating to this centralized structure for better organization.