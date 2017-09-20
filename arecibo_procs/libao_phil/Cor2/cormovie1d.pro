;+
;NAME:
;cormovie1d - make a movie of 1d spectra
;SYNTAX:  cormovie1d,b,loop=loop,win=win,xdim=xdim,ydim=ydim,$
;                    delay=delay,yauto=yauto,$
;                    corplotargs..
;ARGS:
;   b[]: {corget} array of corget data to plot
;
;KEYWORDS:
;   loop:      If set then continue looping through the data array.
;              you can stop by hitting a key and then q for quit.
;              By default the routine exits after making 1 pass through
;              the array.
;   win : int  The window to use for the plotting. By default it uses
;              the first free window above 0.   
;   xdim: int  if supplied, then the x dimension for the plot window
;              in pixel units. the default is 640
;   ydim: int  if supplied, then the y dimension for the plot window
;              in pixel units. the default if 510
;  delay: float The number of seconds (or fractions of seconds) to wait
;               between each plot. The default is 0.
;  yauto:      If set then automatically set the vertical scale by 
;              finding the min,max of all the data.
;   corplotargs: You can pass in any keywords that are accepted by 
;                corplot (eg m=2,/vel, etc..)
;
;DESCRIPTION:
;   Make a movie of an array of corget spectra. It will make a call
;to corplot for each spectra in the array. Pixwins are used to 
;eliminate flashing between plots. By default the routine exits after
;make 1 pass through the array. The /loop keyword will cause
;the routine to continue looping through the array until the user
;asks to quit.
;
;   While plotting, the user can resize the window with the mouse. The
;routine will change to the  new window size.
;
;   If the user hits any key while plotting, the routine will pause
; and print :
;
;idl> return to continue,s step,c exit step mode, q to quit
;
; The user can enter:
;   return  - the routine will continue whatever it was doing.
;        s  - the routine will go to single step mode. The user will
;             have to hit return after each plot.
;        c  - go back to continuous plotting. This exits step mode. 
;        q  - quit.  The routine will exit.
;
;   When using the routine, you should set the vertical scale before calling
;the routine or use the /yauto keyword. When the vertical scale is not
;set then each spectra displayed will autoscale to the min,max.
;
;   Any corplot keywords will be passed through to the corplot call.
;
;EXAMPLES:
;
;   1. input a scan 
; IDL> istat=corinpscan(lun,b)
;
;   2. make a movie of all sbc in b, use auto scaling.
; IDL> cormovie1d,b,/yauto
;
;   3. set the vertical scale and loop forever. Only plot sbc 1.
; IDL> ver,0,2
;      cormovie1d,b,/loop,m=1
;   
;SEE ALSO: corplot
;-
pro cormovie1d,b,loop=loop,_extra=_e,win=win,xdim=xdim,ydim=ydim ,$
                delay=delay,yauto=yauto
;
;
;
    on_error,1
    if (n_elements(delay) eq 0) then delay=0
;
    nrecs=n_elements(b)
    if n_elements(win) eq 0 then win=1
    if not keyword_set(xdim) then xdim=640
    if not keyword_set(ydim) then ydim=510
    if keyword_set(yauto) then begin
        nbrds=n_tags(b[0])
        ymin=1e6
        ymax=-1e6
        for i=0,nbrds-1 do begin
            ymin0=min(b.(i).d,max=ymax0)
            ymin=(ymin0 < ymin) 
            ymax=(ymax0 > ymax) 
        endfor
        yavg=(ymin+ymax)/2.
        slop=.01
        ymax =ymax + (ymax-yavg)*slop
        ymin=ymin - (yavg-ymin)*slop
        ver,ymin,ymax
    endif
;
;   get a free window for pixwin
;
    device,window_state=ws
    ind=where((ws eq 0 ))
    i=0
    if ind[i] eq 0 then i=i+1
    if ind[i] eq win then i=i+1
    pixwin=-ind[i]
    window,win,xsize=xdim,ysize=ydim
;
    done=0
    step=0
    while not done do begin
        for i=0,nrecs-1 do begin
;
;       see if they changed the size of the window
;
            if (!d.x_size ne xdim) or (!d.y_size ne ydim) or $
                (pixwin lt 0) then begin
                if pixwin lt 0 then pixwin=pixwin*(-1L)
                xdim=!d.x_size
                ydim=!d.y_size
                window,pixwin,xsize=xdim,ysize=ydim,/pixmap
            endif
            wset,pixwin
            corplot,b[i],_extra=_e
            wset,win
            device,copy=[0,0,xdim,ydim,0,0,pixwin]
            if (delay gt 0 ) then wait,delay
            key=checkkey()
            if (key ne '') or (step) then begin
               print,'return to continue,s step,c exit step mode, q to quit'
               key=checkkey(/wait)
               case key of
                's': step=1
                'c': step=0
                'q': goto,done
                else:
               endcase
            endif
        endfor
        done=not keyword_set(loop)
    endwhile
done:
    if pixwin gt 0 then wdelete,pixwin
    return
end
