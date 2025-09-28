*============================================================================
* Template for 20295 Microeconometrics Problem Sets
* Group number: [INSERT GROUP NUMBER]
* Group composition: [INSERT NAMES]
*============================================================================

*=============================================================================
*                                 Setup
*=============================================================================

clear all
set more off
set seed 123456  // For reproducibility

* Initialize project paths (replace X with actual problem set number)
do "scripts/stata/utils.do"
init_paths X

* Alternative manual setup if utils.do is not available:
* Uncomment and modify the following lines:
/*
local ps_number = X  // Replace X with problem set number
global project_root = c(pwd)  // Assumes script is run from project root
global ps_data "${project_root}/ps`ps_number'/ps`ps_number'_data"
global ps_output "${project_root}/ps`ps_number'/ps`ps_number'_output"
*/

*=============================================================================
*                          Package Installation
*=============================================================================

* First time running? Uncomment and run package installation:
/*
local packages "outreg2 estout ivreg2 ranktest"
foreach pkg of local packages {
    capture which `pkg'
    if _rc {
        ssc install `pkg', replace
        display "`pkg' installed successfully"
    }
    else {
        display "`pkg' already installed"
    }
}
*/

*=============================================================================
*                                Questions
*=============================================================================

* Question 1
* [Insert question text as comment]

use "${ps_data}/datafile.dta", clear
* [Your analysis code here]

* Save results
esttab using "${ps_output}/table_q1.tex", replace ///
    title("Question 1 Results") ///
    label booktabs

* Question 2
* [Insert question text as comment]

* [Your analysis code here]

log close