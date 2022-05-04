use "$resDir/data/time_varying_data_202203.dta", clear

/*

local outcome = "`1'"
local date = "`2'"
local method = "`3'"
local covars = "`4'"
local exponentiate = "`5'"
local all_exp = "`6'"
local continous_exp = "`7'"
local categorical_exp = "`8'"
local p_val_level = "`9'"

*/

* Edited on 6/1/22 to add negative vs untested as a negative control outcome and to add sensitivity analysis excluding individuals with a positive test in the previous testing period

* Edited on 28/1/22 to change age covariate to categorical age indicator variable to model non-linear association between age and COVID outcomes

* Edited on 9/3/22 to make prior exclusions the main analysis, meaning participants who test positive for covid at one time point are excluded for the immediate next time point

* Edited on 14/3/22 to set baseline values of categorical hh size and vehicles to be best guess of high SEP baseline

* Set global variables for exposures
global all_exp hh_size_base vehicles_base hair_colour highest_qual blood_type income accomodation_base imd_cat home_owner_base hh_size_cat 
global continuous_exp hh_size_base 
global categorical_exp hair_colour highest_qual blood_type income accomodation_base imd_cat home_owner_base hh_size_cat vehicles_base

* Analysis 1: Logistic analysis for receiving a test
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"test" ///
	"20220314" ///
	"logistic" ///
	"i.age_cat sex" ///
	"" ///
	"$all_exp" ///
	"$continuous_exp" ///
	"$categorical_exp" ///
	"1.96"

* Analysis 2: linear model for number of tests
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"lnrepeat_tests" ///
	"20220314" ///
	"regress" ///
	"i.age_cat sex" ///
	"eform(`outcome'_period`i')" ///
	"$all_exp" ///
	"$continuous_exp" ///
	"$categorical_exp" ///
	"1.96"
	
* Analysis 3: logistic model for positive tests
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"positive_test" ///
	"20220314" ///
	"logistic" ///
	"i.age_cat sex" ///
	"" ///
	"$all_exp" ///
	"$continuous_exp" ///
	"$categorical_exp" ///
	"1.96"
	
* Analysis 4: logistic model for negative tests
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"negative_test" ///
	"20220314" ///
	"logistic" ///
	"i.age_cat sex" ///
	"" ///
	"$all_exp" ///
	"$continuous_exp" ///
	"$categorical_exp" ///
	"1.96"
	
********************************************************************************
* Sensitivity analyses excluding retired participants - edited to run on all exposures, not just income

use "$resDir/data/time_varying_data_202203.dta", clear
drop if employment==2

* Analysis 1: Logistic analysis for receiving a test
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"test" ///
	"20220314_exc_retired" ///
	"logistic" ///
	"i.age_cat sex" ///
	"" ///
	"$all_exp" ///
	"$continuous_exp" ///
	"$categorical_exp" ///
	"1.96"
	
* Analysis 2: linear model for number of tests
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"lnrepeat_tests" ///
	"20220314_exc_retired" ///
	"regress" ///
	"i.age_cat sex" ///
	"eform(`outcome'_period`i')" ///
	"$all_exp" ///
	"$continuous_exp" ///
	"$categorical_exp" ///
	"1.96"
	
* Analysis 3: logistic model for positive tests
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"positive_test" ///
	"20220314_exc_retired" ///
	"logistic" ///
	"i.age_cat sex" ///
	"" ///
	"$all_exp" ///
	"$continuous_exp" ///
	"$categorical_exp" ///
	"1.96"
	
* Analysis 4: Logistic analysis for negative tests
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"negative_test" ///
	"20220314_exc_retired" ///
	"logistic" ///
	"i.age_cat sex" ///
	"" ///
	"$all_exp" ///
	"$continuous_exp" ///
	"$categorical_exp" ///
	"1.96"

********************************************************************************
* Sensitivity analyses removing ancestrally diverse participants

use "$resDir/data/time_varying_data_202203.dta", clear
drop if non_white_british==1

*List age as a continous variable to allow the script to run - work out a way of letting the script run with no continuous exposures defined

* Analysis 1: Logistic analysis for receiving a test
do "$scriptDir/2_primary_analyses/analysis_models.do" 	///
	"test" ///
	"20220314_exc_genetic" ///
	"logistic" ///
	"i.age_cat sex" ///
	"" ///
	"blood_type hair_colour" ///
	"age_0_0" ///
	"blood_type hair_colour" ///
	"1.96"

* Analysis 2: linear model for number of tests
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"lnrepeat_tests" ///
	"20220314_exc_genetic" ///
	"logistic" ///
	"i.age_cat sex" ///
	"" ///
	"blood_type hair_colour" ///
	"age_0_0" ///
	"blood_type hair_colour" ///
	"1.96"
	
* Analysis 3: logistic model for positive tests
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"positive_test" ///
	"20220314_exc_genetic" ///
	"logistic" ///
	"i.age_cat sex" ///
	"" ///
	"blood_type hair_colour" ///
	"age_0_0" ///
	"blood_type hair_colour" ///
	"1.96"
	
* Analysis 4: Logistic analysis for negative tests
do "$scriptDir/2_primary_analyses/analysis_models.do" 	///
	"negative_test" ///
	"20220314_exc_genetic" ///
	"logistic" ///
	"i.age_cat sex" ///
	"" ///
	"blood_type hair_colour" ///
	"age_0_0" ///
	"blood_type hair_colour" ///
	"1.96"


********************************************************************************
* Analyses of age and sex with outcomes

use "$resDir/data/time_varying_data_202203.dta", clear

* Analysis 1: Logistic analysis for receiving a test
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"test" ///
	"20220314_age_sex" ///
	"logistic" ///
	"" ///
	"" ///
	"age_cat sex" ///
	"age_0_0" ///
	"age_cat sex" ///
	"1.96"

* Analysis 2: linear model for number of tests
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"lnrepeat_tests" ///
	"20220314_age_sex" ///
	"regress" ///
	"" ///
	"eform(`outcome'_period`i')" ///
	"age_cat sex" ///
	"age_0_0" ///
	"age_cat sex" ///
	"1.96"

* Analysis 3: logistic model for positive tests
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"positive_test" ///
	"20220314_age_sex" ///
	"logistic" ///
	"" ///
	"" ///
	"age_cat sex" ///
	"age_0_0" ///
	"age_cat sex" ///
	"1.96"

* Analysis 4: Logistic analysis for negative tests
do "$scriptDir/2_primary_analyses/analysis_models.do" ///
	"negative_test" ///
	"20220314_age_sex" ///
	"logistic" ///
	"" ///
	"" ///
	"age_cat sex" ///
	"age_0_0" ///
	"age_cat sex" ///
	"1.96"
