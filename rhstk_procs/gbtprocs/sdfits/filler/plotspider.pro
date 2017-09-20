pro plotspider, Pattern
; PLOT OUT THE AZOFFSET AND ZA OFFSET FOR SPIDER PATTERNS...

; PLOT THE OFFSET PATTERN...
plot, [0], /xs, /ys, yr=0.8*[-1,1], xr=0.8*[-1,1], $
      xtit='AZ Offset [Degrees]', ytit='ZA Offset [Degrees]'

; IS THE PATTERN COMPLETE...
NScans = N_elements(Pattern)
complete = (NScans eq 4)
if complete then begin
   legs = intarr(4)
   for i = 0, NScans-1 do legs[i] = (*Pattern[i]).NSubScan
   complete = array_equal(legs,shift(legs,1))
endif

setcolors, /SYSTEM_VARIABLES, /SILENT
color = complete ? !green : !red

; GET CHARACTER SIZE IN DATA UNITS...
xchar = float(!d.x_ch_size)/!d.x_vsize * !x.s[1]
ychar = float(!d.y_ch_size)/!d.y_vsize * !y.s[0]

for i = 0, NScans-1 do begin

  oplot, (*Pattern[i]).SubScan.AZOffSet, $
         (*Pattern[i]).SubScan.ZAOffSet, $
         ps=4, co=color

  scans = (i gt 0) ? [scans, (*Pattern[i]).ScanNum] : (*Pattern[i]).ScanNum

  xyouts, (*Pattern[i]).SubScan[0].AZOffSet+0.05, $
          (*Pattern[i]).SubScan[0].ZAOffSet-0.05, $
          strtrim(i+1,2)
  ;xyouts, (*Pattern[i]).SubScan[0].AZOffSet-2.5*xchar, $
  ;        (*Pattern[i]).SubScan[0].ZAOffSet-2.5*ychar, $
  ;        strtrim(i+1,2)

endfor

xyouts, .15, .88, /norm, 'Scans: '+strjoin(strtrim(Scans,2),', ',/SINGLE)

;wait, 0.3
end; plotspider
