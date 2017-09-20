;------------------------------------------------------------------------------
; prochquery - query info from proc header.
;             doppler header and return 1,0 for true,false
;
function prochsrcname,hdr
;
;   return srcname as a string
;   
    on_error,1
    return,string(hdr.proc.srcName)
end
