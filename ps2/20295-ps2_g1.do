*============================================================================
/* Group number: 1 */
/* Group composition: Stefano Graziosi, Gabriele Molè, Sofia Briozzo */
*============================================================================

*=============================================================================
/* 								Setup 										*/
*=============================================================================

clear

set more off

/* For commands */

/* First time running this code? Please remove the comment marks from the code below and install of the necessary packages */

ssc install outreg2, replace
ssc install estout, replace
ssc install avar, replace
ssc install eventstudyinteract, replace
ssc install bacondecomp, replace
ssc install egenmore, replace
ssc install _gwmean, replace
ssc install twowayfeweights, replace
ssc install ftools, replace
ssc install moremata, replace
ssc install reghdfe, replace

*/

/* For graphs & stuff */
/*
ssc install grstyle, replace
ssc install coefplot, replace
graph set window fontface "Lato"
grstyle init
grstyle set plain, horizontal
*/

* Initialize project paths automatically
capture do "../scripts/stata/utils.do"
if _rc != 0 {
    * Fallback: manual path setup if utils.do not found
    display "Warning: Could not load utils.do, using manual path setup"
    global project_root = c(pwd)
    * Go up one level if we're in ps2 directory
    local current_dir = c(pwd)
    if strpos("`current_dir'", "ps2") > 0 {
        cd ..
        global project_root = c(pwd)
        cd "`current_dir'"
    }
    global ps_data "${project_root}/ps2/ps2_data"
    global ps_output "${project_root}/ps2/ps2_output"
}
else {
    init_paths 2
}

*=============================================================================
/* 								Question 1 									*/
/*                      													*/
*=============================================================================

use "${ps_data}/pset_4.dta", clear

/* (a) Note that one of the variables in the data set is stpop, the state population. In the next exercises, you should follow Wolfers (2006) in weighting both your descriptive output and your analysis by the state population. A short summary of the different weighting procedures in Stata is provided here ([1,2]). Given that divorce rates are an average computed in each state and the variable stpop provides the population in each of these states, which is the weight you should use when reporting the evolution of divorce rates or a regression of divorce rates on unilateral divorce laws to match the analysis in Wolfers (2006)? */

	/* A: 	Wolfers (2006) adopts a weighted least squared framework, using population weights for both descriptive analysis and computation of regression estimates. 
	As the treatment variable, the number of divorces every 1000 people, is at the state level and div_rate is a state mean, we should follow  Dupraz (2013) and adopt the state population (stpop) as the analytical weights and robust standard errors with vce(robust). 
	This procedure improves computational efficiency and would yield the same estimates as relying on "fweight" after correcting for proper standard errors. */
	
/* (b) The article relies on the timing of the introduction of unilateral divorce laws to compare divorce rates in the two possible regimes. One of the assumptions of this analysis is that states with the previous divorce law and the ones that introduced unilateral divorce laws would both follow parallel trends in their divorce rates in the absence of the changes to the legislation. Create 2 different graphs to support this assumption: (i) the first graph should convey the same message as the one in Figure 1 of the original paper, comparing states that did not change their divorce laws during 1968 - 1988 (Friedberg's sample) and the ones that did; (ii) the second graph should perform the same description, but focusing on the simpler analysis we will perform in the next exercise: compare the states adopting the unilateral divorce law between 1969 and 1973 to the ones that introduced it in the year 2000, only reporting the time trend up to 1978 and including a vertical line between 1968 and 1969 (when the first reforms in our sample started). Do your results support the assumption of parallel trends? */

preserve
	egen total_pop_by_state = total(stpop), by(year)
	gen wgt = stpop/total_pop_by_state

	gen TREATED = (lfdivlaw >= 1968 & lfdivlaw <= 1988)
	sum TREATED 

	egen div_rate_tre = wmean(div_rate) if TREATED == 1, by(year) weight(wgt)
	egen div_rate_con = wmean(div_rate) if TREATED == 0, by(year) weight(wgt)

	collapse div_rate_tre div_rate_con, by(year)

	gen div_rate_dif = div_rate_tre - div_rate_con


	#delimit ;

	graph set window fontface "Times New Roman";

	graph twoway	
		(line div_rate_tre year, lcolor(black) lwidth(thick))
		(line div_rate_con year, lcolor(gs5) lwidth(thick))
		(line div_rate_dif year, lcolor(black) lp(dash)) 
		(function y = 0.2, range(1968 1988) lcolor(black) lpattern(solid) lwidth(medium))
		,
		xline(1968 1988, lp(solid)) //* might change the vertical lines 
		ylabel(0(1)7, grid glstyle(solid))
		yline(0, lp(solid))
		xlabel(1956(2)1998, nogrid angle(45))
		xmticks(1957(2)1999)
		legend(
			pos(12)
			order(
				1 "Reform states"
				2 "Control states"
				3 "Difference in divorce rates: Reform states less controls"
				)
			region(lstyle(solid) lcolor(black) lwidth(thin))
		)
		xtitle("Year")
		text(0.3 1982 "Friedberg's sample", size(small) color(black) place(n))	
		text(6.6 1973 "Reform period", size(small) color(black) place(n))
		ytitle("Divorce rate" "Divorces per 1,000 persons per year")

	;

	#delimit cr

	graph export "${ps_output}/Graph_1.pdf", replace

