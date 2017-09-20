; 
;NAME:
;corstostr - move a structure to an array of structs.
;SYNTAX:    corstostr,b,ind,barr
;ARGS:   b[m]:  {corget} structure to move
;         ind:  long  index (0..n-1) in barr to store b
;     barr[n]:  {corget} array of structures. move to here. 
;DESCRIPTION:
;   The data returned by corget is an anonymous structure. This allows
;it to be dynamically generated. A drawback is that you can't combine
;different anonymous structures into an array. This routine allows
;you to place corget data from multiple calls into an array. The
;data placed in barr must all be the same correlator configuration 
;(number of boards, polarizations, and lags).
;
;The input structure can be a single structure or an array of structures.
;You must pre-allocate barr with corallocstr().
;EXAMPLE:
;..storing 1 structure at a time. Assume you want space for numrecs.
;   numrecs=200L
;   for i=1,numrecs-1 do begin
;       istat=corget(lun,b)      .. get the next rec
;       if i eq 0 then bb=corallocstr(b,numrecs) ;;.. if first, allocate bb 
;       corstostr,b,i,bb         .. store this rec
;   endfor
;
;..combine 4 scans separated by 10 scan numbers each. assume 60 recs per
;  scan. bb will hold 4*60 records when done.
;   scan=112500481L
;   for i=0,3 do begin
;     istat=corinpscan(lun,b)                  ;;.. get the scan
;     if i eq 0 then bb=corallocstr(b[0],4*60) ;;.. if first, allocate bb 
;     corstostr,b,i*60,bb                      ;;.. store in correct slot
;   endfor
;
;SEE ALSO: corallocstr.
; 
pro corstostr,b,ind,barr
;
    on_error,2
    wasdat= (tag_names(b[0].b1))[1] eq 'HF'

    lind=ind
    nlen =n_elements(b)
    nbrds=b[0].b1.h.cor.numbrdsused
    if wasdat then begin
        for k=0,nlen-1 do begin
            for j=0,nbrds-1 do begin
                 barr[lind].(j).h     =b[k].(j).h
                 barr[lind].(j).hf    =b[k].(j).hf
                 barr[lind].(j).p     =b[k].(j).p
                 barr[lind].(j).accum =b[k].(j).accum
                barr[lind].(j).d=b[k].(j).d
            endfor
            lind=lind+1L
        endfor
    endif else begin
        for k=0,nlen-1 do begin
            for j=0,nbrds-1 do begin
                 barr[lind].(j).h =b[k].(j).h
                 barr[lind].(j).d=b[k].(j).d
                 barr[lind].(j).p     =b[k].(j).p
                 barr[lind].(j).accum =b[k].(j).accum
            endfor
            lind=lind+1L
        endfor
    endelse
    return
end
