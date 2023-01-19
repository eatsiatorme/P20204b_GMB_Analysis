*quietly {

*** Analysis_Merge
** Youth Survey
* Nathan Sivewright Feb 2021

// This do-file: 
// 1. Appends/Merges together all the rounds of field data
// 2. Saves it in the Data Folder

***************************
**  erase files in data_path **
***************************
/*
local deletepathexp = "$data_path\/"
local dtafiles : dir "`deletepathexp'" file "*.dta", respectcase	
foreach file in `dtafiles' {	
	local fileandpathtodelete = "`deletepathexp'"+"`file'"
	capture erase "`fileandpathtodelete'"
}
*/
*** DO MERGING



********************
use "$di_data1", clear


tempfile y
save `y'
*********************
use "$di_data2", clear
replace b20_2 = "." if b20_2 == ""
destring b20_2 b20_other_3, replace force

tempfile x
save `x'
*********************

use "$di_data1", clear


append using "`x'" "`y'" , gen(cyclex)

label def L_cycle 0 "Cycle 1" 1 "Cycle 2" 2 "Cycle 3"
label val cyclex L_cycle
*use "$field_mc1\Tekki_Fii_PV", clear

foreach var of varlist ta_*{
	cap drop `var' ta_*
	
}

ds ApplicantID treatment, not
foreach var of varlist `r(varlist)' {
	rename `var' `var'_el
}







*** DO MERGING

******************************
**Save in data path**
******************************
save "$data_path\COMPLETE_DATA_Endline.dta", replace