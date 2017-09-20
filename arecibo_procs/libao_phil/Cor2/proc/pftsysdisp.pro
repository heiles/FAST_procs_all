;+
;tsysfunc - function used by pftsysdisp to fit tsys vs za
;DESCRIPTION:
; routine called by pftsysdisp to fit tsys vs za. It has has the
;za crossover point zac hardwired. This is the angle above which
;the 2nd and 3rd order polynomial terms are included..
;-
function tsysfunc,x,m
;

    zac=14.
    xp=x-zac
    x2=xp*xp
    x3=x2*xp
    ind=where(x le zac,count)
    if count gt 0 then begin
        x2[ind]=0.
        x3[ind]=0.
    endif
    return,[[1.],[x],[x2],[x3] ]
end
;+
;pftsysdisp - fit and then plot tsys vs za for a requested set of data
;SYNTAX: pfdotsys,hdrscn,cals,rfnum,frqmin=frqmin,frqmax=frqmax,
;				  tsysmin=tsysmin,tsysmax=tsysmax,pltitle=pltitle ,deg=deg
;				  sym=sym,exhr=exhr,inchr=inchr,sig=sig,over=over,nofit=nofit
;ARGS:
;		hdrscn[]	: {pfhdrstr} we read in
;		cals[]	    : {pfcalstr} from pfcalonoff
;		rfnum 	    : long 		 receiver to use
; KEYWORDS:
;		pltitle     : string plot title..
;		TSYSMIN		: float min systemp to use
;		TSYSMax		: float max systemp to use
;		frqmin 		: float minfreq mhz to use
;		frqmax 		: float maxfrq  mhz to use
;		deg    		: int   polynomial fit degree. def: 4
;		sym[2		: int symbol touse polA, polB
;		to exclude day
;       exhr[2]     : float exclude the hours in the range
;       inchr[2]    : float include only the hours in the range
;       over        : if set then overplot
;       nofit       : if set, don't bother with the fit
;		sig         : float iterate the fit once. Fit all the points,
;					        then fit only those points within
;				            sig Sigmas of the original fit.
;       col         : [2] if set then color for polA,B
;DESCRIPTION:
;	Select a subset of the calonoff pairs and fit the system temperature
;in the cal off position vs za. Use the routine tsysfunc.Plot the
;data vs za and the fit for polA and polB. 
;The fit is:

; tsys(za)= c0 +c1*za +c2*za^2 + c3*za^3
; where c2,c3= 0 for za <= 14 degrees.
;-
pro pftsysdisp,hdrscn,cals,rfnum,tsysmin=tsysmin,tsysmax=tsysmax,frqmin=frqmin,$
		 frqmax=frqmax,exhr=exhr,pltitle=pltitle,sym=sym,sig=sig,inchr=inchr,$
		 col=col,over=over,nofit=nofit
;
;  check the keywords
; 
	if n_elements(frqmin) eq 0 then frqmin=0.
	if n_elements(frqmax) eq 0 then frqmax=1e12
	if n_elements(tsysmin) eq 0 then tsysmin=0.
	if n_elements(tsysmax) eq 0 then tsysmax=1e6
	if n_elements(pltitle) eq 0 then pltitle='Tsys vs za '
	if n_elements(exhr)    eq 0 then exhr=[0.,0.]
	if n_elements(inchr)   eq 0 then inchr=[0.,24.]
	if n_elements(deg) eq 0 then deg=4
	if n_elements(sym) eq 0 then sym=[1,2]
	if n_elements(sig) eq 0 then sig=0.
	if n_elements(col) eq 0 then col=[1,2]
	if n_elements(nofit) eq 0 then nofit=0

	syma=sym[0]
	symb=sym[1]
		
	exclstsec=long(exhr[0]*3600L)
	exclstpsec=long(exhr[1]*3600L)
	inclstsec=long(inchr[0]*3600L)
	inclstpsec=long(inchr[1]*3600L)
;
;	grab some junk from the headers
;
	pfcalquery,hdrscn,cals,'za',za
	pfcalquery,hdrscn,cals,'rfnum',rfnumAr
	pfcalquery,hdrscn,cals,'frq',frqAr
	pfcalquery,hdrscn,cals,'tm',tmsecs
;
;	figure out indices in cals for our data
;
	inda=where((rfnumAr eq rfnum) and (frqAr ge frqmin) and $
			   (frqAr le frqmax)  and (cals.pol eq 1)   and $
		       (cals.tsysoff ge tsysmin) and (cals.tsysoff le tsysmax) and $
			   ((tmsecs le exclstsec) or (tmsecs ge exclstpsec)) and $
			   ((tmsecs ge inclstsec) and (tmsecs le inclstpsec)))

	indb=where((rfnumAr eq rfnum) and (frqAr ge frqmin) and $
			   (frqAr le frqmax)  and (cals.pol eq 2)   and $
		       (cals.tsysoff ge tsysmin) and (cals.tsysoff le tsysmax) and $ 
			((tmsecs le exclstsec) or (tmsecs ge exclstpsec)) and $
			((tmsecs ge inclstsec) and (tmsecs le inclstpsec)))
;
;	main plot
;
	if not keyword_set(over) then  begin
	  plot,za[inda],cals[inda].tsysoff,psym=syma,xtitle='za',ytitle='Tsys [K]',$
	    title=pltitle,color=col[0]
	endif else begin
	  oplot,za[inda],cals[inda].tsysoff,psym=syma,color=col[0]
	endelse
	note,3,'  polA ',xpos=.02,sym=syma
	note,4,'  polB ',xpos=.02,sym=symb
	oplot,za[indb],cals[indb].tsysoff,psym=symb,color=col[1]
;
;	 if we do the fit
;
	if nofit eq 0 then begin 
;
;	polynomial fit
;
;	fita=poly_fit(za[inda],cals[inda].tsysoff,deg,yfit,yband,sigmaA,/double) 
;	fitb=poly_fit(za[indb],cals[indb].tsysoff,deg,yfit,yband,sigmaB,/double)
;    
    fita=svdfit(za[inda],cals[inda].tsysoff,4,function_name='tsysfunc',$ 
			singular=singlea,yfit=yfita,chisq=chisqa)
    fitb=svdfit(za[indb],cals[indb].tsysoff,4,function_name='tsysfunc',$
            singular=singleb,yfit=yfitb,chisq=chisqb)
	nptsfita=(size(inda))[1]
	nptsfitb=(size(indb))[1]
	diffa=(yfita-cals[inda].tsysoff)
	diffb=(yfitb-cals[indb].tsysoff)
	a=moment(diffa,sdev=sdeva)
	a=moment(diffb,sdev=sdevb)
	if sig ne 0. then begin 
		ia1=inda[where(abs(diffa) le (sig*sdeva))]
		ib1=indb[where(abs(diffb) le (sig*sdevb))]
        fita=svdfit(za[ia1],cals[ia1].tsysoff,4,$
		function_name='tsysfunc',singular=singlea,yfit=yfita1,chisq=chisqa)
        fitb=svdfit(za[ib1],cals[ib1].tsysoff,4,$
			function_name='tsysfunc',singular=singleb,yfit=yfitb1,chisq=chisqb)
	    diffa1=(yfita1-cals[ia1].tsysoff)
	    diffb1=(yfitb1-cals[ib1].tsysoff)
	    a=moment(diffa1,sdev=sdeva1)
	    a=moment(diffb1,sdev=sdevb1)
;
;		2nd iteration
;
		ia2=ia1[where(abs(diffa1) le (sig*sdeva1))]
        ib2=ib1[where(abs(diffb1) le (sig*sdevb1))]
        fita=svdfit(za[ia2],cals[ia2].tsysoff,4,$
        function_name='tsysfunc',singular=singlea,yfit=yfita2,chisq=chisqa)
        fitb=svdfit(za[ib2],cals[ib2].tsysoff,4,$
            function_name='tsysfunc',singular=singleb,yfit=yfitb2,chisq=chisqb)
        nptsfita=(size(ia2))[1]
        nptsfitb=(size(ib2))[1]
        diffa2=(yfita2-cals[ia2].tsysoff)
        diffb2=(yfitb2-cals[ib2].tsysoff)
        a=moment(diffa2,sdev=sdeva)
        a=moment(diffb2,sdev=sdevb)
	endif


;
;	evaluate polynomial at .5 degree steps for plot
;
	z=findgen(38)*.5 + 1
;
	yfita=fita[0]+fita[1]*z
	yfitb=fitb[0]+fitb[1]*z
	ind=where(z gt 14.)
	zsub=z[ind] - 14.
	yfita[ind]=yfita[ind] + zsub*zsub*fita[2] + zsub*zsub*zsub*fita[3]
	yfitb[ind]=yfitb[ind] + zsub*zsub*fitb[2] + zsub*zsub*zsub*fitb[3]
;-------
;
;	overplot fit
;
	oplot,z,yfitb,color=col[1]
	oplot,z,yfita,color=col[0]
;
;	 polynomial params..
;
	linar   =strarr(8)
linar[0]='3rd Deg Fit:         POLA              POLB'
linar[1]=string(format='("constant           :",f7.3,"    ",f7.3)',$
							fita[0],fitb[0])
linar[2]=string(format='("za                 :",f9.5,"  ",f9.5)',$
							fita[1],fitb[1])
	linar[3]=string(format='("(za-14)^2 (za>14):",f10.6," ",f10.6)',$
							fita[2],fitb[2])
	linar[4]=string(format='("(za-14)^3 (za>14):",f10.6,f10.6)',$
							fita[3],fitb[3])
	linar[5]=string(format='("sigmasfit [deg K]  :", f8.3,"    ",f7.3)',$
							sdevA,sdevB)
	linar[6]=string(format='("npts data/fit   :", i4,"/",i4,"  ",i4,"/",i4)', $ 
					(size(inda))[1],nptsfita,(size(indb))[1],nptsfitb)
	maxline=6
    if sig ne 0. then begin
	    linar[7]=string(format='("iterate fit with ",f5.2," sigma pnts")',sig)
	    maxline=7
	endif
	linout=5
	for i=0,maxline do  begin
		note,linout,linar[i],xpos=.02
		linout=linout+1
	endfor
	endif
end
