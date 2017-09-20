;+
;NAME:
;corplot - plot the correlator data.
;SYNTAX : corplot,b,m=pltmsk,vel=vel,off=ploff,pol=pol,over=over
;ARGS:
;       b:  {corget} data to plot
;KEYWORDS:
;           m: int bitmask 0-15 to say which boards to plot
;         vel:  if set, then plot versus velocity
;         off:  float, if plotting multiple integrations then this is the
;               offset to add between each plot of a single sbc. def 0.
;         pol:  int if set, then plot only one of the pol(1,2 ..3,4 for stokes) 
;        over:  if keyword is set then overplot with whatever was
;               previously plotted
;DESCRIPTION:
;   corplot will plot the correlator data in b. It can be from a single
;record (corget) or it can be an array from corinpscan. You can plot:
; - any combination of sbc using m=pltmsk and pol=pol
; - by frequency or by velocity
; - make a strip plot if b is an array by using off=ploff.
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
;NOTE: 
;   use hor,ver to set the scale.
;-
;modhistory:
;31jun00 - update for corget change
; 2jul00 - added option to overplot and array of 
; 3jul00 - changed y scaling.. if !y.range = 0,0 then scale each 
;          board to max,min
;
pro corplot,b,m=pltmsk,vel=vel,off=pltoff,pol=pol,over=over 
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
;;    on_error,1
    if ( not keyword_set(vel) eq 0) then vel = 0
    tvlct,[0,1,1,0,0,1]*255,[0,1,0,1,0,1]*255,[0,1,0,0,1,0]*255
    k=[2,3,4,5]
;
;   see how many plots they want
;
    if (n_elements(pltmsk) eq 0) then plttmp=15 else plttmp=pltmsk
    if (n_elements(pltoff) eq 0) then pltoff=0.
    if (n_elements(pol) eq 0) then pol=0
    if (not keyword_set(over) ) then over=0
    if (plttmp eq 0 ) then plttmp=15
    numplts=0
    pltit=intarr(4)                 ; do we plot this boards output?
    for i=0,b[0].(0).h.std.grpTotRecs-1 do begin
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
    title=string(format=$
        '("src:",A," scan:",I9," rec:",I5," tm:",i2,":",i2,":",i2," ",A)', $
        src,b[0].(0).h.std.scanNumber,b[0].(0).h.std.grpNum,hour,min,sec,proc) 
    autoscale=0
    if (!y.range[0] eq 0.) and (!y.range[1] eq 0.) then autoscale=1
;
;   loop plotting the data
;
    for i=0 , b[0].(0).h.std.grpTotRecs-1 do begin 
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
                        x=corfrq(b[ii].(i).h,retvel=vel)
                        if  over then begin
                            !p.multi=[plotsleft,across,down]
;;                        endif else begin
                          endif 
                          if autoscale then begin
                            if (pol eq 0) then begin
                               ymin=min(b.(i).d,max=ymax)
                            endif else begin
                               ymin=min(b.(i).d[*,j],max=ymax)
                            endelse
                          endif else begin
                            ymin=!y.range[0]
                            ymax=!y.range[1]
                          endelse
;                         print,ymin,ymax,' autoscl:',autoscale,pol
;                         print,x[0],xmax 
						  print,'first plot with white, nodata'
                          plot, x,[ymin,ymax],color=1,/xstyle,$
                            /ystyle,/nodata, title=title
;;                        endelse
                        title=""
                        pltx=1
                    endif
					if (b[ii].(i).h.cor.numsbcout eq 1) then begin
						cind=(b[ii].(i).p[0] - 1)
					endif else begin
						cind=j 
					endelse
                    if pltoffcum ne 0. then begin
                        oplot,x,b[ii].(i).d[*,j]+pltoffcum,color=k[cind]
                    endif else begin
                        oplot,x,b[ii].(i).d[*,j],color=k[cind]
                    endelse
                endif
             endfor
             if (pltoff ne 0.) then pltoffcum=pltoffcum+pltoff
           endfor
        if over then plotsleft=plotsleft-1
    endif
    endfor
    return
end
