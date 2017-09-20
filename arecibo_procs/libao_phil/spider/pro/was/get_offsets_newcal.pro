pro get_offsets_newcal, scndata, stokesc1,fitInd,hb_arr,$
					b,ibrd,srcName, beamin_arr,$
					stkOffsets_chnl_arr,byChnl=byChnl
;+
;GET THE ANGULAR OFFSETS, SPECTRA, AND SPECTRUM-INTEGRATED POWERS 
;	FOR THE FOUR STRIPS IN ARRAYS OF [*, 4]
;THE UNITS OF ANGULAR OFFSETS ARE ---> NO LONGER <--- THE SPECIFIED HPBW.
;THE UNITS OF ANGULAR OFFSETS ARE ---> ARCMIN <--- .
;--------> THIS IS A BIG CHANGE!!! <------------

;NOTE: at the end, we attempt to generalize to an arbitrary nr of
;strips and points per strip. however, we read these data from 
;our HAND-GENERATED STRUCTURE SCNDATA instead of from the corfile data.
;
;THIS SHOULD BE FIXED, but i don't know the definitions of the corfile
;structure.
;
;		BEWARE!!
;history:
;02dec04 pjp.. modified to get info from .hf part of header for fits files.
;10jan05 pjp.. interpolating az,za to data samples, do it by strip, not
;			   all at once. Moves edge point a little.
;28feb05 pjp.. pass in src name don't use hdrFits
;-

;---GET THE POSITIONS OF EACH DATA POINT ----------------

points_per_strip =  hb_arr[0,fitInd].proc.iar[2]
ncalpts=scndata.ptsforcal
;------------------------------------------------------------------------------
; below is the code using the header values..
; use it when they fix up input_id for polarization mode
;
; croff2,3b are great circle offsets az/za computed as:
; crval2b,3b - cmd_az
; crval2b is the azimuth/za that would cause the paraxial ray to
;     point at the postion this feed is looking at.
;     it includes the interpolation to the start of the data sample
;     and any encoder errors that were measured. 
;     It knows about alfa rotation angle, it does not know about
;     any offsets used to make beam N the cenral beam rather than
;     beam 0 (this is in prfeedaz,za).
;
; cmd_az,za. The requested ra,dec of the source is converted to az,za.
;            It does not include any offsets, rates. It uses the start
;            of the data sample (for lst) when going ra/dec to az,za.
;			 it does not include encoder errors.
;
;
;
;;;azoffset = reform(b[ncalpts:*].(ibrd).hf.croff2b,points_per_strip, 4)
;;;zaoffset = reform(b[ncalpts:*].(ibrd).hf.croff3b,points_per_strip, 4)
;
; move to the center of each data sample 
; use median delta per strip
;
;;;for i=0,3 do begin
;;;	daz=azoffset[*,i]-shift(azoffset[*,i],1)
;;;	daz[0]=daz[1]
;;;	azoffset=azoffset+ median(daz)/2.
;;;	dza=azoffset[*,i]-shift(azoffset[*,i],1)
;;;	dza[0]=dza[1]
;;;	zaoffset=zaoffset+ median(dza)/2.
;;;endfor
;;;if (beamin_arr[fitInd].rcvrn eq 17) and $
;;;	((hdrFits.prfeed_offaz ne 0.D) or (hdrFits.prfeed_offza ne 0.D)) then begin
;;;		azoffset=azoffset+ hdrFits.prfeed_offaz
;;;		zaoffset=zaoffset+ hdrFits.prfeed_offza
;;;endif
;------------------------------------------------------------------------------
; here is the code that uses the source position and the
; encoder az,za values to compute the offsets.
;
;  get source name, precess to j2000 
;
MJD_TO_JD=2400000.5D
; srcName=hdrFits.object
rcvNum=beamin_arr[fitInd].rcvrn
junk=fluxsrc(srcName,1420.,radec=radec)
jprecess,radec[0]*15D,radec[1],raJ,decJ		; goddard, back in degrees !!
;
; get the start epoch julday sampling of data, moved to center of data 
; sample. 
;
integTm=b[ncalpts].b1.hf.exp
JdDataSample=b[ncalpts:*].(ibrd).hf.mjd_obs + MJD_TO_JD + integTm/(2D*86400D)
;
; get azimuths from encoder..
azEnc=beamin_arr[fitInd].azencoders
zaEnc=beamin_arr[fitInd].zaencoders
;
; need encoder time to be jd
encTmAr=b[ncalpts:*].(ibrd).h.std.postmms*.001
nn=n_elements(encTmAr)
scan=b[ncalpts].b1.h.std.scannumber
daynum=scan/100000L mod 1000L
yr=b[ncalpts].b1.h.std.date / 1000L

;;yr=scan/100000000L + 2000L

