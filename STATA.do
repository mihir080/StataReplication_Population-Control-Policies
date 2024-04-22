clear all

set more off
capture log close 

local current_dir "`c(cd)'"
use Dataset.dta, replace 
log using Replication_Fertility.log, replace

********************************************************************************

// We will check the variables and get a descriptive stats of the dataset

describe

summarize 

codebook, compact

********************************************************************************
*									Figures									   *
********************************************************************************

// Replicating the figures of the paper

shell mkdir "`current_dir'/figures" // Creating a new folder to store the images

// FIGURE 1

quietly {
histogram TFR if year == 1960, bin(15) xscale(range(0 10)) legend(off) ///
xtitle("1960") ytitle("") name(trf60)
histogram TFR if year == 1970, bin(15) xscale(range(0 10)) legend(off) ///
xtitle("1970") ytitle("") name(trf70)
histogram TFR if year == 1980, bin(15) xscale(range(0 10)) legend(off) ///
 xtitle("1980") ytitle("") name(trf80)
histogram TFR if year == 1990, bin(15) xscale(range(0 10)) legend(off) ///
 xtitle("1990") ytitle("") name(trf90)
histogram TFR if year == 2000, bin(15) xscale(range(0 10)) legend(off) ///
 xtitle("2000") ytitle("") name(trf00)
histogram TFR if year == 2013, bin(15) xscale(range(0 10)) legend(off) ///
 xtitle("2013") ytitle("") name(trf13)
}

// Combining the individual histograms to create a panel chart for better comparison

graph combine trf60 trf70 trf80 trf90 trf00 trf13, ycommon xcommon ///
title("Panel Chart Of TRF's Across Periods") ///
note("Data: Population Control Policies and Fertility Convergence") ///
name(fig1)

** graph export "`current_dir'/figures/fig1.png", replace


// FIGURE 2

tempfile fig3 // Saving the collapsed dataset for easy reference
collapse (mean) TFR [fw=population], by(wbregion year)
save `fig3', replace

codebook wbregion /// To get the index codes for each of the regions

twoway (line TFR year if wbregion == 1) (line TFR year if wbregion == 2, lpattern(dash)) (line TFR year if wbregion == 3, lpattern(longdash)) (line TFR year if wbregion == 4, lpattern(longdash_dot)) (line TFR year if wbregion == 5, lpattern(shortdash)) (line TFR year if wbregion == 6, lpattern(shortdash_dot)) (line TFR year if wbregion == 7, lpattern(dash_dot)), ytitle("Total Fertility Rate") xtitle("Years") legend(order(1 "North America" 2 "Europe and Central Asia" 3 "East Asia and Pacific" 4 "Latin America" 5 "Middle East and North Africa" 6 "South Asia" 7 "Sub Saharan Africa") size(small) span position(6) rows(2)) title("Total Fertility Rate Across Periods By Region") note("Data: de Silva, Tenreyro 2017") name(fig2)

** graph export "`current_dir'/figures/fig2.png", replace

use Dataset.dta, replace 

// FIGURE 3

twoway (scatter TFR ln_gdp if year == 1960, msymbol(circle) mfcolor(white)) (lowess TFR ln_gdp if year == 1960 & wbregion!=.) (scatter TFR ln_gdp if year == 2013, msymbol(triangle) mfcolor(blue)) (lowess TFR ln_gdp if year == 2013 & wbregion!=.), legend(order(1 "1960" 3 "2013" 2 "Fitted 1960" 4 "Fitted 2013") rows(1) size(small) position(6)) title("Fertility GDP Relation in 1960 & 2013") ytitle("TFR") xtitle("GDP per capita ($)") note("Data: de Silva, Tenreyro 2017") name(fig3)

** graph export "`current_dir'/figures/fig3.png", replace

// FIGURE 4

twoway (scatter TFR urban_pop_tot if year == 1960, msymbol(circle) mfcolor(white)) (lowess TFR urban_pop_tot if year == 1960 & wbregion!=.) (scatter TFR urban_pop_tot if year == 2013, msymbol(triangle) mfcolor(blue)) (lowess TFR urban_pop_tot if year == 2013 & wbregion!=.), legend(order(1 "1960" 3 "2013" 2 "Fitted 1960" 4 "Fitted 2013") rows(1) size(small) position(6)) title("Fertility Population Relation in 1960 & 2013") ytitle("TFR") xtitle("Urban Population (as a % of total population)") note("Data: de Silva, Tenreyro 2017") name(fig4)

