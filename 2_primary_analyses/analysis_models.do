/* 

Alice R. Carter // 06/01/2022

Sub-do script to carry out one analyses of time-varying risk factors with COVID-19 testing and COVID-19 infection

This script removes individuals who have had a positive test in the previous testing period, e.g., an individual who tests positive in timepoint 1 is excluded from analyses in timepoint 2, but reintroduced into subsequent analyses

*/

* Get Args from main do

local outcome = "`1'"
local date = "`2'"
local method = "`3'"
local covars = "`4'"
local exponentiate = "`5'"
local all_exp = "`6'"
local continous_exp = "`7'"
local categorical_exp = "`8'"
local p_val_level = "`9'"

di "`outcome'"
di "`date'"
di "`method'"
di "`covars'"
di "`exponentiate'"
di "`all_exp'"
di "`continuous_exp'"
di "`categorical_exp'"
di "`p_val_level'"

* Set working directory
cd "$resDir/results/"

* Set local variables for exposure lists

* Set up results file
foreach var of varlist `all_exp' {

	putexcel set `outcome'_`date', sheet(`var') modify
	
	putexcel  A1="Risk factor" B1="Time period" C1="N" D1="N Case/test" ///
				E1="Beta" F1="LCI" G1="UCI" ///
				H1="P value" I1="P value for interaction"

}


* Continuous models for exposure, not accounting for time
* Model 1 - First test among whole population, not accounting for changes over time
* This does not make any exclusions based on covid positivity, and looks at cases across the whole year
foreach var of varlist `continous_exp' {
	
local x=1

putexcel set `outcome'_`date', sheet(`var') modify
	
		`method' `outcome' `var' `covars', `exponentiate'
	
	matrix results = r(table)
	local beta = results[1,1]
	local se = results[2,1]
	local lci = (`beta'-`se'*`p_val_level')
	local uci = (`beta'+`se'*`p_val_level')
	local p_value = results[4,1]
	local n = e(N)
	local exp_label : var label `var'
	
	local x=`x'+1

	putexcel A`x'="`exp_label'" B`x'="Whole year" C`x'=`n' E`x'=`beta' F`x'=`lci' G`x'=`uci' H`x'=`p_value' 

}

* Continuous models for exposure,  accounting for time
* Model 2 - First test within distinct testing period
* This section of code removes people if htye test positive for covid in the immediate preceding time point
* E.g., if someone is COVID(+) in time point 1, they are excluded from time 2, but reincluded in time 3/4
 foreach var of varlist `continous_exp' {

local x=2

forval i =1/4 {

putexcel set `outcome'_`date', sheet(`var') modify

	if ("`i'"=="1") {
		
	`method' `outcome'_period`i' `var' `covars' if period`i'_sample==1, `exponentiate'	
	
	}
	
 if ("`i'"!="1") {
    
local y = `i'-1

	`method' `outcome'_period`i' `var' `covars' if period`i'_sample==1 & positive_test_period`y'!=1, `exponentiate'	
 }
 
	matrix results = r(table)
	local beta = results[1,1]
	local se = results[2,1]
	local lci = (`beta'-`se'*`p_val_level')
	local uci = (`beta'+`se'*`p_val_level')
	local p_value = results[4,1]
	local n = e(N)
	local exp_label : var label `var'
	
	local x=`x'+1

	putexcel A`x'="`exp_label'" B`x'=`i' C`x'=`n' E`x'=`beta' F`x'=`lci' G`x'=`uci' H`x'=`p_value' 

}
}

************************************************************************


