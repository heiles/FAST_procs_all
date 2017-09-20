;+ 
;NAME:
;strtovarnam - modify a string to be a valid variable name
;SYNTAX: newstr=strstovarnam,str,noleading=noleading
;ARGS:
;   str[]: str   hold the string or strings to check
;
;KEYWORDS:
;   noleading:   if set then don't bother checking if the leading
;                character is a letter.
;RETURNS:
;   newstr[]: str modified strings that are valid variable names.
;
;DESCRIPTION:
;   This routine will modify the strings passed in to be valid variable
;names. A variable name must start with a letter and not contain the
;characters: , . ! ; : + - / =
; This routine will make the following substitutions:
; , -> _
; . -> _
; + -> p lus
; - -> m inus
; / -> _
; = -> _
; ! -> _
; ) -> _
; ( -> _
;
;If the string starts with a non letter then prepend the string with 
;the letter v.
;
;   This routine is normally used when creating a variable name
;that is taken from the source name in the header.
;
;EXAMPLE:
;   a='B1934+123'
;   aMod=strtovarnam(a)
;   print,aMod
;  .. 'B1934p123'
;
;   a='1934-123:17'
;   aMod=strtovarnam(a)
;   print,aMod
;  .. 'v1934m123_17'
;
;-
function strtovarnam,str,noleading=noleading
    
    n=n_elements(str)
    strl=str
;
;   replace chars by _
;
    repeat begin
        iar=stregex(strl,'[,./=!:;()]')
        ind=where(iar ne -1,count)
        if (count gt 0) then begin
            for i=0,n-1 do begin
                if (iar[i] ne -1) then begin
                    a=strl[i]
                    strput,a,'_',iar[i]
                    strl[i]=a
                endif
            endfor
        endif
    endrep until count eq 0
;
;   do +, - 
;
    repeat begin
        numP=strpos(strl,'+')
        numM=strpos(strl,'-')
        indP=where(numP ne -1,countP)
        indM=where(numM ne -1,countM)
        if (countP gt 0) or (countM gt 0) then begin
            for i=0,n-1 do begin
                a=strl[i]
                if numP[i] ne -1 then strput,a,'p',numP[i] 
                if numM[i] ne -1 then strput,a,'m',numM[i] 
                strl[i]=a
            endfor
        endif
    endrep until (countP eq 0) and (countM eq 0)
;
;  starting char must be alpha
;
    if not keyword_set(noleading) then begin
    iar=stregex(strl,'^[^a-zA-Z]')
    ind=where(iar ne -1,count)
    if count gt 0 then begin
        for i=0,n-1 do begin
            if iar[i] ne -1 then strl[i]='v'+strl[i]
        endfor
    endif
    endif
    return,strl
end
