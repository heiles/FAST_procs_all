;+
;NAME:
;immosimg1frq - image mosaic of multiple days, 1 freq.
;
;SYNTAX: immosimg1frq,year,mon,day1,dohardcopy,freq=freq,nplts=nplts,$
;                     bpc=bpc,win=win,_extra=e
;
;ARGS  :
;   INPUTS:
;   year  : long    year to start with (4 digits)
;   mon   : long    month to start with (1 to 12)
;   day1  : long    day of month to start with
;dohardcopy: int    if hardcopy is not equal to 0, write to the file 
;                   idl.ps and then spool to printer via lpr. The
;                   default is to write to the screen.
;KEYWORDS:
;   freq  : float   The rfi monitoring band center frequency to use for the
;                   images. The frequecies are: 70 ,165 , 235, 330, 430,$
;                    550, 725, 955,1075,1325,1400,2200,3600,4500,5500,6500,$
;                    7500,8500,9500. The default is the 1400 mhz band.
;   nplts : int     the number of days to put in the mosaic.
;   bpc   :         if set then do a bandpass correction before creating the
;                   mosaic (min value in channel over day).
;   win   : int     window to write to.default is window,1
;
;  Extra keywords that are passed to immosimgscl:
;stretch[2]: float  scale stretch[0],stretch[1] to 0 to 255 before plotting.
;nohisteq  :        if set then don't do histogram equalization on each
;                   freq img. 
;linear    :        if set then convert db to linear before scaling and 
;                   histogram equalizing the image.
;
;DESCRIPTION:
;   immosimg1frq will make a mosaic of spectral density images for a single
;frequency band on consecutive days starting at the day specified by 
;year,mon,day. The keyword freq= selects the freq band to use. There will
;be nplts days in the mosaic. All of the images will be placed on a single 
;page. Each image in the mosaic will be spectral density with axes
;freq vs hour. 
;
;The image is made from db units (the linear keyword can change this). By
;default each image is histogram normalized to cover the dynamic range
;of the data.
;
;EXAMPLE:
; .. do the following 3 lines when starting idl.
;
;idl
;@phil
;@iminit
;
;make a mosaic of 6 days starting 01aug03 for the 1325 band.
;
;   immosimg1frq,2003,8,1,0,freq=1325,nplts=6
;
;The routine uses the current value of the lookup table for display. 
;You can adjust the lookup table with xloadct after running the routine.
;For hardcopy you should run the routine to the screen, adjust the lookup
;table, and then rerun the routine with hardcopy set to 1.
;
;hardcopy=0
;immosimg1frq,2003,8,1,hardcopy,freq=1325,nplts=6
;xloadct .. then play with sliders
;hardcopy=1
;immosimg1frq,2003,8,1,hardcopy,freq=1325,nplts=6
;
;SEE ALSO: IM1IMG - mosaic 1 day 1 freq.
;-
pro immosimg1frq,year,mon,day1,dohardcopy,_extra=e,freq=freq,nplts=nplts,$
            bpc=bpc,win=win
;
;   create image of 1 freq . 10 per page start at day1..
;   need to edit frq,month..
; _extra 
;  linear=linear,nohisteq=nohisteq,stretch=s
;
    if (n_params() lt 4) then dohardcopy=0 
    if not keyword_set(freq) then freq=1400
    if not keyword_set(nplts) then nplts=1
    if not keyword_set(bpc) then bpc=0
    if not keyword_set(win) then win=1
    immossetup,0,2,dohardcopy,mos,_extra=e
    if nplts gt 1 then  mos.numcols=2 else mos.numcols=1
    mos.numrows= (nplts+1)/2
    pltperpage=mos.numrows*mos.numcols
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
    for i=0,pltperpage-1 do begin
        curcol= ((i mod pltperpage) mod mos.numcols ) + 1   ;1..numrows
        currow= ((i mod pltperpage) /   mos.numcols ) + 1   ;1..numcols
        month=mon
        if  (i+day1) gt max then begin
            month=mon+1
            offset=-max
        endif
        yymmdd=(year mod 100)*10000L + month*100+i+day1+offset
        iminpday,yymmdd,d
        imgfrq,d,freq,dfrq
        if (bpc ne 0 ) then imbpc1,dfrq
        immosimg1,dfrq,curcol,currow,mos,dohardcopy,_extra=e
        lab=string(format='("date:",i6)',yymmdd)
            xoff=!x.crange[0]
            yoff=!y.crange[1]+(!y.crange[1]-!y.crange[0])*.018
            xyouts,xoff,yoff,lab,alignment=0.,charsize=mos.charSizeTsys

        
        if  (i mod pltperpage) eq 0 then begin
            xyouts,.5,mos.yOffMainTitle,mos.title,alignment=.5,/normal
        endif
    endfor
    if dohardcopy ne 0  then begin
        hardcopy
        if dohardcopy gt 1 then  spawn,'lpr -Pop1 idl.ps'
        set_plot,'x'
    endif
;     immosreset                ; comment out since resets color table
    return
end

    return
end
