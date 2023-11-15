 /*******************************************************************************

			               Task:  Construct
							
			      - Module F: Farming & Livestock -

				By:           PB
				Last updated: 12May2023
						  
      ----------------------------------------------------------
			  
	*Notes:

	
*******************************************************************************/

*1. Use cleaned dataset  

	u "$endline_ds/intermediate/f_farming_and_livestock_clean.dta",clear	

*2. Create indices 

    ***************************************
    ********* AGRICULTURE ****************
    ***************************************

	* % HH that only cultivated land, only owned livelihood, neither or both
	gen     sample_tag = 1 if !mi(hasplots) & !mi(own_livestock) // = 1 if responses to both questions
	
	gen     noplots_and_livestock = 0 if sample_tag == 1 // full response sample_tag
	replace noplots_and_livestock = 1 if hasplots == 0 & own_livestock == 0 // neither
	
	gen     only_hasplots = 0 if sample_tag == 1 // full response sample_tag
	replace only_hasplots = 1 if hasplots == 1 & own_livestock != 1 // only cultivated land
	
	gen     only_own_livestock = 0 if sample_tag == 1 // full response sample_tag
	replace only_own_livestock = 1 if own_livestock == 1 & hasplots != 1 // only raises livestock
	
	gen     hasplots_and_livestock = 0 if sample_tag == 1 // full response sample_tag
	replace hasplots_and_livestock = 1 if own_livestock == 1 & hasplots == 1 // both
	
	replace plot_n = 0 if hasplots == 0
	
	* Same as above, but categorical variable
	gen     livelihood_group = 0 if sample_tag == 1 // full response sample_tag
	replace livelihood_group = 0 if hasplots == 0 & own_livestock == 0 // neither
	replace livelihood_group = 1 if hasplots == 1 & own_livestock != 1 // only cultivated land
	replace livelihood_group = 2 if own_livestock == 1 & hasplots != 1 // only raises livestock
	replace livelihood_group = 3 if own_livestock == 1 & hasplots == 1 // both
	
	label define livelihood 0 "Neither" 1 "Cultivates land" 2 "Raises livestock" 3 "Both"
	label values livelihood_group livelihood
	
	sum noplots_and_livestock only_hasplots only_own_livestock hasplots_and_livestock
	tab livelihood_group // check: should be same as above
	
	* HH grows Dry Crops
	
	gen     dry_crop = 1 if anyplot_season == 2
	replace dry_crop = 0 if dry_crop == .
	
	* HH grows Rainy Crops
	
	gen     wet_crop = 1 if anyplot_season == 1 
	replace wet_crop = 0 if wet_crop == .

	* HH grows Dry and Rainy Crops
	
	gen     both_crop = 1 if anyplot_season == 3 
	replace both_crop = 0 if both_crop == .
	
	* HH revenue from total sale of crops (both dry and wet)

    forval i = 1/13 {
        replace sale_amount_`i' = 0 if sale_q_`i' == 0 // replace to 0 if the rainy crop was not sold
    }

    forval i = 1/9 {
        replace sale_amount_d_`i' = 0 if sale_q_d_`i' == 0 // replace to 0 if the dry crop was not sold
    }

	egen total_sales_rev    = rowtotal(sale_amount_1 sale_amount_2 sale_amount_3 sale_amount_4 sale_amount_5 sale_amount_6 sale_amount_7 sale_amount_8 sale_amount_9 sale_amount_10 sale_amount_11 sale_amount_12 sale_amount_13 sale_amount_d_1 sale_amount_d_2 sale_amount_d_3 sale_amount_d_4 sale_amount_d_5 sale_amount_d_6 sale_amount_d_7 sale_amount_d_8 sale_amount_d_9), mi 

    replace total_sales_rev = 0 if hasplots == 1 & total_sales_rev == .

	* HH revenue from sale of Wet Crops
	egen wet_sales_rev = rowtotal(sale_amount_1 sale_amount_2 sale_amount_3 sale_amount_4 sale_amount_5 sale_amount_6 sale_amount_7 sale_amount_8 sale_amount_9 sale_amount_10 sale_amount_11 sale_amount_12 sale_amount_13), miss
      replace wet_sales_rev = 0 if hasplots == 1 & wet_sales_rev == . 
	  
	* HH revenue from sale of Dry Crops
	egen dry_sales_rev = rowtotal(sale_amount_d_1 sale_amount_d_2 sale_amount_d_3 sale_amount_d_4 sale_amount_d_5 sale_amount_d_6 sale_amount_d_7 sale_amount_d_8 sale_amount_d_9), miss
	replace dry_sales_rev = 0 if hasplots == 1 & dry_sales_rev == . 
	
    * Calculate farm size
   * egen farm_size = rowtotal(plot_area_*), mi // for those who have a plot

    * Calculate total plot area by hhld
    egen total_plot_area=rowtotal(plot_hectares_*), m
	la var total_plot_area "Total plot area by household"
	sum total_plot_area,d
	
	* Winsorize at 99th percentile
	winsor2 total_plot_area, replace cuts(0 99)
	
	* Calculate the area cultivated by crop for our 7 main crops
	foreach c in 1 8 2 13 10 37 4 {
		forv i=1/12 {
			gen plot_area_`c'_`i'=plot_hectares_`i' if part_c_name_`i'==`c'			//e.g takes the plot area of mil if crop in part_c_name1 is mil
		}
		egen plot_hectares_crop_`c'=rowtotal(plot_area_`c'_*),m	
		sum plot_hectares_crop_`c'
		replace plot_hectares_crop_`c'=0 if missing(plot_hectares_crop_`c')
		
		*create an inverse hyperbolic sine for plot area
		gen ihs_plot_hec_`c'= ln(plot_hectares_crop_`c'+((plot_hectares_crop_`c'^2 + 1)^0.5))
		*ihstrans plot_hectares_crop_`c'										//you can also use ihstrans command
		
		* winsorize at 99, 98, 95
		foreach p in 99 98 95 {
			winsor2 plot_hectares_crop_`c', suffix(_w`p') cuts(0 `p')
			rename plot_hectares_crop_`c'_w`p' plot_hec_`c'_w`p'
			la var plot_hec_`c'_w`p' "Plot area winsorized at `p'"
		}
		*drop unnecessary vars
		drop plot_area_`c'_*
	}
	
	*Total plot area cultivated for the 7 main crops
	egen totplot_hec=rowtotal(plot_hectares_crop_1 plot_hectares_crop_8 plot_hectares_crop_2 ///
			plot_hectares_crop_13 plot_hectares_crop_10 plot_hectares_crop_37 plot_hectares_crop_4),m
	la var totplot_hec "Total plot area for our 7 main crops"
	
	* Plot area for staple crops
	egen plot_stp=rowtotal(plot_hectares_crop_1 plot_hectares_crop_8 plot_hectares_crop_2),m
	la var plot_stp "Total plot area for staple crops"
	
	* Plot area for non staple crops
	egen plot_nstp=rowtotal(plot_hectares_crop_13 plot_hectares_crop_10 plot_hectares_crop_37 plot_hectares_crop_4),m
	la var plot_nstp "Total plot area for non staple crops"
	
	
	
	*create an inverse hyperbolic sine for plot area
	ihstrans totplot_hec
	
	foreach var in totplot_hec plot_stp plot_nstp {
		foreach p in 99 98 95 {
			* winsorize at 99, 98, 95
			winsor2 `var', suffix(_w`p') cuts(0 `p')
			la var `var'_w`p' "Total plot area winsorized at `p'"
		}
	}	
	
  	* Inputs Used
	rename inorganic_fertilizer_d fertizer_use_d
	replace fertizer_use_d = 0 if fertizer_use_d == .
	
	rename pesticide_d pyhto_use_d
	replace pyhto_use_d = 0 if pyhto_use_d == .
	replace paid_labor_d = 0 if paid_labor_d == . 
	replace tpaid_labor_d = 0 if tpaid_labor_d == . 

