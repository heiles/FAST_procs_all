;+
;NAME:
;cmavgstrips- average bandpasses for a map
; 
;SYNTAX:  avgbp=cmavgstrips(m,pol,first=first,last=last)
;
;ARGS: 
;   m[2,nsmp,nstrips] : map structure array 
;                 pol : 1 or 2.. pol to return
;
;KEYWORDS:
;    first : int first strip to use. default =1
;    last  : int last strip to use. default  =last
;   normal : if set then normalize averaged bandpass to unity
;
;RETURNS:
;   avgbp[nfrqchn] : float .. averaged bandpass.
;
;DESCRIPTION:
;   Average all spectra in 1 or more strips together. Return the 
; averaged bandpass.
;
;EXAMPLES:
;   Assume that m[2,31,21] is a map with 31 samples/strip, 21 strips,and
;   1024 frequency channels.
;   avgbp=cmavgstrips(m,1) will average all of the bandpasses for 
;                          pol A in the map
;   avgbp=cmavgstrips(m,1,first=2,last=5) will average all samples in 
;                          strips 2 through 5 (counting from 1).
;   avgbp=cmavgstrips(m,1,first=3,last=3) will average all the samples 
;                          in strip 3.
;-
; 01mar05 fix for single strip processing
function cmavgstrips,m,pol,first=first,last=last,normal=normal
;
    a=size(m)
    nstrips=(a[0] eq 2) ? 1 : a[3]
    nsmp   =a[2]
    nchn   =(size(m[0,0,0].d))[1]
    polI=pol-1
    if not keyword_set(first) then first=1
    if not keyword_set(last)  then last =nstrips
    if (first lt 1 ) or (last gt nstrips) then begin
        print,'cmavgstrips: first,last strips out of range:',1,' to ',nstrips
        return,''
    endif
    bpavg=fltarr(nchn)
    if (last-first) gt 0 then begin
        bpavg=reform(total(total(m[polI,*,first-1:last-1].d,3),3),nchn)/$
            (nsmp*(last-first+1))
    endif else begin
        bpavg=reform(total(m[polI,*,first-1].d,3),nchn)/nsmp
    endelse
    if keyword_set(normal) then bpavg=bpavg/(total(bpavg)/nchn)
    return,bpavg
end
