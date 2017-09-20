;+
;NAME:
;a1963printtimes - print pattern times to stdout.
;SYNTAX: printtimes,datI
;ARGS:
;   datI[n]: {} structure computed by comptimes()
;
;DESCRIPTION 
;   print out the a1963 timing information computed from the
;routine times. The output goes to stdout (the terminal).
;   The output consists of:
;
;info for :       41202 integration time:       480.00000
;
;Jd frac     lmst        ra        dec       az    availTm  ExtraTm
;0.85170  084531.17  092809.50  211326.00  252.47      0.0    0.0
;0.85692  085303.39  092809.50  210356.00  250.64    451.0  -70.7
;
; 041202 is the date in yymmdd format.
;    480 is the integration time in seconds.
;
;col           description
;JD fraction: the fraction of jd day
;       lmst: the sidereal time start of strip. format is hhmmss.ss
;         ra: J2000 ra  in hhmmss from the file
;        dec: J2000 dec in ddmmss from the file
;         az: azimuth in degrees from the file
;    availTm: available time in seconds. Computes from the azimuths and ra,dec
;    extraTm: extra time in seconds. This is the available time - 
;             the (integration time + moveTime).
;             This used the slew rates for the move time. It is probably
;             a maximum value.
;
;EXAMPLE:
;   cmptimes,041130,'/share/obs4/usr/a1963/n2903_nov30.cat',datI
;   printtimes,datI
;info for :       41130 integration time:       480.00000
;Jd frac     lmst        ra        dec       az    availTm  ExtraTm
;0.84925  083405.83  092810.00  215126.00  252.46      0.0    0.0
;0.85573  084327.36  092810.00  215126.00  249.87    560.0   29.5
;0.86236  085301.93  092810.00  215126.00  245.80    573.0   42.5
; ...
;
;NOTE:
;   Do @usrprojinit to include the path to this routine.
;-
;
pro a1963printtimes,datI
;
; print out a listing to terminal
;
SOLAR_TO_SIDEREAL_DAY= 1.00273790935D
;
radhr=12D/!dpi
nsrc=n_elements(datI[*])
    lst=juldaytolmst(datI[*].jd)*radhr &$
    timeAvail =(lst-shift(lst,1))*3600./SOLAR_TO_SIDEREAL_DAY &$
    timeAvail[0]=0. &$
; 
;   compute time needed..
;
    daz=reform((dati.az - shift(dati.az,1))) &$
    daz[0]=0 &$
    dza=reform((dati.za - shift(dati.za,1))) &$
    dza[0]=0 &$
    movAz=abs(daz)/25. * 60. &$
    movZa=abs(dza)/2.5 * 60. &$
    movTm=(movAz > movZa) &$
    intTm=dati.srcTime &$
    timeNeeded=movTm+intTm &$
    timeNeeded[0]=0 &$
    extraTm=timeAvail-timeNeeded &$

    print  &$
    lab=string(format=$
    '("info for :",i6.6," integration time:",f5.0," secs")',$
            datI[0].yymmdd,datI[0].srcTime)
    print,lab
    print  &$
    print,$
"Jd frac     lmst        ra        dec       az    availTm  ExtraTm" &$
;
    for i=0,nsrc-1 do begin &$
    labLst=fisecmidhms3(lst[i]*3600D,/float,/nocol) &$
    labRa =fisecmidhms3(datI[i].rah*3600D,/float,/nocol) &$
    labDec=fisecmidhms3(datI[i].decD*3600D,/float,/nocol) &$
    line=string(format=$ 
        '(f7.5,"  ",a,"  ",a,"  ",a,"  ",f6.1,"   ",f6.1,"  ",f6.1)',$
            (datI[i].jd mod 1D),labLst,labRa,labDec,datI[i].az,$
            timeAvail[i],extraTm[i]) &$
    print,line &$
    endfor &$
    return
end
