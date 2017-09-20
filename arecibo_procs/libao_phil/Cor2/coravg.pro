;+
;NAME:
;coravg - average correlator data.
;SYNTAX: bavg=coravg(binp,pol=pol,max=max,min=min,norm=norm,onlypol=onlypol)
;ARGS:   binp[]: {corget} input data
;KEYWORDS:
;       pol    : if set then average polarizations together
;    onlypol   : only average polarizations. if binp[] is an array
;                do not average together records.
;       max    : return max of each channel rather than average
;       min    : return min of each channel rather than average
;       norm   : if set then normalize each returned sbc to a mean of 1
;                (used when making bandpass correction spectra).
;RETURNS:
;       bavg   : {corget} averaged data.    
;DESCRIPTION:
;  coravg() will average correlator data. It has 3 basic functions:
; 1. average multiple records in a array together.
; 2. compute the average of an accumulated record (output of coraccum)
;    After doing this, it will set the bavg.b1.accum value to be the
;    negative of what was there (so corplot does not get confused).
; 3. average polarizations. This can be done on a single record, or
;    data from steps 1 or 2 above. If the /onlypol keyword is set then
;    it will average polarizations but it will not average together records.
;
;The data is returned in bavg.
;   Polarization averaging will average the two polarizations on all boards
;that have two polarization data. If polarizations are on separate correlator
;boards then the routine will average all boards that have the same setup: 
;nlags, freq, and bandwidth. It will not combine boards that have two 
;polarizations per board.
;
;   If polarization averaging is used then the following header fields will
;be modified.
;   b.(i).h.std.grptotrecs     to the number of boards returned
;   b.(i).h.std.grpcurrec      renumber 1..grptotrecs
;   b.(i).h.cor.numsbcout 2->1 for dual pol sbc
;   b.(i).h.cor.numbrdsused    to the number of returned brds after averaging.
;   b.(i).h.cor.numsbcout      to the number of returned sbc in each brd after
;                              averaging
;   b.(i).h.dop.freqoffsets    in case we reduce the number of boars from 
;                              pol averaging.
;
;   If binp contains multiple records then the max or min keyword can be
;used to return the max or minimum of each channel. This will not work
;on data from coraccum since the sum has already been performed.
;
;Example:
;  
;;  average polarizations:  
;
;   print,corget(lun,b)
;   bavg=coravg(b,/pol)
;;
;; average a scan and then average polarizations
;;
;   print,corinpscan(lun,b)
;   bavg=coravg(b,/pol)
;;
;;  average the data accumulated by coraccum
;;  then average polarizations
;;
;   print,corinpscan(lun,b)
;   coraccum,b,baccum,/new
;   print,corinpscan(lun,b)
;   coraccum,b,baccum
;   bavg=coravg(baccum,/pol)
;;
;; return max value from each channel
;;
;   print,corinpscan(lun,b)
;   bmax=coravg(b,/max)
;
;;  average polarizations but do not average records. An
;;  example would be where pfposonoff() processes all of the
;;  on/off pairs in a file (possibly different sources), and you
;;  want to average the pols of each source. 
;   
;   n=pfposonoff(file,bar,tsys,cals)    ; bar[n]
;   baravg=coravg(bar,/onlypol)         ; baravg[n] with pols averaged
;-
; history:
; 27may02 - added, min,max keywords to coravg
; 04jun02 - need to modify freq offsets in dop.frqoffsets if we
;           do pol averaging with 1 pol per board.
; 13aug02 - switched to use corsubset
; 28aug02 - added onlypol option.
; 05dec06 - when updating dop.freqoffsets[n] force n to be <=3. alfa
;           can get to 8
; 04jun09 - now need 8 freq for dopoffsets.. for was switch to 
;           use the rpfreq (reference pixel frequency)
; 14jun10 - if pol adding, multipley bavg.b1.accum by 2
function coravg,b,pol=pol,onlypol=onlypol,max=max,min=min,norm=norm
;
;   see how many records are in b
;
    on_error,2
;   print,'coravg new version'
    nrec=n_elements(b)
    if keyword_set(onlypol) then pol=1
