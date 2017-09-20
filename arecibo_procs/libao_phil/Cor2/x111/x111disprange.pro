;+
;NAME:
;x111disprange - display a range of time vs frq maps.
;
;SYNTAX: img=x111disprange(freqLow,freqHi,day=day)
;
;ARGS:
;   freqLow:    float. first freq in Mhz.
;   freqHi :    float. last freq in Mhz.
;
;KEYWORDS:
;   day    :    int.  data to disp. default:0
;                    0 - 30nov00
;                    1 - 02dec00
;                    2 - 03dec00
;                    3 - 16nov01 sbwide only
;
;DESCRIPTION:
;
;   The x111 rfi monitoring cycles through the frequency range of all receivers
;(327 through cband) looking at the rfi. At each frequency setting,
;60 1 second integrations are recorded. The correlator is configured as 
;4 sbc of 25Mhz bw with 1024 channels (receivers < 25 Mhz bw use narrower 
;settings). With this setup 100 Mhz can be covered each minute. It takes
;51 steps to cover all of the receivers. 
;For a particular frequency step there will be 60 1 second records followed
;by another 60 1 second records about 1 hour later.
;
;   The center frequencies of each band are:
;
;  RCVR    FreqRange steps bw/img   Notes
;
;   327     251-320    1     25.    polB has a narrow filter    
;   430       418      1     25.    no data yet (rcvr down).
;   610       612      1     12.5
;   lbw    1111-1824   8     25
;   lbn                             not monitored..
;   sbw    1761-3118   15    25.    no data yet (rcvr down).
;   sbn    2334-2403   1     25.    
;   cband  3961-6146   24    25.    
;
;Data was acquired on 30nov00, 02dec00, 03dec00 running about 12 hours per 
;night. This routine will display a set of 25 Mhz images (one at a time). The
;user specifies the date to use via the day keyword (default is 30nov00).
;The frequency low/high parameters specify the frequency range to display.
;Any image that falls within this range will be displayed.
;
;Processing of images:
;
;  An image consists of a 25 Mhz frequency chunk by 1 second integrations. 
;Each group of 60 records are taken consecutively. A group is normalized 
;to the median bandpass of the group. Adjacent groups are spaced by about
;1 hour. The division by the bandpass makes the image units Tsys.
;Histogram equalization will arrange the data values so that there are an
;equal number of pixels in each of the 256 greyscale values. This gives 
;maximum contrast but the lookup ramp is not linear in power (the profile
;and readback values are of the original linear data in units of Tsys). h-
;(described below) turns off histogram equalization giving a linear ramp
;max to min). PolA was used for the current set of images.
;
;EXAMPLE:
;1. Before you run this the first time in an idl session:
;    - idl
;    - if you don't already have phils idl path in your startup file you
;      need to enter @phil 
;    - @x111init           .. load in the procedures to use.
;    - window,3,colors=256 .. this guarantees 256 colors for the image.
;
;2. img=x111disprange(1000,2000) .. disp 1000 through 2000 Mhz day 0.
;   This displays the first image and the line:
;
;   q-quit,h-:histeq,n:nextimg,b:backimg,r-:rdpix,p-:profiles:
;   
;   These are the choices you have. You may have to put the cursor in this
;   window to get a reply:
;   q    : quit the display 
;   h(-) : histogram equalize the display. h- will turn it off. The 
;          default is histogram equalization.
;  return: or
;   n    : move to next image
;   b    : move back to previous image.
;   r(-) : turn on/off pixel readback. When on, the image pixel coordinates
;          0-(xdim-1),0-(ydim-1), and pixel value are displayed. Clicking
;          the left button outputs a fresh line (to record a value). Clicking
;          the right button (in the image window) stops the display. When
;          this is on, no other commands can be entered.
;   p-   : Turn profiles on or off. A 2nd window is displayed with a 
;          horizontal or vertical cut through the image. The left mouse
;          button toggles between horizontal and vertical. The right mouse
;          button stops the profiling. No other commands can be entered while
;          profiling is on.
;3. Stopping.
;   The loop will stop when you increment beyond the end of the list with
;   n or you enter q.  The current image will be returned as a float
;   array in the variable img.You can use the indices from (r) to
;   process a particular strip. Suppose r returned x=215,y=20. 
;   You could then look at the vertical line x=215 or the horizontal line
;   y=20 with:
;    dv=reform(img[215,*]) 
;    plot,dv
;    dh=img[*,20]
;    plot,dh
;    AFter quiting xloadct allows you to manipulate the color of the 
;    last image displayed.
;
;GOTCHAS:
;   The following problems will someday be fixed by me.
;   1. If you turn on p, or r, you need to turn them off before you can
;      enter any more commands.
;   2. You need to move the cursor to the text window for the ascii commands
;      to be accepted. You must be in the image window for p,r to update.
;   3. The p display should allow you to scale the plot.
;   4. xloadct cannot modify the lookup table while you run this
;      routine (although after quitting, the last image can be played with).
;-
function x111disprange,freqlow,freqhigh,day=day
;
;    dayar=['/share/megs/phil/x101/x111/img/nov30',$
;           '/share/megs/phil/x101/x111/img/dec02',$
;           '/share/megs/phil/x101/x111/img/dec03']
    dayar=['/proj/x111cor/img/nov30',$
           '/proj/x111cor/img/dec02',$
           '/proj/x111cor/img/dec03',$
           '/proj/x111cor/img/011116']
    if not keyword_set(day) then day=0
    dayind=(( day > 0)< (n_elements(dayar)-1))
    dir =dayar[dayind]
    on_ioerror,done
    hdrlist=x111gethdrs(dir)
    if not keyword_set(hdrlist) then goto,nofiles
    ind=where(((hdrlist.cfr - hdrlist.bw/2.) ge freqlow) and $ 
              ((hdrlist.cfr + hdrlist.bw/2.) le freqhigh),count)
    if count le 0 then goto,nofiles
    hdrlist=hdrlist[ind]
    numimg=(size(hdrlist))[1]
    prompt=$
