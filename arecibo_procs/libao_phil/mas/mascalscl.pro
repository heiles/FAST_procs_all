;+ 
;NAME:
;mascalscl - Scale from spectrometer cnts to K using cals
;
;SYNTAX: istat=mascalscl(bspc,calI,code,bK,bpc=bpc)
;ARGS  :
;   bspc[n]:{}: mas struct holding spectra to convert to kelvins.
;   calI{} :    cal info structure returned from mascalonoff().
;    code: int	how to do the band pass correction:
;              -1 - no bandpass correction. Use the avg cntsToK
;                   computed by mascalonoff()
;               0 - use average of bspc[n] for bandpass correction.
;               1 - use  bpc= keyword for bandpass correction.
;				    bpc has not been normalized
;               2 - use  bpc= keyword for bandpass correction.
;				    bspc has already been divided by bpc. 
;                   bpc has not been normalized.
;                   Use this for position switching:
;                   bspc=bposOn/bposOff - 1
;                   bpc =bposOff
;               3 - return only total power. No bandpass correction is
;                   needed. bK will be an array of floats [npol,n]
;KEYWORDS:
;	bpc{}:	   mas struct holding band pass correction spectra to use.
;                  see code
;              
;RETURNS:
; istat:   0 ok, -1 error
; bK[n]:         code=3: float[npol,n] will have averages over each bandpass
;                else  : bk[n] masstructs scaled to kelvins.
;                  If bpc
;
;DESCRIPTION:
;   Scale spectra from spectrometer counts to Kelvins. Before calling
;this routine you must call mascalonoff() to get the calI structure 
;loaded.
;	The code variable tells how to process the data.
;code=3  returns only total power averaged over each spectra. This
;        does not need a bandpass correction.
;   The other codes returne mas structures with spectra scaled to kelvins.
;these codes need a band pass correction. It can be bspc itself or
;it can be passed in bpc= keyword.
;	code=2 is for position switching data. In this case, bspc is
; bposOn/bposOff (the -1 is optional). You need to pass in bpc=bposOff
; for the band pass correction.
;
; code=-1 will scale the spectra to the average cntsToK value computed
;       by mascalonoff. The bandpass shape will remain in the returned
;       spectrum. Use this to scale the calOff to kelvins.
;Examples:
;;0. get the cal ons, cal offs:
;	istat=masgetfile('',bcalOn,filename=fnameOn)
;	istat=masgetfile('',bcalOff,filename=fnameOff)
;   istat=mascalonoff(bcalon,bcaloff,calI)
;;1 scale the cal offs to Kelvins
;   istat=mascalscl(bcalOff,calI,0,bcaloffK)
;   warning: here you're dividing calOff,by CalOff so you 
;            don't have any frequency dependence..:w
;;2 position switching scale to kelvins:
;	istat=masgetfile('',bposOn,filename=fnamePosOn)
;	istat=masgetfile('',bposOff,filename=fnamePosOff)
;   bavgOn=masmath(bposOn,/avg)
;   bavgOff=masmath(bposOff,/avg)
;   bavgonoff=masmath(bposOn,bposOff,/div)
;   istat=mascalscl(bavgonoff,calI,2,bpc=bavgOff) 
;  
;NOTES:
;	Current restrictions:
;1. fixed to work with stokes spectra.. not yet tp
;2. need to check that polAdding works..
;
;-
;modhistory
;26jun09 - wrote
;
function mascalscl,bspc,calI,code,bK,bpc=bpc
;
;   
	nobpc   =-1
	usespc  =0
	usebpc   =1
	useposSw =2
	useTp    =3
	nrecs    =n_elements(bspc)
	nchan    =bspc[0].nchan
	ndumps   =bspc[0].ndump
	nspc     =nrecs*ndumps
	npol     =bspc[0].npol
	iiuse    =calI.indUsed
	nchanused=calI.npnts
	exposure=bspc[0].h.exposure
	
;
; make sure bpc included if needed
;
	if ((n_elements(bpc) eq 0) and $
		((code eq usebpc) or (code eq usePosSw))) then begin
		print,"mascalscl: no bpc= value included in call"
		return,-1
 	endif
;
; here are the different choices
;
	switch code of
;    
		nobpc : begin
				bk=bspc
			    break
				end
;                average bspc for bpc
		usespc:
		usebpc:begin
			if (code eq usespc) then begin
				bpcN=(nspc gt 1)?masmath(bspc,/avg):bspc
		    endif else begin
				bpcN=bpc
			endelse
			for ipol=0,npol-1 do begin
				bpcN.d[*,ipol]*= 1./mean(bpcN.d[iiuse,ipol])
			endfor
			bk=masmath(bspc,bpcN,/div)
			break 
			end
		useposSw: begin
;           Need to rescale poson/posoff back to masdevice counts
			scl1=total(bpc.d[iiuse,*],1)/nchanUsed
			bk=masmath(bspc,smul=scl1)
			break
			end
        useTp : begin
				bK=fltarr(npol,nspc)
				if nspc gt 1 then begin
				   bk=total((reform(bspc.d,nchan,npol,nspc))[iiuse,*,*],$
							  1)/nchanused
			    endif else begin
					if npol eq 1 then begin
				    	bk=total(bspc.d[iiuse])/nchanUsed
					endif else begin
				    	bk=total(bspc.d[iiuse,*],1)/nchanUsed
					endelse
				endelse
	            scl=calI.cntsToK*calI.exposure/exposure
			    for ipol=0,npol-1 do bk[ipol,*]*=scl[ipol]
				return,0
			    break 
				end
		else:  begin
				print,"mascalscl:Illegal code requested:",code
				return,-1
		       end
	endswitch
;
;  normalize bpc
;
;   in case cals taken for more/less time than cals.
	scl=calI.cntsToK*calI.exposure/exposure
	if bk[0].npol eq 4 then begin
		xx=scl[0]
		yy=scl[1]
		xy=sqrt(xx*yy)
		scl=[xx,yy,xy,xy]
	endif
	bk=masmath(bk,smul=scl)
	return,0
end
