clear all
set more off

global main "C:\Users\estca\OneDrive\Documentos\Github\intellectual-capital-banks"

globa data "$main/data"

global results "$main/results"

**************************************************************************************
* FINANCIAL ENTITIES
**************************************************************************************

// First, we analyse all banks, financial firms and cooperative banks that have public information in the Superintendency of the Securities Market (SMV), the equivalent of the Securities and Exchange Commission (SEC) for Peru.  

// We exclude two financial firms: FINANCIERA OH!, FINANCIERA QAPAC and one cooperative bank: CAJA LOS ANDES. These entities have outliers during COVID, and might cause inconsistent results.

/*** 1. PREPARE DATA ***/
clear all

import excel "$data/data_financial_entities.xlsx", firstrow

egen ENTITY_ID = group(ENTITY)

** Verify no duplicates

duplicates tag ENTITY_ID YEAR, gen(dup)

tab dup

drop dup

** Set it up as a panel
xtset ENTITY_ID YEAR

xtdescribe

xtsum

*** Verify we have a balanced panel

/*** 2. CORRELATION MATRIX ***/ 
/* Create a correlation matrix */

pwcorr VAIC HCE SCE CCE SIZE DEBT ROA, sig

*** Export it to CSV
corr VAIC HCE SCE CCE SIZE DEBT ROA
mat C = r(C)
outsheet using "$results/correlation_matrix_financial_entities.csv", replace

/*** 3. PANEL MODEL TESTS ***/
/* 3.1 HAUSMAN TEST */

*** Fixed effects 
qui xtreg ROA VAIC SIZE DEBT , fe 
estimates store FE1

qui xtreg ROA ICE HCE SCE CCE SIZE DEBT , fe 
estimates store FE2

*** Random effects
* R1
qui xtreg ROA VAIC SIZE DEBT , re
estimates store RE1

* R2
qui xtreg ROA ICE HCE SCE CCE SIZE DEBT , re
estimates store RE2

*** Hausman test

hausman FE1 RE1  
*Do not reject H0: p-value = 0.39 > 0.05
*We choose Random Effects
 
hausman FE2  RE2, sigmamore
*Reject H0: p-value = 0.00 < 0.05
*We choose Fixed Effects

// For model 1 we will use Random Effects, for model 2 we will use Fixed effects.

/* 3.2 WOOLDRIDGE AUTOCORRELATION TEST */

xtserial ROA VAIC SIZE DEBT, output
* We do not reject H0: p-value = 0.76 > 0.05
* We choose xtreg

xtserial ROA HCE SCE CCE SIZE DEBT, output
* We do not reject H0: p-value = 0.45 <0.05
* We choose xtreg

/* 3.3 VARIANCE INFLATION FACTOR (VIF) */
qui reg ROA VAIC SIZE DEBT
vif
* No multicollinearity

qui reg ROA HCE SCE CCE SIZE DEBT 
vif
* No multicollinearity

/* 3.4 FINAL MODELS */

* Model 1 - Using VAIC
xtreg ROA VAIC SIZE DEBT, re vce(robust)
estimates store MODEL1

* Model 2 - Using HCE, SCE, and CCE
qui xtreg ROA HCE SCE CCE SIZE DEBT , fe vce(robust)
estimates store MODEL2


/*** 4. RESULTS ***/

estimates table MODEL1 MODEL2,  ///
  stats(N r2_o r2_b r2_w sigma_u sigma_e rho) b(%7.4f) star 
  
esttab MODEL1 MODEL2 ///
    using "$results/econometric_results_financial_entities.doc", replace ///
    title("Regression Results") ///
    stats(N r2_o r2_b r2_w sigma_u sigma_e rho) ///
    b(%7.4f) star
	
/*** 5. ROBUSTNESS ***/

// To further validate our benchmark results, we conduct robustness checks using alternative estimation methods.
// We first estimate the two models using a Prais-Winsten (PW) regression, which corrects for AR(1) serial correlation in the error term.
// We then implement a Generalized Least Squares (FGLS) approach that accounts for both heteroskedasticity across panels and serial correlation.

