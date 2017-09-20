pro intensitycal_newcal, scndata, tcalxx, tcalyy, $
    scans, startscan, stokes, stokesc1, nchnls, $
    cumcorr=cumcorr,polBad=polBad,missingcal=missingcal

;+
;NAME:
; intensitycal_newcal
;CALIBRATES INTENSITY SCALE. DOES ON SOURCE AND OFF SOURCE SCANS SEPARATELY.
;INPUTS ARE:
;   TCALXX, TCALYY: THE CAL VALUES FOR XX, YY.
;
;   STOKES, THE UNCALIBRATED STOKES PARAMETERS.
;
;and the following come from structure SCNDATA:
;
;   SCANS, THE SET OF INDICES THAT SHOULD BE CALIBRATED. 
;       FOR EXAMPLE, IN A SET OF 18 OBSERVATIONS OF CROSS PATTERN,
;       YOU WANNA TO ALL OF THEM, SO SCANS=INDGEN(18).
;   INDXCALON, THE INDX NR OF THE SCAN ARRAY THAT HAS THE CAL ON.
;       FOR EXAMPLE, IN THE CROSS PATTERN WE USE ONLY OFF-SOURCE
;       SCANS TO DO THE CALIBRATION, SO INDXCALON=[0,15]
;   INDXCALOFF, THE INDX NR OF THE SCAN ARRAY THAT HAS THE CAL OFF.
;       FOR EXAMPLE, IN THE CROSS PATTERN WE USE ONLY OFF-SOURCE
;       SCANS TO DO THE CALIBRATION, SO INDXCALOFF=[1,14]
;
; polBad: int  =0 --> polA bad, 1--> polB bad else both pols ok
;                makes Q 0, u,v junk
; missingcal: int   if true then there is no cal for this receiver
;              set caldeflection to tsys.

;OUTPUTS:
;   STOKESC1, THE INTENSITY-CALIBRATED STOKES PARAMETERS.

;- 

;EXTRACT OLD NAMES FROM THE STRUCTURE CALLED SCNDATA...
polBadL=(n_elements(polBad) eq 1)?polBad:-1
tcalxxL=(polBadL eq 0)?tcalyy:tcalxx
tcalyyL=(polBadL eq 1)?tcalxx:tcalyy
;
gainchnls= scndata.gainchnls
indxcaloff= scndata.indxcaloff
indxcalon= scndata.indxcalon


;TURN THE STOKES I AND Q INTO XX AND YY. 
nr_gns = n_elements(gainchnls)
xx = 0.5*(stokes[*,0,scans] + stokes[*,1,scans])
yy = 0.5*(stokes[*,0,scans] - stokes[*,1,scans])
if polBadL eq 0 then xx=yy
if polBadL eq 1 then yy=xx

chnlavgxx = total(xx[gainchnls,0,*],1)/nr_gns
chnlavgyy = total(yy[gainchnls,0,*],1)/nr_gns

;xxcaloffavg = total(xx[*,0,indxcaloff],3)/n_elements(indxcaloff)
;yycaloffavg = total(yy[*,0,indxcaloff],3)/n_elements(indxcaloff)

;THE ABS BELOW IS TO TAKE CARE OF NEG NUMBERS AT THE EDGE OF THE BAND,
;   WHICH ARE SMALL AND MEANINGLESS ANYWAYY BUT REALLY SCREW
;   THINGS UP!
xxcaloffavg = abs( total(xx[*,0,indxcaloff],3)/n_elements(indxcaloff))
yycaloffavg = abs( total(yy[*,0,indxcaloff],3)/n_elements(indxcaloff))

;GET THE RATIO OF CAL DEFLECTION TO THE CAL-OFF NUMBERS...
;   THIS IS A CHANNEL AVERAGE...
calonxx = total(chnlavgxx[indxcalon])/n_elements(indxcalon)
calonyy = total(chnlavgyy[indxcalon])/n_elements(indxcalon)
caloffxx= total(chnlavgxx[indxcaloff])/n_elements(indxcaloff)
caloffyy= total(chnlavgyy[indxcaloff])/n_elements(indxcaloff)
if (keyword_set(missingcal)) then begin
	xxcalonavg = abs( total(xx[*,0,indxcalon],3)/n_elements(indxcalon))
    yycalonavg = abs( total(yy[*,0,indxcalon],3)/n_elements(indxcalon))
	;; caloff, calon both caloff. just avg. gives Tsys in units of cor cnts
	gainxx = (xxcaloffavg + xxcalonavg)*.5
	gainyy = (yycaloffavg + yycalonavg)*.5
endif else begin
	ratioxx = (calonxx-caloffxx)/caloffxx
	ratioyy = (calonyy-caloffyy)/caloffyy

	if ( (ratioxx lt 0.) or (ratioyy lt 0.) ) then begin
   	 print, 'CANNOT PROCESS GROUP BEGINNING WITH SCAN NR ', startscan
   	 print, 'BECAUSE CAL DEFLECTIONS ARE NEGATIVE. '
   	 print, 'SETTING TSYS=5*TCAL AND PROCEEDING.', string(7b)
    	print, 'SETTING SUCCESSFUL = 0', string(7b)
   	 ratioxx = 0.2
   	  ratioyy = 0.2
	endif

	gainxx = xxcaloffavg*ratioxx/tcalxxL
	gainyy = yycaloffavg*ratioyy/tcalyyL
endelse

;APPLY THE GAIN FACTORS TO XX AND YY...
xxc1 = fltarr( nchnls, n_elements(scans), /nozero)
yyc1 = fltarr( nchnls, n_elements(scans), /nozero)

for nrll = 0, n_elements(scans)-1 do begin
xxc1[*, nrll] = xx[*,0, nrll]/gainxx
yyc1[*, nrll] = yy[*,0, nrll]/gainyy
stokesc1[*,2,scans[nrll]]=stokes[*,2,scans[nrll]]/sqrt(gainxx*gainyy)
stokesc1[*,3,scans[nrll]]=stokes[*,3,scans[nrll]]/sqrt(gainxx*gainyy)
endfor

;RECOMBINE XX AND YY INTO STOKES I AND U...
stokesc1[*,0,scans]=xxc1+yyc1
stokesc1[*,1,scans]=xxc1-yyc1

;STOP

;AT THIS POINT THE STOKESC1 IS INTENSITY CALIBRATED IN KELVINS.
;THIS HAS BEEN THOROUGHLY CHECKED!!!!!

;endfor

return
end