** graph export "`current_dir'/figures/fig4.png", replace

// FIGURE 5

tempfile fig5 // Saving the collapsed dataset for easy reference

encode fertpolicy, gen(fpcode) //Encoding the fertility policy

gen fpcode76 = fpcode if year == 1976 //Generating a variable with encoded fertility policy for each country for the year 1976

egen fpcode76all=mean(fpcode76) if wbregion!=., by(country) //fitting 1976 values of fertility policy across countries

collapse (mean) TFR [fw=population], by(year fpcode76all) //Collapsing data to keep actual TFR and TFR at the time of fertility policies in 1976

twoway (line TFR year if fpcode76all == 1) (line TFR year if fpcode76all == 2) (line TFR year if fpcode76all == 3) (line TFR year if fpcode76all == 4) if year > 1959 & year < 2011, xlabel(1960(10)2011) legend(order(1 "Lower" 2 "No Intervention" 3 "Maintain" 4 "Raise") size(small) span position(6) rows(2)) xscale(range(1960 2011)) ytitle("Mean TFR") xtitle("Years") title("Fertility Rates by Policy in 1976") note("Data: de Silva, Tenreyro 2017") name(fig5)

** graph export "`current_dir'/figures/fig5.png", replace

save `fig5', replace

********************************************************************************
*									Tables									   *
********************************************************************************

clear all

use Dataset.dta, replace 

shell mkdir "`current_dir'/tables" 

********************************************************************************

// TABLE 1

tabulate year fertpolicy if year == 1976 | year == 1986 | year == 1996 | year == 2005 | year == 2013

// TABLE 2

tab year gov_famplan if year == 1976 | year == 1986 | year == 1996 | year == 2005 | year == 2013

// TABLE 3

// Preparing the data for mutation

save Dataset.dta, replace
tempfile source // A file that contains only the names and codes of the countries. 
collapse (first) CountryCode if wbregion!=., by(country)
save `source', replace

//


use Dataset.dta, replace
tempfile TFR1960 // A file that contains the names and codes of countries and TFR in 1960.
keep if year == 1960
keep country CountryCode TFR
rename TFR TFR1960
save `TFR1960', replace

//

use Dataset.dta, replace
tempfile TFR2013 // A file that contains the names and codes of countries and TFR in 2013.
keep if year == 2013
keep country CountryCode TFR
rename TFR TFR2013
save `TFR2013', replace

//

use Dataset.dta, replace
tempfile funds // A file containing names of countries and family planning funds
gen fund = FPP_total_percapita/CPI_2005
keep if year > 1969 & year < 2000
collapse (mean) fund, by(country)
save `funds', replace 

// 

use Dataset.dta, replace
tempfile effort // A file containing names of countries and famiyl planning efforts
keep if year > 1969 & year < 2000
collapse (mean) prog_effort_score, by(country)
ren prog_effort_score effort
save `effort', replace

//

use Dataset.dta, replace
tempfile exposure // A file containing names of countries and exposure to family planning program
keep if year <= 2005
sort country year
collapse (firstnm) exposure_FP, by(country)
ren exposure_FP exposure
save `exposure', replace

// 

use Dataset.dta, replace
tempfile urbanpop_school // Urban population and years of schooling in 1960 
keep if year == 1960
keep country CountryCode urban_pop_tot yr_sch
rename urban_pop_tot urbanpop1960
rename yr_sch school1960
save `urbanpop_school', replace

// 

use Dataset.dta, replace
tempfile pcgdp //Per capita GDP in the first year before and including 1965 
keep if year <= 1965
sort country year
collapse (firstnm) gdp_percapita, by(country)
rename gdp_percapita gdp1965
save `pcgdp', replace


// 

