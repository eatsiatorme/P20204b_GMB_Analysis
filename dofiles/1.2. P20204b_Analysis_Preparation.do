*quietly {

*** Analysis_Preparation
** Youth Survey
* Nathan Sivewright July 2021

// This do-file: 
// 1. Does all the preparation to the merged dataset ready for analysis

 **** STARTING COMMANDS ***
clear all
capture log close

local country The_Gambia

log using preparation_`country', replace


use "$data_path\COMPLETE_DATA_Endline.dta", clear
*****************************************************************************
// 1. Some respondents did not complete midline survey. These cases can be dropped by using the variable "completed_ml"
lab var completed_el "Completed endline survey"
* drop if completed_ml == 0

********************************************************************************
*						TREATMENT CHARACTERISTICS  							*
********************************************************************************

*TREATMENT <-------------------------------Need to confirm what variable to use

label define L_Treat 0 "Comparison", modify

*label variable treatment_final "Treatment group"
label define treatment_lbl 0"Comparison" 1"Treatment"
*label values treatment_final treatment_lbl

encode treatment_group_clone_el, gen (treatment_prov)
label var treatment_prov "Treatment groups (provisional variable)"
drop treatment_group_clone_el


********************************************************************************
*                         		 EMPLOYABILITY								   *			
********************************************************************************

*JOB SEARCH

gen search_emp1_el=.
replace search_emp1_el=0 if d1_el==0
replace search_emp1_el=1 if d1_el==1 | d1_el==2 | d1_el==3
label var search_emp1_el "Searched for employment in last 4 weeks"

gen search_emp2_el=.
replace search_emp2_el=0 if d1_el==0 | d1_el==2
replace search_emp2_el=1 if d1_el==1 | d1_el==3
label var search_emp2_el "Searched for employment (non-self-employed) in last 4 weeks"

gen search_emp3_el=.
replace search_emp3_el=0 if d1_el==0 | d1_el==1
replace search_emp3_el=1 if d1_el==2 | d1_el==3
label var search_emp3_el "Seeked to start a business in last 4 weeks"

label define bin_lbl 0 "No" 1"Yes"
label values search_emp?_el bin_lbl


*How searched for a job (non-self-employed)
foreach var of varlist  d3a_el-d3f_el d4b_el-d4f_el{
clonevar `var'_clone=`var'
replace `var'_clone=0 if d1_el==0 | d1_el==2
}

label var d3a_el_clone "Read ads in newspapers/journals/magazines"
label var d3b_el_clone "Prepare/revise your CV"
label var d3d_el_clone "Talk to friends/relatives about possible job leads"
*label var d3e_el_clone "Talk to previous employers/business acquaintances"
label var d3f_el_clone "Use Internet/radio/Social media"
label var d4b_el_clone "Send CV"
*label var d4c_el_clone "Filled out job application"
label var d4f_el_clone "Called/emailed prospective employer"


rename d3a_el_clone search_newspaper_el
rename d3b_el_clone search_prepcv_el
rename d3d_el_clone search_friends_el
*rename d3e_el_clone search_employer_el
rename d3f_el_clone search_internet_el

rename d4b_el_clone apply_cv_el
*rename d4c_el_clone apply_application_el
rename d4f_el_clone apply_call_el

rename d4d_el_clone interviewed_el


*Stage of recruitment
gen recruit_step_el=.
replace recruit_step_el=0 if d1_el==0 
replace recruit_step_el=1 if d1_el==1 | d1_el==2 | d1_el==3
replace recruit_step_el=2 if apply_cv_el==1 | apply_application_el==1 | apply_call_el==1
replace recruit_step_el=3 if interviewed_el==1

label var recruit_step_el "Recruitment stage"
label define recruit_step_lbl 0"Did not search" 1"Searched for employment" 2"Applied for a job" 3"Was interviewed"
label values recruit_step_el recruit_step_lbl

tabulate recruit_step_el, generate(recruit_step_el) 
labvarch recruit_step_el*, after(==)



********************************************************************************
*                         		 EMPLOYMENT									   *			
********************************************************************************
{
{ // add to cleaning


destring b12_?_?_el, replace
destring b12_??_?_el, replace

destring b20_?_?_el, replace
destring b20_??_?_el, replace



*** there is a non-missing repeat section after b1_el is no, this should not happen

* remove section for inconsistent b1_el is the prefer
foreach var of varlist  job_name_1_el-b30_other_3_el{
cap replace `var'=. if b1_el==0
cap replace `var'="" if b1_el==0
}

* adjust b1_el
replace b1_el=1 if !missing(job_name_1_el) | !missing(b3_1_el)

}


/* vars generated


self_employed_el
reg_employee_el
fam_work_el
apprentice_el
casual_worker_el
other_worker_el

self_employed_sm_el
reg_employee_sm_el
fam_work_sm_el
apprentice_sm_el
casual_worker_sm_el
other_worker_sm_el

informal_sect_1?_el // ?=a,b,c
informal_sect_2?_el // ?=a,b,c
informal_sect_3?_el // ?=a,b,c
formal_sect_el

informal_employ_1_el
informal_employ_2_el
informal_employ_3_el
formal_employ_el

isic_simple

unemployed

employed

*/
********************************************************************************
* EMPLOYMENT

{ // stable and small job
*stable employment (excludes small jobs)
clonevar stable_job_el=b1_el
label var stable_job_el "Has a stable job"

*# of stable jobs
clonevar nb_stable_job_el=b2_el
replace  nb_stable_job_el=0 if stable_job==0
label var nb_stable_job_el "Number of stable jobs"

*Has more than one stable job
cap gen several_jobs= .
replace several_jobs=0 if stable_job_el==0
replace several_jobs=0 if stable_job_el==1
replace several_jobs=1 if nb_stable_job_el>1 & stable_job==1 
label var several_jobs ">1 stable job"


*Small job (excludes stable jobs)
gen small_job_el=.
** cycle 1 definition (not quite correct)
replace small_job_el=b33_0_el if cycle==1
replace small_job_el=0 if !missing(b32_el) & cycle==1
label var small_job_el "Has an additional small job"
label values small_job_el bin_lbl
*** cycle 2 and forward definitions
replace small_job_el=b31a_el if cycle==2 | cycle==3

* Unemployment
cap drop unemployed_el
gen unemployed_el=.
label var unemployed_el "Is unemployed (last 7 days)"
** cycle 2 onwards
replace unemployed_el=1 if emp_ilo==0
replace unemployed_el=0 if emp_ilo==1
replace unemployed_el=0 if b1b_el==1

** cycle 1 (similar to cycle 2 but different variable names)
replace unemployed_el=0 if b32_el==1 & cycle==1
replace unemployed_el=0 if b32_el==0 & d1_el==0 & cycle==1
replace unemployed_el=1 if b32_el==0 & (d1_el==1 | d1_el==2 | d1_el==3) & cycle==1
//Someone who is has no job but is actively seeking for an employment (self-employed or not self-employed)


* Employment (Based on ILO definition)
cap drop employed_el

*cycle 2 and 3
gen employed_el=emp_ilo
replace employed_el=1 if b1b_el==1 &  (cycle==2 | cycle==3)
/*
is considered as employed if respondent is:
b1a_1_el	A paid employee of someone who is not a member of your household
b1a_2_el	A paid worker on household farm or non-farm business enterprise
b1a_3_el	An employer
b1a_4_el	A worker non-agricultural own account worker, without employees
or
b1b_el has a permanent job but was absent in the past 7 days

b1a_5_el	Unpaid workers (e.g. Homemaker, working in non-farm family business)
b1a_6_el	Unpaid farmers
b1a_7_el	None of the above
*/

* cycle 1
replace employed_el=0 if b32_el==0 & cycle==1
replace employed_el=1 if b32_el==1 & cycle==1
label var employed_el "Has a job (last 7 days)"




}


********************************************************************************
* EMPLOYMENT STATUS

{ // employment status of stable and small jobs

* In stable jobs

*Self-employed
cap gen self_employed_el= .
replace self_employed_el=0 if !missing(b1_el) 
replace self_employed_el=1 if b6_1_el==3 | b6_2_el==3 | b6_3_el==3
label values self_employed_el bin_lbl
label var self_employed_el "Self-employed in stable job"

*Employer
 cap gen employer_el= .
replace employer_el=0 if !missing(b1_el) 
replace employer_el=1 if b6_1_el==3 & b21_1>0 | b6_2_el==3 & b21_2>0 | b6_3_el==3 & b21_3>0
replace employer_el= . if b21_1_el==-98 & (b21_2_el==-98 |b21_2_el==.) & (b21_3_el==-98 | b21_3_el==.) // modified, we gain 2 obs  
label values employer_el bin_lbl
label var employer_el "Employer in stable job"

*Own account worker
cap gen own_account_el= .
replace own_account_el=0 if !missing(b1_el) 
replace own_account_el=1 if employer_el==0 & b21_1==0 | employer_el==0 & b21_2==0 | employer_el==0 & b21_3==0
replace own_account_el= . if b21_1_el==-98 & (b21_2_el==-98 | b21_2_el==.) & (b21_3_el==-98 | b21_3_el==.) // modified, we gain 2 obs  
label values own_account_el bin_lbl
label var own_account_el "Own account in stable job"


*Regular employee
cap gen reg_employee_el= .
replace reg_employee_el=0 if !missing(b1_el) 
replace reg_employee_el=1 if b6_1_el==1 | b6_2_el==1 | b6_3_el==1
label values reg_employee_el bin_lbl
label var reg_employee_el "Regular employee in stable job"

*Regular family worker
gen fam_work_el= .
replace fam_work_el=0 if !missing(b1_el) 
replace fam_work_el=1 if b6_1_el==2 | b6_2_el==2 | b6_3_el==2
label values fam_work_el bin_lbl
label var fam_work_el "Regular family worker in stable job"

*apprentice_el (includes volunteers and interns)
gen apprentice_el= .
replace apprentice_el=0 if !missing(b1_el) 
replace apprentice_el=1 if (b6_1_el==4 | b6_2_el==4 | b6_3_el==4) | (b6_1_el==6 | b6_2_el==6 | b6_3_el==6)
label values apprentice_el bin_lbl
label var apprentice_el "Apprentice in stable job"

*Casual worker
gen casual_worker_el= .
replace casual_worker_el=0 if !missing(b1_el) 
replace casual_worker_el=1 if b6_1_el==5 | b6_2_el==5 | b6_3_el==5
label values casual_worker_el bin_lbl
label var casual_worker_el "Casual worker in stable job"

*Other type of worker
gen other_worker_el= .
replace other_worker_el=0 if !missing(b1_el) 
replace other_worker_el=1 if self_employed_el==0 & reg_employee_el==0 & fam_work_el==0 & apprentice_el==0 & casual_worker_el==0  & stable_job_el==1
label values other_worker_el bin_lbl
label var other_worker_el "Other employment in stable job"

*Other type of worker
gen other_emp_self_el= .
replace other_emp_self_el=0 if !missing(b1_el) 
replace other_emp_self_el=1 if fam_work_el==1 | apprentice_el==1 |casual_worker_el==1
label values other_emp_self_el bin_lbl
label var other_emp_self_el "Other employment status"

}

********************************************************************************
{
* VULNERABLE EMPLOYMENT

*ILO defines vulnerable employment as being contributing faimily worker ot being own account worker
*It remains debatable whether apprencie and casual workers can be considered as "non-vulnerable workers"...		   

*Vulnerable employment:

cap gen vul_emp_el= .
replace vul_emp_el=0 if !missing(b1_el)
replace vul_emp_el=1 if own_account_el==1 | fam_work_el==1
replace vul_emp_el=0 if employer_el==1 | reg_employee_el==1 | apprentice_el==1 | casual_worker_el | other_worker_el // we insert this line after as if at least job is considered "non vulenrable, the obs is considered "non-vulnerable".
replace vul_emp_el= . if b21_1_el==-98 & (b21_2_el==-98 | b21_2_el==.) & (b21_3_el==-98 | b21_3_el==.) //We do not know if these self-employed employ someone
label var vul_emp_el "Vulnerable employment in stable job"

}


********************************************************************************
* FORMALITY (only for those with "stable" job)								   

{ // FORMAL EMPLOYMENT
/* 2 concepts: informal sector and informal employment are distinct concepts, they are also complementary. 
// The informal economy encompasses both perspectives and is defined as all economic activities by workers and economic units that are - in law or in practice - not covered or insufficiently covered by formal arrangements. ---> https://www.ilo.org/global/topics/wages/minimum-wages/beneficiaries/WCMS_436492/lang--en/index.htm


**INFORMAL SECTOR
//ILO recommends using the following criteria to identify the informal sector:
*	size: less than 5 workers --> used for self-employed but we do not have the info for subordinated workers.
*	legal: is not registered --> used 
*	organizational: keeps standardized records --> Do not have question at the job level so cannot be used.
*	production: at least part of the production is oreinted to the market --> implicitly assumed

* In practice, there is isually a great overlap when using the different criteria. there wouldn't be significant changes

*Current definition: works in unregistered firm or is self-employed in a unregistered firm and has less than 5 workers (including respondent)
*/


*** INFORMAL SECTOR

foreach i of num 1/3{
    
*** no default
cap drop informal_sect_`i'a_el
gen informal_sect_`i'a_el= .
label var informal_sect_`i'a_el "Job `i' is in the informal sector [no default]"

// Identify jobs in in/formal sector
cap replace informal_sect_`i'a_el=0 if b12_1_`i'_el==1 & !missing(b3_`i'_el)
cap replace informal_sect_`i'a_el=0 if b12_2_`i'_el==1 & !missing(b3_`i'_el)
cap replace informal_sect_`i'a_el=0 if b12_3_`i'_el==1 & !missing(b3_`i'_el)
cap replace informal_sect_`i'a_el=0 if b12_96_`i'_el==1  & !missing(b3_`i'_el)

