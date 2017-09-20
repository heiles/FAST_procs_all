;+
;NAME:
;wasclose - close a was file for i/o
;
;SYNTAX: wasclose,desc 
;
;ARGS:
;   desc: {wasdescr} - descriptor to close (returned by wasopen)
;KEYWORDS:
;	 all:			   if set then close all open descriptors.
;
;DESCRIPTION:
;   Files opened with wasopen() need to be closed with wasclose() so that
;the resources are freed up.
;
;EXAMPLE:
;   filename='/share/wapp11/wapp1.20040121.a1849.0004.fits'
;   istat=wasopen(filename,desc)
;   .. process the data in the file
;   wasclose,desc   .. this closes the file when done with the processing.
;-
pro wasclose,desc ,all=all
	common	wascom , wasnluns,waslunar

    errmsg=''
	if keyword_set(all) then begin
		ind=where(waslunar ne 0,count)
		for i=0,count-1 do begin
    		errmsg=''
        	fxbclose,waslunar[ind[i]],errmsg=errmsg
			waslunar[ind[i]]=0
			wasnluns=((wasnluns-1) > 0)
		endfor
	endif else begin
    	if desc.lun gt 0 then begin
        	fxbclose,desc.lun,errmsg=errmsg
        	if errmsg ne '' then  print,errmsg
    	endif
    	desc.lun=0
	endelse
    return
end
