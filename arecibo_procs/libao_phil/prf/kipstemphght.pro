;+
;kipsTempHght - compute total kips on platform from temp, platform height
; SYNTAX:
;       kips=kipsTempHght(tempDegF,platformHghtFt,coef=coef,hghtavg=hghtavg,$
;						  tempavg=tempavg,epoch=epoch)
;ARGS:
;	tempDegF[n]: temp in degF.
;	platformhghtFt[n]: float platformhght in feet above sea level
;KEYWORDS:
;	    day: if set use  fit for daytime (6am 8pm) if available
;	   nite: if set use, fit for nitetme (8pm 6am) if available
;	  epoch: int  of data to use. values:2000,2002(default)
;	coef[3]: double coef to use (in case you have refit some data
;	hghtavg: double if coef provided then this is the avg height used in the
;		            fit (eg coef[2]*(hght[n]-htavg))
;	tempavg: double if coef provided then this is the avg temp used in the
;		            fit (eg coef[1]*(temp[n]-tempavg))
;
; 2000  fit comes from 7mar00 through 4may00 data
; default fit comes from 2002 year
;-
function kipsTempHght,temp,platformHght,nite=nite,day=day,$
        tempavg=tempavg,hghtavg=hghtavg,coef=coef,epoch=epoch
;
    tavg=0.d
    havg=1256.D
    if n_elements(coef) eq 0 then begin
		if not keyword_set(epoch) then epoch=2002
		if epoch eq 2000 then begin
;					 offset     Kip/F        kips/Ft .. t=0,h=1256.
        	coefall=[551.89139D,-5.0589346D,-98.174865D]
        	coefday=[551.89139D,-5.0589346D,-98.174865D]
        	coefnite=[551.89139D,-5.0589346D,-98.174865D]
        	tavg=0.d
        	havg=1256.D
		endif else begin
        	tavg=74.d
        	havg=1256.35D
; 
;	note the hghts are kips/inch.. change to feet.
;					 offset     Kip/F        kips/Ft .. t=74,h=1256.35
			coefall=[122.70956D ,-5.1193501D,-105.38584D]  ; rms 5.83
			coefday=[120.95022D ,-5.0271279D,-104.05258D]  ; rms  6.01
			coefnite=[129.35829D,-3.6648419D,-109.49493D]  ; rms 2.78
		endelse
		coef=coefall
		if keyword_set(day)  then coef=coefday
		if keyword_set(nite) then coef=coefnite
    endif else begin
        if n_elements(tempavg) gt 0 then  tavg=tempavg
        if n_elements(hghtavg) gt 0 then  havg=hghtavg
    endelse
		
    return,[coef[0] +coef[1]*(temp-tavg) + coef[2]*(platformHght -havg)]
    end

