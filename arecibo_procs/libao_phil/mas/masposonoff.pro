;+
;NAME:
;masposonoff - process a position switch scan
;SYNTAX: istat=masposonoff(flist,b,bonrecs,boffrecs,sclcal=sclcal,
;                  sclJy=sclJy,median=median,double=double,smooff=smooff,$
;                  sclmask=sclmask,calI=calI,edgefract=edgefract)
;ARGS  :
;  flist[4,n]:  string filenames for on,off,calon,caloff
;KEYWORDS:
;       sclcal: if not zero then scale to kelvins using the cal on/off
;               that follows the scan
;       scljy:  if set then convert the on/off-1 spectra to Janskies. 
;               It first scales to kelvins using the cals and then applies
;               the gain curve.
;    han    :   if set then hanning smooth the data. not yet supported..
;    median :   if set then median filter rather than average
;               the poson,posoff,calon,caloff records.
;    double :   if set then return doubles. default is float.
;    smooff :   if supplied then smooth the off by this number of channels
;               before dividing. 
;               -1,0,1 no smoothing
;               > 1 smooth by averaging
;               < -1 median fitler by this many channels.
;               dividing.
;    sclmask:int used when computing scale factor that average frequency.  
;               These averages include:
;                avg(tcal[freq]),avg(calOn[freq]-caloff[freq]) and
;                    1./avg(posOff[freq])
;                0 - (default)
;                    linear fit to calon/caloff then all points 3 sigma from
;                    the fit are flagged as bad. These points will
;                    not be included in the averages.
;                1 - Use sclmask=0 (calon/caloff) plus check the posOn,posOff
;                    data.
;                    :compute rms/mean along each channel for the posOn
;                     and posoff datasets then avgerage the two rms's.
;                    :robust linear fit to rms throwing out freq channels
;                     of more than 3 sigma.
;               2 -  exclude 6% of channels on each side of the bandpass.
;                    All other channels are used for the averages.
;               The result of sclMask is returned in calI.indused. These are the
;               indices into the freq array that were used for the averages.
; edgefrac[2]:float  fraction of edge on each side to exclude when 
;                    computing cal scaling.-1 median fitler by this many channels.
;RETURNS:
;       istat  int   1: completed ok.
;                    0: did not complete
;                   -1: error...
;         b:    {masget} return (on-off)/off * X here..  
;                   hX is: 
;                   sclCal true : (kelvins/mascnt)/<off>.. units are then K
;                   sclcal false: off                   .. units are TsysOff
;     bonrecs[]  {masget} return individual on records. This is an 
;                   optional argument. The units will be K (if /sclcal),
;                   Jy if /sclJy, else masdevice units.
;     boffrecs[] {masget} return individual off records. This is an 
;                   optional argument. The units will be K (if /sclcal),
;                   Jy if /sclJy, else masdevice units.
;  keywords that return info:
;     calI[]    {calI} return cal info. see mascalonoff..
;DESCRIPTION:
;   Process a position switch on,off pair. Return a single spectrum
;per pol of  (posOn-posOff)/posOff. The units will be:
; Kelvins  if /sclcal is set
; Janskies if /scljy  is set . 
; TsysUnits if none of the above is set.
;
;   The header will be that from the first record of the on with the
;following b.h.azimuth, b.h.elevatio set to the average for the on scan
;
;   If bonrecs is specified then the individual on records will also
;be returned. If boffrecs is specified then the individual off records 
;will be returned. The units for these spectra will be  Kelvins 
;if /sclcal, Jy if /scljy is set or masdevice  units (linear in power).
;
;structures:
;   b - holds the spectral data and headers:
;
;   calI: A structure holding info on the cal,caloff
;       calI.CALVAL[2] :  Cal values used for polA,polB
;       calI.exposure  :  integration time that cntstok corresponds to.
;       calI.NUMPOL    :  number of pols. normally 2. 1--> stokes I
;       calI.CNTSTOK[2]:  Conversion factors masDevice cnts to Kelvins
;                         For pola, polB.
;       calI.npnts     :  number of points in spectra used for averaging.
;       calI.flipped   :  1 normal, -1 spectra was flipped
;       calI. EDGEFRACT[2]:  edgeFract[0,1] excluded
;       calI.USEMASK   :  1--> use mask, 0--> use edge fraction to throw 
;                         out outliers.
;       calI.INDUSED[calI.npnts]: indices into spectra used to compute

