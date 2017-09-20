;+
;NAME:
;a1963cmptimes - a1963 compute times given az,ra from source files
;SYNTAX: a1963cmptimes,yymmdd,srcfile,datI,srctime=srctime
;ARGS:
;   yymmdd: long    date (AST) for source file. It will find the first transit
;                   of each position for this AST date.
;  srcfile: string  the observing file used. It needs the ra,dec and the
;                   AZ= in the comments field.
;  srctime: long    number of seconds to track each source. The default
;                   is 480 seconds.
;RETURNS:
;   dateI[n]:{}     structure holding the computed data. 1 entry per 
;                   source position. The structure contains: 
;  YYMMDD  LONG      41130        ; date user specified
;   RAH    DOUBLE     9.4693056   ; ra in hours from file (J2000)
;   DECD   DOUBLE    21.540556    ; dec in degrees from file (J2000) ;
;   AZ     DOUBLE    252.47028    ; azimuth in degrees from file.
;   ROTD   DOUBLE    -56.000000   ; rotation angle from file (degrees)
;  srcTime double     480.        ; integration time in seconds.
;   AZDIF  DOUBLE      0.00010479062 ; azRequested - azComputed in degrees
;   ZA     DOUBLE     11.834881   ; zacomputed in degrees
;   JD     DOUBLE     2453339.9   ; jd for the az,za computed
;   lst    DOUBLE      0.         ; lst for this start time
;   ASTH   DOUBLE     4.4785450   ; AST hour of day for computed time.
;
;DESCRIPTION:
;   A1963 is using the fixedazimuth pattern. They are using a source file
;that contains and ra,dec and azimuth position for each drift. The datataking
;starts when the source arrives at the specified azimuth. 
;   This routine will verify that the azimuths/radecs are reasonable.
;It will use the ra/dec and azimuth to backcompute the julian date
;and za for the start of each drift. This information can then be used
;to verify that there is enough time between sources.
;   For each drift in a file the computation is:
;1. compute The Jd for the start of the specified ast day (yymmdd)
;2. compute the lst for this jd
;3. precess the ra position to this jd.
;4. compute the transit time of the source for this ast day
;   (raCurrent- jdMidnite)
;5. create an array of 300 jd times centered at the transit time and 
;   spaced by 1 solar second.
;6. use ao_radectoazza() to compute the az,za for each of these positions.
;   Include the /nomodel keyword since a1963 is inputting az,za 
;   without model corrections (they are included later).
;7. find the azimuth that is closest to the requested azimuth.
;8. store : ra,dec,az,rotation Angle from the srcfile as well as the computed:
;           za,jd,lst,astHour, and the difference between the reqested
;           and computed azimuth.
;EXAMPLE:
;   a1963cmptimes,041129,'/share/obs4/usr/a1963/n2903_nov29.cat',datI
;   a1963plotpattm,datI         ; plot the data
;
;NOTE:
;   Do @usrprojinit to include the path to this routine.
;
;WARNINGS:
;1. This routine uses precess from the goddard routines.
;   You need this in your path
;   (eg. addpath,'/pkg/rsi/idl/locallib/astron/pro/astro/')
;
;    
;   The routine expects the source file to look like:
;   srcname     ra       dec  coord
;                               vel  
;az252d2151  092809.5 +215126 j  0 # AZ=252.47028 rot_an=-56
;
;    It needs the ra,dec,#,AZ=, and rot_an= in the file.
; It parses the line after the # looking for AZ= and rot_an=
;-
;history:
; 29nov04 : written.
;
pro a1963cmptimes,yymmdd,srcfile,datI,srctime=srctime

;
    if n_elements(srctime) eq 0 then srctime=480D ; default integration time.
    format=2
    zaMax=19.69
    nsrc=cataloginp(srcfile,format,cdat)
;
; reformat data for what we need
;
a={    yymmdd   : 0L ,$ 
        raH     : 0D ,$
       decD     : 0d ,$
        az      : 0d ,$  
        rotD    : 0d ,$
        srctime : 0d ,$ 
        azDif   : 0d ,$ ; dist from request az to az at sec tick
        za      : 0d ,$ ; computed for this position
        jd      : 0d ,$ ; jd to start at
        lst     : 0d ,$ ; for start
        astH    : 0d }  ; of this time

datI=replicate(a,nsrc)
    for i=0,nsrc-1 do begin 
        datI[i].yymmdd=yymmdd
        datI[i].raH  =cdat[i].raH
        datI[i].decD =cdat[i].decD
;
;   parse the end of line
;
        res=stregex(cdat[i].eol,".*AZ=([0-9.]*) *rot_an=([-0-9]*)",$
            /extract,/subexpr)
        datI[i].az   =double(res[1])
        datI[i].rotD =double(res[2])
    endfor
;
; figure out jd for day of interest
;
    jd=yymmddtojulday(yymmdd) + 4D/24D      ; convert to utc
;
;   process each source
;   
    SOLAR_TO_SIDEREAL_DAY= 1.00273790935D
    radToHr=12D/!dpi
    jd2000=2451544.5D
    equCur=2000D + (jd-jd2000)/365.25D
    lstjd=juldaytolmst(jd)*radToHr          ; for start of day  ast
    for icur=0,nsrc-1 do begin
        raH   =datI[icur].raH
        decD  =datI[icur].decD
        raCD =raH*15D
        decCD=decD
        precess,raCD,decCD,2000D,equCur
        raCH=raCD/15D                       ; back to hours
;
;
;   figure out when racur transits.
;
        dif=raCH - lstjd
        if dif lt 0D then dif=dif+24D
; 
;   dif is now the number of lst hours after midnite ast of the first
;   source transit
;
        jdTransit=jd + (dif/24D)/SOLAR_TO_SIDEREAL_DAY
;
;   now compute az,za for the +/- 1.5 hours from transit
;
        nn=3*3600
        step=1./86400D
        rcv=17
        jdAr=(findgen(nn)-nn/2)*step + jdTransit          ; every half hour
        raAr =dblarr(nn) + raH
        decAr=dblarr(nn) + decD
        ao_radecjtoazza,rcv,raAr,decAr,jdAr,azAr,zaAr,/nomodel
;
;   only keep positions within az,za range
;
        ind=where(zaAr lt zaMax,count)
        if count  eq 0 then begin
            print,'source never rises at ao'
            return
        endif

        jdAr=jdAr[ind]
        azAr=azAr[ind]
        zaAr=zaAr[ind]
;
;   now find the index that is closest to the requested az
;
        min= min(abs(azAr-datI[icur].az),ind)
        datI[icur].azdif=min
        datI[icur].jd   =jdAr[ind]
        datI[icur].srcTime=srcTime
        datI[icur].za   =zaAr[ind]
        datI[icur].lst  =juldaytolmst(jdAr[ind])*radToHr
        caldat,jdar[ind]-4D/24D,mon,day,year,hour,min,sec
        datI[icur].astH = hour + min/60D  + sec/3600D
    endfor
;
    return
;
;
end
