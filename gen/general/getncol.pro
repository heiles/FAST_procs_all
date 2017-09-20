pro getncol, fname, numcol, arr, $
             BYTE=byte, INT=int, LONG=long, FLOAT=float, DOUBLE=double, $
             SKIP=skip, LINES=lines, SILENT=silent
;+
; NAME:
;       GETNCOL
;
; PURPOSE:
;       Read data array of given number of columns from an ASCII data file.
;
; CALLING SEQUENCE:
;       GETNCOL, FNAME, NUMCOL, RESULT, [,/BYTE|/INT|/LONG|/FLOAT|/DOUBLE]
;       [,SKIP=skip][,LINES=lines][,/SILENT]
;
; INPUTS:
;       FNAME - File name.
;       NUMCOL - Number of columns in the file.
;
; KEYWORD PARAMETERS:
;       /BYTE - if set, data read as byte type.
;       /INT - if set, data read as integer type.
;       /LONG - if set, data read as long integer type.
;       /FLOAT - if set, data read as floating-point type.
;       /DOUBLE - if set, data read as double-precision 
;                 floating-point type.
;       SKIP - The number of lines to skip at the start of the file.
;       LINES - Set this keyword to a named variable that stores the
;               number of lines read into the data array.
;       /SILENT - Set this keyword to prevent messages.
;
; OUTPUTS:
;       RESULT - Array containing the data read from file.
;
; COMMON BLOCKS:
;       None.
;
; RESTRICTIONS:
;       All data are assumed to be of the same data type.
;
; EXAMPLE:
;       Read in 12 columns of byte type data from the file file.dat,
;       skipping the first 3 lines and suppressing messages:
;
;       IDL> GETNCOL, 'file.dat', 12, data, /BYTE, /SILENT
;
; NOTES:
;       If no data type keyword is specifies, then floating-point 
;       is assumed.
;
; MODIFICATION HISTORY:
;   02 Mar 2003  Written by Tim Robishaw, Berkeley
;-

; DOES FILE EXIST...
if not file_test(fname) then begin
    message, fname+' does not exist.', /INFO
    return
endif

; HOW MANY LINES ARE IN THE FILE...
spawn, "\wc -l "+fname+"| \awk '{print $1}'", lines
lines = long(lines[0])
if not keyword_set(SILENT) $
  then message, strtrim(lines,2)+' lines to read, ' + $
                strtrim(numcol,2)+' columns.', /INFO

; OPEN FILE FOR READING...
openr, lun, fname, /GET_LUN

; SHOULD LINES BE SKIPPED AT THE BEGINNING...
if keyword_set(SKIP) then begin
    if not keyword_set(SILENT) $
      then message, 'Skipping '+strtrim(skip, 2)+' lines.', /INFO
    for i = 0, skip-1 do readf, lun, useless
    lines = lines-skip
endif

; WHAT DATA TYPE DO YOU WANT THE ARRAY TO BE... 
case 1 of
    keyword_set(int)    : arr = intarr(numcol, lines)
    keyword_set(byte)   : arr = bytarr(numcol, lines)
    keyword_set(long)   : arr = lonarr(numcol, lines)
    keyword_set(float)  : arr = fltarr(numcol, lines)
    keyword_set(double) : arr = dblarr(numcol, lines)
    else : arr = fltarr(numcol, lines)
endcase

; READ THE DATA INTO THE ARRAY...
readf, lun, arr

; CLOSE FILE AND FREE THE LOGICAL UNIT NUMBER...
close, lun
free_lun, lun

; HOW MANY LINES DID WE READ IN...
if not keyword_set(SILENT) $
  then message, strtrim(lines, 2)+' lines read.', /INFO

end; getncol