/************* Did a hhld cultivate a crop ****************************/

gen stp_crop_harv=0
replace stp_crop_harv=1 if r_crop_1==1|r_crop_8==1|r_crop_2==1
la var stp_crop_harv "hhld harvested a staple crop"

gen nstp_crop_harv=0
replace nstp_crop_harv=1 if r_crop_13==1|r_crop_10==1|r_crop_37==1|r_crop_4==1
la var nstp_crop_harv "hhld harvested a non staple crop"

	
/*************	Value of sales  ***********************/

*Create a variable to measure the sale amount by crop for our 7 main crops: Mil, 
* Niebe, Sorgho, Sesame, Arachide, Haricot-vert, Mais
foreach i in 1 8 2 13 10 37 4 {
	gen sale_amount_crop_`i'=0
	replace sale_amount_crop_`i'=sale_amount_1 if part_c_name_1==`i'
		
	*create a loop over other crops 
	forv v=2(1)13 {
		replace sale_amount_crop_`i'=sale_amount_`v'+sale_amount_crop_`i' if part_c_name_`v'==`i'
	}
		replace sale_amount_crop_`i'=0 if missing(sale_amount_crop_`i')
	sum sale_amount_crop_`i',d
	foreach p in 99 98 95 {	
		*winsor the variable at 99%,98% and 95% 
		winsor2 sale_amount_crop_`i', suffix(_w`p') cuts(0 `p')
		rename sale_amount_crop_`i'_w`p' sale_crp_`i'_w`p'
		la var sale_crp_`i'_w`p' "Sale amount winsorized at `p'"
		replace sale_crp_`i'_w`p'=0 if missing(sale_crp_`i'_w`p')
	}
	sum sale_amount_crop_`i',d
	
	local labelname: label r_crop_name `i'
	la var sale_amount_crop_`i' "Sale amount for `labelname'"
}

