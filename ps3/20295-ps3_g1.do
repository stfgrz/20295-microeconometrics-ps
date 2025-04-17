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
    global filepath "/Users/stefanograziosi/Documents/GitHub/20295-microeconometrics-ps/ps3"
	global output "/Users/stefanograziosi/Documents/GitHub/20295-microeconometrics-ps/ps3/ps3_output"
}

if ("`user'" == "gabrielemole") {
    global filepath "/Users/stealth/Documenti/GitHub/20295-microeconometrics-ps/ps1"
	global output "/Users/stealth/Documenti/GitHub/20295-microeconometrics-ps/ps1/ps1_output"
}
