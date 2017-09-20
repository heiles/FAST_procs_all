;+
;NAME:
;sefdget - return telescope sefd(az,za,freq) for rcvr.
;
;SYNTAX: stat=sefdget(az,za,freq,rcvrNum,sefdVal,date=date,zaonly=zaonly)
;
;ARGS:
;      az[n]: float azimuth in degrees
;      za[n]: float zenith angle in degrees
;    freq: float freq in Mhz.
; rcvrNum: int   receiver number 1..16 (see helpdt feeds)) 
;KEYWORDS:
; date[2]: int   [year,daynumber] to use for sefd computation. The default
;                is to use the current day. If they sefd curves change
;                with time, this allows you to access the sefd curve that
;                was in use when the data was taken.
; zaonly:        if set then only return the zenith angle dependence (averages
;                over azimuth)
;RETURNS:
; sefdval[n]: float sefd in Jy
;    stat: int   -1 --> error, not data returned
;                 0 --> requested outside freq range of fits. Return sefd
;                       of the closest frequency value.
;                 1 --> frequency interpolated sefd value returned.
;
;DESCRIPTION:
;   Return the sefd (Jy) for the requested receiver at the specified 
;frequency and az,za. The default is to use the current sefd values. The
;date keyword allows you to access a sefd curve that was valid at some 
;other epoch.
;
;   Fits have been done for sefd(az,za) at different frequencies for various
;receivers. This routine will input the fit information and compute the
;sefd for the two closest frequencies and then interpolate to the
;requested frequency. The input fit data is stored in a common block so
;the data does not have to be input from disc a second time unless you
;pick a different receiver.
;
;NOTE:
;   Some receivers have no sefd fits. They will return -1 in the status.
;If a requested frequency is outside the fitted values, then the value
;at the closest frequency is returned (no extrapolation is done).
;   If you have correlator data, you can use corhsefdget() to get the
;sefd value. It will figure out the receiver number and date from the
;header and then call sefdget. 
;   Some fits only have a za dependance. In these cases just enter 
;arbitrary values for the azimuth (but the parameter is still needed).
;   For a description of the sefd calibration see:
;http://www.naic.edu/~phil --> sefd curves
;
;EXAMPLES:
;   lbw=5
;    get sefd at 1400Mhz az=120,za=10 for lbw
;   stat=sefdget(120.,10.,1400.,lbw,sefdval)
;   az=fltarr(20)               ; az = 0 degrees.
;   za=findgen(20)+1            ; za=1..20
;   date=[2003,200]             ; for 2003, daynumber:200
;   stat=sefdget(az,za,1321,lbw,sefdval,date=date)
;;   sefdval will be an array of 20 values for za 1 to 20 degrees and azimuth
;;   of 0 degrees.
;   
;   to convert from daynumber to day,month,year
;   daynum=dmtodayno(d,mon,year)
;   dm    =daynotodm(daynum,year)
;   where dm=[day,month]
;
;SEE ALSO:sefdinpdata, gainget
;-
function sefdget,az,za,freq,rcvrNum,sefdval,date=date,zaonly=zaonly
;
; return the sefd value for this receiver and  freq
; retstat: -1 error, ge 0 ok
;
    forward_function sefdinpdata,dmtodayno
    common cmsefddata,sefddata
     
    rdfile=(n_elements(sefddata) eq 0 )
    if n_elements(date) eq 2 then begin
        year  =date[0]
        dayNum=date[1]
    endif else begin
        a=bin_date()
        year  =a[0]
        dayNum=dmtodayno(a[2],a[1],a[0])
    endelse
    if (not rdfile) then begin
       if  (sefddata.rcvNum ne rcvrNum)  or $

           ((sefddata.startYr  gt year) or $
            (sefddata.endYr    gt year) or $

            ((sefddata.startYr eq year) and $
             (sefddata.startDaynum gt dayNum)) or $

            ((sefddata.endYr eq year) and $
             (sefddata.endDaynum le dayNum)) ) then rdfile=1
    endif
    if (rdfile) then begin
        datel=[year,dayNum]
        if  sefdinpdata(rcvrNum,sefddata,date=datel) lt 1 then return,-1
    endif
;
;   
;
    gotit=0
    eps=1e-4
    ilow= where(((sefddata.fiti.freq-eps) le freq),countl)
    if countl gt 0 then ilow=ilow[countl-1]
    ihi = where(((sefddata.fiti.freq+eps) ge freq),counth)
    if counth gt 0 then ihi=ihi[0]
    retstat=1           ; ok
    case 1 of 
;
;       ilow < 0 --> reqfreq< minFreq  use ihi[0]
;
      ilow lt 0:begin
                sefdval=fitazzaeval(az,za,sefddata.fiti[ihi],zaonly=zaonly)
                if abs(sefddata.fiti[ihi].freq - freq) gt eps then retstat=0
            end
;
;       ihigh < 0 --> reqfreq > maxFreq use ilow[0]
;
      ihi lt 0:begin
                sefdval=fitazzaeval(az,za,sefddata.fiti[ilow],zaonly=zaonly)
                if abs(sefddata.fiti[ilow].freq - freq) gt eps then retstat=0
               end
;
;       ihigh == ilow  use either 
;
      ihi eq ilow:begin
                sefdval=fitazzaeval(az,za,sefddata.fiti[ihi],zaonly=zaonly)
                if abs(sefddata.fiti[ihi].freq - freq) gt eps then retstat=0
                end
;
;      two freq.. interpolate
;
      else: begin
                sefd1=fitazzaeval(az,za,sefddata.fiti[ilow],zaonly=zaonly)
                sefd2=fitazzaeval(az,za,sefddata.fiti[ihi],zaonly=zaonly)
                f1=sefddata.fiti[ilow].freq
                f2=sefddata.fiti[ihi].freq
                sefdval=sefd1+ (freq-f1)/(f2-f1)* (sefd2-sefd1)
            end
    endcase
    return,retstat
end
