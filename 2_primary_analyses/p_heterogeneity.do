** Meta-analysing across time periods to obtain P value for heterogeneity

local date = "`1'"
local all_exp = "`2'"

di "`date'" 
di "`all_exp'" 

foreach out in lnrepeat_tests_`date' positive_test_`date' test_`date' {

foreach sheet in `all_exp' {
	
import excel "$resDir/results/`out'.xlsx", sheet("`sheet'") firstrow clear

replace Timeperiod = "0" if Timeperiod=="Whole year"
destring Timeperiod, replace

 if ("`sheet'" == "hh_size_base" | "`sheet'" == "vehicles_base"| "`sheet'" == "age_0_0") {

	metan Beta LCI UCI if Timeperiod!=0, lcols(Riskfactor Timeperiod) effect(OR) null(1) nograph
	
	putexcel set "$resDir/results/`out'.xlsx", sheet(`sheet') modify
	
	local p_het = r(p_het)
	
	putexcel I2=`p_het'
 }
 
 if ("`sheet'" == "hair_colour" | "`sheet'" == "highest_qual" | "`sheet'" == "blood_type" | "`sheet'" == "income" | "`sheet'" == "imd_cat" | "`sheet'" == "home_owner_base"| "`sheet'" == "sex") {
     
	 drop if Timeperiod==.

	sencode Riskfactor, generate(riskfactor_levels)
	
	drop if riskfactor_levels==1
	
	levelsof riskfactor_levels, local(levels)
	local x=2
	foreach l of local levels {
	
	metan Beta LCI UCI if Timeperiod!=0 & riskfactor_levels==`l', lcols(riskfactor_level Timeperiod) effect(OR) null(1) nograph
	
	putexcel set "$resDir/results/`out'.xlsx", sheet(`sheet') modify
	
	local p_het = r(p_het)
	local x=`x'+1
	putexcel I`x'=`p_het'
	
	}
	
 }

}

}

* Note Accomodation has no observations for some outcomes, so loop needs adding to pass through error | "`sheet'" == "accomodation_base"