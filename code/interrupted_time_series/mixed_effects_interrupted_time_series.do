** STATS code for analyses
**In STATA "*" preceding a line indicates that the line is ignored  and similarly any lines between the symbols /* & */
clear
**code to identify location of files (edit to fit local folder and file naming)
cd H:\Coronavirus\Pneumococcal\data
*data used as per insheet command below is a comma separated file with one record per patient sample and variables for year, week of year (ISO week), country and pathogen
insheet using iris3.csv
*drop unused variables and ibservations
drop  id aliases isolate date_sampled date_received non_cult year_sam year
keep if species =="S. pneumoniae"

***A continuous week number variable is generated across the three years of the study data
capture drop nweek
gen nweek = week
replace nweek = nweek+52 if isoyear == 2019
replace nweek = nweek+104 if isoyear == 2020
keep country nweek week


**Moving from individual level data to weekly counts 
gen x=1
collapse (sum) total=x, by (country week nweek)

**** missing those country_week combinations with zero values
sort country nweek
save temp, replace

***** this produces a data set missing those country*week combinations with zero values - resolved by making and merging with a dataframe having all nweek records
bysort country (nweek): gen byte last = _n==_N
drop if last == 0
keep country
gen co_code = _n
local i = 1
while `i' < 127{
gen nweek`i' = `i'
local i = `i'+1
}
reshape long nweek, i(country)
drop _j
sort country nweek

**Merging in the study data with this data frame that has each week for each country 
merge 1:1 country nweek using temp, update
drop _merge
***add zero counts and week if missing - may need to amend if missing data.
replace total = 0 if total ==. 
gen count = total
drop total 
replace week_sampled = nweek if week_sampled ==.
replace week_sampled = week_sampled-52 if  week_sampled >52
replace week_sampled = week_sampled-52 if  week_sampled >52

*making a total for each country
egen co_total= total(count), by(country)

*seasonal terms reversing for Southern Hemisphere
replace week = week + 26 if country == "South Africa" |country == "Brazil" | country == "New Zealand"
replace week = week-52 if week > 52

gen s1 = sin(2*_pi*week/52)
gen c1 = cos(2*_pi*week/52)
gen s2 = sin(4*_pi*week/52)
gen c2 = cos(4*_pi*week/52)

**note STATA fourier commands gives same as above (exactly) - line 1. gen degrees = (week/52)*360 line 2. fourier degrees, n(2)

/* 
To decide on how to model seasonality - in terms of how many sets of Fourier terms - earlier versons with poisson model not shown given overdispersion and use of negative binomial final model

nbreg count co_total nweek , irr
estimates store A
nbreg count co_total nweek s1 c1, irr
estimates store B
nbreg count co_total nweek s1 c1 s2 c2, irr
estimates store C
lrtest A B
lrtest B C 
**ON POISSON -  much better fits and highly significant s1 c1(Chi sq on 2 dof 7689.92 p < 0.000 with large coefficients 1.27 & 1.6) and further although much less dramatic improvement with s2 c2 (Chi sq on 2 dof 50.97 with coefficients 0.96 & 1.01)
**ON NBREG - similar coefficient size but LR2 CHI for second order is only 4.1 (p 0.13)

*/

*Identifying evidence for an optimal week on which to set teh time series interruption variable for each country 
log using school, replace
*The model used to evaluate this is a mixed effects negative binomial as below initially allowing random effects for country seasonality and linear trend:
*menbreg count nweek  s1 c1 , exposure(co_total) irr ||  co_code: s1 c1 nweek
**note nweek random effect not significant and caused problems with model running when more complex and so dropped. In full model random effects terms for the time series interruption variables were also included.
*Basic model against which models with an interrupted time series will be compared is:
menbreg count nweek  s1 c1 , exposure(co_total) irr ||  co_code: s1 c1 
estimates store Y
**the expected week for interruption was arbitrarily set as the one when movement (on Google mobility or surrogate measure mostly week 11 or 12, earlier in South East Asian countries) had dropped to half the original level
**evidence for different lags was then evaluated by identifying whether data fitted better with each of these lags.
*gdummy is the variable for interruption week codig for a step change that week and gslope for a linear slope term - modelling a gradual reduction following that week, a log term of slope lgslope was also modelled
capture drop gdummy gslope
gen gdummy = 0
gen gslope = 0
**Iteratively testing various values to identify optimum lag
local i = 100
while `i' < 107{
replace gdummy  = 0
replace gdummy  = 1  if country =="Belgium" & nweek >= `i' +12
replace gdummy  = 1 if country =="Brazil" & nweek >= `i' +12
replace gdummy  = 1  if country =="Canada" & nweek >= `i' +12
replace gdummy  = 1  if country =="Czech Republic" & nweek >= `i' +11
replace gdummy  = 1  if country =="Denmark" & nweek >= `i' +11
replace gdummy  = 1  if country =="Finland" & nweek >= `i' +12
replace gdummy  = 1  if country =="France" & nweek >= `i' +11
replace gdummy  = 1  if country =="Germany" & nweek >= `i' +12
replace gdummy  = 1  if country =="Hong Kong" & nweek >= `i' +7
replace gdummy  = 1  if country =="Ireland" & nweek >= `i' +12
replace gdummy  = 1  if country =="Israel" & nweek >= `i' +11
replace gdummy  = 1  if country =="Luxembourg" & nweek >= `i' +11
replace gdummy  = 1  if country =="Netherlands" & nweek >= `i' +11
replace gdummy  = 1  if country =="New Zealand" & nweek >= `i' +13
replace gdummy  = 1  if country =="Poland" & nweek >= `i' +11
replace gdummy  = 1  if country =="South Africa" & nweek >= `i' +12
replace gdummy  = 1  if country =="South Korea" & nweek >= `i' +8
replace gdummy  = 1  if country =="Spain" & nweek >= `i' +11
replace gdummy  = 1  if country =="Sweden" & nweek >= `i' +11
replace gdummy  = 1  if country =="Switzerland" & nweek >= `i' +11
replace gdummy  = 1  if country =="England" & nweek >= `i' +12
replace gdummy  = 1  if country =="Scotland" & nweek >= `i' +12
replace gdummy  = 1  if country =="Wales" & nweek >= `i' +12
replace gdummy  = 1  if country =="Northern Ireland" & nweek >= `i' +12
**no data for Iceland - replace with median values for Europe as a surrogate. No data for China - replaced with timings of lockdown measures across prefectures (from Wikipedia)
replace gdummy  = 1  if country =="Iceland" & nweek >= `i' +11
replace gdummy  = 1 if country =="China" & nweek >= `i' +5

