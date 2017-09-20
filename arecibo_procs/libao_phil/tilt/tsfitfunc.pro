;-----------------------------------------------------------------------------
;   here are the function to evaluate
;
function tsfitfunc,x,m
    return,[[1.],[x],[sin(x)],[cos(x)],[sin(3.*x)],[cos(3.*x)]]
end
