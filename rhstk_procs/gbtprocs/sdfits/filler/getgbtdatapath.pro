function getgbtdatapath, ProjID
; they keep moving the gbt data around.
; feb09: had to swap the -type and -maxdepth arguments because of warning
;        from find... this is new.
; jun12: they moved the data AGAIN, so we had to change the find command.

;!!!!
; right now this assumes linux, maxdepth doesn't work on solaris

; this is very annoying and prevents us from hardwiring paths in our
; data display and analysis code...

;!!!!
; could use reg expr here to make sure alpha or numeric...

; check the structure of the project ID...
if not strmatch(ProjID,'[TA]GBT[01][0-9][A-C]_[0-9][0-9][0-9]_[0-9][0-9]') $
  then message, /INFO, 'Project ID should be of form AGBT05A_001_01'

; first look in the current gbt data directory...
spawn, 'find /home/gbtdata -maxdepth 1 -type d -name '+ProjID, $
  ProjDataPath, COUNT=nfound

if (nfound gt 0) then return, ProjDataPath[0]

; next check the archive...

spawn, 'find /home/archive/science-data/* /home/archive/test-data/* '+$
  ' /home/archive/early-data/tape* -maxdepth 1 -type d -name '+ProjID, $
  ProjDataPath, COUNT=nfound

if (nfound gt 0) then return, ProjDataPath[0]

message, 'Project ID '+strtrim(ProjID,2)+' not found in GBT archives.'

end; getgbtdatapath

