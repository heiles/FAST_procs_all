;-----------------------------------------------------------------------------
; azsweval.. evaluate azimuth swing
;
function azsweval,azf,az
    return,(azf.c0 + azf.c1*az + $
        azf.az1A*sin(   az*!dtor-azf.az1Ph) + $
        azf.az3A*sin(3.*az*!dtor-azf.az3Ph))
end
