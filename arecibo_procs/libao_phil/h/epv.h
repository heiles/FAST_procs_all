; epv: ephemeris position velocity info of earth center from de403
;      ephemeris
;
;/* taken from $Log: EPV.h,v $
; * Revision 1.4  1997/05/29 21:21:18  nolan
; * Changed some comments.  Added EpvClose
; *
; * Revision 1.3  1997/05/28 00:45:28  nolan
; * Separated high-level routines into EPV.c.  Low level data formats are
; * hidden in structs
; *
; * Revision 1.2  1997/05/21 00:32:10  nolan
; * const was just a pain
; *
; * Revision 1.1  1997/05/21 00:17:05  nolan
; * Initial revision
; * */
;
;/* Constants used in EBPosVel.  KMperAU is from DE403.  */
;
EPV_SECperDAY=86400.D
EPV_KMperAU=149597870.691D
;
; Interval over which the chebychev polynomials are interpolated. 
; They shouldn't necessarily be evaluated this far out.  Chosen to be
; representable in base 2 
;
EPV_T1=(-0.0625D)
EPV_T2=(1.1875D)
;
; And these are how far the polynomials should be evaluated to 
; achieve stated interpolation accuracy 
;
; 45 minutes before */
;
EPV_MINT=(-.03125D) 
; 3 hours after 
EPV_MAXT=(1.125D)
;
; default location for the polynomials..
;   these are all defined in epvinput.
;   EPV_DEFAULT_CHEBFILE 'data/epv_chebfile'
;   EPV_CHEBORDER=5
;	EPV_NUMCOEF  =6
;   EPV_CHFORMATID=1
;
EPV_CHEBORDER=5
EPV_NUMCOEF  =6

;
a={ EPV_CHBHEADER  ,$ 
	headersize: 0L,$
    formatid  : 0L,$
    mjd1      : 0L,$
    mjd2      : 0L,$
    ncoef     : 0L,$
    order     : 0L,$
    datasize  : 0L,$
    dummy1    : 0L $
  } 
;
a={EPV_CHBDAY ,$
           mjd:0L,$
       dummy1:0L,$
;
; 	note the switch in the array dimensions. the data is written in C order
; 	we, access in idl /fortran order
;   cheborder loops over the fit coefs for 1 object,x,y,z,vx,vy,vz
;   numcoef loops over the 6 objects we  fit for x,y,z,vx,vy,vz
;      chebvals:dblarr(EPV_NUMCOEF,EPV_CHEBORDER)$
       chebvals:dblarr(EPV_CHEBORDER,EPV_NUMCOEF)$
  } 
;
; this array is allocated dynamically in epvinput
; holds the data for all the days requested
;a={EPV_INFO ,$
;          hdr:{EPV_CHBHEADER},$;
;		   ndays: 0L		  ,$; number of days of data we have 
;          dayI :replicate({EPV_CHBDAY},ndays)}; one entry per day
