;+
;NAME:
;rmsmodat - smooth the data in rcvmon struct
;SYNTAX: nrecs=rmsmodat(dinp,tosmo,dsmo)
;ARGS:
;   dinp[n] : {rcvmon} data to smooth
;   tosmo   : long  number of points to smooth
;               >= 3. The data will be smoothed and decimated by this amount.
;RETURNS:
;   nrecs      : long    number of smoothed records returned
;   dsmo[nrecs]:{rcvmon} smoothed data
;DESCRIPTION:
;   This routine is normally called via rminpday or rmplot
;
;   Smooth the data fields in dinp by tosmo points using a boxcar smoothing.
;Each point is normally sampled every 22 seconds. Fields that are not numeric:
;.stat use the first element of the pnts to smooth.
;
;EXAMPLE:
;-
function rmsmodat,dinp,tosmo,dsmo
;
    if tosmo le 2 then begin
            message,'smoothing must be > 2 points'
    endif
    nrecs=n_elements(dinp)
    nrecsmo=nrecs/tosmo + 16L
    dsmo=replicate(dinp[0],nrecsmo)
    rcvnumfound=lonarr(16)
    icur=0L
    rcvlist=lindgen(16)
    if n_elements(rcvnum) gt 0 then rcvlist=rcvnum
    for i=0,n_elements(rcvlist)-1 do begin
        ircv=rcvlist[i]
        if (rmconfig(ircv) eq 1) then begin
            ind=where((dinp.rcvnum eq ircv),count)
            if count ge tosmo then begin
               aa=select(dinp[ind].stat,tosmo/2,tosmo)
               inew=n_elements(aa)
               aa=''
                ii=icur
                jj=icur+inew-1
     dsmo[ii:jj].key   =dinp[ind[0]].key
     dsmo[ii:jj].rcvnum=dinp[ind[0]].rcvnum
     dsmo[ii:jj].stat  =select(dinp[ind].stat,tosmo/2,tosmo)
     dsmo[ii:jj].year  =select(smooth(dinp[ind].year,tosmo,/edge),tosmo/2,tosmo)
     dsmo[ii:jj].day=select(smooth(dinp[ind].day,tosmo,/edge),tosmo/2,tosmo)
     dsmo[ii:jj].T16k=select(smooth(dinp[ind].T16K,tosmo,/edge),tosmo/2,tosmo)
     dsmo[ii:jj].T70k=select(smooth(dinp[ind].T70K,tosmo,/edge),tosmo/2,tosmo)
     dsmo[ii:jj].Tomt=select(smooth(dinp[ind].Tomt,tosmo,/edge),tosmo/2,tosmo)
 dsmo[ii:jj].pwrP15=select(smooth(dinp[ind].pwrP15,tosmo,/edge),tosmo/2,tosmo)
 dsmo[ii:jj].pwrN15=select(smooth(dinp[ind].pwrN15,tosmo,/edge),tosmo/2,tosmo)
 dsmo[ii:jj].postampP15=select(smooth(dinp[ind].postampP15,tosmo,/edge),$
                                tosmo/2,tosmo)
                for k=0,2  do begin
     dsmo[ii:jj].dcur[k,0]=select(smooth(dinp[ind].dcur[k,0],tosmo,/edge),$
                                tosmo/2,tosmo)
    dsmo[ii:jj].dcur[k,1]=select(smooth(dinp[ind].dcur[k,1],tosmo,/edge),$
                                tosmo/2,tosmo)
    dsmo[ii:jj].dvolts[k,0]=select(smooth(dinp[ind].dvolts[k,0],tosmo,/edge),$
                                tosmo/2,tosmo)
    dsmo[ii:jj].dvolts[k,1]=select(smooth(dinp[ind].dvolts[k,1],tosmo,/edge),$
                                tosmo/2,tosmo)
                endfor
                icur=icur+inew
            endif  ; count ge smo
        endif      ; rmconfig eq 1
    endfor  ; i =0,15
    nrecs=icur
    if nrecs ne nrecsmo then dsmo=dsmo[0:nrecs-1]
;
;       put back in date order
;
    ind=sort(dsmo.day)
    dsmo=dsmo[ind]
    return,nrecs
end
