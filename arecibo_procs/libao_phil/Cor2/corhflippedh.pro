;*****************************************************************************
;+
;NAME:
;corhflippedh - check if current data is flipped in freq.
;SYNTAX: stat=corhflippedh(hdr,sbcnum)
;ARGS:
;   hdr[]: {hdr} to check.
;   sbcnum:long  sbc to check 1 thru 4.
;RETURNS:   istat- 0 increasing frq, 1- decreasing freq order.
;             if corhdr[] is an array then istat will be an array of ints.
;DESCRIPTION:
;   Check if the correlator data for this sbc is stored in increasing
;or decreasing frequency order (even or odd number of high side lo's).
;   This routine replaces Corhflipped. Corhflipped gave incorrect results for
;1 ghz if's if the LO was below 1500 Mhz and it was being used as hi side, or
;the lo was above 1500 Mhz and it was being used as a low side lo.
; corhflippedh should work in all cases.
;EXAMPLE:
;   sbcnum=1
;   check first board: istat=corhflippedh(b.b1.h,sbcnum)
;-
function corhflippedh,hdr,sbcnum
     on_error,0
;
;   check to see if ch master..
;   if ch. assume lo1=400 (lo), lo2=290(hi), cor flip)== 0
;
    if (pnthgrmaster(hdr[0].pnt) eq 0) then return,0
;   
    mixcfrAr=[750.,1250.,1500.,1750.]
    isbc=sbcnum-1
    nhdr=n_elements(hdr)
    if1num=ishft(hdr.iflo.if1.st1,-24) and 7
;
;    they passes in an array, process using where..
;
    if nhdr gt 1 then begin
;
;   see if the lo1 is above/below the rfcfr 
;
        sb1=intarr(nhdr) - 1    ; assume flipped
        ind10Gc=where(if1num eq 4,count10Gc)
;
;    see if there are any 10 Ghz up converts. it has a dual flip..
;
        if count10Gc ne nhdr then begin

;           cfr=corhcfrtop(hdr)
            cfr=hdr.iflo.if1.rffrq*1d-6
            lo1=hdr.iflo.if1.lo1*1d-6
            ind=where(lo1 lt cfr,count)
            if count gt 0 then sb1[ind]=1
        endif
        if count10Gc gt 0 then sb1[ind10Gc]=1
;
;   now the second if
;
        sb2=intarr(nhdr) + 1    ; assume not flipped
;
;       get 2nd mixer
;
        iMx=where((ishft(hdr.iflo.if2.st4[isbc],-26) and 3) eq 1,countMix)
;
;       only look at data that went thru the 2nd mixing stage..
;       ignore data with if1=260,250..
;
        if countMix gt 0 then begin
            syn2Frq=(hdr.iflo.if2.synFreq[isbc])*1d-6
            ii= ishft(hdr.iflo.if2.st4[isbc],-28)  and '3'XL ; if2 frq used
            if1Mixcfr=mixCfrAr[ii[iMx]]
            ind=where(syn2Frq[iMx] gt if1Mixcfr,count)
            if count gt 0 then sb2[imx[ind]] = sb2[imx[ind]] * (-1)
        endif
        flipped= (sb1*sb2 + 1)/2        ; since cor also flips
    endif else begin
;
;    check the first lo
;
        if if1Num eq 4 then  begin
            sb1=1                       ; 10 ghz is unflipped
        endif else begin
            cfr=hdr.iflo.if1.rffrq*1d-6
            lo1=hdr.iflo.if1.lo1*1d-6
            sb1=(lo1 gt cfr) ? -1:1         ; -1 --> flipped
        endelse
;
;   check the 2nd lo
;
        if ((ishft(hdr.iflo.if2.st4[isbc],-26) and 3) ne 1 ) then begin
            sb2 = 1                             ; no flip since no mixers
        endif else begin
            syn2Frq=(hdr.iflo.if2.synFreq[isbc])*1d-6
            ii= ishft(hdr.iflo.if2.st4[isbc],-28)  and '3'XL
            if1cfr=mixCfrAr[ii]
            sb2=(syn2Frq gt if1cfr)? -1 : 1
        endelse
        flipped= (-1 * sb1*sb2) gt 0 ? 0 : 1
    endelse
    return,flipped
end
