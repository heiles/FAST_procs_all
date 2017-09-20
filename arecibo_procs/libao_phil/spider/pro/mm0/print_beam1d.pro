 pro print_beam1d, nrc, beamout_arr

;+
;NAME:
;print_beam1d - PRINTS OUT THE 1-D BEAMFITS.
;-

;EXTRACT FROM BEAMOUT...
stripfit= beamout_arr[ nrc].stripfit
sigstripfit= beamout_arr[ nrc].sigstripfit

;COLORS...
stripcolor = [' (RED)', ' (GREEN)', ' (BLUE)', ' (YELLOW)']
striplabel = ['ctr', 'lft', 'rgt']
nstk = 0

FOR nrstrip= 0, 3 do begin 

print, ' ' 
print, 'STRIP NR ', strcompress( string( nrstrip)), stripcolor[nrstrip], $
    '; ZEROS: ', $
    stripfit[ 10, nstk, nrstrip], sigstripfit[ 10, nstk, nrstrip], $
    '; ALPHAS: ', $
    stripfit[ 0, nstk, nrstrip], sigstripfit[ 0, nstk, nrstrip]

print, ' ' 

print, $
'    | <--------------- X + Y -----------------> |     X-Y     |     XY      |     YX    
print, $
' G     HGT    SIG |  CNTR    SIG  |   WID   SIG |   HGT  SIG  |  HGT   SIG  |  HGT   SIG'

for nr=0, 2 do print, striplabel[ nr], $
   stripfit[ 1+nr, 0, nrstrip], sigstripfit[ 1+nr, 0, nrstrip], '|', $
   stripfit[ 4+nr, 0, nrstrip], sigstripfit[ 4+nr, 0, nrstrip], '|', $
   stripfit[ 7+nr, 0, nrstrip], sigstripfit[ 7+nr, 0, nrstrip], '|', $

   stripfit[ 1+nr, 1, nrstrip], sigstripfit[ 1+nr, 1, nrstrip], '|', $
   stripfit[ 1+nr, 2, nrstrip], sigstripfit[ 1+nr, 2, nrstrip], '|', $
   stripfit[ 1+nr, 3, nrstrip], sigstripfit[ 1+nr, 3, nrstrip], $
    format='(a3, 2f7.1, 1x, a1, 2f7.3, 1x, a1, 2f6.2, 1x, a1,' $
    + '2f6.3, 1x, a1, 2f6.3, 1x, a1, 2f6.3)' 

print, ' ' 

print, $
'    | <-------- X-Y ----------> | <---------- XY -----------> | <---------- YX ---------> |'
print, $
' G   SQUINT  SIG | SQUASH  SIG  | SQUINT   SIG | SQUASH SIG   | SQUINT  SIG  | SQUASH  SIG'

for nr=0,0 do print, striplabel[ nr], $
   stripfit[ 4+nr, 1, nrstrip], sigstripfit[ 4+nr, 1, nrstrip], '|', $
   stripfit[ 7+nr, 1, nrstrip], sigstripfit[ 7+nr, 1, nrstrip], '|', $

   stripfit[ 4+nr, 2, nrstrip], sigstripfit[ 4+nr, 2, nrstrip], '|', $
   stripfit[ 7+nr, 2, nrstrip], sigstripfit[ 7+nr, 2, nrstrip], '|', $

   stripfit[ 4+nr, 3, nrstrip], sigstripfit[ 4+nr, 3, nrstrip], '|', $
   stripfit[ 7+nr, 3, nrstrip], sigstripfit[ 7+nr, 3, nrstrip], $
    format='(a3, F7.3, f6.3, 1x, a1, F7.3, f6.3, 1x, a1, F7.3, f6.3, 1x, a1,' $
    + 'F7.3, f6.3, 1x, a1, F7.3, f6.3, 1x, a1, F7.3, f6.3)' 

ENDFOR

end
