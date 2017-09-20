;+
;NAME:
;corcalib - intensity calibrate a single spectra
;
;SYNTAX: istat=corcalib(lun,bdat,bcal,bfit,scan=scan,calscan=calscan,$
;                        calinp=calinp,datinp=datinp,avg=avg,maxrecs=maxrecs,$
;                        han=han,sl=sl,edgefract=edgefract,mask=mask,$
;                        bpc=bpc,fitbpc=fitbpc,smobpc=smobpc,blrem=blrem,svd=svd,nochk=nochk
;ARGS:
;   lun   : int     file descriptor to read from
;
;KEYWORDS
; scan    : long    scan number for data. default is current position
; calscan : long    scan number for cal on scan. def: scan following 
;                   the data scan.
;calinp[2]:{corget} pass in the caldata rather than read it from lun
;datinp[n]:{corget} pass in the data rather than read it from lun
;      avg:         if set then return the averaged source record
;  maxrecs: long    maximum number of recs to read in. default is 300.
;      han:         if set then hanning smooth the data.
;     sl[]: {sl}    array used to do direct access to scan.
;edgefract[1/2]: float   fraction of bandpass on each side to not use during
;                   calibration. default .1
;     mask:{cormask} mask structure created for each brd via cormask routine
;                   use this rather than edgefract.
;                   note: currently mask.b1[1024,2] will use the mask for the
;                   first pol of each brd for both entries of the board.
;      bpc: int   1 band pass correct with cal off
;                 2 band pass correct with calon-caloff
;                 3 band pass correct (smooth or fit) with data spectra
;                   The default is no bandpass correction
;   fitbpc: int     fit a polynomial of order fitbpc  to the masked
;                   version of the band pass correction and use the 
;                   polynomial rather than the data to do the bandpass
;                   correction. This is only done if bpc is specified.
;   smobpc: int     smooth the bandpass correction spectra by smobpc channels 
;                   before using it to correct the data. The number should be 
;                   an odd number of channels. This is only done if bpc is
;                   specified.
;    blrem: int     Remove a polynomial baseline of order blrem. Fit to the 
;                   masked portion of the spectra. This is done after
;                   any bandpass correction or averaging.
;    svd  :         If baselining is done (blrem) then the default fitting
;                   routine is poly_fit (matrix inversion). Setting svd
;                   will use svdfit (single value decomposition) which is
;                   more robust but slower.
;   nochk :         if set then don't bother to check the cal records
;                   to see if they are valid (in case they were written
;                   with a non-standard program.
;   
;RETURNS:
;  bdat: {corget} intensity calibrated data spectra
;  bcal: {corget} intensity calibrated cal spectra
;  bfit: {corget} if supplied then return the smoothed or fit data that was
;                 used for the bandpass correction.
; istat: 1 ok
;      : 0 hiteof 
;      :-1 no cal onoff recs
;      :-2 could not get cal value 
;      :-3 cal,data scans different configs
;      :-5 sbc length does not match mask length
;
;DESCRIPTION:
;   For those people who do not do position switching, corcalib allows you
;to scale spectra from a src only scan to kelvins and optionally bandpass
;correct it. The routine uses a src scan and a cal on,off pair. The data can
;be read from disc or input directly to this routine (via calinp, datinp). 
;On output bdat and bcal will be in Kelvins. By default the individual records 
;of the scan are returned. If the /avg keyword is used, the average of all 
;of the src records will be returned. If the bfit argument is supplied then
;the fit or smoothed version used for the bandpass correction will also be
;returned. It will be scaled to the median bdat value so you can overplot
;them.
;
;   If the data is input from disc then lun should be the file descriptor
;from the open command. By default it will start reading the src scan from
;the current file position. The scan=scan keyword lets you position to the 
;src scan before reading. By default the calscans will be the two scans
;following the src scan. The calscan=calscan keyword lets you position
;to the cal on scan before reading them.  If the scans on disc have more than
;300 records you need to use the maxrecs= keywords so the entire scan will
;be input.
;
;   By default 10% of the bandpass on each edge is not used for the calibration
;( when computing the conversion factor:
;  CalInKelvins/ &lt;Calon[maskFrqChn]-calOff[maskFrqChn]&gt;).
;You can increase or decrease this with the edgefract keyword. The mask
;keyword overrides the edgefract keyword and allows you to use a mask for
;each sbc (use cormask to create the mask before calling corcalib).
;The calibration will then only use the channels within the mask when computing
;the gain calibration factors. This mask can be used to exclude rfi or 
;spectral lines.
;
;   Bandpass correction can be done with the cal off scan, the 
;calon-caloff difference spectrum, the data scan, or not at all. These
;can be divided into the data scan as they are (although dividing the
;data scan into itself is not very interesting!) or you can smooth or
;fit a polynomial to the bandpass correction spectrum and then use the
;fit/smooothed spectrum for the bandpass correction. 
;
;   The keyword fitbpc=n will fit an n'th order polynomial to the bandpass
;selected by the bpc keyword. Only the area within the mask (or edgefraction)
;will be used for the fit.
;
;   The keyword smobpc=n will smooth the bandpass selected by the keyword
;bpc and use it to do the bandpass correction (n should be an odd number >= 3).
;
;   You can pass in the data and/or calscans directly by using the 
;datinp, calinp keywords. 
;
;THE PROCESSING:
;   let Src be the src spectral data
;   let CalOn be the calOn spectra
;   let CalOff be the calOff spectra
;   let &lt &gt average over selected channels.The names will then have
;       Avg appended to them (eg calOnAvg=&lt;calOn&gt;)
;   let IndFrq be the set of frequency channels selected to use for the
;       calibration
;
;   The calibration consists of:
;
;1. choose indFrq (the channels to use) in the following order:
;   a. The mask for each board from the mask keyword
;   b. Use edgefract to throw out this fraction of channels at each edge.
;   c. Use an edgefraction of .1 (10%)
;
;2. compute CalOnAvg=&lt;calOn[IndFrq]&gt;,calOffAvg=&lt;calOffAvg[IndFrq]&gt;
;
;3. Scale to Kelvins using: CntToK=CalValK/(calOnAvg-calOffAvg)
;   CalOnK =calOn*CntToK 
;   CalOffK=calOff*CntToK 
;   SrcK   =Src*CntToK 
;
;4. If band pass correction is selected (bpc=1 or 2) then:
;    bpc=1: bpcN= calOff/&lt;calOff[IndFrq]&gt; 
;    bpc=2: dif=  calOn - calOff
;           bpcN= (dif)/&lt;dif[IndFrq]&gt;
;   If fitBpc &gt 0 then 
;        bpcN=polyfit order fitbpc to bpcN[IndFrq]
;   else if smobpc &gt 2 then
;        bpcN=boxcar smooth (bcpN, smooth=smobpc)
;
;   then
;   SrcK=SrcK/bpcN
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
; --print,corcalib(lun,bdat,bcal); will process the first set
; --print,corcalib(lun,bdat,bcal,/han); will process the 2nd set with hanning
;
;To process the 2nd set directly with an edgefraction=.12:
; --print,corcalib(lun,bdat,bcal,scan=210200238L,edgefract=.12)
;
;To input the data first, interactively create a mask, and then process 
;the data with a mask
; --print,corinpscan(lun,bdatinp,scan=210200238L,/han)
; --print,corgetm(lun,2 ,bcalinp,/han)  ; reads the next two records
; --cormask,bcalinp,mask                ; interactively creates the mask
; --print,corcalib(lun,bdat,bcal,calinp=bcalinp,datinp=bdatinp,mask=mask)
;
;Use the same cal for multiple data scans:
; --print,corgetm(lun,2 ,bcalinp,scan=210200236L/han);
; --print,corcalib(lun,bdat1,bcal1,calinp=bcalinp,scan=210200235L)
; --print,corcalib(lun,bdat2,bcal2,calinp=bcalinp,scan=210200238L)
;
;Use the cal off for the bandpass correction. Use a 3rd order polynomial fit 
;to the cal off for the bandpass correction.
; --print,corcalib(lun,bdat,bcal,scan=210200238L,bpc=1,fitbpc=3)
;The bandpass correction is a bit tricky and depends on what type of
;observations you are doing. The integration time for the off is usually
;a lot less than the on positions so you need to use either the bandpass
;fit or smoothing. It would probably be a good idea to add an option for
;the user to input a bandpass to use for the correction (from an off src
;position).
;
;SEE ALSO:
;    cormask,corbl,corlist
;-
; history:
;22aug02: started
;31aug02: added blrem baseline removal keyword.
;01sep02: now call corbl for baselining, added svd keyword.
;02sep02: average on scan input rather that at end to speed processing.
;10sep02: added bpc=3 normalize to average data spectra
;15mar04: if 1 sbc per board and == polB, it was using polA cal value.
;
function corcalib,lun,bdat,bcal,bfit,scan=scan,calscan=calscan,$
                   calinp=calinp,datinp=datinp,avg=avg,maxrecs=maxrecs,$
                   han=han,sl=sl,edgefract=edgefract,mask=mask,$
                   bpc=bpc,fitbpc=fitbpc,smobpc=smobpc,blrem=blrem,svd=sved,$
                   nochk=nochk
    forward_function corhcalrec
;
;   input the data
;
;    on_error,1
    bigErr=1e6                      ; for masked out regions
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
    if smobpc le 1 then smobpc=0
    gotmask=keyword_set(mask)
    if n_elements(edgefract) eq 0 then edgefract=.1
    doblrem=0
    if n_elements(blrem) ne 0 then doblrem=1 
    if not keyword_set(svd) then svd=0
    retfit=n_params() ge 3
;---------------------------
;   Input the data scan
;
    if keyword_set(datinp) then begin
        if (avg) and (n_elements(datinp) gt 1 ) then begin
            bdat=coravg(datinp)
        endif else begin
            bdat=datinp
        endelse
    endif else begin
       istat=corinpscan(lun,bdat,scan=scan,han=han,sl=sl,sum=avg,maxrecs=maxrecs)
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
    if (nochk eq 0 ) then begin
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
;---------------------------
; if we don't have a mask structure passed in, create one here
;
  if (not gotmask) then begin
      mask=cormaskmk(bdat[0],edgefract=edgefract)
  endif
;
;    if band pass correction with data, average then normalize  scan here.
;
  if bpc eq 3 then begin
    bavg=coravg(bdat)
    bavg=cormath(bavg,/norm,mask=mask)
  endif
;---------------------------
;   process the cal on-off      
;
    if retfit then bfit=bcal[1];
    calval=fltarr(2,nbrds)
    for i=0,nbrds-1 do begin
        if corhcalval(bcal[0].(i).h,cal)  eq -1 then begin
            print,'err: getting cal value via corhcalval brd:' + string(i)
            return,-2
        endif
;
;  cal is always returned [polA,polB] if 1 sbc/board an polB need to
;  move 2nd index to first
;
        if bcal[0].(i).h.cor.numsbcout eq 1 then begin  
            lagconfig=bcal[0].(i).h.cor.lagconfig
            if  (lagconfig eq 1) or (lagconfig eq 7) then $
                cal[0]=cal[1]
        endif
        calval[*,i]=cal
        nlags=bcal[0].(i).h.cor.lagsbcout
;
;       figure out the default mask here
;
        mind=where(mask.(i)[*,0] ne 0.)
        mnchn=n_elements(mind)
        nsbc=bdat[0].(i).h.cor.numsbcout
        if (bpc gt 0) and (fitbpc gt 0) then begin
            xx=(nlags-1.)/2.   
            x=(dindgen(nlags)- xx)/(xx)
            if !version.release gt '5.3' then begin
               me=( -(mask.(i)[*,0]-1.)*bigErr+1.D)
            endif else begin
               ignore=1.D/bigErr
               me=(mask.(i)[*,0] > ignore)
            endelse
        endif
;
        for sbc=0,nsbc-1 do begin
;
;       average the cal on,off over the masked channels
;
            xxcalavg=total(bcal.(i).d[mind,sbc],1)/mnchn   ; [0-on, 1-caloff]
            scalexx=calval[sbc,i]/(xxcalavg[0]-xxcalavg[1]);Tcal/(calOn-calOff)
            case bpc of
;
;               band pass correct to cal off
;
            1: begin
                scalexx=abs(scalexx*xxcalavg[1]/bcal[1].(i).d[*,sbc])
                end
;
;               band pass correct to cal on-off
;
            2:  begin
                scalexx=abs(scalexx*(xxcalavg[0]-xxcalavg[1])/ $
                    (bcal[0].(i).d[*,sbc] -  bcal[1].(i).d[*,sbc]))
                end
            3:  begin
                scalexx=abs(scalexx/(bavg.(i).d[*,sbc]))
                end
            else: begin
                end
            endcase
            if (bpc gt 0) and (smobpc gt 0) then $
                scalexx=smooth(scalexx,smobpc,/edge)
            if (bpc gt 0) and (fitbpc gt 0) then begin
                if !version.release le '5.3' then begin
                    if svd then begin
                        coef=svdfit(x,scalexx,fitbpc+1,$
                                weights=me,yfit=yfit,/double)
                    endif else begin
                        coef=polyfitw(x,scalexx,me,fitbpc,yfit)
                    endelse
                    scalexx=yfit
                endif else begin
                    if svd then begin
                           coef=svdfit(x,scalexx,fitbpc+1,yfit=yfit,$
                                measure_errors=me,/double)
                    endif else begin
                        coef=poly_fit(x,scalexx,fitbpc,/double,$
                                    measure_errors=me,yfit=yfit)
                    endelse
                    scalexx=yfit
                endelse
            endif
            bcal[0].(i).d[*,sbc]=scalexx* bcal[0].(i).d[*,sbc]
            bcal[1].(i).d[*,sbc]=scalexx* bcal[1].(i).d[*,sbc]
;
;       now the data .. if bpc then do each record separately
;       since scalexx contains the bandpass
            if bpc ne 0 then begin
                if retfit then bfit.(i).d[*,sbc]=scalexx/median(scalexx[mind])
                for j=0,nrecs-1 do  $
                    bdat[j].(i).d[*,sbc]=scalexx* bdat[j].(i).d[*,sbc]
            endif else begin
                bdat.(i).d[*,sbc]=bdat.(i).d[*,sbc]*scalexx
            endelse
        endfor
    endfor
;
;
;    average if they want it
;    we did it above....
;    if keyword_set(avg) and (n_elements(bdat) gt 1) then bdat=coravgint(bdat)
;
;   retfit scaled to median if the want
;
    if retfit then begin
        for i=0,nbrds-1 do begin
            nsbc=bdat[0].(i).h.cor.numsbcout
            mind=where(mask.(i)[*,0] ne 0.)
            for sbc=0,nsbc-1 do begin
                bfit.(i).d[*,sbc]= median(bdat[0].(i).d[mind,sbc]) * $
                                 bfit.(i).d[*,sbc]
            endfor
        endfor
    endif
;
;   see if they want it baselined
;
    if doblrem then begin
        istat=corbl(bdat,bldat,deg=blrem,svd=svd,mask=mask,/auto,/sub)
        bdat=bldat
    endif
    return,1
end
