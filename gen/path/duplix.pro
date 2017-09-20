pro duplix, FILEGREP, AVOID=avoid, MORE=more
;+
; NAME:
;DUPLIX -- find IDL files with the same name in your IDL path.
;
; PURPOSE:
;       To find IDL files with the same name in your IDL path.
;
; CALLING SEQUENCE:
;       DUPLIX [, string][, AVOID=string][, /MORE]
;
; INPUTS:
;       FILEGREP : string (scalar); file names with containing this string
;                  will be looked for
;
; KEYWORD PARAMETERS:
;       AVOID = string (scalar or array); paths containing this string 
;               will not be searched.
;       /MORE : Set this keyword to list duplications in style of MORE.
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
;-

; PULL OUT THE IDL PATH DIRECTORIES...
path = strsplit(!path,':',/EXTRACT)

if keyword_set(AVOID) then $
  for i = 0, N_elements(AVOID)-1 do $
    path = path[where(strpos(path,avoid[i]) eq -1L)]

; SEARCH EACH PATH DIRECTORY...
if (N_params() eq 0) then filegrep = ''
for root = 1, N_elements(path)-1 do begin
    foundfiles = findfile(path[root]+'/*'+filegrep+'*.pro', COUNT=nfound)
    if (nfound gt 0) $
      then profiles = (N_elements(profiles) eq 0) ? $
                      foundfiles : [profiles,foundfiles]
endfor

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

if keyword_set(MORE) then begin
    ; HOW MANY ROWS IS THE TERMINAL DISPLAYING...
    spawn, "stty -a | grep rows | sed 's/=//g'", result
    result = strmid(result[0],strpos(result,'rows'))
    rows = fix(strmid(result,4,strpos(result,';')-4))-1
endif else rows = N_elements(dup)

; PRINT OUT PATH IN "MORE" FASHION...
for i = 0, N_elements(dup)/rows-1-(N_elements(dup) mod rows eq 0) do begin
    print, transpose(dup[i*rows:(i+1)*rows-1])
    print, "--More--", format='($,A,%"\R")'
    io = get_kbrd(1)
endfor

; PRINT OUT THE REMAINDER OF THE PATH...
print, transpose(dup[i*rows*(N_elements(dup) gt rows):*])

end; duplix