;
;   if more than 1 rec and onlypol (no average of rec, call coravg()
;   for each rec
;
    iswas=wascheck(b=b)
    if keyword_set(onlypol) and (nrec gt 1 ) then begin
        for i=0,nrec-1 do begin &$
            bloc1=coravg(b[i],/pol,max=max,min=min,norm=norm) &$
            if i eq 0 then bloc=replicate(bloc1,nrec) &$
            bloc[i]=bloc1 &$
        endfor
        return,bloc
    endif
            
    ntags=n_tags(b[0])
;
;   average records of array
;
    if nrec gt 1 then begin
        bavg=b[0]
        for i=0,ntags-1 do begin
            case 1 of 
              keyword_set(max) : begin  
                    for k=1,nrec-1 do begin
                        bavg.(i).d=bavg.(i).d > b[k].(i).d
                    endfor
                end
              keyword_set(min) : begin  
                    for k=1,nrec-1 do begin
                        bavg.(i).d=bavg.(i).d < b[k].(i).d
                    endfor
                end
              else : begin
                for j=0,bavg.(i).h.cor.numsbcout-1 do begin
                    bavg.(i).d[*,j]=total(b.(i).d[*,j],2)/(nrec*1.)
                endfor
              end
            endcase
        endfor
;
;   divide by accum count 
;
    endif else begin
        if b.b1.accum gt 0 then begin
            bavg=b
            for i=0,ntags-1 do begin
                scale=abs(bavg.(i).accum)
                bavg.(i).d=bavg.(i).d/scale
                bavg.(i).accum=-scale
            endfor
        endif else begin
            bavg=b
        endelse
    endelse
;
;   see if they want polarization averaging
;
    if not keyword_set(pol) then begin 
        if keyword_set(norm) then begin
           nbrds=n_tags(bavg[0])
           for i=0,nbrds-1 do begin
              for j=0,bavg.(i).h.cor.numsbcout-1 do begin
                  bavg.(i).d[*,j]= bavg.(i).d[*,j]/mean(bavg.(i).d[*,j])
              endfor
            endfor
        endif
        return,bavg
    endif
;
;
    brdsused=intarr(ntags)
    numsbckeep=0
    gooddata=intarr(ntags)
    singlepolconfig=[0,1,6,7]
    dualpolconfig  =[5,8,9]
    for i=0,ntags-1 do begin
        if brdsused[i] eq 0 then begin
;
;       2 pol 1 board, just average
;
            ind=where(bavg.(i).h.cor.lagconfig eq dualpolconfig,count)
            if count gt 0 then begin
                case 1 of 
                    keyword_set(max) : begin
                       bavg.(i).d[*,0]= bavg.(i).d[*,0]>bavg.(i).d[*,1]
                       end
                    keyword_set(min) : begin
                       bavg.(i).d[*,0]= bavg.(i).d[*,0]<bavg.(i).d[*,1]
                       end
                    else: bavg.(i).d[*,0]=total(bavg.(i).d,2)*.5
                endcase
                bavg.(i).p=[1,0]
                bavg.(i).h.cor.numsbcout=1
                bavg.(i).accum*=2.
                brdsused[i]=1
                gooddata[i]=1
            endif else begin 
                ind=where(bavg.(i).h.cor.lagconfig eq singlepolconfig,count)
;
;               stokes or complex leave alone
;
                if count eq 0 then begin
                     brdsused[i]=1
                     gooddata[i]=1
                endif else begin
;
;       single pol, check for another pol that matches it..
;
                bw       =bavg.(i).h.cor.bwnum
                numlags  =bavg.(i).h.cor.lagsbcout
                brdsused[i] =1
                gooddata[i]=1
                bavg.(i).p=[1,0]
                found=0
                if (iswas) then begin
                  frq   =bavg.(i).hf.rpfreq
                  for j=i+1,ntags-1 do begin
                    if (bw      eq bavg.(j).h.cor.bwnum)      and  $
                       (numlags eq bavg.(j).h.cor.lagsbcout) and  $
                       (frq     eq bavg.(j).hf.rpfreq) and  $
                       (brdsused[j] eq 0) then begin
                       case 1 of
                        keyword_set(max) : bavg.(i).d= bavg.(i).d>bavg.(j).d
                        keyword_set(min) : bavg.(i).d= bavg.(i).d<bavg.(j).d
                        else: bavg.(i).d=bavg.(i).d + bavg.(j).d
                       endcase
                       found=found+1
                       brdsused[j]=1
                       bavg.(i).accum*=2.
                    endif
                  endfor

                endif else begin
                  frqoff   =bavg.(i).h.dop.freqoffsets[i]
                  for j=i+1,ntags-1 do begin
                    jdop=(j < 3)                 
                    if (bw      eq bavg.(j).h.cor.bwnum)      and  $
                       (numlags eq bavg.(j).h.cor.lagsbcout) and  $
                       (frqoff  eq bavg.(j).h.dop.freqoffsets[jdop]) and  $
                       (brdsused[j] eq 0) then begin
                       case 1 of 
                        keyword_set(max) : bavg.(i).d= bavg.(i).d>bavg.(j).d
                        keyword_set(min) : bavg.(i).d= bavg.(i).d<bavg.(j).d
                        else: bavg.(i).d=bavg.(i).d + bavg.(j).d
                       endcase
                       found=found+1
                       brdsused[j]=1
                       bavg.(i).accum*=2.
                    endif
                  endfor
                endelse
                if (found gt 0) and (not keyword_set(min)) and $
                        (not keyword_set(max)) then $
                        bavg.(i).d=bavg.(i).d/(found+1.)
           endelse
           endelse
        endif
    endfor
;
;   now recreate structure with fewer entries..
;
    ind=where(gooddata eq 1,count)
    bret=corsubset(bavg,ind+1,/pol)
;
;   optional normalization
;
    nbrds=n_tags(bret[0])
    if keyword_set(norm) then begin
        for i=0,nbrds-1 do begin
            for j=0,bret.(i).h.cor.numsbcout-1 do begin
                bret.(i).d[*,j]= bret.(i).d[*,j]/mean(bret.(i).d[*,j])
            endfor
        endfor
    endif
    return,bret
end
