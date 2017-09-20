;+
;NAME:
;coraccum - accumulate a record in a summary rec
;SYNTAX: coraccum,binp,badd,new=new,scl=scl,array=array,brd=brd
;ARGS:   binp[]: {corget} input data
;          badd: {corget} accumulate data here
;KEYWORDS:
;       new    : if keyword set then this is the first call, alloc badd.
;     scl[]    : float if provided, then scale the binp data by scl before
;                adding. This can be used to weight data by g/t.
;                if scl is an array it should equal the number of output
;                boards requested (see brd keyword). If it is a scalar 
;                then that value will be used for all the boards.
;      array   : if set then treat badd as an array and add element wise
;                the array binp[n] to badd[n]. Use with the new keyword.
;                By default if badd is an array then binp will be added
;                element wise.
;     brd[]    : int if specified then only process the specified boards.
;                numbering is 1,2,3,4. 
;DESCRIPTION:
;  Accumulate 1 or more records worth of data into badd. If keyword 
;/new is set then allocate badd before adding. The header values in 
;badd will come from the first record added into badd. 
;
;   Each element of binp[i] will be added to badd with the following weights:
;1. If scl= is not defined, it defaults to 1.
;2. if binp[i].b1.accum is 0., it is set to 1.
;3. if binp[i].b1.accum is < 0 it is multplied by -1.
;   (This happens after coravg has been called on an accumlated badd.
;    It divides by badd.b1.accum and then sets badd.b1.accum to its negative.)
;4  sclFact= binp[i].b1.d*scl*binp[i].b1.accum
;5. badd.b1.d+=sclFact*binp[i].b1.d
;6. badd.b1.accum+=sclFact
;
;   When corplot is called, it will scale the data by 1./badd.b1.accum. before
;plotting.
;   When calling coraccum with the new keyword, you can include the
;array keyword. This will allocate badd to be the same dimension as
;binp. All future calls using badd will add binp element wise to badd.
;This can be used when accumulating multiple maps.
;   Accumulated data must be of the same type (numlags, numbsbc, bw,etc..).
;If you have observations to accumulate with only partial overlap of the
;data types, you can use the brd keyword to specify which boards to accum. The
;accumlated data must still be of the same type.
;
;Example:
;  
;   print,corget(lun,b)
;   coraccum,b,badd,/new
;   print,corget(lun,b)
;   coraccum,b,badd
;   corplot,badd
;
;; Add n scans together element wise:
;  for i=0,n-1 do begin
;       print,corinpscan(lun,b)
;       coraccum,b,bsum,new=(i eq 0),/array
;  endfor
;;
;; input an entire scan and then plot the average of the records
;; (this can also be done directly by corinpscan).
;   print,corinpscan(lun,b,scan=scan)
;   coraccum,b,bsum,/new
;   corplot,bsum
;;
;; let scan 1 be:4 brds,2pol, 1024 lags 
;; let scan 2 be:2 brds,2 pol,512 lags followed by 2 brds,2 pol, 1024 lags.
;; To accumulate brds 1,2 of scan 1 with brds 3,4 of scan 2:
;
;   print,corinpscan(lun,b,scan=scan1)
;   coraccum,b,badd,/new,brd=[1,2]
;   print,corinpscan(lun,b,scan=scan2)
;   coraccum,b,badd,brd=[3,4]
;
; help,badd.b1,/st
;** Structure <3957c8>, 4 tags, length=9200, refs=2:
;  H               STRUCT    -> HDR Array[1]
;  P               INT       Array[2]
; ACCUM           DOUBLE       2.00000
;  D               FLOAT     Array[1024, 2]
;-
;history:
; 12aug02 - added brd option
; 14may10 - fixed so you can accumulate to bufs that have already been
;           accumulated.
pro coraccum,b,baccum,new=new,scl=scl,array=array,brd=brd
;
    on_error,2
