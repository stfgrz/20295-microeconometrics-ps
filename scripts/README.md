# Scripts Directory

This directory contains reusable analysis scripts and utilities for the 20295 Microeconometrics course.

## Structure:

- **`stata/`**: Stata do-files and utilities
  - `utils.do`: Path management and common functions
  - `template.do`: Template for new problem sets
  - Shared analysis functions and procedures

- **`r/`**: R scripts and utilities  
  - `template.R`: Template for R-based problem sets
  - Helper functions and data processing utilities

## Usage:

### Stata Scripts:
```stata
* Include path utilities at the beginning of problem set scripts
do "scripts/stata/utils.do"
init_paths 1  // Replace 1 with problem set number
```

### R Scripts:
```r
# Source utilities and templates
source("scripts/r/template.R")  # Includes path setup
```

## Guidelines:

1. **Modularity**: Create reusable functions rather than copying code
2. **Documentation**: Comment functions thoroughly
3. **Testing**: Test utilities with different problem sets
4. **Templates**: Use provided templates for consistency across problem sets

## Problem Set Scripts:

Individual problem set scripts remain in their respective `ps*/` directories, but should use utilities from this directory for path management and common operations.