;+
;NAME:
;checkkey - check if any keys have been pressed 
;SYNTAX:  key=checkkey(first=first,all=all,wait=wait,noflush=noflush)
;ARGS  :  NONE
;KEYWORDS:
;   first:  if set then return the first character. default is the last char.
;   all:    if set then return all characters. default is the last char.
;   wait:   if set then wait for at least one character
;   noflush: if set and first is set, then don't flush the other characters
;            in the buf.
;RETURNS:
;   key :   character or characters entered.
;DESCRIPTION:
;   checkkey will check to see if any keys have been pressed. It will return
;with the last key waiting in the input buffer or '' if nothing was there.
;The wait keyword will cause the routine to wait for at least 1 keypress.
;The first keyword will return the first rather last key of any string.
;The all keyword will return all keys entered. By default all characters
;waiting in the input buffer are read. If the noflush and first keyword are
;set then only the first char is returned. The other chars can be read at
;a later time.
;-
function checkkey,first=first,noflush=noflush,all=all,wait=wait

    wait=keyword_set(wait)
    str=get_kbrd(wait)
    if str ne '' then begin
        if keyword_set(first) and keyword_set(noflush) then begin
        endif else begin
            repeat begin
                ch=get_kbrd(0)
                str=str+ch
            endrep until ch eq ''
        endelse
    endif
    if strlen(str) gt 0 then begin
        if keyword_set(all) then return,str
        if keyword_set(first) then return,strmid(str,0,1)
        return,strmid(str,0,1,/reverse_offset)
    endif
    return,''
end
