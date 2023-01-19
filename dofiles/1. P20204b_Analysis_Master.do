quietly {

** EUTF/GIZ Tekki Fii Evaluation
** Youth Survey
* Nathan Sivewright July 2021

// This do-file is the Master do-file for the anaylsis. It first sets up the macros
// to allow collaboration runs the 
// do-files that take the data from export to clean. It then outputs a progress report
// and runs data quality checks

clear all

// General Globals
global ONEDRIVE "C:\Users\/`c(username)'\C4ED"
global version = 1
global date = string(date("`c(current_date)'","DMY"),"%tdNNDD")
global time = string(clock("`c(current_time)'","hms"),"%tcHHMMSS")
global datetime = "$date"+"$time"

// General Globals
global ONEDRIVE "C:\Users\/`c(username)'\C4ED"


/*
if "`c(username)'"=="ThomasEekhout" | "`c(username)'"=="NathanSivewright" {
global P20204i "$ONEDRIVE\P20204i_EUTF_UGA - Documents" 
}
else{
global P20204i "$ONEDRIVE\P20204i_EUTF_UGA - Dokumente"
}
*/

if "`c(username)'" == "Personal" {
	global ONEDRIVE "C:\Users\/Personal\C4ED\"
	global dofiles "C:\Users\Personal\OneDrive - C4ED\Documents\GitHub\P20204b_GMB_Analysis\dofiles"
}

if "`c(username)'"=="NathanSivewright" { 
	global timezone = 1
global dofiles "C:\Users\/`c(username)'\Documents\GitHub\PP20204i_GMB_Analysis\dofiles"
}

if "`c(username)'"=="ThomasEekhout" { 
	global timezone = 1
global dofiles "C:\Users\/`c(username)'\Downloads\GitHub\P20204i_GMB_Analysis\dofiles"
}

if "`c(username)'"=="ElikplimAtsiatorme" {
	global timezone = 1
global dofiles "C:\Users\/`c(username)'\Documents\GitHub\P20204i_GMB_Analysis\dofiles"
}




// Round > Cycle > Tool Globals
global proj "P20204b"
global round "Endline"
*global cycle "C1B1"
global tool "Youth"
global data_path "$ONEDRIVE\P20204b_EUTF_GMB - Documents\02_Analysis\02_Data"
*global path_mc1 "$ONEDRIVE\P20204b_EUTF_GMB - Documents\02_Analysis\02_Data\/Midline\/C1B1\/Youth\"
*global field_mc1 "$ONEDRIVE\P20204b_EUTF_GMB - Documents\02_Analysis\04_Raw_Data\Midline\C1B1\Youth\cleaning\"

global encrypted_drive_s "A"
global encrypted_path_s "$encrypted_drive_s:"

****$di_data refers to de-identified data. Recommended to use this data for analysis
global di_data1 "$ONEDRIVE\P20204b_EUTF_GMB - Documents\02_Analysis\02_Data\Endline\C1\Youth\data_an.dta"
global di_data2 "$ONEDRIVE\P20204b_EUTF_GMB - Documents\02_Analysis\02_Data\Endline\C2\Youth\Tekki_Fii_PV_5_NoPII.dta"
*global di_data3 "$ONEDRIVE\P20204b_EUTF_GMB - Documents\02_Analysis\02_Data\Endline\C3\Youth\Tekki_fii_PV_3_Final_NoPII.dta"


global dofiles "$ONEDRIVE\P20204b_EUTF_GMB - Documents\02_Analysis\01_DoFiles\Analysis"

** Baseline data to merge
global bl_data  "$ONEDRIVE\P20204b_EUTF_GMB - Documents\02_Analysis\04_Raw_Data\Baseline\Cleaned Merge\"
global ml_data "$ONEDRIVE\P20204b_EUTF_GMB - Documents\02_Analysis\02_Data\"

**Data for analysis
*global CLEAN_DATA "$data_path\CLEANED_DATA.dta"
*global CLEAN_DATA "$data_path\CLEANED_DATA_clem.dta"


n: di "Hi `c(username)'!"
cd "$dofiles"


* outputs directory
*global outputs "$ONEDRIVE\P20204b_EUTF_GMB - Documents\02_Analysis\03_Tables_Graphs\"


/* INSTALL REQUIRED PACKAGES HERE
quietly{
* REQUIRED: the 'rtfutil' package; commands 'distinct' and 'unique'
foreach package in estout labutil rtfutil rtfopen distinct unique {
	cap which `package'
	if _rc ssc install `package', replace
	}
}

*pca `vars'
*screeplot
*scoreplot

* INSTALL COMMANDS
net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
set scheme cleanplots, perm

net install palettes, replace from("https://raw.githubusercontent.com/benjann/palettes/master/")
net install colrspace, replace from("https://raw.githubusercontent.com/benjann/colrspace/master/")

 ssc install psmatch2, replace
 
 ssc extremes 
*/

}



******************************************
** 1. ANALYSIS PREPARATION
******************************************
do "1.1. ${proj}_Analysis_Merge.do" // Merge together Rounds and Cycles
cd "$dofiles"
*do "1.2. ${proj}_Analysis_Preparation.do"
cd "$dofiles"
*do "99_maketable_PROGRAM.do"
cd "$dofiles"
*do "1.3. ${proj}_Analysis_Globals.do"
cd "$dofiles"


******************************************
** 2. REGRESSIONS - WIP
******************************************


*Data with results' outputs
*global Results "$data_path\99_results\Estimation results.dta"

*Path for result tables (store in excel file)
*global outputs_regressions "$outputs\03_Regressions\Estimation_results.xlsx"



cd "$dofiles"
*do "2.1 P20204b_Regressions-WIP_clem.do"
cd "$dofiles"



******************************************
** 2. ANALYSIS OUTPUT
******************************************
* Automatic numbering of tables
*global tablenum = 0 // this should go before all the dofiles using maketable for tables, not sure however if we want this




di "Master Do File Ran Fully!"