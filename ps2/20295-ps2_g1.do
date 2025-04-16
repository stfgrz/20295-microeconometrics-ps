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
ssc install ivreg2, replace
ssc install estout, replace
ssc install avar, replace
ssc install eventstudyinteract, replace
ssc install bacondecomp, replace
 */

/* For graphs & stuff */
/*
ssc install grstyle, replace
ssc install coefplot, replace
graph set window fontface "Lato"
grstyle init
grstyle set plain, horizontal
*/
local user = c(username)

if ("`user'" == "erick") {
    global filepath "/home/erick/TEMP/"
}

if ("`user'" == "stefanograziosi") {
	cd "/Users/stefanograziosi/Documents/GitHub/20295-microeconometrics-ps"
    global filepath "/Users/stefanograziosi/Documents/GitHub/20295-microeconometrics-ps/ps2"
	global output "/Users/stefanograziosi/Documents/GitHub/20295-microeconometrics-ps/ps2/ps2_output"
}

if ("`user'" == "gabrielemole") {
    global filepath "/Users/stealth/Documenti/GitHub/20295-microeconometrics-ps/ps1"
	global output "/Users/stealth/Documenti/GitHub/20295-microeconometrics-ps/ps1/ps1_output"
}

*=============================================================================
/* 								Question 1 									*/
/* Use the file jtrain2 													*/
*=============================================================================

use "https://raw.githubusercontent.com/stfgrz/20295-microeconometrics-ps/blob/5c6aebedcdd74f0e85b270c2d25c9e0c9f5501aa/ps2/ps2_data/pset_4.dta", clear

/* (a) Note that one of the variables in the data set is stpop, the state population. In the next exercises, you should follow Wolfers (2006) in weighting both your descriptive output and your analysis by the state population. A short summary of the different weighting procedures in Stata is provided here ([1,2]). Given that divorce rates are an average computed in each state and the variable stpop provides the population in each of these states, which is the weight you should use when reporting the evolution of divorce rates or a regression of divorce rates on unilateral divorce laws to match the analysis in Wolfers (2006)? */

	/* A: Wolfers (2006) adopts a weighted least squared framework, using population weights to account for unbalanced microdata and a treatment variable at the state level. As the treatment variable is at the state level and div_rate is a state mean, we should follow  Dupraz (2013) adopting the state population (stpop) as the analytical weights and robust standard errors with vce(robust). This procedure improves computational efficiency and would yield the same estimates as relying on "fweight" and clustered standard errors. */
	
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
	*text(6.3 1973 "29 states adopted", size(small) color(black) place(n)) //*check if it is 29 states 
	*text(6 1973 "unilateral divorce", size(small) color(black) place(n))
    ytitle("Divorce rate" "Divorces per 1,000 persons per year")

;

#delimit cr

graph export "Graph_1.pdf", replace

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

graph export "Graph_2.pdf", replace
restore 


	/* A: A preliminary analysis does not find a strong support for the parallel trend assumption (PTA). 

Graph 2 shows that treated countries had higher baseline divorce rates compared to the control group. From a first graphical exploration control states and reform states seem to follow similar trajectories before the treatment. Yet the difference among the two groups increases over time, starting from 1.238 in 1956 and noticeably reaching 1.71 in 1968 (38% increase). While we observe a relevant rise of divorce rates in 1970, the outcome variable slowly congerges to the pre-treatment levels. 

This can be explained in line with Wolfers (2006): there is a sort of endogeneity of treatment status, as treated countries already showed a tendency towards more divorces, and the reforms simply freed up the marriages that could not break up due to bilateral divorce laws. In other words the increase in the difference could be explained as a result of all the people who could not divorce previously to the reform and cumulated as a stock ready to be released. Due to this considerations, no clear support for the PTA is found but proper statistical test should be adopted to have clear conclusions. 
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

		/* A: Graph 2 showed that baseline level of divorce rate in treated group is higher than control group. Hence regression i) overestimates the treatment effect as it does not control for group fixed effect. Indeed, after controlling for group fixed effect through the UNILATERAL dummy the treatment effect (1.70 and statistically significant at every conventional level) disappears. The estimated coefficient is negative but very close to 0 (-.005) and statistically insignificant. Thus, this first analysis provides evidence against the hypothesis that the introduction of unilateral divorce laws increased divorce rates.*/
	
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
	putexcel set "table_1.xlsx", replace
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
	
	/* A: Across all specification the estimated coefficient for IMP_UNILATERAL should yield the average treatment effect of the introduction of unilateral divorce laws on divorce rates, provided the parallel trend assumption is met. (ASSICURARSI SIA COSI' ANCHE NELLA TERZA iii). Regression i) estimates a model controlling for both time invariant state fixed effects and time variant effects that are common to all states. This is obtained by adding state and time dummies. The estimated coefficient is -0.05 and statistically insignificant. This supports the hypothesis of a null treatment effect that we found also in the previous simple analysis.
	
Yet as we add a state specific linear trend in regression ii the estimated coefficient for IMP_UNILATERAL increases to 0.477 and becomes statistically significant at every conventional level of significance. After adding quadratic state specific trends in regression iii the coefficient slightly decreases to 0.334 while remaining statistically significant. The estimates show a comparable behavior to Friedberg (1998), where controlling for state specifice trends found a positive effect of the divorce law, differently from the the null effect found in the baseline specification. Because the coefficients change over time the estimated coefficients seem to suffer from omitted variable bias due to different trends among the subgroups that are correlated with the divorce rate. 

This bias is less prominent after controlling for state specific quadratic time trends. Compared to Friedberg (1998) we can better identify the state trends before the treatment as we rely on a wider dataset. Overall these result seem to provide evidence that it is unlikely that the parallel trend assumption holds. Indeed, the estimated coefficients should be the same in all specifications provided control and treatment follow the same trends, which is not this case.  
	*/
	

