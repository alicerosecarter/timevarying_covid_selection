/*
Alice R. Carter - 23/6/21
Cleaning COVID-19 test/death data to merge with UK Biobank baseline data
*/

* Test data - ENGLAND

* Import test data
import delimited "$dataDir/2021-02-24/data/covid/covid19_result_england-20210705.txt", clear 

* Create string variable for test data from specdate variable
gen double test_date_ = date(specdate,"DMY")
format test_date %td

* Count the number of covid tests per person and maximum taken
* The count variable will be used to reshape the data to provide one set of observations for every test taken
by eid, sort: gen count_test=_n
by eid: egen n_tests_ = max(count_test)
lab var n_tests "Number of covid tests taken"

* Rename each variable to have a _ suffix to make reshaped data more clear
foreach var in specdate spectype laboratory origin result acute hosaq reqorg {
	
	rename `var' `var'_
}

* Reshape the data from long to wide format providing one set of observations for every test taken
reshape wide n_tests_ test_date_ specdate_ spectype_ laboratory_ origin_ result_ acute_ hosaq_ reqorg_, i(eid) j(count_test)

* Drop repeated versions of n_tests_
* Keep just the first set, as all variables are the same for all individuals and rename variable 
forvalues i = 2/76 {
drop n_tests_`i'
}
rename n_tests_1 number_covid_tests

* Loop through all results to identify which tests are positive and create covid positive vs covid negative variable
gen covid_test_result =0
forvalues i = 1/76 {
foreach var in result_`i' {
	
	replace covid_test_result = 1 if `var'==1
}
}
lab var covid_test_result "Any COVID-19 test positive"
lab def covid_test_result 0 "COVID-19 negative" 1 "COVID-19 positive"
lab val covid_test_result covid_test_result

* Loop through origin variables to identify whether the test was carried out in hospital or in the community
gen inpatient_covid =  0
forvalues i = 1/76 {
foreach var in origin_`i' {
	
	replace inpatient_covid = 1 if `var'==1
}
}
lab var inpatient_covid "Microbiological evidence ppt was  inpatient"
lab def inpatient_covid 0 "No" 1  "Yes"
lab val inpatient_covid inpatient_covid

gen repeat_covid_test = 0 if number_covid_tests>1
replace repeat_covid_test = 1 if repeat_covid_test==.
lab var repeat_covid_test "More than one covid test for participant"
lab def repeat 0 "One test only" 1 "More than one covid test"
lab val repeat_covid_test repeat

* Create a variable for having a covid test. All participants in this dataset are set to 1. This could also be made in the main dataset based on the _merge variable
gen covid_test = 1
lab var covid_test "Covid test taken"
lab def covid_test 0 "No covid test" 1 "Covid test taken"
lab val covid_test covid_test

rename eid n_eid 

* Label variables and values
lab def origin 0 "No explicit evidence in microbiological record that the participant was an inpatient" 1 "Evidence from microbiological record that the participant was an inpatient", modify
		forvalues i = 1/76 {
		foreach var in origin_`i' {
	
			lab var `var' "Inpatient test (origin) `i'"
			lab val `var' origin
	
			}
		}

lab def reqorg 0 "Null requesting organisation" 1 "Hospital inpatient" 2 "Not found" 3 "Hospital outpatient" 4 "Healthcare worker testing" 5 "Hospital A&E" 6 "Unknown" 7 "General practitioner" 8 "Environmental health officer" 9 "Care home" 10 "Genito-urinary medicine dept." 11 "Occupational health dept." 12 "Other" 13 "Educational establishment" 14 "Local authority" 15 "Private healthcare" 16 "Internal employee testing", modify
		forvalues i = 1/76 {
		foreach var in reqorg_`i' {
	
			lab var `var' "Requesting organisation `i'"
			lab val `var' reqorg
	
			}
		}
	
lab def result 0 "Negative" 1 "Positive", modify
		forvalues i = 1/76 {
		foreach var in result_`i' {
	
			lab var `var' "Test result `i'"
			lab val `var' result
	
			}
		}

lab def acute -1 "Unknown" 0 "No" 1 "Yes", modify
		forvalues i = 1/76 {
		foreach var in acute_`i' {
	
			lab var `var' "Reqorg acute care `i'"
			lab val `var' acute
	
			}
		}

lab def hosaq -1 "Unknown" 0 "No" 1 "Yes", modify
		forvalues i = 1/76 {
		foreach var in hosaq_`i' {
	
			lab var `var' "Hospital acquired`i'"
			lab val `var' hosaq
			
			}
		}
		
forvalues i = 1/76 {
foreach var in specdate_`i' {
	
	lab var `var' "Test date `i'"
	
	}
}
	