restore


*Graph 2


preserve
egen total_pop_by_state = total(stpop), by(year)
gen wgt = stpop/total_pop_by_state

gen TREATED = (lfdivlaw >= 1969  & lfdivlaw <= 1973)

egen div_rate_tre = wmean(div_rate) if TREATED == 1, by(year) weight(wgt)
egen div_rate_con = wmean(div_rate) if TREATED == 0 & lfdivlaw == 2000, by(year) weight(wgt)

collapse div_rate_tre div_rate_con, by(year)

gen div_rate_dif = div_rate_tre - div_rate_con

drop if year > 1978


#delimit ;

graph set window fontface "Times New Roman";

graph twoway	
    (line div_rate_tre year, lcolor(black) lwidth(thick))
    (line div_rate_con year, lcolor(gs5) lwidth(thick))
    (line div_rate_dif year, lcolor(black) lp(dash)) 
    
    ,
    xline(1968.5, lp(solid))
    ylabel(0(1)7, grid glstyle(solid))
    yline(0, lp(solid))
    xlabel(1956(2)1978, nogrid angle(45))
    xmticks(1957(2)1979)
    legend(
        pos(12)
        order(
            1 "Reform states"
            2 "Control states"
            3 "Difference in divorce rates: Reform states less controls"
            )
        region(lstyle(solid) lcolor(black) lwidth(thin))
    )
    xtitle("Year")
    ytitle("Divorce rate" "Divorces per 1,000 persons per year")

;

#delimit cr

graph export "${ps_output}/Graph_2.pdf", replace
restore 


	/* A: A preliminary analysis does not find a strong support for the parallel trend assumption (PTA). 

Graph 2 shows that treated countries had higher baseline divorce rates compared to the control group. From a first graphical exploration control states and reform states seem to follow similar trajectories before the treatment. Yet the difference among the two groups increases over time, starting from 1.238 in 1956 and noticeably reaching 1.71 in 1968 (38% increase). While we observe a relevant rise of divorce rates in 1970, the outcome variable slowly congerges to the pre-treatment levels. 

This can be explained in line with Wolfers (2006): there is a sort of endogeneity of treatment status, as treated countries already showed a tendency towards more divorces, and the reforms simply freed up the marriages that could not break up due to bilateral divorce laws. In other words the increase in the difference could be explained as a result of all the people who could not divorce previously to the reform and cumulated as a stock ready to be released. 

Overall, we cannot clearly support the parallel trend assumptions as we do not rely on any formal test. There is an increasing difference among the control and treated states, yet we do not know whether this is statistically relevant.  
 */
	
/* INSTRUCTIONS: Let us now start an analysis of the effects of the introduction of unilateral divorce laws. As a first step, let us perform a 2-period difference-in-difference analysis using "long differences", focusing on the evolution of divorces between 1968 and 1978. Keeping only these 2 years in our sample, you should compare states adopting the unilateral divorce law between 1969 and 1973 to the ones that introduced it in the year 2000. On this restricted sample, you should create: (i) a variable UNILATERAL equal to 1 if a state introduced the unilateral divorce law during this period (as signaled by variable lfdivlaw); (ii) a variable POST equal to 1 if the year is 1978; and (iii) a variable POST UNILATERAL when both POST and UNILATERAL are equal to 1. */
	
/* (c) Now estimate the following regressions: */

