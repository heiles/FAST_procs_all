; 
;NAME
;x111freqlist - return unique frequencies in x111sl list
;SYNTAX: freqlist=x111freqlist(sl),sbc=sbc
;ARGS:
;       sl[]    : {sl} returned from getsl
;KEYWORS:
;       sbc         : int 1..4 sbc to look at. default is all sbc.
;RETURNS:
;       freqlist[]  : float array of  unique frequencies (mhz).
function x111freqlist,sl,sbc=sbc
;
    nelm=(size(sl))[1]
    if n_elements(sbc) ne 0 then begin &$
        frq=sl.freq[sbc-1] &$
    endif else begin &$
        frq=reform(sl.freq,4L*nelm) &$
    endelse
    frq=frq[uniq(frq,sort(frq))]
    if frq[0] eq 0. then frq=frq[1:*]
    return,frq
end
