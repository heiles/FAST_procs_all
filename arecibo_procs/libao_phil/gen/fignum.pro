;+
;NAME:
;fignum - put figure number on the page
;
;SYNTAX: nextnum=fignum(fnum,xp=xp,ln=ln)
;ARGS  : 
;       fnum    : int   figure number to put on plot. 1..
;KEYWORDS:
;       xp      : float 0..1 xposition for start of FIG N
;       ln      : int   3..33 linenumber for FIG N
;RETURNS:
;       nextnum : int   input value incremented by 1
;
;DESCRIPTION:
;   fignum() will place the string FIG fnum on the plot for you. The 
;horizontal position defaults to .92 of the screen (where the screen goes
; 0..1 horizontally). The vertical position is set  to 3 where the vertical
;screen runs 0 through 33.
;
;NOTE:  
;   the vertical line numbers are for the entire screen. If you use !p.multi
;then you will have to decrease ln= by the corresponding amount.
;
;SEE ALSO: note
;-
function    fignum,fnum,xp=xp,ln=ln 
    if n_elements(xp) eq 0 then xp=.92
    if n_elements(ln) eq 0 then ln=3
    note,ln,string(format='("FIG ",i2)',fnum),xp=xp
    return,fnum+1
end
