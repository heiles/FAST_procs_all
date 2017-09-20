;------------------------------------------------------------------------------
; dophquery - query bitmasks from doppler header. functions input
;             doppler header and return 1,0 for true,false
;
function dophsball,doph
;
;   return 1 if all subbands were doppler shifted, return 0 if only the
;   central rf band center
;   pass in doppler header
;   
    on_error,2

    return,(( doph.stat and '80000000'XL) ne 0)
end
