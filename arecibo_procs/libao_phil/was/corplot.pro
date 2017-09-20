; 
;NAME:
;corplot - plot the correlator data.
;SYNTAX : corplot,b,m=pltmsk,vel=vel,rest=rest,off=ploff,pol=pol,over=over,$
;                   nolab=nolab,extitle=extitle,newtitle=newtitle,col=col, $
;                   sym=sym,chn=chn,cmask=cmask,xtitle=xtitle,ytitle=ytitle
;ARGS:
;       b:  {corget} data to plot
;KEYWORDS:
;           m: int bitmask 0-15 to say which boards to plot
;         vel:  if set, then plot versus velocity
;        rest:  if set, then plot versus rest frequency
;         off:  float, if plotting multiple integrations then this is the
;               offset to add between each plot of a single sbc. def 0.
;         pol:  int if set, then plot only one of the pol(1,2 ..3,4 for stokes) 
;        over:  if set then overplot with whatever was previously plotted.
;               This only works if you plot 1 sbc at a time (eg m=1).
;       nolab:  if set then don't plot the power level labels in the middle
;               of the plot for stokes data.
;       extitle: string add to title line
;       newtitle: string replace title line
;       xtitle  : string title for x axis
;       ytitle  : string title for y axis
;       col[4]  : int Change the order of the default colors. The 
;                 order is PolA,polB,stokesU,stokesV colors.
;                 values are:1=white(on black),2-red,3=green,4=blue,5=yellow
;       sym     : int symbol to plot at each point. The symbols are labeled
;                 1 to 9. Positive numbers only plot the symbol (no connecting
;                 lines). Negative numbers (-1 to -9) plots the symbol and a 
;                 connecting line. sym=10 will plot in histogram mode.
;       chn     : if set then plot vs channel
;       cmask    :{cmask} if provided then overplot the mask on each plot
;DESCRIPTION:
;   corplot will plot the correlator data in b. It can be from a single
;record (corget) or it can be an array from corinpscan. You can plot:
; - any combination of sbc using m=pltmsk and pol=pol
; - by topocentric frequency (defaul), rest frequency, or by velocity
; - make a strip plot if b is an array by using off=ploff.
;   If the data passed in has been accumulated by coraccum() then the
;average will be computed before plotting.
;EXAMPLES:
;   corget,lun,b
;   corplot,b           plot all sbc
;   corplot,b,m=1       plot first sbc only
;   corplot,b,m=2       plot 2nd sbc
;   corplot,b,m=4,pol=2 plot 3rd sbc,polB only
;   corplot,b,m=8,pol=1 plot 4th sbc, pola only
;   corplot,b,m=5,/vel  plot 1st and 3rd sbc by velocity
;   istat=corinpscan(lun,b) .. input entire scan
;   corplot,b,m=1,pol=1 plot sbc 1, pola, overplotting
;   corplot,b,m=2,off=.01  plot sbc 2, with .01 between records
;.. overplot sbc 1 from b[0] (red) and b[1] yellow
;   corplot,b[0],m=1
;   corplot,b[1],m=1,/over,col=[5,5]
;NOTE: 
;   use hor,ver to set the plotting scale.
;   oveplotting only works if you display 1 sbc at a time.
;SEE ALSO:
;   corget,coraccum. hor,ver in the generic idl routines.
; 
;modhistory:
;31jun00 - update for corget change
; 2jul00 - added option to overplot and array of 
; 3jul00 - changed y scaling.. if !y.range = 0,0 then scale each 
;          board to max,min
; 3may02 - check accum variable to see if the data needs to be scaled.
;21may02 - title written with not rather than  title=titleo be scaled.
;21sep02 - added sym keyword to plot symbols or hist mode
;23sep02 - when auto scaling.. check for finite numbers each board.
;23oct02 - added cmask keyword
;13jan03 - added check for decomposed color. if true, then don't use our lut..
;25feb03 - b.accum now use each value separately
;05jun03 - plot first pol index of cmask.. now we can allow two..
pro corplot,b,m=pltmsk,vel=vel,rest=rest,off=pltoff,pol=pol,over=over,$
            nolab=nolab,extitle=extitle,newtitle=newtitle,col=col,sym=sym,$
            chn=chn,cmask=cmask,xtitle=xtitle,ytitle=ytitle
