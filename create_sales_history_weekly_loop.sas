/***********************************************************************/
/*Type: Import (done each week)*/
/*Use: Used as standalone program (fill in parameters at macro call line [%create_sales_history_weekly(shw_year=YYYY, shw_week=WW);] and press run).*/

/*Purpose: Used in extrapolation. 
          Imports Sales from Running Sales (weekly download from SAP). shw_year is the year of imported running sales, shw_week is the week of imported running sales*/

/*IN: dmproc.orders_all*/

/*OUT: shw.raw_YYYY_wk&WW_all (all columns)
     shw.shw_YYYY_wk&WW_all (essential columns)*/

/***********************************************************************/
%include "C:\SAS\APPLICATIONS\SAS\configuration.sas";

%macro create_sales_history_weekly(shw_year=, shw_week=);

  data shw.raw_&shw_year._wk&shw_week._all;
    set dmproc.orders_all;
    format current_season_start current_week_date  yymmdd10.;
    retain current_week_date current_year current_week;

    if _n_=1 then
      do;
        current_year=&shw_year.;
        current_week=&shw_week.;
        current_week_date=input(put(current_year, 4.)||'W'||put(current_week, z2.)||'01', weekv9.);
      end;

    if ^missing(season_week_start) then
      do;
        current_season_start=input(put(current_year, 4.)||'W'||put(season_week_start, z2.)||'01', weekv9.);

        if current_week_date >= current_season_start then
          do;
            current_season=current_year;
          end;
        else
          do;
            current_season=current_year-1;
          end;
      end;

    if current_season=order_season then
      output;
  run;

  data shw.shw_&shw_year._wk&shw_week._all(keep=sls_org sls_off shipto_cntry material variety SchedLine_Cnf_deldte cnf_qty order_type mat_div rsn_rej_cd soldto_nr);
    set shw.raw_&shw_year._wk&shw_week._all;
  run;

%mend create_sales_history_weekly;


%MACRO loop_hist(year_loop=,weekstart=,weekend=);
  %DO week_1 = &weekstart %TO &weekend;
%create_sales_history_weekly(shw_year=&year_loop, shw_week=&week_1);
%END;
%MEND;


/*%loop_hist(year_loop=2018,weekstart=15,weekend=52);*/
/*%loop_hist(year_loop=2019,weekstart=1,weekend=52);*/
/*%loop_hist(year_loop=2020,weekstart=1,weekend=53);*/
%loop_hist(year_loop=2021,weekstart=1,weekend=52);
%loop_hist(year_loop=2022,weekstart=1,weekend=21);
%loop_hist(year_loop=2018,weekstart=1,weekend=14);
 