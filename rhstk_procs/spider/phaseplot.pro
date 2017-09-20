pro phaseplot, scannr0, frq, phase_cal_observed, phase_src_observed, $
        ozerofinal, oslopefinal, srcozerofinal, srcoslopefinal

;common plotcolors

wset,1
plot, frq, phase_cal_observed, xtit='Frequency', $
      title= 'CAL PHASE, SCN '  + strtrim(string(scannr0),2), $
        yra=[-!pi, !pi], /ysty, ytit = 'Phase, radians', psym=3 
oplot, frq, modangle(ozerofinal[0] + oslopefinal[0]*frq,2*!dpi,/NEGPOS), color=!red

wset,0
plot, frq, phase_src_observed, xtit='Frequency', $
        yra=[-!pi, !pi], /ysty, tit = 'CAL-CORRECTED SOURCE PHASE', psym=3, $
        ytit= 'Phase, radians'

;plot, frq, phase_src_observed, xtit='CAL-CORRECTED SOURCE PHASE', $
;
;        yra=[-!pi, !pi], /ysty, ytit = 'SCAN '+string(scannr0), psym=3
oplot, frq, modangle(srcozerofinal[0] + srcoslopefinal[0]*frq,2*!dpi,/NEGPOS), color=!red
end