* Total value of sales for main crops
egen total_sales=rowtotal(sale_amount_crop_1 sale_amount_crop_8 sale_amount_crop_2 sale_amount_crop_13 ///
							sale_amount_crop_10 sale_amount_crop_37 sale_amount_crop_4), m
la var total_sales "Total sales for Mil, Niebe, Sorgho, Sesame, Arachide, Haricot vert and Mais"
							
* Total value of sale for staple crops: Mil, Niebe and Sorgho
egen totsale_stp=rowtotal(sale_amount_crop_1 sale_amount_crop_8 sale_amount_crop_2), m
la var totsale_stp "Total sale amount for mil, niebe and sorgho"

* Total value of sale for non-staple crops: Sesame, Arachide, Haricot-vert, Mais
egen totsale_nstp=rowtotal(sale_amount_crop_13 sale_amount_crop_10 sale_amount_crop_37 sale_amount_crop_4), m
la var totsale_nstp "Total sale amount for sesame, arachide, haricot vert and mais"

* Total sales with winsorized values
foreach p in 99 98 95 {	
	egen tot_sale_w`p'=rowtotal(sale_crp_1_w`p' sale_crp_8_w`p' sale_crp_2_w`p' ///
			sale_crp_13_w`p' sale_crp_10_w`p' sale_crp_37_w`p' sale_crp_4_w`p'), m
	la var tot_sale_w`p' "Total sale winsorized at `p'"
	
	* Staple crops
	egen totsale_stp_w`p'=rowtotal(sale_crp_1_w`p' sale_crp_8_w`p' sale_crp_2_w`p'), m
	la var totsale_stp_w`p' "Total sale of staple crops winsorized at `p'"
	
	*Non-staple crops
	egen totsale_nstp_w`p'=rowtotal(sale_crp_13_w`p' sale_crp_10_w`p' sale_crp_37_w`p' sale_crp_4_w`p'), m
	la var totsale_nstp_w`p' "Total sale of non staple crops winsorized at `p'"	
}
							
* Total value of sales on all plots irrespective of plot in the rainy season
* PB already calculated above : wet_sales_rev
	
/********* Quantity produced for the 7 main crops (after we have done the conversion) ***********/

	*Create a variable to measure the quantity harvested - Mil is 1, Niebe is 8, Sorgho is 2 Sesame, Arachide, Haricot-vert and Mais.
