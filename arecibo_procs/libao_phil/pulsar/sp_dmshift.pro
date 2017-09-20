;+
;NAME:
;sp_dmshift - compute the shift values for dedispersion.    
;SYNTAX: shiftAr=sp_dmshift(f1,df,nchans,dm,tmSample,refRf=refRf,
;                           nbands=nbands)
;ARGS:
;   f1  :double   center frequency of first channel (Mhz).
;   df  :double   Channel width (Mhz)   
; nchans:int      total number of channels
;    dm : double  dispersion measure
;tmSample: double time samples (secs)
;
;KEYWORDS:
;   refRf:double   reference frequency to use for dedispersion. The default
;                  is the first bin of each band.
;  nbands:long     number of dedispersed bands to return. default=1
;                  nbands must divided evenly into nchans
;
;RETURNS:
;   shiftAr[nchans]:long    shift values for each channel.
;
;DESCRIPTION:
;   Compute the shift values for each frequency channel to use when
;dedispersing a time series.
;
;NOTES:
;   Stole from dunc's sigproc routine.
;
;-
function sp_dmshift,f1,df,nchans,dm,tmSample,refRf=refRf,nbands=nbands 
;
    if not keyword_set(nbands) then nbands=1L
    chanPerBand=long(nchans)/long(nbands)
    shiftAr=lonarr(chanPerBand,nbands) 
    f1tmp=dindgen(chanPerBand)*df       ; freq of each channel in band
    f2tmp=dblarr(chanPerBand)           ; ref freq 
    nband_Wd=chanPerBand*df             ; bandwidth each band
    for i=0,nbands-1 do begin
        f1st=f1+i*nband_Wd              ; freq first chan this band
        fref=(keyword_set(refRf))?refRf:f1st
        shiftAr[*,i]=long(sp_dmdelay(f1tmp+f1st,f2tmp+fref,dm)/tmSample + .5)
    endfor
    return,reform(shiftar,nchans,/overwrite)
end
