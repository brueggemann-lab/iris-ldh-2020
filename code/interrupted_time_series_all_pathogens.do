
** STATS code for analyses
**In STATA "*" preceding a line indicates that the line is ignored  and similarly any lines between the symbols /* & */

***JOINT ANALYSIS FOR 4 pathogens
****Note missing data 
*** H. influenzae Canada Spain
*** N. meningitidis Canada China Iceland Israel South Korea Switzerland
*** S. agalactiae Belgium Brazil  Canada  China  Czech Republic France Hong Kong Luxembourg New Zealand Northern Ireland Scotland South Africa South Korea Spain Sweden Switzerland Wales
* Analyses exclude countries with missing data for any of S. pneumoniae, H. Influenzae, N. Meningitidis allowing comparibility across these three pathogens
* Countries missing S. agalactiae are included
************generating datasets by species
clear
**code to identify location of files (edit to fit local folder and file naming)
cd H:\Coronavirus\Pneumococcal\data
 
 
**generating local macros for data handling to cycle through eah pathogen in turn
local z = 0
local b p i m a
foreach m of local b {
 local z = `z' + 1
 local b`z'  ="`m'"
 }
 
local z = 0
local c S.pneumoniae H.influenzae N.meningitidis S.agalactiae 
foreach m of local c {
 local z = `z' + 1
 local c`z'  ="`m'"
 }
 
*save output of analysis to a file
log using lagcheck_species, replace


local z = 0
local bact pneumoniae influenzae meningitidis agalactiae 
foreach m of local bact {
**data used as per insheet command below is a comma separated file with one record per patient sample and variables for year, week of year (ISO week), country and pathogen
insheet using iris3.csv, clear
* dropping variables not used in these analyses
drop  id aliases isolate date_sampled date_received non_cult year_sam year
* drestricting to countries not missing any of the three main pathogens
drop if country == "Canada"  | country == "China"  | country == "Iceland"  | country == "Israel"  | country == "South Korea"  | country == "Spain"  | country == "Switzerland" 

local z = `z' + 1
local bact`z'  ="`m'"
gen xspecies = species
replace species = "pneumoniae" if species =="S. pneumoniae"
replace species = "influenzae" if species =="H. influenzae"
replace species = "meningitidis" if species =="N. meningitidis"
replace species = "agalactiae" if species =="S. agalactiae"
keep if species =="`bact`z''"

**A continuous week number variable is generated across the three years of the study data
capture drop nweek
gen nweek = week
replace nweek = nweek+52 if isoyear == 2019
replace nweek = nweek+104 if isoyear == 2020
*keep country nweek week

*Moving from individual level data to weekly counts 
gen x=1
collapse (sum) total=x, by (country week nweek)
**** this produces a data set missing those country*week combinations with zero values - resolved by merging with a dataframe having all nweek records
sort country nweek
save temp, replace
bysort country (nweek): gen byte last = _n==_N
drop if last == 0
keep country
local i = 1
while `i' < 127{
gen nweek`i' = `i'
local i = `i'+1
}
reshape long nweek, i(country)
drop _j
sort country nweek 
**to add data back into this dataframe:
merge 1:1 country nweek using temp, update
tab _me 
*the above checking command showed all are in master and most in matched - none in using only
drop _merge
***add zero counts and week if missing - may need to amend if missing data.
replace total = 0 if total ==. 
gen `b`z''count = total
drop total
replace week_sampled = nweek if week_sampled ==.
replace week_sampled = week_sampled-52 if  week_sampled >52
replace week_sampled = week_sampled-52 if  week_sampled >52


*Countries collapsed across pathogen so seasonal terms not possible to do differently for Southern Hemisphere in collapsed ddataset
sort country nweek 
collapse (sum) `b`z''count, by(nweek  week)
gen s1 = sin(2*_pi*week/52)
gen c1 = cos(2*_pi*week/52)
gen s2 = sin(4*_pi*week/52)
gen c2 = cos(4*_pi*week/52)
capture drop pred*
/*
seasonality check - results: none for agalactiae, strong first pairs of terms for others and some support for second terms for H inf.
menbreg `b`z''count  nweek , irr
estimates store A`b`z''
menbreg `b`z''count  nweek s1 c1 , irr
predict pred1`b`z''
estimates store B`b`z''
menbreg `b`z''count nweek s1 c1 s2 c2 , irr
predict pred2`b`z''
estimates store C`b`z''
lrtest A`b`z'' B`b`z''
lrtest B`b`z'' C`b`z'' 
drop _est*
*/

*clearing any terms generated when repeating analyses - not essential in a single run
capture drop gdummy 
capture drop gslope
capture drop _est*
capture drop pred*
*generating variables to allow timing of the step change in time series analysis
gen gdummy = 0
gen gslope = 0


**Runing analyses across a range of dummy variable to indicate when the step and slope changes occurred (i.e. which week best fits for the step and slope change). The week with the best average fit is presented in the paper.
local i = 97
while `i' < 108{
* a date for when movement drop was half implemented - to guide differential dummy and slope
***a lag of -2 fitted best - and was used.
replace gdummy  = 0
replace gdummy  = 1  if nweek >= `i' +12
replace gslope = 0
replace gslope = (nweek- (`i'+12 ))*gdummy 
menbreg `b`z''count  nweek gslope gdummy  s1 c1 s2 c2 , irr
**saving results from full model for graphing
predict pred1`b`z''_`i' 
**saving results from the "counterfactual" model - one without any step and slope change allowed but including the voerall trend and seasonality
gen cfact`b`z''_`i'  =  pred1`b`z''_`i'/(exp(_b[gdummy])*(exp(_b[gslope]*gslope))) if gdummy==1
*
*labelling and graphing results for each run
label variable cfact`b`z''_`i' "Counterfactual `c`z'' "
label variable pred1`b`z''_`i' "Model"
label variable `b`z''count "Count/week" 
twoway (scatter `b`z''count nweek)  (line pred1`b`z''_`i' nweek, lcolor(red)) (line cfact`b`z''_`i' nweek, lcolor(red) lpattern(dash)) ,  scheme(s1mono) xscale(range(0 130)) xlabel(0(13)130, grid gstyle(minor)) xtitle("Study week")
graph save g_`b`z''_`i'.gph, replace

*testing each model using a likelihood ratio test
estimates store X`i'
lrtest   X`i'   Y
local f`i' = r(chi2)
local i = `i' +1 
}
*outputing results of LR test alongside the week number allowing identification of the interruption week in that time series.
local i = 97
while `i' < 108{
dis "For a lag of " `i'- 104 " LRTEST Chi = " `f`i''
local i = `i' +1 
}
local i = 97
while `i' < 108{
dis  `i'  ", "`f`i''
local i = `i' +1 
}
save  red`bact`z'', replace
}

log close

**graphs with different weeks when interruption assumed to occur for comparison as part of working - to assess sensitivity to specification of the interruption week.
graph combine g_p_102.gph   g_p_103.gph g_p_104.gph g_p_105.gph  g_i_102.gph    g_i_103.gph  g_i_104.gph  g_i_105.gph   g_m_102.gph    g_m_103.gph  g_m_104.gph  g_m_105.gph  
graph save combined_102_05.gph, replace
graph combine g_p_104.gph  g_i_104.gph   g_m_104.gph   g_a_104.gph  
graph save compare.gph, replace