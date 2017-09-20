; 
;NAME
;x111select - select a set of scans from the entire file
;SYNTAX: numscans=x111select(sl,rfnum=rfnum,freq=freq,cal=cal)
;ARGS:
;       sl[]    : {sl} returned from getsl
;KEYWORS:
;       rfnum   : int 1..16 receiver number to use
;       freq    : float cfr of subband in Mhz.. see x111freqlist
;       cal     : int   if 1=calon recs,2=caloff recs
;RETURNS:
;       freqlist[]  : float array of  unique frequencies (mhz).
function x111select,sl,rfnum=rfnum,freq=freq,cal=cal
;
    nelm=(size(sl))[1]
    if (n_elements(cal) gt 0) then begin
        if  (( cal lt 0) or (cal gt 3)) then begin
        message,'bad cal.. values are: 0 -nocal,1=calon,2-caloff,3=calonandoff'
        endif
    endif
    count=-1
    slloc=sl
    if keyword_set(freq) then begin
        ind=where(sl.freq eq freq,count)
        ind=ind/4                   ; since 4 freq/scan
        if count le 0 then begin
            print,'no scans of ',freq,' found'
            return,''
        endif
        slloc=sl[ind]
    endif
;
; see if they asked for rfnum or cal
;
;
    case  1 of
    (n_elements(rfnum) ne 0) and (n_elements(cal) ne 0): begin
        if (cal eq 3) then begin
            ind=where(((slloc.rectype eq 1) or (slloc.rectype eq 2)) and $
                       (slloc.rfnum eq rfnum),count)
        endif else begin
            ind=where((slloc.rectype eq cal) and (slloc.rfnum eq rfnum),count)
        endelse
    end
    (n_elements(rfnum) ne 0): ind=where(slloc.rfnum eq rfnum,count)
    (n_elements(cal)   ne 0): begin
        if (cal eq 3) then begin
            ind=where((slloc.rectype eq 1) or (slloc.rectype eq 2),count)
        endif else begin
            ind=where((slloc.rectype eq cal),count)
        endelse
    end
    else: begin 
        if count le 0 then begin
            print,'no scans found'
            return,''
        endif
        return,slloc            ; just the freq part
    end
    endcase
    if count le 0 then begin
        print,'no scans found'
        return,''
    endif 
    return,slloc[ind]
end
