cd C:\Users\Lyn_Sofiya\Desktop\Assignment\

import delimited "C:\Users\Lyn_Sofiya\Desktop\Assignment\CountriesData.csv", varnames(1) stringcols(3 4) numericcols(1 5 6 7)

save C:\Users\Lyn_Sofiya\Desktop\Assignment\CountriesAnalysis.dta, replace

*obsering data, changing the long names into short ones

rename gdpperpersonemployedconstant2017 GDPperCap
rename co2emissionsktenatmco2ekt CO2Total
rename populationtotalsppoptotl PopulationTotal
rename countryname country
rename time year

*Transforming countries into string data and droping them
replace country = subinstr(country, " ", "_", .)

*Generating new variable CO2 emission per capita
gen CO2perCapita = CO2Total/PopulationTotal
lab var CO2perCapita "Emission of CO2 per capita in kt"
gen ln_CO2perCapita = ln(CO2perCapita)
gen lnGDPperCap = ln(GDPperCap)
lab var lnGDPperCap "Logarithm of GDP per capita"

drop if country=="Kosovo"


*Cross sectional OLS for year 2005

reg ln_CO2perCapita lnGDPperCap if year == 2005, robust

/*
Linear regression                               Number of obs     =         15
                                                F(1, 13)          =       1.65
                                                Prob > F          =     0.2212
                                                R-squared         =     0.1239
                                                Root MSE          =     .72389

------------------------------------------------------------------------------
             |               Robust
ln_CO2perC~a | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
 lnGDPperCap |   .5975985   .4650591     1.28   0.221    -.4071005    1.602297
       _cons |  -11.64212   4.842007    -2.40   0.032    -22.10264   -1.181602
------------------------------------------------------------------------------

*/

*Cross sectional OLS for 2010

reg ln_CO2perCapita lnGDPperCap if year == 2010, robust

/*
Linear regression                               Number of obs     =         15
                                                F(1, 13)          =       3.28
                                                Prob > F          =     0.0934
                                                R-squared         =     0.2447
                                                Root MSE          =     .66549

------------------------------------------------------------------------------
             |               Robust
ln_CO2perC~a | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
 lnGDPperCap |   1.180691   .6521222     1.81   0.093    -.2281338    2.589515
       _cons |  -17.83012   6.898659    -2.58   0.023    -32.73377   -2.926475
------------------------------------------------------------------------------


. 
*/

*Preparing variables for FD and FE model

egen id = group(country)
tab id
lab var id "ID of country"

xtset id year, yearly

gen d_ln_CO2perCapita = d.ln_CO2perCapita
gen d_lnGDPperCap= d.lnGDPperCap

*First Different model with time trend, no lags

reg d_ln_CO2perCapita d_lnGDPperCap, cluster(country)

/*

Linear regression                               Number of obs     =        392
                                                F(1, 14)          =      44.97
                                                Prob > F          =     0.0000
                                                R-squared         =     0.1457
                                                Root MSE          =     .11032

                                (Std. err. adjusted for 15 clusters in country)
-------------------------------------------------------------------------------
              |               Robust
d_ln_CO2per~a | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
--------------+----------------------------------------------------------------
d_lnGDPperCap |   .6328288   .0943697     6.71   0.000     .4304259    .8352318
        _cons |  -.0178985   .0063434    -2.82   0.014    -.0315037   -.0042933
-------------------------------------------------------------------------------



. 
*/


*First Different model with time trend, 2 year lags
reg d_ln_CO2perCapita L(0/2).d_lnGDPperCap, cluster(country)

/*
Linear regression                               Number of obs     =        362
                                                F(3, 14)          =       4.33
                                                Prob > F          =     0.0234
                                                R-squared         =     0.1211
                                                Root MSE          =     .09622

                                (Std. err. adjusted for 15 clusters in country)
-------------------------------------------------------------------------------
              |               Robust
d_ln_CO2per~a | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
--------------+----------------------------------------------------------------
d_lnGDPperCap |
          --. |   .5393331   .2000694     2.70   0.017      .110227    .9684393
          L1. |    .103204   .2188185     0.47   0.644    -.3661149     .572523
          L2. |   .0613905    .106473     0.58   0.573    -.1669714    .2897524
              |
        _cons |  -.0136354   .0071282    -1.91   0.076    -.0289238     .001653
-------------------------------------------------------------------------------

*/


*First Different model with time trend, 6 year lags */

