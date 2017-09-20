;+
;NAME:
;agcinpday - input all the agc info for 1 day.
;SYNTAX: npts=agcinpday(date,b,cb=cb,fb=fb,onekind=onekind,raw=raw,dirL=dirL)
;ARGS:
;       date:   long yymmdd file to input
;       b[] :   {cbfb}  return cblock,fblock info here, if cb or fb set then
;                       structure will only be cb or fb    
;       npts:   long    number of samples found
;KEYWORDS:
;   cb   : if set, only input cblock
;   fb   : if set, only input fblock
;   raw  : return raw struct as read from vertex.
;  onekind: if set then the datafile only has the cb, or fb specified
;  dirL[]: string  list of extra directories to search for files
;RETURNS:
;     npts: long number of samples found for this day.
;DESCRIPTION:
;   agcinpday will input all of the agc data for the requested day.
;The array B[] will typically have 86400 entries (1 per second). The data
;structure is described in agcIntro above.
;-
function    agcinpday,yymmdd,b,cb=cb,fb=fb,onekind=onekind,raw=raw,dirL=dirL
;
;   get the filename
;
	if ((lun=agcopen(yymmdd,dirUsed=dirUsed,fnameUsed=fnameUsed,dirL=dirL)) $
			 lt 0) then begin
           msg="could not open file: " + fnameUsed
		   print,msg
		   return,0
	endif
    if not keyword_set(fb) then  fb=0
    if not keyword_set(fb) then  fb=0
    if not keyword_set(cb) then  cb=0
    if not keyword_set(onekind) then  onekind=0
	if keyword_set(raw) then begin
    	npts=agcinpraw(lun,b,-1L,fb=fb,cb=cb,onekind=onekind)
	endif else begin
    	npts=agcinp(lun,b,-1L,fb=fb,cb=cb,onekind=onekind)
	endelse
    free_lun,lun
    return,npts
end
