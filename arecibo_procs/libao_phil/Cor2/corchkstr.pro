;+
;NAME:
;corchkstr - check buffers for same structure
;SYNTAX: istat=chbufstr(b1,b2)
;  ARGS:  
;       b1: {corget} correlator data buf
;       b2: {corget} correlator data buf
;RETURNS:
;       istat: 1  buffers are compatible
;              0  buffers are not compatible
;DESCRIPTION:
;   Some routines store correlator data structures i{corget} in arrays 
;use corstostr. This is legal if the two buffers meet the following 
;requirements. 
;1. They have the same number of brds. 
;2. Each corresponding board has the same number of subcorrelators
;3. Each sbc of each corresponding board has the same number of lags.
;
;EXAMPLE: 
;   istat=corget(lun,b1)
;   istat=corget(lun,b2)
;   same=corchkstr(b1,b2)
;-
function corchkstr,b1,b2
;
    istat=0
;
;   check number of boards
;
    if n_tags(b1) ne n_tags(b2) then return,istat
;
;    check sbc and number of lags
;
    hdronly=n_tags(b1[0].b1) lt 3
    for i=0,n_tags(b1)-1 do begin
        if hdronly then begin
            s1=n_tags(b1.(i))
            s2=n_tags(b2.(i))
            if s1 ne s2 then return,istat
        endif else begin
            s1=size(b1.(i).d)
            s2=size(b2.(i).d)
            for j=0,s1[0] do if s1[j] ne s2[j] then return,istat
        endelse
    endfor
    return,1
end

