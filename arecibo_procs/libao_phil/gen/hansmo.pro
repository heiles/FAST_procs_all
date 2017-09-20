;+
;NAME:
;hansmo - hanning smooth a dataset
;SYNTAX: dsmo=hansmo(d)
;ARGS: 
;    d[m,n]:  float/double data to smooth
;RETURNS:
; dsmo[m,n]: the smoothed data.
;
;DESCRIPTION:
;   hansmo will hanning smooth the data in the array d. d can be 1 or
;more dimensions. It will smooth m points at a time.
;   The smoothing is done by convolution in the input domain.
;
;EXAMPLE:
;   d=fltarr(1024,4)
;   ...
;   dsmo=hansmo(d)
;
;   In this example the smoothing would be:
;   for i=0,3 do dsmo[*,i]=hanningSmooth(d[*,i])
;-
;modhistory
function hansmo,d
;
; hanning smooth the data in d
;
;on_error,2
;
;
;
sz=size(d)
ndim=sz[0]
rsize=[sz[1:ndim]]
tosmo=1
for i=0,ndim-2 do tosmo=tosmo*rsize[i+1]
if ndim gt 1 then d=reform(d,rsize[0],tosmo,/overwrite)
han=[.5,1.,.5]
dsmo=d
;
for i=0,tosmo-1 do dsmo[*,i]=convol(d[*,i],han,2.,/edge_truncate)
if ndim gt 1 then begin
    d=reform(d,rsize,/overwrite)
    dsmo=reform(dsmo,rsize,/overwrite)
endif
return,dsmo
end