yrAr=dblarr(nn)+yr
daynumAr=encTmAr/86400D + daynum       ; put on the seconds
dt=(encTmAr - shift(encTmAr,1))        ; dt
dt[0]=1.D							  
ind=where(dt lt 0.,count)
if count gt 0 then daynumAr[ind[0]:*]=daynumAr[ind[0]:*]+1D ; next day
jdenc=daynotojul(daynumAr,yrAr,gmtoffhr=4d) 
;
; 14dec04. don't add 1/2 integration time. the enctime is the sample time.
;
;jdenc=daynotojul(daynumAr,yrAr,gmtoffhr=4d) + integTm/(2d*86400D)
;
; interpolate encoder az,za to  data sample times
;
; 10jan05: interpolate 1 strip at a time.. 
;          prior to this, was interpolating all strips at once.
;          means the edges were probably a little screwed up...
;
	nstrips=n_elements(azEnc)/points_per_strip
	azEnc=reform(azEnc,points_per_strip,nstrips)
	zaEnc=reform(zaEnc,points_per_strip,nstrips)
	jdEnc=reform(jdEnc,points_per_strip,nstrips)
	jdDataSample=reform(jdDataSample,points_per_strip,nstrips)

	for i=0,nstrips-1 do begin &$
		azEnc[*,i]=interpol(azEnc[*,i],jdenc[*,i],jdDataSample[*,i]) &$
		zaEnc[*,i]=interpol(zaEnc[*,i],jdenc[*,i],jdDataSample[*,i]) &$
	endfor
	azEnc=reform(azEnc,nstrips*points_per_strip)
	zaEnc=reform(zaEnc,nstrips*points_per_strip)
	jdenc=reform(jdenc,nstrips*points_per_strip)
	jdDataSample=reform(jdDataSample,nstrips*points_per_strip)
;
;
; 	now get the az,za for the source
;   warning radecjtoazza brings az back 0 to 360.
;
ao_radecjtoazza,rcvNum,raJ/15D + dblarr(nn),decJ + dblarr(nn),jdDataSample,$
		azSrc,zaSrc
;
; 	catch azSrc going 359 to 0.
;
azstp=azsrc-shift(azsrc,1)
azstp[0]=0.
ind=where(azstp lt -100.,count)
if count gt 0 then azSrc[ind[0]:*]=azSrc[ind[0]:*] + 360D
azoffset=(azEnc - azSrc ) 	; great circle
;
; now check az src , azenc differ by 360
;
ind=where(azoffset gt 180.,count)
if count gt 0 then azoffset[ind]=azoffset[ind] - 360D
ind=where(azoffset lt -180.,count)
if count gt 0 then azoffset[ind]=azoffset[ind] + 360D
azoffset=azoffset*sin(zaEnc*!dtor) 	; great circle
zaoffset=(zaEnc - zaSrc )
;
; if alfa, add on the beam offset and rotation angle
; we've offset az,za encoder so rotated feed pixN is centered
; 
;
if rcvNum eq 17 then begin
	alfabmpos,0.,0.,0.,junk,junk,rotangle=b[ncalpts].(ibrd).hf.alfa_ang,$
		hornoffsets=hornoffsets,/offsetsonly
;
;	 HornOffset takes beam 0 to beamN thats what we want since
;    offsets are about beamn not beam0
;
	ii=(ibrd gt 6)?6:ibrd
	azoffset=azoffset + hornoffsets[0,ii]
	zaoffset=zaoffset + hornoffsets[1,ii]
;
; 	--> this is not needed
; 	now need to deal with centering a different beam at the center
;
;	if ((hdrFits.prfeed_offaz ne 0.D) or (hdrFits.prfeed_offza ne 0.D)) $
;		then begin
;      	azoffset=azoffset  + hdrFits.prfeed_offaz
;    	 zaoffset=zaoffset + hdrFits.prfeed_offza
;	endif
endif
;
;------------------------------------------------------------------------------
; 
totoffset = fltarr( points_per_strip, 4)
azoffset=reform(azoffset,points_per_strip,4)
zaoffset=reform(zaoffset,points_per_strip,4)
;

totoffset[ *,0] = azoffset[*,0]
totoffset[ *,1] = zaoffset[*,1]
totoffset[ *,2:3] = sqrt( azoffset[ *,2:3]^2 + zaoffset[ *,2:3]^2)

temp_tot = totoffset[*,2:3]
temp_az = azoffset[*,2:3]
indx = where( temp_az lt 0.,count)
if count gt 0 then temp_tot[ indx] = temp_tot[ indx] * (-1.)
totoffset[ *,2:3] = temp_tot


;CONVERT ALL ANGLES FROM DEGREES TO ARCMIN...
azoffset = 60.* azoffset
zaoffset = 60.* zaoffset
totoffset = 60.* totoffset

;INSERT AZOFFSET, ZAOFFSET, TOTOFFSET INTO THE BEAMIN STRUCTURE...
; CONVERTING TO UNITS OF ARCMIN.
beamin_arr[fitInd].azoffsets= azoffset
beamin_arr[fitInd].zaoffsets= zaoffset
beamin_arr[fitInd].totoffsets= totoffset

;

;------------GET THE STOKES SPECTRA OF EACH DATA POINT ----------------

nchnls= scndata.nchnls
nrpts= points_per_strip
nrstrips= scndata.nrstrips
nrcal= scndata.ptsforcal
;
; 	move the cal spectra over
;
	beamin_arr[fitInd].stkoffsets_chnl_cal= stokesc1[*,*,0:1]

;	compute the total power 

	ngainchnls=n_elements(scndata.gainchnls)
	beamin_arr[fitInd].stkoffsets_cont=$
		total(reform(stokesc1[scndata.gainchnls,*, nrcal:*],ngainchnls,$
				4,nrpts,nrstrips), 1)/ ngainchnls
	if keyword_set(byChnl) then begin
		stkoffsets_chnl_arr[*,*,*,*,fitInd]=$
						reform(stokesc1[*,*,nrcal:*],nchnls,4,nrpts,nrstrips)
	endif


return
end

