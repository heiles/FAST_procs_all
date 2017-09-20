;+
;NAME:
;calonofffind - find all of the cal on/offs in  file
;SYNTAX: numfound=calonoffind(lun,sl,indon)
;ARGS:
;   lun:    int lun for file to search
;   sl[]:   {getsl} scan list structure (returned from getsl(sl).
;RETURNS:
;   indon[numfound]: int  indices into sl for the start of each cal on of
;                    a pair.
;DESCRIPTION:
;   Find all of the calonoff pairs in a file. Return the indices into sl
;for the calon scans. For a pair to be included the calon scan must be
;immediately followed by a cal off scan.
;
;EXAMPLES:
;   sl=getsl(lun)
;   numfound=calonoffind(lun,sl,indon)
;   for i=0,numfound-1 do begin
;       print,posscan(lun,sl[ind[i]].scan,1,sl=sl) ; position to start calon
;       istat=corcalonoff(lun,retdat)   ; process each onoff pair
;   endfor
;SEE ALSO:
;   getsl,corcalonoff
;-
function calonofffind,lun,sl,indon
    numfound=0
    indon=where(sl.rectype eq 1,count)
    if count le 0 then goto,done
;
;   check that indon+1 is a caloff. 
;   be careful if indon[last] is the last entry in sl. we don't
;   want to index beyond the end of the array
;
    onlast=indon[n_elements(indon)-1]          ; index for last on
    if onlast ge (n_elements(sl)-1) then begin ; last on=last scan..
        if (onlast le 1) or (n_elements(indon) le 1)  then goto,done 
        indon=indon[0:n_elements(indon)-1]    ; make onlast 1 smaller
    endif
    ind=where(sl[indon+1].rectype eq 2,count)  ; cal off follows cal on
    if count le 0 then goto,done
    indon=indon[ind]
    numfound=n_elements(ind)
done:
    return,numfound
end
