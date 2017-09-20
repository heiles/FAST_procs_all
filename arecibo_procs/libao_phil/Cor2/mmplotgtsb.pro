;+
;NAME:
;mmplotgtsb - plot gain, Tsys, sefd, and beamWidth for sources
;SYNTAX: mmplotgtsb,mm,col=col,vg=vg,vt=vt,vs=vs,vb=vb,tit=tit,lns=lns,$
;                   lnf=lnf,xpfrq=xpfrq,fig=fig,fgln=fgln,xpfig=xpfig,xps=xps,$
;                   srccol=srccol,bwamin=bwamin,msrc=msrc,bypix=bypix   
;                   charth=charth,thick=thick,cs=cs ,font=font
;
;ARGS: 
;   mm[n]: {mueller} data structure to plot
;KEYWORDS:
;   col[m]: int color array to use
;   vg[2] : float vertical range for gain [K/Jy]     ,[min,max] 
;   vt[2] : float vertical range for Tsys [K]        ,[min,max] 
;   vs[2] : float vertical range for sefd [Jy/Tsys]  ,[min,max] 
;   vb[2] : float vertical range for beamWidth[asecs],[min,max] 
;   tit   : string title for top of plot.
;   lns   : float line number to start plotting source names.def=2
;   lnf   : float line number to print frquencies/pixels. def=2
;   xpfrq : float 0.,1. hor position for frequency/pixel. def=.25
;   fig   : int   figure number
;   fgln  : float line number for figure number
;   xpfig : float 0,1. horizontal position for figure number
;   xps   : float 0,1. horizontal position for source labels
;   srccol: if set then use colors for sources rather than freq/pix
;   bwamin: if set then plot beam width in arc min rather than asecs
;   msrc  : int   max number of source names to print on left side of page
;                 before moving to the right. (def=30)
;   bypix :       if set then colors are for pixels not frequency
;   byaz  :       if set then plot vs azimuth. default is za
;
;DESCRIPTION:
;   Plot the gain, Tsys, Sefd, and average beam width for all 
;of the sources in the mm array. Plot each source with a separate symbol.
;Plot each frequency as a separate color. It is probably a good idea to
;plot 1 receivers worth of data at a time. 
;   You can change the colors used via the col keyword (use number 1 through
;10 for colors..1=black,2-red,3-green,4-blue,5..). The vX array allows
;you to set the vertical scale for each plot. The default is to autoscale
;to the max, min of the data. The lns keyword lets you position the 
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
;   mmplotgtsb,mm,vg=[0,5.],vt=[40,60],vs=[0,30],vb=[30,45],fig=fig,tit=tit
;
;SEE ALSO:
;   mmplotcsme, mmplotpnterr,mm0proc.
;-
;history: switched by srccol,byfrq to mmplotsrc call
pro mmplotgtsb,mm,col=col,vg=vg,vt=vt,vs=vs,vb=vb,tit=tit,$
            lns=lns,lnf=lnf,xpfrq=xpfrq,fig=fig,xpfig=xpfig,$
         fgln=fgln,xps=xps,srccol=srccol,bwamin=bwamin,msrc=msrc,bypix=bypixU,$
         thick=thick,charth=charth,cs=cs,byaz=byaz,font=font

;
;       need to print source names here rather than mmplotsrc
;       mmplotsrc assumes all sources in first freq.
    symb  =[  1,   2   , 4   , 5     ,6     , 8 ,7,$
              1,   2   , 4   , 5     ,6     , 8 ,7]