;   
;NOTES:
; 1. If the individual records are returned and /sclJy is returned then
;    the values will be the SEFD (system equivalent flux density). 
;    No bandpass correction is done on these individual records.
;    values for the ons,offs with be Tsys/gain.
; 2. There is a difference between < on/off - 1> and
;        <on>/<off> namely the bandpass shape .. let f be the bandpass shape:
;        then < f*on/(f*off) -1> does not have the bandpass
;        but   <f*on>/<f*off> does  the basic problem is that
;        <a>/<b> is not equal to <a/b>
; 3. If the acquired band is larger than the bandwidth of the receiver
;    ( eg: 800 Mhz rcvr is about 100 Mhz, and you might use a 172 Mhz
;        band to measure it)
;     then you should use the edg=keyword to limit the computation to the
;     part of the band that has signal.
;     example: suppose there are 8192 channels.
;     masplot,b,/chn
;     look at where the band rises and falls. Suppose it rises at channel
;         1800 and falls at channel 6800.. then
;     edge=[1800,8192.-6800]/8192 
;
;   
;-
;modhistory
;14oct09 - stole from corposonoff
;
function masposonoff,fileAr,b,bonrecs,boffrecs,sclcal=sclcal,$
                      scljy=scljy,median=median,double=double,calI=calI,$
                     _extra=e,sclmask=sclmask,edgefract=edgefract,smooff=smooff
;
;
;   
;    on_error,2

    if n_elements(filear) ne 4 then begin
        print,'file Array needs 4 files: on,off, calon,caloff'
        return,-1
    endif
    if not keyword_set(sclcal)  then sclcal=0
;
;   gain curve needs to scale to kelvins first
;
    if not keyword_set(scljy)   then scljy=0
    floatL=1
    doubleL=0 
    if (keyword_set(double)) then begin
        doubleL=1
        floatL=0
    endif
    if keyword_set(scljy)       then sclcal=1
    sclMaskl=((n_elements(sclMask) eq 0) or (~ sclCal))?0:sclMask
    if sclMaskl gt 1 then sclMaskl=2
    if not keyword_set(han)     then han=0
    retonrecs = 0
    retoffrecs= 0
    if (n_params() ge 3) then retonrecs=1 
    if (n_params() ge 4) then retoffrecs=1
    useOnRecs=retOnRecs
    useOffRecs=retOffRecs
    if (keyword_set(median) or (sclMaskl eq 1)) then begin
        useOnrecs=1
        useOffrecs=1
    endif
    useRecs=[useOnRecs,useOffRecs,0,0]
    lobs =["ONOFF","ONOFF","CAL","CAL"]
    ltype=["ON","OFF","ON","OFF"]
;
;   get on 
;
    ifile=0
    if useOnRecs  then begin
        if (masgetfile(junk,bonrecs,filename=fileAr[ifile],/blankcor,float=floatL,double=doubleL) ne 1) then $
                goto,errInp
		azAvg=mean(bonrecs.h.azimuth) 
		zaAvg=90.-mean(bonrecs.h.elevatio) 
        bon=masmath(bonrecs,/avg,med=median,double=doubleL)
        if sclMaskl eq 1 then brmsOn=masrms(bonrecs)
        if not retOnRecs then bonrecs=''
    endif else begin
        if (masgetfile(desc,bon,/avg,filename=fileAr[ifile],/blankcor,$
			float=floatL,double=doubleL,azavg=azavg,zaavg=zaavg) ne 1) then $
            goto,errInp
    endelse
    if ((bon.h.obsmode ne lobs[ifile]) or $
        (bon.h.scantype ne ltype[ifile])) then begin
            print,"OnFile, obsmode,scantype wrong:",$
            bon.h.obsmode,bon.h.scantype
            return,0
    endif
;
;   get off 
;
    ifile=1
    if useOffRecs then begin
        if (masgetfile(junk,boffrecs,filename=fileAr[ifile],/blankCor,float=floatL,double=doubleL) ne 1) then $
                goto,errInp
        boff=masmath(boffrecs,/avg,med=median,double=doubleL)
        if sclMaskl eq 1 then brmsOff=masrms(boffrecs)
        if not retOffRecs then boffrecs=''
    endif else begin
        if (masgetfile(desc,boff,/avg,filename=fileAr[ifile],/blankcor,float=floatL,double=doubleL) ne 1) then $
             goto,errInp
    endelse
    if ((boff.h.obsmode ne lobs[ifile]) or $
        (boff.h.scantype ne ltype[ifile])) then begin
            print,"OffFile, obsmode,scantype wrong:",$
            boff.h.obsmodeobs,boff.h.scantype
            return,0
    endif
