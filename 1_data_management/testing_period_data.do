/*

A.R. Carter // 24/03/2021
Defining COVID-19 infection and severity in UK Biobank
This uses COVID-19 testing and mortality data released on the 13/02/2021

*/

* get options from args

local period = "`1'"
local startDate = "`2'"
local endDate = "`3'"

di "`period'"
di "`startDate'"
di "`endDate'"

* Exclude participants who died before the start of the period, either from COVID-19 or non-COVID-19 causes
*drop if date_of_death!=. & date_of_death < date("`startDate'", "YMD")


* Remove participants who have died before the start of the testing period
* Set death in period
capture drop covid_death_`period'
gen covid_death_`period' = 1 if covid_death==1 & date_of_death >= date("`startDate'", "YMD") & date_of_death < date("`endDate'", "YMD")


/*
We create 4 variables based on COVID-19 testing and result. Only cases are defined here. Controls and variable labels are assigned in the script below.

These variables are the main variables used to define the different case/control definitions in the script and are called on throughout
*/


* Create case definition variables that will be populated in the loops below
* variables with "test" in the name refer to those based on test data only
* VIn this analysis, we are only interested in selection/changes in testing, so do not use mortality data
capture drop test_`period' positive_test_`period' negative_test_`period'
gen test_`period'=.
gen positive_test_`period'=.
gen negative_test_`period'=.

capture drop test_date_`period' positive_test_date_`period' negative_test_date_`period'
gen first_test_date_`period'=.
gen positive_test_date_`period'=.
gen negative_test_date_`period'=.

capture drop repeat_tests_`period'
gen repeat_tests_`period'=0

* Loop to assign participants to have a covid test, and a positive covid test, in the testing periods
* Participants can have multiple covid tests and therefore, can have a (positive) test in more than one period. 
 
*  ssc install findname

findname test_date_*
local testdatevars = "`r(varlist)'"
foreach thistestdate in `testdatevars' { 

	di "`thistestdate'"

	* COVID test in period
	replace test_`period' = 1 if `thistestdate' >= date("`startDate'", "YMD") & `thistestdate' < date("`endDate'", "YMD") & `thistestdate'!=. & test_`period'==.
	
	* Date of covid test in period
	replace first_test_date_`period' = `thistestdate' if test_`period'==1  & first_test_date_`period'==.

	* Covid positive in period
	* get respective test result
	local i = substr( "`thistestdate'", 11,.)	
	di `i'

	* Set positive cases to 1
	replace positive_test_`period' = 1 if `thistestdate' >= date("`startDate'", "YMD") & `thistestdate' < date("`endDate'", "YMD") & `thistestdate'!=. & positive_test_`period'==. & result_`i'==1
	
	* Date of covid positive in periods
	replace positive_test_date_`period' = `thistestdate' if positive_test_`period'==1 & positive_test_date_`period'==.

	* Covid negative in period
	replace negative_test_`period' = 1 if `thistestdate' >= date("`startDate'", "YMD") & `thistestdate' < date("`endDate'", "YMD") & `thistestdate'!=. & negative_test_`period'==. & result_`i'==0 

	* Set ppts to missing if they have a positive COVID-19 test (as well as negative) so they are only counted once per period
	replace negative_test_`period'=. if positive_test_`period'==1

	* Date of covid negative in periods
	replace negative_test_date_`period' = `thistestdate' if negative_test_`period'==1 & negative_test_date_`period'==.
	
	* Number of covid tests in period
	replace repeat_tests_`period' = (repeat_tests_`period'+1) if  `thistestdate' >= date("`startDate'", "YMD") & `thistestdate' < date("`endDate'", "YMD") & `thistestdate'!=. 
}

* Set test dates of non-tested to end of phase
replace first_test_date_`period' = `endDate' if first_test_date_`period'==.
replace positive_test_date_`period' = `endDate' if positive_test_date_`period'==.
replace negative_test_date_`period' = `endDate' if negative_test_date_`period'==.

********************************************************************************
							* Setting control definitions *
********************************************************************************
	
							* COVID-19 testing *
********************************************************************************
********************************************************************************
							* Assessed vs non-assessed *
********************************************************************************

/*
Setting the control (not assessed) group to zero, based on the case defintion defined in the loop above
*/

* Variables for having test data for COVID stratified by testing period
* Only defined based on tests, not on deaths 

replace test_`period' = 0 if test_`period'==. 

lab var test_`period' "Non-tested vs Covid test during `period'  "
lab def test_`period' 0 "No test `period' " 1 "Test `period'", modify
lab val test_`period' test_`period'

					* COVID-19 INFECTION/SUSCPETIBILITY *
********************************************************************************

********************************************************************************
					* Case (COVID-19 +) vs Controls (all population) *
********************************************************************************

* Variable for covid positive vs covid negative based on test data
* This is defined based on having a positive covid test, not accounting for deaths
* COVID negative is defined as no test or test negative

capture drop positive_test_pop_`period'
gen positive_test_pop_`period' = 1 if positive_test_`period'==1
replace positive_test_pop_`period' = 0 if positive_test_`period'==. 

lab def positive_test_pop_`period' 0 "No test/test negative" 1 "Covid test positive", modify
lab val positive_test_pop_`period' positive_test_`period'
lab var positive_test_pop_`period' "all ppts. (inc -ive test) vs Covid positive confirmed via test in `period' "


* This variable does not include any mortality data. Therefore, participants could have a death of U07.1 recorded (COVID diagnosed via test) and be classed as "untested" if we do not have their test data/results


********************************************************************************
					* Case (COVID-19 +) vs Controls (tested negative) *
********************************************************************************

* Variable for covid positive vs covid negative based on test data
* This is defined based on having a positive covid test, not accounting for deaths
* COVID negative is defined as test negative

replace positive_test_`period' = 0 if negative_test_`period'==1

lab def positive_test_`period' 0 "No test/test negative" 1 "Covid test positive", modify
lab val positive_test_`period' positive_test_`period'
lab var positive_test_`period' "all ppts. (inc -ive test) vs Covid positive confirmed via test in `period' "


* This variable does not include any mortality data. Therefore, participants could have a death of U07.1 recorded (COVID diagnosed via test) and be classed as "untested" if we do not have their test data/results
********************************************************************************

********************************************************************************
				* Case (Covid-19 -) vs Controls (untested) *
********************************************************************************

* Variable for Covid negative participants vs those who have not been tested as a negative control outcome

replace negative_test_`period' = 0 if test_`period'==0

lab def negative_test_`period' 0 "Untested" 1 "Test negative", modify
lab val negative_test_`period' negative_test_`period'
lab var negative_test_`period' "Untested (ref) vs test negative `period'"


********************************************************************************
	* Set deaths from Covid/non-covid causes before the period to missing *
********************************************************************************

foreach var in test_`period' positive_test_pop_`period' positive_test_`period' {
	
	replace `var' = . if date_of_death!=. & date_of_death < date("`startDate'", "YMD")
}


********************************************************************************
                  * Define study population for each testing period *
********************************************************************************

gen `period'_sample = 1 if test_`period'!=.