cap replace informal_sect_`i'a_el=0 if b20_1_`i'_el==1 & !missing(b3_`i'_el)
cap replace informal_sect_`i'a_el=0 if b20_2_`i'_el==1 & !missing(b3_`i'_el)
cap replace informal_sect_`i'a_el=0 if b20_3_`i'_el==1 & !missing(b3_`i'_el)
cap replace informal_sect_`i'a_el=0 if b20_96_`i'_el==1 & !missing(b3_`i'_el)

cap replace informal_sect_`i'a_el=1 if b12_95_`i'_el==1 & !missing(b3_`i'_el)
cap replace informal_sect_`i'a_el=1 if b20_95_`i'_el==1 & !missing(b3_`i'_el)


// number of employees
replace informal_sect_`i'a_el=0 if b6_`i'_el==3 & b21_`i'_el>=4 & !missing(b21_`i'_el) & missing(informal_sect_`i'a_el) & !missing(b3_`i'_el) // before it was set to informal for <4 and default was missing. But comment said default is informal, this does not change. This way we incorporate number of workers in the definition of formality, maybe threshold should change. 4 workers because with the respondent, number of workers=5

replace informal_sect_`i'a_el=1 if b6_`i'_el==3 & b21_`i'_el<4 & !missing(b21_`i'_el)  & missing(informal_sect_`i'a_el) & !missing(b3_`i'_el) //  4 workers because with the respondent, number of workers=5

// weaker info
cap replace informal_sect_`i'a_el=1 if b20_99_`i'_el==1 & missing(informal_sect_`i'a_el) & !missing(b3_`i'_el) // if you don't know if you're registered you are likely not


*** informal default
cap drop informal_sect_`i'b_el
clonevar informal_sect_`i'b_el= informal_sect_`i'a_el
label var informal_sect_`i'b_el "Job `i' is in the informal sector [informal default]"

//By default set as formal when has a job
replace informal_sect_`i'b_el=1 if !missing(b3_`i'_el) & missing(informal_sect_`i'b_el)

*** formal default
cap drop informal_sect_`i'c_el
clonevar informal_sect_`i'c_el= informal_sect_`i'a_el
label var informal_sect_`i'c_el "Job `i' is in the informal sector [formal default]"

//By default set as formal when has a job
replace informal_sect_`i'c_el=0 if !missing(b3_`i'_el) & missing(informal_sect_`i'c_el)

}


*Any formal sector
cap drop  formal_sect_el
gen formal_sect_el= .
replace formal_sect_el=0 if !missing(b1_el)
replace formal_sect_el=1 if informal_sect_1a_el==0 | informal_sect_2a_el==0 | informal_sect_3a_el==0
label var formal_sect_el "Has a stable job in the formal sector"


*** INFORMAL EMPLOYMENT
//definition used in the Gambia: "Informal employment refers to those jobs that generally lack basic social or legal protections or employment benefits and may be found in informal sector, formal sector enterprises or households." 2018 Gambia LFS.  
* Curent definition: has an informal IGA or does not have a written contract in a registered firm.

*informal employment by job
foreach i of num 1/3{
cap drop informal_employ_`i'_el
gen informal_employ_`i'_el= .

* self employed
replace informal_employ_`i'_el=1 if b6_`i'_el==3 & informal_sect_`i'a_el==1
replace informal_employ_`i'_el=0 if b6_`i'_el==3 & informal_sect_`i'a_el==0 

* not self employed
replace informal_employ_`i'_el=1 if b6_`i'_el!=3 & b13_`i'_el==0 | b13_`i'_el==2 
replace informal_employ_`i'_el=0 if b6_`i'_el!=3 & b13_`i'_el==1 & informal_sect_`i'c_el==0 // note I use default formal for firm, as written contract already a burden

* if no contract info then base on sector
replace informal_employ_`i'_el=1 if b6_`i'_el!=3 & missing(informal_employ_`i'_el) & informal_sect_`i'a_el==1  //if in informal sector and no info on contract, then assume he is in informal employment
* replace informal_employ_`i'_el=0 if b6_`i'_el!=3 & missing(informal_employ_`i'_el) & informal_sect_`i'a_el==0 //if in formal sector and no info on contract, then assume he is in formal employment  --> I cancelled out this option as the assumption doesn't seem realistic to me. This said, for Tthis sample, it does not provoke any change.


* default informal 
replace informal_employ_`i'_el=1 if !missing(b6_`i'_el) & missing(informal_employ_`i'_el)


label var informal_employ_`i'_el "Job `i' is informal employment"

}


*Formal employment
cap drop formal_employ_el
gen formal_employ_el= .
replace formal_employ_el=0 if !missing(b1_el)
replace formal_employ_el=1 if informal_employ_1_el==0 | informal_employ_2_el==0 | informal_employ_3_el==0
label var formal_employ_el "Has a formal stable job"
}

//Wrap up:
*order variables created
order self_employed_el reg_employee_el fam_work_el apprentice_el casual_worker_el other_worker_el informal_sect_1?_el informal_sect_2?_el informal_sect_3?_el formal_sect_el informal_employ_1_el informal_employ_2_el informal_employ_3_el formal_employ_el,  after (nb_stable_job_el)
*order self_employed_sm_el reg_employee_sm_el fam_work_sm_el apprentice_sm_el casual_worker_sm_el other_worker_sm_el,  after (small_job_el)

********************************************************************************
* Employment Sector								   

