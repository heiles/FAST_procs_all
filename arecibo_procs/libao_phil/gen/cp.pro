;+
;NAME:
;cp - read cursor position after button press.
;
;SYNTAX: cp,x=x,y=y,/up,/down,/change,/nowait,/data,/device,/normal
;ARGS  :  none
;KEYWORDS:
;   up : if set then wait for button up event
; down : if set then wait for button down event
;change: if set then wait for button change event
;nowait: if set then return immediately with the current x,y values
;data  : if set then return x,y in data coordinates (default)
;device: if set then return x,y in device (screen) coordinates
;normal: if set then return x,y in normalized device coordinates (0.,1.) 
;   x  : float return x value here
;   y  : float return y value here
;
;DESCRIPTION:
;   This routine calls the idl cursor routine. The keywords are the
;same as cursor. By default the routine waits for the  cursor to be
;depressed (or the cursor is already down). It then
;reads the x,y coordinates, prints them out, and then returns.
;
;   If you want to loop reading the cursor n times with a button push
;on each step of the loop , then you need to use /up or /down.
;   
;EXAMPLE:
;   plot,findgen(100)
;   cp
;   .. user clicks left button at desired position on plot.
;   24.0208   23.2295   .. x,y positions printed out.
;
;NOTE:
;   If the window system is set so that the window focus follows the cursor, 
;then you must make sure that the cursor is in the idl input window before
;you enter the command cp. 
;
;SEE ALSO: The idl routine cursor for a descriptoin of the keywords.
;-
pro cp,x=x,y=y,_extra=e

cursor,x,y,_extra=e
print,x,y
return
end
