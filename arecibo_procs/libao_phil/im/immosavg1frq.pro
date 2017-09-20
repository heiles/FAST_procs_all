;+
;NAME:
;immosavg1frq - avg spectra mosaic of multiple days, 1 freq.
;
;SYNTAX: immosavg1frq,year,mon,day1,dohardcopy,freq=freq,nplts=nplts,$
;                     bpc=bpc,win=win,file=filename,_extra=e
;
;ARGS  :
;   INPUTS:
;   year  : long    year to start with (4 digits)
;   mon   : long    month to start with (1 to 12)
;   day1  : long    day of month to start with
;dohardcopy: int    0--> write to screen (default).
;                   1--> write to idl.ps
;                   >1 --> write to idl.ps and then lpr idl.ps
;                          (use printer env variable to set printer).
;                   For multiple pages in 1 file:
;                   -1-> write to idl.ps but don't close on exit
;                   -2-> continue writing to idl.ps (assumes previous
;                        call with -1. user should hardcopy outside this routine
;KEYWORDS:
;   freq  : float   The rfi monitoring band center frequency to use for the
;                   images. The frequecies are: 70 ,165 , 235, 330, 430,$
;                    550, 725, 955,1075,1325,1400,2200,3600,4500,5500,6500,$
;                    7500,8500,9500. The default is the 1400 mhz band.
;   nplts : int     the number of days to put in the mosaic.
;   bpc   :         if set then do a bandpass correction before creating the
;                   mosaic (min value in channel over day).
;   win   : int     window to write to.default is window,1
; file    : string  filename to write to . def=idl.ps
;
;-
; ----------------------------------------------------------------------------
pro immosavg1frq,year,mon,day1,dohardcopy,_extra=e,freq=freq,nplts=nplts,$
            bpc=bpc,win=win,file=filename
;
;   create avgs of 1 freq . 10 per page start at day1..
; _extra 
;  linear=linear,nohisteq=nohisteq,stretch=s
;
;
;    yrange
;
    ylfMinMax=[-85.,0.]
    yhfMinMax=[-70.,0.]

    if (n_params() lt 4) then dohardcopy=0 
    if not keyword_set(freq) then freq=1400
    if not keyword_set(nplts) then nplts=1
    if not keyword_set(bpc) then bpc=0
    if not keyword_set(win) then win=1
    immossetup,0,1,dohardcopy,mos,file=filename
    if nplts gt 1 then  mos.numcols=2 else mos.numcols=1
    mos.numrows= (nplts+1)/2
    pltperpage=mos.numrows*mos.numcols
    if pltperpage eq 2 then begin
        mos.numcols=1
        mos.numrows=2
    endif
    !p.multi=[0,mos.numcols,mos.numrows,0,0]
    if (dohardcopy eq 0)  then begin
         window,win,ysize=mos.winypix
    endif
    case mon of
            1: max=31
            2: max=28
            3: max=31
            4: max=30
            5: max=31
            6: max=30
            7: max=31
            8: max=31
            9: max=30
            10: max=31
            11: max=30
            12: max=31
    end
    offset=0
	if pltperpage le 4 then cs=1.

    for i=0,pltperpage-1 do begin
        curcol= ((i mod pltperpage) mod mos.numcols ) + 1   ;1..numrows
        currow= ((i mod pltperpage) /   mos.numcols ) + 1   ;1..numcols
        month=mon
        if  (i+day1) gt max then begin
            month=mon+1
            offset=-max
        endif
        yymmdd=(year mod 100)*10000L + month*100+i+day1+offset
        iminpday,yymmdd,d,recsfound=recsfound
		if recsfound eq 0 then begin
            print,"no data for:",yymmdd
            continue
        endif
        imgfrq,d,freq,dfrq,nfound=nfound
        if nfound eq 0 then continue
        if (bpc ne 0 ) then imbpc1,dfrq
; note immosavg1 doesn't use dohardcopy
        immosavg1,dfrq,freq,curcol,currow,mos,dohardcopy,$
			ylfMinMax,yhfMinMax,cs=cs
        lab=string(format='("date:",i6)',yymmdd)
            xoff=!x.crange[0]
            yoff=!y.crange[1]+(!y.crange[1]-!y.crange[0])*.018
            xyouts,xoff,yoff,lab,alignment=0.,charsize=mos.charSizeTsys

        
        if  (i mod pltperpage) eq 0 then begin
            xyouts,.5,mos.yOffMainTitle,mos.title,alignment=.5,/normal
        endif
    endfor
    if dohardcopy gt 0  then begin
        hardcopy
        if dohardcopy gt 1 then  spawn,'lpr -Pop1 idl.ps'
        set_plot,'x'
    endif
	if dohardcopy ge 0 then immosreset          
    return
end
