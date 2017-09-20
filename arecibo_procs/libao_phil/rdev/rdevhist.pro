;+
;NAME:
;rdevhist - make a histogram of rdev data.
;SYNTAX: rdevhist,hdr,d
;ARGS:
; hdr : {} header read in with rdropen()
; d[n]: int data read in via rdevget()
;KEYWORDS:
; tit: string   title for plot
;plot keywords.. you can enter keywords to plot and they will be included.
; 
;DESCRIPTION:
;   Plot a histogram of the sampled data as well as the bit usage. The top
;plot is the histogram of the data. The horizontal axis is the values the
;data can take. The vertical axis is the fraction of total counts taken.
;   The bottom plot is a plot of the fraction of time each of the n bits
;were a 1.
;-
pro rdevhist,hdr,d,tit=tit,_extra=e 
            
;
;	case hdr.h2.bitsel of 
	bitsel=3
	case bitsel of 
		0:nbits=2
		1:nbits=4
		2:nbits=8
        3:nbits=16
	endcase
    nsmp=n_elements(d)
    if n_elements(tit) eq 0 then tit=''
;
; make a histogram of the raw data
; 
    maxVal=2^(nbits-1) - 1
    minVal=-maxval - 1
    h=histogram(d,min=minval,max=maxval,binsize=1)
    xh=findgen(2L^nbits) + minVal

    !p.multi=[0,1,2]
    hor
    plot,xh,h/total(h),_extra=e,$
    xtitle='digitzer value',ytitle='Fractional occurence',$
    title=tit + ' Histogram of sampled data'
;
; plot bit usage
;
    mask=1
    bitCnt=lonarr(nbits)
    for i=0,nbits  - 1 do begin &$
        ii=where((d and mask) ne 0,cnt) &$
        bitCnt[i]=cnt &$
        mask*=2 &$
    endfor
    bitCnt/=(nsmp*1.)
;
    hor,-1,nbits
    ver,0,1
    sym=-2
    plot,bitcnt,psym=sym,$
    xtitle='digitizer bit (0..)',ytitle='Fraction Time bit 1',$
    title=tit + 'Fraction of time each bit is a 1'
    scl=.6
    xp=.01
    ln=17
    for i=0,nbits-1 do $
        note,ln+scl*i,string(format='("bit",i2,": ",f4.2)',i,bitcnt[i]),xp=xp
    !p.multi=0
    return
end
