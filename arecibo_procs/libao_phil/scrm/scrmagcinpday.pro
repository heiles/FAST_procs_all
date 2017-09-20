;+
;NAME:
;scrmagcinpday - input all the scrm pnt info for 1 day.
;SYNTAX: npts=scrmagcinpday(date,b,dirL=dirL)
;ARGS:
;       date:   long yymmdd file to input
;       b[] :   {cbfb}  return cblock,fblock info here, if cb or fb set then
;                       structure will only be cb or fb    
;       npts:   long    number of samples found
;KEYWORDS:
;  dirL[]: string  list of extra directories to search for files
;RETURNS:
;     npts: long number of samples found for this day.
;DESCRIPTION:
;   scrmagcinpday will input all of the pnt data for the requested day.
;The array B[] will typically have 86400 entries (1 per second). The data
;structure is described in scrmIntro above.
;-
function    scrmagcinpday,yymmdd,b,dirL=dirL
;
;   get the filename
;
	type="agc"
	if ((lun=scrmopen(yymmdd,type,dirUsed=dirUsed,fnameUsed=fnameUsed,$
			dirL=dirL)) lt 0) then begin
           msg="could not open file: " + fnameUsed
		   print,msg
		   return,0
	endif
   	npts=scrminp(lun,b,-1L,type)
    free_lun,lun
    return,npts
end
