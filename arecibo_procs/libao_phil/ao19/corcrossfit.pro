;+
;NAME:
;corcrossfit - fit 2d gaussian to corcross data 
;SYNTAX: istat=corcrossfit(b,fitI,plotit=plotit,tit=tit,_extra=_e)
;ARGS:
;b[n]: {}    data for two strips az then za to fit
;KEWYORDS:
;plotit: plot the data if set
;tit:    string title if a plot
;_e    : for the plot command
;RETURNS:
;istat:    1 fit ok
;          0 fit failed
;fitI:{}   struct holding fit info
;x[m]: float   x axis amin for 1 strip
;z[m,2]:float  total power data used for fit
;
;-
function corcrossfit,b,fitI,tit=tit,_extra=_e,plotit=plotit
    common colph,decomposedph,colph

;
; see if iar data is there. if not use:
; 60 secs/strip 1 sec sample,beams/strip=6
;
	if n_elements(tit) eq 0 then tit=''
	n=n_elements(b)
	secsPerPnt=1.
	if (b[0].b1.h.proc.iar[0] ne 0 ) then begin
		beamsPerStrip=b[0].b1.h.proc.iar[0]
		secsPerStrip =b[0].b1.h.proc.iar[1]
		numStrips    =b[0].b1.h.proc.iar[3]
	endif else begin
		beamsPerStrip=6
		secsperStrip=60
		numStrips=2
	endelse
	ii0=0
	nstrip=secsPerStrip
	ii1=nstrip
;
	if n ne (numStrips*secsPerStrip) then begin
		print,"corcrossfit: need:",numStrips*secsPerStrip," spectra per fit" 
		return,-1
	endif
	fwhmAmin=b[ii0].b1.h.proc.dar[0]
	azOffD=b[ii0].b1.h.proc.dar[1]
	azRatD=b[ii0].b1.h.proc.dar[3]
	zaOffD=b[ii1].b1.h.proc.dar[2]
	zaRatD=b[ii1].b1.h.proc.dar[4]
;   positioner offset
	azOffPD=b[0].b1.h.proc.dar[5]
	zaOffPD=b[0].b1.h.proc.dar[6]
;
; 	make sure first 60 are row 1 and last 60 are row 2
;
	ii=where(b[ii0:ii0+nstrip-1].b1.h.proc.car[0] ne $
			 b[ii0].b1.h.proc.car[0],cnt)
	if ((cnt gt 0) || ( string(b[ii0].b1.h.proc.car[0]) ne '0')) then begin
		print,"corcrossfit: all of 1st row not az strip"
		return,-1
	endif
	ii=where(b[ii1:ii1+nstrip-1].b1.h.proc.car[0] ne $
			 b[ii1].b1.h.proc.car[0],cnt)
	if ((cnt gt 0) || ( string(b[ii1].b1.h.proc.car[0]) ne '1')) then begin
		print,"corcrossfit: all of 2nd row not za strip"
		return,-1
	endif
;
;	get total power.. just sbc 0
;
	ncoef=7
	xaz=(findgen(nstrip) + .5)*azRatD*60. + azOffD*60.
	xza=(findgen(nstrip) + .5)*zaRatD*60. + zaOffD*60.
	x0=fltarr(nstrip)		; zeros 
	iedg=nstrip/10
	
	z=b.b1.h.cor.lag0pwrratio[0]
	z=reform(z,nstrip,2)
	daz=[xaz,x0]
    dza=[x0,xza]
	initCoef=fltarr(ncoef)
    initCoef[0]=median([z[0:iedg,0],z[nstrip-iedg,0],$
                       z[0:iedg,1],z[nstrip-iedg,1]])
    initCoef[1]=max(z)-initCoef[0] &$
;	put offset at the maximum value
    a=max(z[*,0],imax) &$
    initCoef[2]=xaz[imax]  &$;az err
    a=max(z[*,1],imax) &$
    initCoef[3]=xza[imax] &$ ;za err
    initCoef[4]=fwhmAmin &$
    initCoef[5]=fwhmAmin &$
    initCoef[6]=0. &$
    fitCoef=gsfit2d(daz,dza,z,initCoef,zfit=zfit,sigCoef=sigCoef,$
			sigma=sigma,chisq=chisq,trouble=trouble)
;
;	now stuff results in fit struct
;
	if (trouble ne 0)  then begin
		print,"gsfitd trouble with scan:",b[0].b1.h.std.scannumber
	endif
	fitI={$
		    trouble: trouble,$; not 0 --> problem with fit
	       scanSt:   b[0].b1.h.std.scannumber,$
			ncoef: ncoef ,$
			offset: fitCoef[0],$   ; this is Tsys
			amp   : fitCoef[1],$   ; amplitude
		    azoffA: fitCoef[2],$   ;az err amin	
		    zaoffA: fitCoef[3],$   ;za err amin	
		   fwhmAzA: fitCoef[4],$   ;fwhm az 
		   fwhmZaA: fitCoef[5],$   ;fwhm az 
		   thetaD : fitCoef[6],$   ;rotation of ellipsoid
	            x : xaz       ,$   ; in amin
			    z : z         ,$   , 60,2
			 zfit : reform(zfit,nstrip,2),$
			sigmaFit: sigma ,$
			chisq   : chisq, $
			sigCoef : sigCoef}  ; sigma of coefficients
	if keyword_set(plotit) then begin
		ltit=string(format='("azErr:",f7.1," zaErr:",f7.1," Asecs")',$
			  fitI.azoffA*60.,fitI.zaOffA*60) + tit
		plot ,xaz,z[*,0],_extra=_e,title=ltit
		oplot,xza,z[*,1],col=colph[2]
		oplot,xaz,fitI.zfit[*,0],col=colph[3]
		oplot,xza,fitI.zfit[*,1],col=colph[3]
	endif
	return,1
end