/* 5.1  PRAIS-WINSTEN */
* Model 1 - PW with VAIC
xtpcse ROA VAIC SIZE DEBT, pairwise hetonly cor(ar1)
estimates store PW_MODEL1

* Model 2 - PW with HCE, SCE, and CCE
xtpcse ROA HCE SCE CCE SIZE DEBT, pairwise hetonly cor(ar1)
estimates store PW_MODEL2

/* 5.2  GENERALIZED LEAST SQUARES  */
* Model 1 - FGLS with VAIC
xtgls ROA VAIC SIZE DEBT, panels(heteroskedastic) corr(ar1)
estimates store FGLS_MODEL1

* Model 2 - FGLS with HCE, SCE, and CCE
xtgls ROA HCE SCE CCE SIZE DEBT, panels(heteroskedastic) corr(ar1)
estimates store FGLS_MODEL2

estimates table MODEL1 MODEL2 PW_MODEL1 PW_MODEL2 FGLS_MODEL1 FGLS_MODEL2, ///
  stats(N r2_o sigma_u sigma_e rho) b(%7.4f) star
  
esttab MODEL1 MODEL2 ///
    using "$results/robustness_checks_financial_entities.doc", replace ///
    title("Regression Results") ///
    stats(N r2_o r2_b r2_w sigma_u sigma_e rho) ///
    b(%7.4f) star

	
		
**************************************************************************************
* BANKS
**************************************************************************************

// We analyse the fifthteen (15) largest banks in Peru.

/*** 1. PREPARE DATA ***/
clear all
 
import excel "$data/data_banks.xlsx", firstrow

egen ENTITY_ID = group(ENTITY)

** Verify no duplicates

duplicates tag ENTITY_ID YEAR, gen(dup)

tab dup

drop dup

** Set it up as a panel
xtset ENTITY_ID YEAR

xtdescribe

xtsum

*** Verify we have a balanced panel

/*** 2. CORRELATION MATRIX ***/ 
/* Create a correlation matrix */

pwcorr VAIC HCE SCE CCE SIZE DEBT ROA, sig

*** Export it to CSV
corr VAIC HCE SCE CCE SIZE DEBT ROA
mat C = r(C)
outsheet using "$results/correlation_matrix_banks.csv", replace

/*** 3. PANEL MODEL TESTS ***/
/* 3.1 HAUSMAN TEST */

*** Fixed effects 
qui xtreg ROA VAIC SIZE DEBT , fe 
estimates store FE1

qui xtreg ROA ICE HCE SCE CCE SIZE DEBT , fe 
estimates store FE2

*** Random effects
* R1
qui xtreg ROA VAIC SIZE DEBT , re
estimates store RE1

* R2
qui xtreg ROA ICE HCE SCE CCE SIZE DEBT , re
estimates store RE2

*** Hausman test

hausman FE1 RE1  
*Do not reject H0: p-value = 0.51 > 0.05
*We choose Random Effects
 
hausman FE2  RE2
*Reject H0: p-value < 0.05
*We choose Fixed Effects

// For model 1 we will use Random Effects, for model 2 we will use Fixed effects.

/* 3.2 WOOLDRIDGE AUTOCORRELATION TEST */

xtserial ROA VAIC SIZE DEBT, output
* We reject H0: p-value = 0.00 <0.05
* We choose xtregar

xtserial ROA ICE HCE SCE CCE SIZE DEBT, output
* We reject H0: p-value = 0.00 <0.05
* We choose xtregar

/* 3.3 VARIANCE INFLATION FACTOR (VIF) */
qui reg ROA VAIC SIZE DEBT
vif
* No multicollinearity

qui reg ROA HCE SCE CCE SIZE DEBT 
vif
* No multicollinearity

/* 3.4 FINAL MODELS */

* Model 1 - Using VAIC
qui xtregar ROA VAIC SIZE DEBT, re
estimates store MODEL1

* Model 2 - Using HCE, SCE, and CCE
qui xtregar ROA HCE SCE CCE SIZE DEBT, fe
estimates store MODEL2

/*** 4. RESULTS ***/

