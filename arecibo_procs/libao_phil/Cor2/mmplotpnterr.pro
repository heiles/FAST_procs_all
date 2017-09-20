;+
;NAME:
;mmplotpnterr - plot pointing error.
;SYNTAX: mmplotpnterr,mm,col=col,vza=vza,vaz=vaz,vtot=vtot,hza=hza,haz=haz,$
;            htot=htot,lns=lns,xps=xps,lnm=lnm,xpm=xpm,fig=fig,fgln=fgln,$
;            xpfig=xpfig,rise=rise,tit=tit ,notot=notot,msrc=msrc,bypix=bypix,$
;            byfrq=byfrq,cs=cs,fln=fln,font=font
;
;ARGS: 
;   mm[n]: {mueller} data structure to plot
;KEYWORDS:
;   col[m]: int color array to use
;  vza[2] : float vertical range for zaErr in asecs  ,[min,max] 
;  vaz[2] : float vertical range for azErr in asecs  ,[min,max] 
; vtot[2] : float vertical range for total pntErr in asecs ,[min,max] 
;  hza[2] : float horizontal range for za in deg [min,max] 
;  haz[2] : float horizontal range for az in deg [min,max] 
;   lns   : float line number to start source labels
;   xps   : float 0.,1. horizontal position for source labels
;   lnm   : float line number to start mean,rms labels
;   xpm   : float 0.,1. horizontal position for mean,rms labels
;   fig   : int   figure number
;   fgln  : float line number for figure number
;   xpfig : float 0,1. horizontal position for figure number
;   rise  : if set then use solid, dash lines to differentiate between 
;           rise set. default is to just plot symbols with no connecting
;                     lines
;   tit   : string title for top of page.
; notot   : if set then don't bother plotting the total errors.
;   msrc  : int   max number of source names to print on left side of page
;                 before moving to the right. (def=30)
;   bypix :       if set then colors are for pixels not frequency
;   byfrq :       use colors to separate frequency (default is to use
;                 colors to separate sources.
;   cs=cs :  float if supplied then character size
;  fln    : 0,31  line to start writing the frequencies
;
;DESCRIPTION:
;   Plot the za pointing error, az pointing error, and the total pointing 
;error (sqrt(zaErr^2+azErr^2)) versus zenith angle and azimuth.
;of the sources in the mm array. Plot each source with a separate symbol 
;and color. The pointing error at each frequency will be overplotted.
;   You can change the colors used via the col keyword (use number 1 through
;10 for colors..1=black,2-red,3-green,4-blue,5..). The vX array allows
;you to set the vertical scale for each plot. The default is to autoscale
;to the max, min of the data. The lnX keywords let you position the 
;source names on the plot.
;   The mm array is normally generated from the mm0proc routine.
;   Before calling this routine you should execute @corinit.
;
;EXAMPLES:
;   plot the xband info for jan02.
;   restore,'/share/megs/phil/x101/x102/runs/c020101_020131.sav'
;   ind=where(mm.rcvname eq 'xb')   ; just get the  xband data
;   mm=mm[ind]
;   fig=1
;   tit='02jan02 Xband'   
;   mmplotpnterr,mm,vg=[0,5.],vt=[40,60],vs=[0,30],vb=[30,45],fig=fig,tit=tit
;
;SEE ALSO:
;   mmplotcsme, mmplotgtsb,mm0proc.
;-
pro mmplotpnterr,mm,col=col,vza=vza,vaz=vaz,vtot=vtot,hza=hza,haz=haz,tit=tit,$
            lns=lns,xps=xps,lnm=lnm,xpm=xpm,fig=fig,xpfig=xpfig,fgln=fgln,$
            rise=rise,notot=notot,msrc=msrc,bypix=bypix,byfrq=byfrq,cs=cs,$
            fln=fln,font=font
;
    on_error,1
    if n_elements(cs) eq 0 then cs=1.5
    nc=n_elements(col)
    if nc eq 0 then begin
        col=lindgen(10)+1
        nc=n_elements(col)
    endif
    if n_elements(tit) eq 0 then tit=''
    ind=sort(mm.srcname)
    ind=uniq(mm[ind].srcname)
    nsrc=n_elements(ind)
    if n_elements(lns) eq 0 then lns=1
    if n_elements(xps) eq 0 then xps=(!d.flags and 1) ? -.2:.02
    if n_elements(fgln) eq 0 then fgln=2
    if n_elements(xpfiq) eq 0 then xpfiq=.8
    if n_elements(rise) eq 0 then rise=0
    if n_elements(lnm) eq 0 then begin
        if not keyword_set(notot) then begin
            lnm=4.5
        endif else begin
            lnm=7.4
        endelse
    endif
    if n_elements(xpm) eq 0 then xpm=.0
;
; get the values, fix up the az to go -90 to 270
;
    za=mm.za
    az=mm.az
    ind=where(az lt -90.,count)
    if count gt 0 then az[ind]=az[ind]+360
    zaErr=mm.fit.zaErr*60.D
    azErr=mm.fit.azErr*60.D
    totErr=sqrt(zaErr^2+azerr^2)
    if n_elements(vza) ne 2 then begin
        min=min(zaErr,max=max)
        vza=[min-1,max+1]
    endif
    if n_elements(vaz) ne 2 then begin
        min=min(azErr,max=max)
        vaz=[min-1,max+1]
    endif
    if n_elements(vtot) ne 2 then begin
        min=min(totErr,max=max)
        vtot=[min-1,max+1]
    endif
    if n_elements(haz) ne 2 then haz=[-91,271]
    if n_elements(hza) ne 2 then hza=[0,20]
;
; compute mean, rms of zaErr,azErr,totErr
;
    mrazerr =rms(azErr,/quiet)
    mrzaerr =rms(zaErr,/quiet)
    mrtoterr=rms(totErr,/quiet)
    scl=.5
    xp=.04
;---------------------------------------------------------------------------
; 
if keyword_set(notot) then begin
    !p.multi=[0,1,4]
endif else begin
    !p.multi=[0,1,6]
endelse
;
;   zaErr versus za
;
    ln=2
    hor,hza[0],hza[1]
    ver,vza[0],vza[1]
    mmplotsrc,za,zaErr,mm,col=col,xtitle='za',ytitle='zaErr [asecs]',ln=lns,$
        title=tit + ' za error vs za',charsize=cs,sclln=scl,rise=rise,xp=xps,$
        msrc=msrc,bypix=bypix,byfrq=byfrq,fln=fln,font=font
    if n_elements(fig) gt 0 then fig=fignum(fig,xp=xpfig,ln=fgln)
;
;   zaErr versus az
;
    hor,haz[0],haz[1]
    ver,vza[0],vza[1]
    mmplotsrc,az,zaErr,mm,col=col,xtitle='az',ytitle='zaErr [asecs]',$
        title='za error vs az',charsize=cs,/nolab,rise=rise,bypix=bypix,$
        byfrq=byfrq,font=font
    flag,[0,180],linestyle=2
;
;   azErr versus za
;
    hor,hza[0],hza[1]
    ver,vaz[0],vaz[1]
    mmplotsrc,za,azErr,mm,col=col,xtitle='za',ytitle='azErr [asecs]',$
        title=' az error vs za',charsize=cs,/nolab,rise=rise,bypix=bypix,$
        byfrq=byfrq,font=font
;
;   azErr versus az
;
    hor,haz[0],haz[1]
    ver,vaz[0],vaz[1]
    mmplotsrc,az,azErr,mm,col=col,xtitle='az',ytitle='azErr [asecs]',$
        title='az error vs az',charsize=cs,/nolab,rise=rise,bypix=bypix,$
        byfrq=byfrq,font=font
    flag,[0,180],linestyle=2
;

    if not keyword_set(notot) then begin
;
;   totErr versus za
;
        hor,hza[0],hza[1]
        ver,vtot[0],vtot[1]
        mmplotsrc,za,totErr,mm,col=col,xtitle='za',ytitle='totErr [asecs]',$
        title='total error vs za',charsize=cs,/nolab,rise=rise,bypix=bypix,$
        byfrq=byfrq,font=font
;
;   totErr versus az
;
        hor,haz[0],haz[1]
        ver,vtot[0],vtot[1]
        mmplotsrc,az,totErr,mm,col=col,xtitle='az',ytitle='totErr [asecs]',$
            title='total error vs az',charsize=cs,/nolab,rise=rise,bypix=bypix,$
            byfrq=byfrq,font=font
        flag,[0,180],linestyle=2
    endif
;
; label the mean, rms
;
    labza =string(format='("zaErr Mean:" ,f7.2," Rms:",f5.2)',mrzaErr)
    labaz =string(format='("azErr Mean:" ,f7.2," Rms:",f5.2)',mrazErr)
    labtot=string(format='("totErr Mean:",f7.2," Rms:",f5.2)',mrtotErr)
    if not keyword_set(notot) then begin
        note,lnm      ,labza,xp=xpm
        note,lnm+1*scl,labaz,xp=xpm
        note,lnm+2*scl,labtot,xp=xpm
    endif else begin
        note,lnm      ,labza,xp=xpm
        note,lnm+1*scl,labaz,xp=xpm
    endelse
end