preserve

	gen UNILATERAL = (lfdivlaw >= 1969  & lfdivlaw <= 1973)
	keep if year == 1968 | year == 1978
	drop if lfdivlaw != 2000 & UNILATERAL == 0
	gen POST = (year == 1978)
	gen POST_UNILATERAL = (POST == 1 & UNILATERAL == 1)
	
	encode st, generate(state)
	
	/* (i) A pooled OLS regression of the divorce rate per 1,000 people (div rate) on POST UNILATERAL and POST; */

	reg div_rate POST POST_UNILATERAL [aweight = stpop], vce(robust)
	
	/* (ii) A full Difference-in-Differences specification, including POST, UNILATERAL and POST UNILATERAL as regressors; */
	
	reg div_rate POST UNILATERAL POST_UNILATERAL [aweight = stpop], vce(robust)
	
	*extra 
	
	reg div_rate POST UNILATERAL POST*UNILATERAL [aweight = stpop], vce(robust)

	
	/* (iii) Based on the graphs you created in section (a), could you say something about the difference in the coefficients from regressions (i) and (ii)? What is the effect of introducing unilateral divorce laws according to this analysis? */

		/* A: Graph 2 showed that baseline level of divorce rate in treated group is higher than control group. Hence regression i) overestimates the treatment effect as it does not control for group fixed effect. The Pooled estimate simply computes the difference between treated and control group in the time after the treatment has been introduced. 
		After controlling for group fixed effect through the UNILATERAL dummy the estimated treatment effect of IMP_UNILATERAL in regression i) (1.70 and statistically significant at every conventional level) disappears. The estimated coefficient for regression ii) is negative but very close to 0 (-.005) and statistically insignificant. Thus, this first analysis would provide evidence against the hypothesis that the introduction of unilateral divorce laws increased divorce rates, assuming that the parallel trend assumption holds.*/
	
/* (d) Generate a 3 by 3 matrix with row and column labels as follows: SEE PS2 
Difference 1 should show differences across columns while Difference 2 across lines. Complete this matrix with the averages of div rate, replicating the results you have found in the previous regression. Then, export the matrix to an Excel table named TABLE 1.*/

	matrix table_1 = J(3,3,.)

	* g=1, t=1
	sum div_rate if UNILATERAL==1 & POST==1 [aweight = stpop]
	scalar AVG_Y_1_1 = r(mean)
	matrix table_1[1,1] = AVG_Y_1_1 
	* g=1, t=0
	sum div_rate if UNILATERAL==1 & POST==0 [aweight = stpop]
	scalar AVG_Y_1_0 = r(mean)
	matrix table_1[2,1] = AVG_Y_1_0 

	* g=0, t=1
	sum div_rate if UNILATERAL==0 & POST==1 [aweight = stpop]
	scalar AVG_Y_0_1 = r(mean)
	matrix table_1[1,2] = AVG_Y_0_1 

	* g=0, t=1
	sum div_rate if UNILATERAL==0 & POST==0 [aweight = stpop]
	scalar AVG_Y_0_0 = r(mean)
	matrix table_1[2,2] = AVG_Y_0_0

	*
	scalar DiD = (AVG_Y_1_1 - AVG_Y_1_0) - (AVG_Y_0_1 - AVG_Y_0_0)
	scalar list DiD
	matrix table_1[3,3] = DiD
	matrix table_1[3,1] = AVG_Y_1_1 - AVG_Y_1_0
	matrix table_1[3,2] = AVG_Y_0_1 - AVG_Y_0_0
	matrix table_1[1,3] = AVG_Y_1_1 - AVG_Y_0_1
	matrix table_1[2,3] = AVG_Y_1_0 - AVG_Y_0_0

	matrix colnames table_1 = UNILATERAL=1 UNILATERAL=0 Difference_2
	matrix rownames table_1 = POST=1 POST=0 Difference_1

	matrix list table_1
	putexcel set "${ps_output}/table_1.xlsx", replace
	putexcel A1=matrix(table_1), names
	putexcel C1:C4, border(right)
	putexcel A3:D3, border(bottom)
	putexcel A1:D1, border(bottom)
	putexcel A1:D1, border(top)
	putexcel A4:D4, border(bottom)
restore

	
/* (e) We will now perform the analysis using our complete data set, as in the main results of Wolfers (2006). For this, always focus on the same sample as the one used in Table 2 of the original paper (keeping observations between 1956 and 1988). Load once again our data set and create the dummy variable IMP UNILATERAL, which equals 1 whenever a state has already introduced unilateral divorce laws (as signaled by variable lfdivlaw). Now run the following regressions: */

