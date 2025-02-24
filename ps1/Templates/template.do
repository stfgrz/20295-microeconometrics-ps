/* Template of do-file in Stata to answer problem set */
/* Group number: */
/* Group composition: A, B and C */

/* Gets user name */
local user = c(username)
display "`user'"

/* Stores filepath conditionally */
if ("`user'" == "erick") {
    global filepath "/home/erick/TEMP/"
}

if ("`user'" == "A") {
    global filepath "/FILE/PATH/A/"
}

if ("`user'" == "B") {
    global filepath "/FILE/PATH/B/"
}

if ("`user'" == "C") {
    global filepath "/FILE/PATH/C/"
}

/* Question X */
/* Comments... */
