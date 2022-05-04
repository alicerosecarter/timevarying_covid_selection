/*

A.R. Carter // 06/07/2021
Defining COVID-19 infection and severity in UK Biobank
This uses COVID-19 testing and mortality data released on the 06/07/2021

Updated on 15/09/21 to use newly released data with ABO variable

Updates on 30/09/21 - 
- Use IMD instead of TDI as neighbourhood deprivation variable
- Use full ethnicity variable

Updated on 18/10/21 -
- Flip variables so baseline is always = to highest SEP indicator

*/

* Use the data containing variables which will be used as covariates for analysis
* This dataset has withdrawals removed, but no other exclusions have been applied. These are applied in this script
use "$COVIDITY/data/COVIDITY/UKBB/analysis_variables_202110.dta", clear

* Remove new withdrawals

* Change the working directory
cd "$resDir/data/"

* Exclusions 
/* Remove for pregnancy */
drop if n_3140_0_0 ==1
drop if n_3140_0_0 ==2

/* Remove pre 2020 deaths */
drop if date_of_death!=. & date_of_death < date("20200311", "YMD")


/*

		Total N = 
		N Tests = 
		N untested = 
		N COVID-19 positive = 
		N COVID-19 negative = 
		N COVID-19 death = 

*/

/* Coding/tidying up exposure variables*/

* Household size at baseline - might need to amend upper limit removals
rename n_709_0_0 hh_size_base
lab var hh_size_base "Size of household at baseline"
replace hh_size_base=. if hh_size_base<0


** REMOVE OUTLIERS??
gen hh_size_cat = 0 if hh_size_base==1
replace hh_size_cat = 1 if hh_size_base==2
replace hh_size_cat = 2 if hh_size_base==3
replace hh_size_cat= 3 if hh_size_base>=4 & hh_size_base!=.
lab var hh_size_cat "Household size at baseline - categorical"
lab def hh_size_cat 0 "One person" 1 "Two people" 2 "Three people" 3 "Four or mroe people"
lab val hh_size_cat hh_size_cat

* Car ownership at baseline
rename n_728_0_0 vehicles_base
lab var vehicles_base "Number of vehicles at baseline"
replace vehicles_base=. if vehicles_base<0
replace vehicles_base = vehicles_base-1

lab def vehicles_base 0 "None" 1 "One" 2 "Two" 3 "Three" 4 "Four or more"
lab val vehicles_base vehicles_base

* Average household income at baseline
rename n_738_0_0 income_base
lab var income_base "Average household income at baseline"
replace income_base=. if income_base<0

* Home ownership at baseline
rename n_680_0_0 home_owner_base
lab var home_owner_base "Own or rent accomodation at baseline"
replace home_owner_base=. if home_owner_base<0

* Type of accomodation at baseline
rename n_670_0_0 accomodation_base
lab var accomodation_base "Type of accomodation lived in at baseline"
replace accomodation_base=. if accomodation_base<0

* Destring blood type
gen blood_type_2 = 1 if blood_type=="AA"
replace blood_type_2 = 1 if blood_type=="AO"
replace blood_type_2 = 2 if blood_type=="BB"
replace blood_type_2 = 2 if blood_type=="BO"
replace blood_type_2 = 3 if blood_type=="AB"
replace blood_type_2 = 4 if blood_type=="OO"
lab def blood_type_2 1 "A" 2 "B" 3 "AB" 4 "O", modify
lab val blood_type_2 blood_type_2
lab var blood_type_2 "Genetically predicted blood group"
drop blood_type
rename blood_type_2 blood_type

* Code full ethnicity variable and rename white/other to binary variable
rename ethnicity ethnicity_binary

gen ethnicity = ethnicity_0_0
replace ethnicity = ethnicity_1_0 if ethnicity==.
replace ethnicity = ethnicity_2_0 if ethnicity==.
lab def ethnicity 1 "white" 2 "Indian" 3 "Pakistani" 4 "Bangladeshi" 5 "Other Asian" 6 "Black Caribbean" 7 "Black African" 8 "Chinese" 9 "Other", modify
lab val ethnicity ethnicity
lab var ethnicity Ethnicity

