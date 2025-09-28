# Reports Directory

This directory is intended for LaTeX source files and compiled reports for the 20295 Microeconometrics problem sets.

## Structure:

- LaTeX source files (`.tex`)
- Compiled PDFs
- Bibliography files (`.bib`)
- Style files and templates

## Naming Convention:

- `ps{number}_report.tex` - Main report LaTeX source
- `ps{number}_report.pdf` - Compiled report
- `bibliography.bib` - Shared bibliography

## Usage:

1. Create LaTeX reports that reference tables and figures from the `outputs/` directory
2. Use relative paths to include outputs:
   ```latex
   \input{../outputs/tables/ps1_regression_results.tex}
   \includegraphics{../outputs/figures/ps1_balance_check.pdf}
   ```

## Guidelines:

- Keep LaTeX sources under version control
- PDFs can be committed but consider size limitations
- Use consistent formatting and templates across problem sets
- Include proper citations and references

## Current Status:

Individual problem sets may have their own report files in `ps*/` directories. Consider migrating these to this centralized location for better organization.