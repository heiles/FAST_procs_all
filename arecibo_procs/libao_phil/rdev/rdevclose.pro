;+
;NAME:
;rdevclose - close a rdev file for i/o
;
;SYNTAX: rdevclose,desc,all=all 
;
;ARGS:
;   desc: {rdevdescr} - descriptor to close (returned by rdevopen)
;KEYWORDS:
;    all:              if set then close all open descriptors.
;
;DESCRIPTION:
;   Files opened with rdevopen() need to be closed with rdevclose() so that
;the resources are freed up.
;
;EXAMPLE:
;   filename='/share/pdata/pdev/phil/071106//testdata.20071107.00000.pdev'
;   istat=rdevopen(filename,desc)
;   .. process the data in the file
;   rdevclose,desc   .. this closes the file when done with the processing.
;-
pro rdevclose,desc ,all=all
    common  rdevcom , rdevnluns,rdevlunar

    errmsg=''
    if keyword_set(all) then begin
        ind=where(rdevlunar ne 0,count)
        for i=0,count-1 do begin
			free_lun,rdevlunAr[ind[i]]
            rdevlunar[ind[i]]=0
            rdevnluns=((rdevnluns-1) > 0)
        endfor
    endif else begin
        if desc.lun gt 0 then begin
			free_lun,desc.lun
            ind=where(rdevlunar eq desc.lun,count)
			if count gt 0 then begin
				rdevlunar[ind[0]]=0
				rdevnluns-=1
			endif
        endif
        desc.lun=0
    endelse
    return
end
