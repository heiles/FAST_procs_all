pro intensitycal_gbtcal_1, scndata, gainchnls, tcalxx, tcalyy, $
                           scans, startscan, stokes, stokesc1, nchnls, $
                           cumcorr=cumcorr

;+
;like intensitycal_newcal, but reorders the stokes spectra 

;CALIBRATES INTENSITY SCALE. DOES ON SOURCE AND OFF SOURCE SCANS SEPARATELY.
;INPUTS ARE:
;	TCALXX, TCALYY: THE CAL VALUES FOR XX, YY.
;	SCANS, THE SET OF INDICES THAT SHOULD BE CALIBRATED. 
;		FOR EXAMPLE, IN A SET OF 18 OBSERVATIONS OF CROSS PATTERN,
;		YOU WANNA TO ALL OF THEM, SO SCANS=INDGEN(18).
;	INDXCALON, THE INDX NR OF THE SCAN ARRAY THAT HAS THE CAL ON.
;		FOR EXAMPLE, IN THE CROSS PATTERN WE USE ONLY OFF-SOURCE
;		SCANS TO DO THE CALIBRATION, SO INDXCALON=[0,15]
;	INDXCALOFF, THE INDX NR OF THE SCAN ARRAY THAT HAS THE CAL OFF.
;		FOR EXAMPLE, IN THE CROSS PATTERN WE USE ONLY OFF-SOURCE
;		SCANS TO DO THE CALIBRATION, SO INDXCALOFF=[1,14]
;	STOKES, THE UNCALIBRATED STOKES PARAMETERS.
;	STOKESC1, THE INTENSITY-CALIBRATED STOKES PARAMETERS.

;IMPORTANT VARIABLES IN COMMON ARE:
;	GAINCHNLS, THE CHANNELS OVER WHICH THE GAIN IS CALCULATED.
;		THIS NEEDS TO AVOID THE RESONANCE AND THE HI LINE.
;

;****************  IMPORTANT!!!!!!!! ******************************
;THIS IS IDENTICAL TO INTENSITYCAL_ZMN_W, EXCEPT THAT GAINCHNLS IS
;        INPUTTED AS A PARAMETER BUT HERE IS IN COMMON CROSSPARAMS. 
;	IF YOU NEED TO MAKE CHANGES HERE, 
;	MIRROR THEM IN INTENSITYCAL_ZMN_W
;****************  IMPORTANT!!!!!!!! ******************************
;- 

;EXTRACT OLD NAMES FROM THE STRUCTURE CALLED SCNDATA...
;gainchnls= scndata.gainchnls
indxcaloff= scndata.indxcaloff
indxcalon= scndata.indxcalon

;take care of the case of only one cal on or off spectrum...
if n_elements( indxcaloff) eq 1 then indxcaloff= [indxcaloff, indxcaloff]
if n_elements( indxcalon) eq 1 then indxcalon= [indxcalon, indxcalon]
;help, stokes

;TURN THE STOKES I AND Q INTO XX AND YY. 
nr_gns = n_elements(gainchnls)
xx = stokes[*,0,*]
yy = stokes[*,2,*]
;xx = 0.5*(stokes[*,0,scans] + stokes[*,1,scans])
;yy = 0.5*(stokes[*,0,scans] - stokes[*,1,scans])
chnlavgxx = total(xx[gainchnls,0,*],1)/nr_gns
chnlavgyy = total(yy[gainchnls,0,*],1)/nr_gns

;xxcaloffavg = total(xx[*,0,indxcaloff],3)/n_elements(indxcaloff)
;yycaloffavg = total(yy[*,0,indxcaloff],3)/n_elements(indxcaloff)

;THE ABS BELOW IS TO TAKE CARE OF NEG NUMBERS AT THE EDGE OF THE BAND,
;	WHICH ARE SMALL AND MEANINGLESS ANYWAYY BUT REALLY SCREW
;	THINGS UP!
xxcaloffavg = abs( total(xx[*,0,indxcaloff],3)/n_elements(indxcaloff))
yycaloffavg = abs( total(yy[*,0,indxcaloff],3)/n_elements(indxcaloff))

;GET THE RATIO OF CAL DEFLECTION TO THE CAL-OFF NUMBERS...
;	THIS IS A CHANNEL AVERAGE...
calonxx = total(chnlavgxx[indxcalon])/n_elements(indxcalon)
calonyy = total(chnlavgyy[indxcalon])/n_elements(indxcalon)
caloffxx= total(chnlavgxx[indxcaloff])/n_elements(indxcaloff)
caloffyy= total(chnlavgyy[indxcaloff])/n_elements(indxcaloff)
ratioxx = (calonxx-caloffxx)/caloffxx
ratioyy = (calonyy-caloffyy)/caloffyy

;stop

if ( (ratioxx lt 0.) or (ratioyy lt 0.) ) then begin
   print, 'CANNOT PROCESS GROUP BEGINNING WITH SCAN NR ', startscan
   print, 'BECAUSE CAL DEFLECTIONS ARE NEGATIVE. '
   print, 'SETTING TSYS=5*TCAL AND PROCEEDING.', string(7b)
   print, 'SETTING SUCCESSFUL = 0', string(7b)
   ratioxx = 0.2
   ratioyy = 0.2
endif

gainxx = xxcaloffavg*ratioxx/tcalxx
gainyy = yycaloffavg*ratioyy/tcalyy

;stop

;APPLY THE GAIN FACTORS TO XX AND YY...
xxc1 = fltarr( nchnls, n_elements(scans), /nozero)
yyc1 = fltarr( nchnls, n_elements(scans), /nozero)

for nrll = 0, n_elements(scans)-1 do begin
   xxc1[*, nrll] = xx[*,0, nrll]/gainxx
   yyc1[*, nrll] = yy[*,0, nrll]/gainyy
   ;stokesc1[*,2,scans[nrll]]=stokes[*,2,scans[nrll]]/sqrt(gainxx*gainyy)
   
   ;NOTE FACTORS OF TWO BELOW!!!
   stokesc1[*,2,scans[nrll]]= 2.* stokes[*,1,scans[nrll]]/sqrt(gainxx*gainyy)
   stokesc1[*,3,scans[nrll]]= 2.* stokes[*,3,scans[nrll]]/sqrt(gainxx*gainyy)
endfor

;RECOMBINE XX AND YY INTO STOKES I AND U...
stokesc1[*,0,scans]=xxc1+yyc1
stokesc1[*,1,scans]=xxc1-yyc1

;STOP

;AT THIS POINT THE STOKESC1 IS INTENSITY CALIBRATED IN KELVINS.
;THIS HAS BEEN THOROUGHLY CHECKED!!!!!

;endfor

end
