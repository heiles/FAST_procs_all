;+
;NAME:
;foldtmseries - fold a time series
;SYNTAX: df=foldtmseries(d,smpTm,period,nbins,stphase=stphase,cnts=cnts)
;ARGS:
;   d[n]: float  data to fold
;  smpTm: float  seconds per sample in d
; period: float  period in secs to fold to.
;  nbins: long   number bins after folding
;KEYWORDS:
;sTPhase: float  the starting second for  d[0]. The default is 0.
;
;RETURNS:
;df[nbins]  :double folded data, normalized to the number of counts 
;cnts[nbins]:long  number of counts in each phase bin.
;
;DESCRIPTION:
;    Fold the time series of d into an array df[nbins]. df is normalized
;to the number of counts in each bin. Optionally return
;the number of counts for each bin in cnts[nbins].
;
;   The computations are done in double precision for more accuracy.
;EXAMPLE:
;;  Take a wapp pulsar datafile on B1937+21 and:
;;1. input the file
;;2. dedisperse it.
;;3. fold it
;
;file2='/share/wapp21/p2175.B1937+21.wapp3.53889.0001'
;period=1.55772007d-3           ; pulsar period
;dm=71.040                      ; dm 
;smpTm=80d-6                    ; sample time of the data
;npts=sp_dedisp(file2,dm,dedisp2) ; input and dedisperse
;nbins=32                       ; bins to fold into
;dfold=foldtmseries(dedisp2,smpTm,period,nbins)     ; fold it
;-
;
function foldtmseries,d,smpTm,period,nbins,stphase=stphase,cnts=cnts
;
    if n_elements(stphase) eq 0 then stphase=0D
    n=n_elements(d)
    bind=long($
         (((dindgen(n)*smpTm + (smpTm*.5D + stPhase))/period) mod 1D)*nbins)
    df  =dblarr(nbins)
    cnts=lonarr(nbins)
    for i=0L,nbins-1 do begin
        ii=where(bind eq i,cnt)         ; find points for this bin
        if cnt gt 0 then begin
			df[i]=mean(d[ii])
        	cnts[i]=cnt
		endif
    endfor
    return,df
end