foreach i in 1 8 2 13 10 37 4 {
	gen harvest_q_crop_`i'=0
	*replace harvest_q_crop_`i'=. if missing(harvest_q_`i')
	replace harvest_q_crop_`i'=harvest_q_1_kg if part_c_name_1==`i'
	
	*create a loop over other crops 
	forv v=2/13 {
		replace harvest_q_crop_`i'=harvest_q_`v'_kg+harvest_q_crop_`i' if part_c_name_`v'==`i'
	}
	sum harvest_q_crop_`i'
	replace harvest_q_crop_`i'=0 if missing(harvest_q_crop_`i')
	* replace with missing if all variables/crop names are missing
	*egen num_miss=rowmiss(part_c_name*)
	*replace harvest_q_crop_`i'=. if num_miss==13
	*drop num_miss
	
	*create an inverse hyperbolic sine for plot area
	ihstrans harvest_q_crop_`i'
	rename ihs_harvest_q_crop_`i' ihs_harv_q_`i'
	
	foreach p in 99 98 95 {	
		*winsor the variable at 99%,98% and 95% 
		winsor2 harvest_q_crop_`i', suffix(_w`p') cuts(0 `p')
		rename harvest_q_crop_`i'_w`p' harv_q_crop_`i'_w`p'
			local labelname: label r_crop_name `i'
		la var harv_q_crop_`i'_w`p' "Quantity harvested of `labelname' winsorized at `p'"
		replace harv_q_crop_`i'_w`p'=0 if missing(harv_q_crop_`i'_w`p')
	}
	
	local labelname: label r_crop_name `i'
	la var harvest_q_crop_`i' "Quanity harvested of `labelname'"
	la var ihs_harv_q_`i' "IHS of quantity harvested of `labelname'"
}


* Total quantity harvested for main crops
egen total_harvest_q=rowtotal(harvest_q_crop_1 harvest_q_crop_8 harvest_q_crop_2 harvest_q_crop_13 ///
							harvest_q_crop_10 harvest_q_crop_37 harvest_q_crop_4), m
la var total_harvest_q "Total harvest quantity for 7 main crops"

*create an inverse hyperbolic sine for qty harvested
ihstrans total_harvest_q
rename ihs_total_harvest_q ihs_totharv_q
	
* Total quantity harvested for staple crops: Mil, Niebe and Sorgho
egen tot_harv_stp=rowtotal(harvest_q_crop_1 harvest_q_crop_8 harvest_q_crop_2), m
la var tot_harv_stp "Quanity harvested for staple crops"

*create an inverse hyperbolic sine 
ihstrans tot_harv_stp
rename ihs_tot_harv_stp ihs_totharv_stp

* Total quantity harvested for non-staple crops: Sesame, Arachide, Haricot-vert, Mais
egen tot_harv_nstp=rowtotal(harvest_q_crop_13 harvest_q_crop_10 harvest_q_crop_37 harvest_q_crop_4), m
la var tot_harv_nstp "Quanity harvested for non staple crops"

*create an inverse hyperbolic sine 
ihstrans tot_harv_nstp
rename ihs_tot_harv_nstp ihs_totharv_nstp
	
* Total quantity harvested with winsorized values
foreach p in 99 98 95 {	
	egen total_harv_w`p'=rowtotal(harv_q_crop_1_w`p' harv_q_crop_8_w`p' harv_q_crop_2_w`p' ///
	harv_q_crop_13_w`p' harv_q_crop_10_w`p' harv_q_crop_37_w`p' harv_q_crop_4_w`p'), m
	la var total_harv_w`p' "Total quantity harvested winsorized at `p'"
	
	* Staple crops
	egen tot_harv_stp_w`p'=rowtotal(harv_q_crop_1_w`p' harv_q_crop_8_w`p' harv_q_crop_2_w`p'), m
	la var tot_harv_stp_w`p' "Total qty harvested of staple crops winsor at `p'"
	
	*Non-staple crops
	egen tot_harv_nstp_w`p'=rowtotal(harv_q_crop_13_w`p' harv_q_crop_10_w`p' harv_q_crop_37_w`p' harv_q_crop_4_w`p'), m
	la var tot_harv_nstp_w`p' "Total qty harvested of non staple crops winsor at `p'"	
}

/************** Quantity sold for the 7 main crops (after we have done the conversion) **************/

	*Create a variable to measure the quantity sold - Mil is 1, Niebe is 8, Sorgho is 2 Sesame, Arachide, Haricot-vert and Mais.
