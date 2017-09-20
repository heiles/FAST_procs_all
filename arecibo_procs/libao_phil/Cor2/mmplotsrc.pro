;+
;NAME:
;mmplotsrc - x,y plot using different colors for each source
;SYNTAX: mmplotsrc,x,y,mm,xtitle=xtitle,ytitle=ytitle,title=title,over=over
;                xp=xp,ln=ln,nolab=nolab,col=col,sym=sym,sclln=sclln, 
;                decord=decord,rise=rise,fln=fln,_extra=e,srcl=srcl,msrc=msrc
;                xlp=xlp,thick=thick,charth=charth
;ARGS:   x[npts]    : float xarray  to plot
;        y[npts]    : float yarray  to plot
;       mm[npts]    : {mueller} mueller info
;KEYWORDS:
;   xtitle  : string label for x axis
;   ytitle  : string label for y axis
;   title   : string label top of plot
;   over    : if set then overplot the data with what is there.
;   xp      : float  xposition for srcnames 0..1
;   ln      : int    line to start source list 0..33
;   sclln   : float  fractional step between labels (default 1.)
;   rise    : if set then plot,rise,set as separate linestyles
;   sym     : if set then use symbols rather than color to distinguish
;             sources. use 1st elm of col array for all colors
;   col[nsrc]:use the values for the color (1..10) rather than the defaults
;   nolab   : if set then donot print the source names
;   decord  : if set then plot src in dec order, rather then ra.
;             useful if x is just lindgen(npts) and you want to plot
;             the sources by increasing ra or dec.
;   byfrq   : Use symbols for sources, color for freq. (does not work
;             with /rise option
;   bypix   : if set then use symbols for sources color for pixels.
;             only for alfa, does not work with /rise option.
;   fln     : float line to start writing the frequencies
;   fxp     : float xpos (0...1) to start writing the frequencies
;   srcl[]  : string user passes in source list rather than searching
;                    through mm. Use this if you are making multiple
;                    plots per page and all the plots may not have all the
;                    same sources (eg. lbw 1415 Mhz is shared by the high
;                    and low lbw measurements).
;   msrc    : int   max sources to list on left before move to right col
;   xlp     : float xpos (0..1) for 2nd col. def:1.
;   _extra  : e .. passed to plot routine.
;DESCRIPTION:
;   mmplotsrc will plot the x,y data with a different color 
;for each source.
;EXAMPLE:
;   mmplotsrc,mm.za,mm.fit.tsys,mm,xtitle='za',ytitle='tsys[K]',
;       title='tsys vs za'
;-
;history:
; 02dec01 if only 1 source, still plot it.
; 22nov02 added byfreq option for not rise/set
; 04dec04 if alfa, then use brd number instead of freq for colors
pro mmplotsrc,x,y,mm,xtitle=xtitle,ytitle=ytitle,title=title,over=over,$
    sym=sym,xp=xp,ln=ln,rise=rise,nolab=nolab,col=col,sclln=sclln,$
    decord=decord,byfrq=byfrq,fln=fln,fxp=fxp,_extra=e,srcl=srcl,msrc=msrc,$
        xlp=xlp,bypix=bypix,thick=thick,charth=charth
    common colph,decomposedph,colph

     on_error,1
    if n_elements(xp) eq 0 then xp=(!d.flags and 1) ? -.2:.02
    if n_elements(ln) eq 0  then ln=3
    if n_elements(sclln) eq 0  then sclln=1.
    if n_elements(fln) eq 0 then fln=2
    if n_elements(fxp) eq 0 then fxp=.25
    if n_elements(msrc) eq 0 then msrc=30
    if n_elements(xlp) eq 0 then xlp=1.005
    if n_elements(thick) eq 0 then thick=1
    if n_elements(charth) eq 0 then charth=1
    useAlfa=mm.rcvnum eq 17

    if keyword_set(decord) then begin
        if n_elements(srcl) ne 0 then begin
            n=n_elements(srcl)
            srcs=srcl
            decval=lonarr(n)
            for i=0,n-1 do begin
                decval[i]=long(strmid(srcs[i],6,3))
            endfor
            srcs=srcs[sort(decval)]
        endif else begin
            ind=uniq(mm.srcname,sort(mm.srcname))   ; 
            ind1=sort(mm[ind].dec1950)
            ind=ind[ind1]
            srcs=mm[ind].srcname
        endelse
    endif else begin
        if n_elements(srcl) ne 0 then begin
            srcs=srcl
        endif else begin
            srcs=mm[uniq(mm.srcname,sort(mm.srcname))].srcname
        endelse
    endelse
    usrcol=1
    if n_elements(col) eq 0 then begin
        usrcol=0
        colloc=[  1,   2   , 3   , 4     ,7     , 9 ,6,$
                  5,   8   , 9   , 10    ,1     , 2 ,3]
    endif else begin
        colloc=col
    endelse
                    
    symb  =[  1,   2   , 4   , 5     ,6     , 8 ,7,$
              1,   2   , 4   , 5     ,6     , 8 ,7]
    if keyword_set(rise) then begin
        symb=-1*symb
        lnsrise=0
        lnsset =1
        az=((mm.az + 360) mod 360.)
    endif
    if keyword_set(byfrq) then begin
        frqTot=  mm[uniq(mm.cfr,sort(mm.cfr))].cfr
        nfrqTot=  n_elements(frqTot)
    endif
    if keyword_set(bypix) then begin
        pixTot=  mm[uniq(mm.brd,sort(mm.brd))].brd
        npixTot=  n_elements(pixTot)
    endif
    usersym,[-.5,.5],[0.,0.]
    if (keyword_set(sym) ne 0) and (usrcol eq 0) then colloc=colloc*0+colloc[0]
    numsrcs=n_elements(srcs)
    numplot=0
    maxcol=n_elements(colloc)
    maxsym=n_elements(symb)
for i=0,numsrcs-1 do begin  &$
    lxp=(i ge msrc)?xlp:xp
    icol=(i mod maxcol)
    isym=(i mod maxsym)
    if keyword_set(rise) then begin
        ind1=where((mm.srcname eq srcs[i]) and (az ge 180.),count1)
        ind2=where((mm.srcname eq srcs[i]) and (az lt 180.),count2)
        if (count1 gt 0) or (count2 gt 0) then begin
            if (numplot eq 0 ) and (not keyword_set(over)) then begin
               if count1 gt 0 then ind=ind1 else ind=ind2
               if n_elements(ind) eq 1 then begin
                xx=[x[ind],x[ind]]
                yy=[y[ind],y[ind]]
               endif else begin
                xx=x[ind]
                yy=y[ind]
               endelse
               plot,xx,yy,color=colph[1],psym=symb[isym],xtitle=xtitle,$
                    ytitle=ytitle,title=title,/nodata,_extra=e,$
                    xthick=thick,ythick=thick,charth=charth
            endif
            if count1 gt 0 then begin
                  if (n_elements(ind1) eq 1)  then begin
                    xx=[x[ind1],x[ind1]]
                    yy=[y[ind1],y[ind1]]
                    ind=[0,1]
                  endif else begin
                    xx=x[ind1] & yy=y[ind1] & ind=sort(xx)
                endelse
                  oplot,xx[ind],yy[ind],color=colph[colloc[icol]],$
                  psym=symb[isym],linestyle=lnsrise,$
                    thick=thick
            endif
            if count2 gt 1 then begin
                  if (n_elements(ind2) eq 1)  then begin
                    xx=[x[ind2],x[ind2]]
                    yy=[y[ind2],y[ind2]]
                    ind=[0,1]
                  endif else begin
                    xx=x[ind2] & yy=y[ind2] & ind=sort(xx)
                  endelse
                  oplot,xx[ind],yy[ind],color=colph[colloc[icol]] ,$
                        psym=symb[isym], linestyle=lnsset,$
                        thick=thick
            endif
            numplot=numplot+1
            if not keyword_set(nolab) then $
            note,ln+(i mod msrc)*sclln,' ' +$
                    srcs[i],color=colph[colloc[icol]],sym=symb[isym],$
                    xp=lxp ,charth=charth
        endif
    endif else begin
        ind  =where(mm.srcname eq srcs[i],count)
        if count gt 0 then begin

;           by freq color for freq, symb for source

            if keyword_set(byfrq) then begin
                xx=x[ind]
                yy=y[ind]
                frqarl=mm[ind].cfr
                frqlistLoc=frqarl[uniq(frqarl,sort(frqarl))]
                for j=0,n_elements(frqlistLoc)-1 do begin
                    ff=frqListLoc[j]
                    ind=where(frqarl eq ff,count)
                    if count eq 1 then begin
                        xxx=[xx[ind],xx[ind]]
                        yyy=[yy[ind],yy[ind]]
                    endif else begin
                        xxx=xx[ind]
                        yyy=yy[ind]
                    endelse
                    ind=where(ff eq frqTot,count)
                    jj=ind mod maxcol
                    colToUse=(colloc[jj])[0]
                    if (numplot eq 0 ) and (not keyword_set(over)) then begin &$
                        plot,xxx,yyy,color=colph[1],psym=symb[isym],$
                          xtitle=xtitle,$
                         ytitle=ytitle,title=title,/nodata,_extra=e, $
                         xthick=thick,ythick=thick,charth=charth
                    endif
                    oplot,xxx,yyy,color=colph[colToUse],psym=symb[isym],$
                    thick=thick
                    if j eq 0 then numplot=numplot+1
                endfor
                colSrcName=colloc[0]
;
;            plot color for source, symb for source

            endif else begin
            if keyword_set(bypix) then begin
                xx=x[ind]
                yy=y[ind]
                pixarl=mm[ind].brd
                pixlistLoc=pixarl[uniq(pixarl,sort(pixarl))]
                for j=0,n_elements(pixListLoc)-1 do begin
                    pp=pixListLoc[j]
                    ind=where(pixarl eq pp,count)
                    if count eq 1 then begin
                        xxx=[xx[ind],xx[ind]]
                        yyy=[yy[ind],yy[ind]]
                    endif else begin
                        xxx=xx[ind]
                        yyy=yy[ind]
                    endelse
                    ind=where(pp eq pixTot,count)
                    jj=ind mod maxcol
                    colToUse=(colloc[jj])[0]
                    if (numplot eq 0 ) and (not keyword_set(over)) then begin &$
                        plot,xxx,yyy,color=colph[1],psym=symb[isym],$
                          xtitle=xtitle,$
                         ytitle=ytitle,title=title,/nodata,_extra=e,$
                         xthick=thick,ythick=thick,charth=charth
                    endif
                    oplot,xxx,yyy,color=colph[colToUse],psym=symb[isym],$
                        thick=thick
                    if j eq 0 then numplot=numplot+1
                endfor
                colSrcName=colloc[0]
            endif else begin
                if count eq 1 then begin
                    xx=[x[ind],x[ind]]
                    yy=[y[ind],y[ind]]
                endif else begin
                    xx=x[ind]
                    yy=y[ind]
                endelse
                colToUse=colloc[icol]
                if (numplot eq 0 ) and (not keyword_set(over)) then begin &$
                     plot,xx,yy,color=colph[1],psym=symb[isym],xtitle=xtitle,$
                         ytitle=ytitle,title=title,/nodata,_extra=e,$
                         xthick=thick,ythick=thick,charth=charth
                endif
                oplot,xx,yy,color=colph[colloc[icol]],psym=symb[isym],$
                    thick=thick
                colSrcName=colloc[icol]
                numplot=numplot+1
           endelse
           endelse
           if not keyword_set(nolab) then begin
              note,ln+(i mod msrc) *sclln,' ' +$
                srcs[i],color=colph[colSrcName],sym=symb[isym],$
                xp=lxp,charth=charth
           endif 
       endif
    endelse
endfor
;
;   if srclist specified reprint, since we have have skipped some srcs
;
    if (n_elements(srcl) gt 0) and (not keyword_set(nolab)) then begin
        inc=0
        for i=0,n_elements(srcs)-1 do begin
            lxp=(i ge msrc)?xlp:xp
            isym=(i mod maxsym)
            icol=i mod maxcol
            col=(keyword_set(byfrq)) ?colloc[0]:colloc[icol]
             note,ln+(i mod msrc)*sclln,' ' + srcs[i],color=colph[col],$
                sym=symb[isym],xp=lxp,charth=charth 
        endfor
    endif

    if keyword_set(byfrq) and (not keyword_set(nolab)) then begin
       xpinc=.085
       for i=0,nfrqTot-1  do begin
            lab=string(format='(f6.0," ")',frqTot[i])
            j=i mod n_elements(colloc)
            note,fln,lab,xp=fxp+xpinc*i,color=colph[colloc[j]],charth=charth
        endfor
        note,fln,"Mhz",xp=fxp+xpinc*nfrqTot,charth=charth
    endif
    if keyword_set(bypix) and (not keyword_set(nolab)) then begin
       xpinc=.085
       for i=0,npixTot-1  do begin
            lab=string(format='("pixel",i1," ")',pixTot[i])
            note,fln,lab,xp=fxp+xpinc*i,color=colph[colloc[i]],charth=charth
        endfor
    endif
    return
end
