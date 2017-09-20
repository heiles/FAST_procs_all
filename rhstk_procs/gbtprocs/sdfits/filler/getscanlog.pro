;+
; NAME:
;       GETSCANLOG
;
; PURPOSE:
;       To return an array of structures containing the most essential
;       information for each GBT data scan.
;
; CALLING SEQUENCE:
;       result = GETSCANLOG(ProjectPath [,Source][,NScans=][,/SILENT])
;
; INPUTS:
;       PROJECTPATH - the absolute path to the directory where data are 
;                     stored for a particular project ID.
;
; OPTIONAL INPUTS:
;       SOURCE - scalar string with name of source for which you want to 
;                retrieve information.
;
; KEYWORD PARAMETERS:
;       /SILENT - Set this keyword to prevent written summary of scans.
;
;       NSCANS - Set this keyword to a named variable that receives the
;                number of scans that was observed.
;
; OUTPUTS:
;       RESULT - Structure
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;       
;
; PROCEDURES CALLED:
;       MRDFITS()
;
; EXAMPLE:
;       Return the scan log for project TGBT02A_053_15:
;
;       IDL> ScanLog = GetScanLog('/home/gbtdata/TGBT02A_053_15',/SILENT)
;
;       Inspect which structure tags are stored in the result:
;
;       IDL> help, ScanLog, /STRUCTURE
;
;       Print the scan numbers:
;
;       IDL> print, ScanLog.Scan
;
;       Print the source names:
;
;       IDL> print, ScanLog.Source
;
;       Print the FITS file names corresponding to scan 432:
;
;       IDL> ScanIndx = where(ScanLog.Scan eq 432)
;       IDL> print, ScanLog[ScanIndx].FilePath[0:ScanLog[ScanIndx].NFiles-1]
;
; RELATED PROCEDURES:

;
; MODIFICATION HISTORY:
;   19 Jan 2003  Written by Tim Robishaw, Berkeley
;-

function getscanlog, ProjectPath, Source, $
                     SILENT=silent, NSCANS=nscans

; RETURN THE SCANLOG FROM THE SCANLOG FITS FILE...
Paths  = strsplit(ProjectPath,'/',/EXTRACT)
NPaths = N_elements(Paths)

; READ IN THE FIRST EXTENSION OF THE SCANLOG FITS FILE...
ScanLog = mrdfits(ProjectPath+'/ScanLog.fits', 1, STATUS=iostat, /SILENT)

; IF THE SCANLOG DOESN'T EXIST, LET USER KNOW...
if (iostat EQ -1) $
    then message, 'ScanLog.fits file does not exist!'

; STRIP THE BLANK SPACES AT FRONT/BACK...
ScanLog.FilePath = strtrim(ScanLog.FilePath,2)

; MAKE SURE "/" NOT AT END OF PATH...
AbsPath = '/'+strjoin(Paths[0:Npaths-2],'/')

; REPLACE EACH OCCURENCE OF "./" WITH THE ABSOLUTE PATH...
ReplacePath = where(strpos(ScanLog.FilePath,'./') eq 0, N_Paths)
ScanLog[ReplacePath].FilePath = AbsPath + $
  strmid(ScanLog[ReplacePath].FilePath,1)

; ARE WE PICKING A SOURCE...
PickSource = (N_Params() GT 1)

; GET THE SCAN NUMBERS...
Scans    = ScanLog.Scan
Date     = ScanLog.Date_Obs
FilePath = ScanLog.FilePath

; WE HAVE TO GUARD AGAINST THE POSSIBILITY THAT THE SAME SCAN NUMBER
; WAS OBSERVED MORE THAN ONCE AND OUT OF SEQUENCE...

; GET THE UNIQ ELEMENTS IN THE SCAN ARRAY...
; NOTICE THIS FINDS LOCATIONS OF REPEATED SCAN NUMERS THAT ARE NOT
; ADJACENT, AS WE WISH...

; GET THE INDICES WHERE EACH SCAN STOPS...
StopIndx = UNIQ(Scans)
NScans   = N_elements(StopIndx)

; GET THE INDICES WHERE EACH NEW SCAN STARTS...
StrtIndx  = [0L,StopIndx[0:NScans-2L]+1L]

; DETERMINE THE NUMBER OF DEVICE DIRECTORIES FOR EACH SCAN...
NDev = StopIndx - StrtIndx - 1L

; GET THE MAXIMUM NUMBER OF DEVICES...
MaxNDev = max(NDev)

; MAKE STRUCTURE TO STORE MOST PERTINENT SCAN INFORMATION...
ScanLog = replicate(create_struct(['Scan', $
                                   'Source', $
                                   'DATE_OBS', $
                                   'StartScan', $
                                   'StopScan', $
                                   'NFiles', $
                                   'Device', $
                                   'FilePath'], $
                                  0L,'','','','',0L, $
                                  strarr(MaxNDev), strarr(MaxNDev)), $
                    NScans)

