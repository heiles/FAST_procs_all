;+
;NAME:
;mmfindpattern - get the indices for the start of the patterns
;SYNTAX: nfound=mmfindpattern(sl,indar,stripspat=stripspat)
;ARGS:  
;   sl[]:   {getsl} scan list array from getsl
;KEYWORDS:
;   stripspat: int  minimum number of strips in pattern to count
;                   at ok  default is 4.
;RETURNS:
;   ind[npat]: long indices into sl[] for cal rec at start of each pattern
;   npat     : long number of patterns found
;DESCRIPTION:
;   The getsl() routine will routine a scanlist array holding info about
;every scan in a file. This routine will then search the sl[] array and
;find the indices where the heiles scans start. For it to be included
;there must be at least stripspat strips in the pattern (the default is 4).
;
;EXAMPLE:
;   openr,lun,'/share/olcor/corfile.23aug02.x101.1',/get_lun
;   sl=getsl(lun)
;   npat=mmfindpattern(sl,indfound)
;   for i=0,npat-1 do begin
;      scan=sl[indfound[i]].scan
;      .. process this scan
;-
function mmfindpattern,sl,indfound,stripspat=stripspat,rcv=rcv
;
    if not keyword_set(stripspat) then stripspat=4
    if not keyword_set(rcv) then rcv=0
    if stripspat eq 4 then begin
        pattype=4
    endif else begin
        pattype=5
    endelse
    return,corfindpat(sl,indfound,pattype=pattype,rcv=rcv)
end