;
; cal on
;
    ifile=2
    if (masgetfile(desc,boncal,/avg,median=median,double=doubleL,$
            filename=fileAr[ifile],/blankcor) ne 1)$
             then goto,errInp
    if ((boncal.h.obsmode ne lobs[ifile]) or $
        (boncal.h.scantype ne ltype[ifile])) then begin
            print,"OnCalFile, obsmode,scantype wrong:",$
            boncal.h.obsmodeobs,boncal.h.scantype
            return,0
    endif
;
; cal off
;
    ifile=3
    if (masgetfile(desc,boffcal,/avg,median=median,double=doubleL,$
            filename=fileAr[ifile],/blankcor) ne 1) then goto,errInp
    if ((boffcal.h.obsmode ne lobs[ifile]) or $
        (boffcal.h.scantype ne ltype[ifile])) then begin
            print,"OffCalFile, obsmode,scantype wrong:",$
            boffcal.h.obsmodeobs,boffcal.h.scantype
            return,0
    endif
;
;   start the processing
;
;
    npol =bon.npol
    nchan=bon.nchan
	if n_elements(smooff) gt 0 then begin
		if smooff lt -1 then begin
			for  i=0,boff.npol-1 do begin
				boff.d[*,i]=median(boff.d[*,i],abs(smooff))
			endfor
		endif
	    if (smooff gt 1 ) then begin
			for  i=0,boff.npol-1 do begin
				boff.d[*,i]=smooth(boff.d[*,i],smooff,/edge_trunc)
			endfor
		endif
	endif
    b=masmath(bon,boff,/div,double=doubleL)
	b.h.azimuth=azavg
	b.h.elevatio=90. - zaavg
    b.d-=1.
    gainVal=1.

;   compute cal scale factors.
;     sclMask=0 fits the calOn/calOff across the bandpass
;     sclMask=1 rms of posOn,posOff plus calon/caloff
;
    if  sclCal  then begin
        cmpMask=(sclmaskL le 1)
;
;       compute mask from posOn,posOff , calOn,calOff will be done
;          in mascalonoff.
;
        if sclMaskL eq 1 then begin
            if (npol eq 1) then begin   
                d=(brmsOn.d + brmsOff.d) ; combine rms of pols
            endif else begin
                d=(brmsOn.d[*,0] + brmsOn.d[*,1]) + $
                  (brmsOff.d[*,0] + brmsoff.d[*,1])
            endelse
            x=findgen(nchan)/nchan
            maskOk=intarr(nchan)+1
            deg=1
;           fit rms
            coef=robfit_poly(x,d,deg,bindx=bindx,nbad=nbad)
            if nbad gt 0 then maskOk[bindx]=0 &$
        endif
;
        if mascalonoff(boncal,boffcal,calI,edgefract=edgefract,cmpmask=cmpMask,mask=maskOk) ne 0 then begin
            print,'mascalonoff:error processing cal on,off'
            goto,errinp
        endif
        code=2    ; for position switching
        istat=mascalscl(b,calI,code,b,bpc=boff)
	    if (keyword_set(sclJy)) then begin
			istat=masgainget(bon[0].h,gainVal)
			if istat lt 0 then begin
				print,$
"no gain curves for this receiver. remove sclJy keyword"
				return,-1
			endif
			b.d/=gainval
		endif
        for ipol=0,1 do begin
            ndump=bon[0].ndump
            sclPol=(sclJy)?calI.cntsToK[ipol]/gainVal:calI.cntsToK[ipol]
            if (ndump gt 1) then begin
                if (retonrecs) then begin 
                    bonrecs.d[*,ipol,*]*=sclPol
                endif
                if (retoffrecs) then begin 
                    boffrecs.d[*,ipol,*]*=sclPol
                endif
            endif else begin
                if (retonrecs) then begin 
                    bonrecs.d[*,ipol]*=sclPol 
                endif
                if (retoffrecs) then begin 
                    boffrecs.d[*,ipol]*=sclPol 
                endif
            endelse
        endfor
    endif
    return,1
errinp:
    print,"Error inputing file:",ifile," ",fileAr[ifile]
    return,0
end