for i = 0L, NScans-1L do begin

    if (NDev[i] lt 1) then continue

    ; GET THE INDICES FOR THIS SCAN...
    ThisScan = StrtIndx[i] + lindgen(StopIndx[i]-StrtIndx[i]+1)

    ; WHERE ARE THE STARTING AND STOPPING TIMES LOCATED...
    ; TR: THIS CHANGED SOMETIME AFTER SEP03!!! SO WE'VE MADE IT GENERAL...
    TimeIndx = where(strmatch(FilePath[ThisScan],'SCAN*',/FOLD_CASE),$
                  COMPLEMENT=FileIndx, NTimeMessages)

	; TR 3.7.04 NEEDED THIS FOR REAL-TIME OBSERVING WHEN THERE'S ONLY A START SCAN MESSAGE BUT NO STOP SCAN MESSAGE...
	if (NTimeMessages eq 1) then continue

    TimeIndx = ThisScan[TimeIndx]
    FileIndx = ThisScan[FileIndx]

    ; GET THE GO FILE NAME...
    GOFITSfile = getfilename(FilePath[FileIndx], 'GO')

    ; HAD A PECULIAR SITUATION WHERE GO FITS FILE DID NOT GET SAVED
    ; EVEN THOUGH IT WAS LISTED IN THE SCANLOG!  HAVE TO DOUBLE-CHECK
    ; FOR EXISTENCE.
    ; IF IT EXISTS, RETRIEVE THE HEADER...
    if (strlen(GOFitsFile) gt 0) AND (file_test(GOFITSfile) gt 0) then begin
        GOheader = headfits(GOFitsFile)
        source = strtrim(sxpar(GOheader, 'OBJECT'),2)
    endif else begin
        message, 'No GO FITS file!', /INFO
        source = ''
    endelse

    ; GET SCAN NUMBER, PROJECT ID, SCAN NUMBER AND SOURCE NAME...
    ScanLog[i].Scan      = Scans[StrtIndx[i]]
    ScanLog[i].Source    = source
    ScanLog[i].Date_Obs  = strtrim(Date[StrtIndx[i]],2)
    ScanLog[i].StartScan = FilePath[TimeIndx[0]]
    ScanLog[i].StopScan  = FilePath[TimeIndx[1]]
    ScanLog[i].NFiles    = NDev[i]
    ScanLog[i].FilePath  = FilePath[FileIndx]

    ; GET THE DEVICE NAME...
    Device   = ScanLog[i].FilePath
    Diagonal = indgen(MaxNDev)*MaxNDev + indgen(MaxNDev)
    CutIndx  = strpos(Device,'/',/REVERSE_SEARCH)
    Device   = (strmid(Device,0,CutIndx))[Diagonal]
    CutIndx  = strpos(Device,'/',/REVERSE_SEARCH)
    Device   = (strmid(Device,CutIndx+1))[Diagonal]

    ScanLog[i].Device = Device 

    ; IS THIS THE SOURCE...
    if PickSource then $
      if not strcmp(ScanLog[i].Source, strtrim(Source,2), /FOLD_CASE) $
        then continue

    ; DO WE WANT TO AVOID PRINTING RESULTS...
    if keyword_set(SILENT) then continue

    ; GET THE RECEIVER INFORMATION...
    IFFITSfile = getfilename(FilePath[FileIndx], 'IF')
    IF_1 = mrdfits(IFFITSfile,1,STATUS=iostat, /SILENT)
    if (iostat ne 0) $
      then Rcvr = 'No IF FITS file' $
      else begin
        SPIndx = where(strpos(IF_1.BackEnd,'Spectral') ne -1L, NSP)
        Rcvr = (NSP eq 0) ? $
               'No Rcvr Info' : strtrim(IF_1[SPIndx[0]].Receiver,2)
      endelse

    ; PRINT OUT THE SCAN INFO...
    print, ScanLog[i].Scan, $
           ScanLog[i].Date_Obs, $
           Rcvr, $
           ScanLog[i].Source, $
           ScanLog[i].StartScan, $
           ScanLog[i].StopScan, $
           format='(I4,A27,A16,A12,2(%"\N\R",A),%"\N")'

    ; ARE WE MISSING A FITS FILE...
    if (NDev[i] eq MaxNDev) then continue

    print, 'Scan ', Scans[StrtIndx[i]], ' Missing a FITS file:', $
           FilePath[FileIndx], $
           format='(A,I4,A,%"\N\R",6(A50,%"\N\R"))'

endfor

; RETURN ONLY THE SCANLOG DATA FOR THIS SOURCE...
if PickSource $
  then ScanLog = ScanLog[where(ScanLog.Source eq Source, NScans)]

; WE'LL PASS OUT THE SCAN LOG...
return, ScanLog

end; getscanlog
