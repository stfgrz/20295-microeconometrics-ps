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

/* For graphs & stuff */

ssc install grstyle, replace
ssc install coefplot, replace
graph set window fontface "Lato"
grstyle init
grstyle set plain, horizontal

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

if ("`user'" == "39331") {
    global filepath "C:\Users\39331\OneDrive - Università Commerciale Luigi Bocconi\Desktop\MICROMETRICS\PS3\pset_3.dta"
	global output "C:\Users\39331\OneDrive - Università Commerciale Luigi Bocconi\Desktop\MICROMETRICS\PS3\Output"
}

*=============================================================================
**#								Instructions								*/
*=============================================================================

	/* This problem set is composed of two exercises, each exercise focusing on a different regression discontinuity design (RDD). In Exercise 1, we follow a standard RDD application, Meyers- son (2014), to study the effect that Islamic political representation had on the educational attainment of women in Turkey during the late 1990s. In Exercise 2, we turn to a spatial RDD, Gonzalez (2021), to study the effect of cell phone coverage on electoral frauds. */
	
/*								Commands									*/

	/* Regression discontinuity designs are implementable with packages such as rdrobust, rddensity and lpdensity, among others, in both R and Stata. You should install these before proceeding. */
	
/*								Instructions								*/

	/* (1) rdrobust reports estimates from different estimation methods: (1) Conventional, (2) Bias-corrected, and (3) Robust. In this problem set, any rdrobust output should be reported with Conventional betas and standard errors. Nonetheless, note that in your own research it is recommended that you report Conventional betas and Robust standard errors */
	
	/* (2) Unless asked otherwise, use as default options for your rdrobust estimates:
		
		-> kernel(triangular) p(1) bwselect(mserd)
		
		*/
	
	/* (3) Have in mind that some commands have different default procedures in Stata and R. Since we are not asking you to specify some of these procedures, it is normal that sometimes the results are not exaclty the same between the two languages. */

*=============================================================================
**#								Exercise 1 									*/
/* Use the file pset_3.dta													*/
*=============================================================================

use "https://raw.githubusercontent.com/stfgrz/20295-microeconometrics-ps/500c011b31d4929fb126f88bfbc4fe39e27d5ac9/ps3/ps3_data/pset_3.dta", clear

**# Question (a) 

	/* (i) Generate a RD Plot of ``T - Islamic mayor in 1994'' - against ``X - Islamic Vote Margin in 1994'' - when the Islamic party wins and lose an election. 
	Call the y-axis - ``Treatment Variable'' ; call the x-axis - ``Running variable'' */
	
rdplot T X, graph_options(title(RD Plot) ytitle("Treament Variable") xtitle("Running Variable") legend(off)) graph rename T_X replace
graph export "$output/disc_plot.png", replace
	
	/* (ii) Is the current design a sharp or a fuzzy RD? Why? */
	
		/* A: The graph shows a Sharp Regression Discontinuity design. In a sharp RD, treatment assignment changes deterministically at the cutoff, which means that everyone above the threshold receive the treatment (in our case they have an islamic mayor) and everyone below the threshold does not receive the treatment (and so they do not get a islamic mayor). The plot shows a clean jump from 0 to 1 exactly at the thresholds, with no observations receiving treatment left of the cutoff, and all receiving observations receiving the treatment on the right. */

**# Question (b)

	/* (i) Create a macro named `covariates' containing the baseline variables: ``hischshr1520m i89 vshr islam1994 partycount lpop1994 merkezi merkezp subbuyuk buyuk'' */
	
local covariates hischshr1520m i89 vshr_islam1994 partycount lpop1994 merkezi merkezp subbuyuk buyuk
	
	/* (ii) Create a table named ``Table_1'', summarizing RD estimates for all baseline variables. Table_1 should have the following columns: Label, MSE-Optimal Bandwidth, RD Estimator, p-value */
	
local covariates hischshr1520m i89 vshr_islam1994 partycount lpop1994 merkezi merkezp subbuyuk buyuk