preserve 
	encode st, generate(state)
	keep if year >= 1956 & year <= 1988
	gen IMP_UNILATERAL = (lfdivlaw <= year)
	gen time = year - 1955
	gen time2 = time*time


	/* (i) A regression of div rate on state and year dummies and the dummy IMP UNILATERAL that you created. */
		
	reg div_rate i.year i.state IMP_UNILATERAL [aweight = stpop], vce(robust)
	
	/* (ii) Perform the same regression as the one described above, now including state-specific linear time trends.  */
	
	reg div_rate i.year i.state i.state##(c.time) IMP_UNILATERAL [aweight = stpop], vce(robust)
	
	/* (iii) In addition to state-specific linear time trends, include also quadratic state-specific time trends. */
	
	reg div_rate i.year i.state i.state##(c.time c.time2) IMP_UNILATERAL [aweight = stpop], vce(robust)
restore

	/* (iv) Interpret the results of all 3 regressions. Can you think of a reason for the results to change across specifications? Under which assumption should these results be the same? */ 
	
	/* A: Across all specification the estimated coefficient for IMP_UNILATERAL should yield the average treatment effect of the introduction of unilateral divorce laws on divorce rates, provided the parallel trend assumption is met. Regression i) estimates a model controlling for both time invariant state fixed effects and time variant effects that are common to all states. This is obtained by adding state and time dummies. The estimated coefficient is -0.05 and statistically insignificant. This supports the hypothesis of a null treatment effect that we found also in the previous simple analysis.
	
Yet as we add a state specific linear trend in regression ii) the estimated coefficient for IMP_UNILATERAL increases to 0.477 and becomes statistically significant at every conventional level of significance. After adding quadratic state specific trends in regression iii) the coefficient slightly decreases to 0.334 while remaining statistically significant at every conventional level of significance. The estimates show a comparable behavior to Friedberg (1998), where controlling for state specifice trends found a positive effect of the divorce law, differently from the the null effect found in the baseline specification. Because the coefficients change over time the estimated coefficients seem to suffer from omitted variable bias due to different trends among the subgroups that are correlated with the divorce rate. 

This bias is less prominent after controlling for state specific quadratic time trends. Compared to Friedberg (1998) we rely on a wider dataset. Overall these result seem to provide evidence that it is unlikely that the parallel trend assumption holds. Indeed, the estimated coefficients should be the same in all specifications provided control and treatment follow the same trends, which seems not to be the case.  
	*/
	

/* (f) In our current case study, unilateral divorce laws have been introduced subsequently in different states at different points in time. In such cases, we say that there was a staggered implementation of the treatment. Regressions with a single coefficient, as the ones performed in exercise e), may be biased in this setting. Let us now check some of the properties of these regressions. We will create a simulated data set of 3 periods and 2 states, where one state receives a treatment in the 2nd period and the other state only receives it in the 3rd period. The code below reproduces this simulation: */

/* Created simulated observations */

preserve
	clear

	set obs 6 
	gen obs = _n 
	gen state = floor(.9 + obs/3)
	bysort state : gen year = _n
	gen D = state == 1 & year == 3
	replace D = 1 if state == 2 & ( year == 2 | year == 3 )

	* Generate Y
	gen Y = 0.1 + 0.02 * (year == 2) + 0.05 * (D == 1) + runiform() / 100

	* Generate Y2
	gen Y2 = 0.1 + 0.02 * (year == 2) + 0.05 * (D == 1) + 0.3 * (state == 2 & year == 3) + runiform() / 100

	* Generate Y3
	gen Y3 = 0.1 + 0.02 * (year == 2) + 0.05 * (D == 1) + 0.4 * (state == 2 & year == 3) + runiform() / 100

	* Generate Y4
	gen Y4 = 0.1 + 0.02 * (year == 2) + 0.05 * (D == 1) + 0.5 * (state == 2 & year == 3) + runiform() / 100

		/* (i) Now perform regressions analogous to the one performed in exercise e question (i) for all 4 dependent variables created (that is, a state and year fixed-effects regression with an absorbing treatment dummy). Is it possible to estimate the treatment coefficient consistently in each of these cases? */
		
	reg Y i.state i.year D, vce(robust)
	twowayfeweights Y state year D, type(feTR) 
	reg Y2 i.state i.year D, vce(robust)
	twowayfeweights Y2 state year D, type(feTR) 
	reg Y3 i.state i.year D, vce(robust)
	twowayfeweights Y3 state year D, type(feTR) 
	reg Y4 i.state i.year D, vce(robust)
	twowayfeweights Y4 state year D, type(feTR) 


	/*extra: controlling for state specific time effects */
	reg Y2 i.state##i.year D, vce(robust)
	reg Y3 i.state##i.year D, vce(robust)
	reg Y4 i.state##i.year D, vce(robust)
