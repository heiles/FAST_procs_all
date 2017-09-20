function indx2dim, array, index_array, $
                   N_DIMENSIONS=ndim, DIMENSIONS=dims
;+
; NAME:
;       INDX2DIM
;
; PURPOSE:
;       Converts one-dimensional indices into multidimensional indices.
;
; CALLING SEQUENCE:
;       Result = INDX2DIM(Array, Index_Array, [, 
;       N_DIMENSIONS=variable][, DIMENSIONS=variable] )
;
; INPUTS:
;       ARRAY: a multidimensional array 
;       INDEX_ARRAY: array of one-dimensional indices in ARRAY
;
; OUTPUTS:
;       Returns an N_DIMENSIONS by N_elements(index_array) array with
;       the multidimensional array indices corresponding to each 
;       one-dimensional array index stored in index_array.  If any of
;       the input one-dimensional indices are greater than the number
;       of total elements in the input array (or less than zero) then
;       the multidimensional index returned for each such out-of-range
;       index will be a row of -1L.
;
; OPTIONAL OUTPUTS:
;       N_DIMENSIONS = the number of dimensions of ARRAY
;       DIMENSIONS = the dimensions of ARRAY; a vector of length N_DIMENSIONS
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; EXAMPLE:
;       Make a 4-D array...
;       IDL> x = indgen(2,3,4,5)
;
;       Use WHERE to get the 1-D indices for where array is multiple
;       of 25...
;       IDL> indx = where(x mod 25 eq 0, nindx)
;
;       Return the multidimensional array indices 
;       IDL> dim = indx2dim(x,indx,N_DIMENSIONS=ndim,DIMENSIONS=dims)
;
;       Check the dimensions of the array x...
;       IDL> print, dims
;                  2           3           4           5
;
;       Check the size of the returned multidimensional array; it should
;       be N_DIMENSIONS by N_elements(indx)...
;       IDL> help, ndim, nindx, dim
;       NDIM            LONG      =            4
;       NINDX           LONG      =            5
;       DIM             LONG      = Array[4, 5]
;
;       Finally, what are the multidimensional indices...
;       IDL> print, dim
;                  0           0           0           0
;                  1           0           0           1
;                  0           1           0           2
;                  1           1           0           3
;                  0           2           0           4
;
; NOTES:
;       This routine now exists in IDL 6.0 and is named
;       ARRAY_INDICES(). However, if you pass in an index that is out
;       of bounds, ARRAY_INDICES() crashes and gives a warning.
;
;       The returned array has size N_DIMENSIONS by N_elements(index_array).
;       This is because the user will most likely be using a loop to access
;       each of the returned multidimensional indices: it is faster to loop
;       over the second dimension of the returned 2-D array. E.g., in the
;       above example, you would access each of the multidimensional
;       indices like this...
;
;       IDL> for i = 0, nindx-1 do print, dim[*,i]
;
;       We are accessing each row, which is faster than accessing each
;       column, hence my choice for the orientation of the returned array.
;
; MODIFICATION HISTORY:
;   15 Feb 2004  Written by Tim Robishaw, Berkeley
;-

on_error, 2

; IS EITHER INPUT ARRAY EMPTY...
if (N_elements(array) eq 0) then message, 'The input array is undefined.'
if (N_elements(index_array) eq 0) then $
  message, 'The input index array is undefined.'

; GET THE SIZE OF THE ARRAY...
sz = size(array)

; HOW MANY DIMENSIONS IN THE ARRAY...
ndim = sz[0]

; CHECK FOR CASE WHERE ARRAY IS A SCALAR...
if (ndim eq 0) then begin
    if arg_present(dims) then dims = 0L
    return, (transpose([index_array]) eq 0L)-1L
endif

; WHAT ARE THE DIMENSIONS...
dims = sz[1:ndim]

; CHECK FOR OUT-OF-RANGE INDICES...
out_of_range = where( (index_array ge sz[ndim+2]) OR $
                      (index_array lt 0L), N_out_of_range)

; GET THE SUBSCRIPT POSITION FOR EACH DIMENSION...
subscript_array = [index_array mod dims[0]]
denom = 1L
for i = 1L, ndim-1L do begin
    denom = denom * dims[i-1]
    subscript_array = [ [subscript_array], $
                        [index_array / denom mod dims[i]] ]
endfor

; TRANSPOSE FOR MAXIMUM SPEED WHEN ACCESSING RETURNED ARRAY...
subscript_array = transpose(subscript_array)

; FOLLOW WHERE'S LEAD; FILL OUT-OF-RANGE INDICES WITH -1L...
if (N_out_of_range gt 0) then subscript_array[*,out_of_range] = -1L

return, subscript_array

end; indx2dim