forvalues i = 1/76 {
foreach var in laboratory_`i' {
	
	lab var `var' "Processing lab `i'"
	
	}
}	

forvalues i = 1/76 {
foreach var in spectype_`i' {
	
	lab var `var' "Swab taken from `i'"
	
	}
}	

save "$resDir/data/covid_test_england_202107.dta", replace


* Test data - WALES

* Import test data
import delimited "$dataDir/2021-02-24/data/covid/covid19_result_wales-20210705.txt", clear 

* Create string variable for test data from specdate variable
gen double test_date_ = date(specdate,"DMY")
format test_date %td

* Count the number of covid tests per person and maximum taken
* The count variable will be used to reshape the data to provide one set of observations for every test taken
by eid, sort: gen count_test=_n
by eid: egen n_tests_ = max(count_test)
lab var n_tests "Number of covid tests taken"

* Rename each variable to have a _ suffix to make reshaped data more clear
foreach var in specdate spectype laboratory pattype perstype result {
	
	rename `var' `var'_
}

* Reshape the data from long to wide format providing one set of observations for every test taken
reshape wide n_tests_ test_date_ specdate_ spectype_ laboratory_ pattype_ perstype_ result_ , i(eid) j(count_test)

* Drop repeated versions of n_tests_
* Keep just the first set, as all variables are the same for all individuals and rename variable 
forvalues i = 2/51 {
drop n_tests_`i'
}
rename n_tests_1 number_covid_tests

* Loop through all results to identify which tests are positive and create covid positive vs covid negative variable
gen covid_test_result =0
forvalues i = 1/51 {
foreach var in result_`i' {
	
	replace covid_test_result = 1 if `var'==1
}
}
lab var covid_test_result "Any COVID-19 test positive"
lab def covid_test_result 0 "COVID-19 negative" 1 "COVID-19 positive"
lab val covid_test_result covid_test_result

* Loop through origin variables to identify whether the test was carried out in hospital or in the community
gen inpatient_covid =  0
forvalues i = 1/51 {
foreach var in pattype_`i' {
	
	replace inpatient_covid = 1 if `var'==6
	replace inpatient_covid = 1 if `var'==7 & inpatient_covid==.
	
}
}
lab var inpatient_covid "Inpatient or ITU/HDU patient"
lab def inpatient_covid 0 "No" 1  "Yes"
lab val inpatient_covid inpatient_covid

gen repeat_covid_test = 0 if number_covid_tests>1
replace repeat_covid_test = 1 if repeat_covid_test==.
lab var repeat_covid_test "More than one covid test for participant"
lab def repeat 0 "One test only" 1 "More than one covid test"
lab val repeat_covid_test repeat

* Create a variable for having a covid test. All participants in this dataset are set to 1. This could also be made in the main dataset based on the _merge variable
gen covid_test = 1
lab var covid_test "Covid test taken"
lab def covid_test 0 "No covid test" 1 "Covid test taken"
lab val covid_test covid_test

rename eid n_eid 

* Label variables and values
* NOTE:perstype = 80 labels, unlikely to use (although does define keyworker/asymptomatic etc)
lab def pattype 0 "Null datan" 1 "Hospital A&E" 2 "Ante-natal" 3 "Community" 4 "Day case" 5 "GP practice" 6 "ITU/HDU" 7 "In patient" 8 "Occupational health" 9 "Other" 10 "Outpatient" 11 "Outpatient rapid turnaround" 12 "Post mortem" 13 "Post mortem sample" 14 "Private healthcare" 15 "Renal" 16 "Renal dialysis"17 "Renal and Transplant", modify
		forvalues i = 1/51 {
		foreach var in pattype_`i' {
	
			lab var `var' "Patient type `i'"
			lab val `var' pattype
	
			}
		}
	
lab def result 0 "Negative" 1 "Positive", modify
		forvalues i = 1/51 {
		foreach var in result_`i' {
	
			lab var `var' "Test result `i'"
			lab val `var' result
	
			}
		}

		
forvalues i = 1/51 {
foreach var in specdate_`i' {
	
	lab var `var' "Test date `i'"
	
	}
}
	
forvalues i = 1/51 {
foreach var in laboratory_`i' {
	
	lab var `var' "Processing lab `i'"
	
	}
}	

forvalues i = 1/51 {
foreach var in spectype_`i' {
	
	lab var `var' "Swab taken from `i'"
	
	}
}	

save "$resDir/data/covid_test_wales_202107.dta", replace

* Test data - SCOTLAND


* Import test data
import delimited "$dataDir/2021-02-24/data/covid/covid19_result_scotland-20210705.txt", clear 

* Create string variable for test data from specdate variable
gen double test_date_ = date(specdate,"DMY")
format test_date %td