estimates table MODEL1 MODEL2,  ///
  stats(N r2_o r2_b r2_w sigma_u sigma_e rho) b(%7.4f) star
  
esttab MODEL1 MODEL2 ///
    using "$results/econometric_results_banks.doc", replace ///
    title("Regression Results") ///
    stats(N r2_o r2_b r2_w sigma_u sigma_e rho) ///
    b(%7.4f) star
	
/*** 5. ROBUSTNESS ***/

// To further validate our benchmark results, we conduct robustness checks using alternative estimation methods.
// We first estimate the two models using a Prais-Winsten (PW) regression, which corrects for AR(1) serial correlation in the error term.
// We then implement a Generalized Least Squares (FGLS) approach that accounts for both heteroskedasticity across panels and serial correlation.

/* 5.1  PRAIS-WINSTEN */
* Model 1 - PW with VAIC
xtpcse ROA VAIC SIZE DEBT, pairwise hetonly cor(ar1)
estimates store PW_MODEL1

* Model 2 - PW with HCE, SCE, and CCE
xtpcse ROA HCE SCE CCE SIZE DEBT, pairwise hetonly cor(ar1)
estimates store PW_MODEL2

/* 5.2  GENERALIZED LEAST SQUARES  */
* Model 1 - FGLS with VAIC
xtgls ROA VAIC SIZE DEBT, panels(heteroskedastic) corr(ar1)
estimates store FGLS_MODEL1

* Model 2 - FGLS with HCE, SCE, and CCE
xtgls ROA HCE SCE CCE SIZE DEBT, panels(heteroskedastic) corr(ar1)
estimates store FGLS_MODEL2

estimates table MODEL1 MODEL2 PW_MODEL1 PW_MODEL2 FGLS_MODEL1 FGLS_MODEL2, ///
  stats(N r2_o sigma_u sigma_e rho) b(%7.4f) star
  
esttab MODEL1 MODEL2 ///
    using "$results/robustness_checks_banks.doc", replace ///
    title("Regression Results") ///
    stats(N r2_o r2_b r2_w sigma_u sigma_e rho) ///
    b(%7.4f) star

	
	
**************************************************************************************
* FINANCING FIRMS 
**************************************************************************************

// Then, we analyse a total of eight (8) financial firms excluding the previously mentioned FINANCIERA OH! and FINANCIERA QAPAC.

/*** 1. PREPARE DATA ***/
clear all

import excel "$data/data_financial_firms.xlsx", firstrow

egen ENTITY_ID = group(ENTITY)

** Verify no duplicates

duplicates tag ENTITY_ID YEAR, gen(dup)

tab dup

drop dup

** Set it up as a panel
xtset ENTITY_ID YEAR

xtdescribe

xtsum

*** Verify we have a balanced panel

/*** 2. CORRELATION MATRIX ***/ 
/* Create a correlation matrix */

pwcorr VAIC HCE SCE CCE SIZE DEBT ROA, sig

*** Export it to CSV
corr VAIC HCE SCE CCE SIZE DEBT ROA
mat C = r(C)
outsheet using "$results/correlation_matrix_financial_firms.csv", replace

/*** 3. PANEL MODEL TESTS ***/
/* 3.1 HAUSMAN TEST */

*** Fixed effects 
qui xtreg ROA VAIC SIZE DEBT , fe 
estimates store FE1

qui xtreg ROA ICE HCE SCE CCE SIZE DEBT , fe 
estimates store FE2

*** Random effects
* R1
qui xtreg ROA VAIC SIZE DEBT , re
estimates store RE1

* R2
qui xtreg ROA ICE HCE SCE CCE SIZE DEBT , re
estimates store RE2

*** Hausman test

hausman FE1 RE1  
*Do not reject H0: p-value = 0.68 > 0.05
*We choose Random Effects
 
hausman FE2  RE2
*Reject H0: p-value = 0.00 < 0.05
*We choose Fixed Effects

// For model 1 we will use Random Effects, for model 2 we will use Fixed effects.

/* 3.2 WOOLDRIDGE AUTOCORRELATION TEST */

xtserial ROA VAIC SIZE DEBT, output
* We do not reject H0: p-value = 0.23 > 0.05
* We choose xtreg