foreach i in 1 8 2 13 10 37 4 {
	gen sale_q_crop_`i'=0
	*replace sale_q_crop_`i'=. if missing(sale_q_crop_`i')
	replace sale_q_crop_`i'=sale_q_1_kg if part_c_name_1==`i'
		
	*create a loop over other crops 
		forv v=2/13 {
			replace sale_q_crop_`i'=sale_q_`v'_kg+sale_q_crop_`i' if part_c_name_`v'==`i'
		}
		replace sale_q_crop_`i'=0 if missing(sale_q_crop_`i')
		 *replace with missing if all variables/crop names are missing
		*egen num_miss=rowmiss(part_c_name*)
		*replace sale_q_crop_`i'=. if num_miss==13
		*drop num_miss
		
		sum sale_q_crop_`i',d
	foreach p in 99 98 95 {	
		*winsor the variable at 99%,98% and 95% 
		winsor2 sale_q_crop_`i', suffix(_w`p') cuts(0 `p')
		rename sale_q_crop_`i'_w`p' sale_q_crp_`i'_w`p'
			local labelname: label r_crop_name `i'
		la var sale_q_crp_`i'_w`p' "Qty sold of `labelname' winsor at `p'" 
		replace sale_q_crp_`i'_w`p'=0 if missing(sale_q_crp_`i'_w`p')
	}
		
	local labelname: label r_crop_name `i'
	la var sale_q_crop_`i' "Quantity sold of `labelname'"
}


* Total quantity sold for main crops
egen total_sale_q=rowtotal(sale_q_crop_1 sale_q_crop_8 sale_q_crop_2 sale_q_crop_13 ///
							sale_q_crop_10 sale_q_crop_37 sale_q_crop_4), m
la var total_sale_q "Total quantity sold in kg for 7 main crops"
							
* Total qty sold for staple crops: Mil, Niebe and Sorgho
egen totsale_q_stp=rowtotal(sale_q_crop_1 sale_q_crop_8 sale_q_crop_2), m
la var totsale_q_stp "Total qty sold for staple crops"

* Total qty sold for non-staple crops: Sesame, Arachide, Haricot-vert, Mais
egen totsale_q_nstp=rowtotal(sale_q_crop_13 sale_q_crop_10 sale_q_crop_37 sale_q_crop_4), m
la var totsale_q_nstp "Total qty sold for non staple crops"

* Total quantity sold with winsorized values
foreach p in 99 98 95 {	
	egen tot_sale_q_w`p'=rowtotal(sale_q_crp_1_w`p' sale_q_crp_8_w`p' sale_q_crp_2_w`p' ///
	sale_q_crp_13_w`p' sale_q_crp_10_w`p' sale_q_crp_37_w`p' sale_q_crp_4_w`p'), m
	la var tot_sale_q_w`p' "Total quantity sold in kg for 7 main crops winsor at `p'"
							
	* Total qty sold for staple crops: Mil, Niebe and Sorgho
	egen totsale_q_stp_w`p'=rowtotal(sale_q_crp_1_w`p' sale_q_crp_8_w`p' sale_q_crp_2_w`p'), m
	la var totsale_q_stp_w`p' "Total qty sold for staple crops winsor at `p'"

	* Total qty sold for non-staple crops: Sesame, Arachide, Haricot-vert, Mais
	egen totsale_q_nstp_w`p'=rowtotal(sale_q_crp_13_w`p' sale_q_crp_10_w`p' sale_q_crp_37_w`p' sale_q_crp_4_w`p'), m
	la var totsale_q_nstp_w`p' "Total qty sold for non staple crops winsor at `p'"	
}

/****************** Did a hhld sell a given crop ********************************/
* Create a flag indicating if a household sold a given crop out of our 7 main crops
foreach i in 1 8 2 13 10 37 4 {
	gen sold_crop_`i'=0
	forv c=1/13 {
		replace sold_crop_`i'=1 if part_c_name_`c'==`i' & sale_q_`c'!=0 & sale_q_`c'!=. //e.g:1 if crop is mil and sale amount is greater than 0 
	}
	sum sold_crop_`i'
	tab sold_crop_`i' 
		local labelname: label r_crop_name `i'
	la var sold_crop_`i' "Hhld sold crop `labelname'"
}

* Create a flag if a household sold a staple crops
egen sold_staple_crop=rowtotal(sold_crop_1 sold_crop_8 sold_crop_2),m
replace sold_staple_crop=1 if sold_staple_crop>1
replace sold_staple_crop=0 if sold_staple_crop!=1
la var sold_staple_crop "Hhld sold a staple crop"

