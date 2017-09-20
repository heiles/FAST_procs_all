;+
;NAME:
;puprclose - close a raw puppi file for i/o
;
;SYNTAX: puprclose,desc,all=all 
;
;ARGS:
;   desc: {puprdescr} - descriptor to close (returned by pupropen)
;KEYWORDS:
;    all:              if set then close all open descriptors.
;
;DESCRIPTION:
;   Files opened with pupropen() need to be closed with puprclose() so that
;the resources are freed up.
;
;EXAMPLE:
;   filename='/share/pdata/pdev/phil/071106//testfits.20071107.b0s0.00000.fits'
;   istat=pupropen(filename,desc)
;   .. process the data in the file
;   puprclose,desc   .. this closes the file when done with the processing.
;-
pro puprclose,desc ,all=all
    common  puprcom , puprnluns,puprlunar

    errmsg=''
    if keyword_set(all) then begin
        ind=where(puprlunar ne 0,count)
        for i=0,count-1 do begin
            free_lun,puprlunar[ind[i]]
            puprlunar[ind[i]]=0
            puprnluns=((puprnluns-1) > 0)
        endfor
    endif else begin
        if desc.lun gt 0 then begin
            free_lun,desc.lun
			ind=where(puprlunar eq  desc.lun,count)
			if count gt 0 then begin
				puprlunar[ind[0]]=0
				puprnluns-=1
			endif
        endif
        desc.lun=0
    endelse
    return
end
