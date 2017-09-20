;+
;NAME:
;prfsrcplt - plot pitch,roll,focus values for a particular source.
;SYNTAX: prfsrcplt,dec,name,temp,prfk,azErr,zaErr,fractGain,key=key,step=step,$
;	                   foff=foff,poff=poff,roff=roff,prf2d=prf2d,$
;				       rcvr=rcvr,freq=freq
;ARGS:
;	  dec[3]: float declination, deg,min,sec
;	  name  : string name of source for plot
;	  temp  : float  temperature deg F for computation.
;
;RETURNS:
;	 prfk[n]:{prfk}  hold returned info. defined in hdrTilt.h
;   azErr[n]: float  az error caused by this correction
;   zaErr[n]: float  za error caused by this correction
;fractGain[n]:float  fractional gain if correction not made.
;				     this does not include the offsets input by the user.
;
;KEYWORDS:
;	key     : long  .. tells what to include in plot
;			   1 - pitch and roll
;			  10 - focus
;			 100 - pointing error
;			1000 - kips each td after correction
;		   10000 - tiedown position after correction vs az,za
;		  100000 - tiedown position after correction versus hour angle
;		 1000000 - fractional gain if correction not done.
;   step	: float azimuth step to compute data. default every 1 degree az.
;   foff    : float Value to add to computed focus error (inches).
;   poff    : float Value to add to computed pitch error (degrees).
;   roff    : float Value to add to computed roll error (degrees).
;   prf2d   : {prfit2d} if supplied, use this rather than the default
;                       model fit.
;      rcvr : string 'sb','cb','lb','xb', compute fractional gain if correction
;      freq : float Mhz if supplied then compute fractional gain for this
;					    freq rather then the rcvr freq default freq.
;DESCRIPTION:
;	For a given source, compute the pitch,roll, and focus errors for rise
;to set. Also compute the pointing error that would result if the correction
;was made to the current model. The values are returned in the structure
;prfk, and the arrays azErr,zaErr,fractGain. You can add a constant offset
;to the pitch,roll,focus errors using the xxxoff keywords.
;
;NOTES:
;	to use this routine you should enter
; @tsinit first

;
pro prfsrcplt,dec,name,temp,prfk,azErr,zaErr,fractGain,key=key,step=step,$
			foff=foff,poff=poff,roff=roff,rcvr=rcvr,prf2d=prf2d,$
			freq=freq
;
	if (n_elements(key) eq 0) then key=1111111L
	if (n_elements(step) eq 0) then step=1
	if (n_elements(poff) eq 0) then poff=0.
	if (n_elements(roff) eq 0) then  roff =0.
	if (n_elements(foff) eq 0) then   foff  =0.
	if (n_elements(rcvr) eq 0) then     rcvr='sb'
	!p.multi=[0,1,2,0,0]
clab=string(format=$
	'("src:", a0," dec ",i02.2,":",i02.2,":",f4.1," temp:",f4.1)',$
			name,long(dec[0]),long(dec[1]),dec[2],temp)
	prfSrc,dec,temp,prfk,azErr,zaErr,step=step,prf2d=prf2d,$
		poff=poff,roff=roff,foff=foff
	fractGain=prfgainall(prfk.az,prfk.za,rcvr,freq=freq,$
		pitchtouse=prfk.pitch,rolltouse=prfk.roll,foctouse=prfk.focus)
;------------------------------
; plot the pitch, roll, focus vs az
;
; 1 pitch/roll
;
	if (key mod 10) ne 0 then begin
	ver,-.3,.3 
	hor
	plot,prfk.az,prfk.pitch,/xstyle,/ystyle,$
		xtitle='az',ytitle='[deg]',title='pitch solid, dash:roll errors'
		note,3,clab
 	oplot,prfk.az,prfk.roll,linestyle=1
;	
	hor,0,20
	plot,prfk.za,prfk.pitch,/xstyle,/ystyle,$
		xtitle='za',ytitle='[deg]',title='pitch solid, dash:roll errors'
	oplot,prfk.za,prfk.roll,linestyle=1
	endif

;------------------------------
;  focus 10
;
	if ((key/10) mod 10L) ne 0 then begin
	hor
	ver,-3,3
	plot,prfk.az,prfk.focus,/xstyle,/ystyle,$
		xtitle='az',ytitle='focus err [in]',title='radial focus error'
		note,3,clab
	hor,0,20
	plot,prfk.za,prfk.focus,/xstyle,/ystyle,$
		xtitle='za',ytitle='focus err [in]',title='radial focus error'
	endif
