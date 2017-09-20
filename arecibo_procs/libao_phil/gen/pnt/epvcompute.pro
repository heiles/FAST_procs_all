;+
;NAME:
;epvcompute - compute earth pos/vel in solar sys barycenter
;SYNTAX: npnts=epvcompute(date,epvI,posvelI)
;  ARGS:
;   date[n]: double  mjd data and fraction of day to compute the
;                    earth pos/velocity. The fractional part of the day
;                    is TDB time (see times below).
;   epvI   : {}      info read in using epvinput. The requested dates
;                    need to lie within the range specified in the 
;                    epvinput call.
;KEYWORDS:
;   au     :        If set then return data as au and au/day. The
;                   default is km and km/sec
;RETURNS:
;   npnts:  long    the number of dates returned in posVelI.
;                   It will return 0 if one or more of the dates requested
;                   were not included in the epvI structure.
;posVelI[6,npnts]:double the position,velocity info of the earth
;                   center for the npnts dates requested. The order 
;                   is x,y,z,vx,vy,vz. Units are km and km/sec
;
;DESCRPIPTION:
;   epvcompute returns the position and velocity of the Center of 
;   the Earth with respect to the Solar System Barycenter at a given
;   TDB time.  The values are interpolated from the JPL ephemeris DE403, as
;   provided by their fortran routine dpleph.  Their polynomials were 
;   re-interpolated onto approximately one-day intervals using the
;   numerical recipes routines.  
;       The user inputs the daily polynomials with the epvinput() routine. 
;   The information is stored in the epvI strucuture. The posVel info
;   can then be computed with this routine. The requested dates passed
;   into  epvcompute must lie within the range of data input by epvinput.
;   If not, this routine will routine 0.
;
;   The returned double posVelI[6,N] array is X, Y, Z, Vx, Vy, Vz
;   in J2000 equatorial coordinates (actually the IERS frame).  Units
;   are km and km/sec.
;
;   The format is *hard-coded* to 5th order Chebychev polynomials, and
;   c(1) is multiplied by 0.5, so that that needn't be done in the
;   evaluator.
;
; -Mike Nolan 1997 May 29
;   with mods by phil 27mar98.
;
; EXAMPLES:
;; 
;; input the polynomial info. get the first 10 days of 2004
;;
;   jdTomjd=2400000.5D
;   year=2004D
;   day1=1D
;   ndays=10
;   mjd1=daynotojul(day1,year) - jdtomjd
;   istat=epvinput(mjd1,mjd2,epvI,ndays=ndays)
;;
;; now compute pos/vel at 0 hours TDB start of each day.
;; return data in au, au/day
;;
;   dateAr=dblarr(10) + mjd1
;   n=epvcompute(dateAr,epvI,posVelI,/au)
;; 
;
;NOTES:
;1. The routine is vectorized so it can do multiple dates at the
;   same time (as long as the dates are in epvI).
;2. TIMES:
; TDB is barycentric dynamic time. This is the same as TDT to within
;       1.6 ms. 
; TDT tereserial dynamic time. TDT=TAI + 32.184 secs
; TAI atomic time..  TAI = UTC + cumulative leap seconds (about 32 
;        and counting).
;-
function epvcompute,date,epvI,posVelI,au=au

    SECperDAY=86400D
    KMperAU  =149597870.691D

   idate=long(date)
   ndate=n_elements(date)
;
;   compute indices into dayI using first mjd of the array
;
   ii= idate - epvI.dayI[0].mjd
   ind=where((ii lt 0) or (ii ge epvI.ndays),count) 
   if count gt 0 then return,0
;
    dayFract=date-idate

;  t1 is the normalized Chebychev time 

   t0 = 1D
   t1 = (2D * dayFract - (epvI.t1 + epvI.t2)) * (1D / (epvI.t2 - epvI.t1))
   twot = t1 * 2D;
   t2 = twot * t1 - t0;
   t3 = twot * t2 - t1;
   t4 = twot * t3 - t2;
   posVelI=dblarr(6,ndate)
   convertAU=dblarr(6) + 1D
   if not keyword_set(au) then begin
    convertAU[0:2]=KMperAU
    convertAU[3:5]=(KMperAU/SecPerDay)
   endif

   for i=0,5 do  $
       posVelI[i,*]=convertAU[i]* $
        (epvI.dayI[ii].chebVals[0,i]       + $
        (epvI.dayI[ii].chebVals[1,i]*t1   + $
        (epvI.dayI[ii].chebVals[2,i]*t2  + $
        (epvI.dayI[ii].chebVals[3,i]*t3 + $
         epvI.dayI[ii].chebVals[4,i]*t4 ))))

   return,ndate
end