restore
	
		/* A: Only the first regression consistently estimates the average treatment effect: the estimated coefficient is 0.056 and statistically significant at the 5% level. In all remaining regressions the estimated coefficient for the treatment dummy becomes negative, though statistically insignificant. This can be explained by the way the simulated data have been created. "Y" includes only a fixed efect and a year effect, while following simulated outcomes include a time varying and state specific effect on the outcome that is not accounted by the regression specification we adopted. Indeed, if we control for state specific time effects in the specification (as in the extra section) the estimates for treatment are close to the "true" values of 0.05. Hence, due to the staggered implementation of the treatment the estimated regressions include a downard bias that is increasing depending on the magnitude of the state and year specific effect. This because the treatment effect is "masked" by the state and time specific effect of state 2 in year 3 that might be due either to specific changes in state 2 at year 3 or by heterogeneous treatment effects.   */
	
/* (g) Use the Stata package "twowayfeweights" (or its R version, "TwoWayFEWeights"), based on De Chaisemartin and d'Haultfoeuille (2020), to estimate the weights attached to the regressions you estimated before. Can you explain why the sign of the estimated effect has changed between the regression on Y and the one on Y4? */

	/* A: The code was executed in part f).
	
	De Chaisemartin and d'Haultfoeuille (2020) show that in a fixed effect design with staggered implementation and heterogeneous treatment effects the fixed effect estimator β_fe for the treatment effect could be decomposed as the expectation of a weighted sum of the Δg,t terms, namely the average treatment effect in group g and period t coming from all pairwise difference in differences. The issue is that weights can assume negative values, yielding a downward bias and possibly leading to estimated negative treatment effect even if the average treatment effects on the treated are all positive. Negative weights arise as a result of relying on Difference in Differences where in some cases the control group is already treated due to staggered treatment adoption. 

This is the situation that seems to happen in this case, where the treatment adoption is staggered. The twowayfeweights command show that the estimated β_fe is a result of a weighted sum where a negative weight is present. De Chaisemartin and d'Haultfoeuille (2020) show that it is more likely to assign negative weights to periods where a large fraction of groups are treated, and to groups treated for many periods, which in our case is period 3 and for state 2, that is the one starting treated from period 2. This was also the component that influenced the bias in the previous regressions. Thus a plausible explanation of the estimated negative coefficient for β_fe is that the negative weighted ATE_2,3 overcompensates the positive contributions of the other ATEs, and that the ATE_2,3 increases depending on the effect of the specific changes in state 2 at year 3, thus explaining why estimated coefficients get smaller from regression on Y2 to Y4.

This situation aligns with the example the authors provide in their paper. They showed that under the error decomposition
εg,t = Dg,t − Dg,. − D.,t + D.,. ,
(where εg,t is the residual error to compute the weights, Dg,t the treatment status dummy, Dg, the average treatment status of the group, D.,t, the average treatment status at that time, and D.,. the average treatment status overall), the weight given to the average treatment effect of Δ2,3 is negative. In addition to this, decomposing the fixed effects estimator as β_fe = (DID1 + DID2)/2 they show that bias arises from the second difference in differences:
DID2 = E[Δ1,3] − (E[Δ2,3] − E[Δ2,2]).
Greater increases in E[Δ2,3] − E[Δ2,2] bias downward the β_fe, which explains why bigger increases in the effect at year 3 for state 2 leads to higher biases. 
	
	*/
	
/* (h) Let us now revisit our analysis following Wolfers (2006). We will do this based on the decomposition proposed by Goodman-Bacon (2021). The author provides commands in both Stata and R for his decomposition. To install it in Stata, run the code below: */

preserve 

	/* (i) create a modified population variable init stpop equal to the population of each state in the first observed period of each state. */
	
	sort st year
	by st: gen first_obs = _n == 1
	gen init_stpop = stpop if first_obs
	replace init_stpop = init_stpop[_n - 1] if init_stpop == .

	/* (ii) Rerun regression i of exercise (e) (a regression of div rate on state and year dummies and the dummy IMP UNILATERAL that you created) using init stpop as your weights. */
	
	encode st, generate(state)
	keep if year >= 1956 & year <= 1988
	gen IMP_UNILATERAL = (lfdivlaw <= year)
	
	xtset state year
	xtreg div_rate IMP_UNILATERAL i.year [aweight = init_stpop], fe robust
	
	/* (iii) Run the command bacondecomp to analyze the decomposition of the treatment effect. Plot the graph showing the relationship between the treatment effect estimates and the corresponding weights. Briefly explain what is the analysis proposed by Goodman-Bacon (2021). Is there evidence of issues regarding negative weights? */
	
		bacondecomp div_rate IMP_UNILATERAL [aweight = init_stpop], robust  mcolors(blue red green)
	graph rename bacondecomp22
	graph export "${ps_output}/Bacon_decomposition_graph.pdf", replace
