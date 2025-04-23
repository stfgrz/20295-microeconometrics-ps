*=============================================================================

/*						20295 MICROECONOMETRICS							   	*/

/*							Problem Set 3								   	*/

*=============================================================================

/* Group number: 1 */

/* Group composition: Stefano Graziosi, Gabriele Molè, Sofia Briozzo */
*=============================================================================

*=============================================================================
/* 								Setup 										*/
*=============================================================================

clear

set more off

/* For commands */

/* First time running this code? Please remove the comment marks from the code below and install of the necessary packages */

ssc install outreg2, replace
ssc install rdrobust, replace
ssc install estout, replace
ssc install rddensity, replace
ssc install lpdensity, replace
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
    global filepath "/Users/stefanograziosi/Documents/GitHub/20295-microeconometrics-ps/ps3"
	global output "/Users/stefanograziosi/Documents/GitHub/20295-microeconometrics-ps/ps3/ps3_output"
}

if ("`user'" == "gabrielemole") {
    global filepath "/Users/stealth/Documenti/GitHub/20295-microeconometrics-ps/ps1"
	global output "/Users/stealth/Documenti/GitHub/20295-microeconometrics-ps/ps1/ps1_output"
}

*=============================================================================
**#								Instructions								*/
*=============================================================================

	/* This problem set is composed of two exercises, each exercise focusing on a different regression discontinuity design (RDD). In Exercise 1, we follow a standard RDD application, Meyers- son (2014), 
	to study the effect that Islamic political representation had on the educational attainment of women in Turkey during the late 1990s. In Exercise 2, we turn to a spatial RDD, Gonzalez (2021), 
	to study the effect of cell phone coverage on electoral frauds. */
	
/*								Commands									*/

	/* Regression discontinuity designs are implementable with packages such as rdrobust, rddensity and lpdensity, among others, in both R and Stata. You should install these before proceeding. */
	
/*								Instructions								*/

	/* (1) rdrobust reports estimates from different estimation methods: (1) Conventional, (2) Bias-corrected, and (3) Robust. In this problem set, any rdrobust output should be reported with Conventional 
	betas and standard errors. Nonetheless, note that in your own research it is recommended that you report Conventional betas and Robust standard errors */
	
	/* (2) Unless asked otherwise, use as default options for your rdrobust estimates:
		
		-> kernel(triangular) p(1) bwselect(mserd)
		
		*/
	
	/* (3) Have in mind that some commands have different default procedures in Stata and R. Since we are not asking you to specify some of these procedures, it is normal that sometimes the results are
	not exaclty the same between the two languages. */

*=============================================================================
**#								Exercise 1 									*/
/* Use the file pset_3.dta													*/
*=============================================================================

use "https://raw.githubusercontent.com/stfgrz/20295-microeconometrics-ps/500c011b31d4929fb126f88bfbc4fe39e27d5ac9/ps3/ps3_data/pset_3.dta", clear

**# Question (a) 

	/* (i) Generate a RD Plot of ``T - Islamic mayor in 1994'' - against ``X - Islamic Vote Margin in 1994'' - when the Islamic party wins and lose an election. 
	Call the y-axis - ``Treatment Variable'' ; call the x-axis - ``Running variable'' */
	
	/* (ii) Is the current design a sharp or a fuzzy RD? Why? */

**# Question (b)

	/* (i) Create a macro named `covariates' containing the baseline variables: ``hischshr1520m i89 vshr islam1994 partycount lpop1994 merkezi merkezp subbuyuk buyuk'' */
	
	/* (ii) Create a table named ``Table_1'', summarizing RD estimates for all baseline variables. Table_1 should have the following columns: Label, MSE-Optimal Bandwidth, RD Estimator, p-value */
	
**# Question (c)

	/* (i) Generate a RD plot for each of the baseline variables on `covariates`. */
	
	/* (ii) Use `graph combine` to generate a unique graphic containing all 9 RD plots. */
	
	/* (iii) Title each RD subplot so that the reader is able to identify each subplot to the corresponding outcome. Save the unique graphic as `Graph 1`. */
	