{ // simplified ISIC1

*mapping job_category to isic_1_*

/*

ISIC_1	1	Agriculture, forestry and fishing
ISIC_1	2	Mining and quarrying
ISIC_1	3	Manufacturing
ISIC_1	4	Electricity, gas, steam and air conditioning supply
ISIC_1	5	Water supply; sewerage, waste management and remediation activities
ISIC_1	6	Construction
ISIC_1	7	Wholesale and retail trade; repair of motor vehicles and motorcycles
ISIC_1	8	Transportation and storage
ISIC_1	9	Accommodation and food service activities
ISIC_1	10	Information and communication
ISIC_1	11	Financial and insurance activities
ISIC_1	12	Real estate activities
ISIC_1	13	Professional, scientific and technical activities
ISIC_1	14	Administrative and support service activities
ISIC_1	15	Public administration and defence; compulsory social security
ISIC_1	16	Education
ISIC_1	17	Human health and social work activities
ISIC_1	18	Arts, entertainment and recreation
ISIC_1	19	Other service activities
ISIC_1	20	Activities of households as employers; undifferentiated goods- and services-producing activities of households for own use
ISIC_1	21	Activities of extraterritorial organizations and bodies

job_cat	1	Block-laying and concreting
job_cat	2	Tiling and Plastering
job_cat	3	Welding and farm tool repair
job_cat	4	Small engine repair
job_cat	5	Solar PV installation
job_cat	6	Garment making
job_cat	7	Hairdressing/barbering and beauty therapy
job_cat	8	Animal husbandry
job_cat	9	Satellite installation
job_cat	10	Electrical installation and repairs
job_cat	11	Plumbing
job_cat	12	None of the above categories


*/


foreach i of num 1/3{
cap replace isic_1_`i'_el=6 if (job_category_`i'_el==1 | job_category_`i'_el==2)   & (cycle==2 | cycle==3)
cap replace isic_1_`i'_el=7 if (job_category_`i'_el==3 | job_category_`i'_el==4)   & (cycle==2 | cycle==3) 
cap replace isic_1_`i'_el=5 if (job_category_`i'_el==11)   & (cycle==2 | cycle==3) 
cap replace isic_1_`i'_el=1 if (job_category_`i'_el==8)   & (cycle==2 | cycle==3)
cap replace isic_1_`i'_el=3 if (job_category_`i'_el==6)   & (cycle==2 | cycle==3) 
cap replace isic_1_`i'_el=4 if (job_category_`i'_el==5 | job_category_`i'_el==9 | job_category_`i'_el==10) & (cycle==2 | cycle==3) 
cap replace isic_1_`i'_el=19 if (job_category_`i'_el==7) & (cycle==2 | cycle==3) 

}



**generate dummies

cap drop isic_simple*
clonevar isic_simple=isic_1_1_el

label define isic1_lbl 888 "Other" 999 "No applicable/missing", modify

replace isic_simple=888 if !missing(isic_1_1_el) & !(isic_1_1_el==3 | isic_1_1_el==4 | isic_1_1_el==6 | isic_1_1_el==7 )

* make wholesale and retail and motor repair into retail and other

label define isic1_lbl 7 "Retail trade", modify

replace isic_simple=888 if !missing(isic_1_1_el) & isic_1_1_el==7 & isic_2_1_el!=747

replace isic_simple=999 if !missing(b1_el) & missing(isic_1_1_el)

tab isic_simple

tabulate isic_simple, generate(isic_simple) 
*labvarch isic_simple*, after(==)

rename isic_simple? isic_simple?_el
rename isic_simple isic_simple_el

*Division by 3 main economic sectors
foreach i of num 1/3 {
cap drop  sect_`i'_el
cap gen sect_`i'_el=.
replace sect_`i'_el=1 if isic_1_`i'_el<=2 & !missing(b3_`i'_el)
replace sect_`i'_el=2 if isic_1_`i'_el>=3 & isic_1_`i'_el<=6 & !missing(b3_`i'_el)
replace sect_`i'_el=3 if isic_1_`i'_el>=7 & !missing(b3_`i'_el)

cap label define sect_lbl 1"Primary (extraction of raw materials)" 2"Secondary (Manufacturing)" 3"Services"
label values sect_`i'_el sect_lbl
label var sect_`i'_el "Sector of employment of job `i'"
}


}


}

********************************************************************************
*             	                 INCOME						   			      *			
********************************************************************************
{ // income
/*
List of indicators created/relevant

*INCOME OVER LAST 6 MONTHS
	**Average monthly income over last 6 months:
		avg_inc_all_last6_el

	**Average monthly income from self-employment over last 6 months:
		avg_inc_se_last6_el

	**Average monthly income from employment over last 6 months:
		avg_inc_emp_last6_el

	**Average monthly income from employment over last 6 months excluding inkind payments:
		avg_inc_emp2_last6_el

*INCOME FROM CURRENT JOB
	*Monthly income from current jobs
		inc_all_current_el

	*Monthly income from current self-employment
		inc_se_current_el 

	*Monthly income from current employment:
		inc_emp_current_el

	*Monthly income from current employment excluding inkind payments:
		inc_emp2_current_el

*INCOME FROM MOST RECENT JOB
	**Average monthly income of most recent job:
		inc_most_recent_el

*PRODUCTIVITY: Hourly income
	* Average hourly income from job 1:
		hourly_income_1_el
		hourly_income_2_el
		hourly_income_3_el
	*Average hourly income over last 6 months
		hourly_income_last6_el
		
	*Hourly income from current jobs
		hourly_income_current_el

*BRIEF RESILIENCE SCALE
brs_low_el brs_high_el brs_score_el

*/

{ //  need to put into cleaning

foreach var of varlist c2_el c1_normal_el c4_el b17_?_el b18_?_el b26_?_el{
	replace `var'=.b if `var'==98  | `var'==-98 // forgot - in front of missing value code
	replace `var'=.a if `var'==99 | `var'==-99 // forgot - in front of missing value code

}

* make number of months of contract to numerical var (to be put into cleaning)
destring b17_unit_s_1_el b18_unit_s_1_el b26_unit_s_1_el b26_unit_s_2_el, replace

foreach var in b17_unit_s_1_el b18_unit_s_1_el b26_unit_s_1_el b26_unit_s_2_el{
	replace `var'=1 if `var'==0 // round up to at least 1 month
}

replace c1_el=0 if (c2_el==0 & c4_el==0) | (c2_el==6800 & c4_el==680) // no income variation, should be missing

replace c4_el=. if pii_obs_el==20 | pii_obs_el==322 // income best month=income worst months= 0

* clean income related vars

replace b26_unit_1_el=1 if pii_obs_el==307 & ApplicantID==100247 // 4000 weekly and best months 8000 monthly and May is not a best month, therefore maybe should be 4000 monthly
replace b26_unit_1_el=1 if pii_obs_el==352 & ApplicantID==100352 // 3000 over 12 months and worst months 800 monthly and May is not a worst month, therefore maybe should be 3000 monthly as the question suggests anyways
replace b26_unit_1_el=1 if pii_obs_el==53 & ApplicantID==100415 // 3000 over 2 months and worst months 2500 monthly and May is a best month (7000), therefore maybe should be 3000 monthly as the question suggests anyways
}


{ // monthly income indicators

/*
create monthly income per job in last x months

create monthly income over all non self-employment jobs over last x months

create monthly income over all self employment jobs over last x months

create monthly income over all current jobs

create monthly income most recent job

create hourly productivity 


notes/limitations: 

includes only activities for which the person was employed for at least 1 month; 

time worked is with precision of calendar month, i.e., if someone worked from mid-january in a job, income is calculated as if they worked whole january.

missing values could be more properly handled. i.e. if income is missing for one job, then total income is also somewhat missing, but here it is calculated treating missings as 0.

hours often very high. 50% reportedly work more than 45 hours/week in first job; this (among) other things makes hourly income quite low

*/


{ // income in reference periods, e.g. last 6 months (6 months is maximum based on tool)

local ref_periods 6 // any integer between 1 and 6

foreach r in `ref_periods'{
    
* generate reference period date
* precision is months, rounded to full calender months

cap drop ref_start
gen ref_start=current_month_dt_el-365/12*(`r'-1)
format ref_start %td

foreach i of num 1/3 {

*generate start date of job relevant to reference period, i.e. if before reference period started, then replace with reference period start
cap drop start_job_`i'_el
clonevar start_job_`i'_el=b4_`i'_el if b5_`i'_el>=ref_start & !missing(b3_`i'_el)
replace start_job_`i'_el=ref_start if b4_`i'_el<=ref_start & b5_`i'_el>=ref_start & !missing(b3_`i'_el)

* generate end date, replace with current date if ongoing
cap drop end_job_`i'_el
clonevar end_job_`i'_el=b5_`i'_el if b5_`i'_el>=ref_start & !missing(b3_`i'_el)
replace end_job_`i'_el=current_month_dt if b3_`i'_el==1

* time in months on job during reference period, i.e., number of calendar months(!) in job
cap drop job_time_in_ref_`i'_el
gen job_time_in_ref_`i'_el=.
replace job_time_in_ref_`i'_el=0 if !missing(b3_`i'_el)
replace job_time_in_ref_`i'_el=round((end_job_`i'_el-start_job_`i'_el)/365*12+1)
replace job_time_in_ref_`i'_el=0 if b5_`i'_el<ref_start  // important if job falls outside of reference period

* hours worked per month in job for "non-self-employed"
cap drop monthly_hours_job_`i'_el
gen monthly_hours_job_`i'_el=.
replace monthly_hours_job_`i'_el=b16_`i'_el*b15_`i'_el*4.345 if b6_`i'_el!=3

* hours worked per month in job for self-employed
replace monthly_hours_job_`i'_el=b22_`i'_el*b23_`i'_el*4.345 if b6_`i'_el==3 & !missing(b6_`i'_el) // We assume that time of oppening of the business=time worked by the owner. Once endline data is available, it will be important to check how many self-employed share ownership to assess whether this assumptions holds.



cap drop total_hours_job_`i'_el
gen total_hours_job_`i'_el=monthly_hours_job_`i'_el*job_time_in_ref_`i'_el

* generate cash income from employment
cap drop monthly_cash_job_`i'
gen monthly_cash_job_`i'_el=.
//replace monthly_cash_job_`i'=0 //if !missing(b3_`i'_el)
replace monthly_cash_job_`i'_el=b17_`i'_el //if !missing(b18_`i'_el)
replace monthly_cash_job_`i'_el=monthly_cash_job_`i'*4.345 if b17_unit_`i'_el==2 
replace monthly_cash_job_`i'_el=monthly_cash_job_`i'*4.345*b16_`i'_el if b17_unit_`i'_el==3
replace monthly_cash_job_`i'_el=monthly_cash_job_`i'/b17_unit_s_`i'_el if b17_unit_`i'_el==4 
*replace monthly_cash_job_`i'=. if b17_`i'_el==-97 | b17_`i'_el==-96// if answer cannot be used for calculation


* generate inkind income from employment
cap drop monthly_inkind_job_`i'_el
gen monthly_inkind_job_`i'_el=.
//replace monthly_inkind_job_`i'=0 if !missing(b3_`i'_el)
replace monthly_inkind_job_`i'_el=b18_`i'_el //if !missing(b18_`i'_el)
*replace monthly_inkind_job_`i'=. if b18_`i'_el==-97 | b18_`i'_el==-96// if answer cannot be used for calculation
replace monthly_inkind_job_`i'_el=monthly_inkind_job_`i'_el*4.345  if b18_unit_`i'_el==2
replace monthly_inkind_job_`i'_el=monthly_inkind_job_`i'_el*4.345 *b16_`i'_el  if b18_unit_`i'_el==3
replace monthly_inkind_job_`i'_el=monthly_inkind_job_`i'_el/b18_unit_s_`i'_el if b18_unit_`i'_el==4 

