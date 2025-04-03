** Microeconometrics 20295, TA 4, Tips for Problem Set 2
** Prof: Thomas Le Barbanchon
** TA: Erick Baumgartner
** Partial credits to Jaime Marques Pereira, Francesca Garbin and Alexandros Cavgias

* Objectives for the class: 
* 1 - Introduction to panel data; 
* 2 - Introduction to time-series operators;
* 3 - Regression analyses on Stata - compact coding;
* 4 - Regression analyses on Stata - high-dimensional FEs;
* 5 - Motivating parallel trends;
* 6 - Estimating DiD specifications on Stata;
* 7 - Implementing DiD robustness checks.

********************************************************************************


*** 1 - Introduction to panel data *** 

quietly {

** Setting panel data **
*
* Import dataset from Stata's repository
webuse nlswork, clear
*
* COMMENT! If dealing with panel data, rapidly identify your (a) time identifier,
* commonly a time variable taking unique values within each time unit, and your
* (b) cross-sectional identifier, commonly a unique identifier for each cross-
* sectional unit within each time unit in a panel.
*
* Describe dataset
describe
*
* *year* is our time identifier
tab year
* *idcode* is our cross-section identifier
codebook idcode
bysort year: distinct idcode
*
* Specify time and cross-section identifiers to Stata
help xtset
xtset idcode year
*
* NOTE! *xtset* requires identifiers to be numeric variables.
*
tostring idcode, gen(str_idcode)
xtset str_idcode year
*
* To proceed, either destring a numeric variable...
destring str_idcode, gen(dstr_idcode)
xtset dstr_idcode year
*
* ... or, if any of your identifiers is not convertable to a numeric variable, 
* use Stata's *group* function instead as follows:
egen cross_id = group(str_idcode)
xtset cross_id year
*
* NOTE! Apart from specifying your time and cross-sectional identifiers, you are
* also to specify the *temporal unit* that will be used on your panel data 
* analysis - e.g., if yearly, quarterly, bi-annually or monthly averages, 
* constructed from daily panel data.
*
* Choosing your *temporal unit* can be relevant for your identification (e.g. to
* increase power) and for inference (to argue for robustness to false positivities).
*
* Bertrand et al. (2004) influential paper "How much should we trust differences
* in differences estimates?" suggests that researchers ought to collapse outcomes
* in pre-treatment and post-treatment averages to tackle autocorrelation problems
* that are common in panel data analysis. 
*
* If such a solution underpowers your regression analyses, you ought to cluster
* standard errors at the level of your cross-sectional unit, or use a more 
* aggregate cluster unit that can be estimated by your data (e.g., state when 
* town is your cross sectional unit). 
*
* TIP! Option delta() from *xtset* allows you to change your temporal window.

}

*** 2 -  Introduction to time-series operators ***

quietly {

** Setting panel data **
*
* Import dataset from Stata's repository
webuse nlswork, clear
*
* Setting time and cross-sectional identifiers
xtset idcode year, delta(1)
xtdes


** Working with lag operators **
*
* One (1) lag
reg ln_wage l.ln_wage 
*
* Two or more (>=2) lags *
reg ln_wage l2.ln_wage
reg ln_wage l.l.ln_wage


** Working with lead operators **
*
* One (1) lead 
reg f.ln_wage ln_wage 
*
* Two or more (>=2) leads
reg f.f.ln_wage f.ln_wage ln_wage 


** Working with lead and lag operators succintly ** 
*
reg ln_wage l.ln_wage l.l.ln_wage
*
reg ln_wage l(1/2).ln_wage

}

*** 3 - Regression analyses on Stata - compact coding ***