* Categorical models for exposure, not accounting for time
* Model 1 - First test among whole population, not accounting for changes over time
* This does not make any exclusions based on covid positivity, and looks at cases across the whole year
foreach var of varlist `categorical_exp' {
local x=1

putexcel set `outcome'_`date', sheet(`var') modify
	
	
	if ("`var'"!="blood_type" | "`var'"!="hair_colour" | "`var'"!="hh_size_cat" | "`var'"!="vehicles_base") {
		`method' `outcome' i.`var' `covars', `exponentiate' base
	}
	
	if ("`var'"=="hh_size_cat") {
		`method' `outcome' ib1.`var' `covars', `exponentiate' base	
	}
	
	if ("`var'"=="vehicles_base") {
		`method' `outcome' ib2.`var' `covars', `exponentiate' base
	}
	
	if ("`var'"=="blood_type" | "`var'"=="hair_colour") {
		`method' `outcome' i.`var' `covars' ethnicity, `exponentiate' base
	}	
	
	matrix results = r(table)
	
	local n = e(N)
	
	tab `var', matrow(names)	
	local rows = rowsof(names)
	
	local val = names[1,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,1]-results[2,1]*`p_val_level')
	local uci = (results[1,1]+results[2,1]*`p_val_level')
	local x=`x'+1
	putexcel A`x'="`exp_label'" B`x'="Whole year" C`x'=`n' E`x'=results[1,1] F`x'=`lci' G`x'=`uci' H`x'=results[4,1]

	local val = names[2,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,2]-results[2,2]*`p_val_level')
	local uci = (results[1,2]+results[2,2]*`p_val_level')
	local x=`x'+1
	putexcel A`x'="`exp_label'" B`x'="Whole year" C`x'=`n' E`x'=results[1,2] F`x'=`lci' G`x'=`uci' H`x'=results[4,2]

	 if ("`var'" ==  "hair_colour" |"`var'" ==  "highest_qual" | "`var'" == "blood_type" | "`var'" == "income" | "`var'" == "accomodation_base" | "`var'" == "imd_cat" | "`var'" == "home_owner_base" | "`var'" == "hh_size_cat"  | "`var'" == "vehicles_base" | "`var'" == "age_cat") {
	local val = names[3,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,3]-results[2,3]*`p_val_level')
	local uci = (results[1,3]+results[2,3]*`p_val_level')
	local x=`x'+1
	 putexcel A`x'="`exp_label'" B`x'="Whole year" C`x'=`n' E`x'=results[1,3] F`x'=`lci' G`x'=`uci' H`x'=results[4,3]
	 }
	 
	 if ("`var'" ==  "highest_qual" | "`var'" == "blood_type" | "`var'" == "income" | "`var'" == "accomodation_base" | "`var'" == "imd_cat" | "`var'" == "home_owner_base" | "`var'" == "hh_size_cat"  | "`var'" == "vehicles_base" | "`var'" == "age_cat") {
	local val = names[4,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,4]-results[2,4]*`p_val_level')
	local uci = (results[1,4]+results[2,4]*`p_val_level')
	local x=`x'+1
	 putexcel A`x'="`exp_label'" B`x'="Whole year" C`x'=`n' E`x'=results[1,4] F`x'=`lci' G`x'=`uci' H`x'=results[4,4]

	 if ("`var'" == "income" | "`var'" == "accomodation_base" | "`var'" == "imd_cat" | "`var'" == "home_owner_base" | "`var'" == "vehicles_base" | "`var'" == "age_cat") {
	 
	local val = names[5,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,5]-results[2,5]*`p_val_level')
	local uci = (results[1,5]+results[2,5]*`p_val_level')
	local x=`x'+1
	putexcel A`x'="`exp_label'" B`x'="Whole year" C`x'=`n' E`x'=results[1,5] F`x'=`lci' G`x'=`uci' H`x'=results[4,5]
	 }
	 
	 if ("`var'" == "home_owner_base" | "`var'" == "age_cat") {	
	local val = names[6,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,6]-results[2,6]*`p_val_level')
	local uci = (results[1,6]+results[2,6]*`p_val_level')
	local x=`x'+1
	putexcel A`x'="`exp_label'" B`x'="Whole year" C`x'=`n' E`x'=results[1,6] F`x'=`lci' G`x'=`uci' H`x'=results[4,6]
	}
	
		 if ("`var'" == "age_cat") {	
	local val = names[7,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,7]-results[2,7]*`p_val_level')
	local uci = (results[1,7]+results[2,7]*`p_val_level')
	local x=`x'+1
	putexcel A`x'="`exp_label'" B`x'="Whole year" C`x'=`n' E`x'=results[1,7] F`x'=`lci' G`x'=`uci' H`x'=results[4,7]
	}
	}
}

* Categorical models for exposure,  accounting for time
* Model 2 - First test within distinct testing period
* This section of code removes people if htye test positive for covid in the immediate preceding time point
* E.g., if someone is COVID(+) in time point 1, they are excluded from time 2, but reincluded in time 3/4

