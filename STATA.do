clear 

set more off
capture log close 

cd "/Users/mihir/Documents/D Drive/Mihir Docs UMD/Sem 2/644/HW/HW 1"
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
name(fig1, replace)

// FIGURE 2

tempfile fig3 // Saving the collapsed dataset for easy reference
collapse (mean) TFR [fw=population], by(wbregion year)
save `fig3', replace

codebook wbregion /// To get the index codes for each of the regions

twoway (line TFR year if wbregion == 1) (line TFR year if wbregion == 2, lpattern(dash)) (line TFR year if wbregion == 3, lpattern(longdash)) (line TFR year if wbregion == 4, lpattern(longdash_dot)) (line TFR year if wbregion == 5, lpattern(shortdash)) (line TFR year if wbregion == 6, lpattern(shortdash_dot)) (line TFR year if wbregion == 7, lpattern(dash_dot)), ytitle("Total Fertility Rate") xtitle("Years") legend(order(1 "North America" 2 "Europe and Central Asia" 3 "East Asia and Pacific" 4 "Latin America" 5 "Middle East and North Africa" 6 "South Asia" 7 "Sub Saharan Africa") size(small) span position(6) rows(2)) title("Total Fertility Rate Across Periods By Region") note("Data: de Silva, Tenreyro 2017") name(fig2, replace)

use Dataset.dta, replace 

// FIGURE 3

twoway (scatter TFR ln_gdp if year == 1960, msymbol(circle) mfcolor(white)) (lowess TFR ln_gdp if year == 1960 & wbregion!=.) (scatter TFR ln_gdp if year == 2013, msymbol(triangle) mfcolor(blue)) (lowess TFR ln_gdp if year == 2013 & wbregion!=.), legend(order(1 "1960" 3 "2013" 2 "Fitted 1960" 4 "Fitted 2013") rows(1) size(small) position(6)) title("Fertility GDP Relation in 1960 & 2013") ytitle("TFR") xtitle("GDP per capita ($)") note("Data: de Silva, Tenreyro 2017") name(fig3, replace)

// FIGURE 4

twoway (scatter TFR urban_pop_tot if year == 1960, msymbol(circle) mfcolor(white)) (lowess TFR urban_pop_tot if year == 1960 & wbregion!=.) (scatter TFR urban_pop_tot if year == 2013, msymbol(triangle) mfcolor(blue)) (lowess TFR urban_pop_tot if year == 2013 & wbregion!=.), legend(order(1 "1960" 3 "2013" 2 "Fitted 1960" 4 "Fitted 2013") rows(1) size(small) position(6)) title("Fertility Population Relation in 1960 & 2013") ytitle("TFR") xtitle("Urban Population (as a % of total population)") note("Data: de Silva, Tenreyro 2017") name(fig3, replace)

// FIGURE 5

tempfile fig5 // Saving the collapsed dataset for easy reference

encode fertpolicy, gen(fpcode) //Encoding the fertility policy

gen fpcode76 = fpcode if year == 1976 //Generating a variable with encoded fertility policy for each country for the year 1976

egen fpcode76all=mean(fpcode76) if wbregion!=., by(country) //fitting 1976 values of fertility policy across countries

collapse (mean) TFR [fw=population], by(year fpcode76all) //Collapsing data to keep actual TFR and TFR at the time of fertility policies in 1976

twoway (line TFR year if fpcode76all == 1) (line TFR year if fpcode76all == 2) (line TFR year if fpcode76all == 3) (line TFR year if fpcode76all == 4) if year > 1959 & year < 2011, xlabel(1960(10)2011) legend(order(1 "Lower" 2 "No Intervention" 3 "Maintain" 4 "Raise") size(small) span position(6) rows(2)) xscale(range(1960 2011)) ytitle("Mean TFR") xtitle("Years") title("Fertility Rates by Policy in 1976") note("Data: de Silva, Tenreyro 2017") name(fig5, replace)

save `fig5', replace


