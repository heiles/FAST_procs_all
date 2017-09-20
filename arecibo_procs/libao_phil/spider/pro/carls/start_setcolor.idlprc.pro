xsz = 300
ysz = 225
if (nrbits eq 'pseudo') then begin 
device, pseudo=8, retain=2 
print, 'SETTING 8-BIT PSEUDOCOLOR WITH SYSTEM-RESTRICTED COLORS...' 
window, 0, xsize=xsz, ysize=ysz, retain=2 
endif

if (nrbits eq 'pseudo256') then begin 
device, pseudo=8 , retain=2 
print, 'SETTING 8-BIT PSEUDOCOLOR WITH 256 COLORS...' 
window,0,colors=256, xsize=xsz, ysize=ysz, retain=2  
endif

if (nrbits eq 'true') then begin 
print, 'SETTING 24-BIT TRUE_COLOR...' 
device, true_color=24 , retain=2 
window, 0, xsize=xsz, ysize=ysz, retain=2  
endif

if (nrbits eq 'direct') then begin 
print, 'SETTING 24-BIT DIRECT_COLOR...' 
device, direct_color=24 , retain=2 
window, 0, xsize=xsz, ysize=ysz, retain=2  
endif

if (nrbits ne '0') then device, cursor_standard=46 
;device, cursor_standard=24 (circle/bulls eye type of thing)

end
