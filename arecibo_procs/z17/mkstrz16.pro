pro mkstrz16, nrc, corhdr, hdrsrcname, hdrscan, hdr1info, hdr2info, $
               stkon, stkoff, stk16offs, strz16

;+
;turn output of z16 red prog into a structure.
;-

for ns=0, nrc-1 do begin
str0= {corhdr:corhdr[ *,ns], srcname:hdrsrcname[ns], scan:hdrscan[ns], $
       hdr1:hdr1info[*,ns], hdr2:hdr2info[*,*,ns], stkon:stkon[*,*,ns], $
       stkoff:stkoff[*,*,ns], stk16offs:stk16offs[*,*,*,ns]}
if ns eq 0 then strz16= replicate( str0, nrc)
strz16[ ns]= str0
endfor

return
end
