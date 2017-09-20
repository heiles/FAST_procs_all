;+
;NAME:
;cormath - perform math on correlator data
;SYNTAX: bout=cormath(b1,b2,sub=sub,add=add,div=div,mul=mul,$
;                       sadd=sadd,ssub=ssub,sdiv=sdiv,smul=smul,$
;                       norm=norm,mask=mask)
;ARGS: 
;     b1[n]     :  {corget} first math argument
;     b2[n or 1]:  {corget} second math argument
;KEYWORDS:
;     sub: if set then  bout= b1-b2
;     add: if set then  bout= b1+b2
;     div: if set then  bout= b1/b2
;     mul: if set then  bout= b1*b2 
;    sadd: if set then  bout= b1+sadd  (scalar add)
;    ssub: if set then  bout= b1-ssub  (scalar subtract)
;    sdiv: if set then  bout= b1/sdiv  (scalar divide) 
;    smul: if set then  bout= b1*smul  (scalar multiply)
;    norm: if set then  normalize(b1)  one argument, or norm only
;                       normalize(b2)  if two args and a math operation
;                       If a mask defined, normalize within the mask.
;                       If a math operation is also defined, perform the
;                       math operation after normalization.
;   mask :{cormask}     a mask to use with norm keyword (see cormask).
;                       Note that cormath only uses the polA mask
;                       of each board. If a 2nd mask is defined for polb
;                       (eg corcumfilter), the pola mask is used for both pols
;
;RETURNS:
;   bout[n]: {corget} result of arithmetic operation.
;
;DESCRIPTION:
;   Perform arithmetic on correlator data structures. The operation performed
;depends on the keyword supplied. 
;
;   The keywords sub,add,div, or mul perform the operations on the two 
;structures b1,b2. There are two modes of combining b1,b2:
;
;  1.b1 and b2 are the same length:
;       bout[i]=b1[i] op b2[i]

