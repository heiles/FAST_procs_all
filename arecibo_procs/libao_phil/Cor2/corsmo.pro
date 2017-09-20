;+
;NAME:
;corsmo - smooth correlator data.
;SYNTAX: corsmo,b,bsmo,smo=nchn,savgol=degree
;ARGS: 
;     b[n]:  {corget} data to boxcar smooth
;   smo[n]:  {corget} return smoothed data here. Note.. if only 1 argument
;                    is passed to the routine then the data is smoothed in
;                    place (it is returned in b).
;   savgol: int     Perform savitzky-golay smoothing filter (see idl savgol
;                   routine). Fit a polynomial of order degree to nchn
;                   at a time (degree must be less than nchn). 
;KEYWORDS:
;     smo:  int     number of channels to smooth. default is 3
;
;DESCRIPTION:
;   corsmo will smooth the data in the structure b. By default boxcar
;smoothing is performed. The savgol keyword will smooth by fitting a polynomial
;of order "degree" to "nchn"'s at a time (see idl savgol documentation with 
;order=0).
;   If a single argument is passed to the routine, then the smoothed data is 
;returned in place. If two arguments are passed in (b,bsmo) then the data is
;returned in the second argument. If b is an array of records then each one
;will be smoothed individually.
;
;   The edge points will only be smoothed by the number of available datapoints
;on each side (see the idl /edge_truncate keyword in the smooth() or savgol
;routine).
;
;EXAMPLE:
;   print,corget(lun,b)
;   corsmo,b            ; this smooths the data and returns it in b.
;   print,corget(lun,b)
;   corsmo,b,bsmo       ; this smooths the data and returns it in bsmo
;;  input an entire scan then smooth each record by 9 channels.
;   print,corinpscan(lun,b)
;   corsmo,b,bsmo,smo=9
;;
;;  use polynomial smoothing of order 3 on 31 points at a time.
;   corsmo,b,bsmo,smo=31,savgol=3
;-
;modhistory
;03may02 - created
;15may02 - used ntags rather than grpsTotRec in case they averaged pols.
;16aug02 - bug smooth 4sbc. fixed..
pro corsmo,b,bsmo,smo=smo,savgol=savgol
;
; smooth the data in b
;
    forward_function savgol
on_error,2
;
nrecs=n_elements(b)
if not keyword_set(smo) then     smo=3.
if not keyword_set(savgol) then  savgol=0
if keyword_set(savgol)  then begin
    if (!version.release le '5.3') then $
        message,'savgol keyword can only be use in idl 5.4 or greater'
    if  (smo le savgol) then $
        message,'savgol degree must be less than the number of smoothed points")
end
            
nbrds=n_tags(b[0])
nsbc=intarr(nbrds)
for i=0,nbrds-1 do begin
    a=size(b[0].(i).d)
    if a[0] eq 1 then begin
        nsbc[i]=1
    endif else begin
        nsbc[i]=a[2]
    endelse
endfor
;
    if keyword_set(savgol) then coef=savgol(smo/2,smo/2,0,savgol,/double)

;
if n_params() eq 2 then  begin
    bsmo=b
    for k=0,nrecs-1 do begin
    for i=0 , nbrds-1 do begin
     for j=0 , nsbc[i]-1 do  begin
         if keyword_set(savgol) then begin
            bsmo[k].(i).d[*,j]=convol(b[k].(i).d[*,j],coef,/edge_truncate)
         endif else begin
            bsmo[k].(i).d[*,j]=smooth(b[k].(i).d[*,j],smo,/edge_truncate)
         endelse
     endfor
    endfor
    endfor
endif else begin
    for k=0,nrecs-1 do begin
    for i=0 , nbrds-1 do begin
     for j=0 , nsbc[i]-1 do  begin
         if keyword_set(savgol) then begin
            b[k].(i).d[*,j]=convol(b[k].(i).d[*,j],coef,/edge_truncate)
         endif else begin
            b[k].(i).d[*,j]=smooth(b[k].(i).d[*,j],smo,/edge_truncate)
         endelse
     endfor
    endfor
    endfor
endelse
return
end