foreach var of varlist `categorical_exp' {
local x=8
forval i =1/4 {
	
putexcel set `outcome'_`date', sheet(`var') modify
	
	
	if ("`var'"!="blood_type" | "`var'"!="hair_colour" | "`var'"!="hh_size_cat" | "`var'"!="vehicles_base") {
	    if ("`i'"=="1") {
			`method' `outcome'_period`i' i.`var' `covars' if period`i'_sample==1, `exponentiate'
		}
		if ("`i'"!="1") {		
		local y = `i'-1
			`method' `outcome'_period`i' i.`var' `covars' if period`i'_sample==1 & positive_test_period`y'!=1, `exponentiate'	
		}
	}
	
	if ("`var'"=="hh_size_cat") {
		    if ("`i'"=="1") {
			`method' `outcome'_period`i' ib1.`var' `covars' if period`i'_sample==1, `exponentiate'
		}
		if ("`i'"!="1") {		
		local y = `i'-1
			`method' `outcome'_period`i' ib1.`var' `covars' if period`i'_sample==1 & positive_test_period`y'!=1, `exponentiate'		
			}
		}
	
	if ("`var'"=="vehicles_base") {
		    if ("`i'"=="1") {
			`method' `outcome'_period`i' ib2.`var' `covars' if period`i'_sample==1, `exponentiate'
		}
		if ("`i'"!="1") {		
		local y = `i'-1
			`method' `outcome'_period`i' ib2.`var' `covars' if period`i'_sample==1 & positive_test_period`y'!=1, `exponentiate'	
		}
	}
	
	if ("`var'"=="blood_type" | "`var'"=="hair_colour") {
	    if ("`i'"=="1") {
			`method' `outcome'_period`i' i.`var' `covars' ethnicity if period`i'_sample==1, `exponentiate'
		}
		if ("`i'"!="1") {		
		local y = `i'-1
			`method' `outcome'_period`i' i.`var' `covars' ethnicity if period`i'_sample==1 & positive_test_period`y'!=1, `exponentiate'	
		}
	}	

	matrix results = r(table)
	
	local n = e(N)	
	
	tab `var', matrow(names)	
	local rows = rowsof(names)
	
	local val = names[1,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,1]-results[2,1]*`p_val_level')
	local uci = (results[1,1]+results[2,1]*`p_val_level')
	local x=`x'+1
	putexcel A`x'="`exp_label'" B`x'="`i'" C`x'=`n' E`x'=results[1,1] F`x'=`lci' G`x'=`uci' H`x'=results[4,1]

	local val = names[2,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,2]-results[2,2]*`p_val_level')
	local uci = (results[1,2]+results[2,2]*`p_val_level')
	local x=`x'+1
	 putexcel A`x'="`exp_label'" B`x'="`i'" C`x'=`n' E`x'=results[1,2] F`x'=`lci' G`x'=`uci' H`x'=results[4,2]

	 if ("`var'" ==  "hair_colour" |"`var'" ==  "highest_qual" | "`var'" == "blood_type" | "`var'" == "income" | "`var'" == "accomodation_base" | "`var'" == "imd_cat" | "`var'" == "home_owner_base" | "`var'" == "hh_size_cat"  | "`var'" == "vehicles_base" | "`var'" == "age_cat") {
	local val = names[3,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,3]-results[2,3]*`p_val_level')
	local uci = (results[1,3]+results[2,3]*`p_val_level')
	local x=`x'+1
	 putexcel A`x'="`exp_label'" B`x'="`i'" C`x'=`n' E`x'=results[1,3] F`x'=`lci' G`x'=`uci' H`x'=results[4,3]
	 }
	 
	 if ("`var'" ==  "highest_qual" | "`var'" == "blood_type" | "`var'" == "income" | "`var'" == "accomodation_base" | "`var'" == "imd_cat" | "`var'" == "home_owner_base" | "`var'" == "hh_size_cat"  | "`var'" == "vehicles_base" | "`var'" == "age_cat") {
	local val = names[4,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,4]-results[2,4]*`p_val_level')
	local uci = (results[1,4]+results[2,4]*`p_val_level')
	local x=`x'+1
	 putexcel A`x'="`exp_label'" B`x'="`i'" C`x'=`n' E`x'=results[1,4] F`x'=`lci' G`x'=`uci' H`x'=results[4,4]

	 if ("`var'" == "income" | "`var'" == "accomodation_base" | "`var'" == "imd_cat" | "`var'" == "home_owner_base" | "`var'" == "vehicles_base" | "`var'" == "age_cat") {
	 
	local val = names[5,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,5]-results[2,5]*`p_val_level')
	local uci = (results[1,5]+results[2,5]*`p_val_level')
	local x=`x'+1
	putexcel A`x'="`exp_label'" B`x'="`i'" C`x'=`n' E`x'=results[1,5] F`x'=`lci' G`x'=`uci' H`x'=results[4,5]
	 }
	 
	 if ("`var'" == "home_owner_base" | "`var'" == "age_cat") {	
	local val = names[6,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,6]-results[2,6]*`p_val_level')
	local uci = (results[1,6]+results[2,6]*`p_val_level')
	local x=`x'+1
	putexcel A`x'="`exp_label'" B`x'="`i'" C`x'=`n' E`x'=results[1,6] F`x'=`lci' G`x'=`uci' H`x'=results[4,6]
	 }
	 
	if ("`var'" == "age_cat") {	
	local val = names[7,1]
	local exp_label : label (`var') `val'
	local lci = (results[1,7]-results[2,7]*`p_val_level')
	local uci = (results[1,7]+results[2,7]*`p_val_level')
	local x=`x'+1
	putexcel A`x'="`exp_label'" B`x'="`i'" C`x'=`n' E`x'=results[1,7] F`x'=`lci' G`x'=`uci' H`x'=results[4,7]
	 }
	}
	}
}


/*
foreach var of varlist `all_exp' {
	local x=1
forval i =1/4 {	
	
	putexcel set `outcome'_`date', sheet(`var') modify
	
	local x=`x'+1
	
	 if ("`outcome'" !="lnrepeat_tests") {	
	tab `outcome' if `var'!=. & period`i'==1  , matcell(numbers)
	
	local number_outcome = numbers[2,1]
	putexcel D`x'=`number_outcome' 
	
	 }
}
}

foreach var in `all_exp' {
	local x=2
forval i =1/4 {	
	
	putexcel set `outcome'_`date', sheet(`var') modify
	
	local x=`x'+1
	
	 if ("`outcome'" != "lnrepeat_tests") {	
	tab `outcome'_period`i' if `var'!=. & period`i'==1  , matcell(numbers)
	
	local number_outcome = numbers[2,1]
	putexcel D`x'=`number_outcome' 
	
	 }
}
}
*/
