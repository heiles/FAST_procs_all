;---------------------------------------------------
pro plLrAll,lr,lrfit
;
; plot everything
;
    hor
    ver,-.005,.005
    plLrResAzAll,lr,lrfit,0
    plLrResAzAll,lr,lrfit,1
    ver,-.05,.05
    hor,0,360
    plLrPRAzA,lr,0
    azSwLab,lrfit,20.,.040,0
    plLrPrAzA,lr,1
    azSwLab,lrfit,20.,.040,1
    hor&ver
    plLrPAllZa,lrfit
    plLrRAllza,lrfit
    plLrDa,lr,0,0
    plLrDa,lr,0,1
    return
end
