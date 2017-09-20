;+
;NAME:
;addpath - add a directory to the start of the path variable
;
;SYNTAX: addpath,pathname
;
;ARGS:
;   pathname : string variable with the path to add. If the pathname 
;              does not begin with / or ~ then the path will be 
;              relative to the path returned by aodefdir
;
;DESCRIPTION:
;   Add a directory to the beginning of the !path variable. If the
;first character does not begin with ~, or /, then make the path
;relative to the directory returned by aodefdir(). If the pathname is already 
;in the path, then move it to the front of the path.
;

;EXAMPLE:
;   addpath, '/home/aosun/u4/bozo/idl' .. 
;   addpath, 'Cor2'                    .. adds /pkg/rsi/local/libao/phil/Cor2
;-
;
pro addpath, newpath
;
; see if the pathname is int !path check the 
;   1st, aaa:,    last :aaaaa, or midddle
;
    first =-1
    last  =-1
    middle=-1
;
;   expand to directory if needed
;
    if (strmid(newpath,0,1) ne '/' ) and(strmid(newpath,0,1) ne '~' ) then begin
        newpathloc=aodefdir() + newpath
    endif else begin  
        newpathloc=newpath
    endelse

    newlen=strlen(newpathloc)
    pathlen=strlen(!path)
    first=strpos(!path,newpathloc + ':')
    if first eq 0 then return

    middle=strpos(!path,':' + newpathloc + ':')
    if (middle eq -1) and (pathlen gt newlen) then begin
        last=strpos(!path,':'+ newpathloc,pathlen-(newlen+1))
    endif
    if (last eq -1) and (middle eq -1) then begin
        !path =  newpathloc + ":" + !path
    endif else begin
;
;   path already there, move it to the front
;
        if middle ne -1 then begin
            !path=newpathloc + ':' + strmid(!path,0,middle) + $
                  strmid(!path,middle+newlen+1,pathlen-(middle+newlen+1)+1)
        endif else begin
            !path=newpathloc + ':' + strmid(!path,0,last)
        endelse
    endelse
end
