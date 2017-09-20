;+
;NAME:
;wapptprun - compute total power for a scan for all wapps used
;SYNTAX: npts=wapptprun(wi,tp,wappsUsed=wappsused,polsum=polsum,hdr=hdr,
;                   removeb7=removeb7,verb=verb
;ARGS:
;   wi[n]: {wi}   wapp info for the files to process. They should come
;                 from 1 scan. See wappgetfiproj(),wappgetfilist().
;KEYWORDS:
;   removeb7:     if set then don't returne beam 7 (this is just a 
;                 duplicate of beam 6 for alfa.
;   verb:         print out names of files as we start
;RETURNS:
;   tp[npts,7/8]  :float total power.  for summed pols
;                                 if /removeb7 then last beam not returned
;   tp[npts,2,7/8]: float total power. for not summed pols
;
;DESCRIPTION:
;   compute total power for all wapps used. Probably works best for alfa.
;If sumPols is set then the data is: [timesamples,beam]
;If not sumPols is set then the data is: [timesamples,pols=2,beam]
; It is not setup to work with nsbc/beam (single pixel).
;sumpol config.. 
;-
function wapptprun,wi,tp,wappsUsed=wappsUsed,polsum=polsum,hdr=hdr,$
                        removeb7=removeb7,verb=verb
;
; make a least 1 wapp enabled 
;
    removeb7L=keyword_set(removeb7)
    iiused=where(wi[0].wappused eq 1,nwapps)
    if nwapps eq 0 then begin
        print,'no wappsused'
        return,-1
    endif
    iref=iiused[0]
;
;   see if start of scan
;
    if ( wi[0].wapp[iref].hdr.timeoff ne 0) then begin
        print,'wi does not hold start of scan..'
        return,-1
    endif
    ii=where(wi.wapp[iref].hdr.timeoff eq 0,cnt)
    nwi=(cnt eq 1)?n_elements(wi):ii[1]
;
;   
;
    start=1
    icur=0L
    for iwi=0,nwi-1 do begin
        dif=wi[0].wappused - wi[iwi].wappused
        ii=where(dif ne 0,cnt)
        if cnt gt 0 then begin
            print,'file:',iwi,' has different wapp usage. stopping early'
            break;
        endif
        for ii=0,nwapps-1 do begin
            iwapp=iiused[ii]
            fn=wi[iwi].wapp[iwapp].dir + wi[iwi].wapp[iwapp].fname
            if keyword_set(verb) then print,"  start:"+wi[iwi].wapp[iwapp].fname
            npts=wapptpfile(fn,tp1,hdr=hdr1)
            if start then begin
                hdr=hdr1
                sumPol=hdr.sum eq 1     
                npol=(sumPol)?2:4
                maxpnts=npts*nwi
                tp=fltarr(maxpnts,nwapps*npol)
                start=0
            endif
            tp[icur:icur+npts-1L,ii*npol:ii*npol+npol-1]=tp1
        endfor
        icur+=npts
    endfor
    ntot=icur
;
;   get rid of any extra points
;
    if ntot eq 0 then begin
        tp=''
        return,0
    endif
    ii=where(iiused eq  3,cnt)
    usedB7=cnt gt 0
    dim2=(removeb7L && usedB7)?nwapps*2-1:nwapps*2
    if sumpol then begin
        if ntot ne maxpnts then begin
            tp=reform(tp[0L:ntot-1L,0:dim2-1],ntot,dim2)
        endif 
    endif else begin
        if ntot ne maxpnts then begin
            tp=reform(tp[0L:ntot-1L,0:2*dim2-1],ntot,2,dim2)
        endif else begin
            if (removeb7L) then begin
                tp=removereform(tp[*,0:2*dim2-1],ntot,2,dim2)
            endif else begin
                tp=removereform(tp,ntot,2,dim2)
            endelse
        endelse
    endelse
    return,ntot
end
