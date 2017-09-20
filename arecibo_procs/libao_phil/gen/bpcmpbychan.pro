;+
;NAME:
;bpcmpbychan  - compute a band pass from set of spectra
; 
;SYNTAX: bpc=bpcmpbychan(d,
;                 deg=deg,nsig=nsig,nlsig=nlsig,chnNsig=chnNsig,$
;           flatTsys=flatTsys,
;                 maxFitloop=maxFitLoop,$
;                 chanRms=chanRms,resAll=resAll,dfit=dfit,$
;                 gdpntperchan=gdpntperchan,nloop=nloopbychan,$
;                 indBadChan=indBadChan,indgdchan=indgdchan,zeromean=zeromean,
;                 tsysScl=tsysScl
;ARGS:
;d[nchn,npts]: float    input data to process
;
;KEYWORDS:
;   deg:    int   degree of polynomial fit along each channel. default=1
;  nsig:    float The clipping level (in sigmas) to use for the fit 
;                 residuals. Any value greater than this is not included 
;                 in the fit. The default is 3 sigma.
;  nlsig:   float if nlsig is provided, then channels that have large values 
;                 of sigma/median will have there points to exclude recomputed
;                 with nlsig rather then nsig. A good value would be 2.
;                 By default this is not done.          
; chnNsig:  float : If indBadChan, or indGdChan is requested, use
;                 chnNsig to determine which channels are good:
;                 (rms/sigma le chnNsig), and which channels are bad:
;                 (rms/sigma gt chnNsig). The default for chnNsig is 3 sigma.
; flatTsys:       if set, then divide each spectra by the median
;                 value. This will allow continuum sources to be included
;                 in drift scan mode.
; maxFitLoop:int  The maximum number of times to iterate on the fit for
;                 a single channel. The default is 20.
; zeromean  :     if set, the the input data has zero mean, donot divide
;                 byte the mean;
;
;RETURNS:
;   bpc[nchn]   :float  the bandpass to use for the bandpass correction.
;
;chanRms[nchn]     :float  the rms/mean computed for each channel.
;resAll[nchn,npts] :float  the fit residuals for each point (y-yfit) in
;                          units of sigma of that channel.
;dfit[nchn,npts]:float  the 2d fit of the data to the polynomials by chan.
;
;gdPntPerChan[nchn]:long the number of good points used in each channel.
;indGdChan[]       :long The indices (0 based) for all channels who had
;                        an rms/mean less than chnNSig
;indBadChan[nchn]  :long The indices (0 based) for any channels who had
;                        an rms/mean greater than chnNsig.
;       nloop[nchn]:long The number of fitting iterations that where done 
;                        on each channel.
;tsysScl[npts]     :float If flatTsys was set, then this will contain
;                         1/medianTsysBySpectra for each spectra. have the
;                         tsys scaling factor for each spectra.
;DESCRIPTION:
;   Compute a bandpass correction for a set of data.
;It works with an array of npts spectra each having  nchn channels.
;The algorithm is:
;
;1. If tsysFlat is selected then 
;   compute the median over freq for each spectra and call it Tsys[npts]
;   Use this to flatten each time point so that continuum sources
;   do not skew the data and can be included in the statistics. 
;   If TsysFlat is not selected, then set Tsys[npts] to 1.
;
;2. for each channel take all of the time points for that channel:
;   y=d[ichn,*]
;   a. Normalize this channel to the average tsys over time: 
;     y[npts]=y[npts]/Tsys[npts]
;   b. define all npts to be good points.
;   c. fit a polynomial of order deg to the good points,
;      coef=poly_fit(x[gdpnts],y[gdpnts],deg)
;   d. compute the residuals over all points using the coef from c.
;       res=y-coef(x,coef)
;   e. find all points that are less than nsig times the fit sigma. 
;   f. If there are fewer points than we started with in c, goto c, if
;      not, then we are done with the channel
;   g. store the following:
;       - chanRms[ichn]= rms/mean(last fit)
;       - dfit[ichn,*] = last fit along this channel
;       - gdpntPerChan get number of points we were left with after the fit.
;       - nloop[ichn] is the number of times we looped on the fitting.
;3. When done with all channels, if indBadChan or indGdChan is provided,
;   call meanrob( robust mean) with the chanrms[] array. It will
;   find all of the channel sigmas that stick out less than chnNsig.
;4. Compute the average bandpass correction by averaging the fit array
;   over all time samples: bpc=total(dfit[nchn,npts],2)/npts
;6. The function returns bpc[nchn]
;
;Some Notes on the returned data:
;
;1. The data is flattened in the time direction. The results:
;   bpc, dfit,chanRms,resAll are relative to this dataset. With this
;   processing, continuum sources will not have large residuals (since
;   they were flattened by the mean power of that sample). If you overplot
;   the bpc with the input data, they will differ by a scaling factor. This
;   will be corrected for when the cal is applied.
;2. resAll is in units of rms of the flattened channel: (y-yfit)/sigma. 
;3. chanRms[nchn] has been divided by the mean of each channel. This
;   flattens the bandpass edges. You should be able to predict what
;   this value should be from the 1./sqrt(bw*tau)
;
;EXAMPLE:
;   Suppose you have spectra spc[1024,300] and a calOnOff[1024,2]
;Processing would be:
;   bpc=bpcmpbychan(spc,chanRms=chanRms,indgdChan=indgdchan)
;;  
;;  don't use 100 channels on each edge, plus all the chanRms gt 3 sigma
;;  for scaling to kelvins.
;;
;   mask=lonarr(1024)
;   mask[indgdchan]=1. 
;   mask[0:99]=0    
;   mask[1024-99:*]=0   
;   ind=where(mask eq 1)
;   ngood=n_elements(ind)
;   bpc=bpc/(total(bpc[ind])/ngood) ; bp now normalized to unity
;   for i=0,nsmp-1 do spc=spc[*,i]/bpc
;;
;; now scale to kelvins
;;
;   caldeflTP=total(calOnoff[ind,0]-calonOff[ind,1])/ngood ; use same good chan
;   corToK=calKelvins/calDeflTp
;   spc=spc*corToK                  spectra now in kelvins. 
;
;; I've left the steps separate for illustration. You could combine the
;; calscaling and bandpass corretion in one multiply.
;
;-
;
function bpcmpbychan,d,deg=deg,nsig=nsig,nlsig=nlsig,chnnsig=chnnsig,$
                  flatTsys=flatTsys,$
                  maxFitloop=maxFitLoop,$
                  dfit=dfit,chanRms=chanRms,resAll=resAll,$
                  gdpntperchan=gdpntperchan,$
                  indBadChan=indBadChan,indgdchan=indgdchan,$
                  nloop=nloopbychan,double=double,zeromean=zeromean,$
                  tsysScl=tsysScl
;
    firstTime=1
    a=size(d)
    if a[0] ne 2 then begin
        message,'bpcompute: input bandpass array should be 2d'
    endif
    if not keyword_set(nsig) then nsig=3.
    if not keyword_set(deg)  then deg=1.
    if not keyword_set(maxFitLoop)  then maxFitLoop=20
    if not keyword_set(flatTsys)  then flatTsys=0
    retresAll=(arg_present(resAll))?1:0
;
    nchn =a[1]
    nsmp=a[2]
    dfit=fltarr(nchn,nsmp,/nozero) 
    chanRms =fltarr(nchn,/nozero)       ; rms/mean for each channel
    if retresAll then resAll  =fltarr(nchn,nsmp)          ; 
    gdpntperchan=lonarr(nchn)           ; number good points each chan 
    nloopbychan=lonarr(nchn)            ;
;
;   if flatTsys option supplied, then 
;   compute 1/(total power) vs time. Use this to flatten each
;   channel. This way, continuum sources can be used by the fit.
;
    if keyword_set(flatTsys) then begin
      tsysScl=1./(medianbychan(transpose(d)));tsys per bandpass .. no correction
    endif else begin
      tsysScl=1.
    endelse
    indall=indgen(nsmp)
    xx=(keyword_set(double))?dindgen(nsmp)-nsmp/2D:findgen(nsmp)-nsmp/2.
;
;   for each channel
;
    chnList=lindgen(nchn)
    nsigLoc=nsig
loopChn:
    nchnLoc=n_elements(chnList)
    for l=0,nchnLoc-1 do begin
        ichn=chnList[l]
        indgd=indall                    ; start will all time samples
        y=reform(d[ichn,*])*tsysScl     ; channel data to process
        curCnt=nsmp                     ; start with all points
;
;   move along the samples finding all points with 
;   residuals lt nsig*sigma
;
        for j=0,maxfitloop-1 do begin   ; loop till done or maxloop
            coef=poly_fit(xx[indgd],y[indgd],deg,yerror=sigma)  ; fit
            yn=poly(xx,coef)            ; re evaluate, all points
            ii=where(abs(y-yn) lt (nsigLoc*sigma),count) ;outliers
            if curcnt eq count then goto,endloop ; no Change??  then done...
            indgd=ii                    ; new indices of good points.
            curcnt=count                ; new count  of good points
			if curcnt eq 0 then begin
				yn=xx*0 + 1.
				break
			endif
        endfor
endloop: dfit[ichn,*]=yn
         nloopbychan[ichn]=j
         if not keyword_set(zeromean) then begin
             chanRms[ichn]  = sigma/mean(yn)
        endif else begin
             chanRms[ichn]  = sigma
        endelse
         gdpntperchan[ichn]=curcnt
         if retresAll then resAll[ichn,*]= (y-yn)/sigma
    endfor
;
; check for large sigmas... 
;
    if arg_present(indbadchan) or arg_present(indgdchan) or $
       keyword_set(nlsig) then begin
        ival=meanrob(chanRms,nsig=chnnsig,bindx=indbadchan,gindx=indgdchan,$
                     nbad=nbad)
    endif

    if keyword_set(nlsig) and (firstTime) then begin
        if  nbad gt 0 then begin
            chnListLoc=indbadchan
            firstTime=0
            nsigLoc=nlsig
            goto,loopChn
        endif
    endif

    bpc=total(dfit,2)/nsmp  ; for now return the mean bp
    return,bpc
end
