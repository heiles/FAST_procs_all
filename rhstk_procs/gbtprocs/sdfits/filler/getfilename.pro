function getfilename, FilePath, FileId

; WHICH OF THESE HAVE FITS EXTENSIONS...
fits = where(strpos(FilePath,'.fits') ne -1L)

; WHICH OF THESE HAVE THE FILEID WE'RE LOOKING FOR...
match = where(strpos(FilePath[fits],FileId) ne -1L, nmatch)

if (nmatch gt 0) $
  then return, FilePath[fits[match[0]]]

;!!!!!!!!!!
; COULD HAVE A CASE, LIKE LO1B, WHERE WE DELIBERATELY IGNORE
; THE FILE
return, ''

end; getfilename
