Pro Errplot_x, Low, High, Y, Width = width
;+
; NAME:
;ERRPLOT_X -- Plot error bars IN THE X DIRECTION over a previously drawn plot.
;
; PURPOSE:
;	Plot error bars IN THE X DIRECTION over a previously drawn plot.
;
; CATEGORY:
;	J6 - plotting, graphics, one dimensional.
;
; CALLING SEQUENCE:
;	ERRPLOT_X, Low, High, Y
;
; INPUTS:
;	Low:	A vector of lower estimates, equal to Xdata - error.
;	High:	A vector of upper estimates, equal to Xdata + error.
;	Y:	A vector containing the ordinate (Y-values).
;
; KEYWORD Parameters:
;	WIDTH:	The width of the error bars, in units of the width of
;	the plot area.  The default is 1% of plot width.
;
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	An overplot is produced.
;
; RESTRICTIONS:
;	Logarithmic restriction removed.
;
; PROCEDURE:
;	Error bars are drawn for each element.
;
; EXAMPLES:
;	To plot symmetrical error bars where X = data values and 
;	ERR = symmetrical error estimates, enter:
;
;		PLOT, X, Y			;Plot data
;		ERRPLOT_x, X-ERR, X+ERR, Y	;Overplot error bars.
;
;	If error estimates are non-symetrical, enter:
;
;		PLOT, X, Y
;		ERRPLOT, Upper, Lower, Y	;Where Upper & Lower are bounds.
;
; MODIFICATION HISTORY:
;	DMS, RSI, June, 1983.
;
;	Joe Zawodney, LASP, Univ of Colo., March, 1986. Removed logarithmic
;	restriction.
;
;	DMS, March, 1989.  Modified for Unix IDL.
;       KDB, March, 1997.  Modified to used !p.noclip
;       RJF, Nov, 1997.    Removed unnecessary print statement
;			   Disable and re-enable the symbols for the bars
;	DMS, Dec, 1998.	   Use device coordinates.  Cleaned up logic.
;	Carl Heiles nov 26 2001. Pirated idl's errplot, which does
;	the y direction, and changed it to do the x direction.
;-
on_error,2                      ;Return to caller if an error occurs
if n_params(0) ge 3 then begin	;X specified?
    right = high
    left = low
    yy = y
endif else begin                ;Only 2 params
    PRINT, 'NOT ENOUGH PARAMETERS IN CALL!'
    RETURN
endelse

w = ((n_elements(width) eq 0) ? 0.01 : width) * $ ;Width of error bars
  (!x.window[1] - !x.window[0]) * !d.x_size * 0.5
n = n_elements(right) < n_elements(left) < n_elements(yy) ;# of pnts

for i=0,n-1 do begin            ;do each point.
    xy0 = convert_coord(left[i], yy[i], /DATA, /TO_DEVICE) ;get device coords
    xy1 = convert_coord(right[i], yy[i], /DATA, /TO_DEVICE)

    plots, [replicate(xy0[0],3), replicate(xy1[0],3)], $
	[xy0[1] + [-w, w,0], xy1[1] + [0, -w, w]], $
      NOCLIP=!p.noclip, PSYM=0, /DEVICE

;    plots, [xy0[0] + [-w, w,0], xy1[0] + [0, -w, w]], $
;      [replicate(xy0[1],3), replicate(xy1[1],3)], $
;      NOCLIP=!p.noclip, PSYM=0, /DEVICE
endfor
end
