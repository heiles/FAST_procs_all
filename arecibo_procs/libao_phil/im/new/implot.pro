;---------------------------------------------------------------------------
;implot,{imdrec} - plot a an im data structure
;---------------------------------------------------------------------------
; s   - record to plot
pro implot,r
;
stp=r.h.spanMhz/400.
x= (findgen(401) - 200.) * stp + r.h.cfrDataMhz
title=string(format='("cfr:",f5.0," Mhz  span:",f5.0," Mhz  tm:",i2,":",i2,":",i
2)', $
 r.h.cfrDataMhz,r.h.spanMhz,r.h.secMid/3600, (r.h.secMid mod 3600)/60,  $
  r.h.secMid mod 60)

plot,x,r.d, xtitle="freq [Mhz]", ytitle="pwr [dbm]",title=title
return
end
