;+
;NAME: 
; wasalfacmpradec - compute ra/dec for alfa using wasdata
;
;SYNTAX: wasalfacmpradec,b,raHr,decDeg
;  ARGS:
;   b[n] {wasget} - data as returned from corget(). It is ok to use the 
;                   /hdronly keyword to corget() to speed up i/o.
;
; RETURNS:  
;   rahr[7,n]: double ra in hours for the n samples. The first dimension
;                     has the 7 beams 0 thru 6
; decDeg[7,n]: double declination in degrees for the n sampled points. 
;                     The first dimension has the 7 beams 0 thru 6
;DESCRIPTION:
;   Compute the ra,dec J2000 for the alfa beams using the data structures
;read from the fits files via corget, corinpscan,corgetm etc.. To
;compute the ra/dec the routine does the following:
;
;1. Grab the encoder az,za, and encoder timestamps.
;2. Get the daynumber, year from the scan number
;3. compute the julian day timestamp for the az,za timestamps.
;4. search thru each scan looking for midnite crossings. If there is
;   a midnite crossing (ast) then increment the jd for this stretch.
;5. For each scan do the following:
; a. Get the julian dates for the data samples from the header
;   location mjd_obs (converting to jd). Increment these values
;   by (recIntegrationSecs*.5)/86400D to get the time stamps at the center 
;   of each integration.
; b. interpolate the az,za values sampled at encoder time to the 
;    az za at the data sample time.
; c. call alfabmpos,az,za,juldayData to get the ra,dec for the alfa
;   beams for the data positions/times.
;   return these values as the  ra,dec of the beam positions.
;
;   The data is returned as:
; rahr[7,n]
; decDeg[7,n]
;   Where the first index runs over the 7 pixels of alfa. The second index is
;for the data samples.
;
;   It  is ok if the b[] array contains more than one scan. The routine
;searchs for the start of each scan in the b[] array. It is also ok
;to pass in a b[] array that contains only the headers (see corget(),
;corinpscan(), arch_getdata() /hdronly keyword). This can speed up the
;i/o if you are only interested in the positions and not the spectra.
;
;EXAMPLE:
; 1. input a scan and compute the beam positions.
;
;   print,corinpscan(desc,b)
;   wasalfacmpradec,b,rahr,decdeg
; 2.use arch_getalfaradec to input a set of scans
;   yyyymmdd1=20040903
;   yyyymmdd2=20040906
;   projid='a1943'
;   procname='basket'
;   numrecs=60
;   npnts=arch_getalfaradec(yyyymmdd1,yyyymmdd2,raHr,decDeg,projid=projid,$
;              procname=procname,slar=slar,slfilear=slfilear,indar=indar,$
;              /plotit,/verb,/gt12)
;SEE ALSO
;   alfabmpos (in pointing related idl routines).
;   arch_getalfaradec() (in wapp spectral line routines).
;-
;21oct04 - was a bug when ra crossed 24->0. the interpolation would
;          end up giving you 12 hours..
;          To solve the problem, interpolate the az,za from encoder
;          onto jd time and then call alfabmpos with these 
;          values. This should work since the az does not jump at
;          az=360 degrees..(i hope...)
;
pro wasalfacmpradec,b,rahr,decdeg,startRec=startRec
    npnts=n_elements(b)
    az=b.b1.h.std.azttd*.0001
    za=b.b1.h.std.grttd*.0001
    tm=b.b1.h.std.postmms*.001
    scan=b.b1.h.std.scannumber
    daynum=scan/100000L mod 1000L
    yr=scan/100000000L + 2000L
    daynum=tm/86400D + daynum       ; put on the seconds
    jdenc =daynotojul(daynum,yr,gmtoffhr=4D) ;julian day enc
;
;   see if data is start of record or (def center of rec)
    inc=(keyword_set(startRec))?0D:(.5d * b.b1.hf.exp)/86400D
    jdData=b.b1.hf.mjd_obs + 2400000.5D + inc ;julian day data
;
;   find where each scan started
;
    if n_elements(scan) eq 1 then begin
        nscans=1
        ind=0
    endif else begin
        ind=where((scan -shift(scan,1)) ne 0,nscans)
        if nscans eq 0 then begin
            nscans=1
            ind=0
        endif
    endelse
;
;   - find where each scan starts and it's length. Save it for later
;   - see if any scan crosses midnite. If so, fix the daynum
;     for that part of the scan.
;
    iscanSt=lonarr(nscans)
    scanLen=lonarr(nscans)
    i1=0
    raHr  =dblarr(7,npnts)
    decDeg=dblarr(7,npnts)
    for i=0,nscans-1 do begin &$
;
        i2=(i eq (nscans-1))?npnts-1:ind[i+1]-1 ; index end of scan 
        iscanSt[i]=i1
        scanLen[i]=i2-i1+1L
;
;       see if cross midnite in this scan
;
        if nscans gt 1 then begin
        dif=tm[i1:i2]-shift(tm[i1:i2],1) 
        ii=where(dif[1:*] lt -43200L ,count) ; step within scan 
        if count gt 0 then begin 
            ii=ii+1         ; inc since we started dif[1:]
            jdenc[i1+ii[0]:i2]= jdenc[i1+ii[0]:i2] + 1D ;next day..
        endif 
        endif
;
;      The data sample was not necessarily the same time as the
;      encoder sample. Interpolate the az,za unto the data sample
;      time. This is better than interpolating the ra,decs from
;      encoder time to data time since ra has a jump at 24 and the
;      azimuth doesn't
;
        azData=interpol(az[i1:i2],jdenc[i1:i2],jddata[i1:i2])
        zaData=interpol(za[i1:i2],jdenc[i1:i2],jddata[i1:i2])
        rotangl=b[i1].b1.hf.alfa_ang
;        alfabmpos,az[i1:i2],za[i1:i2],jdenc[i1:i2],rahrEnc,decdegEnc ,$
;                        rotangle=rotangl
        alfabmpos,azData,zaData,jdData[i1:i2],ra,dec,rotangle=rotangl
        raHr[*,i1:i2]  =ra
        decDeg[*,i1:i2]=dec
;        ntag=7
;        for j=0,ntag-1 do begin  
;           rahr[j,i1:i2]  =interpol(rahrEnc[j,*],jdenc[i1:i2],jddata[i1:i2])  
;           decdeg[j,i1:i2]=interpol(decdegEnc[j,*],jdenc[i1:i2],jddata[i1:i2]) 
;        endfor
        i1=i2+1 &$
    endfor  
    return
end
