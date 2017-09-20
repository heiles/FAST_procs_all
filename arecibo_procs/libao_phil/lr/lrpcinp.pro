;+
;NAME:
;lrpcinp - input pc laser ranging data.
;SYNTAX: istat=lrpcinp(yymmdd,b,daynum=daynum,year=year,ext=ext)
;ARGS:
;   yymmdd: long  year,mon,day to input. -1 --> today
;  RETURNS:
;  b[npts]: {lrdat} array holding the data
;   istat :  int    number of entries found
;keywords:
;   daynum: long    if supplied then use daynum for day of year
;   year  : long    if daynum supplied, then year to use. If not supplied,
;                   use current year.
;      ext:         if set then return extended info.. az,gr,ch positions. 
;                   This uses the tdsummary info. It is not available for the
;                   current month.
;
;DESCRIPTION:
;   The routine inputs a days worth of laser ranging data. It returns the
;data from the laser ranging PC as well as the heigts converted to feet
;above sea level (the conversion factors were measured in 1990 and have
;probably changed!). The data available on disc goes back about 8 months
;from the present. New samples are taken once every two minutes. During 
;periods of rain, the distomats have no readings and the distances are
;set to 0.
;
;   The data structure for the returned data is:
;The coordinate systems used are:
;  C1: x-west,ynorth,z-down cm no corrections to move to Sea level crdSys
;  C2: x-west,ynorth,z-up feet above sea level
;
; name        type  coordSys  value      description.
; DATE        DOUBLE        1.0057176 daynumber with fractional day
; TEMPB       FLOAT         0.00000   bowl temp F (not recorded)
; TEMPPL      FLOAT         70.1000   platform temp degF
; DIST        FLOAT         Array[6]  distomat distances [meters].
; DISTTM      FLOAT         Array[6]  secs when reading completed.
; AVGH        FLOAT C2      1256.33   Average hght Ft above sealevel.
; CORNERH     FLOAT C2      array[3]  Corner hght [12,4,8]
; DX          FLOAT C1     -1.50626   Avg x-translation [cm]
; DY          FLOAT C1      4.52196   Avg y-translation [cm]
; DZ          FLOAT C1     -100.191   Avg z-translation [cm]
; XROT        FLOAT C1   -0.00127837  rotation about x-axis [rad]
; YROT        FLOAT C1    0.00106705  rotation about y-axis [rad]
; ZROT        FLOAT C1   -0.00022241  rotation about z-axis [rad]
; PNTS        FLOAT C1    Array[3,3]  [xyz,T12/T4/T8] corner points
; DOK         INT              1      1 if all 6 distances measured ok
; SECPERPNT   INT            120       spacing between measurements [secs]
;
;NOTES:
;   You need to do @lrinit once before calling this routine to define the
;   {lrdat} structure.
;
;-
function lrpcinp,yymmdd,b,daynum=daynum,year=yearl,ext=ext
;
;   create the day:
;   
    forward_function bin_date,tdgetsum

    autoDate=0   
    maxentries=2000L 
;    dirc='/home/lrpc/lr_data/' 
	 dirAr=strarr(2)
     dirAr[0]='/share/lrpc/lr_data/' 
     dirAr[1]='/share/obs4/lr/pc/'       ; long term storage
    on_ioerror,done
    if keyword_set(daynum) then begin
        year=(n_elements(yearl) eq 0)?(bin_date())[0] : yearl
        a=daynotodm(daynum,year)
        yymmdd=(year mod 100L)*10000L+a[1]*100+a[0]
    endif
    if yymmdd lt 0 then begin
        a=bin_date()
        year =a[0]
        month=a[1]
        day  =a[2]
        autoDate=1
    endif else begin
        year=yymmdd/10000L
        if year gt 90 then begin
            year=year+1900L
        endif else begin
            year=year+2000L
        endelse
        month=(yymmdd/100) mod 100L
        day  = yymmdd mod 100L
    endelse
    curyear=(bin_date())[0]
    dirAr[1]=string(format='(a,i4,"/")',dirAr[1],year)
	numTry=0
tryagain:   if day lt 10 then sday=string(format='(i1)',day) else $
                      sday=string(format='(i2)',day)
    if month lt 10 then smon=string(format='(i1)',month) else $
                        smon=string(format='(i2)',month)
;
;   decide on the directory
;
    dir=dirAr[0]
    a=findfile(dir +'d'+smon+'_'+ sday + '.dat')
    if a[0] eq '' then dir=dirAr[1]

    fname=dir+"d"+smon+"_"+sday+".dat"
;    print,fname
    openr,lun,fname,/get_lun,error=ioerr
    if ioerr ne 0 then  begin
        if autoDate eq 1 then begin     ; file hasnot switch yet try yesterday.
            daynuml=dmtodayno(day,month,year)
            daynuml=daynuml-1
            yearl=year
            if daynuml lt 1 then begin
                yearl=year-1
                if isleapyear(yearl) then begin
                  daynuml=366 
                endif else begin
                  daynuml=365 
                endelse
            endif
            a=daynotodm(daynuml,yearl)
            day=a[0]
            month=a[1]
            autoDate=0
			numTry=numTry+1
			if numTry lt 2 then goto,tryagain
        endif
        printf,-2,!err_string," opening file:",fname
        return,0
    endif
    binp=replicate({lrpcinp},maxentries)
    readf,lun,binp
done:
    if lun gt 0 then free_lun,lun
    ind=where(binp.secperpnt eq 0,count)
    numpnts=maxentries
    if count gt 0 then begin
        numpnts=ind[0]
        binp=temporary(binp[0:numpnts-1])
    endif
    if (binp[0].secperpnt lt 0) or (binp[0].secperpnt gt 255) then $
        binp=swap_endian(binp)
    if keyword_set(ext) then begin
        istat=lrcmp(binp,b,/ext)
        yymmddl=(year mod 100L)*10000L+month*100L+day
;;		print,"tdgetsum call yymmddl:",yymmddl
        nrecs=tdgetsum(yymmddl,yymmddl,tds)
        if nrecs gt 0 then begin
            dayno=dmtodayno(day,month,year)
            b.az  =interpol(tds.az,tds.day,b.date)
            b.zagr=interpol(tds.gr,tds.day,b.date)
            b.zach=interpol(tds.ch,tds.day,b.date)
            indbad=where( (b.date-dayno) lt 0.,count)
            if count gt 0 then begin
                b[indbad].az  =-1.
                b[indbad].zagr=-1.
                b[indbad].zach=-1.
            endif
        endif else begin
           print,yymmdd,' No tdsummary recs found for /ext. Is this current month?'
                b.az  =-1.
                b.zagr=-1.
                b.zach=-1.
        endelse
        return,istat
    endif else begin
        return,lrcmp(binp,b)
    endelse
end
