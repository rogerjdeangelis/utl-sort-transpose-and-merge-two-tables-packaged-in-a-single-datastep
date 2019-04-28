Sort transpose and merge two tables packaged in a single datastep

  Two Solutions

      1. Classic sort transpose and then merge
      2, DOSUBL to get size of array and sort then merge in the same daatstep

SAS Forum
https://tinyurl.com/y4w35bh9
https://communities.sas.com/t5/SAS-Programming/Merge-two-tables-and-create-new-columns-for-values-that-match/m-p/554598

Novinosrin
https://communities.sas.com/t5/user/viewprofilepage/user-id/138205

*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

data table1;
 input Week Brand $ avgPrice ;
cards4;
1 CHEVY 111
2 CHEVY 222
1 FORD 333
2 FORD 444
1 KIA 555
2 KIA 666
;;;;
run;quit;

data table2(sortedby=week);
input fam $ week brand $ dollars ;
cards4;
SMITH 1 FORD 32
JOHNSON 2 FORD 25
;;;;
run;quit;

 WORK.TABLE1 total obs=6

 WEEK    BRAND    AVGPRICE

   1     CHEVY       111
   2     CHEVY       222
   1     FORD        333
   2     FORD        444
   1     KIA         555
   2     KIA         666


 WORK.TABLE2 total obs=2

   FAM      WEEK    BRAND    DOLLARS

 SMITH        1     FORD        32
 JOHNSON      2     FORD        25


*           _
 _ __ _   _| | ___  ___
| '__| | | | |/ _ \/ __|
| |  | |_| | |  __/\__ \
|_|   \__,_|_|\___||___/

;

* Table1 sorted on week to show process
                                                            OUTPUT
 WORK.TABLE1 total obs=6                                  +
                                                          |                                PRICE   PRICE   PRICE
 WEEK    BRAND    AVGPRICE    FAM   WEEK  BRAND  DOLLARS  |     FAM   WEEK  BRAND  DOLLARS  BRAND1  BRAND2  BRAND3
                                                          |
   1     CHEVY       111    SMITH     1   FORD      32    |   SMITH     1   FORD      32      111    333     555
   1     FORD        333                                  |
   1     KIA         555                                  |
                                                          |
   2     CHEVY       222   JOHNSON    2   FORD      25    | JOHNSON     2   FORD      25      222    444     666
   2     KIA         666                                  |
   2     FORD        444                                  |

*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

WORK.WANT total obs=2

                                PRICE   PRICE   PRICE
     FAM   WEEK  BRAND  DOLLARS  BRAND1  BRAND2  BRAND3

   SMITH     1   FORD      32      111    333     555
 JOHNSON     2   FORD      25      222    444     666

*
 _ __  _ __ ___   ___ ___  ___ ___
| '_ \| '__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
;

*******************************************
1. Classic sort transpose and then merge  *
*******************************************

proc sort data=table1 out=temp(keep=week avgprice);
by week;
run;

proc transpose data=temp out=_temp(drop=_name_) prefix=Pricebrand;
by week;
var avgprice ;
run;

data want;
merge table2 _temp;
by week;
run;


**************************************************************************
2, DOSUBL to get size of array and sort then merge in the same daatstep  *
**************************************************************************

data want;

  if _n_=0 then do; %let rc=%sysfunc(dosubl('
     proc sql;
        select count (distinct brand) into :maxBrn trimmed from table1;
        create table tab1Srt as select * from table1 order by week, brand;
      quit;
     '));
  end;

  merge table2 tab1Srt(drop=brand);
  by week;

  retain idx 0 pricebrand1-pricebrand&maxBrn;
  array pricebrands[&maxBrn] pricebrand1-pricebrand&maxBrn;

  idx + 1;
  pricebrands[idx]=avgPrice;

  if last.week then do;
      output;
      idx=0;
  end;
  drop idx;

run;quit;