replace gslope = 0
replace gslope = (nweek- (`i'+12 ))*gdummy  if country =="Belgium" 
replace gslope = (nweek- (`i'+12 ))*gdummy  if country =="Brazil" 
replace gslope = (nweek- (`i'+12 ))*gdummy  if country =="Canada" 
replace gslope = (nweek- (`i'+11 ))*gdummy  if country =="Czech Republic" 
replace gslope = (nweek- (`i'+11 ))*gdummy  if country =="Denmark" 
replace gslope = (nweek- (`i'+12 ))*gdummy  if country =="Finland"
replace gslope = (nweek- (`i'+11 ))*gdummy  if country =="France" 
replace gslope = (nweek- (`i'+12 ))*gdummy  if country =="Germany" 
replace gslope = (nweek- (`i'+7 ))*gdummy  if country =="Hong Kong" 
replace gslope = (nweek- (`i'+12 ))*gdummy  if country =="Ireland"
replace gslope = (nweek- (`i'+11 ))*gdummy  if country =="Israel" 
replace gslope = (nweek- (`i'+11 ))*gdummy  if country =="Luxembourg" 
replace gslope = (nweek- (`i'+11 ))*gdummy  if country =="Netherlands" 
replace gslope = (nweek- (`i'+13 ))*gdummy  if country =="New Zealand" 
replace gslope = (nweek- (`i'+11 ))*gdummy  if country =="Poland" 
replace gslope = (nweek- (`i'+12 ))*gdummy  if country =="South Africa" 
replace gslope = (nweek- (`i'+8 ))*gdummy  if country =="South Korea" 
replace gslope = (nweek- (`i'+11 ))*gdummy  if country =="Spain" 
replace gslope = (nweek- (`i'+11 ))*gdummy  if country =="Sweden" 
replace gslope = (nweek- (`i'+11 ))*gdummy  if country =="Switzerland" 
replace gslope = (nweek- (`i'+12 ))*gdummy  if country =="England" 
replace gslope = (nweek- (`i'+12 ))*gdummy  if country =="Scotland" 
replace gslope = (nweek- (`i'+12 ))*gdummy  if country =="Wales" 
replace gslope = (nweek- (`i'+12 ))*gdummy  if country =="Northern Ireland" 

replace gslope = (nweek- (`i'+11 ))*gdummy  if country =="Iceland" 
replace gslope = (nweek- (`i'+5 ))*gdummy  if country =="China" 
capture drop lgslope
gen lgslope = log(gslope+1)

**running models and evaluating statistical fit vs simple model without any time series interruption
menbreg count  nweek gslope gdummy  s1 c1  , exposure(co_total) irr||  co_code:  gslope gdummy s1 c1 
estimates store X`i'
menbreg count  nweek lgslope gdummy  s1 c1  , exposure(co_total) irr ||  co_code:  lgslope gdummy s1 c1 
estimates store lX`i'
lrtest   X`i'   Y
local f`i' = r(chi2)
lrtest   lX`i'   Y
local lf`i' = r(chi2)
local i = `i' +1 
}

**Code to summarise results of statistical fit
local i = 100
while `i' < 107{
dis "For a lag of " `i'- 104 " LRTEST Chi = " `f`i''
dis "on a log scale is it " `lf`i''
local i = `i' +1 
}
log close

**reset to a lag of two weeks based on this testing - for final results and  before adding in school variables (as below)
**do this by rerunning the above just once for this lag

***Analyses considering whether adding the timing of enforced school closures explains any differences in the weekly counts more fully than the analyses above
* date of enforced school closures - note pulling possible dates for effect lag (negative) right back into 2019 to check fit.

capture drop sdummy sslope
gen sdummy = 0
gen sslope = 0
/*Timing from Blavatnik School og Government study:
Belgium 115, Brazil 115, Canada 116,  China 108, Czech Republic 115, Denmark 115, England 117, Finland 116, France 114,Germany 113,Hong Kong 108,Iceland 116, Ireland 115,Israel 115,Luxembourg 11, Netherlands 116,New Zealand 117,Northern Ireland 116, Poland 115, Scotland 116, South Africa 116, South Korea 110, Spain 115, Sweden 127, Switzerland 115,,Wales 116, */

replace sdummy= 1 if country == "Belgium"  & nweek  >= 115
replace sdummy= 1 if country == "Brazil"  & nweek  >= 115
replace sdummy= 1 if country == "Canada"  & nweek  >= 116
replace sdummy= 1 if country == "China"  & nweek  >= 108
replace sdummy= 1 if country == "Czech Republic"  & nweek  >= 115
replace sdummy= 1 if country == "Denmark"  & nweek  >= 115
replace sdummy= 1 if country == "England"  & nweek  >= 117
replace sdummy= 1 if country == "Finland"  & nweek  >= 116
replace sdummy= 1 if country == "France"  & nweek  >= 114
replace sdummy= 1 if country == "Germany"  & nweek  >= 113
replace sdummy= 1 if country == "Hong Kong"  & nweek  >= 108
replace sdummy= 1 if country == "Iceland"  & nweek  >= 116
replace sdummy= 1 if country == "Ireland"  & nweek  >= 115
replace sdummy= 1 if country == "Israel"  & nweek  >= 115
replace sdummy= 1 if country == "Luxembourg"  & nweek  >= 116
replace sdummy= 1 if country == "Netherlands"  & nweek  >= 116
replace sdummy= 1 if country == "New Zealand"  & nweek  >= 117
replace sdummy= 1 if country == "Northern Ireland"  & nweek  >= 116
replace sdummy= 1 if country == "Poland"  & nweek  >= 115
replace sdummy= 1 if country == "Scotland"  & nweek  >= 116
replace sdummy= 1 if country == "South Africa"  & nweek  >= 116
replace sdummy= 1 if country == "South Korea"  & nweek  >= 110
replace sdummy= 1 if country == "Spain"  & nweek  >= 115
replace sdummy= 1 if country == "Sweden"  & nweek  >= 127
replace sdummy= 1 if country == "Switzerland"  & nweek  >= 115
replace sdummy= 1 if country == "Wales"  & nweek  >= 116

replace sslope =(sdummy*(nweek-115)) if country =="Belgium" 
replace sslope =(sdummy*(nweek-115)) if country =="Brazil" 
replace sslope =(sdummy*(nweek-116)) if country =="Canada" 
replace sslope =(sdummy*(nweek-108)) if country =="China" 
replace sslope =(sdummy*(nweek-115)) if country =="Czech" 
replace sslope =(sdummy*(nweek-115)) if country =="Denmark" 
replace sslope =(sdummy*(nweek-117)) if country =="England" 
replace sslope =(sdummy*(nweek-116)) if country =="Finland" 
replace sslope =(sdummy*(nweek-114)) if country =="France" 
replace sslope =(sdummy*(nweek-113)) if country =="Germany" 
replace sslope =(sdummy*(nweek-108)) if country =="Hong" 
replace sslope =(sdummy*(nweek-116)) if country =="Iceland" 
replace sslope =(sdummy*(nweek-115)) if country =="Ireland" 
replace sslope =(sdummy*(nweek-115)) if country =="Israel" 
replace sslope =(sdummy*(nweek-116)) if country =="Luxembourg" 
replace sslope =(sdummy*(nweek-116)) if country =="Netherlands" 
replace sslope =(sdummy*(nweek-117)) if country =="New Zealand" 
replace sslope =(sdummy*(nweek-116)) if country =="Northern" 
replace sslope =(sdummy*(nweek-115)) if country =="Poland" 
replace sslope =(sdummy*(nweek-116)) if country =="Scotland" 
replace sslope =(sdummy*(nweek-116)) if country =="South" 
replace sslope =(sdummy*(nweek-110)) if country =="South" 
replace sslope =(sdummy*(nweek-115)) if country =="Spain" 
replace sslope =(sdummy*(nweek-127)) if country =="Sweden" 
replace sslope =(sdummy*(nweek-115)) if country =="Switzerland" 
replace sslope =(sdummy*(nweek-116)) if country =="Wales" 

*models with and without these added school closure effects compared to the base model with an interruption mased on estimates of altered societal mobility patterns
menbreg count  nweek gslope gdummy  s1 c1  , exposure(co_total) irr ||  co_code:  gslope gdummy s1 c1 
estimates store sn
menbreg count  nweek gslope gdummy sdummy sslope  s1 c1  , exposure(co_total) irr||  co_code:  gslope gdummy  s1 c1 
estimates store sy
lrtest sn sy
*repeated with the logged slope
menbreg count  nweek lgslope gdummy  s1 c1  , exposure(co_total) irr ||  co_code:  lgslope gdummy s1 c1 
estimates store lsn
menbreg count  nweek lgslope gdummy sdummy sslope  s1 c1  , exposure(co_total) irr||  co_code:  lgslope gdummy  s1 c1 
estimates store lsy
lrtest sn sy
