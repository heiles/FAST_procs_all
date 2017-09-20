;+
;NAME:
;avgrobbychan - compute the robust average by chan for 2d array.
;SYNTAX:  result=avgrobbychan(d,nsig=nsig,ncnts=ncnts,rms=rms)
;  ARGS:
;     d[m,n]  : array to compute rms
;KEYWORDS:
;     nsig:float  any points nsig beyond mean are ignored in the average. 
;   
; RETURNS:
;     result[m]: result[i]= robustmean(d[i,*])
;      ncnts[m]: number samples used for each mean
;        rms[m]: rms of each channel (it is not divided by the mean)
; DESCTRIPTION:
;    compute a robust mean by channel of a 2d array. For each channel
;compute the rms. Throw out all points above nsig, continue doing
;this until no points are thrown out. For each channel return the mean 
;of the  remaining points.
;-
;06apr05 - sig computed with restricted set, by test for validity
;          should then be with all the data. Also if number increases,
;          keep looping
function avgrobbychan,d,ncnts=ncnts,nsig=nsig,rms=rms
    a=size(d) 
    if not keyword_set(nsig) then nsig=3.
    if a[0] ne 2 then begin
        print,'array should be 2d'
        return,0
    endif
    nchn=a[1]
    npnt=a[2]
    retavg=dblarr(nchn)
    rms=dblarr(nchn)
    indall=lindgen(npnt)
    ncnts=lonarr(nchn)
    for ichn=0,nchn-1 do begin              ; loop over the channels
        ind=indall
        count1=npnt
        done=0
        while not done do begin
            retavg[ichn]=mean(d[ichn,ind])
            res         =d[ichn,ind]-retavg[ichn]
            sig=sqrt(total(res^2,/double)/(count1-1.0))
;           ind1=where(abs(res) lt (sig*nsig),count) ; points less than cliplev
            resAll=d[ichn,*]-retavg[ichn]
            ind=where(abs(resAll) le (sig*nsig),count) ;points < than cliplev
            done= count eq count1
            if not done then begin
                count1=count
            endif else begin
                ncnts[ichn]=count 
                rms[ichn]=sig
            endelse
        endwhile
    endfor
    return,retavg
end