quietly {

* COMMENT! Compact syntax is particularly useful for regression models with a
* considerable number of dummies and/or large datasets.

** Dummies without generating Dummies (Stata's *i.*) **
*
* Tabulate your covariate of interest
tab race
*
* Regress Y controlling for different categories of your categorical X
reg ln_wage i.race
*
* NOTE! While using *i.*, Stata will drop one group to avoid multicollinearity
* issues - with *i.* Stata will commonly drop your X's first category.
*
* NOTE! *i.* is equivalent to creating dummies to distinguish between alternative
* categories of your categorical covariate X
*
tab race
dummies race 
reg ln_wage race2 race3 
*
* NOTE! Excluding a constant, we are able to recover group averages:
reg ln_wage race1 race2 race3, noc
sum ln_wage if race1==1
sum ln_wage if race2==1
sum ln_wage if race3==1


** Interacting covariates without generating interactions ( Stata's *i.x#i.y*) **
*
* Tabulate your pair of covariates of interest
tab race south
tab race south, cell
*
reg ln_wage i.race#i.south
*
* NOTE! We have 6 (x,y) combinations but 5 coefficients - white#0 has been dropped
* to avoid multicollinearity issues, it should be taken as our reference combination.


** Dummies + Interactions ( Stata's *i.x##i.y*) **
*
* Tabulate again your covariates of interest
tab south union
*
reg ln_wage i.south##i.union
* same as
reg ln_wage i.south i.union i.south#i.union
*
* NOTE! Stata drops first categories (from dummies and intersections) for multi-
* collinearity issues - here our references are 0.south, 0.union and 0#0.


** Interacting a continuous variable with dummies (Stata's *x#c.y*) **
*
* Tabulate your binary covariate of interest
tab south 
* Summarize your continuous covariate of interest
sum hours
*
reg ln_wage south#c.hours
*
* NOTE! Two coefficients, one for hours if south=0, another for hours if 
* south=1. Note that in contrast with i.x##i.y, Stata does not drop variables. 


** Variables + Interactions ( Stata's *i.x##c.y) **
*
reg ln_wage i.south##c.hours
*
* NOTE! Stata drops first categories (for dummies only)!

}

********************************************************************************

*** 4 - Regression analyses on Stata - high-dimension FEs ***
				
quietly {
					
* NOTE! Estimating a DiD specification with thousands of FEs is either (a) too 
* costly time-wise on Stata, using regular methods, or (b) not possible as you 
* exhaust your degrees of freedom.
*
* SOLUTION (1)! Estimate your FE model in (a) first-differences or (b) by demeaning 
* individual-level cross-sectional units - so-called within-group estimators.
*
* (a)
reg d.ln_wage d.wks_work
*
* (b), implemented through *areg, absorb(.)*
areg ln_wage wks_work, absorb(idcode)
*
* (b), implemented through *xtreg*, fe i(.)*
xtreg ln_wage wks_work, fe i(idcode)
* Option i() makes xtreg equivalent to areg. * 
*
* NOTE! First-difference and demeaning transformations are not equivalent if
* we are working with a panel with more than 2 periods.
*
* SOLUTION (2)! Estimate your FE model using "reghdfe" (by Sérgio Correia).
* This is a Stata package that allows you to control for high-dimensional FEs
* in as an efficient way as possible (through numerical optimization algorithms).
*
ssc install reghdfe
help reghdfe
*
reghdfe ln_wage wks_work, absorb(idcode)
				
}
 
*** 5 - Motivating parallel trends  ***

quietly {

* NOTE! To validate your DiD design you are to *motive* the parallel trends
* assumption with a pre-trend analysis.
*
* EXAMPLE! Assume a particular policy change took place in 1980, differentially
* affecting employment opportunities of African-americans (e.g., an anti-discri-
* mination bill). 
*
* Then we ought to believe that non-African-americans were treated significantly
* different before the enactment of our hypothetical anti-discrimination bill.
*
* How are we to understand if non-African-americans are a relevant control group
* for African-american workers in a DiD analysis? 
*
* COMMON PRACTICE: Graph trends of Y for our control and treatment groups in
* the periods before a significant policy change.
*
tab race
codebook race
*
gen TREATED = (race==2)
*
gen Y_C=wks_ue if TREATED==1 
gen Y_T=wks_ue if TREATED==0
*
preserve 
*
	collapse Y_C Y_T, by(year)
*
	twoway  (line Y_T year) (line Y_C year, lpattern(dash)),  ///
	xline(80) title(Outcome trends) ytitle(Number of Unemployed Weeks)   /// 
	legend(order(1 "Treatment" 2 "Control"))   
*
restore 
*
* NOTE! We can also perform a placebo test to check if control and treatment 
* trends  were significantly different before our policy-change (LATER!). 

}
			 				 
*** 6 - Estimating DiD specifications on Stata  ***

quietly {

** Setting data **
*
* Downloading dataset
use "http://fmwww.bc.edu/repec/bocode/c/CardKrueger1994.dta", clear 
*
* CONTEXT! Card and Krueger (1994) - effect of minimum wage on unemployment.
*
* Describe dataset
describe
*
* Outcome Y -> full time of employment
gen Y = fte 
* Post-treatment POST -> period affect the enactment of a minimum wage in New Jersey 
gen POST = t
* Treatment group TREATED -> workers from New Jersey
gen TREATED = (treated==1)
* Post-treatment treated units 
* -> workers from New Jersey after a minimum wage being established in NJ
gen POST_TREAT = POST*TREATED


** DiD "by hand" **
*
* NOTE! A DiD specification with a discrete treatment is equivalent to
* a difference of means. Hence, we can estimate these "by hand".
*
* CONVENTION! 
* Y^g_t -> outcome of group g at time t
* g = {0,1}, where 0 means control and 1 treatment
* t = {0,1}, where 0 means pre-treatment and 1 post-treatment
*
* g=1, t=1
sum Y if TREATED==1 & POST==1
scalar AVG_Y_1_1 = r(mean)
* g=1, t=0
sum Y if TREATED==1 & POST==0
scalar AVG_Y_1_0 = r(mean)
* g=0, t=1
sum Y if TREATED==0 & POST==1
scalar AVG_Y_0_1 = r(mean)
* g=0, t=1
sum Y if TREATED==0 & POST==0
scalar AVG_Y_0_0 = r(mean)
*
scalar DiD = (AVG_Y_1_1 - AVG_Y_1_0) - (AVG_Y_0_1 - AVG_Y_0_0)
scalar list DiD


** DiD by regression  **
*
* #1
reg Y POST_TREAT POST TREATED
*
* #2
reg Y i.POST##i.TREATED
*
* #3
* NOTE! As with other inference methods, a Stata *ado* file exists:
ssc install diff
diff Y, t(TREATED) p(POST)

}

*** 7 - Implementing DiD robustness checks ***

quietly {

** Controlling for baseline covariates **
*
* NOTE! A standard robustness check, in particular if levels of baseline covariates
* are unbalanced across time, is to control for interactions of time (or our post-
* treatment indicator) and baseline covariates.
*
* #1
* Original "by reg" DiD
reg Y POST_TREAT POST TREATED
* 
* Controlling "by reg" for time*covariate interactions
reg Y POST_TREAT POST TREATED i1.POST#(i1.bk i1.kfc i1.roys i1.wendys)
*
* #3
* Original "by *diff*" DiD
diff Y, t(TREATED) p(POST)
*
* Controlling "by *diff*" for time*covariate interactions
diff Y, t(TREATED) p(POST) cov(i1.POST#(i1.bk i1.kfc i1.roys i1.wendys))
*
gen POST_BK = bk*POST
gen POST_KFC = kfc*POST 
gen POST_ROYS = roys*POST 
gen POST_WENFYS = wendys*POST
diff Y, t(TREATED) p(POST) cov(POST_BK POST_KFC POST_ROYS POST_WENFYS)
*
* NOTE! Recent literature on DiDs has argued that controlling for baseline cova-
* riates that vary in time and/or are affected by treatment requires you to make additional identification assumptions that normally are not plausible in standard settings (Caetano et al., 2022; which you can find at https://arxiv.org/abs/2202.02903).
*
* These additional assumptions boil down to your covariates having to present no
* pre-treatment trends before treatment, besides your outcome. In most empirical
* applications this is too stringent of an assumption. Luckily, Caetano and co-
* authors propose alternative DiD estimators robust to this issue.
*
* To implement these though you will have to temporarily migrate to R and use
* Callaway & Sant'Anna's "did" library that allows you to compute these types of
* estimators (so-called doubly-robust DiD estimators).
*
* If you are curious about this I would recommend you to read through Scott Cu-
* nningham's blog post on the issue. There he explains the intuition behind the
* problem and how it can be solved. He also implements the solution with the
* "did" library in R:
*
* https://causalinf.substack.com/p/a-tale-of-time-varying-covariates?s=r


** Placebo testing **
*
* NOTE! Another common robustness check in a differences in differences analysis 
* is to perform a placebo test, regressing pre-treatment outcomes on treatment status.
* 
* Unfortunately, we are not able to perform a placebo test in Card and Krueger's
* dataset - FOR A PLACEBO TEST WE REQUIRE AT LEAST 2 PRE-TREATMENT PERIODS.
*
* Returning to our original dataset, assume a placebo policy change in 1972 and 
* test if our outcome trends of control and treatment groups are different 
* around our place post variable.
*
webuse nlswork, clear
*
destring year, replace	
*
gen Y = wks_ue
*
gen TREATED = (race==2)
gen PLACEBO_POST=(year>=72) 
gen PLACEBO_POST_TREAT = PLACEBO_POST*TREATED 
*
reg Y PLACEBO_POST_TREAT PLACEBO_POST TREATED if year<78

}

*** 8 - Event-studies / TWFE ***

quietly {

*Loads data set
webuse nlswork, clear

*Different TWFE specifications
set matsize 800
reghdfe ln_wage union south, absorb(idcode year) vce(cluster idcode)
*reg ln_wage union south i.idcode i.year, vce(cluster idcode)
xtset idcode year
xtreg ln_wage union south i.year, fe vce(cluster idcode)

*Stores estimates
estimates store reg1

*Plots using coefplot
coefplot reg1, keep(union south) yline(0) xtitle("Coefficients") ytitle("Estimated effect") ///
				title("Dependent variable: Log(wage)") vertical


*Creates year of union entry
gen union_year = year if union == 1
bysort idcode: egen first_union = min(union_year)
drop union_year

*Creates variable for relative time since union entry
gen relative_uy = year - first_union

*Creates dummy for people who never entered the union
gen never_union = (first_union == .)

tab relative_uy

*Creates dummies for leads and lags
forvalues k = 18(-1)2 {
gen g_`k' = relative_uy == -`k'
}
forvalues k = 0/18 {
gen g`k' = relative_uy == `k'
}

reghdfe ln_wage g_* g0-g18 south, absorb(i.idcode i.year) vce(cluster idcode)

*Stores estimates
estimates store reg1

*Shows collinearity
gen g_1 = relative_uy == -1
reghdfe ln_wage g_* g0-g18 south, absorb(i.idcode i.year) vce(cluster idcode)
drop g_1

*Plots graph
coefplot reg1, keep(g*) yline(0) xtitle("Years after union entry") ytitle("Estimated effect") ///
				title("Dependent variable: Log(wage)")

*Labels variables
forvalues k = 18(-1)2 {
label var g_`k' "-`k'"
}
forvalues k = 0/18 {
label var g`k' "+`k'"
}

*Plots graph
coefplot reg1, keep(g*) vertical yline(0) xtitle("Years after union entry") ytitle("Estimated effect") ///
				title("Dependent variable: Log(wage)")

grstyle init
grstyle set plain
coefplot reg1, keep(g*) vertical yline(0) xtitle("Years after union entry") ytitle("Estimated effect") ///
				title("Dependent variable: Log(wage)")

coefplot reg1, keep(g*) vertical yline(0) xtitle("Years after union entry") ytitle("Estimated effect") ///
				title("Dependent variable: Log(wage)") xlabel(, angle(45))

coefplot reg1, keep(g*) vertical yline(0) xtitle("Years after union entry") ytitle("Estimated effect") ///
				title("Dependent variable: Log(wage)") xlabel(, angle(45) alternate)

*We use the IW estimator to estimate the dynamic effect on log wage associated with each relative time.
*With many leads and lags, we need a large matrix size to hold intermediate estimates.
set matsize 800
eventstudyinteract ln_wage g_* g0-g18, cohort(first_union) control_cohort(never_union) covariates(south) absorb(i.idcode i.year) vce(cluster idcode)

*Event study plots
*We may feed the estimates into coefplot for an event study plot.
matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C
coefplot matrix(C[1]), se(C[2]) keep(g*) vertical yline(0) xtitle("Years after union entry") ytitle("Estimated effect") ///
				title("Dependent variable: Log(wage)") xlabel(, alternate)

*For the next steps, let's keep a balanced panel and force union to be weakly monotonic (once you enter, you're "always treated")
*
*Keeps a balanced panel
bysort idcode: gen n_obs = _N
sum n_obs
display r(max)
keep if n_obs == r(max)

*Creates entered_union, weakly monotonic
gen entered_union = year >= first_union

*Simple regression
reghdfe ln_wage entered_union, absorb(idcode year) vce(cluster idcode)

*Runs Bacon-decomposition
ssc install bacondecomp
bacondecomp ln_wage entered_union

*Runs twowayfeweights
ssc install twowayfeweights
twowayfeweights ln_wage idcode year entered_union, type(feTR)

}


********************************************************************************

*** Extra Material on Panel data analysis in Stata ***

quietly {

* Once you xtset your dataset, you can see its characteristics
* Import dataset from Stata's repository
webuse nlswork, clear
*
* Describe dataset
describe
*
* Specify time and cross-section identifiers to Stata
xtset idcode year 

* Balanced or unbalanced panel?
*
* Describe patterns:
xtdescribe

* Summary statistics: overall, and over time (between/within variation)
summ ln_wage
xtsum ln_wage
* how can I identify time-invariant variables from the xtsum table?
xtsum birth_yr

* Additional information on between and within variation
* Panel tabulation for a variable
xttab south

* Transition matrices
xttrans south, freq

* How does occupation change for these individuals over the seven years?
xttab occ
xttrans occ

* Simple time-series plot for experience of 10 individuals
quietly xtline ttl_exp if idcode<=10, overlay 

* Panel data regressions
* Pay attention to the relationships among your variables!
xtsum ln_wage age birth_yr year 

* Capturing variation across individuals or within individuals?
* Pay attention: is there a relationship between age, birth cohort, and current year?
xtreg ln_wage age birth_yr year, fe
xtreg ln_wage age birth_yr year, be

xtreg ln_wage age birth_yr, fe
xtreg ln_wage age birth_yr, be
* Can you say why fe and be consider these covariates differently? 
* Which variation are these picking up?

}

*** Extra code on binary dependent variables ***

quietly {

clear 

webuse union
de
xtdes
xtsum union age grade south
* SMSA: standard metropolitan statistical area 

* Logit
logit union age grade not_smsa south , vce (cluster id)
estimates store LT

* RE
xtlogit union age grade not_smsa south  , i(id) re nolog
estimates store randomeff

* FE
xtlogit union age grade not_smsa south  , i(id) fe nolog
estimates store fixedeff

* Compare the estimates by compiling a table
estimates table LT randomeff fixedeff, b(%10.4f) se stats(N)

* Hausman test
*
* equations() specifies by number the pairs of equations that are to be compared
* e.g. eq(1:2) means that eq.1 of the always-consistent estimator is to be tested against eq.2 of the efficient estimator:
hausman fixedeff randomeff, eq(1:1) 
* Prob>0.0032 reject random effect, even if there is a tiny significant difference.

}
