pro mkstr, nrc, hdr, hdrdbl, scn, srcnm, stk, str

str0= {scn:scn[0], srcnm:srcnm[0], hdr:hdr[*,0], hdrdbl:hdrdbl[*,0], $
      stk:stk[*,*,0]}
str= replicate( str0, nrc)
for ns=0, nrc-1 do $
str[ ns]= {scn:scn[ns], srcnm:srcnm[ns], hdr:hdr[*,ns], hdrdbl:hdrdbl[*,ns], $
      stk:stk[*,*,ns]}
return
end
