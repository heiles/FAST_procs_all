; used by fitsinn
;
; assume x in radians (-pi,pi)
;
function fitsinnfunc,x,m
    common fitsinncom,sinOrder

    ret=[1.]
    for i=1,sinOrder do ret=[ret,[cos(i*x)],[sin(i*x)]]
    return,ret
end

