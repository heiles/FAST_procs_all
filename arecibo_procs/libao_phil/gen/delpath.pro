;+
;NAME:
;delpath - remove pathname from the path variable.
;SYNTAX: delpath, path
;ARGS:  
;   path : string complete pathname to delete from the !path variable.
;                 It must match how it appears in the !path variable.
;-
pro delpath , newpath
;
; cut newpath from path variable. must enter full path
;
val    = newpath + ":"
pstart = strpos(!path,val)      ; where string starts in path
if pstart eq -1  then return        ; not there
cutlen=strlen(val)              ; bytes to cut out
endlen= strlen(!path)  - (pstart + 1 + cutlen)  ; len end of string
!path= strmid(!path,0,pstart) + strmid(!path,pstart+cutlen,endlen)
return
end
