;+
;NAME:
;pdevbitrevind - return index array for fft bitreverse
;SYNTAX: indAr=pevbitrevind(lengthfft)
;ARGS:
;   lengthfft: long length of fft for bitreverse
;RETURNS:
;   indAr[lenth]: long  index array for bit reverse.
; generate a bit reverse index array;
;DESCRIPTION:
;   The data from the pdev spectrometer is output in bit reversed
;order. This routine will generate  an array of indices that can be used
;to put the spectrum in proper frequency order:
;
;EXAMPLE:
;; let spcbr[8192] be the spectra in bit reversed order..
;   indR=pdevbitrevind(8192)
;   spc=spcbr[indR]         ; spc now in proper order
;-
;
function pdevbitrevInd,length
;
;    use half lengths, neg freq same as positive with offsets.
;
    nbits=fix(alog(length)/alog(2) + .5)  - 1
    len=length/2L
    ii=lindgen(len)         ; original indices
    iiR=lonarr(len)         ; hold indices after bit reversal
    mask=1                  ; grab 1 bit at a time
    toshift=nbits-1         ; where to shift this bit from current position.
    for i=0,nbits-1 do begin&$; loop over the bits
        iiR +=ishft(( ii and  mask),toshift)&$; move bit to new position.
        mask   =ishft(mask,1)&$; update mask for next bit
        toshift-=2           &$;shift by two since bit moves down, mask moves up
    endfor 
    iiRet=[iiR,iiR]         ; create full index pos,neg frequencies
    iiRet[len:*]+=len       ; increment neg frequencies.
    return,iiRet
end