* Create a flag if a household sold a non-staple crop
egen sold_nstaple_crop=rowtotal(sold_crop_13 sold_crop_10 sold_crop_37 sold_crop_4),m
replace sold_nstaple_crop=1 if sold_nstaple_crop>1
replace sold_nstaple_crop=0 if sold_nstaple_crop!=1
la var sold_nstaple_crop "Hhld sold a non-staple crop"

* Create a flag if a household sold one of our main crops
egen sold_crop=rowtotal(sold_crop_1 sold_crop_8 sold_crop_2 sold_crop_13 sold_crop_10 sold_crop_37 sold_crop_4),m
replace sold_crop=1 if sold_crop>1
replace sold_crop=0 if sold_crop!=1
la var sold_crop "Hhld sold a main crop"

 /*****************		Value of production		*****************************/
 /*
 1. Back out selling price price from value of sales and quantity sold. Price=sales_amount/sale quantity
 2. Calculate median price by crop
 3. Calculate value of production=quantity harvested*median price
 */
 
  foreach i in 1 8 2 13 10 37 4 {
  
	local labelname: label r_crop_name `i'
	
	*1. Calculate price
	gen price_crop_`i'=sale_amount_crop_`i'/sale_q_crop_`i' 
	replace price_crop_`i'=. if sale_amount_crop_`i'==0
	
	*2. Calculate median price by crop
	gen median_price_crop_`i'=.
	sum price_crop_`i' if r_crop_`i'==1,d
	replace median_price_crop_`i'=`r(p50)'
	la var median_price_crop_`i' "Median price across crop `i'"
	sum median_price_crop_`i',d
	
	*3. Calculate value of production
	gen prod_value_crop_`i'=median_price_crop_`i'*harvest_q_crop_`i'
	la var prod_value_crop_`i' "Production value of `i'"
	
	*create an inverse hyperbolic sine 
	ihstrans prod_value_crop_`i'
	rename ihs_prod_value_crop_`i' ihs_prodv_`i'
	
	foreach p in 99 98 95 {	
		*winsor production value at 99%,98% and 95% 
		winsor2 prod_value_crop_`i', suffix(_w`p') cuts(0 `p')
		rename prod_value_crop_`i'_w`p' prod_v_crp_`i'_w`p'
			local labelname: label r_crop_name `i'
		la var prod_v_crp_`i'_w`p' "Production value of `labelname' winsor at `p'" 
		replace prod_v_crp_`i'_w`p'=0 if missing(prod_v_crp_`i'_w`p')
	}

	*drop unnecessary variable
	drop price_crop_`i'
	
  }
 
 * We now have value of production by crop. Calculate total value of production for our 7 main crops and 
 * total value of production for staple/non staple crops
 
* Total production value for 7 main crops
egen total_prod_v=rowtotal(prod_value_crop_1 prod_value_crop_8 prod_value_crop_2 prod_value_crop_13 ///
							prod_value_crop_10 prod_value_crop_37 prod_value_crop_4), m
la var total_prod_v "Total value of production for 7 main crops"
							
* Total production value for staple crops: Mil, Niebe and Sorgho
egen totprod_v_stp=rowtotal(prod_value_crop_1 prod_value_crop_8 prod_value_crop_2), m
la var totprod_v_stp "Total value of production for staple crops"

* Total production value  for non-staple crops: Sesame, Arachide, Haricot-vert, Mais
egen totprod_v_nstp=rowtotal(prod_value_crop_13 prod_value_crop_10 prod_value_crop_37 prod_value_crop_4), m
la var totprod_v_nstp "Total value of production for non-staple crops"

*create an inverse hyperbolic sine 
foreach var in total_prod_v totprod_v_stp totprod_v_nstp {
	ihstrans `var'
}

