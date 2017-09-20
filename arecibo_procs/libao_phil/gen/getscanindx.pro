;+
;NAME:
;getscanindx - extract scan from array.
;SYNTAX: subarr=getscanindx(datarr,scanind,scanlen)
;ARGS  :
;       datarr[]: any type extract subarray from here
;       index   :     long .. index to extract 
;       scanind[len]: long .. index array from getscanind
;       scanlen[len]: long .. len each scan from getscanind
;RETURNS:
;       datsubarr[] : anytype.. ith scans data
;                           of each scan.
;DESCRIPTION:
;   Some routines return multiple scans data as one large array with
;one of the elements in the array being the scan number. getscanind()
;will find the start and length of each scan in this array.
;getscanindx will extract the i'th scans data from the array.
;EXAMPLE:
;   print,corpwr(lun,9999,p)        ... up to 9999 recs
;   getscanind,p.scan,scanind,scanlen
;;  now loop thru extracting each scans data
;   nscans=(size(scanind))[1]
;   for i=0,nscans-1 do begin
;;      grab those belonging to the ith scan 
;       p1=getscanindx(p,i,scanind,scanlen)
;       ...process
;   endfor
;-
function getscanindx,ar,ind,scanind,scanlen
    return,ar[scanind[ind]:scanind[ind]+scanlen[ind]-1]
end
