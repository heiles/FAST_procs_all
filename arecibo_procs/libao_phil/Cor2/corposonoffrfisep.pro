;+
;NAME:
;corposonoffrfisep - process a position switch pair with rfi excision.
;                 this version searchs on,off separately rather than
;                 on/off -1
;SYNTAX: istat=corposonoffrfisep(lun,bonoff,calscl,bonrecs,boffrecs,$
;                  scan=scan,maxrecs=maxrecs,sl=sl,$
;                  han=han,sclcal=sclcal,sclJy=sclJy,$
;   dataPassedIn:  boninp=boninp,boffinp=boffinp,bcalinp=bcalinp,$
;                  smorfi=smorfi,
;    rfiExcParms:  frqChnNsig=frqChnNsig,tpNSig=tpNsig,badNsig=badNsig,$
;                  flatTsys=flatTsys,adjKer=adjKern,$
;  ReturnRfiInfo:  bsmpPerChn=bsmpPerChn,bresdat=bresdat,bmask=bmask,$
;ReturnRfiTpInfo:  tpdat=tpdat,tpmask=tpmask,$
;                  verbtp=verbtp,verbwt=verbwt,verball=verball
;   
;INPUT ARGS:
;       lun:    int file lun if program is to read the data from disc.
;
;INPUT KEYWORDS:
;POSITIONING:
;         scan: long    scan number of on scan. If not supplied then start
;                       reading from the current position.
;      maxrecs: long    If then number of records in a scan in more than
;                       300, then you need to specify this value using the
;                       maxrecs keyword. If not, the routine will only
;                       read the first 300 records.
;         sl[]: {getsl} If you first scan the file with getsl() then passing
;                       the sl[] array in will allow the routine to do 
;                       random access (rather than sequentially searching
;                       for the scan on interest).
;DATA SCALING:  
;          han:         If set then hanning smooth the data on input.
;       sclCal:         if set then scale the data to kelvins using the
;                       cal scan that follows the position on/off.
;                       By default the units are Tsys (since we divide
;                       by to off source).
;       sclJy:          if set then scale the data to Janskies. This is done
;                       by first scaling to kelvins using the cal on/off
;                       scans and then using the gain curve to scale from
;                       kelvins to Janskies. This only works for those
;                       receivers that have gain curves.
;                       cal scan that follows the position on/off.
;useMask:           If true then use the bmask passed in as a starting
;                   point. This lets you call the routine once with one set of
;                   parameters. A second call with a different set of
;                   parameters can then be made with the first calls
;                   mask included in the final mask.

;USERINPUTS DATA:
;     boninp[]: {corget} The user passes in the on source records rather than
;                       reading them from disc.
;     boffinp[]: {corget} The user passes in the off source records rather than
;                       reading them from disc.
;     bcalinp[]: {corget} The user passes in the cal on/off records rather than
;                       reading them from disc.
;RFI EXCISION:
;        smorfi: long    When searching for rfi, smooth the data by
;                        smorfi channels before searching. smorfi should
;                        be an odd number. This is only used for searching
;                        for the rfi, the returned data is not smoothed.
;      flatTsys:        If flatTsys is set, then divide each spectra by
;                       its median value before searching each freq channel
;                       along the time direction. This will allow records with
;                       total power fluctuations to be included.
;   adjKer[i,j]: float  convol this array with the mask array for each
;                       sbc. If the convolved value is not equal to the 
;                       sum of adjKer then also exclude this point. This
;                       array lets you exclude points adjacent to bad 
;                       points (xdim is frequency, ydim is time). The 
;                       array dimensions should be odd.
;    frqChnNsig: float  The number of sigmas to use when excluding a point.
;                       linear fits are done by channel along the time axis.
;                       Points beyond frqChnNsig will be excluded from the
;                       averaging.
;       tpNsig: float   The total power is computed vs time for the points
;                       that pass the freqchannel test. A linear fit is 
;                       then done versus time. Any time points whose
;                       residuals are greater than tpNSig will be ignored.
;                       The default  is 0 (this computation is not done)
;rowThrLev:   float Row threshhold. If the fraction of good data points
;                    (non zero mask value) in a row is less than rowThrLev
;                    then the entire row will not be used in the average.
;                    eg rowthrlev=.8  means that any rows with fewer than
;                    80% good points will not be included in the average.
;                    The default is to use all good points in the mask.
;                    rowThrDat[] will return each rows fraction of good pnts
;
;RETURNED ARGS:
;bonoff:    {corget}    return processed (on-off)/off here. The units will
;                       by Tsys,K, or K/Jy depending on the sclCal and
;                       sclJy keywords. 
;calScl[2,nbrds]:float  values used to scale correlator counts to kelvins.
;bonrecs[]  : {corget}  return individual on records. This is an
;                       optional argument. The units will be K (if /sclcal) or
;                       correlator units.
;boffrecs[] : {corget}  return then individual off records. This is an
;                       optional argument. The units will be K (if /sclcal) or
;                       correlator units.
;RETURNED KEYWORDS:
;
;bsmpPerChn: {corget}   holds the number of samples averaged for each 
;                       freq channel.
;bresdat[nsmp]:{corget} holds the residuals (in units of sigma along a 
;                       frequency channel)  for all the input data.
;bmask[nsmp]:{corget}   hold mask for points used. 0 excluded, 1. included.
;                       it has anded the on and off source masks.
;tpdat[ntmsmp,2,nbrds]:float Total power vs time for each subband used
;                       for total power clipping. This is after the
;                       bad frequency channels are removed. If only one
;                       polarization per board, then the 2nd pol index will
;                       have 0's.
;tpmask[ntmsmp,2,nbrds]:float Total power mask vs time for each subband used
;                             will contain 1 if time sample used, 0 if it
;                             was not used.
;rowThrDat[ntmsmp,2,nbrds]:float Fraction of good points in each row.
;                       You can look at this to see where the rowthr
;                       should be set. This array is returned if the
;                       keyword rowThrLev is used.
;DESCRIPTION:
;   Process a position switch on,off pair. Return a single spectrum
;per sbc of  (posOn-posOff)/posOff. Try to excise rfi before averaging.
;   The units will be:
; Kelvins  if /sclcal is set
; Janskies if /scljy  is set .
; TsysUnits if none of the above is set.
;
;   If bonrecs is specified then the individual on records will also
;be returned. If boffrecs is specified then the individual off records
;will be returned. The units for these spectra will be  Kelvins
;(if /sclcal,/scljy is set) or correlator units (linear in power).
; .. note the current units for onrecs, offrecs is Tsys.. i need to
;    fix this..
;
;   The user can optionally pass in the data rather than reading it
;from disc (using the keywords boninp,boffinp,bcalinp). If you pass
;in data, you must pass in all the data (ons,offs, and cals).
;
;   The processing is:
;1. Input all of the on  records. Hanning smooth them if requested.
;2. Input all of the off records. Hanning smooth them if requested.
;3. Input the two calon, caloff records if we are scaling to kelvins, Jy,
;   or the user supplied the calscl keyword.
;5. For each sbc of each correlator board call bpccmpbychan(onrecs) and
;   bpccmpbychan(offrecs)
;   bpcbychan() does the following:
;   a.For each freq chan iteratively do a linear fit along the time direction 
;     throwing out any points that have fit residuals greater than freqChnNsig
;     (the default is 3 sigma). Continue fitting the same channel until no 
;     new points are thrown out (or an iteration limit is hit).
;   b.Flag all of the good and bad points found for a channel in bmask:
;     good values get 1, bad values get 0. Also store the fit residuals in
;     bresdat[].
;6. And the masks created for the on recs and the off recs. Use this
;   mask for the combined dataset. This means that if an on or an off
;   recs i bad, then that data point will not be used.
;7. If tpNsig is provided, then compute the total power in the onrecs,offrecs
;   arrays for each time sample using the "good" data points. Do an interative
;   linear fit throwing out complete time points if the fit residuals for
;   a time point is greater than tpNsig. Any time points that get flagged
;   as bad in the on or the off will have all of their frequency channels
;   flagged as bad.
;   This processing is only done if the keyword tpNsig  is provided.
;8. Compute bonavg,boffavg averaging over the good data points.
;   Then compute bonoff=(bonavg/boffavg - 1).
;9. If scaling to Kelvins,or Jy call corcalcmp(calrecs, /blda) with the cal 
;   on,off records. The routine will:
;   a. compute calRatio=(calOn-calOff)/caloff.
;   b. call corblauto(calRatio,deg=1,mask=calmask). It will interatively
;      fit a linear function to (calratio) throwing out any points that
;      are above 3 sigma. The cal mask will be all of the frequency channels
;      that fall below 3 sigma.
;   c. compute corToK= calInK/avg(calon-caloff) averaging over the "good" 
;      cal points.
;
;  -We've compute on/off which is in units of Tsys. The conversion factor
;   computed in c. converts from correlator counts to Kelvins. We need to
;   rescale the onoff computed in 8. back to correlator counts. This should
;   be done using the same frequency channels that were used to compute the 
;   cal scaling factor.
;    meanTpoff = mean(boffavg[over channels where calmask is 1])
;  - compute bonoff*meanTpOff * corToK
;10. If scaling to Jy then get the gain for this frequency and az,za in
;    K/Jy. Divide each frequency point in onoff by this value to get Jy.
;
;SOME OF THE DIFFERENT WAYS TO USE THE ROUTINE:
;
;   The simplest way is to call it with all of the defaults. It will use
;3 sigma as the clipping level. 
;
;   Since final onoff spectra will be averaged over the individual records,
;its rms will be sqrt(nrecs) better than the individual records. We are
;using the rms on the individual records to try and find rfi. There can
;be rfi that slips under the individual rfi rms but sticks out in the
;averaged onoff spectra. The smorfi keyword can be used to improve this
;situation (depending on the signature of the rfi). It will smooth smorfi
;adjacent frequency channels before searching along the time axis for
;rfi. This will improve the individual record rms's by sqrt(smorfi).
; 
;   Another way to catch weak rfi is to use the tpnsig option. This will compute
;the total power at each time sample using only the "good" data points
;(found by searching along the time axis for each frequency channel). Any
;total power points that stick up more than tpNsig from a linear fit to
;tp will have the entire time sample discarded.
;
;   Often times rfi will be strong in a few time or frequency channels and
;weaker in some adjacent ones. The adjker (Adjacent Kernel) keyword lets
;you flag data points next to known bad points as bad. You construct
;a 2-d array (1st dimension is freq, 2nd dimension is time). Fill the 
;array with 1's and 0's. The mask of good data points is computed by
;searching along the time axis for each frequency channel and placing a 
;1 at the good points and a 0 at the bad points. The adjKer is then 
;convolved with the mask. Any points after convolution that do not equal
;the sum of the adjker will be marked as bad. If you center the adjker 
;on a data point, then all data points under the non-zero elements of the
;adjker must be 1. If not the center point is marked bad.
;To mark  frequency points next to bad points as bad use:
; adjker=fltarr[3,1]+1
;To mark adjacent time points as bad use:
; adjker=fltarr[1,3]+1
;To mark adjacent time and freq points as bad (not including diagonols use:
; adjker=fltarr(3,3)+1
; ind=[0,2,6,8]
; adjker[ind]=0
;
;EXAMPLES:
;   Suppose we've opened a data (lun points to it) and it has the
; following data:
;
; W49A 417600054   300        onoff      on 19:26:12 11
; W49A 417600055   300        onoff     off 19:32:14 11
; W49A 417600056     1     calonoff      on 19:37:17 11
; W49A 417600057     1     calonoff     off 19:37:28 11
;
; istat=corposonoffrfsep(lun,bonoff,calscl,scan=417600054L,/han,/sclcal,$
;                      bsmpPerchn=bsmpPerchn,bmask=bmask)
;
; bonoff[1]      will then have on/off-1 in Kelvins
; bsmpPerchn[1] will have the number of samples used in each frq channel
; bmask[300]     will have a 1,0 for the good and bad data points.
;
;; plot on/off -1 in kelvins
;
; corplot,bonof
;
;;plot the good points per channel
; corplot,bsmpperchn
; 
;; make an image of freq vs time of the points that were used (bright)
;; and not used (dark).
;; (first do xloadct to load a linear ramp in the color table)..
;
; img=corimgdisp(bmask,/nobpc)
;-
;
function corposonoffrfisep,lun,bonoff,calscl,bonrecs,boffrecs,$
                        scan=scan,maxrecs=maxrecs,sl=sl,han=han,$
                        sclcal=sclcal,sclJy=sclJy,$
                        boninp=boninp,boffinp=boffinp,bcalinp=bcalinp,$
                        smorfi=smorfi,adjKer=adjKer,flatTsys=flatTsys,$
                        frqChnNsig=frqChnNsig,tpNSig=tpNsig,$
                        bsmpPerChn=bsmpPerChn,bresdat=bresdat,$
                        bmask=bmask,usemask=usemask,$
                        tpdat=tpdat,tpmask=tpmask,$
                        rowthrLev=rowthrLev,rowthrdat=rowthrdat,$
                        verbtp=verbtp,verbwt=verbwt,verball=verball

    istat=1
    if not keyword_set(scan)    then scan=0
    if not keyword_set(sclcal)  then sclcal=0
    if not keyword_set(scljy)   then scljy=0
    useRowThr=n_elements(rowThrLev) gt 0
    if not keyword_set(usemask) then usemask=0
    ;
    ;   gain curve needs to scale to kelvins first
    ;
    if keyword_set(scljy)       then sclcal=1
    if not keyword_set(maxrecs)  then maxrecs=0
    if not keyword_set(sl)       then sl=0
    if not keyword_set(han)       then han=0
    usecals   = sclcal
    if (n_params() ge 4) then usecals=1 ; they want to return them..

    retBres=arg_present(bresdat)    ; they want residual returned..
    if not keyword_set(frqChnNsig) then frqChnNsig =3.
    if not keyword_set(tpNsig)     then tpNsig     =0.
    if not keyword_set(verbtp)     then verbtp     =0 
    if not keyword_set(verbwt)     then verbwt     =0 
    if not keyword_set(smorfi)        then smorfi        =0 
    if keyword_set(verball)        then begin
        verbtp=1;
    endif
    useAdjKer=n_elements(adjker) gt 1

    rettpdat   = arg_present(tpdat)
    rettpmask  = arg_present(tpmask)
    retallmask = arg_present(bmask)
    coltpbad=2
    cs=1.5
;
;   get the data check that they are on,off scans if we read them in..
;
    
    bufsPassedIn=(keyword_set(boninp) and keyword_set(boffinp))
    if bufsPassedIn then begin
      if (n_elements(boninp) ne n_elements(boffinp)) then begin
        print,'on,off scans have different number of records'
        goto ,errinp 
      endif
      bonrecs=boninp
      boffrecs=boffinp
;
;   get the cal recs
;
        if usecals then begin
            if not keyword_set(bcalinp) then begin
              print,'No cal records provided, can not scale to cals or Jy'
              goto,errinp
            endif
            bcalrecs=bcalinp
        endif
    endif else begin
;
;    we read in the on,off buffers
;
      if (corinpscan(lun,bonrecs ,scan=scan,han=han,sl=sl,maxrecs=maxrecs) $
            eq 0) then goto,errinp
      if (corinpscan(lun,boffrecs,han=han,sl=sl,maxrecs=maxrecs)$
             eq 0) then goto,errinp
      if (n_elements(bonrecs) ne n_elements(boffrecs)) then begin
        print,'on,off scans have different number of records'
        goto ,errinp 
      endif
      if ( string(bonrecs[0].(0).h.proc.car[*,0]) ne 'on') then begin
        print,'1st scan not an on',bonrecs[0].(0).h.std.scannumber
        goto,errinp
      endif
      if ( string(boffrecs[0].b1.h.proc.car[*,0]) ne 'off') then begin
        print,'2nd scan not an off',boffrecs[0].b1.h.std.scannumber
        goto,errinp
      endif
;
;   get the cal recs
;
      if (usecals) then begin
        if (corgetm(lun,2,bcalrecs,sl=sl,han=han) ne 1 ) then begin
            print,'Could not read in the calon,off scans'
            goto,errinp
        endif
      endif
    endelse

;
;   allocate some buffers
;
    ntmSmp=n_elements(bonrecs)          ; number of time samples we have
    if tpNSig ne 0. then xtm=findgen(ntmSmp)
;
    bsmpPerChn=bonrecs[0]           ; keep track of good time samples/frq chan
    if retBres then bresdat=bonrecs; return fit residuals
    bonavg =bonrecs[0]
    boffavg=boffrecs[0]
    if smorfi gt 1 then begin
        bonRecsSav =bonrecs
        boffRecsSav=boffrecs
        corsmo,bonrecs ,smo=smorfi
        corsmo,boffrecs,smo=smorfi
    endif
    nbrds=bonrecs[0].b1.h.cor.numbrdsused
    if rettpdat   then tpdat=fltarr(ntmsmp,2,nbrds)
    if rettpmask  then tpmask=fltarr(ntmsmp,2,nbrds)
    if useRowThr  then rowThrDat=fltarr(ntmsmp,2,nbrds) + 1.
    if retallmask then bmask=bonrecs
;
;   loop over the number of correlator boards they have
;
    for ibrd=0,nbrds-1 do begin
        npol=bonavg.(ibrd).h.cor.numsbcout
        if npol gt 2 then begin
            print,'corposonoffrfisep does not support stokes data..sorry'
            goto , errinp
        endif
        nlags=bonavg.(ibrd).h.cor.lagsbcout
        for ipol=0,npol-1 do begin
            nbadtpOn     =0L
            nbadtpOff     =0L
;
;           for each channel do a linear fit over time. Iterate
;           throwing out points with large residuals. Return the fit
;           residuals:
;           resall[freqchn,tmpnts]- fit residuals normalized to the sigma of
;                         each channel.
;
;           We will use this resall to decide which points to use.
; 
;           on recs
;
            bpc=bpcmpbychan(bonrecs.(ibrd).d[*,ipol],deg=deg,nsig=frqChnNsig,$
            resall=resall,flatTsys=flatTsys)
;
;           for each time sample compute the fraction of freq points that are 
;           good
;   
            statar=(usemask)? bmask.(ibrd).d[*,ipol] $
                            : make_array(nlags,ntmSmp,/float,value=1.)
            ind=where(abs(resall) gt frqChnNsig,count_resall)
            if count_resall gt 0 then statar[ind]=0.
            if retBres then bresdat.(ibrd).d[*,ipol]=resall 
;
;           off source
;
            bpc=bpcmpbychan(boffrecs.(ibrd).d[*,ipol],deg=deg,nsig=frqChnNsig,$
            resall=resall,flatTsys=flatTsys)
            ind=where(abs(resall) gt frqChnNsig,count_resall)
            if count_resall gt 0 then statar[ind]=0.
            if retBres then begin
                bresdat.(ibrd).d[*,ipol]=$
                    (abs(bresdat.(ibrd).d[*,ipol]) > abs(resall) )
            endif


            if useAdjKer then begin
                scale=total(adjKer)
                junk=convol(statar,adjKer,/edge_truncate)
                ind=where((junk ne scale),count)
                if count gt 0 then statar[ind]=0.
            endif
;
;           see if they want to test using total power fluctuations
;
            if tpNSig ne 0. then begin
                tpOn =total(bonrecs.(ibrd).d[*,ipol]*statAr,1)/total(statar,1)
                tpOff=total(boffrecs.(ibrd).d[*,ipol]*statAr,1)/total(statar,1)
                maskOn=maskbyrms(xtm,tpOn,deg=deg,nsig=tpNSig,$
                            indxbad=indbadtpOn, nbad=nbadtpOn)
                maskOff=maskbyrms(xtm,tpOff,deg=deg,nsig=tpNSig,$
                            indxbad=indbadtpOff, nbad=nbadtpOff)
                if verbtp then begin
                    lab=string(format='("total pwr brd:",i1," sbc:",i1)',$
                                ibrd+1,ipol+1)
                    plot,xtm,tpOn,charsize=cs,title=lab
                    plot,xtm,tpOff,charsize=cs,title=lab,color=3
                    if nbadtpOn gt 0 then begin
                 oplot,xtm[indbadtpOn],tpOn[indbadtpOn],psym=2,color=coltpbad
                    endif
                    if nbadtpOff gt 0 then begin
                oplot,xtm[indbadtpOff],tpOff[indbadtpOff],psym=2,color=coltpbad
                    endif
                    if verbwt then key=checkkey(/wait)
                endif
                if rettpdat  then tpdat[*,ipol,ibrd]=(tpOn +tpOff)*.5
                if rettpmask then tpmask[*,ipol,ibrd]=maskOn and maskOff
            endif
;
;       see if they want to use rowThrLev to throw out entire rows
;
        if useRowThr then begin
            rowThrDat[*,ipol,ibrd]=(total(statar,1)/nlags)
            ind=where(rowThrDat[*,ipol,ibrd] lt rowThrLev,count)
            if count gt 0 then statar[*,ind]=0.
        endif

;
        if verbtp or verbwt then begin
            lin=string(format='("brd/sbc:",i2,i2," bpntbyfreq:",i6)',$
                        ibrd+1,ipol+1,count_resall)
            if tpNSig ne 0. then begin
                lin=lin+$
            string(format='(" bSmpbyTpSigon,off:",i6,i6)',nbadtpOn,nbadtpOff)
            endif
            print,lin
        endif
;
;           compute number of time samples each freq bin
;           and then sum over time by multiplying with the statar and
;           summing. statar will have 0 for points that are not used.

sumdata:    
            if nbadtpOn      gt 0 then statar[*,indbadtpOn] =0.
            if nbadtpOff     gt 0 then statar[*,indbadtpOff]=0.
            if retallmask then bmask.(ibrd).d[*,ipol]=statar

            bsmpPerChn.(ibrd).d[*,ipol]=total(statar,2); # pnts each freq bin
            if smorfi gt 1 then begin               ; use the unsmoothed data
                bonavg.(ibrd).d[*,ipol]=$
                        total(bonRecsSav.(ibrd).d[*,ipol]*statar,2)
                boffavg.(ibrd).d[*,ipol]=$
                        total(boffRecsSav.(ibrd).d[*,ipol]*statar,2)
            endif else begin
                bonavg.(ibrd).d[*,ipol]=$
                        total(bonRecs.(ibrd).d[*,ipol]*statar,2)
                boffavg.(ibrd).d[*,ipol]=$
                        total(boffRecs.(ibrd).d[*,ipol]*statar,2)
            endelse
        endfor
    endfor
;
;   now normalize to number of samples
;
    bonavg =cormath(bonavg,bsmpPerChn,/div)
    boffavg=cormath(boffavg,bsmpPerChn,/div)
    bonoff=cormath(bonavg,boffavg,/div)
    bonoff=cormath(bonoff,ssub=1.)
;
;   if using cals, compute cal scale factor. We will use the calmask
;   to normalize the off source during the bandpass correction
;
    if usecals then begin
        istat=corcalcmp(bcalrecs[0],bcalrecs[1],calscl,mask=calmask,/blda,$
                    extra=_e)
        if sclcal then begin
;
;       -normalize off to channels used to compute the cal
;       -divide by normalized off, multiple by kelvins/CorCnt o
;       -if sclJy then divide by K/Jy
;
             for ibrd=0,nbrds-1 do begin
                 npol=bonoff.(ibrd).h.cor.numsbcout
                 if sclJy then begin 
                     if (corhgainget(bonavg.(ibrd).h,gainval) lt 0) then begin
    print,'No gain curves for this rcvr. You need to remove scljy=1 keyword'
                        goto,errinp
                    endif
                    gainvalInv=1./gainval   ; k/Jy -> Jy/Kelvin
                endif else gainvalInv=1.
                for ipol=0,npol-1 do begin
                    ind=where(calmask.(ibrd)[*,ipol] eq 1,count)
                    bonoff.(ibrd).d[*,ipol]= bonoff.(ibrd).d[*,ipol] * $
                        mean(boffavg.(ibrd).d[ind,ipol])*calscl[ipol,ibrd]* $
                        gainvalInv
                 endfor
             endfor
             computedonoff=1
        endif
    endif
    return,1
errinp: return,0
end