restore
	
	/* Goodman-Bacon (2021) provides a decomposition of the twoway Difference in Differences estimator (TWFEDD) in case of staggered treatment as the weighted average of all possible 2x2 two group two periods DiD estimators. These differ by the adopted control group: as a group might change treatment status over time, every DiD can either have as control group an always treated group, a never treated group, or timing groups, namely groups whose treatment stated at different times is used as other's controls groups.
	The weights given to the 2x2 DiD depend on the timing group sizes and the variance of the treatment dummy in each pair, which tends to be higher in observations in the middle of the panel. With time-invariant treatment effect the estimator returns an average of cross-group treatment effects where weights depend on the variances and are all positive. In case of heterogeneous treatment effect, negative weights are a result of adopting already-treated units as controls, where the treatment effect might change over time but is subtracted in the pairwise DiD. The authors point out that this does not violate the parallel assumption per se but underscore the need for caution when using the TWFEDD estimator. They suggest the adoption of different strategies, namely event studies, stacked
DD or reweighting estimators. 
	The authors show that the probability limit of the TWFEDD Estimator can be decomposed into the variance-weighted average treatment effect on the treated (VWATT), the so called `variance-weighted common trends'(VWCT), and the the weighted sum of the change in treatment effects within each timing group before and after a later treatment time (deltaATT). The VWCT is assumed to be equal to zero, an assumption called pairwise common trends assumption. Thus, when time-varying treatment effects arise, deltaATT is non-null and biases the estimate while yielding negative weights. 

Plotting the Bacon decomposition for our sample we notice that the assigned weights are all positive as every observation is on the right hand side of the y axis. The estimated coefficient for IMP_UNILATERAL is negative and thus is likely due to a slight predominance of negative estimated average treatment effects in pairwise difference in differences. The large majority (.88) of weights is given to never treated units used as control groups, while "timing groups" and "always treated" units are given weights close to 0. Because already-treated units are usually the most likely source of negative weights but here has negligible importance, this seems to rule out issues with negative weighting. 
*/
	
/* (i) Let us now perform an event-study regression, allowing for the unilateral divorce law coefficients to vary across time. Your analysis will follow table 2 in Wolfers (2006). We will have the period right before the introduction of the law as our basis of comparison, creating dummies for leads and lags for all other distances between our observation period and the law introduction in that state. This means that for any time period t and state s, the dummy Dτ st will be equal to one if in that specific period, state s has introduced unilateral divorce laws τ years before. Following the analysis in the main paper, we will set 
	
	SEE FORMULA ON PDF
	
That is, the dummy will be equal to one for all observations with 15 or more years of unilateral divorce law. For the lead dummies, let us restrict

	SEE FORMULA ON PDF
	
So that this dummy will equal 1 for all observations 10 or more years before the introduction of the unilateral divorce law in that state. Notice that this specification has some deviations from the one performed in table 2 of the original paper. */

	/* (i) Run the regresson below, using the unilateral divorce dummies Dτ st you created and sector (πs) and year (γt) fixed effects. */
	
