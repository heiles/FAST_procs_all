;---------------------------------------------------
pro plLrDa,lr,wait,over
;
;   plot dy,dx for all az spins
;
    if (n_elements(wait) eq 0) then wait=0
    if (n_elements(over) eq 0) then over=0
    a=size(lr)
    if  a[0] eq 1 then last=0 else last=a[2]-1
    overloc=0
    nolab  = over
    a=' '
    for i=0,last do begin
        pllrd1,lr,i,overloc,nolab
        overloc=over
        a=" "
        if wait ne 0 then read,a
    endfor
    return
end
