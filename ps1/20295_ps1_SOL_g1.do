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

/*
ssc install outreg2, replace
ssc install ivreg2, replace
ssc install estout, replace
ssc install randomizr, replace
ssc install ritest, replace
ssc install lassopack, replace
ssc install pdslasso, replace
ssc install ranktest, replace
ssc install balancetable, replace
ssc install randtreat, replace
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
    global filepath "/Users/stefanograziosi/Documents/GitHub/20295-microeconometrics-ps/ps1"
	global output "/Users/stefanograziosi/Documents/GitHub/20295-microeconometrics-ps/ps1/ps1_output"
}

if ("`user'" == "gabrielemole") {
    global filepath "CAMBIA"
}

if ("`user'" == "39331") {
    global filepath "CAMBIA"
}

*=============================================================================
/* 								Question 1 									*/
/* Use the file jtrain2 													*/
*=============================================================================

use "https://raw.githubusercontent.com/stfgrz/20295-microeconometrics-ps/abc3c6d67f27161b9899cedb19c8ff1016402746/ps1/jtrain2.dta", clear

/* (a) Construct a table checking for balance across treatment and control for the following covariates: age educ black hisp nodegree re74 re75.
Name it TABLE 1.
Present for each variable: mean for treated, mean for controls, standard deviations for treated, standard deviations for control, difference in means between treatment and control, appropriate standard errors for difference in means.
Comment on how many variables are balanced or not. Is it what you expected? */

matrix table_1a = J(7,6,.)

local covars "age educ black hisp nodegree re74 re75"
local row_1a = 1