* Create quintiles of IMD
xtile imd_cat=imd_0_0, n(5)
lab var imd_cat "IMD quintiles"

* Define hair colour as blonde, brown and other
replace hair_colour = 3 if hair_colour==1
replace hair_colour = 1 if hair_colour==0
lab def hair_colour  1 "Blonde" 2 "Brown" 3 "Other", modify
lab val hair_colour hair_colour

* Create categories of Age (based on 5 year age bands; over 70s grouped with 65-70years as only 7 participants over 70)
gen age_cat = 1 if age_0_0<=40 & age_0_0!=.
replace age_cat = 2 if age_0_0<=45 & age_0_0>40 & age_cat==.
replace age_cat = 3 if age_0_0<=50 & age_0_0>45 & age_cat==.
replace age_cat = 4 if age_0_0<=55 & age_0_0>50 & age_cat==.
replace age_cat = 5 if age_0_0<=60 & age_0_0>55 & age_cat==.
replace age_cat = 6 if age_0_0<=65 & age_0_0>60 & age_cat==.
replace age_cat = 7 if age_0_0>65 & age_cat==. & age_0_0!=.
lab var age_cat "Age - categorical 5 years bands"
lab def age_cat 1 "≤40" 2 ">40 & ≤45" 3 ">45 & ≤50" 4 ">50 & ≤55" 5 ">55 & ≤60" 6 ">60 & ≤65" 7 ">65"
lab val age_cat age_cat

/* Flip variables so all baseline = highest SEP */

* Note: No prior hypothesis for "baseline" ABO blood group or hair colour

* homeowner, accomodation and IMD all coded as baseline = high SEP

gen income = 1 if income_base == 5
replace income = 2 if income_base == 4
replace income = 3 if income_base == 3
replace income = 4 if income_base == 2
replace income = 5 if income_base ==1

lab var income "Income at baseline (>£100k ref)"
lab def income 1 "Greater than £100,000" 2"£52,000-£100,000" 3 "£31,000-51,599" 4 "£18,000-£30,999" 5"Less than £18,000", modify
lab val income income

gen highest_qual = 1 if eduyears_quali == 3
replace highest_qual = 2 if eduyears_quali == 2
replace highest_qual = 3 if eduyears_quali == 1
replace highest_qual = 4 if eduyears_quali ==0
 
lab def highest_qual  1 "Degree level or higher" 2 "Vocational qualifications" 3 " AS/A level" 4 "GCSE/O level or less"
lab val highest_qual highest_qual
lab var highest_qual "Highest qualification (degree ref)"

********************************************************************************
* Merge in genetic linker  which is needed for sensitivity analyses restricting to genetically determined White British individuals

capture drop _merge
merge 1:1 n_eid using "$resDir/data/genetic_linker"
keep if _merge !=2
capture drop _merge
lab var id_ieu "Genetic Linker"

