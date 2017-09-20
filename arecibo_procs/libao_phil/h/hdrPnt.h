;
; pnthdr
;
; measured values
;
a={hdrpntm, azTTD:			      0L,$; az position end rec. 1/10000 degrees 
   		    grTTD:                0L,$; gr position end rec. 1/10000 degrees
            chTTD:                0L,$; za position end rec. 1/10000 degrees 
       agcTmStamp: 		          0L,$; above time stamp position millisecs 
         turPosRd:                0.,$; turret position radians  
       turTmStamp:                0L,$; millisecs                              
          tdPosIn: fltarr(3,/nozero),$; jack position  inches
        tdTmStamp: lonarr(3,/nozero),$; seconds ?
      platformHgt: fltarr(3,/nozero),$; platform height feet
     platformTemp:                0.,$; deg F 
  platformTmStamp:                0L,$; seconds
           terPos: fltarr(3,/nozero),$; tertiary position                    
       terTmStamp:                0L,$
           filler: lonarr(3,/nozero)}
;
; requested values
;
a={hdrpntr,					         $	
		  ut1Frac:               0.D,$; fraction of day ut1 
           lastRd:               0.D,$; local apparent siderial time
              mjd:                0L,$; modified julian day(ut1)
; compute utcFrac as secMid/86400 +4/24                           
; compute dut1 as (ut1Frac - utcFrac)  checking for crossovers   
       yearDaynum:                0L,$; ast yyyyddd                      
         reqPosRd: fltarr(2,/nozero),$
         reqOffRd: fltarr(2,/nozero),$
     reqRateRdSec: fltarr(2,/nozero),$
dayNumAstRateStart:              0.D,$; when rate applied            
         raJCumRd:                0.,$
        decJCumRd:                0.,$
       geoVelProj:               0.D,$; fraction of c 
     helioVelProj:			     0.D,$; ditto
  posCorrectionRd: fltarr(2,/nozero),$; az,za position correction.
      modelLocDeg: fltarr(2,/nozero),$; loc where model evaluated (degrees)
           secMid:                0L,$; secs from midnight ast for these things
           filler:            0L}
; 
;  statword
;
;typedef struct {
;            unsigned int    filler:9;
;            unsigned int    modelCor:1;  /* 1--> model, 0--> encoder offset*/
;            unsigned int    grMaster:1;  /* 1--> gregorian master*/
;            unsigned int    tracking:1;  /* within tolerance and settled*/
;        /*
;         * PNTCOORD
;        */
;            unsigned int    coordValid :1; /* the requested point is valid*/
;            unsigned int    coordSysPos:4; /* 0..15 coordsys*/
;            unsigned int    coordSysOff:4; /*               */
;            unsigned int    coordSysRate:4;
;        /*
;         * data we read from scramnet was ok
;        */
;            unsigned int    allOk:1;    /* and of all below*/
;            unsigned int    tdOk:1;
;            unsigned int    turOk:1;
;            unsigned int    terOk:1;
;            unsigned int    lrOk:1;
;            unsigned int    pntOk:1;
;            unsigned int    agcOk:1;
;        } PNTHDR_STAT;
;
;	main structure
;
a={hdrpnt,	   id: bytarr(4,/nozero),$
              ver: bytarr(4,/nozero),$;xx.x version
                m:         {hdrpntm},$
                r:         {hdrpntr},$
          errAzRd:                0.,$; az pnt err little circle 
          errZaRd:                0.,$; za pnt err great circle 
             stat:                0L,$; see bitfields above
           filler: lonarr(5,/nozero)}

;
;	utcInfo struct used to hold from file.
;   lets you go utc to ut1.
;
a={utc_info, $
        julDatAtOff: 0.D ,$; julian date at offset
        offset:      0.D ,$; millsec offset at julDatOff
        rate  :      0.D } ; millisecs/day 
;---------------------------------------------------------------------------
; hold model info for a given model. used by pnt/modeval,modinp.,fitmod
;
a={modeldata,  name:    '',$; model name... modelSB
                suf:    '',$; suffix .. like 10A
             format:    '',$; A,B,.. type of model.. currently B
             numelm:     0,$; number coer in az or za
           encTblNm:    '',$; name of encoder table used.''--> none
                azC: fltarr(20),$; azimuth coefficients
                zaC: fltarr(20),$; zenith angle coeff
           encTblAz: fltarr(41),$; za encoder table for az each .5 degree.
           encTblZa: fltarr(41),$; za encoder table for za each .5 degree.
          balanceRd: .1596997627D}; balance angle radians..9.15012 deg
