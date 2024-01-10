 /*******************************************************************************

			               Task:  Regression Tables
							
			      - Module F: Agriculture, Plots, Revenue
						  
				By:           HR
				Last updated: 31Aug2023
						  
      ----------------------------------------------------------  
		
	*Notes:
     1) Create baseline controls variables for food security indicators
	 2) Sanity checks, cleanups etc.
	 3) Baseline Controls
	 4) Tidying up
	 5) Lasso Controls mechanism
	 6) Running Regression
	 7) Exporting regression output 

*******************************************************************************/


* 0. Preamble 


* 1. Use cleaned dataset  
    clear all
    u "${high_frequency_ds}/final/analysis_panel.dta", clear
		

* 2. Cleaning + subsetting relevant variables and rounds only i.e Endline and Baseline
	
    * Variables needed for agri regressions
     keep hhid level1 round_pooled treatment fixed_var cluster_var ///
	 hasplots both_crop wet_crop dry_crop total_sales_rev ///
	 wet_sales_rev dry_sales_rev fertizer_use_d pyhto_use_d ///
	 paid_labor_d tpaid_labor_d poverty_class village_type  iv_var hf_sample ///
	 r_crop_1 r_crop_8 r_crop_2 r_crop_13 r_crop_10 r_crop_37 r_crop_4 ///							//share of crops
	 total_plot_area plot_hectares_crop_1 plot_hectares_crop_8 plot_hectares_crop_2 ///
	 plot_hectares_crop_13 plot_hectares_crop_10 plot_hectares_crop_37 plot_hectares_crop_4 ///		//plot area in hectares
	 plot_hec_1_w99 plot_hec_1_w98 plot_hec_1_w95 plot_hec_8_w99 plot_hec_8_w98 plot_hec_8_w95 plot_hec_2_w99 ///
	 plot_hec_2_w98 plot_hec_2_w95 plot_hec_13_w99 plot_hec_13_w98 plot_hec_13_w95 plot_hec_10_w99 ///
	 plot_hec_10_w98 plot_hec_10_w95 plot_hec_37_w99 plot_hec_37_w98 plot_hec_37_w95 plot_hec_4_w99 ///
	 plot_hec_4_w98 plot_hec_4_w95 totplot_hec_w99 totplot_hec_w98 totplot_hec_w95 totplot_hec ///
	 sale_amount_crop_1 sale_crp_1_w99 sale_crp_1_w98 sale_crp_1_w95 sale_amount_crop_8 ///			//value of sales raw and winsorized
	 sale_crp_8_w99 sale_crp_8_w98 sale_crp_8_w95 sale_amount_crop_2 sale_crp_2_w99 ///
	 sale_crp_2_w98 sale_crp_2_w95 sale_amount_crop_13 sale_crp_13_w99 sale_crp_13_w98 ///
	 sale_crp_13_w95 sale_amount_crop_10 sale_crp_10_w99 sale_crp_10_w98 sale_crp_10_w95 ///
	 sale_amount_crop_37 sale_crp_37_w99 sale_crp_37_w98 sale_crp_37_w95 sale_amount_crop_4 ///
	 sale_crp_4_w99 sale_crp_4_w98 sale_crp_4_w95 total_sales totsale_stp totsale_nstp ///
	 tot_sale_w99 totsale_stp_w99 totsale_nstp_w99 tot_sale_w98 totsale_stp_w98 ///
	 totsale_nstp_w98 tot_sale_w95 totsale_stp_w95 totsale_nstp_w95 ///
	 harvest_q_crop_1 harv_q_crop_1_w99 harv_q_crop_1_w98 harv_q_crop_1_w95 harvest_q_crop_8 ///	//quantity harvested raw and winsorized
	 harv_q_crop_8_w99 harv_q_crop_8_w98 harv_q_crop_8_w95 harvest_q_crop_2 harv_q_crop_2_w99 ///
	 harv_q_crop_2_w98 harv_q_crop_2_w95 harvest_q_crop_13 harv_q_crop_13_w99 harv_q_crop_13_w98 ///
	 harv_q_crop_13_w95 harvest_q_crop_10 harv_q_crop_10_w99 harv_q_crop_10_w98 harv_q_crop_10_w95 ///
	 harvest_q_crop_37 harv_q_crop_37_w99 harv_q_crop_37_w98 harv_q_crop_37_w95 harvest_q_crop_4 ///
	 harv_q_crop_4_w99 harv_q_crop_4_w98 harv_q_crop_4_w95 total_harvest_q tot_harv_stp ///
	 tot_harv_nstp total_harv_w99 tot_harv_stp_w99 tot_harv_nstp_w99 total_harv_w98 ///
	 tot_harv_stp_w98 tot_harv_nstp_w98 total_harv_w95 tot_harv_stp_w95 tot_harv_nstp_w95 ///
	 sale_q_crop_1 sale_q_crp_1_w99 sale_q_crp_1_w98 sale_q_crp_1_w95 sale_q_crop_8 sale_q_crp_8_w99 ///	//quantity sold raw and winsorized
	 sale_q_crp_8_w98 sale_q_crp_8_w95 sale_q_crop_2 sale_q_crp_2_w99 sale_q_crp_2_w98 sale_q_crp_2_w95 ///
	 sale_q_crop_13 sale_q_crp_13_w99 sale_q_crp_13_w98 sale_q_crp_13_w95 sale_q_crop_10 sale_q_crp_10_w99 ///
	 sale_q_crp_10_w98 sale_q_crp_10_w95 sale_q_crop_37 sale_q_crp_37_w99 sale_q_crp_37_w98 sale_q_crp_37_w95 ///
	 sale_q_crop_4 sale_q_crp_4_w99 sale_q_crp_4_w98 sale_q_crp_4_w95 total_sale_q totsale_q_stp ///
	 totsale_q_nstp tot_sale_q_w99 totsale_q_stp_w99 totsale_q_nstp_w99 tot_sale_q_w98 ///
	 totsale_q_stp_w98 totsale_q_nstp_w98 tot_sale_q_w95 totsale_q_stp_w95 totsale_q_nstp_w95 ///
	 sold_crop_1 sold_crop_8 sold_crop_2 sold_crop_13 sold_crop_10 sold_crop_37 sold_crop_4 sold_staple_crop sold_nstaple_crop sold_crop ///		//share of hhld selling a given crop
	 prod_value_crop_1 prod_value_crop_8 prod_value_crop_2 prod_value_crop_13 prod_value_crop_10 prod_value_crop_37 ///					//value of production	
	 prod_value_crop_4 prod_v_crp_1_w99 prod_v_crp_1_w98 prod_v_crp_1_w95 prod_v_crp_8_w99 prod_v_crp_8_w98 prod_v_crp_8_w95 ///
	 prod_v_crp_2_w99 prod_v_crp_2_w98 prod_v_crp_2_w95 prod_v_crp_13_w99 prod_v_crp_13_w98 prod_v_crp_13_w95 prod_v_crp_10_w99 ///
	 prod_v_crp_10_w98 prod_v_crp_10_w95 prod_v_crp_37_w99 prod_v_crp_37_w98 prod_v_crp_37_w95 prod_v_crp_4_w99 prod_v_crp_4_w98 ///
	 prod_v_crp_4_w95 total_prod_v totprod_v_stp totprod_v_nstp tot_prod_v_w99 tot_prod_v_w98 tot_prod_v_w95 prod_v_stp_w99 ///
	 prod_v_stp_w98 prod_v_stp_w95 prod_v_nstp_w99 prod_v_nstp_w98 prod_v_nstp_w95 ihs_total_prod_v ihs_totprod_v_stp ihs_totprod_v_nstp ///
	 ihs_prodv_1 ihs_prodv_8 ihs_prodv_2 ihs_prodv_13 ihs_prodv_10 ihs_prodv_37 ihs_prodv_4 ///
	 ihs_totharv_q ihs_totharv_stp ihs_totharv_nstp ihs_harv_q_1 ihs_harv_q_8 ihs_harv_q_2 ihs_harv_q_13 ihs_harv_q_10 ihs_harv_q_37 ihs_harv_q_4 ///
	 ihs_totplot_hec ihs_plot_hec_1 ihs_plot_hec_8 ihs_plot_hec_2 ihs_plot_hec_13 ihs_plot_hec_10 ihs_plot_hec_37 ihs_plot_hec_4 ///
	 plot_stp plot_nstp totplot_hec_w99 plot_stp_w99 plot_nstp_w99 plot_stp_w98 plot_nstp_w98 plot_stp_w95 plot_nstp_w95 nstp_crop_harv stp_crop_harv 
	 

    * Keep only the baseline and endline values
    keep if round_pooled == 0 | round_pooled == 11
	tab round_pooled, mi // Sanity check - there are some HHIDs from baseline that could not be surveyes at endline
	
	* Keeping observations that were present in both the periods of data collection i.e Baseline and Endline
	sort hhid round_pooled
	by hhid: egen count = count(round_pooled)
	keep if count == 2
	drop count
	tab round_pooled, mi // Looks good

	
