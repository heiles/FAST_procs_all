;+
;NAME:
;mmplotcsme - plot coma,SideLobeHght, and beam efficiencies.
;SYNTAX: mmplotcsme,mm,col=col,vc=vc,vs=vs,vm=vm,ve=ve,tit=tit,lnf,$
;       lnf=lnf,xpfrq=xpfrq,fig=fig,fgln=fgln,xpfig=xpfig,lns=lns,xps=xps,$
;       srccol=srccol,msrc=msrc,bypix=bypix,cs=cs,font=font
;ARGS: 
;   mm[n]: {mueller} data structure to plot
;KEYWORDS:
;   col[m]: int color array to use
;   vc[2] : float vertical range for coma [min,max] 
;   vs[2] : float vertical range for sideLobeHght [min,max] 
;   vm[2] : float vertical range for main beam efficiency [min,max] 
;   ve[2] : float vertical range for main beam +1st sidelobe efficiency
;   lnf   : float line number to print frquencies
;   xpfrq : float 0.,1. horizontal position for frequency
;   fig   : int   figure number
;   fgln  : float line number for figure number
;   xpfig : float 0,1. horizontal position for figure number
;   lns   : float line number to start source labels
;   xps   : float 0,1. horizontal position for source labels
;   srccol: if set then use colors for sources rather than freq
;   msrc  : int   max number of source names to print on left side of page
;                 before moving to the right. (def=30)
;   bypix :       if set then colors are for pixels not frequency
;   cs    : float  chars size for plots. def=1.5
;  font   : int    font to use.

;
;DESCRIPTION:
;   Plot the coma parameter, 1st sidelobe height (in db), the main beam
;efficiency , and the main beam + 1st sidelobe beam efficiency for all
;of the sources in the mm array. Plot each source with a separate symbol.
;Plot each frequency as a separate color. It is probably a good idea to
;plot 1 receivers worth of data at a time. 
;   You can change the colors used via the col keyword (use number 1 through
;10 for colors..1=black,2-red,3-green,4-blue,5..). The vX array allows
;you to set the vertical scale for each plot. The default is to autoscale
;to the max, min of the data. The lnX keywords let you position the 
;source names on the plot.
;   The mm array is normally generated from the mm0proc routine.
;
;EXAMPLES:
;   plot the xband info for jan02.
;   restore,'/share/megs/phil/x101/x102/runs/c020101_020131.sav'
;   ind=where(mm.rcvname eq 'xb')   ; just get the  xband data
;   mm=mm[ind]
;   fig=1
;   tit='02jan02 Xband'
;   mmplotcsme,mm,vc=[0,.3],vs=[-15,0],vm=[0,.5],ve=[0,.5],fig=fig,tit=tit
;SEE ALSO:
;   mmplotgtsb, mm0proc.
;-
; modhistory
; 09apr02 - added xps. only plot source names once.
; 15apr02 - fix for more than 4 freq.s
; 22nov02 - mmplotsrc now does plot by frq
;
pro mmplotcsme,mm,col=col,vb=vb,vc=vc,vs=vs,vm=vm,ve=ve,tit=tit,$
            lns=lns,fig=fig,xpfig=xpfig,fgln=fgln,xps=xps,lnf=lnf,xpfrq=xpfrq,$
            srccol=srccol,msrc=msrc,bypix=bypix,cs=cs,font=font
;
    on_error,1
    maxfreq=10
    nc=n_elements(col)
    if nc eq 0 then begin
        col=lindgen(maxfreq)+1
        nc=n_elements(col)
    endif
    titl=''
    if n_elements(tit) ne 0 then titl=tit
    if n_elements(lnf) eq 0 then lnf=2
    if n_elements(lns) eq 0 then lns=2
    if n_elements(xpfrq) eq 0 then xpfrq=.25
    if n_elements(fgln) eq 0 then fgln=2
    if n_elements(xps) eq 0 then xps=(!d.flags and 1) ? -.2:.02
    if keyword_set(srccol) then begin
        byfrq=0
        bypix=0
    endif else begin
        byfrq=1
        if keyword_set(bypix) then begin
            byfrq=0
            bypix=1
        endif
        fxp=xpfrq
        fln=lnf
    endelse

;
; find out how many freq we have
;
    npts=n_elements(mm)
	if n_elements(cs) eq 0 then cs=1.5
    scl=.5
;---------------------------------------------------------------------------
;  beamwidth
!p.multi=[0,1,4]
    nolab=0
;
; coma
;
    if n_elements(vc) eq 0 then  begin
        vc=fltarr(2)
        vc[0]=min(mm.fit.Coma,max=max)  
        vc[1]=max
    endif
    ver,vc[0],vc[1]
    mmplotsrc,mm.za,mm.fit.coma,mm,col=colUse,ln=lns,$
            xtitle='za',ytitle='coma Parameter',xp=xps,nolab=nolab,$
            title=titl + ' Coma',charsize=cs,sclln=scl,$
            fln=fln,fxp=fxp,byfrq=byfrq,msrc=msrc,bypix=bypix,font=font
    nolab=1
    titl=''
    if n_elements(fig) ne 0 then fig=fignum(fig,xp=xpfig,ln=fgln)

;
; sidelob hgt
;
    y=mm.fit.slhgt
    eps=1e-5
    ind=where(y lt eps,count)
    if count gt 0 then y[ind]=eps
    sdl=alog10(y)*10.
    if n_elements(vs) eq 0 then  begin
        vs=fltarr(2)
        vs[0]=min(sdl,max=max)  
        vs[1]=max
    endif
    ver,vs[0],vs[1]
    mmplotsrc,mm.za,sdl,mm,col=coluse,$
        xtitle='za',ytitle='sideLobHght [db]',nolab=nolab,$
        title=titl + ' SideLobe Height',charsize=cs,sclln=scl,xp=xps,$
        fln=fln,fxp=fxp,byfrq=byfrq,bypix=bypix,font=font

;
; eta mainbm
;
    eta=mm.fit.etamb
    if n_elements(vm) eq 0 then  begin
        vm=fltarr(2)
        vm[0]=min(eta,max=max)
        vm[1]=max
    endif
    ver,vm[0],vm[1]
    mmplotsrc,mm.za,eta,mm,col=coluse,xp=xps,$
          xtitle='za',ytitle='main bm efficiency',nolab=nolab,$
          title=titl + ' Eta MainBm',charsize=cs,sclln=scl,$
          fln=fln,fxp=fxp,byfrq=byfrq,bypix=bypix,font=font
;
; eta mainbm + 1st sidelobe
;
    eta=(mm.fit.etamb+mm.fit.etasl)
    if n_elements(ve) eq 0 then  begin
        ve=fltarr(2)
        ve[0]=min(eta,max=max)  
        ve[1]=max
    endif
    ver,ve[0],ve[1]
    mmplotsrc,mm.za,eta,mm,col=coluse,$
        xtitle='za',ytitle='bm efficiency',xp=xps,nolab=nolab,$
        title=titl + ' Eta (MainBm + 1st SideLobe)',charsize=cs,sclln=scl,$
        fln=fln,fxp=fxp,byfrq=byfrq,bypix=bypix,font=font
    return
end
