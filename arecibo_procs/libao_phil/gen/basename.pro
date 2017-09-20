;+
;NAME:
;basename - return directory and basename of file
;SYNTAX: baseNm=basename(filename,dirNm=dirNm,nmLen=nmLen)
;ARGS:
;   filename: string    filename to split into directory and basename
;RETURNS:
;   baseNm: string  basename (without the directory). '' will be returned if
;                   there is no base name.
;KEYWORDS:
;   dirNm:  string  if present then return the directory name here. It will 
;                   contain the trailing "\". If there is no directory
;                   name then return ''.
;  nmLen[2]: long   length of directory name:(nmLen[0]) and basename:(nmLen[1]).
;                   if either name is not present then nmLen[i] will have 0.
;
;EXAMPLE:
;   file='/share/olcor/corfile.01jun06.x101.1'
;   bnm=basename(file,dirnm=dirnm,nmLen=nmLen)
;;
;  bnm: corfile.01jun06.x101.1
;  dir: /share/olcor/ 
;nmLen: 13   22
;-
function basename,filename,dirnm=dirnm,nmLen=nmLen
;
    nmLen=lonarr(2)
    dirNm=''
    baseNm=''
    filenameLen=strlen(filename)
    if filenameLen eq 0 then return,baseNm
    dirEnd=strpos(filename,'/',0,/reverse_offset,/reverse_search)
    nmLen[0]=(dirEnd ne -1)? dirEnd+1:0
    nmLen[1]=filenameLen-nmLen[0]
    if nmLen[0] gt 0 then dirNm=strmid(filename,0,nmLen[0])
    if nmLen[1] gt 0 then baseNm=strmid(filename,nmLen[0])
    return,baseNm
end