preserve
	use "${ps_data}/pset_4.dta", clear

	encode st, generate(state)
	keep if year >= 1956 & year <= 1988
	gen IMP_UNILATERAL = 0
	replace IMP_UNILATERAL = 1 if lfdivlaw <= year
	gen no_law = 0 
	replace no_law=1 if lfdivlaw==2000
	xtset state year

	gen tau = year - lfdivlaw
	tab tau

	gen lead10 = 0
	replace lead10 = 1 if tau <=-10

	*Lead and lag dummies
	forvalues k = 9(-1)2 {
	gen lead`k' = tau == -`k'
	}

	forvalues k = 0/14 {
	gen lag`k' = tau == `k'
	}
	gen lag15 = 0
	replace lag15 = 1 if tau >= 15

	*Generate the linear and the squared time trends
	forval i=1/51{
		bysort state (year): gen time_trend_`i'=_n if state==`i' 
		replace time_trend_`i'=0 if time_trend_`i'==.
	}

	forval i = 1/51 {
		gen timetrend_square_`i' = time_trend_`i'^2
	}

	reghdfe div_rate lead* lag* [aweight = stpop], absorb(i.year i.state) cluster(state)
	estimates store reg_simple
	outreg2 using "${ps_output}/Reg1.xlsx", title("regression ex i point i") label excel replace

		
		/* (ii) Perform the same regression as the one described above, now including state-specific linear time trends. */
		
	reghdfe div_rate lead* lag* time_trend_* [aweight = stpop], absorb(i.year i.state) cluster(state)
	estimates store reg_timetrend
	outreg2 using "${ps_output}/Reg2.xlsx", title("regression ex i point ii") label excel replace

		
		/* (iii) In addition to state-specific linear time trends, include also quadratic state-specific time trends. */
		
	reghdfe div_rate lead* lag* time_trend_* timetrend_square_* [aweight = stpop], absorb(i.year i.state) cluster(state)
	estimates store reg_sqtime
	outreg2 using "${ps_output}/Reg3.xlsx", title("regression ex i point iii") label excel replace


	
	/* (iv) Interpret the results of all 3 regressions. What can we see in the behaviour of divorce rates through this analysis that was not possible in the single coefficient analysis? */
	
*The event study regressions offers a clearer perspective on the changing effects of unilateral divorce laws compared to the findings and analysis of question (e). 
*In particular, it is clear that right after the reform is implemented, divorce rates experience a positive and statistically significant increase. The first two post-reform years show statistically significant increases, suggesting that the laws had an immediate effect. The interpretation of this phenomenon is clear: when divorce became easier to obtain, all those couples that were under strain, were finally able to divorce. The effects become not statistically different from zero after the third year. This shows a slight short run increase of divorce rates, that is very short lived. 
*Before the legal reform, coefficients were small and statistically insignificant. This is important to note because it points towards the fact that, without the reform, divorce rates in treated and untreated states were similar. In the longer run, it appears like divorce rate decreases after the ninth year after the introduction of the law. This result is not robust to the introduction of the linear and quadratic terms. 
*When introducing state-specific linear trends, the effect appears to remain for longer, with it staying positive until after 5 years from the introduction of the unilateral divorce law. This is in line with the fact that, if states were on different trajectories before the introduction of the law, not including the time trends might bring to wrongly estimating the impact. 
*When including also the quadratic time trends, we see a short lived increase in the divorce rates , that quickly fades at the third year. These results are similar to the ones found in the simple regression without the linear trends.  
*However it is important to note that most coefficients remain statistically insignificant. In fact, only few coefficients of early post-treatment years show robust effects, and these become less precise as we control for linear and quadratic trends. This points towards the fact that there might be a real short-run response, but long-term effects are negligible or too noisy to detect confidently.


/* (j) Use the Stata command coefplot (or any other command of your choosing) to create a graph reporting the coefficients and the 95% confidence intervals of your 3 event-study regressions. */

coefplot ///
    (reg_simple, label("Simple Regression") msymbol(O) mcolor(blue)) ///
    (reg_timetrend, label("Linear Trend") msymbol(D) mcolor(red)) ///
    (reg_sqtime, label("Quadratic Trend") msymbol(T) mcolor(green)) ///
    , drop(_cons) ///
    keep(lead* lag*) ///
    xline(11, lpattern(dash) lcolor(gs10)) ///
    ciopts(recast(rcap) lwidth(medthin)) ///
    xlabel(1 "L10" 2 "L9" 3 "L8" 4 "L7" 5 "L6" 6 "L5" 7 "L4" 8 "L3" 9 "L2" 10 "L1" ///
           11 "0" 12 "1" 13 "2" 14 "3" 15 "4" 16 "5" 17 "6" 18 "7" 19 "8" 20 "9" 21 "10" ///
           22 "11" 23 "12" 24 "13" 25 "14" 26 "15", angle(45)) ///
    ylabel(, angle(horizontal)) ///
    xtitle("Event Time") ///
    ytitle("Coefficient") ///
    title("Event-Study Estimates with 95% Confidence Intervals") ///
    vertical
graph export "${ps_output}/event_study_regression.pdf", replace

/* (k) Wolfers (2006) presents a summary of the debate regarding the influence of the unilateral divorce law in the divorce rates. How do the conclusions of the paper differ from Friedberg (1998)? How does the author rationalize the difference in his findings? */

