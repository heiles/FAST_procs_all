pro sharpcorners, COLOR=color, THICK=thick
;+
; NAME:
;       SHARPCORNERS
;
; PURPOSE:
;       If you look closely, especially if you make your axes thick,
;       the corners of your plots are not sharp.  (Try example below.)
;       This procedure makes sharp corners on your plot.
;
; CALLING SEQUENCE:
;       SHARPCORNERS [, COLOR=value] [, THICK=value]
;
; INPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       COLOR = color index of the axes.
;       THICK = thickness of the axes.
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       Plot corners are now sharp!
;
; RESTRICTIONS:
;       The thickness of the X and Y axes must be the same.
;
; EXAMPLE:
;       IDL> plot, findgen(5), XTHICK=5, YTHICK=5
;       IDL> sharpcorners, THICK=5
;
; MODIFICATION HISTORY:
;   26 Apr 2004  Written by Tim Robishaw, Berkeley
;   19 Aug 2005  TR: have to redraw the first leg after the other four in order
;                for PostScript plots to have the first corner sharp.  This is
;                weird since it's not necessary for X windows.
;-

if n_elements( thick) eq 0 then thk=!x.thick else thk=thick

plots, !x.window[[0,0]], !y.window[[0,1]], /NORMAL, COLOR=color, THICK=thk
plots, !x.window[[0,1]], !y.window[[1,1]], /NORMAL, COLOR=color, THICK=thk
plots, !x.window[[1,1]], !y.window[[1,0]], /NORMAL, COLOR=color, THICK=thk
plots, !x.window[[1,0]], !y.window[[0,0]], /NORMAL, COLOR=color, THICK=thk
plots, !x.window[[0,0]], !y.window[[0,1]], /NORMAL, COLOR=color, THICK=thk

end; sharpcorners
