pro lp, file, PRINTER=printer
useless = findfile(file,count=ct)
if (ct eq 0) then begin
    print, 'File not found.'
    trythis = file_which(file)
    if (trythis ne '') $
      then print, 'Did you mean '+trythis+'? Include full path!' $
      else print, 'Check the path and file name again.'
    return
endif
if not keyword_set(PRINTER) then begin
    spawn, '\lpstat -d', PRINTER
    start = strpos(PRINTER,':')+1
    PRINTER = strtrim(strmid(PRINTER,start),2)
endif
spawn, '\lp -d '+PRINTER+' '+file
end; lp
