pro scancheck, proj, BAD=bad
; THIS ONLY WORKS FOR SPECTRAL PROCESSOR OR SPECTROMETER DATA...

on_error, 2

; FIND THE LOCATION OF THIS PROJECT...
ProjDataPath = GetGBTDataPath(proj)

message, 'Project Data stored in '+strtrim(ProjDataPath,2), /INFO

; GET DATA FROM THE SCANLOG...
f = getscanlog(ProjDataPath,/SILENT)

; GRAB THE SCAN NUMBERS AND SOURCE NAMES...
scan   = f.scan
source = f.source

; GO TO THE BACKEND FITS FILES AND GET NUMBER OF SUBSCANS...
scanlen   = N_elements(scan)
nsubscans = intarr(scanlen)
for i = 0, scanlen-1 do begin
    ; ARE WE USING THE SPECTRAL PROCESSOR...
    SPIndx = where(strmatch(f[i].device,'SpectralProcessor'),nmatch)
    ; IF NOT, HOW ABOUT THE SPECTROMETER...
    if (nmatch eq 0) $
      then SPIndx = where(strmatch(f[i].device,'Spectrometer'),nmatch)
    ; IF NOT USING EITHER BACKEND, MOVE ON...
    if (nmatch eq 0) then continue
    if (nmatch gt 1) then spindx = spindx[0]
    ; TEST TO SEE IF THE FILE ACTUALLY EXISTS...
    if file_test(f[i].filepath[SPIndx]) then begin
        ; GET THE DATA EXTENSION OF THE FILE...
        data_ext = strmatch(f[i].device[SPIndx],'SpectralProcessor') ? 3 : 5
        hdr = headfits(f[i].filepath[SPIndx],EXTEN=data_ext,ERRMSG=useless)
        ; IF HEADFITS FUCKS UP, RETURNS -1 INSTEAD OF STRING...
        if (size(hdr,/TYPE) eq 7) $
          then nsubscans[i] = sxpar(hdr,'NAXIS2')
    endif
endfor

; PUT THE USEFUL DATA TOGETHER...
scans = [[string(scan,format='(I4)')],$
	 [string(nsubscans,format='(I4)')],$
	 [string(source)]]

; PRINT OUT FOUL SCANS...
if keyword_set(BAD) then begin
    foul = where(scans[*,1] eq 0,nfoul)
    if (nfoul eq 0) then begin
        print, 'No bad scans.'
        return
    endif
    print, 'Bad scans:'
    scans = scans[foul,*]
    scanlen = nfoul
endif

; OPEN THE TERMINAL FOR WRITING...
openw, unit, '/dev/tty', /GET_LUN, /MORE

for i = 0, scanlen-1 do printf, unit, strjoin(scans[i,*])

; FREE THE LOGICAL UNIT NUMBER...
free_lun, unit

message, /INFO, 'Scanlog ends at scan '+strtrim(scans[scanlen-1,0],2)

end; scancheck
