;+
;NAME:
;ht_1325_month - image,total pwr plot of 1325 band for month
;SYNTAX:istat=ht_1325_month(yymm,d,used=used,flagkey=flagkey,$
;	           tmStep=tmStep, pschan=pschan,plottype=plottype)
;
;ARGS:
;yymm: long yymm to process
;d[n]: {}   if /used then user passes data in here
;           if used 0 then routine reads the data
;           and passes back data in d
;KEYWORDS:
;used:      if set then user passes data in via d
;           if not set then routine returns data in d
;flagkey:   1 - flag by radar type default
;           2 - flag puntasalinchan
;pschan[l]  : int puntas salinas channels to flag
;tmStep      :double time step for output image (in days).
;                def=1/24. (1 hour).
; wait      : if set then wait between plots
;plottype   : 1= dynamic spectral image, 2= lineplot
;             for 2, set !p.multi=[0,1,2] before
;             first call
;
;RETURNS:
;istat:     1 ok
;           -1 error inputing datan
;d    : {}  im struct returned if used is 0
;
;DESCRIPTION
;	Read and plot monthly summary of hilltope monitoring
;1325 band. 
;	flag the radars, or flag channels of punta salinas.
;   after apr15 only flag modeA (since 100 channels)
;	The top frame contains a dynamic spectra for the month
;The bottom frame is the average spectra for the month.
;	The routine uses the current window, so size it before
;calling the routine. 
;	Normal hardcopy is the done by screen grab (to get the
;flag colors).
;
;
function ht_1325_month,yymm,d,used=used,flagkey=flagkey,$
			tmstep=tmstep,pschan=pschan,plottype=plottype
    common colph,decomposedph,colph
		
	pltImg=1
	freq=1325.
	lflagkey=1
	if n_elements(flagkey) eq 1 then lflagkey=(flagkey eq 2)?2:1
	if n_elements(plottype) eq 0 then plottype=pltImg
	tmStep=(n_elements(tmStep) eq 1)?tmStep:1d/24d
	yr=yymm/ 100L
	mon=yymm mod 100L
	days=daysinmon(mon,yr)
	lmonyr=monname(mon) + string(format='(i02)',yr)
	yymmdd1=yymm*100L + 1
	yymmdd2=yymm*100L + days
	rdData=keyword_set(used)?0:1
	if (rdData) then begin
		n=iminpdaymulti(yymmdd1,freq,d,yymmdd2=yymmdd2)
		if n le 0 then return,-1
	endif
	jd0=yymmddtojulday(yymmdd1)
	jd1=yymmddtojulday(yymmdd2) + 1d - tmStep/2.; end of last day
;
;	see if d.r.d is dbm or linear
;
	islinear=(mean(d.r.d) gt 0.)
	
	d_db=d
	if islinear then imdb,d_db
	d_lin=d
	if not islinear then imlin,d_lin
	freqht=immkfrq(d.r[0])
;
; get bw hilltop chan
;
	bwht=freqht[1]-freqht[0]
	xtht=d.r.h.date - d.r[0].h.date + 1. + d.r.h.secmid/86400d
;
; get punta salinas freq
; 
	itemp=yymm
	if (yymm lt 2100) then itemp+=200000
	old=(itemp lt 201504)
	rfipuntasalinasfreq,psinfo,old=old
	; fix up mode A
;	psinfo[1].name=psinfo[3].name
;	psinfo[3].name=''
	if (not old) and (n_elements(pschan) eq 0)  then begin
		a=stregex(psinfo.name,"mode*")		
		ii=where(a ne -1,nchanps)
		pschan=psinfo[ii].channum
	endif
	nchanps=n_elements(psinfo)
	frqallps=psinfo.freq
			
	faa=[1257.59,1252.41,1349.59,1344.41]
	pb=[1274.58,1269.41,1332.59,1327.41]
	aero=[1261.25,1246.2]
;
; check for the offset in ht data
;
	lmodes=['modeA','modeB','modeC']
	iiusePs=(n_elements(pschan) gt 0)?(pschan-1):lindgen(nchanps)
	xoff=-.2
	colps=2
	colpb=3
	colfaa=4
 	colAero=5
	ls1=0
	ls2=0
	iifrq=where(freqht lt 1410,nfrq)
	nin=d.nrecs
	if (plottype eq pltimg) then begin
;
; 1st time.. flag different radars .. for punta salinas just flag
; 2nd time .. flag punta salinas channels
;
		img=imgflat(d_lin.r.d[iifrq],0,/median)
;
;	now reinterpolate array to uniform spacing.. 
;
		secMid =d.r.h.secMid
		dayno=d.r.h.date mod 1000L
		year=d.r.h.date / 1000L
		jdAr=daynotojul(dayno,year) + d.r.h.secMid/86400d
		nout=resampleary(img,jdAr,tmStep,imgI,y1=jd0,y2=jd1,$
					yout=yout,cntYOut=cntYOut)

		zy=-((nout/800) + 1) 
		zx=2
