;+ 
;NAME:
;fitazzaplres - plot residuals from az,za fit
;SYNTAX: fitazzaplres,az,za,y,fitI,tit=tit,key=key,sbc=sbc,sym=sym
;ARGS:
;       az[npts] : float azimuth positions used for fit
;       za[npts] : float za positions used for fit
;  y[2,nsbc,npts]: float raw data used for fit pola,polB 
;       fitI[2,nsbc] : {azzafit} returned from fitazza
;KEYWORDS:
;       key      : int  key=1 residuals by sample
;                           2 residuals by  za
;                           default both
;       tit     : string title of plot
;       sbc     : int   sbc to plot 0-3. default all
;       sym[2]  : int   symbols for pola, b def.. none 
;DESCRIPTION:
;   Plot the residuals from the az,za fit. The routine assumes that
;you have fit the polA and polB data for a number of subcorrelators.
;It is the callers responsibility to move the fitI single structure into
;the array of structures passed into this routine.
;-
;
pro fitazzaplres,az,za,y,fitI,tit=tit,key=key,sbc=sbc,sym=sym

    common colph,decomposedph,colph

    lnsta=0
    lnstb=1
    ln=3
    xp=.05
    col=[1,2,3,5]
    if not keyword_set(key) then key=3
    if not keyword_set(tit) then tit=''
    if not keyword_set(sym) then sym=[0,0]

    s=size(fitI)
    nbrds=s[2]
    sbc1=0
    sbc2=nbrds-1
    if n_elements(sbc) ne 0  then begin
        sbc1=sbc
        sbc2=sbc
    endif
;
    yfita=y
    res=y
    npts=(size(y))[3]
    for i=sbc1,sbc2 do begin &$
        res[0,i,*]= y[0,i,*] - fitazzaeval(az,za,fitI[0,i]) &$
        res[1,i,*]= y[1,i,*] - fitazzaeval(az,za,fitI[1,i]) &$
    endfor

    title=tit + ' ' + fitI[0,0].type + ' data - fit(az,za)'
    if (key eq 1) or (key  eq 3) then begin
        hor
    for i=sbc1,sbc2 do begin
        if i eq sbc1 then begin
            plot,reform(res[0,i,*]),/xstyle,/ystyle,color=colph[col[i]],$
            psym=sym[0],$ 
                linestyle=lnsta,title=title,xtitle='sample',ytitle=$
            fitI[0,i].ytitle
                    
        endif else begin
            oplot,reform(res[0,i,*]),color=colph[col[i]],psym=sym[0],$ 
                linestyle=lnsta
        endelse
            oplot,reform(res[1,i,*]),color=colph[col[i]],psym=sym[1],$ 
                linestyle=lnstb
        note,ln+2+i,string(format='("freq:",f5.0)',fitI[0,i].freq),xp=xp,$
                color=colph[col[i]]
    endfor
    note,ln,'solid polA',xp=xp
    note,ln+1,'  dot polB',xp=xp
    endif

    if (key eq 2) or (key  eq 3) then begin
        hor,0,20
    for i=sbc1,sbc2 do begin
        if i eq sbc1 then begin
            plot,za,reform(res[0,i,*]),/xstyle,/ystyle,color=colph[col[i]],$
                psym=sym[0],linestyle=lnsta,title=title,xtitle='za',$
                    ytitle=fitI[0,i].ytitle
        endif else begin
            oplot,za,reform(res[0,i,*]),color=colph[col[i]],psym=sym[0],$ 
                linestyle=lnsta
        endelse
            oplot,za,reform(res[1,i,*]),color=colph[col[i]],psym=sym[1],$ 
                linestyle=lnstb
        note,ln+2+i,string(format='("freq:",f5.0)',fitI[0,i].freq),xp=xp,$
                color=colph[col[i]]
    endfor
    note,ln,'solid polA',xp=xp
    note,ln+1,'  dot polB',xp=xp
    endif
    return
end
