;+
;NAME:
;satfindtle - find tle file for satellite name
;SYNTAX: tlefile=satfindtle(satNm)
;ARGS:
;satNm: string  name of satellite to search for.
;
;RETURNS:
;tlefile:string name of tle file. '' if not found
;
;DESCRIPTION:
;   This routine will look for a tle file based on the satNm
;-
function satfindtle,satNm
;
;   
; 
    forward_function satlisttlefiles

    nfiles=satlisttlefiles(tlefiles,suf='tle')
    for ifile=0,nfiles-1 do begin
        nsat=satinptlefile(tlefiles[ifile],tleAr)
        if nsat gt 0 then begin
            ii=where(satNm eq tleAr.satNm,count)
            if count gt 0 then begin
                tlefile=tlefiles[ifile]
                return,tlefile
            endif
        endif
    endfor
    return,''
end