* 3. Generating baseline controls 
	
    global outcome_vars hasplots both_crop wet_crop dry_crop total_sales_rev wet_sales_rev dry_sales_rev fertizer_use_d pyhto_use_d paid_labor_d

    foreach outcome_var of global outcome_vars {

    * Generate baseline values for this outcome variable when round_pooled == 0
    by hhid: gen b_`outcome_var' = `outcome_var' if round_pooled == 0
    by hhid: carryforward b_`outcome_var', replace

    * Preserve the dataset to remember the current state
    preserve
    
    * Filter the dataset to only include rows where round_pooled == 11
    keep if round_pooled == 11
    
    * Summarize any missing values in the baseline and outcome variables
    misstable summarize b_`outcome_var' `outcome_var'
    
    * Restore the dataset for the next iteration
    restore
}

    * Keeping only endline rows since we have replicated the baseline variables into a new column
	keep if round_pooled == 11
	
* 4. Tidying up labels and checking consistency of variables across baseline and endline
 
     * Labelling variables
     label var treatment "Treatment Assignment"
	 
	 * Checking for consistency and scale of variables in baseline and endline - Looks good
	 sum *hasplots // Looks good
     sum *both_crop // Looks good
     sum *wet_crop // Looks good
     sum *dry_crop //Looks good
     sum *total_sales_rev // Looks good
     sum *wet_sales_rev // Looks good
     sum *dry_sales_rev // Looks very strange for endline, double check!
     sum *fertizer_use_d // Looks good
     sum *pyhto_use_d // Looks good
     sum *paid_labor_d  // Looks good