**# Question (d)

	/* (i) Generate a graphic with histograms for the observations to the left and the observations to the right of our cutoff. Choose contrasting colors for the histograms on each side of our cutoff. */
	
	/* (ii) Use `rddensity` to generate a graphic of our running variable X's estimated density. */
	
	/* (iii) In both graphics, plot a vertical line to signal our cutoff. Save a graphic named `Graph_2` containing the histogram plot and the estimated density plot side-by-side. */
	
**# Question (e)

	/* (i) Use `rddensity` to test if a discontinuity in our running variable X's density does not exist in our cutoff. */
	
	/* (ii) What are we able to conclude from such test? */
	
	/* (iii) Is it favorable or against the validity of our RD design? */
	
**# Question (f)

	/* (i) Test if alternative discontinuities do not exist in the following alternative cutoffs:

		-10, -5, 5, 10. */
	
	/* (ii) Did we found any evidence in favor of the absence of alternative discontinuities? */
	
/* After validating our RD design, we can estimate our treatment's effect on our outcomes and check for the robustness of our results. That is what we will do in the following questions. */
	
**# Question (g)

	/* (i) Generate a RD Plot of ``Y - Share Women aged 15-20 with High School Education'' - against ``X - Islamic Vote Margin in 1994'' - when the Islamic party wins and loose an election. 
	
		Use 40 Evenly-Spaced Bins.
		
		Call the y-axis - `Outcome; call the x-axis - `Running Variable' */
	
**# Question (h) 

	/* (i) Use rdrobust to estimate the effect of ``T - Islamic mayor in 1994'' - on ``Y - Share Women aged 15-20 with High School Education'' using a linear polynomial. */
	
	/* (ii) Try both an uniform and triangular kernel. */
	
	/* (iii) Does electing a mayor from an Islamic party has a significant effect on the educational attainment of women? Do results differ significantly for different kernel choices? */
	
/* MANDATORY: Use a triangular kernel for these next items. */
	
**# Question (i) Estimate the effect of T on Y but using a global approach.

	/* (i) Do not choose any bandwidth. Use a polynomial of order 4. */
	
	/* (ii) Run a regular linear regression instead of rdrobust. */
	
**# Question (j) Estimate the effect of T on Y but using a local approach by restricting our sample to a window within an optimal bandwidth that we should have obtained with rdrobust (mserd bandwidth).

	/* (i) Run a regular linear regression. */
	
	/* (ii) Use a linear polynomial. */
	
	/* (iii) Do we get the exact same result as in item (h)? If not, explain why. 
		
		HINT: In the `rdrobust` post-estimate, save our optimal bandwidth in a local using:

			`local opt i = e(h l)` */
	
**# Question (k) Save item (h)'s bandwidth as a scalar named opt i.

	/* (i) Re-estimate item (h)'s RD using as alternative bandwidths:
	
		`0.5*opt i, 0.75*opt i, 1.25*opt i, and 1.5*opt i`*/
	
	/* (ii) Plot each five RD point estimates, including that from item (h), with their respective confidence intervals in a graphic named Graph 3. */
	
	/* (iii) What can we say about the robustness of our results with respect to bandwidth choice? */

*=============================================================================
**#								Exercise 2 									*/
/* Use the file pset_3.dta													*/
*=============================================================================

**# Question (a)

	/* (i) Plot the treatment variable used at Gonzalez (2021) as a function of this new running variable. In addition, compute the RD estimate for a regression where you model the 
	same treatment variable as a function of the new running variable. */
	
	/* (ii) Is the current design a sharp or a fuzzy RD? */
	
	/* (iii) Which assumptions must hold in order for the one-dimensional RD estimates of Gonzalez (2021) to be valid? */

**# Question (b)

	/* (i) Point out in which setting does having a proxy for longitude does not require you to change RD design (relative to Gonzalez, 2021).
	
	HINT: Read the "Additional Results" section of Gonzalez (2021) and reflect on which type of cell phone coverage boundary would deliver you this result. */

**# Question (c)

	/* (i) Use fraud pcenter final to partially replicate Columns 1, 3 and 5 of Table 2 under this new RD setting (present only point estimates). Interpret your new estimates.
	
	HINT: use ``Table_onedim_results.do'' and review your RDD slides. */
	