'q-quit,h-:histeq,n/cr:nextimg,b:backimg,r-:rdpix,p-:profiles:?'
    ans=''
    prof=0
    rdpix =0
    histeq=1
    i=0
    while i lt numimg do begin
        img=x111getimg(hdrlist[i],prof=prof,histeq=histeq,$
                rdpix=rdpix,/disp,dir=dir)
        donewithimg=0
        repeat begin
            badinp=0
            read,ans,prompt=prompt
            updatedisp=0
            if ans eq '' then ans='n'
            case ans of
                'q':  goto ,done
                'n':  begin
                      donewithimg=1
                      rdpix=0
                      prof=0
                      i=i+1
                      end
                'b':  begin
                        if i gt 0 then donewithimg=1
                        i=((i-1) > 0)
                      end
                'h-': begin
                      if (histeq ne 0) then begin
                        histeq=0
                        updatedisp=1
                      endif
                      end
                'h':  begin
                      if (histeq ne 1) then begin
                        histeq=1
                        updatedisp=1
                      endif
                      end
                'p':  begin
                        prof=1
                        rdpix=0
                        updatedisp=1
                      end
                'p-': prof=0
                'r':  begin 
                        rdpix=1
                        prof=0
                        updatedisp=1
                      end
                'r-': rdpix=0
                else:badinp=1 
            endcase
            if badinp then begin
                print,'badinp please try again'
            endif else begin
                if (not donewithimg) and updatedisp then begin
                    retimg=x111dispimg(img,hdrlist[i],histeq=histeq,$
                        prof=prof,rdpix=rdpix)
                endif
            endelse
        endrep until  donewithimg
    endwhile
done:
    return,img
nofiles:
    print,'nofiles found in dir:',dir,' \nfreq range',freqlow,freqhigh
end
