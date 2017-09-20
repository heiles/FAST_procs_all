;+
;pfplotstd - call pfplot with standard labels
;
;SYNTAX: pfplotstd,srcinp,srcout,za,y,type=type,xtit=xtit,
;				   ytit=ytit,tit=tit,_extra=e
;ARGS:
;	 	srcinp[]    : {pfsrcinp} describes each source	
;	 	srcout[npts]: {pfsrcout} holds the measured data
;	 	    za[pnts]: float za for each point
;	   y[2,sbc,npts]: float data to plot
;KEYWORDS:
; 			    type: string	 
;				      'sefd'
;				      'tsys'
;				      'gain'
;				      'calscl'
;				      'fpol'
;		   tit:   string. if set then prepend this to default title
;		  xtit:   string. if set then override default xtitle
;		  ytit:   string. if set then override default ytitle
;		noteln:	  int     line to start notes..
;_extra:		args that pfplot accepts:
;
;		   sbc :  -1 no sbc dim., 0-3 1 sbc , or 4 for all sbc
;		   over:  if set then overplot
;			pol:  int 1-pola,2-polb,3 or not present .. both
;			sep:  if set then each sbc is a separate plot
;		     xp:  0-1. xposition for notes
;		  notel:  0-1. xposition for notes
;	    lnstyle: see pfplot
;				
;			
;KEYWORDS:
;- 
pro pfplotstd,srcinp,srcout,za,y,type=type,xtit=xtit,ytit=ytit,$
 			  tit=tit,noteln=noteln,_extra=e

	if not keyword_set(tit) then tit=''
	if not keyword_set(noteln) then noteln=3
	xtitle='za'
	if keyword_set(xtit) then xtitle=xtit
	pol=3
	case type of
		'gain': begin
				ytitle='gain [K/Jy]'
				title ='Gain vs za'
				end
		'gainavg': begin
				ytitle='Avg gain [K/Jy]'
				title ='Avg Gain vs za'
				pol=1
				end
		'sefd': begin
				ytitle='sefd [Jy/Tsys]'
				title ='SEFD vs za'
				end
		'tsys': begin
				ytitle='Tsys [K]'
				title ='Tsys vs za'
				end
		'calscl': begin
				ytitle='Kelvins/Count'
			    title=' CalScale Factor vs za '
				end
		'fpol': begin
				ytitle='Fractional polarization'
			    title=' Fractional polarization'
				pol=1
				end
		else: begin
				ytitle=''
				title =''
				end
	endcase

	title=tit + ' ' + title
	pfplot,srcinp,srcout,za,y,xtitle,ytitle,title,noteln,pol=pol,_extra=e
	return
end
