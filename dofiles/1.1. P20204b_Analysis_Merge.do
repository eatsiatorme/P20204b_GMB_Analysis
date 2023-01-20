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

cap drop deviceid_el subscriberid_el devicephonenum_el mean_light_level_el min_light_level_el max_light_level_el sd_light_level_el sd_light_level_el mean_movement_el sd_movement_el min_movement_el max_movement_el mean_sound_level_el min_sound_level_el max_sound_level_el sd_sound_level_el mean_sound_pitch_el min_sound_pitch_el max_sound_pitch_el max_sound_pitch_el sd_sound_pitch_el pct_quiet_el pct_still_el pct_still_el pct_moving_el pct_conversation_el light_level_el movement_el movement_el sound_level_el sound_pitch_el conversation_el nameid_el id_key_el final_phone1_el final_phone2_el final_phone3_el final_phone4_el final_phone5_el fianl_phone6_el whatsapp_el telegram_el email_el other_phone_el other_phone_owner_el respondent_found_el respondent_found_el respondent_found_comx_el availability_el availability_comx_el loclatitude_el loclongitude_el localtitude_el locaccuracy_el id1a_comx_el id1b_comx_el id1_check_comx_el id2_comx_el id2_check_consistency_el id2_check_consistency_comx_el id2_check_consistency_comx_el id2_check_el id2_check_dk_el a5_comx_el a8_comx_el a9_comx_el d1_comx_el d2_comx_el d12_comx_el d7_comx_el d8_comx_el b1a_comx_el b1c_comx_el b1_comx_el b2_comx_el job_name_comx_el b3_comx_el b3_comx_el b3_a_comx_el b6_comx_el b9_comx_el b9a_comx_el b12_comx_el b13_comx_el b14_comx_el b14e_comx_el b15_comx_el b15_check_comx_el b16_comx_el b16_check_comx_el b17_unit_s_comx_el b17low_check_comx_el b20_comx_el b22_comx_el b23_comx_el b27_comx_el b31a_comx_el b31c_comx_el b32_job_name_el b37_comx_el b38_comx_el b39_comx_el c1_normal_comx_el c1_comx_el c3_comx_el c2_comx_el c5_comx_el c4_comx_el p2_comx_el p3_comx_el t2_comx_el t3_comx_el t5_comx_el t6_comx_el t7_comx_el e0_comx_el e1_comx_el e6_comx_el h2_comx_el h4_comx_el h5_comx_el h13_comx_el r3_comx_el r4_comx_el r5_comx_el r5_comx_el f1_comx_el f1_comx_el f3_comx_el f3_comx_el j1a_comx_el j4_comx_el j6_comx_el tekki_comp_check_comx_el tekki_institute_comx_el tekki_institute_comx_el tekki_course_comx_el tekkifii_dropout_comx_el tekki_institute_applied_comx_el tekkifii_outcome_comx_el tekkifii_absent_unsucc_comx_el k1_comx_el k1_comx_el k2_comx_el k4_comx_el k5_comx_el k6_comx_el k10_comx_el k10_comx_el k11_comx_el k11_comx_el k12_comx_el tekkifii_check_ind_why_comx_el k21_comx_el k22_comx_el a6_comx_el a6_comx_el b4_comx_el b5_comx_el b5_comx_el cc8_comx_el pay_cash_comx_el refused_comx_el completed_questions_comx_el profit_comx_el pay_inkind_comx_el sales_comx_el respondent_name_el respondent_name_el //Move this to cleaning

ds ApplicantID treatment, not
foreach var of varlist `r(varlist)' {
	rename `var' `var'_el
}







*** DO MERGING

******************************
**Save in data path**
******************************
save "$data_path\COMPLETE_DATA_Endline.dta", replace