*Wolfers (2006) differs from Friedberg (1998) in both conclusions and interpretation. While Friedberg finds that unilateral divorce laws account for about one-sixth of the rise in divorce rates since the late 1960s, Wolfers argues that her results may confound preexisting trends with the effects of the policy. Wolfers finds that although divorce rates rise sharply after the adoption of unilateral divorce laws, this increase is not persistent. In fact, about 15 years later, early adopters tend to have lower divorce rates. He rationalizes the difference by highlighting that Friedberg's analysis may not adequately separate dynamic policy effects from underlying state-specific trends.

/* (l) Several different procedures to estimate a staggered Difference-in-Differences analysis have been proposed recently. Let us now perform one of these procedures. You will use command eventstudyinteract in Stata, based on Sun and Abraham (2021) 

Now perform an analogous analysis to the event-study regression in exercise (i) based on the Sun and Abraham (2021) estimation. Once again, report your results in an event-study graph. Are your results consistent with the ones from the original paper? Briefly explain what kind of correction your proposed algorithm is performing.*/

drop time_trend_*
drop timetrend_square_*

*simple
eventstudyinteract div_rate lead* lag* [aweight=stpop], cohort(lfdivlaw) control_cohort(no_law) absorb(i.year i.state) vce( cluster state)
estimates store reg_interact_simple
outreg2 using "${ps_output}/Reg4.xlsx", title("regression ex l 1") label excel replace
matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C
coefplot matrix(C[1]), se(C[2]) keep(lag* lead*) vertical yline(0) xtitle("Years after law") ytitle("Estimated effect") ///
				title("Simple Event Study") xlabel(, alternate)
graph export "${ps_output}/interact_simple.pdf", replace

*linear time trends

forval i=1/51{
	bysort state (year): gen time_trend_`i'=_n if state==`i' 
	replace time_trend_`i'=0 if time_trend_`i'==.
}
local lineartime time_trend_*

eventstudyinteract div_rate lead* lag* [aweight=stpop], cohort(lfdivlaw) covariates(`lineartime') control_cohort(no_law) absorb(i.year i.state ) vce(cluster state)
estimates store reg_interact_linear
outreg2 using "${ps_output}/Reg5.xlsx", title("regression ex l 2") label excel replace
*graph
matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C
coefplot matrix(C[1]), se(C[2]) keep(lag* lead*) vertical yline(0) xtitle("Years after law") ytitle("Estimated effect") ///
				title("Event Study with Linear Time Trends") xlabel(, alternate)
graph export "${ps_output}/interact_linear.pdf", replace
				
*squared time trends


forval i=1/51{
	bysort state (year): gen timetrend_sq_`i'=_n^2 if state==`i'
	replace timetrend_sq_`i'=0 if timetrend_sq_`i'==.
}
local squaretrend timetrend_sq_*

eventstudyinteract div_rate lead* lag* [aweight=stpop], cohort(lfdivlaw) control_cohort(no_law) covariates(`lineartime' `squaretrend') absorb(i.year i.state) vce(cluster state)
estimates store reg_interact_squared
outreg2 using "${ps_output}/Reg6.xlsx", title("regression ex l 3") label excel replace

*graph

matrix C = e(b_iw)
mata st_matrix("A",sqrt(diagonal(st_matrix("e(V_iw)"))))
matrix C = C \ A'
matrix list C
coefplot matrix(C[1]), se(C[2]) keep(lag* lead*) vertical yline(0) xtitle("Years after law") ytitle("Estimated effect") ///
				title("Event Study with Square Time Trends") xlabel(, alternate)
graph export "${ps_output}/final_graph.pdf", replace
				
restore
				
*In Sun and Abraham (2021) the following is discussed: with heterogenous treatment effects, standard event-study coefficients are not able to capture the dynamic treatment effects. So, with the eventstudyinteract command, the estimators are "interaction-weighted": at first, the CATT (Cohort-specific Average Treatment effect on the Treated) is estimated , then the CATT estimates are averaged across cohorts at a given relative period. These estimators are robust to heterogeneous treatment effects. 

*Comparison with the results from the original paper:
*In general, the results found in this exercise are in line with what was found by the original paper, so in both cases what has been found is a short run increase in the divorce rates in the first years after the introduction of the unilateral divorce laws. After a couple of years, the effect becomes insignifcantly different from zero. When adding squared time trends, there is an unusual output. In particular, ten years before the introduction of the law, there is a significantly positive effect, that then is zero for most of the other time periods analyzed, and it becomes significantly negative after the eleventh period after the introduction of the law. 
