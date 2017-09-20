pro duplix, FILEGREP, AVOID=avoid, MORE=more, NOLINKS=nolinks
;+
; NAME:
;       DUPLIX
;
; PURPOSE:
;       To find IDL files with the same name in your IDL path.
;
; CALLING SEQUENCE:
;       DUPLIX [, string][, AVOID=string][, /NOLINKS][, /MORE]
;
; INPUTS:
;       FILEGREP : string (scalar); file names containing this string
;                  will be looked for
;
; KEYWORD PARAMETERS:
;       AVOID = string (scalar or array); paths containing this string 
;               will not be searched.
;       /MORE : Set this keyword to list duplications in style of MORE.
;       /NOLINKS : Prevent any symbolic links from being included.
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       A list of duplicate IDL file names (with full paths) is
;       printed to the screen.
;
; EXAMPLE:
;       The following will look for all files with names matching
;       'calc' and will avoid any path with 'homework' or 'goddard'
;       in its name:
;
;       IDL> duplix, 'calc', AVOID=['homework','goddard']
;
; NOTES:
;       Tested for UNIX and Linux.
;
; MODIFICATION HISTORY:
;   24 May 2003  Written by Tim Robishaw, Berkeley
;   06 Apr 2005  Spawn FIND.  Added /NOLINKS keyword.
;   09 Nov 2006  If /MORE set, dump to /dev/tty.
;-

; PULL OUT THE IDL PATH DIRECTORIES...
path = strsplit(!path,':',/EXTRACT)

if keyword_set(AVOID) then $
  for i = 0, N_elements(AVOID)-1 do $
    path = path[where(strpos(path,avoid[i]) eq -1L)]

; SEARCH EACH PATH DIRECTORY...
spawn, 'find '+strjoin(path,' ')+$
       ' -maxdepth 1 ' +$
       (keyword_set(NOLINKS) ? ' -type f' : '')+$
       '| grep \.pro$'+$
       ((N_elements(filegrep) gt 0) ? ' | grep '+filegrep : ''), $ 
       profiles, COUNT=nfound

N_profiles = N_elements(profiles)

; PULL OUT THE .PRO FILE NAMES...
strt = strpos(profiles,'/',/reverse_search)
stop = strlen(profiles)
pronames = strarr(N_profiles)
for i = 0L, N_profiles-1L do $
  pronames[i] = strmid(profiles[i],strt[i]+1,stop[i]-strt[i])

; GO THROUGH THE LIST OF .PRO FILES AND FIND DUPLICATES...
uniqnames = pronames[uniq(pronames,sort(pronames))]
for i = 0L, N_elements(uniqnames)-1L do begin
    duplicates = profiles[where(pronames eq uniqnames[i],N_duplicates)]
    if (N_duplicates gt 1) then $
      dup = (N_elements(dup) eq 0) ? $
             [duplicates,'        '] : [dup,duplicates,'        ']
endfor

if (N_elements(dup) eq 0) then begin
    message, 'No duplicate procedures found on !PATH.', /INFO
    return
endif

; OPEN THE TERMINAL FOR WRITING...
openw, unit, '/dev/tty', /GET_LUN, MORE=keyword_set(MORE)
for i = 0,  N_elements(dup)-1 do printf, unit, dup[i]
free_lun, unit

end; duplix