;    on_error,1
    nc=n_elements(col)
    if nc eq 0 then begin
        col=lindgen(10)+1
        nc=n_elements(col)
    endif
    titl=''
    if n_elements(tit) ne 0 then titl=tit
    ind=sort(mm.srcname)
    ind=uniq(mm[ind].srcname)
    nsrc=n_elements(ind)
    srcnameAr=mm[ind].srcname
    if n_elements(lns) eq 0 then lns=2
    if n_elements(lnf) eq 0 then lnf=2
    if n_elements(xpfrq) eq 0 then xpfrq=.25
    if n_elements(fgln) eq 0 then fgln=2
    if n_elements(xpfiq) eq 0 then xpfiq=.8
    if n_elements(xps) eq 0 then xps=(!d.flags and 1) ? -.2:.02
    if n_elements(charth) eq 0 then charth=1.
    if n_elements(thick) eq 0 then thick=1.
    if n_elements(byaz) eq 0 then byaz=0

    if keyword_set(srccol) then begin
        byfrq=0
        bypix=0
    endif else begin
        byfrq=1
        bypix=0
        if keyword_set(bypixU) then begin
            byfrq=0
            bypix=1
        endif
        fxp=xpfrq
        fln=lnf
    endelse

    if n_elements(bwamin) eq 0 then begin
        bwfac=1.
        bwlab='aSec'
    endif else begin
        bwfac=60.
        bwlab='aMin'
    endelse
;
; find out how many frequencies we have
;
    npts=n_elements(mm)
    cs=(n_elements(cs) eq 1)?cs:1.5
    scl=.5
    xp=.04
;---------------------------------------------------------------------------
; gain,Tsys,sefd
    
	lxtit=(byaz)?"azimuth":"za"
	x=(byaz)?mm.az:mm.za
!p.multi=[0,1,4]
    nolab=0
    if n_elements(vg) eq 0 then  begin
         vg=fltarr(2)
         vg[0]=min(mm.fit.gain,max=max)
         vg[1]=max
     endif
    ver,vg[0],vg[1]
    mmplotsrc,x,mm.fit.gain,mm,col=col,$
            xtitle=lxtit,ytitle='Gain [K/Jy]',ln=lns,xp=xps,nolab=nolab,$
            title=titl + ' Gain K/Jy',charsize=cs,font=font,sclln=scl,$
            fln=fln,fxp=fxp,byfrq=byfrq,msrc=msrc,bypix=bypix,$
            thick=thick,charth=charth

    if n_elements(fig) gt 0 then fig=fignum(fig,xp=xpfig,ln=fgln)
    nolab=1
    titl=''
;
; Tsys
;
    if n_elements(vt) eq 0 then  begin
         vt=fltarr(2)
         vt[0]=min(mm.fit.tsys*.5,max=max)
         vt[1]=max
     endif
    ver,vt[0],vt[1]
    mmplotsrc,x,mm.fit.tsys*.5,mm,col=col,$
            xtitle=lxtit,ytitle='Tsys [K]',nolab=nolab,$
            title=titl + ' Tsys',charsize=cs,font=font,sclln=scl,$
            fln=fln,fxp=fxp,byfrq=byfrq,bypix=bypix,$
            thick=thick,charth=charth
;
; sefd
;

    sefd=mm.fit.Tsys*mm.srcflux/(mm.fit.tsrc)
    if n_elements(vs) eq 0 then  begin
         vs=fltarr(2)
         vs[0]=min(sefd,max=max)
         vs[1]=max
     endif
    ver,vs[0],vs[1]
    mmplotsrc,x,sefd,mm,col=col,$
           xtitle=lxtit,ytitle='SEFD [Jy/Tsys]',nolab=nolab,$
           title=titl + ' Sefd',charsize=cs,font=font,sclln=scl,$
           fln=fln,fxp=fxp,byfrq=byfrq,bypix=bypix,$
            thick=thick,charth=charth
;
; beam width
;
    if n_elements(vb) eq 0 then  begin
        b=fltarr(2)
        vb=fltarr(2)
        vb[0]=min(mm.fit.bmWidAvg*60./bwfac,max=max)
        vb[1]=max
    endif
    ver,vb[0],vb[1]
    ylab='AvgBmWidth [' + bwlab + ']'
    mmplotsrc,x,mm.fit.bmWidAvg*60/bwfac,mm,col=col,$
            xtitle=lxtit,ytitle=ylab,nolab=nolab,$
            title=titl + ' AvgBmWidth',charsize=cs,font=font,sclln=scl,$
           fln=fln,fxp=fxp,byfrq=byfrq,bypix=bypix,$
            thick=thick,charth=charth
    return
end
