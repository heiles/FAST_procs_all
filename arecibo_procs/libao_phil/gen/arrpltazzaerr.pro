;+ 
;NAME:
;arrpltazzaerr -  arrow plot of azerr,zaerr vs az,za
;SYNTAX: arrpltazzaerr,az,za,azerr,zaerr,tit,ticklen=tickLen,hard=hard
;                   indlist=indlist,names=names,notab=notab,tabtit=tabtit,
;                   colar=colar,ln=ln,nmOff=nmOff,tblln=tblln,xpsrc=xpsrc
;				    cs1=cs1,csn=csn,ltit=ltit
;ARGS:
;   az[npts]: float   azimuth deg
;   za[npts]: float   za deg
;azerr[npts]: float   azerr asecs
;zaerr[npts]: float   zaerr asecs
;       tit:  string. title.. eg 'pointing errors'
;
;KEYWORDS:
;ticklen      : float  ticklen in asecs. def: 5
;hard         :        if set then use hardcopy settings
;names[nsrc]  : string list of source names used. print left of image.
;indlist[npts]: long   index into names array for each point in az,za
;notab        :        if set then donot print avg/rms table by za
;tabtit       :        title for err table by za. def:errors
;colar[]      : long   color indices to use
;ln           : long   line number (1..) to start the notes ..
;nmoff        : long   offset line to start printing the source names
;tbllen       : long   if supplied then line number to start table
;xpsrc        : float  xpostion to start srcnames. [0.,1]
;                       default -.1 screen,-.2 plotting
;ltit         : int    line to start the plot title
;
;DESCRIPTION:
;   make a 2d arrow plot of azimuth, za error versus az,za. This is 
;normally used to plot the residual fits of the pointing model. The
;length of each arrow will be proportional to the pointing error at 
;that az,za. The direction of the arrow will be that of the error. 
;
;   By default a table of the errors in 5 degrees steps is printed at
;the bottom of the plot. (it may not show up on the screen version but
;it will be there in the postscript file).
;-
; history
; changed to use ,/full
; plot goes at the botom..
pro arrpltazzaerr,az,za,azerr,zaerr,tit,ticklen=tickLen,hard=hard,$
        indlist=indlist,names=names,notab=notab,colar=colar,ln=ln,yoff=yoff,$
        nmoff=nmoff,tblln=tblln,xpsrc=xpsrc,cs1=cs1,csn=csn,ltit=ltit,zamax=zamax

        common colph,decomposedph,colph
;
; for hard copy: 
;  change xpsrcl,-.1 -> -.2
;
	cs=(n_elements(cs1) gt 0)?cs1:1.
	csn=(n_elements(csn) gt 0)?csn:cs
    xpsrcl=(n_elements(xpsrc) gt 0)?xpsrc:-.1  ; where source names go for screen  
    xpsrcr=1.
    lnscl=.6
    hardst=30
    if n_elements(ln) gt 0 then hardst=ln

    nmOffL=(n_elements(nmOff) ne 0)?nmOff:0L
    if keyword_set(hard) then begin
        xpsrcl=-.2  ;for printer
        hard=1
        nmOffL=(n_elements(nmOff) eq 0)?12:nmOff
    endif else hard=0
    if not keyword_set(ticklen) then ticklen=5.
    if not keyword_set(colar) then begin
        numcol=10
        colar=lindgen(numcol)+1
    endif else begin
        numcol=n_elements(colar)
    endelse

	if n_elements(zamax) eq 0 then zamax=20.
    azrad=!dtor*az
    sclPos=1.
;   arrow head fraction (of length)
    arrowHd=.2
;
;   scale arrow to requested length
    sclArrow=1./tickLen
;
; setup the axis... no data
;
    th=findgen(50)/49 * 360 * !dtor
    r =fltarr(50);
;   create_view
    plot,th,r,xrange=[-zamax-1,zamax+1],yrange=[-zamax-1,zamax+1],/nodata, $
        ytitle="west (rising) ",/xstyle,/ystyle,/isotropic,chars=cs
;
;  lines constant za
;
    zainc=zamax/4.
    a=zainc
    for i=0,3 do begin $
        r(*)=a  & $
;       print,r[1] & $
         oplot,r,th,/polar & $
        a=a+zainc
    endfor
;
;  lines constant angle
;
    r=zamax*findgen(50)/50.
    for a=0,360,30 do begin $
        th= (fltarr(50) + a) * !dtor & $
        oplot,r,th,/polar & $
    endfor