* 5. Merging subset of variables from endline to run Lasso regressions
     merge 1:1 hhid using "${endline_ds}/final/lasso_variables_endline.dta"	
	 drop _merge
	 
	/* In lasso_variables_endline, we kept all lasso controls with baseline values
	* Add new variables created using endline data as lasso controls
	foreach var in total_plot_area r_crop_1 r_crop_8 r_crop_2 r_crop_13 r_crop_10 r_crop_37 r_crop_4 ///
						sale_amount_crop_1 sale_amount_crop_8 sale_amount_crop_2 sale_amount_crop_13 ///
						sale_amount_crop_10 sale_amount_crop_37 sale_amount_crop_4 harvest_q_crop_1 ///
						harvest_q_crop_8 harvest_q_crop_2 harvest_q_crop_13 harvest_q_crop_10 harvest_q_crop_37 ///
						harvest_q_crop_4 sale_q_crop_1 sale_q_crop_8 sale_q_crop_2 sale_q_crop_13 ///
						sale_q_crop_10 sale_q_crop_37 sale_q_crop_4 {
						
		gen lasso_`var'=`var'
	}
	*/
    * Defining control variables	 
	local lasso_variables lasso_size_hhh lasso_age_hhh lasso_sex_hhh /// HH characteristics
	lasso_d5_employment_1 lasso_d14_employment_secondary_1 /// Wage Labor
	lasso_total_income_hh_w lasso_wage_job_any lasso_agri_job lasso_agri_job_any /// Wage Labor
	lasso_non_agri_job lasso_non_agri_job_any lasso_avg_emp_days /// Wage Labor
	lasso_hh_own_bus lasso_business_count lasso_enterprise_month  /// Business
	lasso_enterprise_month lasso_enterprise_profit lasso_enterprise_profit_w /// Business
	lasso_wet_crop lasso_dry_crop lasso_both_crop lasso_own_livestock lasso_profit_livestock  /// Agriculture
	lasso_profit_cons_livestock lasso_hasplots lasso_hh_chicken lasso_hh_cow /// Agriculture
	lasso_hh_goat lasso_hh_sheep lasso_hh_loth lasso_tot_lstock_count lasso_tot_animal /// Agriculture
	lasso_tot_lstock_count_tlu lasso_tot_animal_tlu lasso_total_sales_rev /// Agriculture
	lasso_farm_assets_tot  lasso_hh_assets_tot lasso_farm_assets_own  /// Assets
	lasso_hh_assets_own lasso_both_assets_own lasso_asset_group /// Assets
	lasso_hh_diet_div lasso_food_cons_score_cens lasso_fies_score  /// Food Security
	lasso_ps_life_satis_today lasso_ps_life_satis_past lasso_ps_social_status /// Psychosocial
	lasso_ps_future_exp lasso_ps_depression_cesd lasso_ps_depression_sqr /// Psychosocial
	lasso_ps_stress lasso_ps_self_efficacy lasso_ps_satis_life lasso_ps_asp_edu_girl /// Psychosocial
	lasso_shock_group_1 lasso_shock_group_2 lasso_shock_group_3 lasso_shock_group_4 lasso_tot_shocks /// Shocks
	lasso_shock_group_5 lasso_shock_group_6 lasso_shock_group_7 lasso_shock_group_8 lasso_avg_shocks /// Shocks
	lasso_hh_migrated lasso_migr_oth lasso_remittances  /// Migration
	lasso_tot_food_exp_annual_w lasso_tot_food_exp_month_w lasso_tot_food_exp_month_pc_w /// Consumption Exp
	lasso_tot_food_exp_week_w lasso_tot_nfood_exp_annual_w /// Consumption Exp
	lasso_tot_nfood_exp_month_w lasso_tot_nfood_exp_month_pc_w lasso_food_exp_share /// Consumption Exp
	lasso_tot_nfood_exp_week_w lasso_tot_exp_month_w lasso_tot_exp_month_pc_w /// Consumption Exp
	lasso_ask_sum lasso_fin_supp_index lasso_fin_supp_f_index lasso_social_cohes_index  lasso_collective_action_index 
	
	