;  2.b1[n] and b2[1] then 
;       bout[i]= b1[i] op b2[0]  .. 
;
;   The 2nd form could be used when bandpass correcting a set of records
;with a single bandpass.
;
;   The keywords sadd,ssub,sdiv,smul take a single scalar value and 
;perform the operation on all elements of b1[n] (b2 is ignored if provided).
;The scalar value provided can be:
;   1. a single number. In this case all sbc,pol, freqbins are operated on
;      with this number.
;      eg:  bout[i]=b[i] op scalarvavlue
;   2. an array of numbers with Numpol*Numsbc entries. In this case each
;      pol,sbc is operated on with its number.
;      eg. if b has 4sbc by 2 pols, sclarr[2,4] would have a separate
;          number for each sbc and the multilply would be:
;        b[n].(sbc).d[*,pol] op sclarr[pol,sbc]
;
;   The keyword norm will normalize b1 (so mean value is 1) if only b1 is 
;provided. If 2 args are provided then normalize b2 before performing the
;operation. If a mask is provided, then compute the normalization over the
;mask.
;
;EXAMPLE:
;   print,corget(lun,b1)
;   print,corget(lun,b2)
;   badd=cormath(b1,b2,/add)
;;
;; subtract a smoothed bandpass from a single rec 
;; 
;   corsmo,b1,bsmo,smo=15 
;   bout=cormath(b1,bsmo,/sub)
;;
;; bandpass correct a smoothed bandpass from a single rec 
;; 
;   corsmo,b1,bsmo,smo=15 
;   bout=cormath(b1,bsmo,/div,/norm)
;
;;  multiply data by a scalar value  1.34
;
;   bout=cormath(b1,smul=1.34);
;
;; input an entire scan, compute normalized band pass and then bandpass correct
;; each record
;   print,corinpscan(lun,binp)
;   bbandpass=coravg(binp,/norm)
;   bout=cormath(binp,bbandpass,/div)
;;
;;  input on,off data and normalize on to off record by record
;;  then average the spectra. It is probably simpler to add the records
;;  before dividing but you could do it this way to verify that the results
;;  are the same.
;;
;   print,corinpscan(lun,bon1)           ; bon1  is  n recs
;   print,corinpscan(lun,boff1)          ; boff1 is n recs
;   bonoff1=cormath(bon1,boff1,/div,/norm);bonoff1 is n recs
;   bonoff1=coravg(bonoff1)             ; bonoff1 is 1 averaged rec
;;  The faster way would be
;   print,corinpscan(lun,bon2,/avg)     ; bon2  is 1 averaged record
;   print,corinpscan(lun,boff2,/avg)    ; boff2 is 1 averaged record
;   bonoff2=cormath(bon2,boff2,/div,/norm)
;;  Use a mask (see cormask() to normalize the bandpass where the mask is 
;;  non-zero instead of the entire bandpass.
;   bonoff2=cormath(bon2,boff2,/div,/norm,mask=cmask)
;
;SEE ALSO: cormask,coravg,corinpscan
;-
;modhistory
;03may02 - created
;02sep02 - added norm, mask keywords
; doing the operations on rec at a time or not 
; nrecs1 =  nrecs2 and nonorm    at once
;24may04 = donot reform scaler if it is 1 element.
;03feb05 = fix to work with 8 sbc normscl..
;  
;
function cormath,b1,b2,sub=sub,add=add,div=div,mul=mul,$
                sadd=sadd,ssub=ssub,sdiv=sdiv,smul=smul,norm=norm,mask=mask
;
    on_error,2
    nparams=n_params()
    nrecs1=n_elements(b1)
    if nparams gt 1 then nrecs2=n_elements(b2)
    dobyrec=0               ; set true if nrecs1 > nrecs1  and nrecs1=1
    normonly=0              ; only normalize
    donorm  =0              ; normalize
;
;   check that 1 keyword is set 
;
    usescaler=0
    case 1 of 
        keyword_set(sub) or $
        keyword_set(add) or $
        keyword_set(mul) or $
         keyword_set(div) : begin
            if nparams lt 2 then begin
                message,'cormath with /sub,/add,/mul,/div requires 2 args'
                return,''
            endif
            if (nrecs1 ne nrecs2) then begin
                if (nrecs2 eq 1) then  begin
                    dobyrec=1
                endif else begin
                    message,'b1,b2 must have the same number of records'
                    return,''
                endelse
            endif
            end

         (n_elements(ssub) ne 0): begin
                scaler=ssub
                usescaler=1
                end
         (n_elements(sadd) ne 0): begin
                scaler=sadd
                usescaler=1
                end
         (n_elements(smul) ne 0): begin
                scaler=smul
                usescaler=1
                end
         (n_elements(sdiv) ne 0): begin
                scaler=sdiv
                usescaler=1
                end
         (keyword_set(norm)): begin
                normonly=1
                donorm  =1
                end
          else: begin
            message,$
    'you must set one of the keywords for cormath:/add,/sub,/mul,/div..'
            return,''
            end
    endcase
;   
    if keyword_set(norm) then begin
        donorm=1
        dobyrec=1
    endif
    nbrds=b1[0].b1.h.std.grpTotRecs
    if usescaler then begin
       nrecs1=n_elements(b1)
       nrecs2=0
       nsbctot=0
       for i=0,nbrds-1 do nsbctot=nsbctot + b1[0].(i).h.cor.numSbcOut
       if (n_elements(scaler) ne nsbctot) then $
            scaler=fltarr(nsbctot)+scaler[0]
        if n_elements(scaler) gt 1 then $ 
            scaler=reform(scaler,nsbctot)
    endif
;   
;   if we normalize compute 1./mean by sbc
;
    if (donorm) then begin
        nrecs=nrecs1
        use1=1
        if (nparams eq 2) and (not normonly) then begin
            nrecs=nrecs2
            use1=0
        endif
        normscl=fltarr(4,8,nrecs)+1.; sbc,brd,nrecs alfa..
        for i=0,nbrds-1 do begin
            if not keyword_set(mask) then begin
                ind=lindgen(b1[0].(i).h.cor.lagsbcout)
            endif else begin
                ind=where(mask.(i)[*,0] ne 0.)
            endelse
            for k=0,nrecs-1 do begin
                for j=0 , b1[0].(i).h.cor.numSbcOut-1 do  begin
                    if use1 then begin
                        normscl[j,i,k]=1./mean(b1[k].(i).d[ind,j])
                    endif else begin
                        normscl[j,i,k]=1./mean(b2[k].(i).d[ind,j])
                    endelse
                endfor
            endfor
        endfor
    endif
;
    bout=b1
;
;   b2[1] goes into each element of b1, need to do it by rec
;
    if dobyrec then begin
;        if n_elements(normscl) eq 0 then normscl=fltarr(4,4,nrecs1)+1.
        if n_elements(normscl) eq 0 then normscl=fltarr(4,8,nrecs1)+1. ;for alfa
        for k=0,nrecs1-1 do begin
            indscl=0
            for i=0,nbrds-1 do begin
                if nparams gt 1 then l= (k < (nrecs2-1))
                for j=0 , b1[0].(i).h.cor.numSbcOut-1 do  begin
                    case 1 of 
            keyword_set(sub) : $
                bout[k].(i).d[*,j]= b1[k].(i).d[*,j] - (b2[l].(i).d[*,j]*$
                                        normscl[j,i,l])
            keyword_set(add) : $
                bout[k].(i).d[*,j]= b1[k].(i).d[*,j] + (b2[l].(i).d[*,j]*$
                                        normscl[j,i,l])
            keyword_set(mul): $
                bout[k].(i).d[*,j]= b1[k].(i).d[*,j] * (b2[l].(i).d[*,j]*$
                                        normscl[j,i,l])
            keyword_set(div): $
                bout[k].(i).d[*,j]= b1[k].(i).d[*,j] / (b2[l].(i).d[*,j]*$
                                        normscl[j,i,l])
            n_elements(sadd) ne 0: $
                bout.(i).d[*,j]= b1[k].(i).d[*,j]*normscl[j,i,k] +$
                                 scaler[indscl]
            n_elements(ssub) ne 0: $
                bout.(i).d[*,j]= b1[k].(i).d[*,j]*normscl[j,i,k] -$
                                  scaler[indscl]
            n_elements(smul) ne 0: $
                bout.(i).d[*,j]= b1[k].(i).d[*,j]*normscl[j,i,k] *$
                                  scaler[indscl]
            n_elements(sdiv) ne 0: $
                bout.(i).d[*,j]= b1[k].(i).d[*,j]*normscl[j,i,k] /$
                                  scaler[indscl]
            normonly:$ 
                bout[k].(i).d[*,j]= b1[k].(i).d[*,j]*normscl[j,i,k]
                  endcase
                  indscl=indscl+1
                endfor
            endfor
        endfor
    endif else begin

    indscl=0
    for i=0,nbrds-1 do begin
       for j=0 , b1[0].(i).h.cor.numSbcOut-1 do  begin
         case 1 of 
            keyword_set(sub) : $
                bout.(i).d[*,j]= b1.(i).d[*,j] - b2.(i).d[*,j]
            keyword_set(add) : $
                bout.(i).d[*,j]= b1.(i).d[*,j] + b2.(i).d[*,j]
            keyword_set(mul): $
                bout.(i).d[*,j]= b1.(i).d[*,j] * b2.(i).d[*,j]
            keyword_set(div): $
                bout.(i).d[*,j]= b1.(i).d[*,j] / b2.(i).d[*,j]
            n_elements(sadd) ne 0: $
                bout.(i).d[*,j]= b1.(i).d[*,j] + scaler[indscl]
            n_elements(ssub) ne 0: $
                bout.(i).d[*,j]= b1.(i).d[*,j] - scaler[indscl]
            n_elements(smul) ne 0: $
                bout.(i).d[*,j]= b1.(i).d[*,j] * scaler[indscl]
            n_elements(sdiv) ne 0: $
                bout.(i).d[*,j]= b1.(i).d[*,j] / scaler[indscl]
          endcase
          indscl=indscl+1
        endfor
    endfor
    endelse
    return,bout
end
