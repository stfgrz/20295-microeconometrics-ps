********************************************************************************
* Purpose: This file performs main RD analysis
* Author: Robert Gonzalez
* Date modified: 2018
********************************************************************************


clear all
set more off



global dt "D:\Dropbox\Afghanistan\Submissions\AEJ_Applied\Replication"
global dt "C:\Users\Robert\Dropbox\Afghanistan\Submissions\AEJ_Applied\Replication"

global in "$dt\data"
global tables "$dt\latex"



********************************************************************************
* 		A. Data preparation and bandwidth calculations
********************************************************************************
use "$out\fraud_pcenter_final.dta", clear
recode region2 (3=1) (4=2)

drop if conflict==1


replace dist=dist/1000
gen dist2=dist^2
gen dist3=dist^3
gen dist4=dist^4
foreach i in 2 3 4 {
	gen lat`i'=lat^`i'
	gen lon`i'=lon^`i'
}


* Optimal bandwidth
gen temp=dist
replace temp=-dist if cov==0


foreach var in /*600 95 ecc*/ comb comb_ind {
		rdbwselect vote_`var' temp if ind_seg50==1, vce(cluster segment50)
		scalar hopt_`var'=e(h_mserd)
		forvalues r=1/2 {
			rdbwselect vote_`var' temp if ind_seg50==1 & region2==`r', vce(cluster segment50)
			scalar hopt_`var'_`r'=e(h_mserd)
	}
}
*

* Control means
foreach var in /*600 95 ecc*/ comb comb_ind {
		sum vote_`var' if (cov==0 & ind_seg50==1 & dist<=hopt_`var')
		scalar mean_`var'=r(mean)
		forvalues r=1/2 {
			sum vote_`var' if (cov==0 & ind_seg50==1 & dist<=hopt_`var'_`r' & region2==`r')
			scalar mean_`var'_`r'=r(mean)
	}
}
*
foreach var in /*600 95 ecc*/ comb comb_ind {
		sum vote_`var' if (cov==0 & ind_seg50==1)
		scalar mean_`var'_all=r(mean)
		forvalues r=1/2 {
			sum vote_`var' if (cov==0 & ind_seg50==1 & region2==`r')
			scalar mean_`var'_`r'_all=r(mean)
	}
}
*

xtset, clear
xtset segment50 pccode


********************************************************************************
* 		B. Local Linear Regression (using distance as forcing variable)
********************************************************************************

foreach var in /*600 95 ecc*/ comb_ind comb {	
	* All regions
	xtreg vote_`var' cov##c.(dist) if ind_seg50==1 & dist<=hopt_`var', fe robust 
		est store col1_a_`var'
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_`var'
		estadd scalar Bw = hopt_`var'
		estadd scalar Gr = e(N_clust)

	* Southeast
	xtreg vote_`var' cov##c.(dist) if ind_seg50==1 & dist<=hopt_`var'_1 & ///
	region2==1, fe robust 
		est store col1_b_`var'
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_`var'_1
		estadd scalar Bw = hopt_`var'_1
		estadd scalar Gr = e(N_clust)

	* Northwest
	xtreg vote_`var' cov##c.(dist) if ind_seg50==1 & dist<=hopt_`var'_2 & ///
	region2==2, fe robust 
		est store col1_c_`var'
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_`var'_2
		estadd scalar Bw = hopt_`var'_2
		estadd scalar Gr = e(N_clust)
 }



********************************************************************************
* 		C. Polynomial RD using distance with all obs
********************************************************************************

foreach var in /*600 95 ecc*/ comb_ind comb {	
	* All regions
	xtreg vote_`var' cov##c.(dist dist2 dist3) if ind_seg50==1, fe robust	
		est store col2_a_`var'
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_`var'_all
		estadd scalar Gr = e(N_clust)
	* Southeast
	xtreg vote_`var' cov##c.(dist dist2 dist3) if ind_seg50==1 & region2==1, fe robust	
		est store col2_b_`var'
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_`var'_1_all
		estadd scalar Gr = e(N_clust)
	* Northwest
	xtreg vote_`var' cov##c.(dist dist2 dist3) if ind_seg50==1 & region2==2, fe robust	
		est store col2_c_`var'
		estadd scalar Obs = e(N)
		estadd scalar Mean = mean_`var'_2_all
		estadd scalar Gr = e(N_clust)
}
*



********************************************************************************
* 		E. Export results to latex table
********************************************************************************
* Wide version
estout col1_a_comb_* col2_a_comb_* col1_b_comb_* col2_b_comb_* col1_c_comb_* col2_c_comb_*  ///
using "$tables\results_onedim_a.tex", replace style(tex) ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
keep(1.cov) mlabels(, none) collabels(, none) eqlabels(, none) ///
stats(Obs Mean Bw Gr, fmt(a3) ///
labels("Observations" "Mean Outside coverage" "Bandwidth (km)" "Neighborhoods"))

estout col1_a_comb col2_a_comb col1_b_comb col2_b_comb col1_c_comb col2_c_comb ///
using "$tables\results_onedim_b.tex", replace style(tex) ///
label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
keep(1.cov) mlabels(, none) collabels(, none) eqlabels(, none) ///
stats(Obs Mean Bw Gr, fmt(a3) ///
labels("Observations" "Mean Outside coverage" "Bandwidth (km)" "Neighborhoods"))