;------------------------------
; 100 -	 pnt error:
;
	if (key/100 mod 10L) ne 0 then begin
	hor
	ver,-120,120
	plot,prfk.az,azErr,/xstyle,/ystyle,$
			xtitle='az',ytitle='azPntErr asec great circle',$
			title='AzErr solid, zaErr dashed'
		note,3,clab
	oplot,prfk.az,zaErr,linestyle=1,color=2

	hor,0,20
	plot,prfk.za,azErr,/xstyle,/ystyle,$
			xtitle='za',ytitle='azPntErr asec great circle',$
			title='AzErr solid, zaErr dashed'
	oplot,prfk.za,zaErr,linestyle=1,color=2
	endif
;------------------------------
; 1000 -	kips
; 
	if (key/1000L mod 10L) ne 0 then begin
	hor
	ver,0,120
	for i=0,2 do begin
		if i eq 0 then begin
			plot,prfk.az,prfk.kips[i],/xstyle,/ystyle,$
				xtitle='az',ytitle='tdkips 1 block',$
				title='tiedown kips 1 blk. solid:12,dot:4,dash:8'
		     note,3,clab
		endif else begin
			oplot,prfk.az,prfk.kips[i],linestyle=i,color=i+2
		endelse
	endfor

	hor,0,20
	for i=0,2 do begin
		if i eq 0 then begin
			plot,prfk.za,prfk.kips[i],/xstyle,/ystyle,$
				xtitle='za',ytitle='tdkips 1 block',$
				title='tiedown kips 1 blk. solid:12,dot:4,dash:8'
		endif else begin
			oplot,prfk.za,prfk.kips[i],linestyle=i,color=i+2
		endelse
	endfor
	endif
;------------------------------
;
; 10000-tdPos
;
	if (key/10000L mod 10L) ne 0 then begin
	hor
	ver,0,24
	for i=0,2 do begin
		if i eq 0 then begin
			plot,prfk.az,prfk.tdpos[i],/xstyle,/ystyle,$
				xtitle='az',ytitle='tdPos [in]',$
		title='tiedown position. solid:12,dot:4,dash:8'
		note,3,clab
		endif else begin
			oplot,prfk.az,prfk.tdpos[i],linestyle=i,color=i+2
		endelse
	endfor

	hor,0,20
	for i=0,2 do begin
		if i eq 0 then begin
			plot,prfk.za,prfk.tdpos[i],/xstyle,/ystyle,$
				xtitle='za',ytitle='tdPos [in]',$
		title='tiedown position. solid:12,dot:4,dash:8'
		endif else begin
			oplot,prfk.za,prfk.tdpos[i],linestyle=i,color=i+2
		endelse
	endfor
	endif
	!p.multi=[0,0,0,0,0]
;------------------------------
;
; 100000 - td position vs hour angle
;
	if (key/100000L mod 10L) ne 0 then begin
    npts=(size(prfk.za))[1]
	ha=step*(findgen(npts)- npts/2.)/60.
	hor
    for i=0,2 do begin
        if i eq 0 then begin
            plot,ha,prfk.tdpos[i],/xstyle,/ystyle,$
                xtitle='time to transit (minutes)',ytitle='tdPos [in]',$
        title='tiedown position. solid:12,dot:4,dash:8'
        endif else begin
            oplot,ha,prfk.tdpos[i],linestyle=i,color=i+2
        endelse
    endfor
	endif
;------------------------------

;  focus 10
;
    if ((key/1000000L) mod 10L) ne 0 then begin
	!p.multi=[0,1,2,0,0]
    hor
    ver,0,1.
	if min(fractGain) ge .5 then ver,.5,1
    plot,prfk.az,fractGain,/xstyle,/ystyle,$
        xtitle='az',ytitle='fractional gain',$
	    title='fractional gain if correction not made'
        note,10,clab+' rcvr:'+rcvr
    hor,0,20
    plot,prfk.za,fractGain,/xstyle,/ystyle,$
        xtitle='za',ytitle='fractional gain',$
	    title='fractional gain if correction not made'
    endif
	!p.multi=0
	return
end
