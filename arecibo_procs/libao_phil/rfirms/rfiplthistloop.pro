;+
;NAME:
;rfiplthistloop - loop plotting histograms for a group of months
;SYNTAX: rfiplthistloop,rcvr,yr,m1,m2,delay=delay,_extra=e
;ARGS:
;   rcvr:string     rcvr to plot . 'lb'
;     yr:int        year to plot, 2001..
;     m1:int        first month to plot (1..12)
;     m2:int        last  month to plot (1..12)
;KEYWORDS:
;   delay:  float   seconds to delay between plots. If < 0 then prompt user
;                   to continue after each plot.
;   _extra:  keywords=values .. pass these to rfiplthist
;
;DESCRIPTION:
;   Call rfiplthist for a group of months of a particular year. You
;can set the horizontal scale to zoom in on a frequency region (you may
;then have to set the vertical scale so that it is scaled correctly for
;all months. The default delay between plots in 1 seconds.
;
;   The data is read from the files in /share/megs/rfi/rms/histdat. If the
;histograms have not been made, they can't be plotted.
;
;EXAMPLES:
;   rfiplthist,'lb',2001,1,9  .. plot jan-sept with 1 sec between plots.
;   hor,1300,1450
;   ver,0,1
;   rfiplthist,'lb',2001,1,9,delay=-1 .. plot jan-sept 1300-1450 Mhz 
;                                     prompt user to continue after each plot.
;-
pro rfiplthistloop,rcvr,yr,m1,m2,_extra=e,delay=delay
;
    mon=['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']
    dir='/share/megs/rfi/rms/histdat/'
    yrl=yr mod 100
    if n_elements(delay) eq 0 then delay=1.
    case rcvr of 
        'lb': begin
                hname='hsav_1100_1800.'
              end   
        else: begin
                message,'set rcvr to: lb'
              end
    endcase
    savxmargin=!x.margin
    savymargin=!y.margin
    !x.margin=[10,9]
    !y.margin=[4,4]
     for i=m1,m2 do begin
        nm=dir+ hname + string(format='(i2.2,i2.2)',yrl,i)
        restore,nm
        if i ne m1 then begin
            if delay lt 0 then begin
                print,'xmit to continue'
                test=' '
                read,test
            endif else begin
                wait,delay
            endelse
        endif
        rfiplthist,histar,histinfo,_extra=e
        lab=string(format='(a3," ",i2.2)',mon[i-1],yrl)
        ln=3
        xp=.05
        note,ln,lab,xp=xp
     endfor
     !x.margin=savxmargin
     !y.margin=savymargin
     return
end
