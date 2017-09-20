pro phaseplot, scannr0, frq, phase_cal_observed, phase_src_observed, $
        ozerofinal, oslopefinal, srcozerofinal, srcoslopefinal

wset,1
plot, frq, phase_cal_observed, xtit='UNCORRECTED CAL PHASE', $
        yra=[-!pi, !pi], /ysty, ytit = 'SCAN '+string(scannr0), psym=3 
oplot, frq, ozerofinal[0] + oslopefinal[0]*frq, color=red

wset,0
plot, frq, phase_src_observed, xtit='CAL-CORRECTED SOURCE PHASE', $
        yra=[-!pi, !pi], /ysty, ytit = 'SCAN '+string(scannr0), psym=3
oplot, frq, srcozerofinal[0] + srcoslopefinal[0]*frq, color=red
end

