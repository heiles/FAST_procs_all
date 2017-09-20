;+ 
;NAME:
;hardcopy - flush the postscript data to disc.
;SYNTAX: hardcopy
;ARGS:   none
;DESCRIPTION:
;   Flush the postscript buffers to disc. Call this routine before
;swithing back to x windows display.
;SEE ALSO:
;ps,pscol,psimage, x
;-
pro hardcopy
device, /close
return
end

pro hard
hardcopy
end

