;+
;NAME:
;readasciifile - read an ascii file into strarr
;SYNTAX: nlines=readasciifile(filename,inpLines,comment=comment)
;ARGS:
;   filename: string the filename to read
;KEYWORDS:
;    comment: string single character that is a comment
;                    lines that start with this will be skipped
;RETURNS:
;     nlines: long number of lines read
;                  -1 if file does not exist.
;inpLines[nlines]: strarr lines read
;
;DESCRIPTION
;   Read an entire file into a string array. 1 line per string index.
;Skip any lines that start with the comment character.
;Return the string array and the number of lines read.
;
;EXAMPLES:
;   filename='savfiles.dat'
;   nlines=readasciifile(filename,inplines,comment=';')
;-
;history:
;
function readasciifile,filename,inpLines,comment=comment

    if file_exists(filename) eq 0 then return,-1
    cmd='wc ' + filename
    spawn,cmd,nlines
    nlines=nlines[0]
	if nlines eq 0 then return,0
    openr,lun,filename,/get_lun
    inpLines =strarr(nlines)
    readf,lun,inpLines
    free_lun,lun
    if keyword_set(comment) then begin
        ind=where(strmid(inpLines,0,1) ne comment,count)
        if count ne nlines then begin
		 	if count eq 0 then begin
				inplines=''
				return,0 
			endif else begin
				inpLines=inpLines[ind]
			endelse
		endif
    endif
    return,n_elements(inpLines)
end
