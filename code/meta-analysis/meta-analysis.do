********************************************************************************
/* 
IRIS DATA ANALYSIS 
SEPTEMBER 2020
STATA SE VERSION 16.1, UPDATED 15/03/2021
INTERUPTED TIME-SERIES ANALYSIS
********************************************************************************
STATISTICAL ANALYSIS PLAN:
1. FIT MODELS TO INDIVIDUAL COUNTRIES
2. POOL RESULTS OF LOCKDOWN INTERVENTION AND SLOPE
3. PERFORM META-ANALYSIS OF RESULTS
********************************************************************************
GENERAL APPROACH:
1. FIT GENERALISED LINEAR MODEL - POISSON FAMILY WITH SCALE TO CORRECT FOR OVERDISPERSION
2. USE FOURIER CORRECTIONS TO ACCOUNT FOR SEASONALITY
3. CENTRE THE DATA
********************************************************************************
*/

import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"

********************************************************************************
* 1. BELGIUM:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Belgium"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=116


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-116)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Belgium, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", replace
putexcel B1 = matrix(matB), names
putexcel A2 = ("Belgium")
putexcel A3 = ("Belgium")

********************************************************************************
* 2. BRAZIL:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Brazil"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=116


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-116)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Brazil.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B4 = matrix(matB), names
putexcel A5 = ("Brazil")
putexcel A6 = ("Brazil")

********************************************************************************
* 3. CANADA:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Canada"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=116


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-116)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Canada.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B7 = matrix(matB), names
putexcel A8 = ("Canada")
putexcel A9 = ("Canada")

********************************************************************************
* 4. CHINA:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "China"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=109


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(109, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-109)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(109, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save China.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B10 = matrix(matB), names
putexcel A11 = ("China")
putexcel A12 = ("China")

********************************************************************************
* 5. CZECH REPUBLIC:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Czech Republic"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=115


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-115)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Czech.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B13 = matrix(matB), names
putexcel A14 = ("Czech Republic")
putexcel A15 = ("Czech Republic")

********************************************************************************
* 6. DENMARK:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Denmark"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=115


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-115)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Denmark.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B16 = matrix(matB), names
putexcel A17 = ("Denmark")
putexcel A18 = ("Denmark")

********************************************************************************
* 7. ENGLAND:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "England"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=116


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-116)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save England.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B19 = matrix(matB), names
putexcel A20 = ("England")
putexcel A21 = ("England")

********************************************************************************
* 8. FINLAND:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Finland"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=116


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-116)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Finland.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B22 = matrix(matB), names
putexcel A23 = ("Finland")
putexcel A24 = ("Finland")

********************************************************************************
* 9. FRANCE:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "France"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=115


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-115)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save France.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B25 = matrix(matB), names
putexcel A26 = ("France")
putexcel A27 = ("France")

********************************************************************************
* 10. GERMANY:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Germany"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=116


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-116)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Germany.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B28 = matrix(matB), names
putexcel A29 = ("Germany")
putexcel A30 = ("Germany")

********************************************************************************
* 11. HONG KONG:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Hong Kong"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=111


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(111, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-111)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(111, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Hong_Kong.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B31 = matrix(matB), names
putexcel A32 = ("Hong Kong")
putexcel A33 = ("Hong Kong")


********************************************************************************
* 12. ICELAND:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Iceland"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=115


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-115)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Iceland.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B34 = matrix(matB), names
putexcel A35 = ("Iceland")
putexcel A36 = ("Iceland")

********************************************************************************
* 13. IRELAND:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Ireland"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=116


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-116)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Ireland.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B37 = matrix(matB), names
putexcel A38 = ("Ireland")
putexcel A39 = ("Ireland")

********************************************************************************
* 14. ISRAEL:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Israel"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=115


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-115)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Israel.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B40 = matrix(matB), names
putexcel A41 = ("Israel")
putexcel A42 = ("Israel")

********************************************************************************
* 15. LUXEMBOURG:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Luxembourg"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=115


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-115)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Luxembourg.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B43 = matrix(matB), names
putexcel A44 = ("Luxembourg")
putexcel A45 = ("Luxembourg")

********************************************************************************
* 16. NETHERLANDS:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Netherlands"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=115


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-115)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Netherlands.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B46 = matrix(matB), names
putexcel A47 = ("Netherlands")
putexcel A48 = ("Netherlands")

********************************************************************************
* 17. NORTHERN IRELAND:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Northern Ireland"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=116


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-116)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save NI.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B49 = matrix(matB), names
putexcel A50 = ("Nothern Ireland")
putexcel A51 = ("Northern Ireland")

********************************************************************************
* 18. POLAND:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Poland"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=115


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-115)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Poland.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B52 = matrix(matB), names
putexcel A53 = ("Poland")
putexcel A54 = ("Poland")

