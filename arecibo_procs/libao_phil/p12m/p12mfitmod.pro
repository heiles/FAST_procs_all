;+
; p12mfitmod - fit model to az,el positions and pointing errors
; for now we fit the strips separately
;
; SYNTAX: p12mfitmod,azA,elA,azE,elE,azErr,elErr,modI,resAz,resEl
; ARGS:
;       azA[npts] : flt/dbl azimuth positions degrees for az strips.
;       elA[npts] : flt/dbl el      angle positions degrees for az strips.
;       azE[npts] : flt/dbl azimuth positions degrees for el strips.
;       elE[npts] : flt/dbl el      angle positions degrees for el strips.
;    azErr[npts] : flt/dbl azimuth errors (great circle) deg.  az strip
;    elErr[npts] : flt/dbl el      angle errors deg.
;                                  (this includes refraction error)
;           modI : {modelInfo} return model data here
;   resAz[npts]: hold the residuals from the azimuth fits (asecs).  
;                                  at azA,elA positions
;   resEl[npts]: hold the residuals from the zenith angle fits (asecs).  
;                                  at azE,elE positions
; DESCRIPTION:
;   fit the 12meter model to the output of the cross strip fit.
;The errors have been defined  such that:
;    azCmp + azErr = azToUse
;
;The residuals are defined as:
;  res=  errStart - errFit 
;    so a positive residual --> the fits is too low.
;
;  azCor=p0 
;  1. compute refraction from the elvation input
;  2. fit the az errors to azA,elRA using fitmodAz
;  3. remove the refraction correction from elErrors ->elErrCor
;  3. fit the elErrCor to azE,elRE using fitmodEl
;  4. compute  the residuals.
; Mark uses names p1..p9
; the model is fit to great circle values
;
;ind pNum  azCoef    
;0   p1    offset
;1   p2    cosEl     
;2   p3    sinEl
;3   p4    sinEl*cosAz
;4   p5    sinEl*sinA   
;
;ind pNum  elCoef    
;0   p4    sinAz 
;1   p5    cosAz     
;2   p7    offset
;3   p8    cosEl
;4   p9    cotEl
;
;   Model params are 0..8
;     0..4 az  , 3,4,6,7,8 el
;    i fit 3,4 (tilt) separately. They should be fit together
;    modI.
;-
function fitmodAz_func,x,m
	common fitmodc,azrd,elrd
	
;
; 	compute the refracted el.
;   that is what the model fits 
;
	i=long(x+.5d)
	az=azrd[i]
	el=elrd[i]
	sinEl=sin(el)
	cosEl=cos(el)
	cosAz=cos(az)
	sinAz=sin(az)
	return,[[1.D]       , $
            [cosEl]     , $
		    [sinEl]     ,$
		    [sinEl*cosAz],$
            [sinEl*sinAz]]
end
function fitmodEl_func,x,m
	common fitmodc,azrd,elrd
	
	i=long(x+.5d)
	az=azrd[i]
	el=elrd[i]
	cosEl=cos(el)
	cosAz=cos(az)
	sinAz=sin(az)
	cotEl=1d/tan(el)
	return,[    [-sinAz] , $
                [cosAz], $
		        [1.D]   ,$
		        [cosEl] ,$
                [cotEl]]
end
pro p12mfitmod,azA,elA,azE,elE,azErrD,elErrD,modI,resAz,resEl
;
	common fitmodc,azrd,elrd

;
	ddtor=!dpi/180d
	npnts=n_elements(azA)
	modI={$ 
	      coefD:dblarr(5,2),$; p1,p2,p3,p4,p5, 0 az deg..
	                         ; -p4,p5,p7,p8,p9  1 el
	       npnts : 0L     ,$; number az,el points for fit
	       chisq:dblarr(2),$; for az,el fit
	       coefSig:dblarr(5,2),$; az,el ..deg
	       rmsmod :dblarr(2)} ; az,el rms (data - model)
	numCoef=5
	modI.npnts=npnts
	modI.coefD*=0d
;       do az strip first
 	azrd=azA*ddtor
	elrd= p12mrefract(elA)*ddtor
	x=dindgen(npnts)
;
;	azimuth errors fit
;
	coefAz=svdfit(x,azErrD,numCoef,chisq=chisq,sigma=sigma, singular=singular,$
			yfit=yfitaz,/double,function_name='fitmodAz_func')
	if singular ne 0 then begin
		print,'Warning..azfit had', singular,' singular coefficeints'
	endif
	resAz=azErrD - yfitAz
	modI.coefD[*,0]=coefAz
	modI.chisq[0]=chisq
        modI.coefSig[*,0]= sigma
	a=moment(resAz,sdev=stdev)
	modI.rmsmod[0]= stdev
;
;	el angle error fit
;
	elRefr=p12mrefract(elE)		; the refracted elevation
 	azrd=azE*ddtor
	elrd= elRefr*ddtor
	elErrNoRefrD= elErrD - (elRefr - elE)
	coefEl=svdfit(x,elErrNoRefrD,numCoef,chisq=chisq,sigma=sigma,singular=singular,$
				   yfit=yfitEl,/double,function_name='fitmodEl_func')
	if singular ne 0 then begin
		print,'Warning..azfit had', singular,' singular coefficeints'
	endif
	resEl=ElErrNoRefrD - yfitEl
	modI.coefD[*,1]=coefEl
	modI.chisq[1]=chisq
        modI.coefSig[*,1]= sigma
	a=moment(resEl,sdev=stdev)
	modI.rmsmod[1]= stdev
	return
end