* 6. Running regressions		 
*global t1 hasplots both_crop wet_crop dry_crop total_sales_rev wet_sales_rev fertizer_use_d pyhto_use_d paid_labor_d
    * Setting model index for loop (i)
    local i = 0

	 foreach var in hasplots wet_crop dry_crop fertizer_use_d pyhto_use_d paid_labor_d {
	 
	 * Dropping the uniform variable created later
	 cap drop lag_outcome_var
	 
	 * Creating a modified list of lasso variables excluding the current variable
     local temp_lasso_vars ""
    
	 foreach v in `lasso_variables' {
     if ("`v'" != "lasso_`var'") local temp_lasso_vars "`temp_lasso_vars' `v'"
	 }
	
	 * Lasso double selection 
	 dsregress `var' treatment, controls(`temp_lasso_vars') rseed(8259) missingok
	 estimates store ds_`var' // Storing estimates
	 lassocoef(ds_`var', for (`var')) 
     di "`e(controls_sel)'" // Browsing selected lasso controls
	 
	 * To tidy up the tables - labeling baseline variables
     gen lag_outcome_var = b_`var'
     label var lag_outcome_var "Lag of outcome"
    
         ** Iterating model index
         local  ++i

         ** Fetching variable label
         local  varlbl :    variable label `var'
         
 	    * Reduced form regression
          eststo rf_`var': reg `var' treatment lag_outcome_var  `e(controls_sel)'  i.fixed_var, cluster(cluster_var)
		sum `var' if e(sample) & treatment == 0 
        estadd scalar ybar = r(mean)
	    estadd local lasso = "Yes"
	    estadd local blockfe = "Yes"
		
	 * IV Regression on HF sub-sample
	 eststo iv_`var': ivreg2 `var' (iv_var = treatment) lag_outcome_var `e(controls_sel)'  i.fixed_var   if hf_sample == 1, cluster(cluster_var)
	 sum `var' if e(sample) & treatment == 0 
	 estadd scalar ybar = r(mean)
	 estadd local lasso = "Yes"
	 estadd local blockfe = "Yes"
	 
	 
        * Poverty Class
	    eststo p_`var': reg `var' treatment##poverty_class lag_outcome_var `e(controls_sel)'  i.fixed_var, cluster(cluster_var)
	    test (1.treatment + 1.treatment#1.poverty_class) = 0
	    local fstat = r(p)
	    sum `var' if e(sample) & treatment == 0 
	    estadd scalar ybar = r(mean) 
	    estadd local lasso = "Yes"
	    estadd local blockfe = "Yes"
	    estadd scalar F_statistic = `fstat'
	 
	 
	    * Village type
	    eststo v_`var': reg `var' treatment##village_type lag_outcome_var `e(controls_sel)'  i.fixed_var, cluster(cluster_var)
	    test (1.treatment + 1.treatment#1.village_type) = 0
	    local fstat = r(p)
	    sum `var' if e(sample) & treatment == 0 
	    estadd scalar ybar = r(mean)
	    estadd local lasso = "Yes"
	    estadd local blockfe = "Yes"
	    estadd scalar F_statistic = `fstat'	


	 }

* 7. Exporting regressions
* Change variable labels so we can export them to the tables
la var hasplots "Cultivated land" 
la var wet_crop "Cultivated in rainy season"
la var dry_crop "Cultivated in dry season"
la var fertizer_use_d "Used fertilizers" 
la var pyhto_use_d "Used pesticides" 
la var paid_labor_d "Used paid labor"
la var treatment "Treatment"

	  // Table 1
	 esttab rf_* using "$endline_out/final/overleaf/f_agri_reg_v1.tex", ///
      se label star(* 0.10 ** 0.05 *** 0.01) compress booktabs ///
	  nogap nonote noomitted replace ///
	 sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE") ///
	   keep(treatment) mlabel(,dep) ///
	   addnotes("Standard errors have been clustered at the village level and block fixed effects have been included. *** p$<$0.01, ** p$<$0.05, * p$<$0.1")
	  
	  // Table 2
	 esttab iv_* using "$endline_out/final/overleaf/f_agri_reg_v2.tex", ///
      se label star(* 0.10 ** 0.05 *** 0.01) compress ///
	  nogap nonote noomitted replace ///
	 sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE") ///
	   keep(iv_var) mlabel(,dep)
	   	   
	 // Table 3   
	 esttab p_* using "$endline_out/final/overleaf/f_agri_reg_v3.tex", ///
      se label star(* 0.10 ** 0.05 *** 0.01) compress ///
	  nogap nonote noomitted replace ///
	  sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE" " F_statistic  P-value for interaction term") ///
	   keep(1.treatment 1.poverty_class 1.treatment#1.poverty_class) mlabel(,dep)
	  
	 // Table 4
      esttab v_* using "$endline_out/final/overleaf/f_agri_reg_v4.tex", ///
      se label star(* 0.10 ** 0.05 *** 0.01) compress ///
	  nogap nonote noomitted replace ///
	  sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE" " F_statistic  P-value for interaction term") ///
	   keep(1.treatment 1.village_type 1.treatment#1.village_type) mlabel(,dep)


* 8. Running regressions for new variables 		 
/* Added variables for ag for 7 main crops: Mil(1), Niebe (8), Sorgho(2), Sesame(13), 
		Arachide(10), Haricot-vert(37), Mais(4)
		1. flag if a hhld cultivated a given crop (r_crop)
		2. value of sales for each crop
		3. Quantity produced for each crop
		4. Quantity sold for each crop
*/
    * Setting model index for loop (i)
    local i = 0

	 /* We will split the variables to produce 6 tables: 
		1) total plot area and plot area by crop
		2) If hhld cultivated a given crop
		3) Total value of sales, total value of sales for staple crops, total 
		   value of sales for non-staple crops and value of sales for each crop.
		4) Total qty produced for all crops, total qty of staple crops produced, 
			total qty of non staple crops produced, quantity produced for each crop
		5) Total qty sold for all crops, total qty sold for staple crops, total 
			quantity sold for non staple crops and quantity sold for each crop.
		6) If they sold a given crop, a staple crop and a non staple crop
		7) Value of production for all crops, staple crops, non-staple crops and by crop
			
			We repeat tables 1, 3,4, 5 and 7 for winsorized values at 95, 98 and 99.
	 */
	 
	*1) If hhld cultivated a given crop
	global t1 stp_crop_harv nstp_crop_harv r_crop_1 r_crop_8 r_crop_2 r_crop_13 r_crop_10 r_crop_37 r_crop_4
	 
	 *2) total plot area and plot area by crop
	 global t2 totplot_hec plot_stp plot_nstp plot_hectares_crop_1 plot_hectares_crop_8 plot_hectares_crop_2 ///
				plot_hectares_crop_13 plot_hectares_crop_10 plot_hectares_crop_37 plot_hectares_crop_4
	global t2w99 totplot_hec_w99 plot_stp_w99 plot_nstp_w99 plot_hec_1_w99 plot_hec_8_w99 plot_hec_2_w99 plot_hec_13_w99 plot_hec_10_w99 plot_hec_37_w99 plot_hec_4_w99
	global t2w98 totplot_hec_w98 plot_stp_w98 plot_nstp_w98 plot_hec_1_w98 plot_hec_8_w98 plot_hec_2_w98 plot_hec_13_w98 plot_hec_10_w98 plot_hec_37_w98 plot_hec_4_w98
	global t2w95 totplot_hec_w95 plot_stp_w95 plot_nstp_w95 plot_hec_1_w95 plot_hec_8_w95 plot_hec_2_w95 plot_hec_13_w95 plot_hec_10_w95 plot_hec_37_w95 plot_hec_4_w95
	global t2ihs ihs_totplot_hec ihs_plot_hec_1 ihs_plot_hec_8 ihs_plot_hec_2 ihs_plot_hec_13 ihs_plot_hec_10 ihs_plot_hec_37 ihs_plot_hec_4
	
	/*3) Total qty produced for all crops, total qty of staple crops produced, total 
		  qty of non staple crops produced, quantity produced for each crop */
	 global t3 total_harvest_q tot_harv_stp tot_harv_nstp harvest_q_crop_1 harvest_q_crop_8 ///
			harvest_q_crop_2 harvest_q_crop_13 harvest_q_crop_10 harvest_q_crop_37 harvest_q_crop_4 
	 global t3w99 total_harv_w99 tot_harv_stp_w99 tot_harv_nstp_w99 harv_q_crop_1_w99 harv_q_crop_8_w99 ///
			harv_q_crop_2_w99 harv_q_crop_13_w99 harv_q_crop_10_w99 harv_q_crop_37_w99 harv_q_crop_4_w99
	 global t3w98 total_harv_w98 tot_harv_stp_w98 tot_harv_nstp_w98 harv_q_crop_1_w98 harv_q_crop_8_w98 ///
			harv_q_crop_2_w98 harv_q_crop_13_w98 harv_q_crop_10_w98 harv_q_crop_37_w98 harv_q_crop_4_w98
	 global t3w95 total_harv_w95 tot_harv_stp_w95 tot_harv_nstp_w95 harv_q_crop_1_w95 harv_q_crop_8_w95 ///
			harv_q_crop_2_w95 harv_q_crop_13_w95 harv_q_crop_10_w95 harv_q_crop_37_w95 harv_q_crop_4_w95
	global t3ihs ihs_totharv_q ihs_totharv_stp ihs_totharv_nstp ihs_harv_q_1 ihs_harv_q_8 ihs_harv_q_2 ihs_harv_q_13 ihs_harv_q_10 ihs_harv_q_37 ihs_harv_q_4	
	
	 *4) Value of production for all crops, staple, non-staple and by crop
	 global t4 total_prod_v totprod_v_stp totprod_v_nstp prod_value_crop_1 prod_value_crop_8 prod_value_crop_2 prod_value_crop_13 prod_value_crop_10 prod_value_crop_37 prod_value_crop_4
	 global t4w99 tot_prod_v_w99 prod_v_stp_w99 prod_v_nstp_w99 prod_v_crp_1_w99 prod_v_crp_8_w99 prod_v_crp_2_w99 prod_v_crp_13_w99 prod_v_crp_10_w99 prod_v_crp_37_w99 prod_v_crp_4_w99
	 global t4w98 tot_prod_v_w98 prod_v_stp_w98 prod_v_nstp_w98 prod_v_crp_1_w98 prod_v_crp_8_w98 prod_v_crp_2_w98 prod_v_crp_13_w98 prod_v_crp_10_w98 prod_v_crp_37_w98 prod_v_crp_4_w98
	 global t4w95 tot_prod_v_w95 prod_v_stp_w95 prod_v_nstp_w95 prod_v_crp_1_w95 prod_v_crp_8_w95 prod_v_crp_2_w95 prod_v_crp_13_w95 prod_v_crp_10_w95 prod_v_crp_37_w95 prod_v_crp_4_w95
	 global t4ihs ihs_total_prod_v ihs_totprod_v_stp ihs_totprod_v_nstp ihs_prodv_1 ihs_prodv_8 ihs_prodv_2 ihs_prodv_13 ihs_prodv_10 ihs_prodv_37 ihs_prodv_4
	 
	  * 5) If they sold a given crop, a staple crop and a non staple crop	
	 global t5 sold_staple_crop sold_nstaple_crop sold_crop_1 sold_crop_8 sold_crop_2 sold_crop_13 sold_crop_10 sold_crop_37 sold_crop_4 			
	 
	 /*6) Total qty sold for all crops, total qty sold for staple crops, total 
		  quantity sold for non staple crops and quantity sold for each crop. */
	 global t6 total_sale_q totsale_q_stp totsale_q_nstp sale_q_crop_1 sale_q_crop_8 ///
			sale_q_crop_2 sale_q_crop_13 sale_q_crop_10 sale_q_crop_37 sale_q_crop_4
	 global t6w99 tot_sale_q_w99 totsale_q_stp_w99 totsale_q_nstp_w99 sale_q_crp_1_w99 ///
			sale_q_crp_8_w99 sale_q_crp_2_w99 sale_q_crp_13_w99 sale_q_crp_10_w99 sale_q_crp_37_w99 sale_q_crp_4_w99
	 global t6w98 tot_sale_q_w98 totsale_q_stp_w98 totsale_q_nstp_w98 sale_q_crp_1_w98 ///
			sale_q_crp_8_w98 sale_q_crp_2_w98 sale_q_crp_13_w98 sale_q_crp_10_w98 sale_q_crp_37_w98 sale_q_crp_4_w98
	 global t6w95 tot_sale_q_w95 totsale_q_stp_w95 totsale_q_nstp_w95 sale_q_crp_1_w95 ///
			sale_q_crp_8_w95 sale_q_crp_2_w95 sale_q_crp_13_w95 sale_q_crp_10_w95 sale_q_crp_37_w95 sale_q_crp_4_w95
	 
	 /*7) Total value of sales, total value of sales for staple crops, total value
		  of sales for non-staple crops and value of sales for each crop. */
	 global t7 total_sales totsale_stp totsale_nstp sale_amount_crop_1 sale_amount_crop_8 ///
			sale_amount_crop_2 sale_amount_crop_13 sale_amount_crop_10 sale_amount_crop_4 				//removed sale_amount_crop_37
	 global t799 tot_sale_w99 totsale_stp_w99 totsale_nstp_w99 sale_crp_1_w99 ///
			sale_crp_8_w99 sale_crp_2_w99 sale_crp_13_w99 sale_crp_10_w99 sale_crp_37_w99 sale_crp_4_w99	
	 global t798 tot_sale_w98 totsale_stp_w98 totsale_nstp_w98 sale_crp_1_w98 ///
			sale_crp_8_w98 sale_crp_2_w98 sale_crp_13_w98 sale_crp_10_w98 sale_crp_37_w98 sale_crp_4_w98
	 global t795 tot_sale_w95 totsale_stp_w95 totsale_nstp_w95 sale_crp_1_w95 ///
			sale_crp_8_w95 sale_crp_2_w95 sale_crp_13_w95 sale_crp_10_w95 sale_crp_37_w95 sale_crp_4_w95
	
	
	
	 
	 
	 /**************** Tables 1-7: not winsorized *********************/
	global list1 t1 t2 t2ihs
	global list2 t3 t3ihs t4 t4ihs t5 t6 t7
	foreach l in list1 list2 {
	 foreach g in $`l' {
	 
	 foreach var in $`g' {
	 disp "`var'"
	 * Dropping the uniform variable created later
	 cap drop lag_outcome_var
	 
	 * Creating a modified list of lasso variables excluding the current variable
     local temp_lasso_vars ""
    
	 foreach v in `lasso_variables' {
     if ("`v'" != "lasso_`var'") local temp_lasso_vars "`temp_lasso_vars' `v'"
	 }
	
	 * Lasso double selection 
	 dsregress `var' treatment, controls(`temp_lasso_vars') rseed(8259) missingok
	 estimates store ds_`var' // Storing estimates
	 lassocoef(ds_`var', for (`var')) 
     di "`e(controls_sel)'" // Browsing selected lasso controls
	 
	 * To tidy up the tables - labeling baseline variables
     *gen lag_outcome_var = b_`var'
     *label var lag_outcome_var "Lag of outcome"
    
         ** Iterating model index
         local  ++i

         ** Fetching variable label
         local  varlbl :    variable label `var'
         
 	    * Reduced form regression
        eststo rf_`g'_`var': reg `var' treatment  `e(controls_sel)'  i.fixed_var, cluster(cluster_var)
		sum `var' if e(sample) & treatment == 0 
        estadd scalar ybar = r(mean)
	    estadd local lasso = "Yes"
	    estadd local blockfe = "Yes"
		
		* IV Regression on HF sub-sample
		disp "error here"
		di "`e(controls_sel)'" 
		eststo iv_`g'_`var': ivreg2 `var' (iv_var = treatment) `e(controls_sel)'  i.fixed_var   if hf_sample == 1, cluster(cluster_var)
		sum `var' if e(sample) & treatment == 0 
		estadd scalar ybar = r(mean)
		estadd local lasso = "Yes"
		estadd local blockfe = "Yes"
		
	 
        * Poverty Class
	    eststo p_`g'_`var': reg `var' treatment##poverty_class `e(controls_sel)'  i.fixed_var, cluster(cluster_var)
	    test (1.treatment + 1.treatment#1.poverty_class) = 0
	    local fstat = r(p)
	    sum `var' if e(sample) & treatment == 0 
	    estadd scalar ybar = r(mean) 
	    estadd local lasso = "Yes"
	    estadd local blockfe = "Yes"
	    estadd scalar F_statistic = `fstat'
	 
	 
	    * Village type
	    eststo v_`g'_`var': reg `var' treatment##village_type `e(controls_sel)'  i.fixed_var, cluster(cluster_var)
	    test (1.treatment + 1.treatment#1.village_type) = 0
	    local fstat = r(p)
	    sum `var' if e(sample) & treatment == 0 
	    estadd scalar ybar = r(mean)
	    estadd local lasso = "Yes"
	    estadd local blockfe = "Yes"
	    estadd scalar F_statistic = `fstat'	
		
		disp "End of regressions for y=`var'"
		estimates drop ds_`var' 												// Drop  estimates, we do not need these anymore

	 }
	 sleep 2000


* 9. Exporting regressions
	
	if "`g'"=="t1"|"`g'"=="t5" {
		local mtitle="Staple_crops Non_staple_crops Mil Niebe Sorgho Sesame Arachide Haricot_vert Mais"
	}
	else if "`g'"=="t2"|"`g'"=="t2_ihs" {
		local mtitle="All_crops Staple_crops Non_staple_crops Mil Niebe Sorgho Sesame Arachide Haricot_vert Mais"
	}
	else if "`g'"=="t7" {
		local mtitle="All_crops Staple_crops Non_staple_crops Mil Niebe Sorgho Sesame Arachide Mais"
	}
	else {
		local mtitle="All_crops Staple_crops Non_staple_crops Mil Niebe Sorgho Sesame Arachide Haricot_vert Mais"
	}
	
	  // Table 1
	 esttab rf_`g'_* using "$endline_out/final/overleaf/f_agri_reg_v1_`g'.tex", ///
      keep(treatment) se label star(* 0.10 ** 0.05 *** 0.01) compress ///
	  nogap noomitted replace ///
	 sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE") ///
	   mtitle(`mtitle') 
	  
	  // Table 2
	 esttab iv_`g'_* using "$endline_out/final/overleaf/f_agri_reg_v2_`g'.tex", ///
      se label star(* 0.10 ** 0.05 *** 0.01) compress ///
	  nogap noomitted replace keep(iv_var) ///
	 sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE") ///
	   mtitle(`mtitle')
	  	   
	 // Table 3   
	 esttab p_`g'_* using "$endline_out/final/overleaf/f_agri_reg_v3_`g'.tex", ///
      se label star(* 0.10 ** 0.05 *** 0.01) compress ///
	  nogap noomitted replace keep(1.treatment 1.poverty_class 1.treatment#1.poverty_class) ///
	  sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE" " F_statistic  P-value for interaction term") ///
	   mtitle(`mtitle') 
	  
	 // Table 4
      esttab v_`g'_* using "$endline_out/final/overleaf/f_agri_reg_v4_`g'.tex", ///
      se label star(* 0.10 ** 0.05 *** 0.01) compress ///
	  nogap noomitted replace keep(1.treatment 1.village_type 1.treatment#1.village_type) ///
	  sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE" " F_statistic  P-value for interaction term") ///
	   mtitle(`mtitle')

	   local i=`i'+1
}
estimates drop _all
}
 
* drop all estimates
estimates drop _all
 
/* Winsorized values - there are too many models that we get the error message system limit exceeded
when running everything. Create a loop so we can clear estimates and run more models */
global list1 t2w99 t2w98 t2w95 t3w99 t3w98 t3w95 t4w99 t4w98 t4w95
global list2 t6w99 t6w98 t6w95 t799 t798 t795
foreach l in list1 list2 {
	 foreach g in $`l' {
	 
	 foreach var in $`g' {
	 disp "`var'"
	 * Dropping the uniform variable created later
	 cap drop lag_outcome_var
	 
	 * Creating a modified list of lasso variables excluding the current variable
     local temp_lasso_vars ""
    
	 foreach v in `lasso_variables' {
     if ("`v'" != "lasso_`var'") local temp_lasso_vars "`temp_lasso_vars' `v'"
	 }
	
	 * Lasso double selection 
	 dsregress `var' treatment, controls(`temp_lasso_vars') rseed(8259) missingok
	 estimates store ds_`var' // Storing estimates
	 lassocoef(ds_`var', for (`var')) 
     di "`e(controls_sel)'" // Browsing selected lasso controls
	 
	 * To tidy up the tables - labeling baseline variables
     *gen lag_outcome_var = b_`var'
     *label var lag_outcome_var "Lag of outcome"
    
         ** Iterating model index
         local  ++i

         ** Fetching variable label
         local  varlbl :    variable label `var'
         
 	    * Reduced form regression
        eststo rf_`g'_`var': reg `var' treatment  `e(controls_sel)'  i.fixed_var, cluster(cluster_var)
		sum `var' if e(sample) & treatment == 0 
        estadd scalar ybar = r(mean)
	    estadd local lasso = "Yes"
	    estadd local blockfe = "Yes"
		
		/* IV Regression on HF sub-sample
		disp "error here"
		di "`e(controls_sel)'" 
		eststo iv_`g'_`var': ivreg2 `var' (iv_var = treatment) `e(controls_sel)'  i.fixed_var   if hf_sample == 1, cluster(cluster_var)
		sum `var' if e(sample) & treatment == 0 
		estadd scalar ybar = r(mean)
		estadd local lasso = "Yes"
		estadd local blockfe = "Yes"
		*/
	 
        * Poverty Class
	    eststo p_`g'_`var': reg `var' treatment##poverty_class `e(controls_sel)'  i.fixed_var, cluster(cluster_var)
	    test (1.treatment + 1.treatment#1.poverty_class) = 0
	    local fstat = r(p)
	    sum `var' if e(sample) & treatment == 0 
	    estadd scalar ybar = r(mean) 
	    estadd local lasso = "Yes"
	    estadd local blockfe = "Yes"
	    estadd scalar F_statistic = `fstat'
	 
	 
	    * Village type
	    eststo v_`g'_`var': reg `var' treatment##village_type `e(controls_sel)'  i.fixed_var, cluster(cluster_var)
	    test (1.treatment + 1.treatment#1.village_type) = 0
	    local fstat = r(p)
	    sum `var' if e(sample) & treatment == 0 
	    estadd scalar ybar = r(mean)
	    estadd local lasso = "Yes"
	    estadd local blockfe = "Yes"
	    estadd scalar F_statistic = `fstat'	
		
		disp "End of regressions for y=`var'"
		estimates drop ds_`var' 												// Drop  estimates, we do not need these anymore

	 }
	 sleep 2000

* 11. Exporting regressions

	if "`g'"=="t1w99"|"`g'"=="t1w98"|"`g'"=="t1w95" {
		local mtitle="Total_plot_area Mil Niebe Sorgho Sesame Arachide Haricot_vert Mais"
	}
	else {
		local mtitle="All_crops Staple_crops Non_staple_crops Mil Niebe Sorgho Sesame Arachide Haricot_vert Mais"
	}
	
	  // Table 1
	 esttab rf_`g'_* using "$endline_out/final/overleaf/f_agri_reg_v1_`g'.tex", ///
      keep(treatment) se label star(* 0.10 ** 0.05 *** 0.01) compress ///
	  nogap noomitted replace ///
	 sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE") ///
	   mtitle(`mtitle') 
	  
	  // Table 2
	 /*esttab iv_`g'_* using "$endline_out/final/overleaf/f_agri_reg_v2_`g'.tex", ///
      se label star(* 0.10 ** 0.05 *** 0.01) compress ///
	  nogap nonote noomitted replace keep(iv_var) ///
	 sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE") ///
	   mtitle(`mtitle')
	  */ 	   
	 // Table 3   
	 esttab p_`g'_* using "$endline_out/final/overleaf/f_agri_reg_v3_`g'.tex", ///
      se label star(* 0.10 ** 0.05 *** 0.01) compress ///
	  nogap noomitted replace keep(1.treatment 1.poverty_class 1.treatment#1.poverty_class) ///
	  sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE" " F_statistic  P-value for interaction term") ///
	   mtitle(`mtitle') 
	  
	 // Table 4
      esttab v_`g'_* using "$endline_out/final/overleaf/f_agri_reg_v4_`g'.tex", ///
      se label star(* 0.10 ** 0.05 *** 0.01) compress ///
	  nogap noomitted replace keep(1.treatment 1.village_type 1.treatment#1.village_type) ///
	  sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE" " F_statistic  P-value for interaction term") ///
	   mtitle(`mtitle')

}
estimates drop _all
}

* drop all estimates
estimates drop _all

* Prepare tables we want to include in slides abd report. Use values winsoriuzed at 98th percentile
*Rename variables so we can use variable labels in the table

*table 0: 
*table 1: Total area cultivated, Total quantity produced, Total quantity sold
global table1 totplot_hec_w98 total_harv_w98 tot_sale_q_w98
la var totplot_hec_w98 "Area cultivated"
la var total_harv_w98 "Quantity harvested"
la var tot_sale_q_w98 "Quantity sold"

*table 2: Total value of production, total value of sales
global table2 tot_prod_v_w98 tot_sale_w98
la var tot_prod_v_w98 "Value of production"
la var tot_sale_w98 "Value of sales"

*table 3.1.5: Total area cultivated, total q produced, value of production, ///
*			  share of household selling (might need to build), total q sold,  value of sales,
global tab5 totplot_hec_w98 total_harv_w98 tot_prod_v_w98 sold_crop tot_sale_q_w98 tot_sale_w98
la var sold_crop "\% HHs selling crops"

*table 3.1.6: for staple crops: hh cultivated, area cultivated, q produced, value of production, share of household selling, q sold,  value of sales
global tab6 stp_crop_harv plot_stp_w98 tot_harv_stp_w98 prod_v_stp_w98 sold_staple_crop totsale_q_stp_w98 totsale_stp_w98 
foreach type in stp nstp {
	la var `type'_crop_harv "\% HHs cultivating crops" 
	la var plot_`type'_w98 "Area cultivated" 
	la var tot_harv_`type'_w98 "Quantity produced" 
	la var prod_v_`type'_w98 "Value of production" 
	la var sold_staple_crop "\% HHs selling crops" 
	la var sold_nstaple_crop "\% HHs selling crops"
	la var totsale_q_`type'_w98 "Quantity sold" 
	la var totsale_`type'_w98 "Value of sales"
}

	*table 3.1.7: for non-staple crops: hh cultivated, area cultivated, q produced, value of production, share of household selling, q sold,  value of sales
global tab7 nstp_crop_harv plot_nstp_w98 tot_harv_nstp_w98 prod_v_nstp_w98 sold_nstaple_crop totsale_q_nstp_w98 totsale_nstp_w98

/* Winsorized values */
	 foreach g in table1 table2 tab5 tab6 tab7 {
	 
	 foreach var in $`g' {
	 disp "`var'"
	 * Dropping the uniform variable created later
	 cap drop lag_outcome_var
	 
	 * Creating a modified list of lasso variables excluding the current variable
     local temp_lasso_vars ""
    
	 foreach v in `lasso_variables' {
     if ("`v'" != "lasso_`var'") local temp_lasso_vars "`temp_lasso_vars' `v'"
	 }
	
	 * Lasso double selection 
	 dsregress `var' treatment, controls(`temp_lasso_vars') rseed(8259) missingok
	 estimates store ds_`var' // Storing estimates
	 lassocoef(ds_`var', for (`var')) 
     di "`e(controls_sel)'" // Browsing selected lasso controls
	 
	 * To tidy up the tables - labeling baseline variables
     *gen lag_outcome_var = b_`var'
     *label var lag_outcome_var "Lag of outcome"
    
         ** Iterating model index
         local  ++i

         ** Fetching variable label
         local  varlbl :    variable label `var'
         
 	    * Reduced form regression
        eststo rf_`g'_`var': reg `var' treatment  `e(controls_sel)'  i.fixed_var, cluster(cluster_var)
		sum `var' if e(sample) & treatment == 0 
        estadd scalar ybar = r(mean)
	    estadd local lasso = "Yes"
	    estadd local blockfe = "Yes"
		
		* IV Regression on HF sub-sample
		disp "error here"
		di "`e(controls_sel)'" 
		eststo iv_`g'_`var': ivreg2 `var' (iv_var = treatment) `e(controls_sel)'  i.fixed_var   if hf_sample == 1, cluster(cluster_var)
		sum `var' if e(sample) & treatment == 0 
		estadd scalar ybar = r(mean)
		estadd local lasso = "Yes"
		estadd local blockfe = "Yes"
		
	 
        * Poverty Class
	    eststo p_`g'_`var': reg `var' treatment##poverty_class `e(controls_sel)'  i.fixed_var, cluster(cluster_var)
	    test (1.treatment + 1.treatment#1.poverty_class) = 0
	    local fstat = r(p)
	    sum `var' if e(sample) & treatment == 0 
	    estadd scalar ybar = r(mean) 
	    estadd local lasso = "Yes"
	    estadd local blockfe = "Yes"
	    estadd scalar F_statistic = `fstat'
	 
	 
	    * Village type
	    eststo v_`g'_`var': reg `var' treatment##village_type `e(controls_sel)'  i.fixed_var, cluster(cluster_var)
	    test (1.treatment + 1.treatment#1.village_type) = 0
	    local fstat = r(p)
	    sum `var' if e(sample) & treatment == 0 
	    estadd scalar ybar = r(mean)
	    estadd local lasso = "Yes"
	    estadd local blockfe = "Yes"
	    estadd scalar F_statistic = `fstat'	
		
		disp "End of regressions for y=`var'"
		estimates drop ds_`var' 												// Drop  estimates, we do not need these anymore

	 }
	 sleep 2000
}

* 12. Exporting regressions
local i=1
foreach g in table1 table2 tab5 tab6 tab7 {
	*Table 1
	if `i'==1 {
		local mtitle ""Total area cultivated" "Total quantity produced" "Total quantity sold""
		local notes ""Table shows values for main crops cultivated including Mil, Niebe, Sorgho, Sesame, Arachide, Haricot-vert, and Mais. Standard errors have been clustered" "at the village level and block fixed effects have been included. All values are winsorized at 98th percentile."  "*** p$<$0.01, ** p$<$0.05, * p$<$0.1""
	}
	*Table 2
	else if `i'==2 {
		local mtitle ""Total value of production" "Total value of sales""
		local notes ""Table shows values for main crops including Mil, Niebe, Sorgho, Sesame, Arachide, Haricot-vert, and Mais. Standard errors have been clustered at the village level and block fixed effects have been included. All values are winsorized at 98th percentile."  "*** p$<$0.01, ** p$<$0.05, * p$<$0.1""
	}
	*Table 5
	else if `i'==3 {
		local mtitle ""Area cultivated" "Quantity produced" "Value of production" "% HHs selling crops" "Quantity sold" "Value of sales""
		local notes ""Table shows values for main crops including Mil, Niebe, Sorgho, Sesame, Arachide, Haricot-vert, and Mais. Standard errors have been clustered" "at the village level and block fixed effects have been included. All values are winsorized at 98th percentile."  "*** p$<$0.01, ** p$<$0.05, * p$<$0.1""
	}
	*Table 6
	else if `i'==4 {
		local mtitle ""% HHs cultivating crops" "Area cultivated" "Quantity produced" "Value of production" "% HHs selling crops" "Quantity sold" "Value of sales""
		local notes ""Table shows values for staple crops including Mil, Niebe and Sorgho. Standard errors have been clustered at the village level and block fixed effects have been included." "All values are winsorized at 98th percentile. *** p$<$0.01, ** p$<$0.05, * p$<$0.1""
	}
	*Table 7
	else if `i'==5 {
		local mtitle ""% HHs cultivating crops" "Area cultivated" "Quantity produced" "Value of production" "% HHs selling crops" "Quantity sold" "Value of sales""
		local notes ""Table shows values for non staple crops including Sesame, Arachide, Haricot-vert, and Mais. Standard errors have been clustered at the village level and block fixed effects have been included." "All values are winsorized at 98th percentile.  *** p$<$0.01, ** p$<$0.05, * p$<$0.1""
	}
	
	  // Table 1
	 esttab rf_`g'_* using "$endline_out/final/overleaf/f_agri_reg_v1_`g'.tex", ///
      keep(treatment) se label star(* 0.10 ** 0.05 *** 0.01) compress booktabs ///
	  nogap noomitted replace nonote addnotes(`notes') mlabel(,dep) ///
	 sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE") 
	    
	  
	  // Table 2
	 esttab iv_`g'_* using "$endline_out/final/overleaf/f_agri_reg_v2_`g'.tex", ///
      se mlabel(,dep) label star(* 0.10 ** 0.05 *** 0.01) compress booktabs ///
	  nogap nonote noomitted replace keep(iv_var) addnotes(`notes') ///
	 sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE") 
	    
	   
	 // Table 3   
	 esttab p_`g'_* using "$endline_out/final/overleaf/f_agri_reg_v3_`g'.tex", ///
      se mlabel(,dep) label star(* 0.10 ** 0.05 *** 0.01) compress booktabs addnotes(`notes') ///
	  nogap noomitted replace keep(1.treatment 1.poverty_class 1.treatment#1.poverty_class) ///
	  sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE" " F_statistic  P-value for treatment effects for poor") 
	  
	 // Table 4
      esttab v_`g'_* using "$endline_out/final/overleaf/f_agri_reg_v4_`g'.tex", ///
      se mlabel(,dep) label star(* 0.10 ** 0.05 *** 0.01) compress ///
	  nogap noomitted replace keep(1.treatment 1.village_type 1.treatment#1.village_type) ///
	  sca("N Observations" "ybar Control Mean" "lasso Lasso Controls"  "blockfe  Block FE" " F_statistic  P-value for treatment effects for primary villages") ///
	  booktabs ///
	  addnotes(`notes') 

	   local i=`i'+1
}

  
