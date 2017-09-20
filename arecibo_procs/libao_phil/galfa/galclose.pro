;+
;NAME:
;galclose - close a gal file for i/o
;
;SYNTAX: galclose,desc 
;
;ARGS:
;   desc: {galdescr} - descriptor to close (returned by galopen)
;KEYWORDS:
;    all:              if set then close all open descriptors.
;
;DESCRIPTION:
;   Files opened with galopen() need to be closed with galclose() so that
;the resources are freed up.
;
;EXAMPLE:
;   filename='/share/wapp11/wapp1.20040121.a1849.0004.fits'
;   istat=galopen(filename,desc)
;   .. process the data in the file
;   galclose,desc   .. this closes the file when done with the processing.
;-
pro galclose,desc ,all=all
    common  galcom , galnluns,gallunar

    errmsg=''
    if keyword_set(all) then begin
        ind=where(gallunar ne 0,count)
        for i=0,count-1 do begin
            errmsg=''
            fxbclose,gallunar[ind[i]],errmsg=errmsg
            gallunar[ind[i]]=0
            galnluns=((galnluns-1) > 0)
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