*generate monthly profits from self-employment
cap drop monthly_profit_job_`i'_el
gen monthly_profit_job_`i'_el=.
//replace monthly_profit_job_`i'=0 if !missing(b3_`i'_el)
replace monthly_profit_job_`i'_el=b26_`i'_el // if !missing(b26_`i'_el)
*replace monthly_profit_job_`i'=. if b26_`i'_el==-97 | b26_`i'_el==-96// if answer cannot be used for calculation
replace monthly_profit_job_`i'_el=monthly_profit_job_`i'*4.345  if b26_unit_`i'_el==2
replace monthly_profit_job_`i'_el=monthly_profit_job_`i'*4.345 *b16_`i'_el  if b26_unit_`i'_el==3
replace monthly_profit_job_`i'_el=monthly_profit_job_`i'/b26_unit_s_`i'_el if b26_unit_`i'_el==4 

* generate total monthly income of job (for later, not reference period)
cap drop total_monthly_`i'_el
egen total_monthly_`i'_el=rowtotal(monthly_cash_job_`i'_el monthly_inkind_job_`i'_el monthly_profit_job_`i'_el) , missing

* calculate total income by type from job during whole reference period (assuming working full calendar months)
cap drop total_cash_job_`i'_el
gen total_cash_job_`i'_el=monthly_cash_job_`i'_el*job_time_in_ref_`i'_el

cap drop total_inkind_job_`i'_el
gen total_inkind_job_`i'_el=monthly_inkind_job_`i'_el*job_time_in_ref_`i'_el

cap drop total_profit_job_`i'_el
gen total_profit_job_`i'_el=monthly_profit_job_`i'_el*job_time_in_ref_`i'_el


* hourly incomevars
cap drop hourly_income_`i'_el
gen hourly_income_`i'_el=.
replace hourly_income_`i'_el=total_monthly_`i'_el/monthly_hours_job_`i'_el
label var hourly_income_`i'_el "Average hourly income from `i'. job"
replace hourly_income_`i'_el=. if b17_`i'_el==-97 | b17_`i'_el==-96 |b18_`i'_el==-97 | b18_`i'_el==-96 //| b26_`i'_el==-97 | b26_`i'_el==-96 | // if answer cannot be used for calculation

}

* calculate total income by type during reference period
cap drop total_income_last`r'mo_el
egen total_income_last`r'mo_el=rowtotal(total_cash_job_?_el total_inkind_job_?_el total_profit_job_?_el)
replace total_income_last`r'mo_el=. if missing(b1_el)
replace total_income_last`r'mo_el=0 if b1_el==0


cap drop total_cash_last`r'mo_el
egen total_cash_last`r'mo_el=rowtotal(total_cash_job_?_el)
replace total_cash_last`r'mo_el=. if missing(b1_el)
replace total_cash_last`r'mo_el=0 if b1_el==0


cap drop total_inkind_last`r'mo_el
egen total_inkind_last`r'mo_el=rowtotal(total_inkind_job_?_el)
replace total_inkind_last`r'mo_el=. if missing(b1_el)
replace total_inkind_last`r'mo_el=0 if b1_el==0


cap drop total_profit_last`r'mo_el
egen total_profit_last`r'mo_el=rowtotal(total_profit_job_?_el)
replace total_profit_last`r'mo_el=. if missing(b1_el)
replace total_profit_last`r'mo_el=0 if b1_el==0


* calculate average monthly income by type during reference period

cap drop avg_inc_all_last`r'_el
gen avg_inc_all_last`r'_el=(total_cash_last`r'mo+total_inkind_last`r'mo+total_profit_last`r'mo)/`r'

label var avg_inc_all_last`r'_el "Average monthly income over last `r' months"

cap drop avg_inc_se_last`r'_el
gen avg_inc_se_last`r'_el=total_profit_last`r'mo/`r'

label var avg_inc_se_last`r'_el "Average monthly income from self-employment over last `r' months"

cap drop avg_inc_emp_last`r'_el
gen avg_inc_emp_last`r'_el=(total_cash_last`r'mo+total_inkind_last`r'mo)/`r'

label var avg_inc_emp_last`r'_el "Average monthly income from employment over last `r' months"

cap drop avg_inc_emp2_last`r'_el
gen avg_inc_emp2_last`r'_el=(total_cash_last`r'mo)/`r'

label var avg_inc_emp2_last`r'_el "Average monthly income from employment over last `r' months excl. inkind"


* calculate hourly_income overall last r months
cap drop total_hours_last`r'mo
egen total_hours_last`r'mo=rowtotal(total_hours_job_?_el)
replace total_hours_last`r'mo=. if missing(b1_el)
foreach i in 1 2 3{
replace total_hours_last`r'mo=. if missing(monthly_hours_job_`i') & !missing(total_monthly_`i')
*replace total_income_last`r'mo=. if b26_`i'_el==-97 | b26_`i'_el==-96 | b17_`i'_el==-97 | b17_`i'_el==-96 |b18_`i'_el==-97 | b18_`i'_el==-96 // if income information not disclosed by respondent 
}


cap drop hourly_income_last`r'_el
gen hourly_income_last`r'_el=total_income_last`r'/total_hours_last`r'

label var hourly_income_last`r' "Average hourly income over last `r' months"
}

}


*Months in employment during the last 6 months --> variable to place in employment section
cap drop job_time_el
gen job_time_el=job_time_in_ref_1
replace job_time_el= job_time_in_ref_2 if job_time_in_ref_2<job_time_el
replace job_time_el= job_time_in_ref_2 if job_time_in_ref_3<job_time_el
label var job_time_el "Months in employment in the last 6 months"


{ // income in current jobs

cap drop inc_all_current_el
gen inc_all_current_el=.
replace inc_all_current_el=0 

cap drop inc_se_current_el
gen inc_se_current_el=.
replace inc_se_current_el=0 

cap drop inc_emp_current_el
gen inc_emp_current_el=.
replace inc_emp_current_el=0

cap drop inc_emp2_current_el
gen inc_emp2_current_el=.
replace inc_emp2_current_el=0 

cap drop hours_current
gen hours_current=.
replace hours_current=0

foreach i of num 1/3{
replace inc_all_current_el=inc_all_current_el+monthly_cash_job_`i' if b3_`i'_el==1 & !missing(monthly_cash_job_`i')
replace inc_all_current_el=inc_all_current_el+monthly_inkind_job_`i' if b3_`i'_el==1 & !missing(monthly_inkind_job_`i')
replace inc_all_current_el=inc_all_current_el+monthly_profit_job_`i' if b3_`i'_el==1 & !missing(monthly_profit_job_`i')

replace inc_se_current_el=inc_se_current_el+monthly_profit_job_`i' if b3_`i'_el==1
replace inc_emp_current_el=inc_emp_current_el+monthly_cash_job_`i'+monthly_inkind_job_`i' if b3_`i'_el==1
replace inc_emp2_current_el=inc_emp2_current_el+monthly_cash_job_`i' if b3_`i'_el==1

replace hours_current=hours_current+monthly_hours_job_`i'  if b3_`i'_el==1 
}

cap drop hourly_income_current_el
gen hourly_income_current_el=.
replace hourly_income_current_el=inc_all_current_el/hours_current

label var inc_all_current_el "Monthly income from current jobs"

label var inc_se_current_el "Monthly income from current self-employment"

label var inc_emp_current_el "Monthly income from current employment"

label var inc_emp2_current_el "Monthly income from current employment excl. inkind"

label var hourly_income_current_el "Hourly income from current jobs"
}

{ // calculate average monthly income of the job with most recent starting date

cap drop inc_most_recent_el 

gen inc_most_recent_el=.
replace inc_most_recent_el=total_monthly_1 if !missing(b4_1_el) & b4_1_el<b4_2_el & b4_1_el<b4_3_el & b3_1_el==1

replace inc_most_recent_el=total_monthly_2 if !missing(b4_2_el) & b4_2_el<b4_1_el & b4_2_el<b4_3_el & b3_2_el==1

replace inc_most_recent_el=total_monthly_3 if !missing(b4_3_el) & b4_3_el<b4_2_el & b4_3_el<b4_1_el & b3_3_el==1

label var inc_most_recent_el "Average monthly income of most recent job"
}


* make missing those which are not asked about employment questions

local incomevars avg_inc_* inc_*_el hourly_income_last*

foreach var of varlist `incomevars'{
replace `var'=. if missing(b1_el) // just to be sure not to include those that are not asked this module, those asked, even if no information provided, might have 0 income

foreach i of num 1/3{
replace `var'=. if b26_`i'_el==-97 | b26_`i'_el==-96 | b17_`i'_el==-97 | b17_`i'_el==-96 |b18_`i'_el==-97 | b18_`i'_el==-96 // if income information not disclosed by respondent, make it missing
}
}



}


{ // check to clean problematic observations/inconsistencies

* problematic observations:

cap drop income_check

gen income_check=0

foreach num in 310 163 298 199 53 352 288 296 249 264 295{
replace income_check=1 if pii_obs_el==`num'
cap label define income_check_lbl 0"problematic obs regarding income" 1"OK"

}



/*
* too little profit/income
br monthly_profit_job_1 total_monthly_2 total_monthly_3 b26_1_el b26_unit_1_el b26_unit_s_1_el c3_5_el c2_el c5_5_el c4_el income_check if !missing(total_monthly_1) & !missing(c2_el) & b6_1_el==3 & monthly_profit_job_1<c2_el & income_check==0

br monthly_cash_job_1 monthly_inkind_job_1 total_monthly_2 total_monthly_3 b17_1_el b17_unit_1_el b17_unit_s_1_el b18_1_el b18_unit_1_el b18_unit_s_1_el c3_5_el c2_el c5_5_el c4_el income_check if !missing(total_monthly_1) & !missing(c2_el) & b6_1_el!=3 & total_monthly_1<c2_el & income_check==0

* too much profits
br monthly_profit_job_1 b26_1_el b26_unit_1_el b26_unit_s_1_el c3_5_el c2_el c5_5_el c4_el if !missing(total_monthly_1) & b6_1_el==3 & monthly_profit_job_1>c4_el & income_check==0

* too much income often due to daily, often ridiculous working days and hours, some however average out for the last 6 months
br monthly_cash_job_1 monthly_inkind_job_1 total_monthly_2 total_monthly_3 b17_1_el b17_unit_1_el b17_unit_s_1_el b18_1_el b18_unit_1_el b18_unit_s_1_el c3_5_el c2_el c5_5_el c4_el income_check if !missing(total_monthly_1) & !missing(c2_el) & b6_1_el!=3 & total_monthly_1>c4_el & income_check==0
*/

