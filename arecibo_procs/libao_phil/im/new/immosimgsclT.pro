;-----------------------------------------------------------------------------
;immosimgscl, datAr  - scale the image
;-----------------------------------------------------------------------------
function immosimgscl,datAr,stretch=s
;
; scale the image.place in a separate function it's easy to redefine
;
        cmsize=256
        minv=min(datAr)
        maxv=max(datAr)
        scale=cmsize/(maxV-minV)
;   
;       we have a distribution of values. we've scale min-> max 0.255
;       pick a min distribution value and set it to a
;       < minDistribution value = 0
;       > maxDistribution value = maxValue
;       scale minDistr to maxDistribution MinVal maxVal
;       scale minValu->maxVal   to 0..255
;       clip below minPixValue  to 0
;       else add off2 to pixValue
;       then clip to maxPixVal
;
        minDistrPnt=15.
        maxDistrPnt=50.
        minDistrVal=150.
        maxDistrVal=255.
;
;       minDistrPnt=20. for 1325 clipping
;        maxDistrPnt=255.
;       minDistrVal=155.
;       maxDistrVal=255.

        deltax=(maxDistrPnt-minDistrPnt)
        deltay=(maxDistrVal-minDistrVal)
        scale2= deltay/deltax
;
;       scales 0 to 255 in pixels values
;
;            datAr=hist_equal((datAr-minv)*scale)
            datAr=(datAr-minv)*scale
            indexAr1=where(datAr lt minDistrPnt,count1)
            indexAr2=where(datAr ge maxDistrPnt,count2)
            datAr= (datAr-minDistrPnt)*scale2 + minDistrVal
            if count1 gt 0 then datAr[indexAr1]=0.
            if count2 gt 0 then datAr[indexAr2]=maxDistrVal
            return,255B-byte(datAr)
end
