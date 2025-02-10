clear all
set more off

global ruta "C:\Users\estca\OneDrive\Documentos\Github\intellectual-capital-banks"

globa data "$ruta/data"

**************************************************************************************
* ALL FINANCIAL ENTITIES
**************************************************************************************

/*** 1. Import the data ***/
clear all

import excel "$data/data_entidades_final.xlsx", firstrow

egen ENTITY_ID = group(ENTITY)

** Verify no duplicates

duplicates tag ENTITY_ID YEAR, gen(dup)

tab dup

drop dup

** Set it up as a panel
xtset ENTITY_ID YEAR

xtdescribe

xtsum

*** We have a balanced panel

/*** 2. CORRELATION MATRIX ***/ 
/* Create a correlation matrix */

pwcorr VAIC HCE SCE CCE SIZE DEBT ROA, sig

/*** 3. PANEL MODEL TESTS */
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

/* 3.4 BREUSCH-PAGAN */
qui xtreg ROA VAIC SIZE DEBT , re
xttest0

qui xtreg ROA HCE SCE CCE SIZE DEBT, re 
xttest0

/* 3.4 FINAL MODELS */

* Model 1
qui xtreg ROA VAIC SIZE DEBT , re 
estimates store MODEL1

* Model 2
qui xtreg ROA HCE SCE CCE SIZE DEBT , fe
estimates store MODEL2


/*** 4. RESULTS */

estimates table MODEL1 MODEL2,  ///
  stats(N r2_o r2_b r2_w sigma_u sigma_e rho) b(%7.4f) star  


**************************************************************************************
* BANKS
**************************************************************************************

/*** 1. Import the data ***/
clear all
 
import excel "$data/data_bancos_final.xlsx", firstrow

egen ENTITY_ID = group(ENTITY)

** Verify no duplicates

duplicates tag ENTITY_ID YEAR, gen(dup)

tab dup

drop dup

** Set it up as a panel
xtset ENTITY_ID YEAR

xtdescribe

xtsum

*** We have a balanced panel

/*** 2. CORRELATION MATRIX ***/ 
/* Create a correlation matrix */

pwcorr VAIC HCE SCE CCE SIZE DEBT ROA, sig

/*** 3. PANEL MODEL TESTS */
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

* Model 1
qui xtregar ROA VAIC SIZE DEBT , re 
estimates store MODEL1

* Model 2
qui xtregar ROA HCE SCE CCE SIZE DEBT , fe
estimates store MODEL2


/*** 4. RESULTS */

estimates table MODEL1 MODEL2,  ///
  stats(N r2_o r2_b r2_w sigma_u sigma_e rho) b(%7.4f) star  

**************************************************************************************
* FINANCING FIRMS 
**************************************************************************************

/*** 1. Import the data ***/
clear all

import excel "$data/data_financieras_final.xlsx", firstrow

egen ENTITY_ID = group(ENTITY)

** Verify no duplicates

duplicates tag ENTITY_ID YEAR, gen(dup)

tab dup

drop dup

** Set it up as a panel
xtset ENTITY_ID YEAR

xtdescribe

xtsum

*** We have a balanced panel

/*** 2. CORRELATION MATRIX ***/ 
/* Create a correlation matrix */

pwcorr VAIC HCE SCE CCE SIZE DEBT ROA, sig

/*** 3. PANEL MODEL TESTS */
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

* Model 1
qui xtreg ROA VAIC SIZE DEBT , re 
estimates store MODEL1

* Model 2
qui xtreg ROA HCE SCE CCE SIZE DEBT , fe
estimates store MODEL2


/*** 4. RESULTS */

estimates table MODEL1 MODEL2,  ///
  stats(N r2_o r2_b r2_w sigma_u sigma_e rho) b(%7.4f) star  



**************************************************************************************
* COOPERATIVE BANKS (MUNICIPAL SAVINGS BANKS)
**************************************************************************************

/*** 1. Import the data ***/
clear all

import excel "$data/data_cajas_final.xlsx", firstrow

egen ENTITY_ID = group(ENTITY)

** Verify no duplicates

duplicates tag ENTITY_ID YEAR, gen(dup)

tab dup

drop dup

** Set it up as a panel
xtset ENTITY_ID YEAR

xtdescribe

xtsum

*** We have a balanced panel

/*** 2. CORRELATION MATRIX ***/ 
/* Create a correlation matrix */

pwcorr VAIC HCE SCE CCE SIZE DEBT ROA, sig

/*** 3. PANEL MODEL TESTS*/
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

* Model 1
qui xtreg ROA VAIC SIZE DEBT , re 
estimates store MODEL1

* Model 2
qui xtreg ROA HCE SCE CCE SIZE DEBT , re
estimates store MODEL2


/*** 4. RESULTS */

estimates table MODEL1 MODEL2,  ///
  stats(N r2_o r2_b r2_w sigma_u sigma_e rho) b(%7.4f) star  