rename n_eid id_phe
capture drop _merge
foreach var in  highly_related relateds non_white_british {
    merge m:1 id_ieu using "$resDir/data/exclusions/exclusions_`var'.dta"
	gen `var'= 1 if _merge==3
    drop _merge
}
rename id_phe n_eid

gen genetic_exclusion = 1 if highly_related==1 | relateds==1 | non_white_british==1
replace genetic_exclusion = 0 if genetic_exclusion ==.
lab var genetic_exclusion "Recommended genetic exclusions"

						* Create COVID-19 definitions *
********************************************************************************
							* Reference variables *						
********************************************************************************

* Tested vs non-tested 
* Tested defined as having a COVID test in the PHE data 
* This uses the variable covid_test defined in the script cleaning_covid_data.do. Participants with a test are already set to 1, so anyone missing (because they were not in the PHE data) are set to 0
*gen covid_test=1 if number_covid_tests!=.
replace covid_test = 0 if covid_test==.
lab def covid_test 0 "Not tested" 1 "Tested", modify
lab val covid_test covid_test
lab var covid_test "Non-tested vs covid tested (any setting)"

* This variable does not include any mortality data. Therefore, participants could have a death of U07.1 recorded (COVID diagnosed via test) and be classed as "untested" if they do not have their test data/results

********************************************************************************

* This is  a variable for those who have died either from COVID or other causes compared with those alive
* The variable covid_death is defined in the script cleaning_covid_data.do.This sets anyone with a non-covid death to 1 and a covid death to 2
* This set of code assigns anyone with no data (i.e., missing) on death to 0
gen any_death = 0 if covid_death==.
replace any_death = 1 if covid_death == 1
replace any_death = 2 if covid_death ==2
lab def any_death 0 "Alive" 1 "Non Covid death" 2 "Covid death", modify
lab val any_death any_death
lab var any_death "Alive vs Death in 2020 from covid or non-covid causes"

* Note that some of the "non-covid" deaths may still have received a positive covid test and some of the covid deaths may not have been tested

********************************************************************************

* Variable combining suspected and tested covid deaths according to ICD codes used, not according to test data
* This replaces data in the covid_death variable derived from the script cleaning_covid_data.do. Here, we set any non-covid deaths to 0 (the same as those with no death) and covid deaths are set to 1
* Very few deaths are defined as suspected covid, there are also a number of covid deaths recorded as U07.1 indicating they were tested without test data, so all deaths will be treated equally

replace covid_death = 0 if covid_death==.
replace covid_death = 0 if covid_death==1 /* This line sets non-covid deaths to a controls, they are not excluded from analyses */
replace covid_death = 1 if covid_death==2
replace covid_death_test = 0 if covid_death_test==. & covid_death_suspect!=1
replace covid_death_suspect = 0 if covid_death_suspect==. & covid_death_test!=1

lab def covid_death 0 "Alive or non-covid death" 1 "Covid death", modify
lab val covid_death covid_death
lab val covid_death_test covid_death
lab val covid_death_suspect covid_death 
lab var covid_death "Alive  or non-covid death (all ppts.) vs covid death"

********************************************************************************
* Create date of first test/first positive test *
********************************************************************************
capture drop first_test first_test_date first_positive first_positive_date repeat_tests first_negative first_negative_date
gen first_test =.
gen first_test_date =. 
gen first_positive =. 
gen first_positive_date =.
gen repeat_tests=0
gen first_negative =.
gen first_negative_date =.

* Loop to assign participants to have a covid test, and a positive covid test, across the 12 month aggregated period
* Participants can have multiple covid tests and therefore, can have a (positive) test in more than one period. 
 
*  ssc install findname

local startDate = "20200311"
local endDate = "20210328"

findname test_date_*
local testdatevars = "`r(varlist)'"
foreach thistestdate in `testdatevars' { 

	di "`thistestdate'"

	* COVID test in period
	replace first_test = 1 if `thistestdate' >= date("`startDate'", "YMD") & `thistestdate' < date("`endDate'", "YMD") & `thistestdate'!=. & first_test==.
	
	* Date of covid test in period
	replace first_test_date = `thistestdate' if first_test==1 & first_test_date==.

	* Covid positive in period
	* get respective test result
	local i = substr( "`thistestdate'", 11,.)	
	di `i'

	* Set positive cases to 1
	replace first_positive = 1 if `thistestdate' >= date("`startDate'", "YMD") & `thistestdate' < date("`endDate'", "YMD") & `thistestdate'!=. & first_positive==. & result_`i'==1
	
	* Date of covid positive in periods
	replace first_positive_date = `thistestdate' if first_positive==1 & first_positive_date==.

	* Set positive cases to 1
	replace first_negative = 1 if `thistestdate' >= date("`startDate'", "YMD") & `thistestdate' < date("`endDate'", "YMD") & `thistestdate'!=. & first_negative==. & result_`i'==0 & first_positive!=1
	
	* Date of covid positive in periods
	replace first_negative_date = `thistestdate' if first_negative==1 & first_negative_date==.	
	
	* Number of covid tests in 1 year period
	replace repeat_tests = (repeat_tests+1) if  `thistestdate' >= date("`startDate'", "YMD") & `thistestdate' < date("`endDate'", "YMD") & `thistestdate'!=. 

}

