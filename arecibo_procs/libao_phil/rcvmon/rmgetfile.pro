;+
;NAME:
;rmgetfile - find the files for the specified date(s)
;SYNTAX: nfiles=rmgetfile(yymmdd1,yymmdd2,filelist,ndays=ndays)
;ARGS:
;   yymmdd1: long  date for first day to read 
;   yymmdd2: long  date for last day of interest
;KEYWORDS:
;   ndays: long find files for ndays starting at yymmdd1. In this case
;               ignore yymmdd2.
;RETURNS:
;   nfiles: number of files found.
;   filelist[nfiles]: list of files.
;   yymmdd2: will return the actual last day used (in case you have
;            requested something in the future.
;DESCRIPTION:
;   Return the list of filenames that contain the data for yymmdd1 through
;yymmdd2. If keyword ndays is provided then return the list of filenames
;for the ndays of data starting at yymmdd1 and return yymmdd2.
;   The data is stored by month.
;
;EXAMPLE:
;   Get the files for oct02 through dec02
;   nfiles=rmgetfile(021001,021230,filelist)
;   print,nfiles
;   3
;   print,filelist
;   /share/obs4/rcvm/rcvmN.0210 
;   /share/obs4/rcvm/rcvmN.0211 
;   /share/obs4/rcvm/rcvmN
;-
function rmgetfile,yymmdd1,yymmdd2,filelist,ndays=ndays
;
    fpath='/share/obs4/rcvm/rcvmN'
    maxfiles=12
    yymm2=yymmdd1/100L
    if keyword_set(ndays) then begin
        julday1=yymmddtojulday(yymmdd1)
        if ndays lt 0 then begin
            julday2=julday1+ndays+1
        endif else begin
            julday2=julday1+ndays-1
        endelse
        caldat,julday2,mon,day,year
        yymmdd2=(year mod 100)*10000L + mon*100 + day
    endif
    yymmdd1l=yymmdd1
    yymmdd2l=yymmdd2
    if (yymmdd1l gt yymmdd2l) then begin
        itemp=yymmdd1l
        yymmdd1l=yymmdd2l
        yymmdd2l=itemp
    endif
    a=bin_date()
    yymmddcur=(a[0] mod 100) *10000L + a[1]*100 + a[2]
    if yymmdd2l gt yymmddcur then yymmdd2l=yymmddcur
    filelist=strarr(maxfiles)
    yymm  =yymmdd1l/100L
    yymm2 =yymmdd2l/100L
    yymmcur = yymmddcur/100
    nfiles=0;
    for i=0,maxfiles-1 do begin
        if (yymm gt yymmcur) or (yymm gt yymm2)  then goto,done
        if (yymm eq yymmcur) then begin
            filelist[nfiles]=fpath
            nfiles=nfiles+1
            goto,done
        endif
        lab=string(format='(i4.4)',yymm)
        filelist[nfiles]=fpath + '.' + lab
        nfiles=nfiles+1
        yy=yymm/100
        mm=(yymm mod 100) + 1
        if mm gt 12 then begin
            mm=1
            yy=yy+1
        endif
        yymm=yy*100+mm
    endfor
done:   return,nfiles
end
