;+
;NAME:
;gainget - return telescope gain(az,za,freq) for rcvr.
;
;SYNTAX: stat=gainget(az,za,freq,rcvrNum,gainVal,date=date,zaonly=zaonly)
;
;ARGS:
;      az[n]: float azimuth in degrees
;      za[n]: float zenith angle in degrees
;    freq: float freq in Mhz.
; rcvrNum: int   receiver number 1..16 (see helpdt feeds)) 
;KEYWORDS:
; date[2]: int   [year,daynumber] to use for gain computation. The default
;                is to use the current day. If they gain curves change
;                with time, this allows you to access the gain curve that
;                was in use when the data was taken.
; zaonly:        if set then only return the zenith angle dependence (averages
;                over azimuth)
;RETURNS:
; gainval[n]: float gain in Kelvins/Jy
;    stat: int   -1 --> error, not data returned
;                 0 --> requested outside freq range of fits. Return gain
;                       of the closed frequency value.
;                       the closest value.
;                 1 --> frequency interpolated gain value returned.
;
;DESCRIPTION:
;   Return the gain (K/Jy) for the requested receiver at the specified 
;frequency and az,za. The default is to use the current gain values. The
;date keyword allows you to access a gain curve that was valid at some 
;other epoch.
;
;   Fits have been done for g(az,za) at different frequencies for various
;receivers. This routine will input the fit information and compute the
;gain for the two closest frequencies and then interpolate to the
;requested freqeuncy. The input fit data is stored in a common block so
;the data does not have to be input from disc a second time unless you
;pick a different receiver.
;
;NOTE:
;   Some receivers have no gain fits. They will return -1 in the status.
;If a requested frequency is outside the fitted values, then the value
;at the closest frequency is returned (no extrapolation is done).
;   If you have correlator data, you can use corhgainget() to get the
;gain value. It will figure out the receiver number and date from the
;header and then call gainget. 
;   For a description of the gain calibration see:
;http://www.naic.edu/~phil. Look under calibration for the receiver
;of interest. The lines with the remark (gain curves) were used to compute
;the gain curves.
;
;EXAMPLES:
;   lbw=5
;       get gain at 1400Mhz az=120,za=10 for lbw
;   stat=gainget(120.,10.,1400.,lbw,gainval)
;   az=fltarr(20)               ; az = 0 degrees.
;   za=findgen(20)+1            ; za=1..20
;   date=[2001,200]             ; for 2001, daynumber:200
;   stat=gainget(az,za,1321,lbw,gainval,date=date)
;   gainval will be an array of 20 values for za 1 to 20 degrees and azimuth
;   of 0 degrees.
;   
;   to convert from daynumber to day,month,year
;   daynum=dmtodayno(d,mon,year)
;   dm    =daynotodm(daynum,year)
;   where dm=[day,month]
;
;SEE ALSO:gaininpdata, calinpdata, corhcalval
;-
function gainget,az,za,freq,rcvrNum,gainval,date=date,zaonly=zaonly
;
; return the gain value for this receiver and  freq
; retstat: -1 error, ge 0 ok
;
    forward_function gaininpdata,dmtodayno
    common cmgaindata,gdata
     
    rdfile=(n_elements(gdata) eq 0 )
    if n_elements(date) eq 2 then begin
        year  =date[0]
        dayNum=date[1]
    endif else begin
        a=bin_date()
        year  =a[0]
        dayNum=dmtodayno(a[2],a[1],a[0])
    endelse
    if (not rdfile) then begin
       if  (gdata.rcvNum ne rcvrNum)  or $

           ((gdata.startYr  gt year) or $
            (gdata.endYr    gt year) or $

            ((gdata.startYr eq year) and $
             (gdata.startDaynum gt dayNum)) or $

            ((gdata.endYr eq year) and $
             (gdata.endDaynum le dayNum)) ) then rdfile=1
    endif
    if (rdfile) then begin
        datel=[year,dayNum]
        if  gaininpdata(rcvrNum,gdata,date=datel) lt 1 then return,-1
    endif
;
;   
;
    gotit=0
    eps=1e-4
    ilow= where(((gdata.fiti.freq-eps) le freq),countl)
    if countl gt 0 then ilow=ilow[countl-1]
    ihi = where(((gdata.fiti.freq+eps) ge freq),counth)
    if counth gt 0 then ihi=ihi[0]
    retstat=1           ; ok
    case 1 of 
;
;       ilow < 0 --> reqfreq< minFreq  use ihi[0]
;
      ilow lt 0:begin
                gainval=fitazzaeval(az,za,gdata.fiti[ihi],zaonly=zaonly)
                if abs(gdata.fiti[ihi].freq - freq) gt eps then retstat=0
            end
;
;       ihigh < 0 --> reqfreq > maxFreq use ilow[0]
;
      ihi lt 0:begin
                gainval=fitazzaeval(az,za,gdata.fiti[ilow],zaonly=zaonly)
                if abs(gdata.fiti[ilow].freq - freq) gt eps then retstat=0
               end
;
;       ihigh == ilow  use either 
;
      ihi eq ilow:begin
                gainval=fitazzaeval(az,za,gdata.fiti[ihi],zaonly=zaonly)
                if abs(gdata.fiti[ihi].freq - freq) gt eps then retstat=0
                end
;
;      two freq.. interpolate
;
      else: begin
                gain1=fitazzaeval(az,za,gdata.fiti[ilow],zaonly=zaonly)
                gain2=fitazzaeval(az,za,gdata.fiti[ihi],zaonly=zaonly)
                f1=gdata.fiti[ilow].freq
                f2=gdata.fiti[ihi].freq
                gainval=gain1+ (freq-f1)/(f2-f1)* (gain2-gain1)
            end
    endcase
    return,retstat
end