foreach var of local covars {
	ttest `var', by(train)
    
    local treated_mean = r(mu_2)
    local control_mean = r(mu_1)
    local treated_sd = r(sd_2)
    local control_sd = r(sd_1)
    local diff_mean = `treated_mean' - `control_mean'
    local se_diff = r(se)
    
    matrix table_1a[`row_1a',1] = `treated_mean'
    matrix table_1a[`row_1a',2] = `control_mean'
    matrix table_1a[`row_1a',3] = `treated_sd'
    matrix table_1a[`row_1a',4] = `control_sd'
    matrix table_1a[`row_1a',5] = `diff_mean'
    matrix table_1a[`row_1a',6] = `se_diff'
    
    local row_1a = `row_1a' + 1
}

matrix colnames table_1a = TreatedMean_j3 ControlMean_j3 TreatedSD_j3 ControlSD_j3 DiffMean_j3 SE_Diff_j3
matrix rownames table_1a = age educ black hisp nodegree re74 re75

matrix list table_1a

esttab matrix(table_1a) using "ps1/ps1_output/table_1.tex", replace tex ///
    title("Balance Check Across Treatment and Control") ///
    cells("result(fmt(3))") ///
	nomtitles

/* (b) Regress re78 on train.
Save the estimate and the standard error of the coefficient on train as scalars.
Interpret the coefficient. */

regress re78 train, vce(robust)

scalar coef1 = _b[train]
scalar se1 = _se[train]

	/* A: By running a regression of the real earnings in 1978 on training (which represents our treatment variable), we obtain a positive coefficient of 1.794343 significant at the 5% level; this implies that real earnings, in our experiment, were positive correlated with the training programme.
	
	We ought to keep in mind that, despite the coefficient being statistically significant and different from zero, the R^2 of our model (0.0178) suggests that there are other factors responsible for the vast portion of the variation of real earnings in 1978 */

/* (c) Construct a table by sequentially adding the output of the following regressions to each column:
(1) re78 on train;
(2) re78 on train age educ black hisp;
(3) re78 on train age educ black hisp re74 re75;
Add rows to the table with the number of controls and treated in each regression. Name it TABLE 2. */

matrix table_1c = J(4, 3, .)
local col_1c = 1

*Regression 1*

count if e(sample) & train==0
scalar controls1 = r(N)
count if e(sample) & train==1
scalar treated1 = r(N)

matrix table_1c[1, `col_1c'] = coef1
matrix table_1c[2, `col_1c'] = se1
matrix table_1c[3, `col_1c'] = controls1
matrix table_1c[4, `col_1c'] = treated1

local col_1c = `col_1c' + 1

*Regression 2*

regress re78 train age educ black hisp, vce(robust)

scalar coef2 = _b[train]
scalar se2   = _se[train]

count if e(sample) & train==0
scalar controls2 = r(N)
count if e(sample) & train==1
scalar treated2 = r(N)

matrix table_1c[1, `col_1c'] = coef2
matrix table_1c[2, `col_1c'] = se2
matrix table_1c[3, `col_1c'] = controls2
matrix table_1c[4, `col_1c'] = treated2

local col_1c = `col_1c' + 1

*Regression 3*

regress re78 train age educ black hisp re74 re75, vce(robust)

scalar coef3 = _b[train]
scalar se3   = _se[train]

count if e(sample) & train==0
scalar controls3 = r(N)
count if e(sample) & train==1
scalar treated3 = r(N)

matrix table_1c[1, `col_1c'] = coef3
matrix table_1c[2, `col_1c'] = se3
matrix table_1c[3, `col_1c'] = controls3
matrix table_1c[4, `col_1c'] = treated3

*Table 2*

matrix rownames table_1c = Coef_train SE_train N_controls N_treated
matrix colnames table_1c = Reg(1) Reg(2) Reg(3)

matrix list table_1c

esttab matrix(table_1c) using "ps1/ps1_output/table_2.tex", replace tex ///
    title("Sequential Regression Results") ///
    cells("result(fmt(3))") ///
	nomtitles 
	
/* Are your results sensitive to the introduction of covariates? */

	/* A: No, given that our coefficient for the treatment programme does not change significantly as we introduce covariates, we can safely state that our results are relatively robust */

/* (d) dfbeta is a statistic that measures how much the regression coefficient of a certain variable changes in standard deviations if the i-th observation is deleted.
If using Stata, type help dfbeta and discover how to estimate this statistic after a regression.
Generate a variable named influence_train storing the dfbetas of train of the last regression you did in point (c).
Redo the last regression you did in point (c) but removing the observations with the 3, 5, and 10 lowest and largest values in influence train.
Are your results sensitive to influential observations? */

regress re78 train age educ black hisp re74 re75, vce(robust)
dfbeta, stub(influence_)

egen rank_influence = rank(influence_1), field

*3 observations*

preserve
	summarize influence_1, meanonly
	local N = r(N)
	drop if rank_influence <= 3 | rank_influence >= (`N' - 3 + 1)
	regress re78 train age educ black hisp re74 re75, vce(robust)
	estimates store trim3
restore

*5 observations*

preserve
    summarize influence_1, meanonly
	local N = r(N)
	drop if rank_influence <= 5 | rank_influence >= (`N' - 5 + 1)
	regress re78 train age educ black hisp re74 re75, vce(robust)
	estimates store trim5
restore

*10 observations*

preserve
    summarize influence_1, meanonly
	local N = r(N)
	drop if rank_influence <= 10 | rank_influence >= (`N' - 10 + 1)
	regress re78 train age educ black hisp re74 re75, vce(robust)
	estimates store trim10
restore

* Questa just in case ci fossimo persi qualcosa, secondo me ha senso ma non è richiesta #SG *

esttab trim3 trim5 trim10 using "ps1/ps1_output/table_3.tex", replace tex ///
    title("Regression Results After Removing Extreme Influence Observations") ///
    stats(N, fmt(%9.0g) label("N")) ///
	nomtitles 
	
	
		/* A: Although the coefficient on train decreases from 1.68 in the full sample to 1.02 after the most aggressive trimming, it remains statistically significant at each stage. This suggests that while the magnitude of the effect is somewhat sensitive to influential observations, the overall conclusion — i.e. that training has a positive effect on real earnings — holds.
		 
		On the other hand, we can also observe how some variables, like education, lose significance when the influential observations are removed, indicating that their estimated effects may be more affected by a few extreme cases. 

		For what it concerns the model's explanatory power, we observe that R^2 values do not change dramatically between the various trimming. */

*=============================================================================
/* 								Question 2 									*/
/* Use the jtrain3 															*/
*=============================================================================

* SBLOCCA STO COSO PER AVERE ACCESSO ALL'ALTRO DATASET | NON USARLI ENTRAMBI, QUESTO CANCELLA IL DATASET PRECEDENTE *

use "https://raw.githubusercontent.com/stfgrz/20295-microeconometrics-ps/abc3c6d67f27161b9899cedb19c8ff1016402746/ps1/jtrain3.dta", clear

/* (a) Do a table with the same structure of TABLE 1 of item (a) in question 1 for the following covariates: age educ black hisp re74 re75 (note that nodegree is not present in the current dataset.) Add the corresponding columns to TABLE 1. */

matrix table_2a = J(6,6,.)

local covars "age educ black hisp re74 re75"
local row_2a = 1

foreach var of local covars {
	ttest `var', by(train)
    
    local treated_mean = r(mu_2)
    local control_mean = r(mu_1)
    local treated_sd = r(sd_2)
    local control_sd = r(sd_1)
    local diff_mean = `treated_mean' - `control_mean'
    local se_diff = r(se)
    
    matrix table_2a[`row_2a',1] = `treated_mean'
    matrix table_2a[`row_2a',2] = `control_mean'
    matrix table_2a[`row_2a',3] = `treated_sd'
    matrix table_2a[`row_2a',4] = `control_sd'
    matrix table_2a[`row_2a',5] = `diff_mean'
    matrix table_2a[`row_2a',6] = `se_diff'
    
    local row_2a = `row_2a' + 1
}

matrix list table_2a

matrix table_2a_new = J(7,6,.)
forvalues i = 1/4 {
    forvalues j = 1/6 {
        matrix table_2a_new[`i', `j'] = table_2a[`i', `j']
    }
}
forvalues i = 5/6 {
    forvalues j = 1/6 {
        matrix table_2a_new[`i'+1, `j'] = table_2a[`i', `j']
    }
}

matrix drop table_2a
matrix table_2a = table_2a_new

matrix list table_2a

matrix table_1a_2a = table_1a, table_2a

matrix colnames table_1a_2a = TreatedMean_treat_1a ControlMean_treat_1a TreatedSD_treat_1a ControlSD_treat_1a DiffMean_treat_1a SE_Diff_treat_1a TreatedMean_treat_2a ControlMean_treat_2a TreatedSD_treat_2a ControlSD_treat_2a DiffMean_treat_2a SE_Diff_treat_2a

matrix list table_1a_2a

esttab matrix(table_1a_2a) using "ps1/ps1_output/table_1.tex", replace tex ///
    title("Balance Check Across Treatment and Control") ///
    cells("result(fmt(3))") ///
	nomtitles

/* (b) Generate a variable named treated that randomly allocates half of observations to a (fake) treatment group and the other half to a (fake) control group. Fix a seed of 5 digits using the command set seed. */

set seed 20295
gen treated = runiform()

replace treated =0 if treated <= 0.5
replace treated =1 if treated > 0.5

tabulate treated

/* (c) If using Stata, type ssc install randtreat. Then, read randtreat help file. */
	
	/* (i) Redo point (b) using the command randtreat. (ii) Name treated 2 your new (fake) treatment variable.*/
	
randtreat, generate(treated_2) setseed(20295) misfits(strata) // check this out as one value results to this misfitted	
		
	/* (iii) Check whether the correlation between treated 2 and treated is statistically significant or not. (Hint: use pwcorr X Y, sig) */
	
pwcorr treated treated_2, sig

/* (d) Do a table with the same structure of TABLE 1 of item (a) in question 1., but using treated instead of train. */ 

	/* (i) Use the same list of covariates of item (a) of this question. */
	
matrix table_2d = J(6,6,.)

local covars "age educ black hisp re74 re75"
local row_2d = 1

foreach var of local covars {
	ttest `var', by(treated)
    
    local treated_mean = r(mu_2)
    local control_mean = r(mu_1)
    local treated_sd = r(sd_2)
    local control_sd = r(sd_1)
    local diff_mean = `treated_mean' - `control_mean'
    local se_diff = r(se)
    
    matrix table_2d[`row_2d',1] = `treated_mean'
    matrix table_2d[`row_2d',2] = `control_mean'
    matrix table_2d[`row_2d',3] = `treated_sd'
    matrix table_2d[`row_2d',4] = `control_sd'
    matrix table_2d[`row_2d',5] = `diff_mean'
    matrix table_2d[`row_2d',6] = `se_diff'
    
    local row_2d = `row_2d' + 1
}

matrix colnames table_2d = TreatedMean_treat ControlMean_treat TreatedSD_treat ControlSD_treat DiffMean_treat SE_Diff_treat
matrix rownames table_2d = age educ black hisp re74 re75

matrix list table_2d
	
	/* (ii) Add the corresponding columns to TABLE 1. */
	
matrix table_2d_new = J(7,6,.)
	
forvalues i = 1/4 {
    forvalues j = 1/6 {
        matrix table_2d_new[`i', `j'] = table_2d[`i', `j']
    }
}
forvalues i = 5/6 {
    forvalues j = 1/6 {
        matrix table_2d_new[`i'+1, `j'] = table_2d[`i', `j']
    }
}

matrix list table_2d_new

matrix drop table_2d
matrix table_2d = table_2d_new

matrix list table_2d
	
matrix table_1a_2a_2d = table_1a_2a, table_2d

esttab matrix(table_1a_2a_2d) using "ps1/ps1_output/table_1.tex", replace tex ///
    title("Balance Check Across Treatment and Control") ///
    cells("result(fmt(3))") ///
	nomtitles
	
	/* (iii) What you find corresponds to your expectations? */
	
		/*
		As expected, being the treatment randomly allocated, covariates are balanced across both treatment and control.
		*/

/* (e)  */

	/* (i) Sequentially add the output of the following regressions to TABLE 2:
		(1) re78 on treated;
		(2) re78 on treated age educ black hisp;
		(3) re78 on treated age educ black hisp re74 re75. */
		
reg re78 treated, vce(robust)
count if e(sample) & treated == 0
local n_control= r(N)
count if e(sample) & treated == 1
local n_treated= r(N)
outreg2 using "ps1/ps1_output/table_2.tex", addstat("Number Treated",`n_treated', "Number Control",`n_control')ctitle (Randomised Treatment 1) append dta

reg re78 treated age educ black hisp, vce(robust)
count if e(sample) & treated == 0
local n_ctrl= r(N)
count if e(sample) & treated == 1
local n_trt= r(N)
outreg2 using "ps1/ps1_output/table_2.tex", addstat("Number Treated",`n_trt', "Number Control",`n_ctrl')ctitle (Randomised Treatment 1) append dta

reg re78 treated age educ black hisp re74 re75, vce(robust)
count if e(sample) & treated == 0
local n_ctrl= r(N)
count if e(sample) & treated == 1
local n_trt= r(N)
outreg2 using "ps1/ps1_output/table_2.tex", addstat("Number Treated",`n_trt', "Number Control",`n_ctrl')ctitle (Randomised Treatment 1) append dta
	
	/* (ii) Add lines in the table with the number of controls and treated in each regression. */
	
		/* A: This task was carried out for each individual regression with the command `addstat` */
	
	/* (iii) Comment on what you find. Is it what you expected? */
	
		/* A: */

/* (f) */

	/* (i) Sequentially add the output of the following regressions to TABLE 2:
		(1) re78 on train;
		(2) re78 on train age educ black hisp;
		(3) re78 on train age educ black hisp re74 re75. */
	
	
	
	/* (ii) Add lines in the table with the number of controls and treated in each regression. */
	
	
	
	/* (iii) Compare the results with the first three columns of TABLE 2. */
	
	
	
	/* (iv) Comment on what you find. Is it what you expected? Are your results sensitive to the introduction of covariates? */ 


*=============================================================================
/* 								Question 3 									*/
/* So far we have selected the covariates to be added to the regression ourselves. We will now use regularization methods to perform this selection in a data-driven approach.
You may use the lassopack package in Stata or the hdm package in R to perform your analysis. To answer the questions below, read Belloni et al. (2014) to understand the "double selection" procedure and check the help files of the commands above in the language you chose. */
*=============================================================================

use "https://raw.githubusercontent.com/stfgrz/20295-microeconometrics-ps/abc3c6d67f27161b9899cedb19c8ff1016402746/ps1/jtrain2.dta", clear

/* (a) Revisit your analysis of the data set jtrain2 in exercise 1 as a post-Lasso OLS estimation. */

	/* (i) To do this, in the first step you should perform a Lasso regression of re78 on age educ black hisp re74 re75. */
	
set seed 20295
	
rlasso re78 age educ black hisp re74 re75
	
		/* IMPORTANT NOTE: for the sake of clarity, our first attempt revolved around the robust lasso approach, here implemented by rlasso. Nonetheless, we faced difficulties as none of the variables would end up resulting statistically significant, exception made for the constant.
		
		Given this lack of results, we decided to relax our assumptions and implement a standard lasso approach, here exemplified by the command `lasso linear' */

lasso linear re78 age educ black hisp re74 re75
lassocoef
	
	/* (ii) Then, in a second step, run an OLS regression of re78 on train and all the variables selected in the first step. */
	
		/* A: According to the output, all of our previous variables were accepted, exception made for ``hisp'' */
	
regress re78 train age educ black re74 re75
	
	/* (iii) Discuss your results. What are the issues of performing inference based on such a regression? */

		/* A: For what it concerns our regression, we obtain a positive coefficient of 1.67495: this not only reinforces our previous analysis from point (1)a, but it also provides us with a slightly lower p-value which might indicate a more robust model specification.
		
		For what it concerns the approach, still, performing inference after a post‐Lasso OLS regression raises several challenges that arise largely from the fact that the model selection step is inherently data‐driven. When Lasso is used to select controls, the resulting set of regressors is not picked by us (the researcher), but it depends on the particularities of the sample and the chosen tuning parameter. This extra randomness is typically ignored by conventional OLS inference, leading to standard errors and confidence intervals that are too narrow and p‐values that might misrepresent the true level of uncertainty.

		Moreover, a naive approach that applies Lasso solely on the outcome equation can inadvertently drop variables that, while only moderately predictive of the outcome, are strongly correlated with the treatment variable; in this case, the issue is that such omissions risk introducing omitted‐variable bias into the treatment effect estimate. Even if one subsequently re-estimates the model using OLS on the selected variables—often called post‐Lasso—the initial selection step's bias can persist. Lasso's regularization not only shrinks coefficient estimates toward zero, but its selection process can also be sensitive to the penalty level, which further complicates the inference.

		In essence, while post‐Lasso OLS offers a useful strategy for reducing dimensionality in high-dimensional settings, the inference based on such a regression is fraught with complications. The additional variability introduced by the selection process, along with the risk of omitted-variable bias and regularization bias, means that traditional OLS standard errors are insufficient. Adopting the double selection method is a step in the right direction, but it also necessitates specialized adjustments in the inferential framework to yield reliable conclusions. */

/* (b) Now perform the "double selection" procedure as described by Belloni et al. (2014). We will perform this for two sets of variables in the exercises below. For each of these cases, you should first perform the "double selection" procedure directly using pdslasso in Stata or rlassoEffect in R and then check each step of this selection by running rlasso either in Stata or R.*/

	/* (i) In a first step, perform the "double selection" on the original variable list age educ black hisp re74 re75. Comment on your results. */
	
pdslasso re78 train (age black hisp re74 re75), rlasso

	/* We implemented the double selection procedure following the approach described by Belloni et al. (2014). The procedure involves two key selection steps: one for the outcome (re78) and one for the treatment (train). In both steps, none of the candidate high-dimensional controls—age, black, hisp, re74, and re75—were selected. In other words, the lasso did not add any extra controls beyond the constant term.

		The final structural equation, estimated with CHS lasso-orthogonalized variables, yields a statistically significant coefficient for the treatment variable (train) of approximately 1.79 (standard error 0.63, p = 0.004). This result indicates that, even after allowing for a data-driven selection of additional controls, the estimated effect of the treatment remains robust and significant.

		The absence of additional selected controls suggests that the potential confounders in our original variable list do not contribute significantly to explaining the variation in re78 or the treatment assignment beyond what is already captured. Consequently, our original covariate specification appears adequate, and the double selection procedure confirms the robustness of the estimated treatment effect. */
	
	/* (ii) Now increase the potential selected features by creating dummies for each of the age and educ levels (you're also free to add other variables, such as interactions between controls). Discuss your results and the improvements provided by the "double selection" procedure with respect to the one performed in Q3(a) */
	
egen agegrp = cut(age), group(4)
tabulate agegrp, generate(agegrp_d)

egen educgrp = cut(educ), group(4)
tabulate educgrp, generate(educgrp_d)

pdslasso re78 train (age educ black hisp re74 re75 agegrp_d1 agegrp_d2 agegrp_d3 agegrp_d4 educgrp_d1 educgrp_d2 educgrp_d3 educgrp_d4), rlasso

		/* A: In this part, we increased the pool of potential controls by creating categorical dummies for age and education. Specifically, we divided age and education into 6 groups each (using the egen command and then generating dummies), and then added these new variables to the existing list of controls. The purpose was to allow for more flexible (nonlinear) effects of age and education and to test whether these additional features might improve the selection process.

			After running the double selection procedure with this expanded set, the results remained consistent with the previous specification: the procedure still did not select any extra controls beyond those already included in the original model with robust lasso (the one we initially decided to discard as it was not providing statistically significant variables), and the estimated effect of the treatment variable remained at approximately 1.79 (with the same standard error and level of significance).

			This finding is quite informative. It suggests that even when we allow for a richer set of functional forms (through dummies for age and educ), the additional variables do not add explanatory power for predicting either the outcome or the treatment assignment. In other words, the balance between the treatment and control groups with respect to these characteristics appears to be good, and the original continuous measures of age and education already capture the necessary variation. Thus, the double selection procedure confirms the robustness of my original model and implies that the covariate balance is adequate. */
	
	/* (iii) What can you say about the balance of the characteristics of the treatment and control group based on the selected variables? */
	
		/* A: The results from the double selection procedure—both with the original covariate set and with the expanded set including dummies for age and educ—suggest that the treatment and control groups are well balanced with respect to the observed characteristics. Specifically, the procedure did not select any additional controls beyond those initially specified. This outcome indicates that none of the extra potential predictors (whether in their continuous form or as categorical dummies) were strongly associated with either the outcome (re78) or the treatment assignment (train) beyond what was already captured.

			This absence of additional selected variables implies that the observable covariates are comparably distributed between the treatment and control groups. In other words, the groups do not differ systematically on these characteristics. Consequently, any differences in the outcome can be more confidently attributed to the training program rather than to pre-existing imbalances. This is an important confirmation because one of the key challenges in observational studies is ensuring that the treatment and control groups are similar in their observable traits.

			Nonetheless, while the balance in observed characteristics is reassuring, it is still crucial to acknowledge that this balance does not rule out the possibility of imbalance in unobserved factors. However, based on the data-driven selection process, the evidence points to a strong level of balance between the groups on the characteristics we can measure, thereby supporting the credibility of the estimated treatment effect. */

*=============================================================================
/* 								Question 4 									*/
/* Use the jtrain2 data set.
Read Athey and Imbens (2017) (focus on those sections where the authors discuss how to perform inference in completely randomized experiments; in particular, section 4). */
*=============================================================================

/* (a) Under which conditions, allowing for heterogeneous treatment effects, is Neyman's inference unbiased? */

	/*
	Neyman, in the context of inference from random experiments, proposed as an estimator the difference in average outcomes by treatment status.
	Allowing heterogeneous treatment effects, for the estimator proposed by Neyman to be unbiased pure randomisation must hold, so it must be a completely randomized experiment. 
	On the other hand, if we are considering the estimation of the standard error, for the estimator to be unbiased under heterogeneous treatment effects, it must be possible to view the sample analyzed as a random sample from an infinite population.
	*/

/* (b) Describe Fisher's inference and replicate section 4.1 of Athey and Imbens (2017) in Stata. Do you arrive at their same p-value? If not, why? Hint: Note that you can draw motivation from third-parties for your own answer; for this case, we suggest that you read Heß (2017).*/ 

	/*
	Fisher's inference is based on testing the sharp null hypothesis, which is the null hypothesis under which we can infer all the missing potential outcomes from the observed ones. A typical choice is the null hypothesis that the treatment has no effect. The alternative hypothesis is that there exists at least one unit such that this does not hold.  
	This type of inference, also called Fishearian Randomization Inference, produces a distribution of a test statistic under a null hypothesis, and it helps the researcher understand if the observed value of the statistic is "extreme", and so it helps understand whether the null hypothesis must be rejected. 
	Fisher's inference makes it possible to infer, for any statistic that is a function of the Y^obs (observed outcomes), W (treatment) and X (covariates), the exact distribution of that statistic under the null hypothesis.
	*/
use "https://raw.githubusercontent.com/stfgrz/20295-microeconometrics-ps/6439a5d44431b6a76c8de6989f44bf7adc461cbb/ps1/ps1_data/jtrain2.dta", clear

*calculating the simple difference in means
*seed set at 20295 to mantain coherence

*default of 100 permutations
ritest train _b[train], seed(20295): ///
	reg re78 train 

*running same test with 1000 permutations
ritest train _b[train], reps(1000) seed(20295): ///
	reg re78 train 

*running the same test with 10000 permutations
ritest train _b[train], reps(10000) seed(20295): ///
    reg re78 train 

	/* We followed the approach of Heß (2016) and we replicated section 4.1 from Athey and Imbens (2017). We conducted the resampling with 100 (default) iterations, 1000 and 10000 iterations. With 100 iterations, the p-value is approximately zero. With 1000 iterations, the p-value varies between 0.0030 and 0.0070. With the last specification, with 10000 resampling replications the p-value is 0.0039, which is slightly smaller than the one found by Athey and Imbens (2017). The difference is to be expected, because of the random nature of the permutation sampling.*/

/* (c) Read again the randomization plan in LaLonde (1986). On which grounds Athey and Imbens (2017)'s illustration of Fisherian inference on LaLonde (1986)'s paper could be criticized? */

	/*
	The main critique that could be moved against Athey and Imbens (2017) illustration of Lalonde (1986)'s paper is how randomization was carried out in the original experiment versus how it was reproduced in the Athey and Imbens paper. In particular, the treatment in the data analyzed by Lalonde was given out by 10 different sites of the project, while in the Athey and Imbens (2017) Fisherian inference illustration, the data is treated as if the treatment was randomly assigned across the sample, without the intervention of the single sites. An important assumption when conducting Fisherian inference is that all treatment assignments are equally likely, so if site-specific factors influence outcomes or the assignment process, this assumption might not hold, and for this reason it could lead to incorrect p-values, and so to incorrect conclusions about statistical significance. 
*/

/* (d) The article Channeling Fisher: Randomization Tests and the Statistical Insignificance of Seemingly Significant Experimental Results (Young, 2019) presents the results of an exercise to test the null hypothesis of no treatment effects in a series of experimental papers recently published in AEA journals, showing that many of the coefficients reported in those papers are no longer significant in a randomization test. A critique of this paper has been published by professors Uri Johnson, Leif Nelson and Joe Simmons in their blog, Data Colada. Read their post here and answer the questions below. */

	/* (i) Briefly explain the difference between the procedure used as the default in Stata for the calculation of standard errors (HC1) and the one proposed by the Data Colada post (HC3). */
	
		/*
		In HC1 Robust Standard Errors, the diagonal elementes of the variance-covariance matrix are substitued with Robust Standard error, based on non-constant variance, which are the squared residuals, weighted by the following coefficient n/(n-k). HC1 robust standard errors are the default in Stata. 
HC3 Robust Standard Errors, on the other hand, are widely used and considered as the best standard errors when heteroskedasticity is present. The diagonal elements of the variance-covariance matrix are replaced by the squared residuals divided by (1-h)^2, h being the hat values that range from 0 to 1. 
		*/
	
	/* (ii) Using the dataset jtrain2, rerun the analysis you have performed in exercise 1, now calculating the standard errors based on HC3 (this is done in Stata using the option vce() in your regression command). */

*First regression
regress re78 train, vce(hc3)

*second regression
regress re78 train age educ black hisp, vce(hc3) 

*third regression
regress re78 train age educ black hisp re74 re75, vce(hc3)

/*The analysis carried out in point d of the 1st exercise cannot be done with any other VCE other than the standard VCE(ols)*/

	/* (iii) Perform a third version of your analysis, now based on bootstrapping (use the bootstrap command in Stata). Briefly describe how the standard errors are calculated in this approach. */

*first regression
bootstrap _b, reps(1000): regress re78 train
*second regression
bootstrap _b, reps(1000): regress re78 train age educ black hisp
*third regression
bootstrap _b, reps(1000): regress re78 train age educ black hisp re74 re75

		/*
		Bootstrapping is a non-parametric statistical method that uses random sampling with replacement to determine the sampling variation of an estimate. In particular, standard errors in a bootstrap procedure are calculated by resampling the data multiple times (the standard on stata is 50 times) , recalculating the statistic of interest for each resample, and finally computing the standard deviation of the replications. The standard deviation of the bootstrap replications is the bootsrap standard error.
		*/
	
	/* (iv) Do any of your conclusions regarding the effect of the training program change based on the analysis performed in this exercise? Based on the discussion provided in the Data Colada post, can you think of a reason for why your results using HC3 should or shouldn't change for this exercise? 

*The regressions performed in this exercise yield the same results as the regressions performed in exercise 1. In particular, the coefficients for all three specifications (non-robust standard errors, HC3 and bootstrapping) are the same, and the only difference between the results of the two analyses are the standard errors. In particular, the standard errors tend to be slightly higher when using HC3 or bootstrapping instead of the normal standard errors of the first regression.

The fact that coefficients remain consistent across specifications, with only slight widening of the confidence intervals, is an indicator of the robustness of the analysis performed. 

Based on the discussion in the Data Colada post, it was to be expected that the results do not change much, since the sample size is much larger than 250 observations, and we know that HC3 performs much better than the default standard error option when the sample size is small. 

Finally, our conclusion regarding the effect of the training program did not change based on the analysis performed in this exercise. 

	