function graphselect, x, y, n, NOFILL=nofill, RESTORE=restore
;+
; NAME:
;       GRAPHSELECT
;
; PURPOSE:
;	Select points within an area of a graph defined by the cursor.
;       Return the indices of these points.
;
; CALLING SEQUENCE:
;       Result = GRAPHSELECT(X, Y [,N][,/NOFILL][,/RESTORE])
;
; INPUTS:
;       X: array of x values on the plot.
;       Y: array of y values on the plot.
;
; KEYWORD PARAMETERS:
;       /NOFILL - Set this keyword to inhibit filling of the 
;                 defined region on completion. 
;       /RESTORE - Set this keyword to restore the display to its 
;                  original state upon completion.  N.B., this
;                  doesn't do such a great job, but that's DEFROI's
;                  fault!
;
; OUTPUTS:
;       Returns the indices of the points that are within the 
;       selected area.
;
; OPTIONAL OUTPUTS:
;       N: the number of points inside the selected area.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       The area selected is drawn on the plot window and, unless the 
;       /NOFILL keyword is set, filled in.
;
; RESTRICTIONS:
;       Only works for interactive, pixel oriented devices with a cursor.
;       Selected region must have less than 1001 vertices.
;       Can only be used in most recently created window.
;
; PROCEDURES CALLED:
;       DEFROI()
;
; EXAMPLE:
;       Create some x and y values... 
;       IDL> x = indgen(20)
;       IDL> y = randomn(seed,20)
;
;       Plot the points...
;       IDL> plot, x, y, psym=4
;
;       Select a region of the plot and return the indices 
;       of these points...
;       IDL> indx = graphselect(x,y,n_indx)
;
; NOTES:
;       If you are trying to obtain the indices of an image, you need to
;       pass in arrays of x and y values, e.g., they should be arrays of
;       size N_elements(x) by N_elements(y) in which the x array is 
;       repeated in N_elements(y) rows and the y array is repeated in
;       N_elements(x) columns.  The routine will return the indices of
;       points within the selected polygon.
;
; MODIFICATION HISTORY:
;	Written by Carl Heiles. 12 Sep 1998.
;       Souped up by Tim Robishaw 19 Aug 2003.
;-

; IS A WINDOW EVEN OPEN...
if (!d.window eq -1L) then begin
    message, 'No window is open!', /INFO
    return, -1
endif

; DEFROI USES THE !D.TABLE_SIZE-1th COLOR TO OVERPLOT...
; SO, MAKE SURE WE SHUT OFF COLOR DECOMPOSITION...
device, get_decomposed=decomposed
device, decomposed=0
inside = defroi(!d.x_size, !d.y_size, $
                NOFILL=keyword_set(NOFILL), $
                RESTORE=keyword_set(RESTORE))
device, decomposed=decomposed

; MAKE A MASK WHICH IS ZERO OUTSIDE THE SELECTED REGION, ONE INSIDE...
mask = bytarr(!d.x_size,!d.y_size)
mask[inside] = 1B

; CONVERT DATA POINTS FROM DATA COORDINATES TO DEVICE COORDINATES...
data2dev = convert_coord(x,y,/DATA,/TO_DEVICE)
xdev = reform(data2dev[0,*])
ydev = reform(data2dev[1,*])


; RETURN THE INDICES INSIDE THE SELECTED REGION...
return, where(mask[xdev,ydev] eq 1B, n)

end; graphselect