/* (f) In our current case study, unilateral divorce laws have been introduced subsequently in different states at different points in time. In such cases, we say that there was a staggered implementation of the treatment. Regressions with a single coefficient, as the ones performed in exercise e), may be biased in this setting. Let us now check some of the properties of these regressions. We will create a simulated data set of 3 periods and 2 states, where one state receives a treatment in the 2nd period and the other state only receives it in the 3rd period. The code below reproduces this simulation: */

/* Created simulated observations */

preserve
clear

set 		obs = 6 
gen 		obs = _n ;
gen 		state = floor(.9 + obs/3)
bysort		state : gen year = _n ;
gen 		D = state == 1 & year == 3 ;
replace 	D = 1 if state == 2 & ( year == 2 | year == 3 ) ;

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
	
	De Chaisemartin and d'Haultfoeuille (2020) show that in a fixed effect design with heterogeneous treatment effects and under the parallel trend assumption the estimated coefficient β_fe for the treatment effect could be decomposed as the expectation of a weighted sum of the Δg,t terms, namely the average treatment effect in group g and period t coming frm pairwise difference in differences. The issue is that weights can assume negative values, yiealding a downard bias and possibly leading to estimated negative treatment effect even if the average treatment effects on the treated are all positive. Negative weights arise as a result of relying on Difference in Differences where in some cases the control group is already treated due to staggered treatment adoption. Weights are computed using the residual of a regression of the treatment dummy on fixed and time effect, that is basically obtained through demeaning. Hence, demeaning on control groups that were already treated is more likely to yield negative weights. 

This is the situation that seems to happen in this case, where the treatment adoption is staggered. The twowayfeweights command show that the estimated β_fe is a result of a weighted sum where a negative weight is present. De Chaisemartin and d'Haultfoeuille (2020) show that it is more likely to assign negative weights to periods where a large fraction of groups are treated, and to groups treated for many periods, which in our case is period 3 and the group that is treated from time 2 that we will denote by group 2. This was also the component that influenced the bias in the previous regressions. Thus a plausible explanation of the estimated negative coefficient for β_fe is that the negative weighted ATE_2, overcompensates the positive contributions of the other ATE, and that the ATE_2,3 increases depending on the effect of the specific changes in state 2 at year 3.

This situation aligns with the example the authors provide in their papers. They showed that under the error decomposition
εg,t = Dg,t − Dg,. − D.,t + D.,. ,
(where εg,t is the residual error to compute the weights, Dg,t the treatment status dummy, Dg, the average treatment status of the group, D.,t, the average treatment status at that time, and D.,. the average treatment status overall), the weight given to the average treatment effect Δ2,3 is negative. In addition to this, considering β_fe = (DID1 + DID2)/2 they show that bias arises from the second difference in differences:
DID2 = E[Δ1,3] − (E[Δ2,3] − E[Δ2,2]).
Greater increases in E[Δ2,3] − E[Δ2,2] bias downward the β_fe, which explains why bigger increases in the effect at year 3 for group 2 lead to higher biases. 
	
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
	graph rename bacondecomp
	graph export "Bacon_decomposition_graph.pdf", replace
restore
	
/* (i) Let us now perform an event-study regression, allowing for the unilateral divorce law coefficients to vary across time. Your analysis will follow table 2 in Wolfers (2006). We will have the period right before the introduction of the law as our basis of comparison, creating dummies for leads and lags for all other distances between our observation period and the law introduction in that state. This means that for any time period t and state s, the dummy Dτ st will be equal to one if in that specific period, state s has introduced unilateral divorce laws τ years before. Following the analysis in the main paper, we will set 
	
	SEE FORMULA ON PDF
	
That is, the dummy will be equal to one for all observations with 15 or more years of unilateral divorce law. For the lead dummies, let us restrict

	SEE FORMULA ON PDF
	
So that this dummy will equal 1 for all observations 10 or more years before the introduction of the unilateral divorce law in that state. Notice that this specification has some deviations from the one performed in table 2 of the original paper. */

	/* (i) Run the regresson below, using the unilateral divorce dummies Dτ st you created and sector (πs) and year (γt) fixed effects. */
	
	/* (ii) Perform the same regression as the one described above, now including state-specific linear time trends. */
	
	/* (iii) In addition to state-specific linear time trends, include also quadratic state-specific time trends. */
	
	/* (iv) Interpret the results of all 3 regressions. What can we see in the behaviour of divorce rates through this analysis that was not possible in the single coefficient analysis? */
	

/* (j) Use the Stata command coefplot (or any other command of your choosing) to create a graph reporting the coefficients and the 95% confidence intervals of your 3 event-study regressions. */

/* (k) Wolfers (2006) presents a summary of the debate regarding the influence of the unilateral divorce law in the divorce rates. How do the conclusions of the paper differ from Friedberg (1998)? How does the author rationalize the difference in his findings? */

/* (l) Several different procedures to estimate a staggered Difference-in-Differences analysis have been proposed recently. Let us now perform one of these procedures. You will use command eventstudyinteract in Stata, based on Sun and Abraham (2021) 

Now perform an analogous analysis to the event-study regression in exercise (i) based on the Sun and Abraham (2021) estimation. Once again, report your results in an event-study graph. Are your results consistent with the ones from the original paper? Briefly explain what kind of correction your proposed algorithm is performing.*/


	



	





















