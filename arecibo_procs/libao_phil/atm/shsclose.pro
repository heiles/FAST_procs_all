;+
;NAME:
;shsclose - close an atm shs file
;SYNTAX: shsclosel,desc,all=all
;ARGS:
;   desc: {}    descriptor returned by shsopen()
;KEYWORDS:
;    all:       if set then close all open descriptors.
;
;
;DESCRIPTION:
;   close an atm shs file. This frees up the lun.
;-
pro shsclose,desc,all=all
;
;
    common  shscom , shsnluns,shslunar

    if keyword_set(all) then begin
        ind=where(shslunar ne 0,count)
        for i=0,count-1 do begin
            errmsg=''
            free_lun,shslunar[ind[i]]
            shslunar[ind[i]]=0
            shsnluns=((shsnluns-1) > 0)
        endfor
    endif else begin
        if desc.lun gt 0 then free_lun,desc.lun
        desc.lun=0 
    endelse
    return
end
