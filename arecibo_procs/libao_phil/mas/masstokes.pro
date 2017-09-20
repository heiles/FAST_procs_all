;+
;NAME:
;masstokes - intensity calibrate stokes data.
;
;SYNTAX: istat=masstokes(bdatIn,bcalIn,descDat,descCal,$
;                        bdatOut,bcalOut,
;                        avg=avg,han=han,edgefract=edgefract,
;                        mask=mask,cmpmask=cmpmask, phase=phase
;                        bpc=bpc,fitbpc=fitbpc,smobpc=smobpc,phsmo=phsmo,$
;                        nochk=nochk,mmcor=mmcor,mmret=mmret
;ARGS:
; bdatIn[n]:{}       data to calibrate.
; bcalIn[2]:{}       cal on,off. Should already be averaged to 1 on rec, 
;                     1 off rec.
; descDat  :{}        descriptor for datafile
; descCal  :{}        descriptor for cal file
;                     These are needed to check the ashift pdev 
;                     parameter for the scaling of the data. It is stored
;                     in desc.hsp1.
;
;KEYWORDS:
;        avg:         if set then return the averaged data record
;        han:         if set then hanning smooth the data.
;  edgefract: float   fraction of bandpass on each side to not use during
;                     calibration. default .1
;mask[nchan]:int      if supplied then mask to use when computing things
;                     0--> do not include channel. nchan must match 
;                     number of channels in spectra. 
;cmpmask    :         if set then compute mask from calon/caloff
;                     and ignoring 6% of channels on each edge.
;      phase:         if set then phase calibrate the data
;      bpc: int       1 band pass correct with cal off
;                     2 band pass correct with calon-caloff
;                     3 band pass correct with mean(data)
;                     4 band pass correct with the median(data)
;                     Last two good for time varying measurements:
;                     mapping,flares, etc..
;   fitbpc:  int      fit a polynomial of order fitbpc  to the masked
;                     version of the band pass correction and use the 
;                     polynomial rather than the data for the "interior
;                     portions of the mask (1 portions of the mask excluding
;                     the outside edges where the filter falls off.
;                     This is only used if bpc =1,or 2.
;   smobpc:  int      smooth the bandpass correction by smobpc channels 
;                     It should be an odd number of channels. This is only
;                     valid if bpc =1 or 2.
;   phsmo:   int      number of channels to smooth the sin,cos of the
;                     phase angle before computing the arctan. default 11.
;   nochk:            if set then don't bother to check if these are valid
;                     cal records. Good to use if data from a non standardprg.
;   mmcor:            if set then apply the mueller matrix correction
;                     to the data (if it exists for the receiver)
;mmret[4,4,nbrds]:    if mmcor set and mmret is provided, return the mueller
;                     matrix for this dataset.
;   
;RETURNS:
;bdatOut: {masget} intensity calibrated data spectra
;bcalOut: {masget} intensity calibrated cal spectra
; istat: 1 ok
;      : 0 hiteof 
;      :-1 no cal onoff recs
;      :-2 could not get cal value 
;      :-3 cal,data scans different configs
;      :-4 at least 1 board did not have stokes data
;      :-5 sbc length does not match mask length
;      :-6 illegal bandpass correction requested
;      :-7 desc.ashifts0s1 or ashifts2s3 not equal
;
;DESCRIPTION:
;   masstokes will intensity calibrate (and optionally phase calibrate) 
;stokes data given  data  and a cal on,off. The data is passed in via
;bdatInp. The cal is input vis bcalInp. The cal should already be averaged
;so there is 1 cal on spectra and 1 cal off spectra.
;	The descDat,descCal are the descriptors from masopen() of the data
;and the cal file. They are needed to get the pdev scaling done
;on the data (desc.hsp1).
;
;	On output bdatOut and bcalOut will be in units of Kelvins. 
;The /avg keyword will cause the bdatOut to be averaged to a single
;spectra.
;
;   By default 10% of the bandpass on each edge is not used for the calibration.
;You can increase or decrease this with the edgefract keyword. The mask
;keyword allows you to create a mask for each sbc. The calibration will only
;use the channels within the mask when computing the gain and phase calibration
;factors. You can use this to exclude rfi or spectral lines.
;
;   Bandpass correction can be done with the cal off scan or with the 
;calon-caloff difference spectrum. Since the integration time for the cal is
;usually much less than the data integration time,  you need to do some
;type of averaging to the bandpass so the signal to noise does not increase.
;The program lets you fit an N order polynomial to the bandpass with the
;fitbpc keyword. An alternative would be to use the smobpc= keyword to
;smooth the bandpass. 
;
;   Phase calibration can be included by using the /phase keyword. 
;
;THE PROCESSING:
;
;   Let X and Y be the two polarizations, Px,Py be the total power, and
; MN be the correlation of M and N. cosft is a cosine transmform and cacf
; is a complex acf from YX and XY. Then the raw data is stored as: 
;I (Px*cosft(XX) + Py*cosft(YY))/(Px+Py)
;Q (Px*cosft(XX) - Py*cosft(YY))/(Px+Py)
;U (real(fft(cacf)*Px*Py)/(Px+Py)
;V (-img(fft(cacf)*Px*Py)/(Px+Py)
;(the Q,U,V naming assumes linear polariztion).
;
;   The intensity calibration consists of:
;
;1. Scale all of the spectra by (Px+Py) to get unnormalized data.
;
;2. Compute the average &lt;calon&gt;,&lt;calOff&gt; over the specified channels.
;   The specified channels are determined by:
;   a. The mask from the mask keyword
;   b. Use edgefract to throw out this fraction of channels at each edge.
;   c. Use an edgefraction of .1 (10%)
;
;4. The conversion factor Tcal/(&lt;calOn&gt; - &lt;calOff&gt;) is computed for
;   the two polarizations: scaleXX, scaleYY
;
;5. If band pass correction is done,   multiply 
;    scaleXX=scaleXX/normalized(bandpassXX)
;    scaleYY=scaleYY/normalized(bandpassYY)
;    bandpassXX can be taken from the calon or  calon-caloff. You can
;    smooth the bpc (smobpc=) or you fit a polynomial to it (fitbpc=). If
;    fitting is selected then the channels specified in 3. above are used
;    for the fit.
;    The normalization of the bandpass is also computed over the channels
;    selected in 3. above.
;
;6. For the cals and the data compute
;I = (XX*scaleXX + YY*scaleYY)
;Q = (XX*scaleXX - YY*scaleYY)
;U = U*sqrt(scaleXX*scaleYY)
;V = V*sqrt(scaleXX*scaleYY)
;
;7. The phase correction will do a linear fit to the phase using the
;   channels selected in 3. above.
;
;   When deciding on the mask or edge fraction to use, you should have
;a region where the calon-calOff is relatively flat (no filter rolloff and
;no rfi).
;
;EXAMPLE:
;   Suppose we have the following scans:
;
; 40.42+0.70 210200238     5           on      on 18:02:53  5
; 40.42+0.70 210200239     1     calonoff      on 18:07:56  5
; 40.42+0.70 210200240     1     calonoff     off 18:08:07  5
; 
;To process the first two sets:
; --rew,lun
; --print,masstokes(lun,bdat,bcal); will process the first set
; --print,masstokes(lun,bdat,bcal,/han); will process the 2nd set with hanning
;
;To process the 2nd set directly with an edgefraction=.12:
; --print,masstokes(lun,bdat,bcal,scan=210200238L,edgefract=.12)
;
;To input the data first, interactively create a mask, and then process 
;the data with a mask
; --print,corinpscan(lun,bdatinp,scan=210200238L,/han)
; --print,corgetm(lun,2 ,bcalinp,/han)  ; reads the next two records
; --cormask,bcalinp,mask                ; interactively creates the mask
; --print,masstokes(lun,bdat,bcal,calinp=bcalinp,datinp=bdatinp,mask=mask)
;
;Use the same cal for multiple data scans:
; --print,corgetm(lun,2 ,bcalinp,scan=210200236L/han);
; --print,masstokes(lun,bdat1,bcal1,calinp=bcalinp,scan=210200235L)
; --print,masstokes(lun,bdat2,bcal2,calinp=bcalinp,scan=210200238L)
;
;Do amplitude and phase calibration. Use the cal off for the bandpass
;correction. Use a 3rd order polynomial fit to the cal off for the bandpass
;correction.
; --print,masstokes(lun,bdat,bcal,scan=210200238L,/phase,bpc=1,fitbpc=3)
;The bandpass correction is a bit tricky and depends on what type of
;observations you are doing. The integration time for the off is usually
;a lot less than the on positions so you need to use either the bandpass
;fit or smoothing. It would probably be a good idea to add an option for
;the user to input a bandpass to use for the correction (from an off src
;position).
;
;SEE ALSO:
;WARNING:
; 01dec09 still in progress
;        .. mmcor,mmret do not yet work so don't try them
; 
;-
; history:
;30nov09: stole from corstokes
;
function masstokes,bdatIn,bcalIn,descDat,descCal,bdatOut,bcalOut,$
                   avg=avg,han=han,sl=sl,edgefract=edgefract,$
				   mask=mask,cmpmask=cmpmask,phase=phase,$
				   bpc=bpc,fitbpc=fitbpc,smobpc=smobpc,phsmo=phsmo,$
				   nochk=nochk,mmcor=mmcor,mmret=mmret,dbg=dbg
;    forward_function 
;
;   input the data
;
;    on_error,1
;
;   need to scale the cross spectra up by an extra factor of 
;   two. this is after accounting for jeff's 2*aa,2*bb 
;
	if n_elements(dbg) eq 0 then dbg=0
	crossSclExtra=2.		;
	iicon=0
	iicoff=1
	nchan=bcalIn[0].nchan
    if not keyword_set(bpc) then bpc =0
    if not keyword_set(han)  then han =0
    if not keyword_set(avg)  then avg=0
    if not keyword_set(fitbpc)  then fitbpc=0
    if not keyword_set(smobpc)  then smobpc=0
    if not keyword_set(nochk)  then nochk=0
    if n_elements(phsmo) eq 0 then phsmo=11
    if smobpc le 1 then smobpc=0
    gotmask=keyword_set(mask)
    if n_elements(edgefract) eq 0 then edgefract=.1
    nrecs=n_elements(bdatIn)
	ndump=bdatIn[0].ndump
;
;	if no blanking then this is the fftaccums  we expect
;
	fftAccumStdCal=descCal.hsp1.fftaccum*1.
	fftAccumStdDat=descDat.hsp1.fftaccum*1.
;
; 	jeff Mock computes
;   2*polA
;   2*polb
;   U
;   V
;   for 16 bit data i upshift u,v so it has the same
;   scale as polA,polB. for 32 bit data i don't
;
;	The cal scale factors cntsToKelvins  computed for calPolA,polB
;   compute how these need to be modified for uv, and
;   the data scaling
;   Here is where this is corrected..
;
	ashiftDat=[descDat.hsp1.ashift_s0,$
	           descDat.hsp1.ashift_s1,$
	           descDat.hsp1.ashift_s2,$
	           descDat.hsp1.ashift_s3]
	ashiftCal=[descCal.hsp1.ashift_s0,$
	           descCal.hsp1.ashift_s1,$
	           descCal.hsp1.ashift_s2,$
	           descCal.hsp1.ashift_s3]
	if ((ashiftCal[0] ne ashiftCal[1]) or $
	    (ashiftCal[2] ne ashiftCal[3])) then begin
		print,"descCal.hsp1.ashift_s0/s1 or s2/s3 rnot equal"
		return,-7
	endif
	if ((ashiftDat[0] ne ashiftDat[1]) or $
	    (ashiftDat[2] ne ashiftDat[3])) then begin
		print,"descDat.hsp1.ashift_s0/s1 or s2/s3 rnot equal"
		return,-7
	endif
;
;	correct for  u,v maybe .5 times polA,polB
;   sclCal,sclDat multiply cntsToK  which are based on the
;   cal polA,polB
;
	sclCal=[1.,1.,1.,1.]
	sclDat=[1.,1.,1.,1.]
	dif=ashiftCal[2]-ashiftCal[0]  ; 1--> they are the same
	if (dif ne 1 ) then begin
		sclCal[2]= (2.^( (-dif)+1))
		sclCal[3]= (sclCal[2])
	endif
	dif=ashiftDat[2]-ashiftDat[0]
	if (dif ne 1) then begin
		sclDat[2]=( 2.^( (-dif)+1))
		sclDat[3]=( sclDat[2])
	endif
;
;	now correct for cal upshift different than data upshift
;
	dif=ashiftCal[0] - ashiftDat[0]
	if (dif ne 0) then begin
		sclDat/=(2.^dif)
	endif
;
; 	here's our extra factor of 2..
;
	sclCal[2:3]*=crossSclExtra
	sclDat[2:3]*=crossSclExtra
;
;   make sure we have a cal on off
;
    if nochk eq 0 then begin
    	if n_elements(bcalIn) ne 2 then begin
        	print,'Bcal must contain on and off cal'
        	return,-1
    	endif
		if (bcalIn[0].h.obsmode  ne 'CAL') or $
		   (bcalIn[0].h.scantype ne 'ON') then begin
    		print,'bcalIn[0] not a cal On spectra'
		    return,-1
		endif
		if (bcalIn[1].h.obsmode  ne 'CAL') or $
		   (bcalIn[1].h.scantype ne 'OFF') then begin
    		print,'bcalIn[1] not a cal Off spectra'
		    return,-1
		endif
    endif
;
;---------------------------
;   make sure that all boards are stokes data
;
	if bcalIn[0].nchan ne bdatIn[0].nchan then begin
		print,"calIn and datIn have different number of channels"
		return,-1
	endif
	if (bcalIn[0].npol ne 4) or (bdatIn[0].npol ne 4) then begin
		print,"calIn or datIn not stokes data"
		return,-1
	endif
;
;	do calon, off processing and optionally generate the mask
;
	if (mascalonoff(bcalIn[0],bcalIn[1],calI,edgeFract=edgeFract,mask=mask,$
				cmpmask=cmpmask) ne 0 ) then  begin
		print,"Error getting  cal value"
		return,-2
	endif
	mnchn=calI.npnts
	mind=calI.indused
;
;       average the cal on,off over the masked channels
;
    cntsToKCalA=calI.cntsToK[0]
    cntsToKCalB=calI.cntsToK[1]
	if dbg then begin
	lab=string(format='("-- bm:",i1," mnchn:",i4," cntsToK:",f10.6,1x,f10.6)',$
			bcalin[0].h.beam,mnchn,cntsToKCalA,cntsToKCalB)
 	print,lab
	endif
;---------------------------------------------------------------------------
;   figure out the bandpass correction that they want. options are:
;   1. use caloff or use calon-caloff
;   2. either smooth the selection from 1 (the whole band) or
;      fit a polynomial to it over the currently masked region.
;
    if (bpc gt 0) then begin
        case bpc of
        1: begin        ; cal off 
            bpcxx=bcalIn[1].d[*,0]*1.
            bpcyy=bcalIn[1].d[*,1]*1.
            Kx=mean(bpcxx[mind])
            Ky=mean(bpcyy[mind])
           end
        2: begin        ; cal on-caloff
            bpcxx  =(bcalIn[0].d[*,0] - bcalIn[1].d[*,0])*1.
            bpcyy  =(bcalIn[0].d[*,1] - bcalIn[1].d[*,1])*1.
            Kx=mean(bpcxx[mind])
            Ky=mean(bpcyy[mind])
           end
        3: begin        ;  mean of data
            scl=1./(nrecs*ndump)
			if ndump gt 1 then begin
            	bpcxx=total(reform(bdat.d[*,0,*],nchan,nrecs*ndump),2)*scl
               	bpcyy=total(reform(bdat.d[*,1,*],nchan,nrecs*ndump),2)*scl
			endif else begin
               	bpcxx=total(reform(bdat.d[*,0],nchan,nrecs*ndump),2)*scl
               	bpcyy=total(reform(bdat.d[*,1],nchan,nrecs*ndump),2)*scl
			endelse
            Kx=mean(bpcxx[mind])
            Ky=mean(bpcyy[mind])
           end
        4: begin        ;  median by channel
            scl=.5
			if ndump gt 1 then begin
                bpcxx=medianbychan(reform(bdat.d[*,0,*]*1.,nchan,nrecs*ndump))
                bpcyy=medianbychan(reform(bdat.d[*,1,*]*1.,nchan,nrecs*ndump))
            endif else begin
                bpcxx=medianbychan(reform(bdat.d[*,0]*1.,nchan,nrecs*ndump))
                bpcyy=medianbychan(reform(bdat.d[*,1]*1.,nchan,nrecs*ndump))
            endelse
            Kx=mean(bpcxx[mind])
            Ky=mean(bpcyy[mind])
           end

        else: begin
            print,'err:illegal bpcorrection requested'
            return,-6
           end
         endcase

;       smooth or fit if they requested 
;
        if (fitbpc gt 0) then begin
            x =intarr(nchan)
            x[mind]=1
            if mind[0]       gt 0 then x[0:mind[0]-1]=1
            if mind[mnchn-1] gt 0 then x[mind[mnchn-1]:*]=1
            replaceInd=where(x eq 0,count); the region to replace
            if count gt 0 then begin
                coef=poly_fit(mind,bpcxx[mind],fitbpc,yfit)
                bpcxx[replaceInd]=poly(replaceInd,coef)
                coef=poly_fit(mind,bpcyy[mind],fitbpc,yfit)
                bpcyy[replaceInd]=poly(replaceInd,coef)
            endif
        endif
        if smobpc gt 0 then begin
             if fitbpc gt 0 then begin
                smoind=where(x eq 1,count)
                bpcxx[smoind]=smooth(bpcxx[smoind],smobpc,/edge)
                bpcyy[smoind]=smooth(bpcyy[smoind],smobpc,/edge)
             endif else begin
                bpcxx=smooth(bpcxx,smobpc,/edge)
                bpcyy=smooth(bpcyy,smobpc,/edge)
            endelse
        endif 
    endif else begin
        bpcxx=1.
        bpcyy=1.
        Kx=1.
        Ky=1.
    endelse
;---------------------------------------------------------------------------
;       scale the cal spectra
;  probably need to check the blanking here..
;  problem is that maswinkingcal has already fixed it
;  but regular cal hasn't been fixed.
;      
    scalexx=abs(cntsToKCalA*Kx/bpcxx)
    scaleyy=abs(cntsToKCalB*Ky/bpcyy)
    scalexy=sqrt(scalexx*scaleyy)
	bcalOut=bcalIn
    for j=0,1 do begin
        xs=bcalIn[j].d[*,0]*scalexx*sclCal[0]
        ys=bcalIn[j].d[*,1]*scaleyy*sclCal[1]
        bcalOut[j].d[*,0] =(xs+ys)   ; stokes I
        bcalOut[j].d[*,1]=(xs-ys)   ; stokes Q
        bcalOut[j].d[*,2]= bcalIn[j].d[*,2]*scalexy*sclCal[2]
        bcalOut[j].d[*,3]= bcalIn[j].d[*,3]*scalexy*sclCal[3]
    endfor
; ------------------------------------------------------------
;       now the data .. if bpc then do each record separately
;       since scalexx,scaleyy contains the bandpass
;
;	make sure bdatOut is float
;
	dtype=size(bdatIn.d[0],/type)
	if (dtype ne 4) and (dtype ne 5) then begin
		bdatOut=masmkstruct(bdatIn[0],/float,nelm=nrecs)
		bdatOut.h=bdatIn.h
		bdatOut.st=bdatIn.st
	endif else begin
		bdatOut=bdatIn
	endelse
;
;    correct for any differences in the requested integration times of
;    cal and data
;
	 sclDat1=sclDat*(fftaccumStdDat/fftAccumStdCal)
     if bpc ne 0 then begin
		if ndump gt 1 then begin &$
        	for j=0,nrecs-1 do begin &$
		    	for i=0,ndump-1 do begin &$
;					include any blanking differences
				    scl=(bdatIn[j].blankCorDone)?sclDat1 $
				                                :sclDat1*fftaccumStdDat/bdatIn[j].st[i].fftaccum
              		xs=bdatIn[j].d[*,0,i]*scalexx*scl[0] &$
              		ys=bdatIn[j].d[*,1,i]*scaleyy*scl[1] &$
              		bdatOut[j].d[*,0,i]=(xs+ys) &$
              		bdatOut[j].d[*,1,i]=(xs-ys) &$
              		bdatOut[j].d[*,2,i]= bdatIn[j].d[*,2,i]*scalexy*scl[2] &$
              		bdatOut[j].d[*,3,i]= bdatIn[j].d[*,3,i]*scalexy*scl[3] &$
				endfor &$
		    endfor &$
		endif else begin
           	for j=0,nrecs-1 do begin
				    scl=(bdatIn[j].blankCorDone)?sclDat1 $
				                               :sclDat1*fftaccumStdDat/bdatIn[j].st.fftaccum
             		xs=bdatIn[j].d[*,0]*scalexx*scl[0]
              		ys=bdatIn[j].d[*,1]*scaleyy*scl[1]
              		bdatOut[j].d[*,0]=(xs+ys)
              		bdatOut[j].d[*,1]=(xs-ys)
              		bdatOut[j].d[*,2]= bdatIn[j].d[*,2]*scalexy*scl[2]
              		bdatOut[j].d[*,3]= bdatIn[j].d[*,3]*scalexy*scl[3]
		    endfor
		endelse
		if (dbg) then begin
		lab=string(format=$
'("-- bm:",i1," kx,ky:",f10.6,1x,f10.6," scl4:",4(f4.1,1x))',$
			bcalin[0].h.beam,kx,ky,scl)
		print,lab
		endif
	endif else begin
;
;			no bandpass correction, numbers are just scalers. do all at once
;
		if ndump gt 1 then begin
			for idmp=0,ndump-1 do begin
           	  bdatOut.d[*,0,idmp]= bdatIn.d[*,0,idmp]*(scalexx*sclDat1[0]) + $
           	                  bdatIn.d[*,1,*]*(scaleyy*sclDat1[1])
           	  bdatOut.d[*,1,idmp]= bdatIn.d[*,0,idmp]*(scalexx*sclDat1[0])  - $
           	                  bdatIn.d[*,1,*]*(scaleyy*sclDat1[1])
           	  bdatOut.d[*,2,idmp]= bdatIn.d[*,2,idmp]*scalexy*sclDat1[2]
           	  bdatOut.d[*,3,idmp]= bdatIn.d[*,3,idmp]*scalexy*sclDat1[3]
;			do blanking for this dump  of the row
			  if (not bdatIn[0].blankCordone) then begin
			  	ii=where(bdatIn.st[idmp].fftaccum ne fftaccumStdDat,cnt)
			    if cnt gt 0 then begin
				  for i=0,cnt-1 do begin
				   j=ii[i]
				   bdatOut[j].d[*,*,idmp]*=fftaccumStdDat/$
							bdatIn[j].st[idmp].fftaccum
				  endfor
			    endif
			  endif
			endfor
	    endif else begin
           	bdatOut.d[*,0]= bdatIn.d[*,0]*(scalexx*sclDat1[0]) + $
           	                bdatIn.d[*,1]*(scaleyy*sclDat1[1])
           	bdatOut.d[*,1]= bdatIn.d[*,0]*(scalexx*sclDat1[0]) - $
           	                bdatIn.d[*,1]*(scaleyy*sclDat1[1])
           	bdatOut.d[*,2]= bdatIn.d[*,2]*(scalexy*sclDat1[2])
           	bdatOut.d[*,3]= bdatIn.d[*,3]*(scalexy*sclDat1[3])
			if (not bdatIn[0].blankCorDone) then begin
			  ii=where(bdatIn.st.fftaccum ne fftaccumStdDat,cnt)
			  if cnt gt 0 then begin
				for i=0,cnt-1 do begin
					j=ii[i]
					bdatOut[j].d*=fftaccumStdDat/$
                            bdatIn[j].st.fftaccum
				endfor
			  endif
			endif
		endelse
    endelse
	bdatOut.blankCorDone=1


    if keyword_set(phase) then begin
		bandFlipped=(bdatOut[0].h.cdelt1 lt 0)
        xydif=bcalOut[0].d[*,2]- bcalOut[1].d[*,2]
        yxdif=bcalOut[0].d[*,3]- bcalOut[1].d[*,3]
        if phsmo gt 2 then begin
            delta=atan(smooth(yxdif,phsmo,/edge),smooth(xydif,phsmo,/edge))$
                    *!radeg 
        endif else begin
            delta=atan(yxdif,xydif)*!radeg 
        endelse
        off=0.
        for j=0,nchan-2 do begin &$
            d=delta[j+1]+off-delta[j] &$
            if abs(d) gt 180. then begin &$
                if d gt 0 then begin &$
                    off=off-360. &$
                endif else begin &$
                    off=off+360. &$
                endelse &$
            endif &$
            delta[j+1]=delta[j+1]+off &$
        endfor

;           now linear fit vs freq
;
        freq=masfreq(bcalOut[0].h)
        freq=freq-freq[nchan/2]
        coef=poly_fit(freq[mind],delta[mind],1,yfit=yfit,yerror=yerror)
        ind=where(abs(delta[mind] - yfit) lt (3*yerror),count)
        if (count ne n_elements(yfit)) then begin
            if count eq 0 then begin
                print,'Warning phase fit failed brd:',i
                return,-1
            endif
            coef=poly_fit(freq[mind[ind]],delta[mind[ind]],1,yfit,yerror)
        endif
;            print,coef 
;
;   offset + slope in deg/Mhz
;
        phase=coef[0] + freq*coef[1]
		if dbg then begin
	    	lab=string(format=$
'("-- bm:",i1," phaseCoef::",f12.6,1x,f12.6)',bcalin[0].h.beam,coef)
			print,lab
		endif
        cmpphase=exp(complex(0.,-(!dtor*phase)))
		if ndump eq 1 then begin
        	for j=0,nrecs-1 do begin &$
            	rotated=complex(bdatOut[j].d[*,2],bdatOut[j].d[*,3])*$
                    cmpphase &$
            	bdatOut[j].d[*,2]=float(rotated) &$
           	    bdatOut[j].d[*,3]=imaginary(rotated) &$
        	endfor
		endif else begin
        	for j=0,nrecs-1 do begin &$
				for idmp=0,ndump-1 do begin
            		rotated=complex(bdatOut[j].d[*,2,idmp],$
						bdatOut[j].d[*,3,idmp])*$
                    cmpphase &$
            		bdatOut[j].d[*,2,idmp]=float(rotated) &$
           	    	bdatOut[j].d[*,3,idmp]=imaginary(rotated) &$
				endfor
        	endfor
		endelse
        rotated=complex(bcalOut[0].d[*,2],bcalOut[0].d[*,3])*$
                 cmpphase
        bcalOut[0].d[*,2]=float(rotated)
        bcalOut[0].d[*,3]=imaginary(rotated)
        rotated=complex(bcalOut[1].d[*,2],bcalOut[1].d[*,3])*$
                 cmpphase
        bcalOut[1].d[*,2]=float(rotated)
        bcalOut[1].d[*,3]=imaginary(rotated)
;
;		correct 4th band: E1*E2*sin(delta) in caseband flipped.
;       band flipping negates the phase difference polA,B. This 
;       affects the sin(delta) term only (stokes V if linear). 
		print,"bandFlipped:",bandflipped
		if bandFlipped then begin
			if ndump gt 1 then begin
				bdatOut.d[*,3,*]=-bdatOut.d[*,3,*]
			endif else begin
				bdatOut.d[*,3]=-bdatOut.d[*,3]
			endelse
			bcalOut.d[*,3,*]=-bcalOut.d[*,3,*]
		endif
    endif
            
    if keyword_set(avg) and (n_elements(bdatOut) gt 1) then $ 
 		bdatOut=masmath(bdatOut,/avg)
    if keyword_set(mmcor) then begin
		print,"mmcor mueller correction not yet supported"
;	
;   	rcvnum=bcalOut[0].h.rfnum
;	mjdToJd=2400000.5D
;       file want ast..
;   	astToUtc=4./24.
;	caldat,bdat[0].h.mjdxxobs + mjdToJd - astToUtc,mon,day,year
;	daynum=dmtodayno(day,mon,year)
;      	yyyyday=year*10000L + daynum
;      	mmcor=fltarr(4,4)
;      	if arg_present(mmret) then mmret=fltarr(4,4)
;      	cfr=bdatOut[0].h.crval1*1e-6
;      	istat=mmgetparams(rcvnum,cfr,mmparams,date=yyyyday)
;      	if istat eq -1 then begin
;      		print,'No mueller matrix for rcv,cfr:',rcvnum,cfr
;      	endif else begin
;          ; the correction is the inverse
;          	mm=mmcmpmatrix(mmparams)
;          	mmcor[*,*]=invert(mm)
;          	if n_elements(mmret) ne 0 then mmret[*,*]=mm
;
;       loop over the records
;
;          	for j=0,n_elements(bdatOut)-1 do begin &$
;                 bdatOut[j].d=mmcor[*,*] ## bdatOut[j].d &$
;           endfor
;           for j=0,1 do begin &$
;               bcalOut[j].d=mmcor[*,*] ## bcalOut[j].d &$
;           endfor
;       endelse
    endif
    return,1
end
