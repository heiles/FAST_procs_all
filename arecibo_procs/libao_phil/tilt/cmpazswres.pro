;+
;cmpazswres - compute azswing data - fit
;-
function cmpazswres,da,azfit,ind,roll=roll
    forward_function azsweval
	if n_elements(roll) eq 0 then roll=0
    azrd=da[*,ind].az * !dtor
    if roll eq 0 then begin
        return, da[*,ind].p - azsweval(azfit[ind].p,da[*,ind].aznomod )
    endif
    return, da[*,ind].r - azsweval(azfit[ind].r,da[*,ind].aznomod )
end

