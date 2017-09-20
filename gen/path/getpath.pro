pro getpath, MORE=more
;+
; NAME:
;GETPATH -- print out the current !path system variable as a list of directories
;     
; PURPOSE:
;       To print out the current !path system variable as a list
;       of directories, rather than a character-separated string.
;     
; CALLING SEQUENCE:
;       GETPATH [,/MORE]
;     
; INPUTS:
;       None.
;     
; OUTPUTS:
;       None.
;
; KEYWORDS:
;       MORE : Set this keyword to list !PATH in style of MORE.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       The entire IDL path is printed to the screen.
;
; NOTES:
;       Tested for UNIX and Linux.
;
; MODIFICATION HISTORY:
;       Written Tim Robishaw, Berkeley 18 Feb 2002
;-

; EXTRACT THE !PATH INTO A STRING ARRAY...
path = strsplit(!path, ':', /EXTRACT)
pathlen = N_elements(path)

if keyword_set(MORE) then begin
    ; HOW MANY ROWS IS THE TERMINAL DISPLAYING...
    spawn, "stty -a | grep rows | sed 's/=//g'", result
    result = strmid(result[0],strpos(result,'rows'))
    rows = fix(strmid(result,4,strpos(result,';')-4))-1
endif else rows = pathlen

; PRINT OUT PATH IN "MORE" FASHION...
for i = 0, pathlen/rows-1-(pathlen mod rows eq 0) do begin
    print, transpose(path[i*rows:(i+1)*rows-1])
    print, "--More--", format='($,A,%"\R")'
    io = get_kbrd(1)
endfor

; PRINT OUT THE REMAINDER OF THE PATH...
print, transpose(path[i*rows*(pathlen gt rows):*])

end; getpath
