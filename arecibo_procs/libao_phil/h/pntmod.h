;---------------------------------------------------------------------------
; header for ri data turret scans...
@hdrRiFull.h
;---------------------------------------------------------------------------
;	filled in when reading in a record from ri turret scan 
;   stored in pmccom...
;
a={pminfo,	turPosD: 	    0.D,$;	degrees
          	turAmpD:        0.D,$;	amplituted in degrees
          	turFrqH:        0.D,$;	frequency in hertz
          	recsPerStrip:   0  ,$;  records per strip
			stripNum:       0  ,$;  count from 1
			samplesPerStrip: 0L  ,$;  samples per strip
			zaOffStartD:    0.D,$;  offset deg  za this strip
          	secsPerStrip:   0. ,$;  records per strip
          	secsPerRec:     0. ,$;  records per strip
			az:             0.D,$;  az deg end 1st rec
			za:             0.D}
;---------------------------------------------------------------------------
;  to fit turret scans (routine fittur)
;
a={fitturparm ,  amp:    0.,$; amplitud in digitizer counts
		       zaErrA:    0.,$; zenith angle error arc seconds
		        zaWdA:    0.,$; zenith width arc seconds
		       azErrA:    0.,$; azimuth error great circle arcseconds
		        azWdA:    0.,$; azimuth width great circle arcseconds
	           PhaseD:    0. }; turret phase in degrees

a={fitturI, zaOffDeg:    0.,$; zenith angle offset in degrees
              zaVel:    0.,$; zentih angle velocity deg/sec
          turAmpDeg:    0.,$; turret amplitude in degrees
             turFrq:    0.,$; turret frequency cycle/second
             turScl:    0.,$; gcAsec/turret degree .. -45
		 sampleRate:    0.,$; samples per second.
			 tmCon:     0.,$; time constant in seconds.
		       pinp:   {fitturparm},$; input parameters
			      p:   {fitturparm},$; fitted parameters
              sigma:    0.,$; constat sigma to use for data points
              chisq:    0.,$; from fit
              niter:    0 } ; number of iterations it took to converge.
;---------------------------------------------------------------------------
;  used to keep track of what scan/rec to input next .
;  stored in pmccom, used by cnxt, cpos, x101, etc..
;
a={pmccomI, lun    :	0L,$;	-1 --> not initialized
		   filename:    '',$; filename
		   scanReq: 0L,$;   0, any, -1 not defined, or scan to use
		   scanInp: 0L,$;   -1 none, last scan input.
		  stripReq: 0L,$;   pnt to strip to input.
		  stripInp: 0L,$;   -1 none,last strip input
	       scanStB: 0L,$;  bytes position scanInp;
	     stripLenB: 0L,$;  length of strip in bytes.
		  iostat  : 0L} ;  1:ok,0:eof,-1:difscan,-2:badhdr,-3:posErroR
;---------------------------------------------------------------------------
; fitmodel info. info returned by fitmod
;
a={fitmodInfo, model:     {modeldata},$; modeldata, coef, encoder table,
		    npntsInp:              0L,$; number of inputs points to fit
			   chisq:       dblarr(2),$; chisq fit az,za
		   coefsigma:    dblarr(20,2),$; sigma each coef, az/za
		      rmsmod:       dblarr(2),$; az,za rms from data- model
			  rmstot:       dblarr(2)} ; az,za rms from data-(model+encTbl)
;---------------------------------------------------------------------------
; output from x101 fitting.
;
a={x101fitval, src : ' ',$;  source name
		  srcInd:  0L   ,$; index into src array...
		  freq :   0.D,$;
		    az :0.,$
        	za : 0.,$
        	g  : 0.,$
        	b  : 0.,$
        	zaE: 0.,$
        	zaW: 0.,$
        	azE: 0.,$
        	azW: 0.,$
        	ph : 0.,$
        	chi : 0.,$
        	pntE: 0.,$
        	ok  : 0.}
;---------------------------------------------------------------------------
; src inp structure
a={pmsrcinpst, file: ' ',$;
			srcname: ' ',$;
			   scan:  0L,$;
		    nstrips:  0L,$;
			 ftpamp:  0.,$;
			 ftpsig:  0.,$;
		 nbadstrips:  0L,$;
		  badstrips: lonarr(20)}; strip number bad strips. count from 1
;---------------------------------------------------------------------------
; to read in analyz data
;
a={anzfitval,  az:0.,$
              za: 0.,$
        g: 0.,$
        b: 0.,$
        zaE: 0.,$
        zaW: 0.,$
        azE: 0.,$
        azW: 0.,$
        ph : 0.,$
        chi : 0.,$
        pntE: 0.,$
        ok  : 0.}

	common pmccom,pmci,pmc,pmcb
	pmci={pmccomi}
	common fitturcom,ftcI,ftcTurW
	ftcI={fitturI}
	forward_function pmget
	forward_function pmbase
	forward_function dblevels
	forward_function turpos
