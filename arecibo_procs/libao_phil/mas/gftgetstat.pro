;+
;NAME:
;gftgetstat - input status info from file
;SYNTAX: istat=gftgetstat(desc,statOn,statOff,nrows=nrows,all=all)
;ARGS:
;   desc: {}      struct returned from masopen()
;KEYWORDS:
;    row : long   row to position to before reading count from 1.
;   nrows: long   number of rows of stat data to read in .default=1 row
;                 from current position.
;     all:        if set then read in the stat info for the entire file.
;RETURNS:
;   istat: n  number of stat stuctures returned. One struct for each
;             spectra. if nrows were read, there will be nrows*spcPerRow
;          -1 error reading file
;stat[n]:{stat} stat data from file.
;-
function gftgetstat,desc,stOnAr,stOffAr,nrows=nrows,all=all,row=row
;
;
;
    curRowStart=desc.currow
    useall=keyword_set(all)
    nrowsL=(useall)?desc.totrows $
                    :(n_elements(nrows) gt 0)$
                    ? nrows:1L
    rowStart=(useall)?1:$
			 keyword_set(row)?row:desc.currow +1l ; desc.currow counts from 1.
    if rowStart gt desc.totrows then begin
        print,"gftgetstat: row request beyond end of file"
        return,-1
    endif
    rowEnd=rowStart+nrowsL - 1L
    rowEnd=(rowEnd gt desc.totrows)?desc.totrows:rowEnd
    errmsg=''
    first=1
    icnt=0L
    for irow=rowStart,rowend do begin
        fxbread,desc.lun,stOnSh,3,irow,errmsg=errmsg
        if errmsg ne '' then begin
            print,"staton read error:" + errmsg
            goto,ioerr
        endif
        fxbread,desc.lun,stOffSh,4,irow,errmsg=errmsg
        if errmsg ne '' then begin
            print,"statoff read error:" + errmsg
            goto,ioerr
        endif
        desc.currow=irow
        ndump=n_elements(stOnSh)/10L
        if first then begin
            maxrows=ndump*(rowEnd - rowStart + 1)
            stOnAr =replicate({pdev_hdrdump},maxrows)
            stOffAr=replicate({pdev_hdrdump},maxrows)
            first =0
        endif
        stOnSh=reform(stOnSh,10,ndump)
        stOffSh=reform(stOffSh,10,ndump)
        for i=0,9 do begin
			stOnAr[icnt:icnt+ndump-1].(i)=reform(stOnSh[i,*])
			stOffAr[icnt:icnt+ndump-1].(i)=reform(stOffSh[i,*])
		endfor
        icnt+=ndump
    endfor
    if icnt lt maxrows then begin
		stOnAr=stOnAr[0:icnt-1]
		stOffAr=stOffAr[0:icnt-1]
	endif
    return,icnt
ioerr:
    desc.currow=curRowStart
    return,-1
end