;
    yloc=sqrt(azerr*azerr + zaerr*zaerr)
    arrowmag  =sclArrow*yloc
;
;   with north=0, clockwise increase to eas
;
    arrowangle=atan(azerr,zaerr) + azrad
;
;   east=0, ccw increase angle, x,y coord system
;
    xerr=arrowmag*cos(-arrowangle+!pi/2.)
    yerr=arrowmag*sin(-arrowangle+!pi/2.)
;
;    the offset for this az,za point put in center of plot
;   make right of plot be east, top north, left west
;
    x=sclPos*za*cos(!pi/2. - azrad) 
    y=sclPos*za*sin(!pi/2. - azrad) 
    numnm=n_elements(names)
    if numnm gt 0 then begin
        for i=0,numnm-1 do begin
            ind=where(indlist eq i,count)
            col=colar[i mod numcol]
;;            print,'i:',i,' count:',count,' col:',col
            if (count gt 0) then begin
             arrow,x[ind],y[ind],x[ind]+xerr[ind],y[ind]+yerr[ind],/data,$
                hsize=-arrowHd,color=colph[col]
             j=i+1
             inc=0
             xp=xpsrcl
             if j gt 28 then begin
                 j=j-28 
                 xp=xpsrcr
             endif
             note,nmOffL+j*lnscl,names[i],xp=xp,color=colph[col],chars=csn
            endif
        endfor
    endif else begin
            arrow,x,y,x+xerr,y+yerr,/data,$
                hsize=-arrowHd
    endelse
done:
	lnLoc=1
    if hard then lnLoc=hardst
    if (n_elements(ltit) gt 0) then lnLoc=ltit
    xp=.06
    note,lnLoc,tit + ' vs az,za',xp=xp,chars=csn
    note,lnLoc+1*lnScl,string(format='("1 div=",f5.2,"Asecs")',tickLen),xp=xp,$
			chars=csn
    xyouts,-2,-zamax-1,'SOUTH (feed)',chars=csn
    xyouts,-2, zamax, 'NORTH (feed)',chars=csn
;
; compute max,avg,rms in 5 degree increments
;
    a=fltarr(3,5)
    aa=rms(yloc)
    a[0,0]=max(yloc)
    a[1,0]=aa[0]
    a[2,0]=aa[1]
;
    ind=where(za le zainc,count)
    if count gt 0 then begin 
        aa=rms(yloc[ind])
        a[0,1]=max(yloc[ind])
        a[1,1]=aa[0]
        a[2,1]=aa[1]
    endif
;
    ind=where((za gt zainc) and (za le 2.*zainc),count)
    if count gt 0 then begin
        aa=rms(yloc[ind])
        a[0,2]=max(yloc[ind])
        a[1,2]=aa[0]
        a[2,2]=aa[1]
    endif
;
    ind=where((za gt (2.*zainc)) and (za le (3.*zainc)),count)
    if count gt 0 then begin
        aa=rms(yloc[ind])
        a[0,3]=max(yloc[ind])
        a[1,3]=aa[0]
        a[2,3]=aa[1]
    endif
;
    ind=where(za gt (3.*zainc),count)
    if count gt 0 then begin
        aa=rms(yloc[ind])
        a[0,4]=max(yloc[ind])
        a[1,4]=aa[0]
        a[2,4]=aa[1]
    endif
;
    if not keyword_set(notab) then begin
    lnLoc=24
    if hard then lnLoc=hardst+2*lnscl
	if n_elements(tblln) gt 0 then lnLoc=tblln
    if not keyword_set(tabtit) then  tabtit='errors'
    note,lnLoc,string(format='(a," each ",f3.1,"deg")',tabtit,zainc),xp=xp,$
		chars=csn
    zar=findgen(4)*zainc+zainc
    note,lnLoc+1*lnscl,'za max  avg  rms',xp=xp,chars=csn
    for i=0,4 do begin &$
        if i eq 0 then begin &$
            lab='all' &$
        endif else begin &$
            lab=string(format='(i2)',zar[i-1]) &$
        endelse &$
;       print,lab
        line=string(format='(a,f5.1,f5.1,f5.1)',lab,a[0,i],a[1,i],a[2,i]) &$
        note,lnLoc+(2+i)*lnscl,line,xp=xp,chars=csn &$
    endfor
    endif
end