********************************************************************************
* 19. SCOTLAND:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Scotland"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=116


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-116)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Scotland.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B55 = matrix(matB), names
putexcel A56 = ("Scotland")
putexcel A57 = ("Scotland")

********************************************************************************
* 20. SOUTH AFRICA:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "South Africa"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=116


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-116)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save South_Africa.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B58 = matrix(matB), names
putexcel A59 = ("South Africa")
putexcel A60 = ("South Africa")

********************************************************************************
* 21. SOUTH KOREA:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "South Korea"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=112


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(112, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-112)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(112, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save South_Korea.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B61 = matrix(matB), names
putexcel A62 = ("South Korea")
putexcel A63 = ("South Korea")

********************************************************************************
* 22. SPAIN:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Spain"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=115


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-115)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Spain.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B64 = matrix(matB), names
putexcel A65 = ("Spain")
putexcel A66 = ("Spain")

********************************************************************************
* 23. SWEDEN:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Sweden"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=115


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-115)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Sweden.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B67 = matrix(matB), names
putexcel A68 = ("Sweden")
putexcel A69 = ("Sweden")

********************************************************************************
* 24. SWITZERLAND:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Switzerland"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=115


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-115)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(115, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Switzerland.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B70 = matrix(matB), names
putexcel A71 = ("Switzerland")
putexcel A72 = ("Switzerland")

********************************************************************************
* 25. WALES:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "Wales"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=116


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-116)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(116, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save Wales.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B73 = matrix(matB), names
putexcel A74 = ("Wales")
putexcel A75 = ("Wales")

********************************************************************************
* 25. NEW ZEALAND:
import delimited "iris.csv", clear
drop isolate aliases year date_sampled date_received non_culture year_sampled
keep if species == "S. pneumoniae"
keep if country == "New Zealand"
sort isoyear_sampled week_sampled
collapse (count) id, by(isoyear_sampled week_sampled)
gen cases = id
merge 1:1 isoyear_sampled week_sampled using test2, update replace
sort isoyear_sampled week_sampled
replace cases = 0 if cases==.
drop id

*Visualise
scatter cases time
hist cases, freq normal
summ cases, detail
*Check Case Number
tabstat cases, stat(sum)

*Implement ITS
gen degrees = (time/52)*360
fourier degrees, n(2)
gen lockdown = 0
replace lockdown = 1 if time>=117


glm cases lockdown sin* cos* time, family(poisson) scale(x2) eform
predict pred
predict res, r
twoway (scatter res time)(lowess res time)
gen counterfactual = pred/exp(_b[lockdown]) if lockdown==1

twoway (scatter cases time) (line pred time, lcolor(red)) (line counterfactual time, lcolor(red) lpattern(dash)), xline(117, lcolor(black) lpattern(dash)) scheme(s1mono)

*Fix slope
gen inter_lockdowntime = lockdown*(time-117)

drop cos* sin* degrees
gen degrees=(time/52)*360
fourier degrees, n(2)

glm cases lockdown inter_lockdowntime sin* cos* time, family(poisson) scale(x2) eform
matrix matA = r(table)'
matrix matB = matA[1..2,1],matA[1..2,2..6]
predict pred4
lincom lockdown + inter_lockdowntime*4, irr
lincom lockdown + inter_lockdowntime*8, irr
twoway (scatter cases time) (line pred4 time, lcolor(red)), xline(117, lcolor(black) lpattern(dash)) scheme(s1mono)
graph save New_Zealand.gph, replace
*Put into matrix and insert into EXCEL
putexcel set "meta.xlsx", modify
putexcel B76 = matrix(matB), names
putexcel A77 = ("New Zealand")
putexcel A78 = ("New Zealand")

graph combine Belgium.gph Brazil.gph Canada.gph Czech.gph Denmark.gph England.gph Finland.gph France.gph Germany.gph Iceland.gph Ireland.gph Israel.gph Luxembourg.gph Netherlands.gph NI.gph Poland.gph Scotland.gph South_Africa.gph South_Korea.gph Spain.gph Sweden.gph Switzerland.gph Wales.gph New_Zealand.gph Hong_Kong.gph China.gph

graph save All_countries.gph

*NOTE: copy results from lincom command (4 and 8 weeks) into an Excel document
*Generate step_slope_1.csv for effect at 4 weeks
*Generate step_slope_1.csv for effect at 8 weeks
*These files will be used in the R script
********************************************************************************
********************************************************************************
**CONVERT TO .CSV FORMAT AND DROP SUPERFLUOUS ROWS
*Edit meta.xlsx and drop all repeated rows
*Convert to .csv 
*This section can be performed in R (code supplied)
import delimited "meta.csv", clear

gen logb = log(b)
gen logll = log(ll)
gen logul = log(ul)
drop v2
keep if v3 == "lockdown"

meta set logb logll logul, studylabel(ï) eslabel(IRR)
meta forestplot, transform(`"IRR"': exp) esrefline nullrefline
