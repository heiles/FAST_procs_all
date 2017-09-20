;+
;NAME:
;agcazzadif - compute az,za offsets from agc data.
;
;SYNTAX: stat=agcazzadif(rcvnum,raJ,decJ,agcDat,stSec,stDay,stYear,tmStepSec,
;                        npts, azdif,zadif)
;ARGS:
;   rcvnum  :int      reciever number
;   raJ     :double   J2000 ra in hours
;   decJ    :double   J2000 dec in hours
;
;agcDat[4,n]:fltarr   holds tmsecs,azPos,grPos,chPos in degrees
;     stYear: long    year for starting time to use
;   stdayNum: long    daynumber of year for starting time to use
;      stSec: double  start sec
;  tmStepSec: double  time step we want 
;       npts: long    number of points to compute
;KEYWORDS:
; raDecPacked: if set the ra is hhmmss.s and dec is ddmmss.s
;
;RETURNS:
;   azdif[npts]:double offset in azimuth (great circle arc minutes)
;   zadif[npts]:double offset in za (great circle arc minutes)
;   stat       : int   1 ok, 0 no data
;
;DESCRIPTION:
;   When doing on the fly mapping, the telescope is moving rapidly while the
;correlator, ri is recording the data. The pointing system can be requested
;to log the az,za positions in a file at a 25 hz rate. This routine will
;then compute the actual great circle az,za offset of the correlator 
;sampled data from the center of the map. To do this the user must input:
;
;1. The center of the map in ra,dec J2000.. raJ, decJ.
;2. The 25 hz sampled pointing data ... agcDat.
;3. The start time of each correlator dump. You enter the 
;   starting year,dayno, astSecond of the scan: stYear,stDay,stSec
;   as well as the integration time for each record (solar secs): tmStepSec
;   Finaly you must enter the number of records: npts.
;
;The routine converts raJ,decJ to az,za for the center of each integration
;using ao_radecjtoazza. It then interpolates the measured az,za positions
;to these times and computes the az,za differences.
;
;   Each sample of the 25Hz agc data is stored as 4 longs:
;   agc.tm  long milliseconds from midnite (AST)
;   agc.az  long azimuth position in degrees  *10000 (dome side)
;   agc.gr  long za position of dome in degrees  *10000
;   agc.ch  long za position of ch in degrees  *10000
;
;   To input all the data of a file:
;       filename='/share/obs1/pnt/pos/dlogPos.1' 
;       openr,lun,filename,/get_lun
;       fstat=fstat(lun)
;       numSamples=fstat.size/(4*4)
;   allocate array to hold all the data
;       inparr=lonarr(4,numSamples)
;   read the data
;       readu,lun,inparr
;       free_lun,lun
;   convert to seconds and  degrees.
;       datArr=fltarr(4,numSamples)
;       datArr[0,*]= inpArr[0,*]*.001   ; millisecs to secs
;       datArr[1,*]= inpArr[1,*]*.0001  ; az data to deg
;       datArr[2,*]= inpArr[2,*]*.0001  ; gr data to deg
;       datArr[3,*]= inpArr[3,*]*.0001  ; ch data to deg
;
;SEE ALSO: ao_radecjtoazza
;
;NOTE:
;   The data in agcDat is stored with only a secsFrom midnite timestamp.
;The first entry in agcDat should be the same day as stDay. If that
;is true,then it is ok to cross midnite.
;-
; history:
;23nov02: started
;
function agcazzadif,rcvnum,raJ,decJ,agcDat,stSec,stDay,stYear,tmStepSec,npts,$
               azDif,zaDif,raDecPacked=raDecPacked,inptmsecs=inptmsecs
;
;   get the julian dates for the time samples
;
    ddtor=!dpi/180.D
    if n_elements(inptmsecs) gt 0 then begin
        locnpts=n_elements(inptmsecs)
        tmSecs=inptmsecs*1.D
    endif else begin
        locnpts=npts
        tmSecs  = (dindgen(npts)+.5D)*tmStepSec + stSec
    endelse
    yearAr  = long(stYear) + dblarr(locnpts) 
    dayNoAr = long(stDay)  + tmSecs/86400.D
    julDayAr= daynotojul(daynoar,yearAr) + 4.D/24.D  ; arecibo offset from gmt 
;
;   compute az,za for source position
;
    if keyword_set(raDecPacked) then begin
        raAr =dblarr(locnpts) + hms1_rad(raJ)/(2.D*!dpi)*24.D
        decAr=dblarr(locnpts) + dms1_rad(decJ)*!radeg
    endif else begin
        raAr =dblarr(locnpts) + raJ
        decAr=dblarr(locnpts) + decJ
    endelse
    ao_radecjtoazza,rcvnum,raAr,decAr,juldayAr,azSrcAr,zaSrcAr
;
;   interpolate the measured az,za to the data sample times
;   check if we cross midnite
;
    tm=agcdat.tm
    ind=where(tm ge stSec,count)
    if count eq 0 then goto,nodata
    i0=ind[0]
    ind=where(tm[i0:*] lt tm[i0],count)
    if count gt 0 then begin
        tm[ind+i0]=tm[ind + i0]+86400.
    endif
;
;   be careful interpolating across 360,0..
;   looks like agcdat is 0 to 720.

    azpos=interpol(agcdat.az,tm,tmSecs)
    zapos=interpol(agcdat.za,tm,tmSecs)
;
; now compute the az,za great circle offset for each sample
;
    zadif=  (zapos  - zaSrcAr)*60.D
    azDif=  (azpos  - azSrcAr)
    ind=where(azDif gt 180.D,count)
    if count gt 0 then azDif[ind]=azDif[ind]-360.D
    ind=where(azDif lt  -180.D,count)
    if count gt 0 then azDif[ind]=azDif[ind]+360.D
    azDif=azDif*sin(zaSrcAr*ddtor)*60.D
    return,1
nodata: 
    print,'no agc data for requested times'
    return,0
end
