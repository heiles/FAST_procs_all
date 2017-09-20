;+
;plazswfit - plot azswing data, overplot fit. print fit values, and residuals
;
;SYNTAX:
;     plazswfit,azd,azfit,/roll,label=label,fcolor=fcolor,ln=ln
;
;ARGS
;	  azd:   array of {ts} structure holding data used for fit
;     azfit: {azf} structure hold fit values
;
;KEYWORDS:
;	  roll: if set then plot roll. if not set, then plot pitch
;	  label : date 
;	  foc   : if not zero label as focus
;	  fcolor: if provided then use this color for the fit
;	  ln    : if provided then starting line number for fitlabels
;
pro  plazswfit,azd,azfit,roll=roll,foc=foc,label=label,over=over,color=color,$
			fcolor=fcolor,ln=ln
     common colph,decomposedph,colph

				
;
	if n_elements(label) eq 0 then label=''
	if not keyword_set(roll)  then roll=0 else roll=1
	lcol=1
	if n_elements(color) ne 0 then lcol=color
	if n_elements(foc) eq 0 then foc=0 else foc=1
	if n_elements(fcolor) eq 0 then fcolor=lcol
	if n_elements(ln) eq 0 then ln=1
	case 1 of
		roll ne 0: begin
			y=azd.r
			fdat=azfit.r
			lab="roll"
			end
		foc ne 0: begin
			y=azd.p
			fdat=azfit.p
			lab="focus"
			end
		else: begin
			y=azd.p
			fdat=azfit.p
			lab="pitch"
		    end
	endcase
	title=string(format='(A," az swing. solid:data, dash:fit")',label+lab)
	if not keyword_set(over) then begin
		plot,azd.az,y,title=title,xtitle="az",ytitle=lab,xstyle=1,ystyle=1 
	endif else begin
 	 oplot,azd.az,y,color=colph[lcol]
	endelse
	oplot,azd.az,azsweval(fdat,azd.aznomod),linestyle=2,color=colph[fcolor]
;
;	output the fit values
;
	x=(!x.crange[1]- !x.crange[0]) *.02 + !x.crange[0]
	y=!y.crange[1] - (!y.crange[1]-!y.crange[0]) *.03*ln
 	azswlab,azfit,x,y,roll=roll,foc=foc,color=lcol
	return
end
