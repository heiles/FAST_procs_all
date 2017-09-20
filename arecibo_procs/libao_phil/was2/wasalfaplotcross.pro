;+
;NAME:
;wasalfaplotcross - plot alfa cross data
;SYNTAX: alfaplotcross,(baz,bza,proj=proj,auto=auto,two=two)
;ARGS:
; baz[60]   : {corget}   az strip data
; bza[60]   : {corget}   az strip data
;
;KEYWORDS:
;   proj    : string    projid.
;   auto    :           if set then autoscale each plot
;   two     :           if set then two cols by 4 rows..default ,1 by 8.
;     cs    : float     charsize keyword for labels. def: 1.7
;
;RETURNS:
;
;DESCRIPTION:
;   plot alfa cross total power by beam. There will a separate plot window
;for each beam. A single beam will have 120 points (az,za points) for pol
;a (black or white) and polB in Red.
;   Dashed red lines will be plotted at the center of the azimuth and
;za strips. A dashed green line will be plotted at at the start of the
;za strip.
;-

pro wasalfaplotcross,baz,bza ,auto=auto,cs=cs,two=two

    common colph,decomposedph,colph

    if n_elements(cs) eq 0 then cs=1.7
    smpStrip=n_elements(baz)
    procName=string(baz[0].b1.h.proc.procname)
    srcName =string(baz[0].b1.h.proc.srcname)
    scanAz  =baz[0].b1.h.std.scannumber
    scanZa  =bza[0].b1.h.std.scannumber
    nbrds   =baz[0].b1.h.cor.numbrdsused
    npol=2
;
    tpAr=fltarr(smpStrip,2,nbrds,npol)
    for i=0,nbrds-1 do begin
        tpAr[*,0,i,0]=baz.(i).h.cor.lag0pwrratio[0]
        tpAr[*,0,i,1]=baz.(i).h.cor.lag0pwrratio[1]
        tpAr[*,1,i,0]=bza.(i).h.cor.lag0pwrratio[0]
        tpAr[*,1,i,1]=bza.(i).h.cor.lag0pwrratio[1]
    endfor
    tpar=reform(tpar,smpStrip*2,nbrds,2)
    x=findgen(smpStrip*2)
    xp1=.28 
    xp1inc=.5
    pltinc=0.
    x=findgen(smpStrip*2) 

    !p.multi=(keyword_set(two))?[0,2,4]:[0,1,nbrds]
    yr=scanaz/100000000L + 2000L
    dayno= (scanaz/100000L)  mod 1000L
    dm=daynotodm(dayno,yr)
    datLab=string(format='(i2,"/",i2,"/",i4)',dm[1],dm[0],yr) 
    title0=string(format= '(a," ",a," src:",a," ",a," scan:",i10)',$
         datLab,baz[0].b1.hf.projid,srcName,procName,scanaz) &$
    xp=.04 &$
    scl=.5 &$
    ln=9.5 &$
    xtitle='samples of cross [1 div= 3.2 Amin]'
    ytitle='pwr [lin]'
    for ibrd=0,nbrds-1 do begin
        lab=string(format='(" Pix:",i1)',ibrd)
        if keyword_set(auto) then begin
            ymin=min(tpar[*,ibrd,*])
            ymax=max(tpar[*,ibrd,*])
            eps=(ymax-ymin)/20.
            ver,ymin-eps,ymax +eps
        endif
        tit=(ibrd eq 0)?title0 + lab:lab
        plot,x,tpar[*,ibrd,0],xtitle=xtitle,ytitle=ytitle,$
            title=tit ,color=colph[1],charsize=cs
        oplot,x,tpar[*,ibrd,1],color=colph[2]
        flag,[30,90],linestyle=2,color=colph[2] &$
        flag,[60],linestyle=2,color=colph[3] &$
        if ibrd eq 0 then begin
            labrot=string(format='("rotAngl:",f5.0)',baz[0].b1.hf.alfa_ang)
            note,2.,labrot,xp=.04
        endif
    endfor
    return
end
