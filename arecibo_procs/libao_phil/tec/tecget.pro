;+
;NAME:
;tecget - get tec data from the archive
;SYNTAX: npnts=tecget(yymmdd1,yymmdd2,tecAr)
;ARGS:
; yymmdd1: long first day to get
; yymmdd2: long last day to include
;RETURNS:
;npnts       : long number of points found.
;tecAr[npnts]: {}   tecAr holding all data samples in the requested range
;DESCRIPTION:
;   Return all of the tec info between the specified dates. 
;A sample is included if the ast time of the first point
;in the satellite pass falls within the date range (including the last day).
;-
function tecget,yymmdd1,yymmdd2,tAr 
    forward_function daysinmon
;
;   get a list of the save files we currently have:
;
    dir=tecdir()            ; directory holding the data
    pathspec=dir + "tec*.sav"
    flist=file_search(pathspec)
    nfiles=n_elements(flist)
    julday1=yymmddtojulday(yymmdd1) + 4./24. ; go ast to utc
    julday2=yymmddtojulday(yymmdd2) + 4./24. ; go ast to utc
    useMon=intarr(nfiles)
    curp=0L
    passNumCur=0L
    for i=0,nfiles-1 do begin
        a=stregex(flist[i],'.*tec([0-9]*).sav',/extract,/subex)
        yymmddf1=long(a[1])*100L + 01
        daysInMon=daysinmon((yymmddf1 / 100L) mod 100,yymmddf1/10000L)
        yymmddf2=yymmddf1 + daysInMon -1
        if (yymmddf2 lt yymmdd1) or (yymmddf1 gt yymmdd2) then begin
            continue
        endif else begin
            restore,flist[i]
            ntotMon=n_elements(tar)
            ii=where((tecar.jd ge julday1) and (tecar.jd lt (julday2+1.)),cnt)
            if cnt gt 0 then begin
                if (passNumCur ne 0L) then begin
                    tecAr.passNum+=passNumCur
                endif
                passNumCur=max(tecAr.passNum)
                if curp eq 0 then  begin
                    tAr=(ntotMon eq cnt)?tecAr:tecAr[ii]
                endif else begin
                    tAr=[tAr,tecAr[ii]]
                endelse
                curp+= cnt
            endif
        endelse
    endfor
    return,curp
end