;
		xoff=-.5
		xr=[freqht[0],freqht[nfrq-1]] + xoff
		yr=[yout[0],yout[nout-1]] - jd0 + 1.
		nsigclip=[-1,3]
		maxval=1d2
		border=80
		ytit='day in ' + lmonyr
		xtit='freq [Mhz]'
		cs=1.8
;
;-----------------------------------------------------------------
		!p.multi=0
;

		imgdisp,imgI < maxval,xr=xr,yr=yr,zx=zx,zy=zy,nsig=nsigclip,$
        	border=border,ytit=ytit,xtit=xtit,chars=cs
;
		ln=.8
		if Lflagkey eq 1 then begin
			note,ln,'hilltop monitor dynamic spectra ' + lmonyr + '. 1325 band. Flag radars',$
       			chars=cs
		    ln=1.2
			xp=-.1
		endif else begin
			note,ln,'hilltop monitor dynamic spectra ' + lmonyr +$
					 '. 1325 band. Flag PuntaSalinas(PS)',chars=cs
		    ln=1.3
			lnr=1.3
			xp=-.1
			xpr=.95
		endelse
	endif else begin 
;
;-----------------------------------------------------------------
; db  plot .. use all the data
;
		y=total(d_lin.r[0:nIn-1].d,2)/nIn
		ydb=alog10(y)*10.
		sym=10
		cs=1.4
		ytit='avg power [db]'
        if Lflagkey eq 1 then begin
            ln= .8
            xp=-.1 
			titEx=" (Flag all radars)"
        endif else begin
            ln=15
			lnr=18
            xp=-.1 
			titEx=" (Flag PuntaSalinas chan)"
			xpr=.90
        endelse
		plot,freqht[iifrq]+xoff,ydb[iifrq],psym=sym,$
        	ytit=ytit,xtit=xtit,chars=cs,$
        	tit='average spectra month of ' + lmonyr + titEx
	endelse

;   labels for the images/plots

	if Lflagkey eq 1 then begin
		flag,frqallps[*,iiusePs],linestyle=ls1,col=colph[colps] 
		flag,faa,linestyle=ls1,col=colph[colfaa] 
		flag,pb,linestyle=ls1,col=colph[colpb] 
		flag,aero,linestyle=ls1,col=colph[colaero] 
		csn=1.5
;		ln=13.5
;		xp=.05
		scl=.7
		note,ln+0*scl,"PuntaSalinas",xp=xp,chars=csn,font=font,col=colph[colps]
		note,ln+1*scl,"FaaRdr",xp=xp,chars=csn,font=font,col=colph[colFAA]
		note,ln+2*scl,"PuntaBoriquen",xp=xp,chars=csn,font=font,col=colph[colPb]
		note,ln+3*scl,"Aerostat",xp=xp,chars=csn,font=font,col=colph[colAero]
	endif else begin
		for i=0,n_elements(iiusePs)-1 do begin &$
    		icol=i mod 10 + 2 &$
     		jj=iiusePs[i] &$
    		flag,frqallps[0,jj],linestyle=ls1,col=colph[icol] &$
    		flag,frqallps[1,jj],linestyle=ls2,col=colph[icol] &$
		endfor
		 ;
        ; label ps channels
        ;
        csn=1.5
;        ln=17
;        xp=.02
        scl=.7
        for i=0,n_elements(iiusePs)-1 do begin &$
			j=iiusePs[i]
            lab='PSc' + string(format='(i02)',psinfo[j].channum)  &$
            note,ln+i*scl,lab,xp=xp,chars=csn,font=font,col=colph[i+2] &$
        endfor
        xp=.95
        note,lnr     ,"modeA  ",xp=xpr,chars=csn
		  ii=where(psinfo[iiuseps].channum eq 14,cnt)
          ic=(cnt eq 0)?1:ii +2
        note,lnr     ,"       14",xp=xpr,chars=csn,col=colph[ic]
		  ii=where(psinfo[iiuseps].channum eq 40,cnt)
          ic=(cnt eq 0)?1:ii +2
        note,lnr     ,"          ,40",xp=xpr,chars=csn,col=colph[ic]

        note,lnr+1*scl,"modeB  ",xp=xpr,chars=csn
		  ii=where(psinfo[iiuseps].channum eq 14,cnt)
          ic=(cnt eq 0)?1:ii +2
        note,lnr+1*scl,"       14",xp=xpr,chars=csn,col=colph[ic]
		  ii=where(psinfo[iiuseps].channum eq 54,cnt)
          ic=(cnt eq 0)?1:ii +2
        note,lnr+1*scl,"          ,54",xp=xpr,chars=csn,col=colph[ic]

        note,lnr+2*scl,"modeC ",xp=xpr,chars=csn
		  ii=where(psinfo[iiuseps].channum eq 40,cnt)
          ic=(cnt eq 0)?1:ii +2
        note,lnr+2*scl,"       40",xp=xpr,chars=csn,col=colph[ic]
		  ii=where(psinfo[iiuseps].channum eq 52,cnt)
          ic=(cnt eq 0)?1:ii +2
        note,lnr+2*scl,"          ,52",xp=xpr,chars=csn,col=colph[ic] &$

	endelse
	return,d.nrecs
end
