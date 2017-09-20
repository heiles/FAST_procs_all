;+
;NAME:
;pupfclose - close a puppi psrfits file for i/o
;
;SYNTAX: pupfclose,desc,all=all 
;
;ARGS:
;   desc: {pupfdesc} - descriptor to close (returned by pupfopen)
;KEYWORDS:
;    all:              if set then close all open descriptors.
;
;DESCRIPTION:
;   Files opened with pupfopen() need to be closed with pupfclose() so that
;the resources are freed up.
;
;EXAMPLE:
;   filename='/share/pdata/pdev/phil/071106//testfits.20071107.b0s0.00000.fits'
;   istat=pupfopen(filename,desc)
;   .. process the data in the file
;   pupfclose,desc   .. this closes the file when done with the processing.
;-
pro pupfclose,desc ,all=all
    common  pupfcom , pupfnluns,pupflunar

    errmsg=''
    if keyword_set(all) then begin
        ind=where(pupflunar ne 0,count)
        for i=0,count-1 do begin
            errmsg=''
            fxbclose,pupflunar[ind[i]],errmsg=errmsg
            pupflunar[ind[i]]=0
            pupfnluns=((pupfnluns-1) > 0)
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
