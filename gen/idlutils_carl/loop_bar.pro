pro loop_bar,i,imax,imin=imin

;+
;
; LOOP_BAR
; A program to create a progress bar within a loop.
;
; Call sequence: The last statement of your FOR loop should be, 
;   LOOP_BAR, I, IMAX [, IMIN=integer]
;
; Inputs:
;   I - The index being advanced in the loop.
;   IMAX - The value at the loop's finish.
;
; Outputs:
;   Prints out a simple empty bar that fills up with 10 dashes as the
;   loop completes.  Also prints percent complete and estimates time
;   remaining.
;
; Keyword:
;   IMIN - Include if IMIN is nonzero.  Default IMIN = 0.
;
; Calls:
;   DELVARX (Goddard Routine)
;
; Katie Peek / August 2004
;  Updated to include remaining time estimate - August 2005
; bug (not properly finishing) fixed - CH - 29nov2006
;
;-

;Define variable types.
imax = float(imax)
if (n_elements(imin) eq 0) then imin = 0 else $
if keyword_set(imin) then imin=imin else imin=0

;Save start time for later calculations.
if (i eq imin) then begin
  common times,start_time
  start_time = systime(/julian)
endif

;Set up printout
  ;Bar
done = fix(10.0*(i-imin)/imax)
notdone = 10 - done
  ;Information
percent_done = round(((i-imin)/imax)*100.)
if (percent_done eq 0) then begin
  info = '0%'
  goto,first
endif
  ;Calculate remaining time
current_time = systime(/julian)
elapsed_time = current_time - start_time; - 0.5 ;Julian half-day (why?)
est_tot_time = elapsed_time/(percent_done/100.); + 0.5
remain_time = est_tot_time - elapsed_time
  ;Less than a day
if (remain_time lt 1.0) then begin
  hrs = floor(remain_time*24)
  min = floor((remain_time*24 - hrs)*60)
  sec = floor(((remain_time*24 - hrs)*60 - min)*60)
  if (hrs lt 10.) then hrs_str = '0'+strtrim(string(hrs),2) $
                  else hrs_str = strtrim(string(hrs),2)
  if (min lt 10.) then min_str = '0'+strtrim(string(min),2) $
                  else min_str = strtrim(string(min),2)
  if (sec lt 10.) then sec_str = '0'+strtrim(string(sec),2) $
                  else sec_str = strtrim(string(sec),2)
  time_left = hrs_str+':'+min_str+':'+sec_str
endif
  ;More than a day
if (remain_time ge 1.0) then begin
  day=floor(remain_time)
  new_time = remain_time - float(day)
  hrs = floor(remain_time*24)
  min = floor((remain_time*24 - hrs)*60)
  sec = floor(((remain_time*24 - hrs)*60 - min)*60)
  if (day eq 1)   then day_str = strtrim(string(day),2)+' day + ' $
                  else day_str = strtrim(string(day),2)+' days + '
  if (hrs lt 10.) then hrs_str = '0'+strtrim(string(hrs),2) $
                  else hrs_str = strtrim(string(hrs),2)
  if (min lt 10.) then min_str = '0'+strtrim(string(min),2) $
                  else min_str = strtrim(string(min),2)
  if (sec lt 10.) then sec_str = '0'+strtrim(string(sec),2) $
                  else sec_str = strtrim(string(sec),2)
  time_left = day_str+hrs_str+':'+min_str+':'+sec_str
endif
  ;String to be printed at each iteration.
info = strtrim(string(percent_done),2)+'%, Time remaining: ~'+time_left

first: ;Skip all the "time remaining" stuff if percent_done = 0.

; I n   L o o p 
;Beginning
if (i eq imin) then print,format='(%" [>         ] %s")','Start time: '+systime(0)
if ((done eq 0) and (i ne imin)) $
  then print,format='(%" [>         ] %s \r",$)',info
;Middle
if ((done ge 1) and (notdone gt 1)) then $
  print,format='(%" [%s%s%s%s%s%s%s%s%s%s] %s \r",$)', $
  replicate('-',done),'>',replicate(' ',notdone-1),info
if (notdone eq 1) then print,format='(%" [--------->] %s \r",$)',info
;End
if (notdone eq 0) then print,format='(%" [----------] %s \r",$)',info
if ((i-1) eq imax) then begin
  common times,start_time
  end_time = systime(/julian)
  total_time = end_time - start_time - 0.5 ;subtract Julian half-day
  ;Shorter loops (less than a day)
  if (total_time lt 0.5) then print,format='(%" [----------]  %s ",C(CHI2.2,":",CMI2.2,":",CSF5.2,TL5,CSI2.2))','Total loop time:',total_time
  ;Longer loops (more than a day)
  if (total_time ge 0.5) then begin
    day=floor(total_time+0.5)
    ;One day (to get plurals right)
    if (day eq 1) then print,format='(%" [----------]  %s %o day + ",C(CHI2.2,":",CMI2.2,":",CSF5.2,TL5,CSI2.2))','Total loop time:',day,total_time-day
    ;Two or more days (for correct plurals)
    if (day ne 1) then print,format='(%" [----------]  %s %o days + ",C(CHI2.2,":",CMI2.2,":",CSF5.2,TL5,CSI2.2))','Total loop time:',day,total_time-day
  endif
  delvarx,start_time
endif

end  