local num: list sizeof covariates
mat balance = J(`num',4,.)
mat list balance 
local row = 1
foreach z in `covariates' {
    qui rdrobust `z' X
	mat balance[`row',1] = round(e(h_l) , .001)
	mat balance[`row',2] = round(e(tau_cl), .001)
	mat balance[`row',3] = round(e(pv_cl), .001)
	mat balance[`row',4] = round(e(N_h_l) + e(N_h_r), .001)
	local ++row
}
mat rownames balance = "Share Men High School Education" "Islamic Mayor in 1989" "Islamic vote share 1994" "N parties receiving votes 1994" " Log Population in 1994" " District center" " Province center" "Sub-metro center" "Metro center"
mat colnames balance = "MSE-Optimal Bandwidth" "RD Estimator" "p-value" "Effective Number of Observations"
mat list balance 

putexcel set "$output/table1.csv", replace
putexcel A1=matrix(balance), names nformat(number_d2)
putexcel (A2:A10), overwr bold border(right thick) 
putexcel (B1:E1), overwr bold border(bottom thick)

esttab matrix(balance) using "$output/table1.csv", replace

		/* A: Since all p-values are large, this implies that covariates are balanced across the cutoff. The balance checks suggest that the treatment assignment around the cutoff is as good as random, supporting validity of the RD design. */
	
**# Question (c)

	/* (i) Generate a RD plot for each of the baseline variables on `covariates`. */
	
local covariates hischshr1520m i89 vshr_islam1994 partycount lpop1994 merkezi merkezp subbuyuk buyuk

local label1 "Men High School Education (1989)"
local label2 "Islamic Mayor in 1989"
local label3 "Islamic Vote Share (1994)"
local label4 "Parties Receiving Votes (1994)"
local label5 "Log of Population (1994)"
local label6 "District Center Dummy"
local label7 "Province Center Dummy"
local label8 "Sub-Metro Center Dummy"
local label9 "Metro Center Dummy"

local i = 1
foreach var of local covariates {
    local title "`label`i''"
    rdplot `var' X, graph_options(title("`title'") ytitle("Treament Variable", size(3)) xtitle("Running Variable", size(3)) legend(off) name(`var'_X, replace))
    local ++i
}
	
	/* (ii) Use `graph combine` to generate a unique graphic containing all 9 RD plots. */
	
graph combine hischshr1520m_X i89_X vshr_islam1994_X partycount_X lpop1994_X merkezi_X merkezp_X subbuyuk_X buyuk_X, cols(3)
	
	/* (iii) Title each RD subplot so that the reader is able to identify each subplot to the corresponding outcome. Save the unique graphic as `Graph 1`. */
	
graph export "$output/Graph_1.png", replace
	
**# Question (d)

	/* (i) Generate a graphic with histograms for the observations to the left and the observations to the right of our cutoff. Choose contrasting colors for the histograms on each side of our cutoff. */
	
rdrobust Y X, kernel(triangular) p(1) bwselect(mserd)
scalar h_left = -e(h_l)
scalar h_right = e(h_r)
twoway (histogram X if X >=h_left & X < 0, color(navy%70)) ///
         (histogram X if X >= 0 & X <= h_right,  color(orange%70) xline(0, lcolor(black) lpattern(solid))), name(hist_1, replace) ///
      graphregion(color(white)) xtitle(Islamic Vote Margin) ytitle(Density) legend(off) 

local h_l = h_left
local h_r = h_right
	
	/* (ii) Use `rddensity` to generate a graphic of our running variable X's estimated density. In both graphics, plot a vertical line to signal our cutoff. */
	
rddensity X, plot plot_range(`h_l' `h_r') graph_opt(name(hist_2, replace) legend(off) xline(0, lcolor(black) lpattern(solid)) xtitle(Islamic Vote Margin) ytitle(Density))
	
	/* (iii) Save a graphic named `Graph_2` containing the histogram plot and the estimated density plot side-by-side. */
	
graph combine hist_1 hist_2
graph export "$output/Graph_2.png", replace
	
**# Question (e)

	/* (i) Use `rddensity` to test if a discontinuity in our running variable X's density does not exist in our cutoff. */
	
rddensity X , all plot
graph export "$output/Graph_3.png", replace
	
	/* (ii) What are we able to conclude from such test? Is it favorable or against the validity of our RD design? */
	
		/* A: The command rddensity implements manipulation testing procedures using local polynomial density estimators as proposed in Cattaneo, Jannson and Ma (2020). To implement an RD design, an important assumption is that the treatment is "as good as random", and so that the control group (so the observations just under the cutoff) are credible counterfactuals to those just above the cutoff. The command rddensity tests whether this is the case. The tests consists in testing whether the density is discontinuous at the cutoff. The null hypothesis is that the function is continuous at the cutoff.

		For small window sizes, the p-values are large, so there is no evidence against the null hypothesis (no manipulation). On the other hand, as the window increases in size (from the largest window size of 4.261) , the p-value drops, suggesting that at larger scales there might be manipulation. At the same time, manipulation is typically a bigger issue closer to the cutoff, so it should not be an issue. 

		With the conventional test, we have a small p-value (0.0145) , that might suggest a manipulation at the cutoff, but the robust version of the tests finds a p-value of 0.1634 that suggests no strong evidence of manipulation after accounting for bias correction.

		In general, based on our results, there appears to be no manipulation at the cutoff. Hence, this supports the assumption that the assignment to treatment is likely valid, as there is no evident manipulation of municipalities around the cutoff.  */
	
**# Question (f)

	/* (i) Test if alternative discontinuities do not exist in the following alternative cutoffs:

		-10, -5, 5, 10. */
		
*** Baseline Test
rdrobust Y X, c(-10) 
*conv. p-value: 0.003, robust: 0.006
rdrobust Y X, c(-5) 
*conv. p-value: 0.246 , robust: 0.268
rdrobust Y X, c(5) 
*conv. p-value: 0.624 , robust: 0.472
rdrobust Y X, c(10) 
*conv. p-value: 0.193 , robust: 0.162
	
	/* (ii) Did we found any evidence in favor of the absence of alternative discontinuities? */
		
		/* A: At the arbitrarily chosen cutoffs of -5, 5 and 10, the null hypothesis of the presence of discontinuities is not rejected. 
		
		At the cutoff -10 there is a statistically significant jump, which might be a problem. This could suggest a local anomaly, and we might ahve found the jump at this cutoff by change. This can happen, especially when testing multiple placebo cutoffs. 
		
		To conclude, we have found no consistent evidence that there are discountinuities at random cutoffs, and this supports our findings of the discontinuity at the actual cutoff, in line with RD design assumptions.  */
	
/* After validating our RD design, we can estimate our treatment's effect on our outcomes and check for the robustness of our results. That is what we will do in the following questions. */
	
**# Question (g)

	/* (i) Generate a RD Plot of ``Y - Share Women aged 15-20 with High School Education'' - against ``X - Islamic Vote Margin in 1994'' - when the Islamic party wins and loose an election. 
	
		Use 40 Evenly-Spaced Bins.
		
		Call the y-axis - `Outcome; call the x-axis - `Running Variable' */
		
rdplot Y X, nbins(20 20) binselect(es) graph_options(title("RD plot") ytitle(Outcome) xtitle(Running Variable))
*note that c(0) is the default

graph export "$output/RD_Plot.pdf", replace

	
**# Question (h) 

	/* (i) Use rdrobust to estimate the effect of ``T - Islamic mayor in 1994'' - on ``Y - Share Women aged 15-20 with High School Education'' using a linear polynomial. Try both an uniform and triangular kernel. Does electing a mayor from an Islamic party has a significant effect on the educational attainment of women? Do results differ significantly for different kernel choices? */
	
*uniform
rdrobust Y X, p(1) kernel(uni) bwselect(mserd)
outreg2 using table_1.tex, append se bdec(3) sdec(3) ///
ctitle("Uniform Kernel")

*triangular
rdrobust Y X, p(1) kernel(tri) bwselect(mserd)
outreg2 using table_1.tex, replace se bdec(3) sdec(3) ///
ctitle("Triangular Kernel")


/* A: We find a positive and statistically significant effect of the election of a muslim party on the share of women with high school education. 
The estimated Treatment Effect at the cutoff is 3.2019 percentage points for the uniform kernel and 3.0195 percentage points for the triangular kernel. Both estimates are significant at the 5% level using conventional standard errors (as requested in the guidelines of the problem set). It is worth mentioning that using robust standard errors the p-value for the triangular kernel increases to 0.076, hence granting significance only at the 10% level. 
 The uniform kernel gives equal weights to the observations in the bandwith, while the triangular one gives linearly less weight as observations get further from the cutoff. The results are yet fairly comparable between different approaches.  */
	
/* MANDATORY: Use a triangular kernel for these next items. */
	
**# Question (i) Estimate the effect of T on Y but using a global approach.

	/* (i) Do not choose any bandwidth. Use a polynomial of order 4. */
	
	/* (ii) Run a regular linear regression instead of rdrobust. */
	
*as the cutoff is 0 then X-c = X
gen X2 = X^2
gen X3 = X^3
gen X4 = X^4

reg Y T X X2 X3 X4 i.T#c.X i.T#c.X2 i.T#c.X3 i.T#c.X4
outreg2 using table_1.tex, append se bdec(3) sdec(3) ///
ctitle("Unweighted Global Regression")

*Triangular weights 
gen wght= .
sum X, d
scalar min = r(min)
scalar max = r(max)
replace wght = (1-abs(X/min)) if X<0
replace wght = (1-abs(X/max)) if X>=0

reg Y T X X2 X3 X4 i.T#c.X i.T#c.X2 i.T#c.X3 i.T#c.X4 [aw = wght]
outreg2 using table_1.tex, append se bdec(3) sdec(3) ///
ctitle("Triangular Global Regression")

	
**# Question (j) Estimate the effect of T on Y but using a local approach by restricting our sample to a window within an optimal bandwidth that we should have obtained with rdrobust (mserd bandwidth).

	/* (i) Run a regular linear regression. Use a linear polynomial. */
	
	/* (ii) Do we get the exact same result as in item (h)? If not, explain why. 
	
		HINT: In the `rdrobust` post-estimate, save our optimal bandwidth in a local using:

			`local opt i = e(h l)` */
			
preserve
rdrobust Y X, p(1) kernel(triangular) bwselect(mserd)
local opt_i e(h_l)
display `opt_i'
drop if X>`opt_i' | X <-`opt_i'
reg Y T X i.T#c.X
*Save the files
outreg2 using table_1.tex, append se bdec(3) sdec(3) ///
ctitle("Unweighted Local Regression")
restore

*triangular weights
preserve
rdrobust Y X, p(1) kernel(triangular) bwselect(mserd)
local opt_i = e(h_l)
display `opt_i'
drop if X>`opt_i' | X <-`opt_i'
gen whgt2 = .
replace whgt2 = (1 - abs(X/`opt_i')) if X < 0 & X >= -`opt_i'
replace whgt2 = (1 - abs(X/`opt_i')) if X >= 0 & X <= `opt_i'

reg Y T X i.T#c.X [aw = whgt2]
outreg2 using table_1.tex, append se bdec(3) sdec(3) ///
ctitle("Triangular Local Regression")
restore

/* A: The global unweighted regression yields a point estimate of 3.683 (statistically significant at the 5% level). This is quite different from the one found in point h). If we adopt triangular weights in the regression, the estimates returns a value of 3.028359 (statistically significant at the 5% level), comparable to the one in h) but probably still a bit noisy due to the large number of observations far from the cutoff used and the high-order polynomial that might be overfitting. An alternative strategy is then restricting the sample to a bandwith close to the cutoff and using linear first order polynomials. 

Using the uweighted local regression, the estimated treatment effect at the cutoff is 3.06. Results are not the same in h) yet are not dramatically different. The slight disrepancy might be due to the different weights given to the observations. The triangular kernel used in h) gives less weight to observation far from the cutoff. These are equally weighted in the regression, hence capturing some noise the kernel was cancelling out. Indeed if we estimate the regression in j) using triangular kernels the estimated treatment effect at the cutoff is virtually identical to h). */

	
**# Question (k) Save item (h)'s bandwidth as a scalar named opt i.

	/* (i) Re-estimate item (h)'s RD using as alternative bandwidths:
	
		`0.5*opt i, 0.75*opt i, 1.25*opt i, and 1.5*opt i`*/

rdrobust Y X, p(1) kernel(triangular) bwselect(mserd)
local opt_i = e(h_l)
estimates store reg_band_3
rdrobust Y X, p(1) kernel(triangular) h(0.5*`opt_i' 0.5*`opt_i')
estimates store reg_band_1
rdrobust Y X, p(1) kernel(triangular) h(0.75*`opt_i' 0.75*`opt_i')
estimates store reg_band_2
rdrobust Y X, p(1) kernel(triangular) h(1.25*`opt_i' 1.25*`opt_i')
estimates store reg_band_4
rdrobust Y X, p(1) kernel(triangular) h(1.5*`opt_i' 1.5*`opt_i')
estimates store reg_band_5
	
	/* (ii) Plot each five RD point estimates, including that from item (h), with their respective confidence intervals in a graphic named Graph 3. */
	
coefplot ///
    (reg_band_1, label("Bandwidth 0.5") msymbol(O) mcolor(navy)) ///
    (reg_band_2, label("Bandwidth 0.75") msymbol(D) mcolor(maroon)) ///
    (reg_band_3, label("Bandwidth 1.0") msymbol(S) mcolor(forest_green)) ///
    (reg_band_4, label("Bandwidth 1.25") msymbol(T) mcolor(orange_red)) ///
    (reg_band_5, label("Bandwidth 1.5") msymbol(H) mcolor(magenta)) ///
, ///
    title("Coefficient Estimates Across Bandwidths") ///
    ytitle("Coefficient Estimate") ///
    xtitle("Variable") ///
    msiz(medium) ///
	xlabel(, grid) ///
    ciopts(recast(rcap) color(gs8)) ///
    scheme(s1color) ///
    legend(on)
	
graph export "$output/Graph_3.pdf", replace

	/* (iii) What can we say about the robustness of our results with respect to bandwidth choice? */
	
		/* A: Relying on various intervals for the bandwith shows the bias-variance trade off in the estimation of the local average treatment effect. 
The graph shows the point estimates coming from the adoption of different bandwiths and the 95% level confidence intervals. If we keep a very small bandwith by taking 0.5*opt_i the estimates is likely to be less biased but it is highly volatile. Indeed, the coefficient is not statistically significant, with wide standard errors. The variance diminishes as we increase the width of the bandwith reaching statistical significance when using the values of opt_i. The coefficient slightly increases (from 1.8 to 3.02) compared to the 0.5*opt_i interval, showing that the cost of smaller variance comes with an estimate that is likely to be marginally biased. Increasing the bandwith does not come with a great increase in variance while yielding point estimates comparable to the baseline case of opt_i */


*=============================================================================
**#								Exercise 2 									*/
/* Use the file pset_3.dta													*/
*=============================================================================

use "https://raw.githubusercontent.com/stfgrz/20295-microeconometrics-ps/2f55a86f76628ec3c31c25581dafa7e4469a9f9c/ps3/ps3_data/fraud_pcenter_final.dta", clear

* First of all, we need to generate the appropriate variables

gen runvar = cond(cov==1, _dist, -_dist)
label variable runvar "Signed distance to boundary (neg=outside, pos=inside)"

gen D = runvar>=0 /* GM: occhio che mi sa che qui devi mettere = cov perché ci sono casi in cui hai copertura ma il tuo D=0*/
label variable D "Indicator: inside coverage"

gen fraud1 = (frnum_comb>0)
label variable fraud1 "1 if ≥1 Category C station"

gen outcome_a = vote_comb_ind
label variable outcome_a "at least one station with category C fraud"

gen outcome_b = vote_comb
label variable outcome_b "share of votes with category C fraud"

**# Question (a)

	/* (i) Plot the treatment variable used at Gonzalez (2021) as a function of this new running variable. In addition, compute the RD estimate for a regression where you model the 
	same treatment variable as a function of the new running variable. */
	
twoway ///
  (lpolyci cov runvar if runvar<0, bwidth(2) lcolor(blue)      ) ///
  (lpolyci cov runvar if runvar>=0, bwidth(2) lcolor(red)     ) ///
  (scatter cov runvar,     ///
      msymbol(circle) msize(vsmall) mcolor(gs14%40) jitter(0.002)) ///
  , xline(0, lpattern(dash) lwidth(thin)) ///
    xtitle("Signed distance (km)", size(medium)) ///
    ytitle("Pr(Coverage = 1)", size(medium)) ///
    title("First-Stage Coverage Probability", size(large)) ///
    scheme(s1color) ///
    graphregion(color(white)) bgcolor(white)
	
	/* rdplot T X if X>-20 & X<20 + opzioni grafico*/
	
graph save "$output/g_covprob.gph", replace
graph export "$output/first_stage_coverage.pdf", as(pdf) replace


	*-----Panel A------------------*
	
rdrobust outcome_a runvar, p(1) kernel(triangular) bwselect(mserd)

foreach v in elevation slope {
	local fname = "`v'_rdplot"
	
	rdplot outcome_a runvar if runvar> -20 & runvar< 20, p(4) kernel(triangular) bwselect(mserd) ///
		title("rdrobust / rdplot with optimal bandwidth") ///
		name(`fname', replace)
	
	graph save "$output/`fname'.gph", replace
    graph export "$output/`fname'.pdf", as(pdf) replace
	
	reg `v' outcome_a runvar if abs(runvar)<=5, vce(cluster province_id)
	di as txt "`v' jump = " as res %6.3f
}

	*-----Panel B------------------*
	
rdrobust outcome_b runvar, p(1) kernel(triangular) bwselect(mserd)

foreach v in elevation slope {
	local fname = "`v'_rdplot"
	
	rdplot outcome_b runvar if runvar> -20 & runvar< 20, p(4) kernel(triangular) bwselect(mserd) ///
		title("rdrobust / rdplot with optimal bandwidth") ///
		name(`fname', replace)
	
	graph save "$output/`fname'.gph", replace
    graph export "$output/`fname'.pdf", as(pdf) replace
	
	reg `v' D runvar if abs(runvar)<=5, vce(cluster province_id)
	di as txt "`v' jump = " as res %6.3f _b[D]
}

* Density (McCrary) test
rddensity runvar, c(0)
	
	/* (ii) Is the current design a sharp or a fuzzy RD? */
	
		/* A: In the original article González (2021) models the mobile-coverage frontier as though it determined treatment perfectly: a polling centre that falls inside the raster cell is coded as treated, one that falls outside is coded as untreated, and the regressions estimate the sharp discontinuity in outcomes at that boundary.  The exercise you are asked to perform places that set-up in a different information environment.  Longitude is now observed with error—only a noisy proxy is available—while latitude is measured correctly.  González therefore computes each centre's Euclidean distance to the frontier with a coordinate that is partly wrong, and uses the sign of that proxy distance as if it told him on which side of the threshold the centre lies.  At the same time he retains an independent, accurately recorded indicator of whether the centre actually had a phone signal on election day.

		Because of the noise in longitude the proxy distance no longer maps deterministically into treatment status: some stations that truly lacked coverage are nevertheless calculated as having positive distance, while some that truly enjoyed coverage are calculated as negative.  What remains at zero proxy distance is not a clean cliff from treatment probability zero to one; instead the probability of treatment jumps upward but stops short of unity.  That probabilistic jump is what allows us to determine that we are dealing with a fuzzy regression-discontinuity design.  Position relative to the nominal frontier functions as a strong but imperfect instrument for realised coverage, and the causal parameter of interest becomes the local Wald ratio—the discontinuity in the fraud outcome divided by the discontinuity in the treatment rate—estimated within a narrow bandwidth around the threshold.

		Identification in this context still depends on the usual smoothness of potential outcomes with respect to the true but unobserved distance; in addition it requires that the longitudinal measurement error be random, unrelated to potential fraud outcomes, and mild enough that crossing the proxy boundary never makes a centre less likely to receive coverage (monotonicity).  Under those conditions, estimating two local-linear regressions—one with the fraud variable and one with the treatment indicator as dependent variables, both as functions of the proxy distance and latitude, with boundary-segment fixed effects—yields two discontinuities whose ratio consistently recovers the causal effect of mobile coverage for the polling centres whose treatment status is genuinely altered by being measured just inside or just outside the threshold.  In short, once the running variable is observed with noise while an accurate treatment flag is available, the design that had been sharp in González (2021) must be analysed as a fuzzy RD and the boundary indicator must be treated as an instrument rather than as the treatment itself. */
	
	/* (iii) Which assumptions must hold in order for the one-dimensional RD estimates of Gonzalez (2021) to be valid? */
	
		/*A: For that one-dimensional sharp RD to deliver credible causal estimates, a sequence of conditions—some generic to the RD framework, others specific to the geographic setting—must hold. 
		
		First, the potential outcomes (the fraud measures that would be observed with or without coverage) must vary smoothly with location so that any jump exactly at distance = 0 can only be attributed to the treatment. Gonzalez subjects an extensive battery of electoral, demographic, topographic and development covariates to the same discontinuity test applied to the outcomes and shows that, once the sample is narrowed to polling centres lying within a few kilometres of the frontier, those characteristics evolve continuously across it; none of them mimics the break in fraud that the treatment generates​​.
		
		Second, there must be no strategic manipulation of the running variable: polling stations (or the villages they serve) cannot have been placed deliberately "just inside" or "just outside" coverage in anticipation of the election. A recent Cattaneo-Jansson-Ma density test reveals no bunching of observations on either side of zero distance, which supports the absence of sorting or gaming of the assignment mechanism​​.
		
		Third, since the cut-off is geographical rather than behavioural, the Stable Unit Treatment Value Assumption is plausible: a centre's fraud behaviour is unlikely to be affected by whether a neighbouring centre metres away is, technically, on the other side of the invisible radio boundary, and empirical tests detect neither spill-overs nor displacement of fraud into nearby untreated areas​​. 
		
		Because the physical environment is rugged and cellular footprints can be irregular, it is equally important that the smooth functions used to partial out latitude and longitude are flexible enough within the selected bandwidth. Gonzalez adopts the Calonico-Cattaneo-Titiunik bandwidth selector, estimates separate low-order polynomials on each side of the cut-off, and shows that alternative polynomial orders or wider/narrower windows leave the treatment coefficient essentially unchanged​​.

		Moreover, comparison must always be local; accordingly the author discards any stretch of frontier for which at least one side lacks observations, thereby satisfying the "boundary positivity" requirement that every segment offer both treated and control units for comparison​​.

		Under those assumptions the discontinuity in fraud that Gonzalez documents can be interpreted as the deterrent effect of enabling voters to communicate irregularities in real time. */

**# Question (b)

	/* (i) Point out in which setting does having a proxy for longitude does not require you to change RD design (relative to Gonzalez, 2021).
	
	HINT: Read the "Additional Results" section of Gonzalez (2021) and reflect on which type of cell phone coverage boundary would deliver you this result. */
	
		/* A: In the specific case we are asked to consider, the regression-discontinuity design would remain sharp—despite the noisy longitude—only if the treatment frontier were an east-west, horizontal line so that coverage status depended exclusively on latitude.  With such a geometry every polling centre's signed distance to the boundary can be computed with the formula ``runvar = latitude – φ0'' where φ0 is the latitude of the coverage edge.  Longitude never enters that calculation, so measurement error in the east-west coordinate has absolutely no bearing on whether a centre is classified as "inside" or "outside." 
		
		The indicator  `D = 1(runvar ≥ 0)' would therefore remain a deterministic function of the running variable, and the first-stage discontinuity in the probability of treatment would still jump from zero to one.  In other words, the essential identifying feature of a sharp RD—the perfect alignment between the crossing of the cut-off and receipt of treatment—would survive intact, and no fuzzy correction would be necessary.

		González effectively illustrates this point in the "Additional Results" section of the paper when he implements placebo boundaries defined by randomly chosen latitudes.  Those boundaries slice the map along horizontal lines; because only latitude matters, any mis-recorded longitude cannot create misclassification at those artificial cut-offs, and the estimated discontinuities collapse to zero.  The exercise demonstrates that as soon as the frontier can be described by latitude alone, noise in longitude is innocuous.  By contrast, the real Afghan 2-G footprint winds through both latitude and longitude, so once longitude is observed imprecisely the relationship between the nominal cut-off and true coverage becomes probabilistic, forcing the researcher to treat the specification as a fuzzy RD. */

**# Question (c)

	/* (i) Use fraud pcenter final to partially replicate Columns 1, 3 and 5 of Table 2 under this new RD setting (present only point estimates). Interpret your new estimates.
	
	HINT: use ``Table_onedim_results.do'' and review your RDD slides. */

* Optimal bandwidth

foreach var in 600 95 ecc comb comb_ind {
		rdbwselect vote_`var' runvar if ind_seg50==1, vce(cluster segment50)
		scalar hopt_`var'=e(h_mserd)
		forvalues r=1/2 {
			rdbwselect vote_`var' runvar if ind_seg50==1 & region2==`r', vce(cluster segment50)
			scalar hopt_`var'_`r'=e(h_mserd)
	}
}

xtset, clear
xtset segment50 pccode

*Local Linear Regression 

gen T=cov	
label variable T "Coverage dummy"
gen instrument_T=0
replace instrument_T=1 if runvar>0
gen interaction=T*runvar
label variable interaction "Interaction between coverage dummy and outcome variable"
gen instrument_interaction=runvar*instrument_T
 
*** Only using the treatment instrument 

foreach var in comb_ind comb {	
	* All regions
	xtivreg vote_`var' (T = instrument_T) runvar if ind_seg50==1 & _dist<=hopt_`var', fe  vce(robust)
		est store col1_a1_`var'
		

	* Southeast
	xtivreg vote_`var' (T = instrument_T) runvar if ind_seg50==1 & _dist<=hopt_`var'_1 & region2==1, fe vce(robust)  
		est store col1_b1_`var'
		

	* Northwest
	xtivreg vote_`var' (T = instrument_T) runvar if ind_seg50==1 & _dist<=hopt_`var'_2 & region2==2, fe vce(robust)
		est store col1_c1_`var'
	
 }



foreach var in comb_ind comb {	
	* All regions
	xtivreg vote_`var' (T interaction = instrument_T instrument_interaction) runvar if ind_seg50==1 & _dist<=hopt_`var', fe  vce(robust)
		est store col1_a2_`var'
		
	* Southeast
	xtivreg vote_`var' (T interaction = instrument_T instrument_interaction) runvar if ind_seg50==1 & _dist<=hopt_`var'_1 & region2==1, fe vce(robust)  
		est store col1_b2_`var'
		
	* Northwest
	xtivreg vote_`var' (T interaction = instrument_T instrument_interaction) runvar if ind_seg50==1 & _dist<=hopt_`var'_2 & region2==2, fe vce(robust)
		est store col1_c2_`var'
	
 }

/*Aggiungere clusters optimal bandwidth? */

* Panel A
estout col1_a1_comb_ind  col1_a2_comb_ind  col1_b1_comb_ind  col1_b2_comb_ind col1_c1_comb_ind  col1_c2_comb_ind   ///
using "$output/Table_2.tex", replace style(tex) ///
keep(T) label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
mlabels(, none) collabels(, none) eqlabels(, none) ///
stats(N, fmt(a3) ///
labels("Observations")) ///
prehead("\begin{table}[H]" "\centering" "\begin{tabular}{lcccccc}" ///
	"\noalign{\smallskip} \hline \hline \noalign{\smallskip}" ///
	"& \multicolumn{6}{c} {RDD - Optimal Bandwidth}"   ///
	"\noalign{\smallskip} \\ " ///
	"& \multicolumn{2}{c} {All regions} & \multicolumn{2}{c} {SE region} & \multicolumn{2}{c} {NW region}\\" ///
	" & (1) & (2) & (3) & (4) & (5) & (6) \\" ) ///
	posthead("\hline \noalign{\smallskip}" "\multicolumn{6}{l}{\emph{Panel A. At least one station with Category C fraud}} \\" "\noalign{\smallskip} \noalign{\smallskip}" ) ///
	prefoot("\noallign{\smallskip}" "Interaction & & \checkmark & & \checkmark & & \checkmark \\")

* Panel B
estout col1_a1_comb  col1_a2_comb  col1_b1_comb  col1_b2_comb col1_c1_comb  col1_c2_comb  ///
using "$output/Table_2.tex", append style(tex) ///
posthead("\noalign{\smallskip} \noalign{\smallskip} \noalign{\smallskip}" "\multicolumn{6}{l}{\emph{Panel B.  Share of votes under Category C fraud}} \\" "\noalign{\smallskip} \noalign{\smallskip}" ) ///
keep(T) label cells(b(star fmt(3)) se(par fmt(3))) starlevels(* 0.10 ** 0.05 *** 0.01) ///
mlabels(, none) collabels(, none) eqlabels(, none) ///
stats(N, fmt(a3) ///
labels("Observations")) ///
prefoot("\noallign{\smallskip}" "Interaction & & \checkmark & & \checkmark & & \checkmark \\") ///
postfoot("\noalign{\smallskip} \hline \hline \noalign{\smallskip}" ///
	"\end{tabular} \end{table}")

	/* A: The different estimation strategy leads to a change in both point estimates and significance levels of the coefficients. Point estimates are generally lower compared to Table 2. The coefficients lose in significance too. Panel A shows that the overall estimated effect on "At least one station with Category C fraud" is negative (-11.1 percentage points) yet not statistically significant. Panel B presents a negative and statistically significant effect of the coverage of 10.1 percentage points on the "Share of votes under Category C fraud". 
Similarly to Gonzalez (2021), there is heterogeneity in effects. In Panel A South-East regions have a significant negative effect (- 29.0 percentage points) while North-West ones are associated to a positive (2.5 percentage points) yet insignificant effect. The estimates in Panel B follow a similar dynamic. South-East regions yield a negative effect of -28.2 percentage points, and North-West areas show almost null and insignificant coefficients. 

	Overall, there are not striking differences among the two instrumental strategies: point estimates are virtually equal while the interaction instument is related to a slight drop in significance in South-East regions in both Panel A and Panel B. This corroborates the hypothesis of a constant slope of the outcome with respect to the running variable. The IV estimates the Local Average Treatment Effect on the compliers, provided the "no-defiers" assumption is met. In this context it seems plausible to assume that the treatment dummy does not decrease at the cutoff: according to the reported figures in Gonzalez (2021) the covered areas are wide enough to assume that once you step into them the coverage persists for various kilometres.
		
	The difference compared to Table 2 is likely due the different estimated bandwith: by applying comparable methodologies for calculating the optimal bandwidth, and taking into account the very fact that our design requires a larger set of information to carry out inference, it is reasonable to assume that our larger bandwith imply a tradeoff; namely, we are dealing with the bias-variance trade-off: shifting to a local regression reduces bias by relying on less-noisy observations, namely the ones close to the cut-off, while increasing the variance due to the reduction in the number of the observations, hence explaining why the estimates become statistically insignificant. */
		