* Count the number of covid tests per person and maximum taken
* The count variable will be used to reshape the data to provide one set of observations for every test taken
by eid, sort: gen count_test=_n
by eid: egen n_tests_ = max(count_test)
lab var n_tests "Number of covid tests taken"

* Rename each variable to have a _ suffix to make reshaped data more clear
foreach var in specdate laboratory factype site result {
	
	rename `var' `var'_
}

* Reshape the data from long to wide format providing one set of observations for every test taken
reshape wide n_tests_ test_date_ site_ specdate_ laboratory_ factype_ result_ , i(eid) j(count_test)

* Drop repeated versions of n_tests_
* Keep just the first set, as all variables are the same for all individuals and rename variable 
forvalues i = 2/65 {
drop n_tests_`i'
}
rename n_tests_1 number_covid_tests

* Loop through all results to identify which tests are positive and create covid positive vs covid negative variable
gen covid_test_result =0
forvalues i = 1/65 {
foreach var in result_`i' {
	
	replace covid_test_result = 1 if `var'==1
}
}
lab var covid_test_result "Any COVID-19 test positive"
lab def covid_test_result 0 "COVID-19 negative" 1 "COVID-19 positive"
lab val covid_test_result covid_test_result

gen repeat_covid_test = 0 if number_covid_tests>1
replace repeat_covid_test = 1 if repeat_covid_test==.
lab var repeat_covid_test "More than one covid test for participant"
lab def repeat 0 "One test only" 1 "More than one covid test"
lab val repeat_covid_test repeat

* Create a variable for having a covid test. All participants in this dataset are set to 1. This could also be made in the main dataset based on the _merge variable
gen covid_test = 1
lab var covid_test "Covid test taken"
lab def covid_test 0 "No covid test" 1 "Covid test taken"
lab val covid_test covid_test

rename eid n_eid 

* Label variables and values
lab def factype 0 "Null datan" 1 "Community" 2 "GP" 3 "Hospital" 4 "NHS - Other" 5 "Non-NHS Other" 6 "Occupational health" 7 "Residential care home", modify
		forvalues i = 1/65 {
		foreach var in factype_`i' {
	
			lab var `var' "Testing facility `i'"
			lab val `var' factype
	
			}
		}
	
lab def result 0 "Negative" 1 "Positive", modify
		forvalues i = 1/65 {
		foreach var in result_`i' {
	
			lab var `var' "Test result `i'"
			lab val `var' result
	
			}
		}

		
forvalues i = 1/65 {
foreach var in specdate_`i' {
	
	lab var `var' "Test date `i'"
	
	}
}
	
forvalues i = 1/65 {
foreach var in site_`i' {
	
	lab var `var' "Processing site `i'"
	
	}
}	

forvalues i = 1/65 {
foreach var in laboratory_`i' {
	
	lab var `var' "Prcessing lab `i'"
	
	}
}	

save "$resDir/data/covid_test_scotland_202107.dta", replace

* Import test data
import delimited "$dataDir/2021-02-24/data/covid/covid19_result_wales-20210705.txt", clear 


*Death data
*import delimited 
import delimited "$dataDir/2021-02-24/data/covid/death_cause-20210617.txt", clear

gen covid_death_test_x=1 if cause_icd10=="U071"
gen covid_death_suspect_x=1 if cause_icd10=="U072"

bysort eid: egen covid_death_test = max(covid_death_test_x)
replace covid_death_test = 0 if covid_death_test==.

bysort eid: egen covid_death_suspect = max(covid_death_suspect_x)
replace covid_death_suspect = 0 if covid_death_suspect==. & covid_death_test==0

gen covid_death = 2 if covid_death_test==1 
replace covid_death = 2 if covid_death_suspect==1 & covid_death==.
replace covid_death = 1 if covid_death==.

lab def covid_death 0 "Alive" 1 "Non-covid death" 2"Any covid death"
lab val covid_death covid_death

lab val covid_death_test casecontrol
lab val covid_death_suspect casecontrol

lab var covid_death "Suspected or confirmed covid death"
lab var covid_death_test "Covid death confirmed with test"
lab var covid_death_suspect "Suspected covid death (no test)"

save "$resDir/data/covid_death_202106.dta", replace

** Adding date of death

import delimited "$dataDir/2021-02-24/data/covid/death-20210617.txt", clear

merge m:m eid using "$resDir/data/covid_death_202106.dta"

keep if _merge==3

gen double date = date(date_of_death,"DMY")
format date %td

drop date_of_death
rename date date_of_death

duplicates tag eid, gen(duplicate)
duplicates drop eid, force

save "$resDir/data/covid_death_dates_202106.dta", replace
