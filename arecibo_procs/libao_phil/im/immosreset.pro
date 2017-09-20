pro immosreset
;
; reset junk we've hard coded
;
    window,0
    !p.multi=0
    hor&ver
    !y.omargin=[0,0]
    !p.tickLen =.02 
    !p.charSize =1
    !p.charThick=1
    !x.margin   = [10,3]
    !y.margin   = [4,2]     ; bottom,top
    return
end
