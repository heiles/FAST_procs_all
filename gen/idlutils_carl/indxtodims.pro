pro indxtodims, array, indx, dims, direction
;+
;NAME:
;INDXTODIMS --  convert between a 1-d index and an n-dimensional index or vice-versa
;
;PURPOSE:
;    converts between a 1-d index and an n-dimensional index for an
;	array of the given size. Goes either direction.
;
;CALLING SEQUENCE:
;	INDXTODIMS, array, indx, dims, direction
;
;INPUTS:
;	ARRAY: an N-dimensional input array. Not changed or used except
;to define the dimensions for which the outputs are computed.
;	INDX: the one-d index. an INPUT if direction=+1, an OUTPUT otherwise.
;	DIMS: a vector of size N containing the three indices in N-d space.
;An INPUT if direction=-1, an OUTPUT otherwise.
;	direction: the direction of conversion: 
;		+1 to go from INDX ---> DIMS
;		-1 to go from DIMS ---> INDX
;
;IMPORTANT: INDX can be an N-element array, where N is the nr of indices
;		to treat.
;	    DIMS can be an N by M element array, where N is the nr of indices
;		to treat and M is the nr of dimensions in ARRAY.
;OUTPUTS:
;	indx: the one-d index. an INPUT if direction=+1, an OUTPUT otherwise.
;If indx is an INPUT, it may be a 1-d array, in which case dims will
;be an array whose first dimension is that of indx.
;	dims: a vector of size N containing the three indices in N-d space.
;An INPUT if direction=-1, an OUTPUT otherwise.
;
;EXAMPLE:
;	you have a 3-d vector X(541,541,9) and a 1-d index returned from
;the 'where' function equal to 880212.
;
;	INDXTODIMS, X, 880212, dims, +1
;
;returns dims=[5,4,3].
;HISTORY:
;	Written by Carl Heiles. 18 Sep 1998.
;-

arraysize = size(array)

if (direction eq 1) then begin
indxsize = n_elements(indx)
dims = lonarr(indxsize, arraysize[0])
indxremain = indx
multiplier = n_elements(array)
for nr = arraysize[0]-1l, 0l, -1l do begin
	multiplier = multiplier/arraysize[nr+1l]
	dims[*, nr] = indxremain/multiplier
	indxremain = indxremain - dims[*,nr]*multiplier
	;print, nr, indx, multiplier, dims[nr]
endfor
endif


if (direction eq -1) then begin
dimz=dims
dimssize = size(dims)
if (dimssize[0] eq 1) then dims=reform(dimz,1,dimssize[1])
indx = lonarr(dimssize[1])
multiplier = 1l
for nr = 0l, arraysize[0]-1l do begin
indx = indx + multiplier*dims[*,nr]
;print, nr, ' 0', indx[0], multiplier, dims[0,nr]
;print, nr, ' 1', indx[1], multiplier, dims[1,nr]
multiplier=multiplier*arraysize[nr+1]
endfor
dims=dimz
endif

;print, 'indx = ', indx
;print, 'dims = ', dims
;stop
return
end

