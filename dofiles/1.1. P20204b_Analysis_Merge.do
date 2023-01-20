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


append using "`x'" , gen(cyclex)


label def L_cycle 0 "Cycle 1" 1 "Cycle 2"
label val cyclex L_cycle
*use "$field_mc1\Tekki_Fii_PV", clear

foreach var of varlist ta_*{
	cap drop `var' ta_*
	
}

drop deviceid subscriberid devicephonenum mean_light_level min_light_level max_light_level sd_light_level mean_movement sd_movement max_movement mean_sound_level min_sound_level max_sound_level sd_sound_level mean_sound_pitch min_sound_pitch max_sound_pitch sd_sound_pitch pct_quiet pct_still pct_moving pct_conversation light_level movement sound_level sound_pitch conversation nameid final_phone1 final_phone2 final_phone3 final_phone4 final_phone5 fianl_phone6 whatsapp telegram email email other_phone other_phone_owner availability availability_comx loclatitude loclongitude localtitude locaccuracy id1a_comx id1b_comx id1_check_comx id2_comx id2_check_consistency id2_check_consistency_comx id2_check id2_check_dk a5_comx a8_comx a9_comx d1_comx d2_comx d12_comx d7_comx d8_comx b1a_comx b1b_comx b1c_comx b1_comx b2_comx job_name_comx b3_comx b3_a_comx b6_comx b9_comx b9a_comx b12_comx b13_comx b14_comx b14e_comx b15_comx b15_comx b15_check_comx b16_comx b16_check_comx b17_unit_s_comx b17low_check_comx b18_a_comx b20_comx b20_comx b21_comx b22_comx b23_comx b27_comx b31a_comx b31c_comx b37_comx b38_comx b39_comx b40_comx c1_normal_comx c1_comx c3_comx c2_comx c5_comx c4_comx p2_comx p3_comx t2_comx t3_comx t5_comx t6_comx t7_comx e0_comx e1_comx e6_comx h2_comx h4_comx h5_comx h13_comx r3_comx r4_comx r5_comx f1_comx f1_comx f3_comx j1a_comx j4_comx j6_comx tekki_course_comx k1_comx k2_comx k4_comx k5_comx k6_comx k10_comx k11_comx k12_comx k21_comx k22_comx a6_comx b4_comx b5_comx cc8_comx pay_cash_comx refused_comx completed_questions_comx profit_comx pay_inkind_comx pay_inkind_comx sales_comx respondent_name //Move this to cleaning

ds ApplicantID treatment, not
foreach var of varlist `r(varlist)' {
	rename `var' `var'_el
}







*** DO MERGING

******************************
**Save in data path**
******************************
save "$data_path\COMPLETE_DATA_Endline.dta", replace