format first_test_date %td
format first_positive_date %td

* Set control group
replace first_test = 0 if first_test==.


*label variable/values
lab def testing 0 "No test" 1 "Test"
lab val first_test testing
lab var first_test "First test"
rename first_test test

*label variable/values
replace first_negative = 0 if test==0
lab def first_negative 0 "Untested" 1 "Test negative"
lab val first_negative first_negative 
lab var first_negative "First negative test (excluded if any subsequent positive test)"
rename first_negative negative_test

*label variable/values
replace first_positive = 0 if test==1 & first_positive!=1
lab def first_positive 0 "SARS-CoV-2 negative" 1 "SARS-CoV-2 positive", modify
lab val first_positive first_positive
lab var first_positive "First positive test"
rename first_positive positive_test


********************************************************************************
* Setting testing variables for time periods *
********************************************************************************
* generate covid variables for period 1 (March 2020-May 2020, first wave pre-mass testing)
* Dates selected based on WHO declaring a pandemic and the introduction of mass testing
do "$scriptDir/1_data_management/testing_period_data.do" "period1" "20200311" "20200518"

* generate covid variables for period 2 (June 2020-October 2020, post-mass testing with relaxed restrictions)
* 19th May chosen as entry date as mass testing began and 13th October as the last day before the tier system began (https://www.bmj.com/content/371/bmj.m3961)
do "$scriptDir/1_data_management/testing_period_data.do" "period2" "20200519" "20201013"

* generate covid variables for period 3 (October 2020-December 2020, Early winter wave with localised restrictions)
* 14th October chosen as first day of tier system and 4th January as final day before winter lockdown (https://www.gov.uk/government/news/prime-minister-announces-national-lockdown)
do "$scriptDir/1_data_management/testing_period_data.do" "period3" "20201014" "20210104"

* generate covid variables for period 4 (January 2021 - March 2021, Winter peak with full restrictions)
* 5th January start date as first day of full lockdown 2021 and 28th March as last day before lockdown easy allowing rule of 6 outside (https://www.bbc.co.uk/news/uk-56158405)
do "$scriptDir/1_data_management/testing_period_data.do" "period4" "20210105" "20210328"

* Log transforming number of tests for use in analyses
foreach var of varlist repeat_tests* {
    
	gen ln`var' = ln(`var')
}

* Create variable for Scottish/Welsh participants to remove from main analyses
gen scottish_welsh = 1 if n_54_0_0==11003 | n_54_0_0==11004 | n_54_0_0==11005 | n_54_0_0==11022 | n_54_0_0==11023


* Remove Scottish and Welsh participants - not used in analyses due to different rules/legislation and therefore likely different selection pressures

drop if scottish_welsh==1

* Drop incorrectly merged in/missing variables
drop if n_eid==.

* drop unecesary variables

keep n_eid sd_tdi tdi_0_0 hh_size_base vehicles_base income home_owner_base accomodation_base highest_qual ethnicity covid_death* first_test* first_positive* *diag n_54* negative_* number_* repeat_tests* period* positive* negative* sd_age sd_bmi sex sibling scottish_welsh sbp_avg dbp_avg sd_sbp sd_dbp test test_period* urban_rural current_smoke age_0_0 blood_type hair_colour blonde_brown covid_test imd_0_0 sd_imd lnrepeat_tests* hair_colour imd_cat employment highly_related relateds non_white_british age_cat hh_size_cat date_of_death

save "time_varying_data_202203.dta", replace
