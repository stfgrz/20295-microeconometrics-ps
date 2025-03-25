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

	/* A: */
	
/* (b) The article relies on the timing of the introduction of unilateral divorce laws to compare divorce rates in the two possible regimes. One of the assumptions of this analysis is that states with the previous divorce law and the ones that introduced unilateral divorce laws would both follow parallel trends in their divorce rates in the absence of the changes to the legislation. Create 2 different graphs to support this assumption: (i) the first graph should convey the same message as the one in Figure 1 of the original paper, comparing states that did not change their divorce laws during 1968 - 1988 (Friedberg's sample) and the ones that did; (ii) the second graph should perform the same description, but focusing on the simpler analysis we will perform in the next exercise: compare the states adopting the unilateral divorce law between 1969 and 1973 to the ones that introduced it in the year 2000, only reporting the time trend up to 1978 and including a vertical line between 1968 and 1969 (when the first reforms in our sample started). Do your results support the assumption of parallel trends? */

	/* A: */
	
/* INSTRUCTIONS: Let us now start an analysis of the effects of the introduction of unilateral divorce laws. As a first step, let us perform a 2-period difference-in-difference analysis using "long differences", focusing on the evolution of divorces between 1968 and 1978. Keeping only these 2 years in our sample, you should compare states adopting the unilateral divorce law between 1969 and 1973 to the ones that introduced it in the year 2000. On this restricted sample, you should create: (i) a variable UNILATERAL equal to 1 if a state introduced the unilateral divorce law during this period (as signaled by variable lfdivlaw); (ii) a variable POST equal to 1 if the year is 1978; and (iii) a variable POST UNILATERAL when both POST and UNILATERAL are equal to 1. */
	
/* (c) Now estimate the following regressions: */
	
	/* (i) A pooled OLS regression of the divorce rate per 1,000 people (div rate) on POST UNILATERAL and POST; */
	
		/* A: */
	
	/* (ii) A full Difference-in-Differences specification, including POST, UNILATERAL and POST UNILATERAL as regressors; */
	
		/* A: */
	
	/* (iii) Based on the graphs you created in section (a), could you say something about the difference in the coefficients from regressions (i) and (ii)? What is the effect of introducing unilateral divorce laws according to this analysis? */

		/* A: */
	
/* (d) Generate a 3 by 3 matrix with row and column labels as follows: SEE PS2 
Difference 1 should show differences across columns while Difference 2 across lines. Complete this matrix with the averages of div rate, replicating the results you have found in the previous regression. Then, export the matrix to an Excel table named TABLE 1.*/

	/* A: */
	
/* (e) We will now perform the analysis using our complete data set, as in the main results of Wolfers (2006). For this, always focus on the same sample as the one used in Table 2 of the original paper (keeping observations between 1956 and 1988). Load once again our data set and create the dummy variable IMP UNILATERAL, which equals 1 whenever a state has already introduced unilateral divorce laws (as signaled by variable lfdivlaw). Now run the following regressions: */

	/* (i) A regression of div rate on state and year dummies and the dummy IMP UNILATERAL that you created. */
		
		/* A: */
	
	/* (ii) Perform the same regression as the one described above, now including state-specific linear time trends.  */
	
		/* A: */
	
	/* (iii) In addition to state-specific linear time trends, include also quadratic state-specific time trends. */
	
		/* A: */

	/* (iv) Interpret the results of all 3 regressions. Can you think of a reason for the results to change across specifications? Under which assumption should these results be the same? */ 
	

/* (f) In our current case study, unilateral divorce laws have been introduced subsequently in different states at different points in time. In such cases, we say that there was a staggered implementation of the treatment. Regressions with a single coefficient, as the ones performed in exercise e), may be biased in this setting. Let us now check some of the properties of these regressions. We will create a simulated data set of 3 periods and 2 states, where one state receives a treatment in the 2nd period and the other state only receives it in the 3rd period. The code below reproduces this simulation: */

/* Created simulated observations */

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
	
		/* A: */
	
/* (g) Use the Stata package "twowayfeweights" (or its R version, "TwoWayFEWeights"), based on De Chaisemartin and d'Haultfoeuille (2020), to estimate the weights attached to the regressions you estimated before. Can you explain why the sign of the estimated effect has changed between the regression on Y and the one on Y4? */

	/* A: */
	
/* (h) Let us now revisit our analysis following Wolfers (2006). We will do this based on the decomposition proposed by Goodman-Bacon (2021). The author provides commands in both Stata and R for his decomposition. To install it in Stata, run the code below: */

	/* (i) create a modified population variable init stpop equal to the population of each state in the first observed period of each state. */
	
	/* (ii) Rerun regression i of exercise (e) (a regression of div rate on state and year dummies and the dummy IMP UNILATERAL that you created) using init stpop as your weights. */
	
	/* (iii) Run the command bacondecomp to analyze the decomposition of the treatment effect. Plot the graph showing the relationship between the treatment effect estimates and the corresponding weights. Briefly explain what is the analysis proposed by Goodman-Bacon (2021). Is there evidence of issues regarding negative weights? */
	
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


	



	





















