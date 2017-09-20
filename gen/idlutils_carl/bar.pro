
pro bar,i,imax

;+
;
; A program to create a progress bar within a loop. use LOOP_BAR instead!!
;
; Call sequence:
;   BAR, I, IMAX
;
; Inputs:
;   I - The index being advanced in the loop.
;   IMAX - The value at the loop's finish.
;
; Outputs:
;   Prints out a simple empty bar that fills up with 10 dashes as the
;   loop completes.
;
; Calls:
;   DELVARX (Goddard Routine)
;
;Katie Peek August 2004
;-

;Define variable types.
imax = float(imax)

stop, 'YOU ARE USING "BAR"; USE "LOOP_BAR" INSTEAD!!!!'

;Set up printout
done = fix(10.0*i/imax)
notdone = 10 - done

if (i eq 0) then begin
  common times,starttime
  starttime = systime(/julian)
endif
if (done eq 0) then print,format='(%" [>         ] %s \r",$)',systime(0)
if ((done ge 1) and (notdone gt 1)) then $
  print,format='(%" [%s%s%s%s%s%s%s%s%s%s] %s \r",$)', $
  replicate('-',done),'>',replicate(' ',notdone-1),systime(0)
if (notdone eq 1) then print,format='(%" [--------->] %s \r",$)',systime(0)
if (notdone eq 0) then print,format='(%" [----------] %s \r",$)',systime(0)
if ( (i-1) eq imax) then begin
  common times,starttime
  endtime = systime(/julian)
  totaltime = endtime - starttime - 0.5  ;subtract Julian half-day
  print,format='(%" [----------]  %s ",C(CHI2.2,":",CMI2.2,":",CSF5.2,TL5,CSI2.2))','Total loop time:',totaltime
  delvarx,starttime
endif

end  


