pro print_beam2d, b2dfit

lambda= 30000./ b2dfit[ 17,0]

print, 'MEAN SIDELOBE PEAK HEIGHT/MAINBEAM PEAK = ', $
        b2dfit[ 13,0]/ b2dfit[ 2,0]
print, 'HPBW IN (ARCMIN) = ', b2dfit[5, 0]
print, 'HPBW FOR UNIF-ILL-APERTURE = ', 0.591*lambda/sqrt( b2dfit[ 16,0])
print, 'KPERJY = ',  b2dfit[ 16,0]

print, 'MAIN BEAM EFFICIENCY = ', b2dfit[ 14,0]
print, 'SIDELOBE  EFFICIENCY = ',  b2dfit[ 15,0]

print, 'RATIO SIDELOBE/MAIN = ', b2dfit[ 15,0]/ b2dfit[ 14,0]

;stop

return
end
