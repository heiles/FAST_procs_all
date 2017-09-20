;+
;NAME:
;masclose - close a mas file for i/o
;
;SYNTAX: masclose,desc,all=all 
;
;ARGS:
;   desc: {masdescr} - descriptor to close (returned by masopen)
;KEYWORDS:
;    all:              if set then close all open descriptors.
;
;DESCRIPTION:
;   Files opened with masopen() need to be closed with masclose() so that
;the resources are freed up.
;
;EXAMPLE:
;   filename='/share/pdata/pdev/phil/071106//testfits.20071107.b0s0.00000.fits'
;   istat=masopen(filename,desc)
;   .. process the data in the file
;   masclose,desc   .. this closes the file when done with the processing.
;-
pro masclose,desc ,all=all
    common  mascom , masnluns,maslunar

    errmsg=''
    if keyword_set(all) then begin
        ind=where(maslunar ne 0,count)
        for i=0,count-1 do begin
            errmsg=''
            fxbclose,maslunar[ind[i]],errmsg=errmsg
            maslunar[ind[i]]=0
            masnluns=((masnluns-1) > 0)
        endfor
    endif else begin
        if desc.lun gt 0 then begin
            fxbclose,desc.lun,errmsg=errmsg
            if errmsg ne '' then  print,errmsg
			ind=where(maslunar eq  desc.lun,count)
			if count gt 0 then begin
				maslunar[ind[0]]=0
				masnluns-=1
			endif
        endif
        desc.lun=0
    endelse
    return
end
