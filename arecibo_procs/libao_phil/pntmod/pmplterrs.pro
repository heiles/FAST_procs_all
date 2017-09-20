;------------------------------------------------------------------------------
;+
;pmplterrs. - plot the fit errors
;SYNTAX: pltpnterr,fit,sym=symsrc,over=over,vaz=vaz,nl=nl,xp=xp,col=col, 
;				   pl1=pl1,srcind=srcind,scl=scl
;ARGS:
;	 fit[] : {X101FITVAL} .. output from fit
;KEYWORDS:
;		sym  : int if set then symbol index to use for this src. def: 2-*
;		over : int if set then overplot ..
;		 vaz : int if set plot vs az. default vs za
;		  nl : int if set then line num for note symbol,srcname
;		  xp : int if set then xposition start sym/srcname ( 0 to 1.).
;		 col : int if set then color index to use for this call . def:1
;		 pl1 : int if set 1-plot,zaE, 2-pltAzE, else plot both
;      srcInd; int if set then extract only srcInd from set
;         ln : int line number for solid,za msg. def 3.
;      scl   : float scale for spacing notes. def. 1.
;      cs    : float char size scale for labels
;DESCRIPTION:
; 	plot errors vs az,za for a single source. The default assumes that
;	fit contains 1 src. If srcInd is set, then fit can contain more than
;1 source and the routine will only plot srcInd
;-
pro pmplterrs,fit,title,sym=symsrc,over=over,vaz=vaz,nl=nl,xp=xp,col=col,$
			   pl1=pl1,srcind=srcind,ln=ln,scl=scl,cs=cs

	lnst=[0,2]
	if not keyword_set(symsrc) then symsrc=2
	if not keyword_set(nl) then nl=5
	if not keyword_set(xp) then xp=.05
	if not keyword_set(col) then col=1
	if not keyword_set(pl1) then pl1=0
	if n_elements(ln) eq 0 then ln=3
	if n_elements(scl) eq 0 then scl=1.
	if n_elements(xp) eq 0 then xp=.02
	if n_elements(cs) eq 0 then cs=1.
	if n_elements(srcind) ne 0  then begin
		ind=where(fit.srcind eq srcind)
	endif else begin
		ind=lindgen((size(fit))[1])
	endelse
	case pl1 of
		1: begin
			lab1='solid za Error'
			lab2=''
			lnst1=lnst[0]
			y1=fit[ind].zaE
		   end
		2: begin
			lab1='solid az Error'
			lab2=''
			lnst1=lnst[0]
			y1=fit[ind].azE
		   end
     else: begin
			y1=fit[ind].zaE
			y2=fit[ind].azE
			lab1='solid za Error'
			lab2='dash az Error'
			lnst1=lnst[0]
			lnst2=lnst[1]
			end
	endcase
	if  keyword_set(vaz) then begin
		x=fit[ind].az
		xtitle='az'
	endif else begin
		x=fit[ind].za
		xtitle='za'
	endelse
	ytitle='pointing error [asecs]'
	if not keyword_set(over) then  begin
		plot ,x,y1,xtitle=xtitle,ytitle=ytitle,title=title,psym=-symsrc,$
			color=col,linestyle=lnst1,/xstyle,/ystyle,charsize=cs
	endif else begin
		oplot ,x,y1,color=col,linestyle=lnst1,psym=-symsrc
	endelse
	if pl1 eq 0 then begin
		oplot,x,fit[ind].azE,sym=symaz,color=col,linestyle=lnst2,psym=-symsrc
	endif
	if not keyword_set(over) then begin
		note,ln,lab1,xp=xp
		if pl1 eq 0 then note,ln+1*scl,lab2,xp=xp
	endif
	note,nl,string(format='("  ",A)',fit[ind[0]].src),xp=xp ,sym=symsrc,$
			color=col
	return
end