;
; plot correlator data
;
; setup the color table
; 1 - white
; 2 - red       sbc1 or polA if 1 sbc
; 3 - green     sbc2 or polB if 1 sbc
; 4 - bluen     sbc3
; 5 - yellow    sbc4
;
    forward_function isecmidhms3,corfrq
    on_error,1
    xptitle=.02
    lntitle=.8
;   wasdat=(tag_names(b[0].b1))[1] eq 'HF'
    wasdat=0
    if ( n_elements(vel)  eq 0) then vel = 0
    if ( n_elements(rest) eq 0) then rest=0
    if not keyword_set(nolab) then nolab=0
    if n_elements(extitle) eq 0  then extitle=''
    if n_elements(sym) eq 0 then sym=0
    if n_elements(xtitle) eq 0 then xtitle=''
    if n_elements(ytitle) eq 0 then ytitle=''
    usemask=0
    maskfract=.73
    maskcol=1
    masklns=2
    if keyword_set(cmask) then usemask=1
    bychn=0
    if keyword_set(chn) then bychn=1
    ps= !d.flags and 1  
    if ps eq 0 then begin
       tvlct,[0,1,1,0,0,1]*255,[0,1,0,1,0,1]*255,[0,1,0,0,1,0]*255
    endif
    k=[2,3,4,5]
    n=n_elements(col)
    if n gt 0 then begin
        for i=0,4 - 1 do begin 
            if i ge n then begin
                k[i]=col[n-1] 
            endif else begin
                k[i]=col[i] 
            endelse
        endfor
    endif
    white=1
;
;   see if we have decomposed color
;
    if ps eq 0 then begin
        device,get_decomp=getd
        if getd eq 1 then begin
            red  =255L
            green=255L*256L
            blue=255L*(256L)^2
            white=red+green+blue
            yellow=red+green
            k=[red,green,blue,yellow]
            maskcol=white
        endif
    endif
;
;   see how many plots they want
;
    if (n_elements(pltmsk) eq 0) then plttmp=15 else plttmp=pltmsk
    if (n_elements(pltoff) eq 0) then pltoff=0.
    if (n_elements(pol) eq 0) then pol=0
    if (not keyword_set(over) ) then over=0
    if (plttmp eq 0 ) then plttmp=15
    nbrds=n_tags(b[0])
    accumscl=fltarr(nbrds) + 1.
    for i=0,nbrds-1 do begin
        if b[0].(i).accum gt 0. then  accumscl[i]=1./b[0].(i).accum
    endfor
    numplts=0
    pltit=intarr(4)                 ; do we plot this boards output?
;    for i=0,b[0].(0).h.std.grpTotRecs-1 do begin
     for i=0,n_tags(b[0])-1 do begin
        pltit(i)= (plttmp and 1)
        numplts=numplts+pltit(i)
        plttmp=ishft(plttmp,-1)
    end
    if (numplts gt 2) then across=2 else across=1
    if (numplts gt 1) then down=2 else down=1
    if not over then begin
        !p.multi=[0,across,down]
    endif else begin
        plotsleft=across*down
        !p.multi=[plotsleft,across,down]
    endelse
;
; create the title for plot 1
;
    isecmidhms3,b[0].(0).h.std.time,hour,min,sec
    src=string(b[0].(0).h.proc.srcname)
    proc=string(b[0].(0).h.proc.procname)
    title=string(format='(A," ",I9," rec:",I4," tm:",i2,":",i2,":",i2," ",A)', $
      src,b[0].(0).h.std.scanNumber,b[0].(0).h.std.grpNum,hour,min,sec,proc)
    title=title+extitle
    if n_elements(newtitle) gt 0 then title=newtitle
    autoscale=0
    if (!y.range[0] eq 0.) and (!y.range[1] eq 0.) then autoscale=1
