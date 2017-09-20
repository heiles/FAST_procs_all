pro print_beam2d, b2dfit

lambda= 30000./ b2dfit[ 17,0]

print, 'KPERJY = ',  b2dfit[ 16,0]
print, 'MEAN SIDELOBE PEAK HEIGHT/MAINBEAM PEAK = ', $
        b2dfit[ 13,0]/ b2dfit[ 2,0]
print, 'MAIN BEAM EFFICIENCY = ', b2dfit[ 14,0]
print, 'SIDELOBE  EFFICIENCY = ',  b2dfit[ 15,0]
print, 'RATIO SIDELOBE/MAIN efficiencies= ', b2dfit[ 15,0]/ b2dfit[ 14,0]


print, 'HPBW IN (ARCMIN) = ', b2dfit[5, 0]
print, 'HPBW FOR UNIF-ILL-APERTURE = ', 0.591*lambda/sqrt( b2dfit[ 16,0])
print, 'beam ellipticity (diff/mean)=', b2dfit[ 6,0]/b2dfit[ 5,0]
print, 'PA of HPBW major axis, deg= ', b2dfit[ 7,0]


print, 'AZ OFFSET of scn cntr from beam cntr, arcmin= ', b2dfit[3,0]
print, 'ZA OFFSET of scn cntr from beam cntr, arcmin= ', b2dfit[4,0]

print, '------------------------------------------------------

nstk=3
print, 'V SQUINT MAGNITUDE, ARCMIN= ', b2dfit[ 10+ 10*nstk+ 3,0]  ;
print, 'V SQUINT PA (IN AZ/ZA SYSTEM), DEGREES= ', b2dfit[ 10+ 10*nstk+ 4,0]  ;
print, 'V SQUASH MAGNITUDE, ARCMIN= ', b2dfit[ 10+ 10*nstk+ 5,0]  ;
;print, 'V SQUASH PA, DEGREES= ', b2dfit[ 10+ 10*nstk+ 6,*]  ;
print, 'V SQUASH PA, DEGREES= ', b2dfit[ 10+ 10*nstk+ 6,0]  ;

;stop

return
end
