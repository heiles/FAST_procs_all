;+
;NAME:
;cormapinp  - input a galfa file as correlator map.
;
;SYNTAX:istat=cormapinp(desc, m,han=han,binp=binp,smo=smo)
;
;ARGS:
;  desc: {}  file descriptor from galopen() that points at the file
;            to use. It will be rewound before inputing.
;KEYWORDS:
;     han:    if set then hanning smooth the data on input.
; binp[n]:{corget} If the data has already been read in, you can pass
;             it into the routine via binp keyword. In this case no
;             hanning smoothing is done
;  smo   :    If the smooth keyword is set, then the frequency channels
;             will be smoothed and then decimated by 7. The 7679 channels 
;             will be reduced to 1097 channels. The header locations that
;             specify the number of frequency channels will also be updated.
;           
;RETURNS:
;   istat:    int  1: got all the strips
;                  0: got part of requested map
;                 -1: got no data.
;m[2,pnts/strip,7]:{} array of structures holding the returned 
;                       data and header. (see below for a description).
;DESCRIPTION:
;   Input a galfa file and load it into a map structure. If the binp=
;keyword is used then you can pass in galfa data that has already been
;read in via corgetm. Normally you would open the file with galopen()
;and then pass in the descriptor. If the file is to be input, desc will
;be rewound before the input.
;
;   This routine differs from the interrim correlator cormapinp in 
; various ways:
;  1. the old routine would read in an entire map. This routine reads in
;     an entire file.
;  2. The galfa files are not necessarily sychronized with the start
;     of a mapping pattern on the telescope. A single strip on the telescope may
;     take more than 1 galfa file or may start in the middle of a galfa file.
;  3. You need to be careful with memory usage. Each file returned
;     is about 300Mb. You need to keep an eye on the computer memory
;     usage with top when processing. Don't make a whole lot of
;     copies of the arrays..
;
;   The map information is returned as an array m of structures. The 
;dimensions of the array are:  
;
;  m[pol,pntsperstrip,npixels].  pol=2
;
;Each element of the array contains the information for a particular 
;polarization,sample, and pixel. The following example is for 
; [0:polA,5:sample,6:beamnum]
; eg:
;
; m[0,5,6].h        the std header for pola, 
; m[0,5,6].hf       the fits header for pola, 
; m[0,5,6].d[7679]  the data   for pola
; m[0,5,6].p        the total power value for this sample (linear scale).
; m[0,5,6].az       the azimuth position in degrees at the endedncenter  of 
;                   each sample.
; m[0,5,6].za       the zenith angle position in degrees at the end of
;                   each sample.
; m[0,5,6].raHr     the RA in hours at the middle of each sample.
; m[0,5,6].decDeg   the declination in degrees at the middle of each sample.
; m[0,5,6].calscl   the cal scale factore (this value is currently not 
;                   loaded.
;
;m.h holds the older header information for this sample. It is mainly
;blank. You should probably use the m.hf header for the info
;
;The sample order is how it is found on disc. There is no reordering of
;the data.
;
;EXAMPLE:
; The standard file is 600 seconds long.
; idl
; @phil
; @galinit
;
; 1. open file and input via cormapinp.
;
; file='/share/galfa/galf.20050623.a2055.0008.fits'
; istat=galopen(file,desc)
; istat=cormapinp(desc,m)
;
; the data would then have:
; m[0,4,3].d[*]      polA sample 4,beam 3
; m[1,4,3].d[*]      polB sample 4,beam 3
;
; the headers would be:
; m[0,4,3].hf        polA header sample 4,beam 3
; m[1,4,3].hf        polB header sample 4,beam 3
;
; 2. open file, input it, and then pass the struct to cormapinp
; file='/share/galfa/galf.20050623.a2055.0008.fits'
; istat=galopen(file,desc)
; istat=corgetm(desc,600,b)
; istat=cormapinp(desc,m,b=b)
;
;
;SEE ALSO:
;
;NOTES: 
; Current status:
; * cormapsclk does not yet work since the cal info is not there.
; * i've tried cormapbc and it seems to work ok.
;
; ---------------------
;modhistory
;23jun05: stole from cormapinp interrim cor and updated for galfa.
;10jul05: added /smo keyword
;14jul05: fixed jdenc computation. was failing 8pm to 12 midnite.
;-
function cormapinp,desc,m,binp=b,han=han,smo=smo
;
; 1. position to scan. read header figure out
;
    forward_function corgetm

;   some flags we fill in later
;
    usebinp=n_elements(b) gt 0
    npixels=7
    if not keyword_set(han) then han=0
    rew,desc
    nrecsreq=desc.totrecs
    if not usebinp then begin
        print,'inputing..'
        istat=corgetm(desc,nrecsreq,b,han=han)
        if istat eq 0 then goto,errread
    endif
    recsfound=n_elements(b)
;
;   allocate struct to hold hdr start each strip then the data
;   c.h           for 1 pol
;   c.d[numlags]  for 1 pol
;
    tosmo=7
    nlagsIn =b[0].b1.h.cor.lagsbcout
    nlagsOut=keyword_set(smo) ? nlagsIn/tosmo : nlagsIn
    c={  $
        h :      b[0].b1.h ,$; 
        hf:      b[0].b1.hf,$; 
        p :              0.,$;
        az:              0.,$;
        za:              0.,$;
        azErrAsec:       0.,$;
        zaErrAsec:       0.,$;
        raHr:            0.,$;
        decDeg:          0.,$;
        calScl:          1.,$;
        d : fltarr(nlagsout,/nozero)}
     m=replicate(c,2,recsfound,npixels)
;
;       compute the ra/dec from the az,za,azza timestamps and the
;       timestamps of the data. interpolate to the center of data each sample
;
;       1. get the pos time stamp in Jd. 
;          - we only have secs ast, need day,
;            just take jd of first data sample, strip off the fraction
;            then add on the fraction of the ast.. this could only
;            fail at noon if the ast time is on the other side of noon from
;            jd. But who in their right mind would start a scan at Noon???
;            4/24. goes to utc, +.5 since jd starts at noon
;        
    print,'interpolating positions'
         jd1=b[0].b1.hf.jd_obs
         jd1=jd1 - (jd1 mod 1D)     ; remove fraction . start of cur jd
         jdEnc = (((b.b1.h.std.postmms*.001D)/86400D + 4./24D + .5D) mod 1D) + $
				jd1
;
;       see if posTm  crossed midnite
;     
        if (jdEnc[recsFound-1] lt jdEnc[0]) then begin
            dif=jdEnc-shift(jdEnc,1)
            ind=where(dif[1:*] lt -.5,count)    ;
            ii=ind[0] + 1               ; since dif[1: ]
            jdEnc[ii:*]=jdEnc[ii:*] + 1D
        endif
;
;   The data starts on a hardware tick, but the time stamps come from
;   ntp. We need to round the time stamps to the closest second and then
;   add .5 secs. hopefully the times stamps are within a second..
;   The data actually starts 5.7344 milliseconds after the hardware tick
;   so add on .00269 secs.
;
    jdData=b.b1.hf.jd_obs + .5D/86400D      ; add 1/2 a sec to round up
    jdData=jdData - ((jdData*86400D) mod 1d)/86400D + .50269D/86400D
;
;   now interpolate the az,za to the data
;   az goes 0 to 720 so there should be no zero crossing problem.
;   
     azData=interpol(b.b1.hf.crval2b,jdenc,jddata)
     zaData=interpol(b.b1.hf.crval3b,jdenc,jddata)
     rotangl=median(b.b1.hf.alfa_ang)
     alfabmpos,azData,zaData,jdData,ra,dec,rotangle=rotangl
;
;   now load up the structure
;
    print,'loading struct'
    for ipix=0,npixels-1 do begin
        m[1,*,ipix].h=m[0,*,ipix].h
        m[0,*,ipix].hf=reform(b.(ipix).hf,1,recsfound)
        m[1,*,ipix].hf=m[0,*,ipix].hf
        m[0,*,ipix].rahr=reform(ra[ipix,*],1,recsfound)
        m[1,*,ipix].rahr=m[0,*,ipix].rahr
        m[0,*,ipix].decDeg=reform(dec[ipix,*],1,recsfound)
        m[1,*,ipix].decDeg=m[0,*,ipix].decDeg
        m[0,*,ipix].az    =reform(azData,1,recsfound)
        m[1,*,ipix].az    =reform(azData,1,recsfound)
        m[0,*,ipix].za    =reform(zaData,1,recsfound)
        m[1,*,ipix].za    =reform(zaData,1,recsfound)
        if keyword_set(smo) then begin
            m[0,*,ipix].d =total($
            reform(b.(ipix).d[*,0],tosmo,nlagsOut,1,recsfound),1)/tosmo
            m[1,*,ipix].d =total($
            reform(b.(ipix).d[*,1],tosmo,nlagsOut,1,recsfound),1)/tosmo
        endif else begin
            m[0,*,ipix].d     =reform(b.(ipix).d[*,0],nlagsOut,1,recsfound)
            m[1,*,ipix].d     =reform(b.(ipix).d[*,1],nlagsOut,1,recsfound)
        endelse
        m[0,*,ipix].p     =reform(total(m[0,*,ipix].d,1)/nlagsOut,1,recsfound)
        m[1,*,ipix].p     =reform(total(m[1,*,ipix].d,1)/nlagsOut,1,recsfound)
    endfor
done:
    if keyword_set(smo) then begin
        m.h.cor.lagsbcout=m.h.cor.lagsbcout/tosmo
        m.hf.cdelt1= m.hf.cdelt1*tosmo
        m.hf.crpix1= long(m.hf.crpix1/tosmo) + 1  ; 
    endif   
    return,1
errread:
    print,'missing records in file..'
    return,0
end