;
;   loop plotting the data
;
    labcnt=0
;;    for i=0 , b[0].(0).h.std.grpTotRecs-1 do begin 
      for i=0 ,n_tags(b[0]) - 1 do begin 
        if pltit(i) then begin
           pltoffcum=0.
           pltx=0                       ; no x scale yet
           for ii=0,(size(b))[1]-1 do begin ; if array loop over whole array
             for j=0,b[ii].(i).h.cor.numsbcout-1 do begin 
                if (pol eq 0) or (j eq (pol-1)) then begin
                    if  pltx eq 0 then begin
;
;          figure out y scaling 
;
                        if bychn then begin
                            x=findgen(b[ii].(i).h.cor.lagsbcout)
                        endif else begin
                           x=(wasdat) $ 
                            ? corfrq(b[ii].(i).hf,retvel=vel,retrest=rest)$
                            : corfrq(b[ii].(i).h,retvel=vel,retrest=rest)
                        endelse
                        if  over then begin
                            !p.multi=[plotsleft,across,down]
                        endif 
                        if autoscale then begin
                            if (pol eq 0) then begin
                               ymin=min(b.(i).d*accumscl[i],max=ymax)
                            endif else begin
                               ymin=min(b.(i).d[*,j]*accumscl[i],max=ymax)
                            endelse
;                            if not finite, skip board
                            ind=where(finite([ymin,ymax]) eq 0,count)
                            if count gt 0 then begin
                                print,'skip board:',i+1,' data not finite'
                                goto,donebrd
                            endif
                        endif else begin
                            ymin=!y.range[0]
                            ymax=!y.range[1]
                        endelse
;                       print,ymin,ymax,' autoscl:',autoscale,pol
;                       print,x[0],xmax 
                        plot, x,[ymin,ymax],color=white,/xstyle,$
                           /ystyle,/nodata,psym=sym,ytitle=ytitle,xtitle=xtitle
                        if title ne "" then begin
                            note,lntitle,title,xp=xptitle,charsize=1.25
                        endif
                        if usemask then begin
                            oplot,x,cmask.(i)[*,0]*maskfract*(ymax-ymin)+ymin,$
                                color=maskcol,linestyle=masklns
                        endif
                        if (b[ii].(i).h.cor.lagconfig eq 10) then begin
                           lab=string(format=$
'("pwrRatio:",f4.1," ",f4.1)',b[ii].(i).h.cor.lag0pwrratio[0]*accumscl[i],$
                             b[ii].(i).h.cor.lag0pwrratio[1]*accumscl[i]);

                            ln=8-down
                            cs=1.5
                            if (labcnt lt across) then begin
                                if not nolab then $
                                note,ln,lab,charsize=cs,color=white
                            endif else begin
                                if not nolab then $
                                note,ln+15,lab,charsize=cs,color=white
                            endelse
                            labcnt=labcnt+1
                        endif
                        title=""
                        pltx=1
                    endif
                    if (b[ii].(i).h.cor.numsbcout eq 1) then begin
                        cind=(b[ii].(i).p[0] - 1)
                    endif else begin
                        cind=j 
                    endelse
                    if pltoffcum ne 0. then begin
                       oplot,x,b[ii].(i).d[*,j]*accumscl[i]+pltoffcum,$
                            color=k[cind],psym=sym
                    endif else begin
                     oplot,x,b[ii].(i).d[*,j]*accumscl[i],color=k[cind],psym=sym
                    endelse
                endif
             endfor  ; end loop over sbc of this board, this rec
             if (pltoff ne 0.) then pltoffcum=pltoffcum+pltoff
           endfor   ; end loop over array elements
        if over then plotsleft=plotsleft-1
    endif       ; endif plot this board
donebrd:
    endfor      ; end loop over brds
    return
end