reg d_ln_CO2perCapita L(0/6).d_lnGDPperCap, cluster(country)
/*
reg d_ln_CO2perCapita L(0/6).d_lnGDPperCap, cluster(country)

Linear regression                               Number of obs     =        302
                                                F(7, 14)          =       8.60
                                                Prob > F          =     0.0004
                                                R-squared         =     0.0961
                                                Root MSE          =     .08406

                                (Std. err. adjusted for 15 clusters in country)
-------------------------------------------------------------------------------
              |               Robust
d_ln_CO2per~a | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
--------------+----------------------------------------------------------------
d_lnGDPperCap |
          --. |   .5767693   .1795401     3.21   0.006      .191694    .9618445
          L1. |  -.0887141   .2387848    -0.37   0.716    -.6008565    .4234283
          L2. |  -.1449015   .1869467    -0.78   0.451    -.5458622    .2560592
          L3. |  -.0541354   .0907572    -0.60   0.560    -.2487903    .1405195
          L4. |   .0208015   .1196542     0.17   0.864    -.2358313    .2774343
          L5. |  -.0330616   .0722828    -0.46   0.654    -.1880929    .1219696
          L6. |   .0869616   .0526752     1.65   0.121    -.0260154    .1999385
              |
        _cons |   .0025125    .008555     0.29   0.773    -.0158361    .0208611
-------------------------------------------------------------------------------

*/


*Fixed Effect Model for time

xtreg ln_CO2perCapita lnGDPperCap i.year, fe cluster(country)

/*

Fixed-effects (within) regression               Number of obs      =       407
Group variable: id                              Number of groups   =        15

R-sq:  Within  = 0.3094                         Obs per group: min =        23
       Between = 0.2127                                        avg =      27.1
       Overall = 0.1865                                        max =        28

                                                F(14,14)           =         .
corr(u_i, Xb)  = 0.2009                         Prob > F           =         .

                               (Std. err. adjusted for 15 clusters in country)
------------------------------------------------------------------------------
             |               Robust
ln_CO2perC~a | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
 lnGDPperCap |   .3154509   .2795047     1.13   0.278     -.284027    .9149288
             |
        year |
       1993  |  -.1316711   .0702856    -1.87   0.082    -.2824187    .0190766
       1994  |  -.3491497   .1570467    -2.22   0.043    -.6859814   -.0123181
       1995  |  -.3254644   .1524197    -2.14   0.051    -.6523721    .0014433
       1996  |  -.3927889   .1752964    -2.24   0.042    -.7687624   -.0168154
       1997  |  -.3967454   .1542476    -2.57   0.022    -.7275736   -.0659172
       1998  |  -.3828165   .1553652    -2.46   0.027    -.7160418   -.0495912
       1999  |   -.439181   .1726667    -2.54   0.023    -.8095143   -.0688477
       2000  |  -.3980755   .1626579    -2.45   0.028    -.7469421   -.0492089
       2001  |  -.4234503   .1739057    -2.43   0.029    -.7964409   -.0504598
       2002  |  -.4303469   .1907432    -2.26   0.041    -.8394504   -.0212434
       2003  |  -.3786569   .1929447    -1.96   0.070    -.7924821    .0351683
       2004  |  -.3660531   .1936373    -1.89   0.080    -.7813639    .0492576
       2005  |  -.3545104    .185698    -1.91   0.077    -.7527929    .0437722
       2006  |  -.3394336   .1911176    -1.78   0.097    -.7493402    .0704729
       2007  |  -.3151907   .1928525    -1.63   0.124    -.7288181    .0984367
       2008  |  -.2974755   .2000968    -1.49   0.159    -.7266403    .1316894
       2009  |   -.387337   .1879744    -2.06   0.058    -.7905021     .015828
       2010  |  -.3523003    .203229    -1.73   0.105    -.7881833    .0835826
       2011  |  -.2868651   .2007891    -1.43   0.175    -.7175149    .1437847
       2012  |  -.3034706   .2013741    -1.51   0.154     -.735375    .1284338
       2013  |  -.3337364   .2049521    -1.63   0.126    -.7733149    .1058422
       2014  |  -.3523649   .2132918    -1.65   0.121    -.8098303    .1051005
       2015  |   -.347032   .2145416    -1.62   0.128    -.8071779     .113114
       2016  |  -.3454804   .2105452    -1.64   0.123     -.797055    .1060943
       2017  |  -.3160218   .2165147    -1.46   0.166    -.7803995     .148356
       2018  |  -.3189369   .2247113    -1.42   0.178    -.8008947    .1630209
       2019  |  -.3115768    .227206    -1.37   0.192    -.7988853    .1757317
             |
       _cons |  -8.385642   2.807176    -2.99   0.010    -14.40643   -2.364849
-------------+----------------------------------------------------------------
     sigma_u |  .66707896
     sigma_e |  .23553651
         rho |   .8891497   (fraction of variance due to u_i)
------------------------------------------------------------------------------

*/
