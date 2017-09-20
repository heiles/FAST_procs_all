;+
;NAME:
;bitreverse - bit reverse data
;SYNTAX datBr=bitreverse(dat,numBits)
;ARGS: 
;dat[n]: long	data to bit reverse
;numbits: long	number of bits to reverse
;RETURNS:
;datBr[n]: long	 the bit reversed data.
;DESCRIPTION:
;	Bit reverse the data in array dat. The number of bits to use
;for the reversal is specified in numBits:
;EXAMPLE:
;	if  a=00000001b then bitreverse(a,4) would return 0001000.
;-
function bitreverse,val,nbits
    n=n_elements(val)
    out=lonarr(n)
    mask=1L
    for i=0,nbits-1 do begin
        out*=2L
        ii=where((val and mask) ne 0,cnt)
        if cnt gt 0 then out[ii]+=1
        mask*=2L
    endfor
    return,out
end

