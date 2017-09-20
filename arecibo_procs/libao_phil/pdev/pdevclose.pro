;+
;NAME:
;pdevclose - close a pdev file for i/o
;
;SYNTAX: pdevclose,desc,all=all 
;
;ARGS:
;   desc: {pdevdescr} - descriptor to close (returned by pdevopen)
;KEYWORDS:
;    all:              if set then close all open descriptors.
;
;DESCRIPTION:
;   Files opened with pdevopen() need to be closed with pdevclose() so that
;the resources are freed up.
;
;EXAMPLE:
;   filename='/share/pdata/pdev/phil/071106//testfits.20071107.b0s0.00000.fits'
;   istat=pdevopen(filename,desc)
;   .. process the data in the file
;   pdevclose,desc   .. this closes the file when done with the processing.
;-
pro pdevclose,desc ,all=all
    common  pdevcom , pdevnluns,pdevlunar

    errmsg=''
    if keyword_set(all) then begin
        ind=where(pdevlunar ne 0,count)
        for i=0,count-1 do begin
            errmsg=''
			free_lun,pdevlunar[ind[i]]
            pdevlunar[ind[i]]=0
            pdevnluns=((pdevnluns-1) > 0)
        endfor
    endif else begin
        if desc.lun gt 0 then begin
			free_lun,desc.lun
			ind=where(pdevlunar eq desc.lun,count)
    		if count gt 0 then begin
       		 	pdevlunar[ind[0]]=0
        		pdevluns=(pdevnluns-1) > 0 
			endif
    	endif
        desc.lun=0
    endelse
    return
end