use Dataset.dta, replace
tempfile imr //Infant Mortality Rate in the first year before and including 1965
keep if year <= 1965
sort country year
collapse (firstnm) IMR, by(country)
rename IMR imr1965
count if imr1965!=.
save `imr', replace

// 

use Dataset.dta, replace
tempfile urbanpop_2013 //Urban population in 2013
keep if year == 2013
keep country CountryCode urban_pop_tot
rename urban_pop_tot urbanpop2013
save `urbanpop_2013', replace

//

use Dataset.dta, replace
tempfile school2010 // Years of schooling in 2010
keep if year == 2010
keep country CountryCode yr_sch
rename yr_sch school2010
save `school2010', replace

// 

use Dataset.dta, replace
tempfile gdp2013 //Per capita gdp in 2013
keep if year == 2013
keep country CountryCode gdp_percapita
rename gdp_percapita gdp2013
save `gdp2013', replace

// 

use Dataset.dta, replace
tempfile imr2013 // Infant Mortality Rate in 2013
keep if year == 2013
keep country CountryCode IMR
rename IMR imr2013
save `imr2013', replace

// Merging the datasets for the required regressions

use `source', replace
merge 1:1 country using `TFR1960', keep(master match) nogen
merge 1:1 country using `TFR2013', keep(master match) nogen
merge 1:1 country using `funds', keep(master match) nogen
merge 1:1 country using `effort', keep(master match) nogen
merge 1:1 country using `exposure', keep(master match) nogen
merge 1:1 country using `urbanpop_school', keep(master match) nogen
merge 1:1 country using `pcgdp', keep(master match) nogen
merge 1:1 country using `imr', keep(master match) nogen
merge 1:1 country using `urbanpop_2013', keep(master match) nogen
merge 1:1 country using `school2010', keep(master match) nogen
merge 1:1 country using `gdp2013', keep(master match) nogen
merge 1:1 country using `imr2013', keep(master match) nogen

tempfile mergeddata

// Generating other variables as per required

gen TFRdiff = TFR2013 - TFR1960 // Change in TFR
gen TFRpct = (TFRdiff/TFR1960)*100 // PCT Change in TFR
gen popdiff = urbanpop2013 - urbanpop1960 // Change in Urban Population
gen poppct = (popdiff/urbanpop1960)*100 // PCT Change in Urban Population
gen schooldiff = school2010 - school1960 // Change in Schooling
gen schoolpct = (schooldiff/school1960)*100 // PCT Change in Schooling
gen imrdiff = imr2013 - imr1965 // Change in IMR
gen imrpct = (imrdiff/imr1965)*100 // PCT Change in IMR
gen lngdp2013 = ln(gdp2013) // Change in natural log of gdp
gen lngdp1965 = ln(gdp1965)
gen lngdpdiff = lngdp2013 - lngdp1965
gen lngdppct = (lngdpdiff/lngdp1965)*100 // PCT Change in natural log of gdp
gen lnfund = ln(fund) // Natural Log of Fund

save `mergeddata', replace

// Replicating Table 3

quietly reg TFRdiff lnfund, vce(r)
est sto m1
quietly reg TFRdiff lnfund schooldiff popdiff lngdpdiff imrdiff, vce(r)
est sto m2
quietly reg TFRpct lnfund, vce(r)
est sto m3
quietly reg TFRpct lnfund schoolpct poppct lngdppct imrpct, vce(r)
est sto m4
esttab m1 m2 m3 m4, b se stats(N r2)

// Replicating Table 4

quietly reg TFRdiff effort, vce(r)
est sto m5
quietly reg TFRdiff effort schooldiff popdiff lngdpdiff imrdiff, vce(r)
est sto m6
quietly reg TFRpct effort, vce(r)
est sto m7
quietly reg TFRpct effort schoolpct poppct lngdppct imrpct, vce(r)
est sto m8
esttab m5 m6 m7 m8, b se stats(N r2)

// Replicating Table 5

quietly reg TFRdiff exposure, vce(r)
est sto m9
quietly reg TFRdiff exposure schooldiff popdiff lngdpdiff imrdiff, vce(r)
est sto m10
quietly reg TFRpct exposure, vce(r)
est sto m11
quietly reg TFRpct exposure schoolpct poppct lngdppct imrpct, vce(r)
est sto m12
esttab m9 m10 m11 m12, b se stats(N r2)

********************************************************************************

log close 