xtserial ROA ICE HCE SCE CCE SIZE DEBT, output
* We do not reject H0: p-value = 0.18 > 0.05
* We choose xtreg

/* 3.3 VARIANCE INFLATION FACTOR (VIF) */
qui reg ROA VAIC SIZE DEBT
vif
* No multicollinearity

qui reg ROA HCE SCE CCE SIZE DEBT 
vif
* No multicollinearity

/* 3.4 FINAL MODELS */

* Model 1 - Using VAIC
qui xtreg ROA VAIC SIZE DEBT , re vce(robust)
estimates store MODEL1

* Model 2 - Using HCE, SCE, and CCE
qui xtreg ROA HCE SCE CCE SIZE DEBT , fe vce(robust)
estimates store MODEL2


/*** 4. RESULTS ***/

estimates table MODEL1 MODEL2,  ///
  stats(N r2_o r2_b r2_w sigma_u sigma_e rho) b(%7.4f) star  

esttab MODEL1 MODEL2 ///
    using "$results/econometric_results_financial_firms.doc", replace ///
    title("Regression Results") ///
    stats(N r2_o r2_b r2_w sigma_u sigma_e rho) ///
    b(%7.4f) star
	
/*** 5. ROBUSTNESS ***/

// To further validate our benchmark results, we conduct robustness checks using alternative estimation methods.
// We first estimate the two models using a Prais-Winsten (PW) regression, which corrects for AR(1) serial correlation in the error term.
// We then implement a Generalized Least Squares (FGLS) approach that accounts for both heteroskedasticity across panels and serial correlation.

/* 5.1  PRAIS-WINSTEN */
* Model 1 - PW with VAIC
xtpcse ROA VAIC SIZE DEBT, pairwise hetonly cor(ar1)
estimates store PW_MODEL1

* Model 2 - PW with HCE, SCE, and CCE
xtpcse ROA HCE SCE CCE SIZE DEBT, pairwise hetonly cor(ar1)
estimates store PW_MODEL2

/* 5.2  GENERALIZED LEAST SQUARES  */
* Model 1 - FGLS with VAIC
xtgls ROA VAIC SIZE DEBT, panels(heteroskedastic) corr(ar1)
estimates store FGLS_MODEL1

* Model 2 - FGLS with HCE, SCE, and CCE
xtgls ROA HCE SCE CCE SIZE DEBT, panels(heteroskedastic) corr(ar1)
estimates store FGLS_MODEL2

estimates table MODEL1 MODEL2 PW_MODEL1 PW_MODEL2 FGLS_MODEL1 FGLS_MODEL2, ///
  stats(N r2_o sigma_u sigma_e rho) b(%7.4f) star
  
esttab MODEL1 MODEL2 ///
    using "$results/robustness_checks_financial_firms.doc", replace ///
    title("Regression Results") ///
    stats(N r2_o r2_b r2_w sigma_u sigma_e rho) ///
    b(%7.4f) star
	
	

**************************************************************************************
* COOPERATIVE BANKS (MUNICIPAL SAVINGS BANKS)
**************************************************************************************

// Finally, we analyse a total of three (3) cooperative banks excluding the CAJA LOS ANDES due to having huge financial problems during the COVID pandemic and causing inconsistent results.

/*** 1. PREPARE DATA ***/
clear all

import excel "$data/data_cooperative_banks.xlsx", firstrow

egen ENTITY_ID = group(ENTITY)

** Verify no duplicates

duplicates tag ENTITY_ID YEAR, gen(dup)

tab dup

drop dup

** Set it up as a panel
xtset ENTITY_ID YEAR

xtdescribe

xtsum

*** Verify we have a balanced panel

/*** 2. CORRELATION MATRIX ***/ 
/* Create a correlation matrix */

pwcorr VAIC HCE SCE CCE SIZE DEBT ROA, sig

*** Export it to CSV
corr VAIC HCE SCE CCE SIZE DEBT ROA
mat C = r(C)
outsheet using "$results/correlation_matrix_cooperative_banks.csv", replace

/*** 3. PANEL MODEL TESTS ***/
/* 3.1 HAUSMAN TEST */

