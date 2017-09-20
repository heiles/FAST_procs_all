;+
;NAME:
;psrfclose - close a psrfits file for i/o
;
;SYNTAX: psrfclose,desc,all=all 
;
;ARGS:
;   desc: {psrfdescr} - descriptor to close (returned by psrfopen)
;KEYWORDS:
;    all:              if set then close all open descriptors.
;
;DESCRIPTION:
;   Files opened with psrfopen() need to be closed with psrfclose() so that
;the resources are freed up.
;
;EXAMPLE:
;   filename='/share/pdata/pdev/phil/071106//testfits.20071107.b0s0.00000.fits'
;   istat=psrfopen(filename,desc)
;   .. process the data in the file
;   psrfclose,desc   .. this closes the file when done with the processing.
;-
pro psrfclose,desc ,all=all
    common  psrfcom , psrfnluns,psrflunar

    errmsg=''
    if keyword_set(all) then begin
        ind=where(psrflunar ne 0,count)
        for i=0,count-1 do begin
            errmsg=''
            fxbclose,psrflunar[ind[i]],errmsg=errmsg
            psrflunar[ind[i]]=0
            psrfnluns=((psrfnluns-1) > 0)
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
