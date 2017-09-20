;+
;NAME:
;findrdripp - the the ipps of a radar from total power data
;SYNTAX:nipps=findrdripp(d,minipp,maxipp,maxNumipp,onval,ipps,offset,
;                   ipplen=ipplen,ipppos=ipppos
;ARGS:
;   d[npts]: total power time series for radar.
;   minipp : float minium ipp to allow. units = sample rate
;   maxipp : float maximum ipp to allow. units = sample rate
;maxNumipp : int   max number of distinct ipps to allow
;     onval: float The value of d that --> radar is on.
; KEYWORDS:
;   nippcor: long number of ipps to use for correlation to find offset.
;                 default is 40
;
;RETURNS:
; nipps    : long  number of ipps found.
;  ipps[m] : float The ipps that were found.
;offset    : long  the offset to start of first ipp.
;KEYWORDS:
;   ipplen[]: int  the length of each ipp found for all the data
;   ipppos[]: long  index into d for each ipp found
;
;DESCRIPTION:
;   Given a total power times series for a radar try and find the 
;ipps that the radar uses. The user specifies a threhold above which the
;radar is determined on (this does not have to be 100% accurate). The 
;routine then finds the indices for all points above this value. It then
;looks for all indices that have at least minipp samples before it less than
;this threshould values. These indices are then marked as ipp starts. 
;The difference between ipp starts are then computed and all ipplens greater
;than the maximum ipp are discarded (since we may have missed some of the
;ipps). The ipplen is then sorted and the transitions are marked. The 
;median value between transistions is then taken as the ipps. 
;
;The total ipp (length before ipp repeats) is computed. Each ipp that is
;then crosscorrelated with 40 ipptot worth of data looking for where this
;ipp starts. The order of the ipps is set to reflect the data order and the
;offset in the dataset for the first ipp is also returnd.
;
;NOTES:
;   1. You need at least 40 complete cycles of the data.
;   2. you may need to play with minipp,maxipp and maxnumipp a little.
;   3. if you supply the key ipplen you can see the ipps that the
;      routine is catching ipp per ipp.
;   4. This returns the ipptot to within 1 sample. You then need to 
;      look far down the dataset using ipptot and find the fractional
;      value:
;EXAMPLES:
;   1. To check that it worked.
;      eg.  
;      ippcum=total(ipps,/cum)  
;      hor,0,ipptot*1.5
;      plot,d[0:ipptot*1.5]
;      flag,ippcum+offset,color=2
;   2. to figure out what eps should be.
;      eps=0.
;      l=offset+nipptot*(ipptot+eps) 
;   plot,t[l:l+ipptot*1.5]
;   flag,ippcum+offset;
;   loop adjusting eps till the flags overlap the data.
;-
function findrdripp,d,minipp,maxipp,maxnipp,onval,ipps,offset,ipplen=ipplen,$
            nippcor=nippcor,ipppos=ipppos

    nippsFound=0L
    if not keyword_set(nippcor) then nippcor=40l
    npts=n_elements(d)
    minippdelta=2.
    ind=lindgen(n_elements(d))
    tmon=where(d gt onval,count)      ; radar on tm in usecs
    if count lt 2 then return,0
    step=tmon- shift(tmon,1)    ; samples between points
    step[0]=step[1];
;
;   find points that could be start of ipp. require 
;     > minipp samples < onval before this point
;     < maxipp samples < onval before this point
;   this will get starting ipps, but it will miss some that were not
;   strong enough
;
    indst =where((step gt minipp) and (step lt maxipp),count)
    if count lt 2 then return,0
;
;   and length each ipp in samples
;   since we missed some ipps above, some of the ipplens will be 
;   too long.
;
    ipplen=tmon[indst]-shift(tmon[indst],1)
    ipplen[0]=ipplen[1]
    ipppos=tmon[indst]
;
;   get rid of ipps that are too long or short
;
    ind=where((ipplen gt minipp) and (ipplen lt maxipp),count)
    if count lt 2 then return,0
    ipplen=ipplen[ind]
    ipppos=ipppos[ind]
;
;   sort in ascending order ipplen
;
    ipplens=ipplen(sort(ipplen))
;
;   find where the ipps change then compute median value here to
;   previous change. this will be the ipp accurate to 1 sample
;
    ipps=dblarr(maxnipp)
    ippdelta=ipplens-shift(ipplens,1)
    ippdelta[0]=ippdelta[1]
    ind=where(ippdelta gt  minippdelta,count)
    avgperipp=n_elements(ippdelta)/maxnipp
    curstind=0L
    iout=0L
    nptsipplens=n_elements(ipplens)
    if count gt 0 then begin
    for i=0L,n_elements(ind)-1L do begin 
        if  (ind[i]- curstind) gt (avgperipp*.5) then  begin 
                ipps[iout]=median(ipplens[curstind:ind[i]]) 
                iout=iout+1 
                curstind=ind[i] 
                if iout ge maxnipp then  goto,doneipp 
        endif 
    endfor
doneipp:
    if (((nptsipplens - ind[iout-1L]) gt avgperipp*.5) and $
         iout lt maxnipp) then begin
         ipps[iout]=median(ipplens[curstind:nptsipplens-1])
         iout=iout+1
    endif
    endif else begin
        ipps[0]=median(ipplens)
        iout=1
    endelse
    ipps=ipps[0:iout-1]
    nipps=n_elements(ipps)
    ipptot=total(ipps)
;
;   try finding where each started. 
;   crosscorrelate each ipp with the data.
;   use a mask of 1 xxxx1 where xxx is the ipplen. repeat this
;   n times spaced by ipptot samples.
;   find the lag of the peak for each ipp. 
;   sort by the lag index to get the correct ipp
;   also use the lag to compute the offset in the data stream for the
;   first ipp
;
    n=nippcor
    maxind=lonarr(nipps)    ; hold indices of the correl max
    for i=0L,nipps-1 do begin 
        ind=lonarr(2L,n)     ;
        ind[0,*]=long(lindgen(n)*ipptot) ; space 1st index by ipptot
        ind[1,*]=ind[0,*]+ipps[i]        ; 2nd ind ipps[i] after ind 0
        ans=fltarr(ipptot)               ; hold correl function
        for lag=0L,ipptot-1 do begin      ; loop over long ipp
            ans[lag]=total(d[ind+lag])   ; grab value this delay
        endfor
        val=max(ans,maxi)                ; find index for max lag
        maxind[i]=maxi 
   endfor
   if nipps eq 0 then begin
    offset=maxind[0]
    goto,done
   endif
   ind=sort(maxind)                      ; sort gives ipp order
   ipps=ipps[ind]
   maxind=maxind[ind]                    ; peaks occured here
   offset=mean(maxind-(total(ipps,/cum)-ipps[0])); this is the offset for ipps
   aa=shift(maxind,-1)
   aa[nipps-1]=aa[nipps-1]+total(ipps)
   offset=mean(aa-total(ipps,/cum)); this is the offset for ipps
;
;   need to add search for epsilon offset
;
done:
   return,n_elements(ipps)
end