*Wrapping up

	*drop intermediary/helper vars
	*drop ref_start start_job_? end_job_? monthly_cash_job_? monthly_inkind_job_? monthly_profit_job_? job_time_in_ref_? total_cash_job_? total_inkind_job_? total_profit_job_? total_monthly_? total_cash_last?mo total_inkind_last?mo total_profit_last?mo monthly_hours_job_? total_hours_job_? total_hours_last?mo hours_current


	*order variables
	order job_time_el inc_all_current_el inc_se_current_el inc_emp_current_el inc_emp2_current_el inc_most_recent_el hourly_income_1_el hourly_income_2_el hourly_income_3_el hourly_income_last6_el hourly_income_current_el income_check, before (c1_el)

}

}


{ // income variation


/* list of indicators created/relevant

*Has more than one stable job during last 6 months
	mult_jobs_last6_el

* Difference in income between best and worst month
	inc_range_el

* Number of best minus worst income months times x income difference
	inc_range_weighted_el

*Average absolute deviation from median income (maximum)
	max_abs_dev_inc

*Average absolute deviation from median income (minimum)
	min_abs_dev_inc

*Annualized monthly income
	an_monthly_inc_el

*Variation and standard deviation of annualized monthly income
	var_income_el
	sd_income_el
	
*Coefficient of variation
	cv_income_el


*/

{ // version1

/*
having multiple activities

lowest level of income

income variation

income diversification


create dummy more than 1 job last 6 months (only stable jobs, i.e. those with more than 1 month)

create income in worst month (cannot be calculated consistently, we only have this for those for which income varies, about 60%, for the others we can get at most that from stable jobs, but we find, that for a considerable share they have no stable jobs)

create difference worst and best month

create dummy reportedly variation (readily from questionnaire c1_el)

create number of best - number of worst months

notes/limitations:

no difference between more than 1 job currently and more than 1 job last 6 months

hard to measure variation with only extremes as asked during interview

measures of pure variation do not distinguish between positive and negative variation.

*/

foreach i of num 1/12{
	assert !(c3_`i'_el==1 & c5_`i'_el==1)  if cycle==1
	assert !(c3_`i'_el==1 & c5_`i'_el==1) & !(c3_`i'_el==1 & c1_normal_month_`i'_el==1) & !(c1_normal_month_`i'_el==1 & c5_`i'_el==1) if (cycle==2 | cycle==3)
	*assert (c3_`i'_el==1 | c5_`i'_el==1 | c1_normal_month_`i'_el==1 | c1_el==0)  if cycle==2 & !missing(c1_el)
	
	replace c3_`i'_el=0 if c1_el==1 & missing(c3_`i'_el) 
	replace c5_`i'_el=0 if c1_el==1 & missing(c5_`i'_el) 
	replace c1_normal_month_`i'_el=0 if c1_el==1 & missing(c1_normal_month_`i'_el)
	
	* several cases for which something is neither normal, good nor bad month
	replace c1_normal_month_`i'_el=1 if c3_`i'_el==0 & c5_`i'_el==0 & c1_el==1 & (cycle==2 | cycle==3)
}

tabstat c3_*_el

tabstat c5_*_el

tabstat c1_normal_month_*_el

* dummy multiple stable jobs last 6 months
cap drop mult_jobs_last6_el
gen mult_jobs_last6_el=.
replace mult_jobs_last6_el=0 if !missing(b2_el)
replace mult_jobs_last6_el=1 if b2_el>1 & !missing(b2_el)

label var mult_jobs_last6_el "More than one stable job during last 6 months"

* difference worst and best months
cap drop inc_range_el
gen inc_range_el=.
replace inc_range_el=c4_el-c2_el
replace inc_range_el=0 if c1_el==0

label var inc_range_el "Difference in income between best and worst month"

* number of worst months

cap drop num_worst_inc num_best_inc  num_indicated_inc
egen num_worst_inc=rowtotal(c3_?_el c3_??_el)
egen num_best_inc=rowtotal(c5_?_el c5_??_el)
gen num_indicated_inc=num_best_inc+num_worst_inc

/*
Thomas: I have hard time understanding how the 2 following variables can be used. While range is quite simple and illustrative of variation:
	*The diff between number of best and good months does not say much about vulnerability/resilience without taking into account the levels of income
	*The diff between number of best and good months weighted by income range mixes two concepts that I have hard time understanding and what tangible information it can provide. for instance how do we interpret someone that has "-62800"? 
*/
cap drop diff_best_worst_inc_el
gen diff_best_worst_inc_el=num_best_inc-num_worst_inc
replace diff_best_worst_inc_el=. if missing(c1_el)
label var diff_best_worst_inc_el "Number of best minus worst income months"

cap drop inc_range_weighted_el
gen inc_range_weighted_el=diff_best_worst_inc_el*inc_range_el
label var inc_range_weighted_el "Number of best minus worst income months times income difference"

* income variation as measured by maximum average absolute deviation from median
/*
we have number best/worst months (b/w), income in best months (B/W), but not for the remaining months. Simplifying the income into three categories, best, worst, and rest (number of months: r and value:R), we then can calculate this measure from what we have.
 
Given that b and w are almost always smaller than 6 means that the median income ist R. (if b>6 then median is B and if w>6 then median is W)

We then have for average absolute deviation from median: 
1/12 (b(B-R)+w(R-W)+r(R-R)) which can be written as 1/12 b(B-W)+(w-b)(R-L)

We still need R which we do not observe, but for most observations w=b and for those it does not matter. 

Therefore I suggest to simply look at the maximum (or minimum) of this variable with respect to R, i.e. using H for R in case w>b and L for R in case b>w.

While this sounds complicated, it basically just boils down to taking the income difference between best and worse and multiplying it with 1/12*number of worst/best months, whichever is larger.
*/




cap drop max_abs_dev_inc
gen max_abs_dev_inc=.
replace max_abs_dev_inc=0 if c1_el==0
replace max_abs_dev_inc=1/12*num_worst_inc*(inc_range_el) if 6>num_worst_inc & num_worst_inc>=num_best_inc & !missing(num_worst_inc) & !missing(num_best_inc)

replace max_abs_dev_inc=1/12*num_best_inc*(inc_range_el) if num_worst_inc<=num_best_inc & num_best_inc<6 & !missing(num_worst_inc) & !missing(num_best_inc) 

replace max_abs_dev_inc=1/12*(12-num_best_inc)*(inc_range_el) if num_best_inc>6 & !missing(num_worst_inc) & !missing(num_best_inc) 
replace max_abs_dev_inc=1/12*(12-num_worst_inc)*(inc_range_el) if num_worst_inc>6 & !missing(num_worst_inc) & !missing(num_best_inc) 


cap drop min_abs_dev_inc
gen min_abs_dev_inc=.
replace min_abs_dev_inc=0 if c1_el==0

replace min_abs_dev_inc=1/12*num_best_inc*(inc_range_el) if 6>num_worst_inc & num_worst_inc>=num_best_inc & !missing(num_worst_inc) & !missing(num_best_inc)

replace min_abs_dev_inc=1/12*num_worst_inc*(inc_range_el) if num_worst_inc<=num_best_inc & num_best_inc<6 & !missing(num_worst_inc) & !missing(num_best_inc) 

replace min_abs_dev_inc=1/12*(num_worst_inc)*(inc_range_el) if num_best_inc>6 & !missing(num_worst_inc) & !missing(num_best_inc) 
replace min_abs_dev_inc=1/12*(num_best_inc)*(inc_range_el) if num_worst_inc>6 & !missing(num_worst_inc) & !missing(num_best_inc) 


*maximum and minimum differs only for 36 observations and even among those it is quite similar

label var max_abs_dev_inc "Average absolute deviation from median income (maximum)"
label var min_abs_dev_inc "Average absolute deviation from median income (minimum)"
}


*LOWEST LEVEL OF MONTHLY INCOME
cap drop lowest_monthly_inc_el
gen lowest_monthly_inc_el=.
replace lowest_monthly_inc_el=0 if b1_el==0   //  a priori, if no stable job, no income
replace lowest_monthly_inc_el=avg_inc_all_last6_el if c1_el==0  // if no variation, lowest income=avg income
replace lowest_monthly_inc_el=c2_el if c1_el==1  // ultimatelly, if declares income variation, keep c2_el
replace lowest_monthly_inc_el=. if c2_el==-97 | c2_el==-96   // if income information not disclosed by respondent, make it missing
lab var lowest_monthly_inc_el "Lowest monthly income in pat 6 months"



{/* version2 Thomas: I keep on believing that using the average income from the 3 jobs makes more sense, unless there is too many incoherences... this would be a relatively solid proxy of R and r although it only covers 6 months.
*/
* Annualized monthly income

	*setup intermediate var
	cap drop num_normal_inc
	gen num_normal_inc=.
	replace num_normal_inc=12-num_worst_inc-num_best_inc 

	cap drop c2_el2
	gen c2_el2=c2_el
	replace c2_el2=0 if c2_el== . | c2_el== .c
	
	cap drop c4_el2
	gen c4_el2=c4_el
	replace c4_el2=0 if c4_el== . | c4_el== .c

	*Generate variable
	cap drop an_monthly_inc_el
	gen an_monthly_inc_el= .
	
	replace an_monthly_inc_el= ((num_worst_inc*c2_el)+(num_best_inc*c4_el)+(num_normal_inc*avg_inc_all_last6_el))/12 if cycle==1
	replace an_monthly_inc_el=avg_inc_all_last6_el if c1_el==0 & cycle==1
	
	replace an_monthly_inc_el= ((num_worst_inc*c2_el)+(num_best_inc*c4_el)+(num_normal_inc*c1_normal_el))/12 if (cycle==2 | cycle==3)
	replace an_monthly_inc_el=c1_normal_el if c1_el==0 & (cycle==2 | cycle==3)
	
	
	label var an_monthly_inc_el "Annualized monthly employment income"

	replace an_monthly_inc_el=. if an_monthly_inc_el==-97 // if income information not disclosed by respondent, make it missing



/*
Note: for cohort 1, we assume "normal month" to be equal to average income the last 6 month as it is based on "typical earnings". This approximation shall only be done for cohort 1 as we should get the information in the next cohorts. As of now we do no correct for inconsistencies such as:
	c2_el>avg_inc_all_last6_el
	c4_el<avg_inc_all_last6_el
This said we find a very similar distribution to avg_inc_all_last6_el, which is somewhat reassuring.
*/


*Above the minimum wage among those in stable employment 

gen daily_inc_el=an_monthly_inc_el/21 //estimate 21 working days in one month


cap drop above_min_wage
gen above_min_wage= .
label var above_min_wage "Above minimum wage"
replace above_min_wage=1 if daily_inc_el>=50 & !missing(b1_el)
replace above_min_wage=0 if daily_inc_el<50 & !missing(b1_el)
label values above_min_wage bin_lbl


*Variation and standard deviation of annualized monthly income

	cap drop var_income_el
	gen var_income_el=.
	
	
	
	replace var_income_el=((c2_el-an_monthly_inc_el)^2*num_worst_inc+((c4_el-an_monthly_inc)^2*num_best_inc)+(avg_inc_all_last6_el-an_monthly_inc_el)^2*num_normal_inc)/12 if cycle==1  // Here we use normal income as income from the 3 stable jobs (at this point we didn't have a question for "normal months" in the questionnaire - this was added for cohorts 2 and 3)
	
		replace var_income_el=((c2_el-an_monthly_inc_el)^2*num_worst_inc+((c4_el-an_monthly_inc)^2*num_best_inc)+(c1_normal_el-an_monthly_inc_el)^2*num_normal_inc)/12 if cycle==2 | cycle==3 // Here we use normal income from income variation module - recommend using this formula if data is available
	
		
	replace var_income_el=0 if c1_el==0
	*For obs with c3_el or c4_el, either replace by missing or by mean/median of the sample?
		*Replace by median:
		quietly: summarize var_income_el, detail
		local med_var_income = r(p50)
		dis `med_var_income'
		foreach var in c2_el c4_el{
		replace var_income_el= `med_var_income' if `var'==-96 | `var'==-97
		}

	
	label var var_income_el "Income variance"

	cap drop sd_income_el
	gen sd_income_el= sqrt(var_income)

	label var sd_income_el "Income standard deviation"

*Coefficient of variation
	cap drop cv_income_el
	gen cv_income_el=.
	replace cv_income_el=0 if b1_el==0 // As of now, we can consider that "if no stable job, income does not vary, unless the respodnet explicitly states it does (see following condition)"
	replace cv_income_el=0 if c1_el==0 // if no income variation across the year, coefficient ==0
	replace cv_income_el= sd_income_el/an_monthly_inc_el if c1_el==1
	lab var cv_income_el "Coefficient of variation in income"


/*
Note: problematic due to missing variables as an_monthly_inc_el can be equal to 0
*/
}
*Wrapping up
	*drop intermediate var
	drop c2_el2 c4_el2 num_best_inc num_worst_inc num_normal_inc num_indicated_inc
	
	*order variables
	order mult_jobs_last6_el inc_range_el inc_range_weighted_el diff_best_worst_inc_el inc_range_weighted_el max_abs_dev_inc min_abs_dev_inc var_income_el sd_income_el cv_income_el an_monthly_inc_el, after (c4_el)

}


*IDENTIFICATION OF OUTLIERS.
*This code only identies outliers at the top of the distribution (i.e. those with the highest levels of income)
*Conceptual problem with the way you define outliers. Here it is defined as > three standard deviations removed from the mean. However the standard deviation and the mean are itself greatly influenced by potential outliers
*Consider using "extremes" command


local income_vars	an_monthly_inc_el avg_inc_all_last6_el avg_inc_se_last6_el avg_inc_emp_last6_el avg_inc_emp2_last6_el	inc_all_current_el inc_se_current_el inc_emp_current_el inc_emp2_current_el	inc_most_recent_el	hourly_income_1_el	hourly_income_2_el	hourly_income_3_el	hourly_income_last6_el	hourly_income_current_el

cap drop Z_`var' `var'_outlier


foreach var of varlist `income_vars' {
cap drop Z_`var'
cap `var'_outlier
quietly summarize `var'
gen Z_`var'= (`var' > 3*r(sd)) if `var' < .
list `var' Z_`var' if Z_`var' == 1
clonevar `var'_outlier=`var'
replace `var'_outlier= . if Z_`var'==1
}


********************************************************************************
*                          BRIEF RESILIENCE SCALE							   *			
********************************************************************************

foreach var of varlist i2_brs_el i4_brs_el i6_brs_el { // Creating a cloned variable for the "reverse" variables (i.e. those where agree is a negative) that will just be used for the BRS score
	clonevar `var'_brs_el = `var'
	recode `var'_brs_el (1=5) (2=4) (4=2) (5=1)
}

	egen brs_score_el=rowmean(i1_brs_el i2_brs_el i3_brs_el i4_brs_el i5_brs_el i6_brs_el)
	label var brs_score "Brief Resilience Scale Score"

label var i1_brs_el "I tend to bounce back quickly after hard times"
label var i2_brs_el "I have a hard time making it through stressful events*"
label var i3_brs_el "It does not take me long to recover from a stressful event"
label var i4_brs_el "It is hard for me to react positively when something bad happens*"
label var i5_brs_el "I usually come through difficult times with little trouble"
label var i6_brs_el "I tend to take a long time to get over set-backs in my life*"
*the scoring of items labelled with a * have been inversed
	
/*
create brs score (already done during field work, just double checked)
computed as just above:

create dummies for high and low resilience

notes/limitations:
based on: https://www.psytoolkit.org/survey-library/resilience-brs.html
cronbach's alpha is really low with 0.3, only values above 0.7 are considered good
*/

cap drop brs_low_el
gen brs_low_el=.
replace brs_low_el=0 if brs_score_el>=3 & !missing(brs_score_el)
replace brs_low_el=1 if brs_score_el<3 & !missing(brs_score_el)

label var brs_low_el "Low resilience (Brief Resilience Scale)"

cap drop brs_high_el
gen brs_high_el=.
replace brs_high_el=0 if brs_score_el<4.31 & !missing(brs_score_el)
replace brs_high_el=1 if brs_score_el>=4.31 & !missing(brs_score_el)

label var brs_high_el "High resilience (Brief Resilience Scale)"

alpha i?_brs_el, item

*Wrapping up

	*order variables
	order brs_score_el brs_low_el brs_high_el, after (i6_brs_el)


********************************************************************************
*						PROFESSIONAL PRACTICES									*
********************************************************************************
{ // PROFESSIONAL PRACTICES
/* notes

vars generated

	bus_prac_plan
	bus_prac_all
	bus_prac_sem
	bus_prac_intern_el
	bus_prac_extern_el
	
	
*background
professional practices score based on module H
probably derived from de mel et al 2014 Business Training and Female Enterprise Start-up, Growth, and Dynamics
https://openknowledge.worldbank.org/bitstream/handle/10986/11998/WPS6145.pdf?sequence=1&isAllowed=y
simple additive score
note Financial planning questions were asked to the whole sample (Regular employee and Self employed) while professional practice questions were asked only to self-employed, thus the different sample size. Financial planninig ->299 observ. Professional practices -> 99 observ.
*/

{ // generate scores

***Financial Planning (complete sample)

clonevar fin_record_el=h2_el
replace fin_record_el=1 if fin_record_el==2
label var fin_record_el "Keeps written financial records (simple or detailed notes)" 
label values fin_record_el bin_lbl

clonevar goal_year_el=h4_el
label var goal_year_el "Has a concrete goal for next year"

clonevar anticip_invest_el=h5_el
label var anticip_invest_el "Anticipates investments of the coming year"

clonevar check_target_el=h6_el
label var check_target_el "Check whether targets have been achieved (frequency: 0-3)"

clonevar h6bis_el= h6_el
replace h6bis_el=1 if h6_el==1 | h6_el==2 | h6_el==3

 
gen fin_plan_el = fin_record_el + h4_el + h5_el + h6bis_el
label var fin_plan_el "Basic financial planning (0-4)"


****Self employed professional practices (only self-employed)
clonevar pers_pro_el=h1_el
label var pers_pro_el "Seperates professional and personal cash"

clonevar visit_comp_el=h7_el
label var visit_comp_el "Visited competitor's business in the past 6 month'"

clonevar supply_comp_el=h8_el
label var supply_comp_el "Adapted supply according to competitors in the past 6 month"

clonevar disc_client=h9_el
label var disc_client "Discussed with a client how to answer needs in the past 6 month"

clonevar disc_suppl=h10_el
label var disc_suppl "Asked supplier about products selling well in the past 6 month"

clonevar advert_el=h11_el
label var advert_el "Has advertised his business/goods/services in the past 6 month"

clonevar goods_profit_el=h12_el
label var goods_profit_el "Know which goods/services make the most profit"

clonevar records_an_el=h13_el
label var records_an_el "Uses records to analyse performances of products (0-4)"

clonevar h13bis_el= h13_el
replace h13bis_el=1 if h13_el==1 | h13_el==2 | h13_el==3

*Composite score of Self employed professional practices
gen bus_prac_el = h1_el + h7_el + h8_el + h9_el + h10_el + h11_el + h12_el + h13bis_el
label var bus_prac_el "Business practices [Self employed] (0-8)"

// Alternative suggestion (Thomas)

*Internal management (only for entrepreneurs)
gen bus_prac_intern_el= h1_el+h2_el+h4_el+h5_el+h6_el+h12_el+h13_el
label var bus_prac_intern_el "Internal management practices score [Self employed] (0-12)"
//replace intern_manag_self= . if self_employed==0

*External management (only for entrepreneurs)
gen bus_prac_extern_el= h7_el+h8_el+h9_el+h10_el+h11_el+h12_el
label var bus_prac_intern_el "External management practices score [Self employed] (0-5)"
//replace intern_manag_self= . if self_employed==0
}


}


********************************************************************************
*						Entrepreneurial spirit									*
********************************************************************************
{ // entrepreneurial spirit

/* notes
vars generated

	entrep_spirit

background

Treatment 2 observation have been selected based on their motivation to start/develop a business (i.e. they are different from those in treatment 1 and control)
The variables were introduced in the Qx to control for potential difference before the treatment and support the matching procedure.
Questions intend to collect information on entrepreneurial spirit retrospectively

Notes/Limits:

non of the items predicts treatment status.

*/


describe g6_el g7_el g8_el g10_el 

label var g6_el "When younger, involved in organising social projects"
label var g7_el "When younger, candidate for class prefect/other"
label var g8_el "When younger, regularly organize events with the family or friends"
label var g10_el "When younger, ever tried to open a business"

*Entrepreneurial spirit score (simple addition of items)
gen entrep_spirit_el=g6_el+g7_el+g8_el+g10_el
label var entrep_spirit_el "Entrepreneurial spirit score [0-4]}"
}




********************************************************************************
*						Job matches											*
********************************************************************************
{ // job matches tvet skills all jobs

/*

-	Has job (*1 month in the past 6 months*) in a branch related to trade

notes/limitations:

Fro cycle 1 we tried to it base on the ISIC.
ISIC 2 codes often to crude. Matching based on name sometimes ambigous, how exact should match be? Maybe outsource double checking or hand matching in future? 
*/

{ // ISIC second level codes and trades list

/* ISIC_2
ISIC_2	101	Crop and animal production, hunting and related service activities
ISIC_2	102	Forestry and logging
ISIC_2	103	Fishing and aquaculture
ISIC_2	205	Mining of coal and lignite
ISIC_2	206	Extraction of crude petroleum and natural gas
ISIC_2	207	Mining of metal ores
ISIC_2	208	Other mining and quarrying
ISIC_2	209	Mining support service activities
ISIC_2	310	Manufacture of food products
ISIC_2	311	Manufacture of beverages
ISIC_2	312	Manufacture of tobacco products
ISIC_2	313	Manufacture of textiles
ISIC_2	314	Manufacture of wearing apparel
ISIC_2	315	Manufacture of leather and related products
ISIC_2	316	Manufacture of wood and of products of wood and cork, except furniture; manufacture of articles of straw and plaiting materials
ISIC_2	317	Manufacture of paper and paper products
ISIC_2	318	Printing and reproduction of recorded media
ISIC_2	319	Manufacture of coke and refined petroleum products
ISIC_2	320	Manufacture of chemicals and chemical products
ISIC_2	321	Manufacture of basic pharmaceutical products and pharmaceutical preparations
ISIC_2	322	Manufacture of rubber and plastics products
ISIC_2	323	Manufacture of other non-metallic mineral products
ISIC_2	324	Manufacture of basic metals
ISIC_2	325	Manufacture of fabricated metal products, except machinery and equipment
ISIC_2	326	Manufacture of computer, electronic and optical products
ISIC_2	327	Manufacture of electrical equipment
ISIC_2	328	Manufacture of machinery and equipment n.e.c.
ISIC_2	329	Manufacture of motor vehicles, trailers and semi-trailers
ISIC_2	330	Manufacture of other transport equipment
ISIC_2	331	Manufacture of furniture
ISIC_2	332	Other manufacturing
ISIC_2	333	Repair and installation of machinery and equipment
ISIC_2	435	Electricity, gas, steam and air conditioning supply
ISIC_2	536	Water collection, treatment and supply
ISIC_2	537	Sewerage
ISIC_2	538	Waste collection, treatment and disposal activities; materials recovery
ISIC_2	539	Remediation activities and other waste management services
ISIC_2	641	Construction of buildings
ISIC_2	642	Civil engineering
ISIC_2	643	Specialized construction activities
ISIC_2	745	Wholesale and retail trade and repair of motor vehicles and motorcycles
ISIC_2	746	Wholesale trade, except of motor vehicles and motorcycles
ISIC_2	747	Retail trade, except of motor vehicles and motorcycles
ISIC_2	849	Land transport and transport via pipelines
ISIC_2	850	Water transport
ISIC_2	851	Air transport
ISIC_2	852	Warehousing and support activities for transportation
ISIC_2	853	Postal and courier activities
ISIC_2	955	Accommodation
ISIC_2	956	Food and beverage service activities
ISIC_2	1058	Publishing activities
ISIC_2	1059	Motion picture, video and television programme production, sound recording and music publishing activities
ISIC_2	1060	Programming and broadcasting activities
ISIC_2	1061	Telecommunications
ISIC_2	1062	Computer programming, consultancy and related activities
ISIC_2	1063	Information service activities
ISIC_2	1164	Financial service activities, except insurance and pension funding
ISIC_2	1165	Insurance, reinsurance and pension funding, except compulsory social security
ISIC_2	1166	Activities auxiliary to financial service and insurance activities
ISIC_2	1268	Real estate activities
ISIC_2	1369	Legal and accounting activities
ISIC_2	1370	Activities of head offices; management consultancy activities
ISIC_2	1371	Architectural and engineering activities; technical testing and analysis
ISIC_2	1372	Scientific research and development
ISIC_2	1373	Advertising and market research
ISIC_2	1374	Other professional, scientific and technical activities
ISIC_2	1375	Veterinary activities
ISIC_2	1477	Rental and leasing activities
ISIC_2	1478	Employment activities
ISIC_2	1479	Travel agency, tour operator, reservation service and related activities
ISIC_2	1480	Security and investigation activities
ISIC_2	1481	Services to buildings and landscape activities
ISIC_2	1482	Office administrative, office support and other business support activities
ISIC_2	1584	Public administration and defence; compulsory social security
ISIC_2	1685	Education
ISIC_2	1786	Human health activities
ISIC_2	1787	Residential care activities
ISIC_2	1788	Social work activities without accommodation
ISIC_2	1890	Creative, arts and entertainment activities
ISIC_2	1891	Libraries, archives, museums and other cultural activities
ISIC_2	1892	Gambling and betting activities
ISIC_2	1893	Sports activities and amusement and recreation activities
ISIC_2	1994	Activities of membership organizations
ISIC_2	1995	Repair of computers and personal and household goods
ISIC_2	1996	Other personal service activities
ISIC_2	2097	Activities of households as employers of domestic personnel
ISIC_2	2098	Undifferentiated goods- and services-producing activities of private households for own use
ISIC_2	2199	Activities of extraterritorial organizations and bodies

For cycles 2 and 3 we directly ask whether the job is related to the trades available

"BLOCK LAYING"
"GARMENT MAKING"
"HAIR DRESSING"
"HAIR DRESSING & BEAUTY THERAPY"
"SATELLITE INSTALLATION"
"SOLAR INSTALLATION"
"TILING AND PLASTERING"
*/

}


* match based on isic code for cycle 1
cap drop job_trade_match_el
gen job_trade_match_el=0

foreach var in isic_2_1_el isic_2_2_el isic_2_3_el isic_2_seven_el{
replace job_trade_match_el=1 if (trade_area_applied=="BLOCK LAYING" | trade_area_applied=="TILING AND PLASTERING")  & (`var'==641 | `var'==642 | `var'==643) & cycle==1
replace job_trade_match_el=1 if trade_area_applied=="GARMENT MAKING" & (`var'==313 | `var'==314 | `var'==315 | `var'==747) & cycle==1
replace job_trade_match_el=1 if (trade_area_applied=="HAIR DRESSING" | trade_area_applied=="HAIR DRESSING & BEAUTY THERAPY") & (`var'==1996 | `var'==2098) & cycle==1
replace job_trade_match_el=1 if (trade_area_applied=="SATELLITE INSTALLATION" | trade_area_applied=="SOLAR INSTALLATION") & (`var'==333 | `var'==435) & cycle==1
}

replace job_trade_match_el=. if missing(b1_el) & cycle==1
replace job_trade_match_el=. if missing(trade_area_applied) & cycle==1
replace job_trade_match_el=. if cycle==2
replace job_trade_match_el=. if cycle==3


*Match based on trade_applied

recode trade_applied (1 = .) (2 = 8) (3 = 1) (4 = 6) (5 = 7) (6 = 9) (7 = 4) (8 = 5) (9= 2) (10 = 3), gen(trade_applied_rec)
label var trade_applied_rec "Trade applied"

replace job_trade_match_el=0 if cycle==2 | cycle==3	 
replace job_trade_match_el=1 if (job_category_1_el==trade_applied_rec | job_category_2_el==trade_applied_rec | job_category_3_el==trade_applied_rec) & (cycle==2 | cycle==3) 


label var job_trade_match_el "Job last 6 months that matches applied trade area based on ISIC code"

/*
* match based on job name
cap drop job_trade_match_name_el
gen job_trade_match_name_el=0 if cycle==1

foreach var in job_name_1_el job_name_2_el job_name_3_el{
replace job_trade_match_name_el=1 if (trade_area_applied=="BLOCK LAYING" | trade_area_applied=="TILING AND PLASTERING")  & regexm(`var',"CONSTRUCT") & cycle==1

replace job_trade_match_name_el=1 if (trade_area_applied=="TILING AND PLASTERING")  & (regexm(`var',"PLASTERING")) & cycle==1

replace job_trade_match_name_el=1 if (trade_area_applied=="BLOCK LAYING")  & (regexm(`var',"LAYING")) & cycle==1

replace job_trade_match_name_el=1 if trade_area_applied=="GARMENT MAKING" & (regexm(`var',"TAILOR")) & cycle==1

replace job_trade_match_name_el=1 if (trade_area_applied=="HAIR DRESSING" | trade_area_applied=="HAIR DRESSING & BEAUTY THERAPY") & (regexm(`var',"HAIR") | regexm(`var',"BEAUTY") | regexm(`var',"COSMETIC") | regexm(`var',"MARK-") | regexm(`var',"BARBER") | regexm(`var',"SALOON")) & cycle==1 // MARK- UP likely make up


replace job_trade_match_name_el=1 if trade_area_applied=="SATELLITE INSTALLATION"  & (regexm(`var', "SATELLITE")) & cycle==1

replace job_trade_match_name_el=1 if trade_area_applied=="SOLAR INSTALLATION" & (regexm(`var', "SOLAR")) & cycle==1

replace job_trade_match_name_el=1 if (trade_area_applied=="SOLAR INSTALLATION" | trade_area_applied=="SATELLITE INSTALLATION") & (regexm(`var', "ELECTR")) & cycle==1 // should we include this? 


replace job_trade_match_isic_el=1 if (trade_area_applied=="BLOCK LAYING" | trade_area_applied=="TILING AND PLASTERING")  & (`var'==641 | `var'==642 | `var'==643) & cycle==1



}

replace job_trade_match_name_el=. if missing(job_name_1_el) &  missing(job_name_2_el) & missing(job_name_3_el) 
replace job_trade_match_name_el=. if missing(trade_area_applied)

label var job_trade_match_name_el "Job last 6 months that matches applied trade area based on description"
*/



}





********************************************************************************
*						Job search behavior									*
********************************************************************************

{ // job seeker and search intensity
/* indicators relevant/created

job_seeker job_search_intens job_search_intens_prep job_search_intens_act job_search_intens2 

d5a_el d5b_el d5e_el (looking for work in district, outside district, outside gambia respectively)

d8_el (job offers)

*Discussion points: Two possible definitions of job seeker
job seeker: Anyone who is actively seeking employment

job_seeker: Anyone who is UNEMPLOYED and searching for a job or trying to start a business or both searching for a job and trying to start a business


*/



* is the person a job seeker?
cap drop job_seeker
gen job_seeker=.
replace job_seeker=0 if !missing(d1_el)
replace job_seeker=1 if d1_el==1 & b1_el == 0 & b32_el == 0  | d1_el==3 & b1_el == 0 & b32_el == 0  | d1_el == 2 & b1_el == 0 & b32_el == 0

label var job_seeker "Is job seeker"

cap drop job_seeker_all
gen job_seeker_all=.
replace job_seeker_all=0 if !missing(d1_el)
replace job_seeker_all=1 if d1_el==1  | d1_el==3   | d1_el == 2 & b1_el == 0 & b32_el == 0

label var job_seeker "Is job seeker [Total Sample]"

* search intensity (if searching)
cap drop job_search_intens
egen job_search_intens=rowmean(d3?_el d4?_el)
replace job_search_intens=. if job_seeker==0 | missing(job_seeker)

label var job_search_intens "Share of job search related activities"

cap drop job_search_intens_prep
egen job_search_intens_prep=rowmean(d3?_el)
replace job_search_intens_prep=. if job_seeker==0 | missing(job_seeker)

label var job_search_intens_prep "Share of prepatory job search related activities"


cap drop job_search_intens_act
egen job_search_intens_act=rowmean(d4?_el)
replace job_search_intens_act=. if job_seeker==0 | missing(job_seeker)

label var job_search_intens_prep "Share of active job search related activities"

cap drop job_search_intens2
gen job_search_intens2=0

foreach var in d3a_el d3b_el d3d_el d3e_el d3f_el d4b_el d4c_el d4d_el d4f_el{
	summ `var'
	cap drop helper
	di `r(mean)'
	gen helper=(`var'-`r(mean)')/`r(sd)'/9
	replace job_search_intens2=job_search_intens2+helper
	drop helper
}

label var job_search_intens "Index based on job search related activities" // this give different weight to different activities 


}




** training quality type questions

/*

generated vars

train_attend train_attend_formal tekkifii_attend tekkifii_bus_attend tekkifii_ind_attend tf_*_qual


Notes:
basically all training attended is categorized as formal
completion not available for tekki fii from survey
in principle I guess all/many of the K-module variables can be looked at descriptively/qualitatively e.g. absenteeism (reasons: K12, K14),
quality measures almost always at the top of the scale (4 or 5 of 5), thus little to no information


*/

*training attendance (treat and control)
cap drop train_attend
gen train_attend=.
replace train_attend=j1a_el if treatment_group==0
replace train_attend=0 if treatment_group==1 & !missing(j1b_el)
replace train_attend=1 if j1b_el==1 | tekkifii_check_el==1

label var train_attend "Attended job training since January 2020 (Tekki fii or other)"

cap drop train_attend_formal
gen train_attend_formal=train_attend
replace train_attend_formal=0 if treatment_group==0 & j3_el==2
replace train_attend_formal=0 if treatment_group==1 & j3_el==2 & tekkifii_check_el==0

label var train_attend_formal "Attended (formal) job training since January 2020 (Tekki fii or other)"

*component attendance tekkifii

cap drop tekkifii_attend
gen tekkifii_attend=.
replace tekkifii_attend=tekkifii_check_el
replace tekkifii_attend=2 if tekkifii_check_ind_el==1
replace tekkifii_attend=3 if k18_el==1
replace tekkifii_attend=4 if k18_el==1 & tekkifii_check_ind_el==1

cap label define tekkifii_attend_lbl 0 "No attendance" 1 "Any tekki fii training" 2 "Industrial placement" 3 "Business development" 4 "All components"

label values tekkifii_attend tekkifii_attend_lbl

label var tekkifii_attend "Tekki fii attendance by components"

cap drop tekkifii_ind_attend
gen tekkifii_ind_attend= tekkifii_attend==2 | tekkifii_attend==4
replace tekkifii_ind_attend=. if missing(tekkifii_attend)

cap drop tekkifii_bus_attend
gen tekkifii_bus_attend= tekkifii_attend==3 | tekkifii_attend==4
replace tekkifii_bus_attend=. if missing(tekkifii_attend)

label var tekkifii_ind_attend "Attended Tekki fii industrial placement"
label var tekkifii_bus_attend "Attended Tekki fii business development"

*ABSENTEEISM

*Training absenteeism



**These option were not selected, so need to create variable
cap gen k12_4_el=. 
replace k12_4_el=0 if k11_el==1 & cycle==1
cap gen k12_6_el=. 
replace k12_6_el=0 if k11_el==1 & cycle==1
order k12_4_el, after (k12_3_el)
order k12_6_el, after (k12_5_el)


foreach var of varlist k12_1_el-k12_7_el {
replace `var'=0 if k11_el==1 & `var'!=1
}

label variable k11_el "Missed at least one training day"
cap label variable k12_1_el "Reasons for Tekki Fii absenteeism [Illness]"
cap label variable k12_2_el "Reasons for Tekki Fii absenteeism [Household obligations]"
cap label variable k12_3_el "Reasons for Tekki Fii absenteeism [Economic obligations]"
cap label variable k12_4_el "Reasons for Tekki Fii absenteeism [Lack of childcare]"
cap label variable k12_5_el "Reasons for Tekki Fii absenteeism [Lack of money to travel]" //To confirm with Eli and Nathan
cap label variable k12_6_el "Reasons for Tekki Fii absenteeism [Covid Lockdown]"   //To confirm with Eli and Nathan
cap label variable k12_7_el "Reasons for Tekki Fii absenteeism [Climate conditions]" //To confirm with Eli and Nathan

*Industrial placement absenteeism

**These option were not selected, so need to create variable
cap gen k14_4_el=. 
replace k14_4_el=0 if k13_el==1 & cycle==1
cap gen k14_7_el=. 
replace k14_7_el=0 if k13_el==1 & cycle==1
order k14_4_el, after (k14_3_el)
order k14_7_el, after (k14_6_el)


foreach var of varlist k14_1_el-k14_7_el {
cap replace `var'=0 if k13_el==1 & `var'!=1
}

label variable k13_el "Missed at leat one indutrial placement"
cap label variable k14_1_el "Reasons for industrial placement absenteeism [Illness]"
cap label variable k14_2_el "Reasons for industrial placement absenteeism [Household obligations]"
cap label variable k14_3_el "Reasons for industrial placement absenteeism [Economic obligations]"
cap label variable k14_4_el "Reasons for industrial placement absenteeism [Lack of childcare]"
cap label variable k14_5_el "Reasons for industrial placement absenteeism [Lack of money to travel]" //To confirm with Eli and Nathan
cap label variable k14_6_el "Reasons for industrial placement absenteeism [Covid Lockdown]" //To confirm with Eli and Nathan
cap label variable k14_7_el "Reasons for industrial placement absenteeism [Climate conditions]" //To confirm with Eli and Nathan




* training quality

label variable k1_el "Teaching methods of teachers"
label variable k2_el "Teachers' ability to handle training equipment"
label variable k4_el "Teachers ability to engage students"
label variable k5_el "Quality of TVET facilities"

label variable k6_el "Assessment to obtain relevant skills"
label variable k8_el "Assessment to improve team work skills"
label variable k9_el "Assessment to improve skills to work independently"
label variable k10_el "Assessment to improve self expression"

cap drop tf_teacher_qual
egen tf_teacher_qual=rowmean(k1_el k2_el k4_el)
replace tf_teacher_qual=. if missing(k1_el) | missing(k2_el) | missing(k4_el)

label var tf_teacher_qual "Quality of Tekki fii teaching (1=very bad; 5=excellent)"

cap drop tf_centre_qual
gen tf_centre_qual=k5_el

label var tf_centre_qual "Quality of Tekki fii centre (1=very bad; 5=excellent)"

cap drop tf_skills_qual
egen tf_skills_qual=rowmean(k6_el k8_el k9_el k10_el)
replace tf_skills_qual=. if missing(k6_el) | missing(k8_el) | missing(k9_el)  | missing(k10_el)

label var tf_skills_qual "Tekki fii develops skills (1=very bad; 5=excellent)"

cap drop tf_ind_qual
egen tf_ind_qual=rowmean(k15_el k16_el)
replace tf_ind_qual=. if missing(k15_el) | missing(k16_el) 

label var tf_ind_qual "Tekki fii industrial placement usefuleness (1=very bad; 5=excellent)"


/*
foreach var of `generatedvars'{
rename `var' `var'_el
}
*/

label variable k16_el "Usefulness work experience for career development"
label variable k17_el "Was Offered a job at company of industrial placement"

label variable k18_el "Participation in BD component"
label variable k16_el "Usefulness work experience for career development"
label variable k16_el "Usefulness work experience for career development"


********************************************************************************
* SAVE MERGED_ANALYSIS
********************************************************************************

save "$data_path\CLEANED_DATA.dta", replace

********************************************************************************
* EXIT CODE
********************************************************************************

n: di "${proj}_${tool}_Clean_Data ran successfully"
*}
