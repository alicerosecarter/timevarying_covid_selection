* Calculating test positivity at each timepoint by strata of SEP

* Test positivity = (Positive tests/total tests)*100

use "$resDir/data/time_varying_data_202203.dta", clear

* Set date local
global date 20220316

* Set working directory
cd "$resDir/results/"

* Set global variables for exposures
global all_exp hh_size_base vehicles_base hair_colour highest_qual blood_type income accomodation_base imd_cat home_owner_base hh_size_cat 
global continuous_exp hh_size_base 
global categorical_exp hair_colour highest_qual blood_type income accomodation_base imd_cat home_owner_base hh_size_cat vehicles_base

* Set up results file
foreach var of varlist $all_exp {

	putexcel set $resDir/results/test_positivity_$date, sheet(`var') modify
	
	putexcel A1="Exposure" B1="Level of exposure" C1="Time Period" D1="Total sample" E1="Positive tests" F1="Total tests" G1="Test positivity %" H1="LCI" I1="UCI"

}


* Test positivity not accounting for SEP
local x=1
forval i =1/4 {
 
putexcel set $resDir/results/test_positivity_$date, sheet(Total) modify

   if ("`i'"=="1") {
   
		tab period`i'_sample if period`i'_sample==1, matcell(numbers)	
		local total_sample = numbers[1,1]	
		
		tab positive_test_period`i' if period`i'_sample==1, matcell(numbers)
		local total_positive = numbers[2,1]

		tab test_period`i' if period`i'_sample==1, matcell(numbers)
		local total_test = numbers[2,1]	
   }
 
    if ("`i'"!="1") {
		
		local y = `i'-1
		
		tab period`i'_sample if period`i'_sample==1 & positive_test_period`y'!=1, matcell(numbers)	
		local total_sample = numbers[1,1]	

		tab positive_test_period`i' if period`i'_sample==1 & positive_test_period`y'!=1, matcell(numbers)
		local total_positive = numbers[2,1]

		tab test_period`i' if period`i'_sample==1 & positive_test_period`y'!=1, matcell(numbers)
		local total_test = numbers[2,1]	
   }
   
	di "period_`i'"
	di  (`total_positive'/`total_test')*100
	local test_positivity_percent = ((`total_positive'/`total_test')*100)
	local sample_prop = `total_positive'/`total_test'
	local se = sqrt(((`sample_prop'*(1-`sample_prop'))/(`total_test'))*1.96)
	local lci = `test_positivity_percent'-`se'
	local uci = `test_positivity_percent'+`se'
	
	local x=`x'+1
	
	putexcel A1="Exposure" B1="Level of exposure" C1="Time Period" D1="Total sample" E1="Positive tests" F1="Total tests" G1="Test positivity %" H1="LCI" I1="UCI"
	putexcel A`x'="Total" B`x'="NA" C`x'="period_`i'" D`x'="`total_sample'" E`x'="`total_positive'" F`x'="`total_test'" G`x'="`test_positivity_percent'" H`x'=`lci' I`x'=`uci'
	
}


* Test positivity accounting for SEP

foreach var of varlist $categorical_exp {
local x = 1
putexcel set $resDir/results/test_positivity_$date, sheet(`var') modify

levelsof `var', local(levels)

foreach l of local levels {

	tab `var' if `var'==`l' , matrow(names)	
	local rows = rowsof(names)
	
	local val = names[1,1]
	local level_label : label (`var') `val'

forval i =1/4 {
	
   if ("`i'"=="1") {
		
		tab `var' if `var'==`l' & period`i'_sample==1, matcell(numbers)	
		local total_sample = numbers[1,1]	
		
		tab positive_test_period`i' if `var'==`l' & period`i'_sample==1, matcell(numbers)
		local total_positive = numbers[2,1]

		tab test_period`i' if `var'==`l' &  period`i'_sample==1, matcell(numbers)
		local total_test = numbers[2,1]	
   }
 
    if ("`i'"!="1") {
		local y = `i'-1
	
		tab `var' if `var'==`l' & period`i'_sample==1 & positive_test_period`y'!=1, matcell(numbers)	
		local total_sample = numbers[1,1]	
				
		tab positive_test_period`i' if `var'==`l' &  period`i'_sample==1 & positive_test_period`y'!=1, matcell(numbers)
		local total_positive = numbers[2,1]

		tab test_period`i' if `var'==`l' &  period`i'_sample==1 & positive_test_period`y'!=1, matcell(numbers)
		local total_test = numbers[2,1]	
   }
   
	
	di "`var'" "`level_label'"
	di "period_`i'"
	di (`total_positive'/`total_test')*100
	local test_positivity_percent = ((`total_positive'/`total_test')*100)
	local sample_prop = `total_positive'/`total_test'
	local se = sqrt(((`sample_prop'*(1-`sample_prop'))/(`total_test'))*1.96)
	local lci = `test_positivity_percent'-`se'
	local uci = `test_positivity_percent'+`se'
	
	local x=`x'+1
	local exp_label : var label `var'
	
	putexcel A`x'="`exp_label'" B`x'="`level_label'" C`x'="period_`i'" D`x'="`total_sample'" E`x'="`total_positive'" F`x'="`total_test'" G`x'="`test_positivity_percent'" H`x'=`lci' I`x'=`uci'
	
}
}
}