;  
    if n_elements(scl) eq 0 then scl=1.
    mult=1.
    usebrd=keyword_set(brd)
    if keyword_set(new) then begin
        if usebrd then begin
          if keyword_set(array) then begin
            baccum=corsubset(b,brd)
          endif else begin
            baccum=corsubset(b[0],brd)
          endelse
        endif else begin
          if keyword_set(array) then begin
            baccum=b
          endif else begin
            baccum=b[0]
          endelse
        endelse
        mult=0.             ; to zero it out
        for i=0,n_tags(baccum[0])-1 do begin
            baccum.(i).accum=0.
            baccum.(i).d=0.
        endfor
    endif 
;
;   check that some things match here
;
    numrecsinp=(size(b))[1]
    numrecsout=n_elements(baccum)
    outarray=0L
    if (numrecsout gt 1) then begin
        if (numrecsinp ne numrecsout) then $
            message,'array accumlation requires matching inp,accum dimensions'
        outarray=1L
    endif
    if usebrd then begin
        numbrdsinp=n_elements(brd)
        brdind=brd-1
    endif else begin
        numbrdsinp=n_tags(b)
        brdind=indgen(numbrdsinp)
    endelse
    numbrdsout=n_tags(baccum)
    if numbrdsinp ne numbrdsout then $
            message,'number of boards does not match, input and accum bufs'
;
;   verify that the data types are the same
;
    for j=0,numbrdsout-1 do begin
        jj=brdind[j]
        if baccum[0].(j).h.cor.bwnum ne b[0].(jj).h.cor.bwnum then begin
            lin=string(format=$
              '("Bandwidth mismatch inpbrd:",i2," accum brd:",i2)',j+1,jj+1)
            message,lin 
        endif
        if baccum[0].(j).h.cor.numsbcout ne b[0].(jj).h.cor.numsbcout then begin
            lin=string(format=$
              '("Numsbc  mismatch inpbrd:",i2," accum brd:",i2)',j+1,jj+1)
            message,lin 
        endif
        if baccum[0].(j).h.cor.lagsbcout ne b[0].(jj).h.cor.lagsbcout then begin
            lin=string(format=$
              '("Numlags mismatch inpbrd:",i2," accum brd:",i2)',j+1,jj+1)
            message,lin 
        endif
        if baccum[0].(j).h.cor.lagconfig ne b[0].(jj).h.cor.lagconfig then begin
            lin=string(format=$
              '("lagconfig mismatch inpbrd:",i2," accum brd:",i2)',j+1,jj+1)
            message,lin 
        endif
    endfor
;
;   if baccum.b1.accum is < 0 then the data has already been averaged 
;   (via coravg). In this case rescale the data back up to the unavged
;   values. Assume that for an array, the scale for the first one equals the
;   scale for all.
;
    for j=0,numbrdsout-1 do begin
        if baccum[0].(j).accum lt 0. then begin
            baccum.(j).accum*=-1.      ;make accum position
            baccum.(j).d *=baccum[0].(j).accum ; scale up data from avg
        endif
    endfor
;
;   fix up scl to match the number of output boards
;
    lscl=fltarr(numbrdsout)   ; to use the scl= then input
    mscl=fltarr(numbrdsout)   ; to scl any already accumulated data
    lenScl=n_elements(scl)
    for j=0,numbrdsout-1 do begin
        lscl[j]=( j lt lenScl) ? scl[j] : scl[lenScl-1]
    endfor
    
    for i=0,numrecsinp-1 do begin
        for j=0,numbrdsout-1 do begin
            jj=brdind[j]
;
;           also scale the input by any accums it has had.
;
            mscl=(b[i].(jj).accum)
            mscl=(mscl lt 0.)?-mscl:1.
            baccum[i*outarray].(j).d+=b[i].(jj).d*lscl[j]*mscl
            baccum[i*outarray].(j).accum+=(b[i].(jj).accum ge 1.)?$
                            lscl[j]*b[i].(jj).accum:lscl[j]*mscl
        endfor
    endfor
;
;    if outarray then begin 
;        inc=lscl
;    endif else begin
;        inc=lscl*numrecsinp
;    endelse
;    for i=0,n_tags(baccum)-1 do baccum.(i).accum=baccum.(i).accum + inc[i]
    return
end