*** Fixed effects 
qui xtreg ROA VAIC SIZE DEBT , fe 
estimates store FE1

qui xtreg ROA ICE HCE SCE CCE SIZE DEBT , fe 
estimates store FE2

*** Random effects
* R1
qui xtreg ROA VAIC SIZE DEBT , re
estimates store RE1

* R2
qui xtreg ROA ICE HCE SCE CCE SIZE DEBT , re
estimates store RE2

*** Hausman test

hausman FE1 RE1, sigmamore  
*Do not reject H0: p-value = 0.21 > 0.05
*We choose Random Effects
 
hausman FE2  RE2
*Do not reject H0: p-value = 0.88 > 0.05
*We choose Random Effects

// For model 1 we will use Random Effects, for model 2 we will use Fixed effects.

/* 3.2 WOOLDRIDGE AUTOCORRELATION TEST */

xtserial ROA VAIC SIZE DEBT, output
* Do not reject H0: p-value = 0.09 > 0.05
* We choose xtreg

xtserial ROA ICE HCE SCE CCE SIZE DEBT, output
* Do not reject H0: p-value = 0.55 > 0.05
* We choose xtreg

/* 3.3 VARIANCE INFLATION FACTOR (VIF) */
qui reg ROA VAIC SIZE DEBT
vif
* No multicollinearity

qui reg ROA HCE SCE CCE SIZE DEBT 
vif
* Multicollinearity between HCE and SCE

/* 3.4 FINAL MODELS */

* Model 1 - Using VAIC
qui xtreg ROA VAIC SIZE DEBT , re vce(robust)
estimates store MODEL1

* Model 2 - Using HCE, SCE, and CCE
qui xtreg ROA HCE SCE CCE SIZE DEBT , re vce(robust)
estimates store MODEL2


/*** 4. RESULTS ***/

estimates table MODEL1 MODEL2,  ///
  stats(N r2_o r2_b r2_w sigma_u sigma_e rho) b(%7.4f) star  

esttab MODEL1 MODEL2 ///
    using "$results/econometric_results_cooperative_banks.doc", replace ///
    title("Regression Results") ///
    stats(N r2_o r2_b r2_w sigma_u sigma_e rho) ///
    b(%7.4f) star
	
/*** 5. ROBUSTNESS ***/

// To further validate our benchmark results, we conduct robustness checks using alternative estimation methods.
// We first estimate the two models using a Prais-Winsten (PW) regression, which corrects for AR(1) serial correlation in the error term.
// We then implement a Generalized Least Squares (FGLS) approach that accounts for both heteroskedasticity across panels and serial correlation.

/* 5.1  PRAIS-WINSTEN */
* Model 1 - PW with VAIC
xtpcse ROA VAIC SIZE DEBT, pairwise hetonly cor(ar1)
estimates store PW_MODEL1

* Model 2 - PW with HCE, SCE, and CCE
xtpcse ROA HCE SCE CCE SIZE DEBT, pairwise hetonly cor(ar1)
estimates store PW_MODEL2

/* 5.2  GENERALIZED LEAST SQUARES  */
* Model 1 - FGLS with VAIC
xtgls ROA VAIC SIZE DEBT, panels(heteroskedastic) corr(ar1)
estimates store FGLS_MODEL1

* Model 2 - FGLS with HCE, SCE, and CCE
xtgls ROA HCE SCE CCE SIZE DEBT, panels(heteroskedastic) corr(ar1)
estimates store FGLS_MODEL2

estimates table MODEL1 MODEL2 PW_MODEL1 PW_MODEL2 FGLS_MODEL1 FGLS_MODEL2, ///
  stats(N r2_o sigma_u sigma_e rho) b(%7.4f) star
  
esttab MODEL1 MODEL2 PW_MODEL1 PW_MODEL2 FGLS_MODEL1 FGLS_MODEL2 ///
    using "$results/robustness_checks_cooperative_banks.doc", replace ///
    title("Regression Results") ///
    stats(N r2_o r2_b r2_w sigma_u sigma_e rho) ///
    b(%7.4f) star

	
	