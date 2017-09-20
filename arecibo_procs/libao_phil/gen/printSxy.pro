pro printSxy
;
; print x,y system variable values of interest
;
print,"!x,!y"
print,format='("   range: x",f11.5,f11.5," Req dataRange to plot (DCrd)")'$
                                          ,!x.range
print,format='("        : y",f11.5,f11.5)',!y.range

print,format='("  crange: x",f11.5,f11.5," dataRange last Plot (DCrd)")'$
                                          ,!x.crange
print,format='("        : y",f11.5,f11.5)',!y.crange

print,format='("   scale: x",f11.5,f11.5," Ndc=[0] +[1]*DataCd")'$
                                          ,!x.s
print,format='("        : y",f11.5,f11.5)',!y.s

print,format='("  margin: x",f11.5,f11.5," l,r.. charUnits")'$
                                          ,!x.margin
print,format='("        : y",f11.5,f11.5," b,t")',!y.margin

print,format='(" omargin: x",f11.5,f11.5," l,r..charUnits,multi window")'$
                                          ,!x.omargin
print,format='("        : y",f11.5,f11.5," b,t")',!y.omargin

print,format='("  window: x",f11.5,f11.5," ncd pltDataWindow. output only")'$
                                          ,!x.window
print,format='("        : y",f11.5,f11.5)',!y.window

print,format='("  region: x",f11.5,f11.5," ncd region. output only(see !p.")'$
                                          ,!x.region 
print,format='("        : y",f11.5,f11.5)',!y.region 
    return
end