* Total quantity sold with winsorized values
foreach p in 99 98 95 {	
	* Total production value for 7 main crops
	egen tot_prod_v_w`p'=rowtotal(prod_v_crp_1_w`p' prod_v_crp_8_w`p' prod_v_crp_2_w`p' ///
						  prod_v_crp_13_w`p' prod_v_crp_10_w`p' prod_v_crp_37_w`p' prod_v_crp_4_w`p'), m
	la var tot_prod_v_w`p' "Total value of production for 7 main crops"
							
	* Total production value  for staple crops: Mil, Niebe and Sorgho
	egen prod_v_stp_w`p'=rowtotal(prod_v_crp_1_w`p' prod_v_crp_8_w`p' prod_v_crp_2_w`p'), m
	la var prod_v_stp_w`p' "Total value of production for staple crops"

	* Total production value  for non-staple crops: Sesame, Arachide, Haricot-vert, Mais
	egen prod_v_nstp_w`p'=rowtotal(prod_v_crp_13_w`p' prod_v_crp_10_w`p' prod_v_crp_37_w`p' prod_v_crp_4_w`p'), m
	la var prod_v_nstp_w`p' "Total value of production for non-staple crops"
}
 
 
    ***************************************
    ********* LIVESTOCK *******************
    ***************************************

	winsor2 hh_cow, replace cuts(2 98)
	winsor2 hh_chicken, replace cuts(2 98)
	winsor2 hh_goat, replace cuts(2 98)
	winsor2 hh_sheep, replace cuts(2 98)
	winsor2 hh_loth, replace cuts(2 98)
	
	* Average number of animals owned by HH

	egen    tot_animal      = rowtotal(hh_chicken hh_cow hh_goat hh_sheep hh_loth), mi

    gen     tot_lstock_count = tot_animal
    replace tot_lstock_count = 0 if own_livestock == 0 | tot_lstock_count == . 

	* TLU weighted Livestock Index 
	gen hh_chicken_tlu  = hh_chicken*0.01
	gen hh_cow_tlu      = hh_cow*0.70
	gen hh_goat_tlu     = hh_goat*0.10
	gen hh_sheep_tlu    = hh_sheep*0.10


	egen    tot_lstock_count_tlu = rowtotal(hh_chicken_tlu hh_cow_tlu hh_goat_tlu hh_sheep_tlu), mi
    replace tot_lstock_count_tlu = 0 if own_livestock == 0 | tot_lstock_count_tlu == . // all hhs

	egen tot_animal_tlu = rowtotal(hh_chicken_tlu hh_cow_tlu hh_goat_tlu hh_sheep_tlu), mi

	* Livestock revenue - sold
	egen    profit_livestock = rowtotal(lstock_income), mi
    replace profit_livestock = 0 if profit_livestock == . & own_livestock == 1

	* Livestock revenue - consumed
	egen    profit_cons_livestock = rowtotal(lstock_auto lprod_auto), mi
    replace profit_cons_livestock = 0 if profit_cons_livestock == . & own_livestock == 1

    gen livestock_sold     = regexm(livestock_use, "1") if own_livestock == 1
	replace livestock_sold = 0 if livestock_sold == .
    gen livestock_consumed = regexm(livestock_use, "2") if own_livestock == 1
    replace livestock_consumed = 0 if livestock_consumed == .

 
*3. Clean
  
    gen own_chicken = 1 if hh_chicken > 0 & hh_chicken != .
    replace own_chicken = 0 if own_chicken == .
	replace hh_chicken = 0 if hh_chicken == .

    gen own_goat = 1 if hh_goat > 0 & hh_goat != .
    replace own_goat = 0 if own_goat == .
	replace hh_goat = 0 if hh_goat == .

    gen own_cow = 1 if hh_cow > 0 & hh_cow != .
    replace own_cow = 0 if own_cow == .
	replace hh_cow = 0 if hh_cow == .

    gen own_sheep = 1 if hh_sheep > 0 & hh_sheep != .
    replace own_sheep = 0 if own_sheep == .
	replace hh_sheep = 0 if hh_sheep == .
	
	replace hh_loth = 0 if hh_loth == .
	
	winsor2 tpaid_labor_d,              replace cuts(2 98)
	winsor2 wet_sales_rev,              replace cuts(2 98) 
    winsor2 dry_sales_rev,              replace cuts(2 98) 
	winsor2 total_sales_rev,            replace cuts(2 98) 
	winsor2 profit_livestock,           replace cuts(2 98)  
	winsor2 profit_cons_livestock,      replace cuts(2 98) 
	winsor2 lstock_income,              replace cuts(2 98) 
	winsor2 plot_n,                 	replace cuts(2 98) 

    foreach var of varlist wet_sales_rev dry_sales_rev total_sales_rev tpaid_labor_d  profit_livestock profit_cons_livestock {
		
		replace `var' = 0 if `var' == .
        replace `var' = `var'/1000
    
    }


   * Members reared livestock
   
    gen liv_hh_mem_work_count = wordcount(livestock_hh_mem_work) // Number of HH members that cared for livestock
	replace liv_hh_mem_work_count = 0 if own_livestock == 0 | liv_hh_mem_work_count == . // unconditional on HH that had livestock
   
    label var liv_hh_mem_work_count "Number of HH members that cared for livestock"
	
   * Members cultivated land
   
   gen ag_hh_mem_work_count = wordcount(ag_hh_mem_work) // Number of HH members that cultivated land per HH
   replace ag_hh_mem_work_count = 0 if hasplots == 0 | ag_hh_mem_work_count == . // unconditional on HH that cultivate land

   label var ag_hh_mem_work_count "Number of HH members that cultivated land"

   
   * 2.5  Days cultivated land
   * -----------
      
   egen         num_days_ag_total = rowtotal(num_days_ag_*), miss // total days worked by hh
   replace      num_days_ag_total = 0 if hasplots == 0 | num_days_ag_total == . // unconditional on HH that cultivate land
   winsor2      num_days_ag_total, cuts (0 99) replace
   
   gen          num_days_ag_avg = num_days_ag_total/ag_hh_mem_work_count // avg days worked by HH for HH that cultivate land
   
   label var    num_days_ag_total       "Total number of days HH members cultivated land (0-99th)"
   label var    num_days_ag_avg         "Avg number of days HH members cultivated land"
   replace      num_days_ag_avg = 0 if num_days_ag_avg == .

   * 2.6  Days worked on livestock
   * -----------
      
   egen         num_days_lstock_total = rowtotal(num_days_livestock_*), miss // total days worked by hh
   replace      num_days_lstock_total = 0 if own_livestock == 0 | num_days_lstock_total == . // unconditional on HH that cultivate land
   winsor2      num_days_lstock_total, cuts (0 99) replace
   
   gen          num_days_lstock_avg = num_days_lstock_total/liv_hh_mem_work_count // avg days worked by HH for HH that cultivate land
   
   label var    num_days_lstock_total   "Total number of days HH members worked on livestock (0-99th)"
   label var    num_days_lstock_avg     "Avg number of days HH members worked on livestock"
   replace      num_days_lstock_avg = 0 if num_days_lstock_avg == .
   
   * 2.7  Income from livestock
   * -----------
   rename lstock_income lstock_turnover
   replace lstock_turnover = 0 if lstock_turnover == .

