;+
;NAME:
;masrdrsatzaplt - plot za strips from radar saturation data.
;SYNTAX: masrdrsatzaplt,hdr,tpCln,tpRdr,za,rdrFrqAr,beamList,$
;        wait=wait,deg=deg,zaStart=zaStart,zaStep=zaStep,tit=tit,$
;        rdrFrqOrd=rdrFrqOrd,vmaxRdr=vmaxRdr,medRdr=medRdr,medCln=medCln
;ARGS:
;hdr{}:     fits binary header for this file
;tpCln[nsmp,nbeam]: float the power data from the clean band
;tpRdr[nsmp,nbeam,nrdr]: float the peak data from the radar band.
;za[nsmp]:  the za for each sample
;rdrFrqAr[nrdr]: float start freq each rdr band (see masrdrsat()).
;beamList[nbeam]: int beam number for each array index
;KEYWORDS:
;
;wait   :        if set then wait for return between each plot.
;deg:   : long   order of polynomial to fit when removing za dependence
;                 over zastep points. Default is 1.
;zaStart: float  first za to  use (deg) def=min value in dataset
;zaStep:  float  za length plot each page. default is 2.5 deg
;tit:  ''        string to add to title
;rdrFrqOrd[nrdr]: int order to plot the radar data. This is relative to 
;                 how the dat is stored.
;vmaxRdr: float   max value for the rdr plots in db's above Tsys.
;medCln[nsmp,nbeam]:float  if supplied then the median value at each sample.
;                 use this to normalize the cln band data.
;medRdr[nsmp,nbeam,nrdr]:float  if supplied then the median value at each sample.
;                 use this to normalize the rdr data.
;
;DESCRIPTION:
;   make plots of radar saturation za strips. Data comes from masrdrsat().
;Plot zaStep degrees per page (default is 2.5 degrees). On each page
;plot the avg total power for the clean band followed by the
;peak values in the radar band.
;
;EXAMPLE:
;   savFile='rdrsat.sav'
;   nfound=masrdrsat(fnmiar,rfifreq,/aero,/faa,/remy,savFile=savFile,$
;                    /verb,/savza)
;
;   restore,savFile,/verb
;   todec=1000
;   masrdrsatdec(todec,,tpCln,tpRdr,tpClnD,tpRdrD,nptDec,indAr
;   zaStart=2.
;   zaStep=2.5
;   masrdrsatzaplt,hdrD,tpClnD,tpRdrD,zaAr[indAr],rdrFrqAr,beamList,wait=wait,$
;       zaStart=zaStart,zaStep=zaStep,tit=tit,deg=2
;-
pro masrdrsatzaplt,hdr,tpCln,tpRdr,za,rdrFrqAr,beamList,wait=wait,deg=deg,$
            zaStart=zaStart,zaStep=zaStep,tit=tit,rdrFrqOrd=rdrFrqOrd,$
            vmaxRdr=vmaxRdr ,medrdr=medrdr,medcln=medcln
;
    common colph,decomposedph,colph
    forward_function robfit_poly

    useMedCln=n_elements(medCln) gt 0
    useMedRdr=n_elements(medRdr) gt 0
    zaMax=19.5
    beamAr=['beam0','beam1','beam2','beam3','beam4','beam5','beam6']

    if n_elements(zaStart) eq 0 then zaStart=long(min(za))
    if n_elements(zaStep) eq 0 then zaStep=2.5
    if n_elements(tit) eq 0 then tit=''
    if n_elements(vmaxRdr) eq 0 then vmaxRdr=50

    if n_elements(wait) eq 0 then wait=0
    if n_elements(deg) eq 0 then deg=1
    cs=1.7
    a=size(tpCln)
    nbeams=(a[0] eq  1)?1:a[2]
    nsmpTot=a[1]
    a=size(tpRdr)
    if nbeams eq 1 then begin
        nrdr=(a[0] eq 1)?1:a[2]
    endif else begin
        nrdr=(a[0] lt 3)?1:a[3]
    endelse
    if n_elements(rdrFrqOrd) eq 0 then rdrFrqOrd=lindgen(nrdr)
    labRdr=strarr(nrdr)
    eps=.1
    faa=1330
    remy=1270
    aero=1241.74
    for i=0,nrdr-1 do begin
        case 1 of  
        abs(rdrFrqAr[i]-faa) lt eps : labRdr[i]='FAA Radar'
        abs(rdrFrqAr[i]-aero) lt eps :labRdr[i]='AeroStat Radar'
        abs(rdrFrqAr[i]-remy) lt eps :labRdr[i]='Remy Radar'
        else : labRdr[i]='unknown Freq'
       endcase
    endfor
    smpTm=hdr.cdelt5
;;  smpStep=secsStep/smpTm
    nstepTot=long((max(za) - zaStart)/zaStep + 1l)
    medClnL=fltarr(nbeams)
    medRdrL=fltarr(nbeams,nrdr)
    ii=where(za lt 10)
    for ibm=0,nbeams-1 do begin
        medClnL[ibm]=(useMedCln)?median(medCln[ii,ibm]) :median(tpCln[ii,ibm])
        for irdr=0,nrdr-1 do begin
            medRdrL[ibm,irdr]=(useMedRdr)?median(medRdr[ii,ibm,irdr]) :median(tpRdr[ii,ibm,irdr])
        endfor
    endfor
    za1=zaStart
    inc=.01
    !p.multi=[0,1,nrdr+1]
    for i=0,nstepTot-1 do begin
        ind=where((za ge za1) and (za lt ((za1 + zaStep) < zaMax)),cnt)
        if cnt eq 0 then break
        x=za[ind]
        yCln=tpCln[ind,*]
        yRdr=tpRdr[ind,*,*]
        for ibm=0,nbeams-1 do begin
            yy=yCln[*,ibm]/medClnL[ibm]
            coef=robfit_poly(x,yy,deg,nsig=nsig,yfit=yfit,sig=sig,/double,$
                            ngood=ngood)
            yCln[*,ibm]=(yy - yfit)+ 1.
            for irdr=0,nrdr-1 do begin
                yy=yrdr[*,ibm,irdr]
                coef=robfit_poly(x,yy,deg,yfit=yfit)
                yRdr[*,ibm,irdr]= $
                alog10((yy - yfit)/medRdrL[ibm,irdr] + 1.)*10.
            endfor
        endfor
        ver,.98,1.08
        stripsxy,x,ycln,0,inc,/step,charsize=cs,$
            xtitle='za [deg]',ytitle='pwr [Tsys]',$
            title=tit + ' Avg pwr 1450 Band vs za. smooth to '+$
            string(format='(f6.3)',hdr.cdelt5) + " secs"
;
        ln=round(32./(nrdr+1) *1.1)
         xp=.04
         xpinc=.09
         for j=0,nbeams-1 do begin
            note,ln,beamAr[beamList[j]],xp=xp+xpinc*j,col=colph[j+1]
         endfor

        ver,0,vmaxRdr
        for irdr=0,nrdr-1 do begin
            ii=rdrFrqOrd[irdr]
            stripsxy,x,yRdr[*,*,ii],0,0,/step,charsize=cs ,$
            xtitle='za [deg]',ytitle='pwr [dbTsys]',$
            title='pk pwr ' + labRdr[ii]
        endfor
        if keyword_set(wait) then begin
            print,'enter to continue. s=stop, q-return'
            key=checkkey(/wait)
            if (key eq 's') or (key eq 'S') then stop
            if (key eq 'q') or (key eq 'Q') then return
         endif
        za1+=zaStep
    endfor
    return
end
