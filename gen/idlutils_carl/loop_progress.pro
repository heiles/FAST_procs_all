pro loop_progress, indx, lim0, lim1
;+
; NAME:
;       LOOP_PROGRESS
;
; PURPOSE:
;       Update the progress inside a loop.
;
; CALLING SEQUENCE:
;       LOOP_PROGRESS, index, limit0, limit1
;
; INPUTS:
;       INDX: the index for the loop.  If this is called within a single
;             loop then INDX should be a scalar.  If this is called within
;             nested loops, then INDX should be a vector with each value
;             representing the index for each loop; the order is important
;             with the index of the innermost loop coming first and that of
;             the outermost loop last.
;
;       LIM0: the starting index for the loop.  A scalar or vector.  As
;             above, for a vector the order must increase from the inner
;             loop index to the outer loop index.
;
;       LIM1: the stopping index for the loop.  A scalar or vector. As
;             above, for a vector the order must increase from the inner
;             loop index to the outer loop index.
;
; OUTPUTS:
;       None.
;
; SIDE EFFECTS:
;       A progress indicator is written to the IDL window.  If nothing else
;       is printed to the IDL window inside the loop, the progress status
;       will be overwritten and therefore only take up a single line in the
;       IDL window.  If anything else is written to the IDL window, a new
;       line will be produced for every progress update.
;
; RESTRICTIONS:
;       The input parameters must all have the same size.  Since this
;       routine is designed to help the user gauge the speed of a long
;       loop, there is no sense in adding checks for this and slowing
;       things down.  
;
; EXAMPLES:
;       for k = 20, 41 do $
;        for j = 0, 53 do $
;         for i = 99, 103 do $
;          loop_progress, [i,j,k], [99,0,20], [103,53,41]
;
;       na = N_elements(a)
;       for i = 0, na-1 do $
;        loop_progress, i, 0, na-1
;
; MODIFICATION HISTORY:
;	Written by Tim Robishaw, Berkeley  26 Jun 2008
;-

; WE COULD CHECK TO SEE THE USER HAS INPUT THE SAME SIZE INDX, LIM0, AND
; LIM1 ARRAYS.  SINCE THIS IS INSIDE A LOOP, THERE IS NO SENSE IN RUNNING
; CHECKS AND SLOWING THE LOOP DOWN!!  THE USER SHOULD BE CAREFUL TO READ
; THIS DOCUMENTATION BEFORE USING.

n_indx = N_elements(indx)

size = lim1 - lim0 + 1l

total_size = product(size, /CUMULATIVE)
this_indx = indx[0]-lim0[0]
for i = 1, n_indx-1 do $
   this_indx = this_indx + (indx[i]-lim0[i])*total_size[i-1]

print, 100*float(this_indx)/(total_size[n_indx-1]-1), $
       FORMAT='($,"Progress: ",I4,"%",%"\R")'

end ; loop_progress