*4. Label
	
    label var wet_crop              "\% HHs growing crops in rainy season" // Previously dry crop season
    label var dry_crop              "\% HHs growing crops in dry season" // Previously wet crop season
    label var both_crop             "\% HHs growing crops in dry and rainy season" // Previously wet crop season
	label var own_livestock         "\% HHs rearing livestock"
    label var profit_livestock      "Profit from sold livestock and products"
    label var profit_cons_livestock "Value consumed of livestock and products"
	label var hasplots             "\% HHs that cultivated land"
	label var plot_n                "Number of plots"
    label var hh_chicken            "Number of chickens"
    label var hh_cow                "Number of cows"
    label var hh_goat               "Number of goats"
    label var hh_sheep              "Number of sheep"
    label var hh_loth               "Number of other animals"
    label var tot_lstock_count      "Total livestock count, all households"
    label var tot_animal            "Total livestock count, households with livestock"
    label var tot_lstock_count_tlu  "Tropical Livestock Unit (TLU), all households"
    label var tot_animal_tlu        "Tropical Livestock Unit (TLU), households with livestock"
    label var total_sales_rev       "Annual revenue from all crop sales in 2020 (dry and rainy season)"
    label var livestock_sold        "\% HHs that sold any livestock in the past 6 months (for HH that own animals)"
    label var livestock_consumed    "\% HHs that consumed any livestock in the past 6 months (for HH that own animals)"
    label var lstock_turnover         "Total revenue from sales of livestock in the last 6 months (for HH that sold animals)"

*5. Save
	

    save "$endline_ds/final/f_farming_livestock_construct.dta", replace
