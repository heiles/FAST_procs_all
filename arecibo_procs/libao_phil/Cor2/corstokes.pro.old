;+
;NAME:
;corstokes - input and intensity calibrate stokes data.
;
;SYNTAX: istat=corstokes(lun,bdat,bcal,scan=scan,calscan=calscan,$
;                        calinp=calinp,datinp=datinp,avg=avg,maxrecs=maxrecs,$
;                        han=han,sl=sl,edgefract=edgefract,mask=mask,phase=phase
;                        bpc=bpc,fitbpc=fitbpc,smobpc=smobpc,phsmo=phsmo,$
;                        nochk=nochk
;ARGS:
;   lun     : int      file descriptor to read from
;
;KEYWORDS:
;   scan    : long    scan number for data. default is current position
;   calscan : long    scan number for cal on scan. def: scan following 
;  calinp[2]:{corget} pass in the caldata rather than read it from lun
;  datinp[n]:{corget} pass in the data rather than read it from lun
;        avg:         if set then return the averaged source record
;    maxrecs: long    maximum number of recs to read in. default is 300.
;        han:         if set then hanning smooth the data.
;       sl[]: {sl}    array used to do direct access to scan.
;  edgefract: float   fraction of bandpass on each side to not use during
;                     calibration. default .1
;       mask:{cormask} mask structure created for each brd via cormask routine
;                      Note: if mask.b1[1024,2] has two masks per board,
;                            this routine uses the first mask for all sbc.
;      phase:         if set then phase calibrate the data
;      bpc: int       1 band pass correct with cal off
;                     2 band pass correct with calon-caloff
;   fitbpc:  int      fit a polynomial of order fitbpc  to the masked
;                     version of the band pass correction and use the 
;                     polynomial rather than the data for the "interior
;                     portions of the mask (0 portions of the mask excluding
;                     the outside edges where the filter falls off.
;                     This is only used if bpc =1,or 2.
;   smobpc:  int      smooth the bandpass correction by smobpc channels 
;                     It should be an odd number of channels. This is only
;                     valid if bpc =1 or 2.
;   phsmo:   int      number of channels to smooth the sin,cos of the
;                     phase angle before computing the arctan. default 11.
;   nochk:            if set then don't bother to check if these are valid
;                     cal records. Good to use if data from a non standardprg.
;   
;RETURNS:
;  bdat: {corget} intensity calibrated data spectra
;  bcal: {corget} intensity calibrated cal spectra
; istat: 1 ok
;      : 0 hiteof 
;      :-1 no cal onoff recs
;      :-2 could not get cal value 
;      :-3 cal,data scans different configs
;      :-4 at least 1 board did not have stokes data
;      :-5 sbc length does not match mask length
;      :-6 illegal bandpass correction requested
;
;DESCRIPTION:
;   corstokes will intensity calibrate (and optionally phase calibrate) 
;stokes data given a data scan and cal on,off scans. The data can be read
;from disc or input directly to this routine. On output bdat and bcal will be
;in units of Kelvins. The /avg keyword will return the average of the
;records in the scan after calibration.
;
;   If the data is input from disc then lun should be the file descriptor
;from the open command. By default it will start reading the data scan from
;the current file position. The scan=scan keyword lets you position to the 
;data scan before reading. By default the calscans will be the two scans
;following the data scan. The calscan=calscan keyword lets you position
;to the cal on scan before reading them.  If the scans on disc have more than
;300 records you need to use the maxrecs= keywords so the entire scan will
;be input.
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
;   You can pass in the data and/or calscans directly by using the 
;datinp, calinp keywords. 
;
;THE PROCESSING:
;
;   Let X and Y be the two polarizations, Px,Py be the total power, and
; MN be the correlation of M and N. cosft is a cosine transmform and cacf
; is a complex acf from YX and XY. Then the raw data is stored as: 
;sbc1: I (Px*cosft(XX) + Py*cosft(YY))/(Px+Py)
;sbc2: Q (Px*cosft(XX) - Py*cosft(YY))/(Px+Py)
;sbc3: U (real(fft(cacf)*Px*Py)/(Px+Py)
;sbc4: V (-img(fft(cacf)*Px*Py)/(Px+Py)
;(the Q,U,V naming assumes linear polariztion).
;
;   The intensity calibration consists of:
;
;1. Scale all of the spectra by (Px+Py) to get unnormalized data.
;
;2. Convert, I,Q back into XX,YY spectra
;   XX=(I+Q)*.5,YY=(I-Q)*.5
;
;3. Compute the average &lt;calon&gt;,&lt;calOff&gt; over the specified channels.
;   The specified channels are determined by:
;   a. The mask for each board from the mask keyword
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
;   sbc1:I = (XX*scaleXX + YY*scaleYY)
;   sbc2:Q = (XX*scaleXX - YY*scaleYY)
;   sbc3:U = U*scaleXX*scaleYY
;   sbc4:V = V*scaleXX*scaleYY
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
;corlist,lun
;    SOURCE       SCAN   GRPS    PROCEDURE     STEP  LST   RCV
;  B1641+173 210200235     5           on      on 17:42:08  5
;  B1641+173 210200236     1     calonoff      on 17:47:10  5
;  B1641+173 210200237     1     calonoff     off 17:47:21  5
; 40.42+0.70 210200238     5           on      on 18:02:53  5
; 40.42+0.70 210200239     1     calonoff      on 18:07:56  5
; 40.42+0.70 210200240     1     calonoff     off 18:08:07  5
; 
;To process the first two sets:
; --rew,lun
; --print,corstokes(lun,bdat,bcal); will process the first set
; --print,corstokes(lun,bdat,bcal,/han); will process the 2nd set with hanning
;
;To process the 2nd set directly with an edgefraction=.12:
; --print,corstokes(lun,bdat,bcal,scan=210200238L,edgefract=.12)
;
;To input the data first, interactively create a mask, and then process 
;the data with a mask
; --print,corinpscan(lun,bdatinp,scan=210200238L,/han)
; --print,corgetm(lun,2 ,bcalinp,/han)  ; reads the next two records
; --cormask,bcalinp,mask                ; interactively creates the mask
; --print,corstokes(lun,bdat,bcal,calinp=bcalinp,datinp=bdatinp,mask=mask)
;
;Use the same cal for multiple data scans:
; --print,corgetm(lun,2 ,bcalinp,scan=210200236L/han);
; --print,corstokes(lun,bdat1,bcal1,calinp=bcalinp,scan=210200235L)
; --print,corstokes(lun,bdat2,bcal2,calinp=bcalinp,scan=210200238L)
;
;Do amplitude and phase calibration. Use the cal off for the bandpass
;correction. Use a 3rd order polynomial fit to the cal off for the bandpass
;correction.
; --print,corstokes(lun,bdat,bcal,scan=210200238L,/phase,bpc=1,fitbpc=3)
;The bandpass correction is a bit tricky and depends on what type of
;observations you are doing. The integration time for the off is usually
;a lot less than the on positions so you need to use either the bandpass
;fit or smoothing. It would probably be a good idea to add an option for
;the user to input a bandpass to use for the correction (from an off src
;position).
;
;SEE ALSO:
;    cormask,corlist
;-
; history:
;18apr02: started
;15aug02: check version idl.. use poly_fit or polyfitw ..
;20aug02: left output last version check polyfit at end.
;         bug in scaling u,v was taking sqrt twice..
;21oct02: if fitting, fit -1 to 1
;21oct02: <pjp001>change order of bandpass fit, smooth. Was doing it after the
;         divide.Better to do it before in case noise brings some
;         values close to 0 then you take 1/x.
;
function corstokes,lun,bdat,bcal,scan=scan,calscan=calscan,$
                   calinp=calinp,datinp=datinp,avg=avg,maxrecs=maxrecs,$
                   han=han,sl=sl,edgefract=edgefract,mask=mask,phase=phase,$
                   bpc=bpc,fitbpc=fitbpc,smobpc=smobpc,phsmo=phsmo,nochk=nochk
    forward_function corhcalrec
;
;   input the data
;
;    on_error,1
    if not keyword_set(sl)   then sl  =0
    if not keyword_set(bpc) then bpc =0
    if not keyword_set(scan) then scan=0
    if not keyword_set(calscan) then calscan=0
    if not keyword_set(han)  then han =0
    if not keyword_set(maxrecs)  then maxrecs=0
    if not keyword_set(avg)  then avg=0
    if not keyword_set(fitbpc)  then fitbpc=0
    if not keyword_set(smobpc)  then smobpc=0
    if not keyword_set(nochk)  then nochk=0
    if n_elements(phsmo) eq 0 then phsmo=11
    if smobpc le 1 then smobpc=0
    gotmask=keyword_set(mask)
    if n_elements(edgefract) eq 0 then edgefract=.1
;---------------------------
;   Input the data scan
;
    if keyword_set(datinp) then begin
        bdat=datinp
    endif else begin
       istat=corinpscan(lun,bdat,scan=scan,han=han,sl=sl,maxrecs=maxrecs)
        if istat ne 1 then begin
            print,'err inputing data scan'
            return,0
        endif
    endelse
    nrecs=n_elements(bdat)
;---------------------------
;   get cal scans. should be 1 rec calon, 1 rec cal off
;
    if keyword_set(calinp) then begin
        bcal=calinp
    endif else begin
        istat=corgetm(lun,2,bcal,scan=calscan,han=han,sl=sl)
        if istat ne 1 then begin
            print,'err inputing cal data'
            return,0
        endif
    endelse
;
;   make sure we have a cal on off
;
    if nochk eq 0 then begin
    if n_elements(bcal) ne 2 then begin
        print,'Bcal must contain on and off cal'
        return,-1
    endif
    if  corhcalrec(bcal[0].b1.h)  ne 1 then begin
         print,'Bcal[0] must be cal on scan'
         return,-1
    endif
    if  corhcalrec(bcal[1].b1.h)  ne 2 then begin
         print,'Bcal[1] must contain cal off scan'
       return,-1
    endif
    endif
;
;---------------------------
;   see how many boards,lags there are . make sure cal, data the same
;
    nbrds=n_tags(bcal[0])
    if n_tags(bdat[0]) ne nbrds then begin
        print,'different number of boards in data and cal scans'
        return,-3
    endif
;
;---------------------------
;   make sure that all boards are stokes data
;
	if (not keyword_set(nochk)) then begin
    for i=0,nbrds-1 do begin
        if corhstokes(bdat[0].(i).h) eq 0 then begin
            print,'brd:',i+1,' of data scan not stokes data'
            return,-4
        endif
        if corhstokes(bcal[0].(i).h) eq 0 then begin
            print,'brd:',i+1,' of cal scan not stokes data'
            return,-4
        endif
    endfor
	endif
;
;---------------------------
;   process the cal on-off      
;
    calval=fltarr(2,nbrds)
    for i=0,nbrds-1 do begin
        if corhcalval(bcal[0].(i).h,cal)  eq -1 then begin
            print,'err: getting cal value via corhcalval brd:' + string(i)
            return,-2
        endif
        calval[*,i]=cal
        nlags=bcal[0].(i).h.cor.lagsbcout
;
;       figure out the default mask here
;
        if (gotmask) then begin
            mind=where(mask.(i)[*,0] ne 0.)
        endif else begin
            i1=long(nlags*edgefract)
            i2=nlags-i1-1
            mind=indgen(i2-i1+1)+i1
        endelse
        mnchn=n_elements(mind)
;
;       3level stokes data is normalized we need to scale it back to
;       power units. do all recs,sbc for 1 board
;
        Ical   =total(bcal.(i).h.cor.lag0pwrratio,1) ; add xx,yy ->I
        Idat=total(bdat.(i).h.cor.lag0pwrratio,1)  ;
        bcal.(i).d=reform(mav(reform(bcal.(i).d,nlags*4,2),Ical,/sec),$
                          nlags,4,2)
        if nrecs eq 1 then begin
        bdat.(i).d=reform(reform(bdat.(i).d,nlags*4)*Idat,nlags,4)
        endif else begin
        bdat.(i).d=reform(mav(reform(bdat.(i).d,nlags*4,nrecs),Idat,/sec),$
                          nlags,4,nrecs)
        endelse
;
;       go from i,q back to pola, polB
;
        xxcal=(bcal.(i).d[*,0] + bcal.(i).d[*,1])*.5
        yycal=(bcal.(i).d[*,0] - bcal.(i).d[*,1])*.5
;
;       average the cal on,off over the masked channels
;
        xxcalavg=total(xxcal[mind,*],1)/mnchn   ; [0-on, 1-caloff]
        yycalavg=total(yycal[mind,*],1)/mnchn
        scalexx=calval[0,i]/(xxcalavg[0]-xxcalavg[1])   ;Tcal/(calOn-calOff)
        scaleyy=calval[1,i]/(yycalavg[0]-yycalavg[1])  
;---------------------------------------------------------------------------
;   figure out the bandpass correction that they want. options are:
;   1. use caloff or use calon-caloff
;   2. either smooth the selection from 1 (the whole band) or
;      fit a polynomial to it over the currently masked region.
;
        if (bpc gt 0) then begin
            case bpc of
            1: begin        ; cal off 
                bpcxx=xxcal[*,1]
                bpcyy=yycal[*,1]
                Kx=xxcalavg[1]          ; average cal off over mask
                Ky=yycalavg[1]          ; average cal off over mask
               end
            2: begin        ; cal on-caloff
                bpcxx=xxcal[*,0]-xxcal[*,1]
                bpcyy=yycal[*,0]-yycal[*,1]
                Kx=xxcalavg[0]-xxcalavg[1] ; averge calon-caloff over mask
                Ky=yycalavg[0]-yycalavg[1] ; averge calon-caloff over mask
               end
            else: begin
                print,'err:illegal bpcorrection requested'
                return,-6
               end
             endcase
;
;       smooth or fit if they requested 
;
            if (fitbpc gt 0) then begin
                x =intarr(nlags)
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
;
        scalexx=abs(scalexx*Kx/bpcxx)
        scaleyy=abs(scaleyy*Kx/bpcyy)
        scalexy=sqrt(scalexx*scaleyy)
        for j=0,1 do begin
            xs=xxcal[*,j]*scalexx
            ys=yycal[*,j]*scaleyy
            bcal[j].(i).d[*,0]=(xs+ys)
            bcal[j].(i).d[*,1]=(xs-ys)
            bcal[j].(i).d[*,2]= bcal[j].(i).d[*,2]*scalexy
            bcal[j].(i).d[*,3]= bcal[j].(i).d[*,3]*scalexy
        endfor
;
;       now the data .. if bpc then do each record separately
;       since scalexx,scaleyy contain the bandpass
        xx=(bdat.(i).d[*,0]+bdat.(i).d[*,1])*.5
        yy=(bdat.(i).d[*,0]-bdat.(i).d[*,1])*.5
        if bpc ne 0 then begin
            for j=0,nrecs-1 do begin
                xs=xx[*,j]*scalexx
                ys=yy[*,j]*scaleyy
                bdat[j].(i).d[*,0]=(xs+ys)
                bdat[j].(i).d[*,1]=(xs-ys)
                bdat[j].(i).d[*,2]= bdat[j].(i).d[*,2]*scalexy
                bdat[j].(i).d[*,3]= bdat[j].(i).d[*,3]*scalexy
            endfor 
        endif else begin
            bdat.(i).d[*,0]=(xx*scalexx+yy*scaleyy)
            bdat.(i).d[*,1]=(xx*scalexx-yy*scaleyy)
            bdat.(i).d[*,2]= bdat.(i).d[*,2]*scalexy
            bdat.(i).d[*,3]= bdat.(i).d[*,3]*scalexy
        endelse

        if keyword_set(phase) then begin
            xydif=bcal[0].(i).d[*,2]- bcal[1].(i).d[*,2]
            yxdif=bcal[0].(i).d[*,3]- bcal[1].(i).d[*,3]
            if phsmo gt 2 then begin
                delta=atan(smooth(yxdif,phsmo,/edge),smooth(xydif,phsmo,/edge))$
                        *!radeg 
            endif else begin
                delta=atan(yxdif,xydif)*!radeg 
            endelse
            freq=corfrq(bcal[0].(i).h)
            freq=freq-freq[nlags/2]
            off=0.
            for j=0,nlags-2 do begin
                d=delta[j+1]+off-delta[j]
                if abs(d) gt 180. then begin
                    if d gt 0 then begin
                        off=off-360.
                    endif else begin
                        off=off+360.
                    endelse
                endif
                delta[j+1]=delta[j+1]+off
            endfor
;
;           now linear fit vs freq
;
            coef=poly_fit(freq[mind],delta[mind],1,yfit,yerror)
            ind=where(abs(delta[mind] - yfit) lt (3*yerror),count)
            if (count ne n_elements(yfit)) then begin
                if count eq 0 then begin
                    print,'Warning phase fit failed brd:',i
                    return,-1
                endif
                coef=poly_fit(freq[mind[ind]],delta[mind[ind]],1,yfit,yerror)
            endif
            print,coef 
;
;   offset + slope in deg/Mhz
;
            phase=coef[0] + freq*coef[1]
            cmpphase=complex(0.,-(!dtor*phase))
            cmpphase=exp(complex(0.,-(!dtor*phase)))
            for j=0,nrecs-1 do begin
                rotated=complex(bdat[j].(i).d[*,2],bdat[j].(i).d[*,3])*$
                        cmpphase
                bdat[j].(i).d[*,2]=float(rotated)
                bdat[j].(i).d[*,3]=imaginary(rotated)
            endfor
            rotated=complex(bcal[0].(i).d[*,2],bcal[0].(i).d[*,3])*$
                     cmpphase
            bcal[0].(i).d[*,2]=float(rotated)
            bcal[0].(i).d[*,3]=imaginary(rotated)
            rotated=complex(bcal[1].(i).d[*,2],bcal[1].(i).d[*,3])*$
                     cmpphase
            bcal[1].(i).d[*,2]=float(rotated)
            bcal[1].(i).d[*,3]=imaginary(rotated)
        endif
    endfor
            
    if keyword_set(avg) and (n_elements(bdat) gt 1) then bdat=coravgint(bdat)
    return,1
end
