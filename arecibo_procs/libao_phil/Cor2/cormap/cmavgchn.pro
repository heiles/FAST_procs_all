;+
;NAME:
;cmavgchn   - average freq channels of a map
;
;SYNTAX:  avgchn=cmavgchn(m,pol,chn1,ch2)
;
;ARGS:
; m[2,nsmp,nstrips] : map structure array 
;               pol : 1 or 2.. pol to return.
;              chn1 : first freq chn for average. count from 1
;              chn2 : last freq chn for average. count from 1
;
;RETURNS:
;   avgchn[nsmp,nstrips: float the averaged channels.
;
;DESCRIPTION:
;   Average frequency channels chn1 through chn2 of the requested
;polarization. Return a float array of the averaged channels.
;
;EXAMPLE:
;   assume m[2,31,21]  is a map with 2 polarizations, 31 samples per strip, 
;21 strips, and 1024 frequency channels. Then the call :
;   avgchn=cmavgchn(m,1,500,520)
;returns the array avgchn[31,21] that is averaged over the frequency 
;channels 500=520.
;-
function cmavgchn,m,pol,chn1,chn2
;
    a=size(m)
    nstrips=a[3]
    nsmp   =a[2]
    nchn   =(size(m[0,0,0].d))[1]
    if (chn1 lt 1 ) or (chn2 lt 1) or (chn1 gt nchn) or (chn2 gt nchn) or $
        (chn1 gt chn2) then begin
            print,'chn1,chn2 must be between,1 and ',nchn
            return,''
    endif
    return,reform(total(m[pol-1,*,*].d[chn1-1:chn2-1],1),nsmp,nstrips)/$
            (chn2-chn1+1)
end
