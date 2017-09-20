pro pseudo_ch, colr, original=original, notvlct=notvlct, hue0=hue0, loops=loops

;+
;NAME:
;	PSEUDO_CH -- apply a modified pseudo (psychologically uniform lightnesss) colortable
;
;	the mod is to, first, decrease the minimimum in red; and 
;second, to change the scaling on the 'x axis' to make the colors more
;uniformly changing. 
;
;	an older version of the program just did the minimumin red. 
;to get this, use the /original keyword.
;PURPOSE:
;	Replace the pure pseudo colortable of IDL with our modified one,
;	which subtracts some red to give a little more green
;
;CALLING SEQUENCE:
;	PSEUDO_CH, colr
;
;INPUTS: optionally, /ORIGINAL to get the original version.
;
;KEYWORD: 
;        NOTVLCT, return COLR but don't change internal IDL color tables.
;        ORIGINAL, use the purist, unmodified IDL pseudo version
;       LOOPS -- recommend loops=0.68; hue0=-50.; original=1
;       HUE0 -- recommend loops=0.68; hue0=-50.; original=1
;OUTPUTS: 
;	COLR, the 256 X 3 colortable
;
;SIDE EFFECTS:
;	redefines r_curr and r_orig (and the grn and blue counterparts),
;which are in the COLORS common block; and loads the new thing into IDL's
;colortable using TVLCT. 
;-

COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

;REMEMBER THE ORIGINAL COLOR TABLE IF NOTVLCT IS SET...
IF KEYWORD_SET( NOTVLCT) THEN tvlct, v1, v2, v3, /get
if n_elements( loops) eq 0 then loops=0.68
if n_elements( hue0) eq 0 then hue0=22.5

;RHIS IS THE ORIGINAL MOD, THAT AFFECTS RED ONLY...
;pseudo, 100, 100, 100, 100, 22.5, 0.68, colr
pseudo, 100, 100, 100, 100, hue0, loops, colr
;for nr=0,2 do print, minmax(colr[*,nr] )

IF KEYWORD_SET( ORIGINAL) THEN GOTO, SKIP

colr[*,0]= bytscl( colr[*,0], min=100,max=255)

ndx0= 2 + indgen( 84-2+1)
ndx0= interpol( ndx0, 83)
                                                                                
ndx3= 93+ indgen( 109- 93+1)
                                                                                
ndx1= 110+ indgen( 132-110+1)
ndx1= interpol( ndx1, 52)
                                                                                
ndx2= 133+ indgen( 251-133+1)
;ndx2= interpol( ndx2, 80)
ndx2= interpol( ndx2, 90)

ndx= [ndx0, ndx3, ndx1, ndx2]
                                                                                
colr[ *, 0]= interpol( colr[ ndx,0], 256)
colr[ *, 1]= interpol( colr[ ndx,1], 256)
colr[ *, 2]= interpol( colr[ ndx,2], 256)


SKIP:

IF KEYWORD_SET( NOTVLCT) THEN BEGIN
        tvlct, v1, v2, v3
    ENDIF ELSE BEGIN
        r_orig = colr[*,0] & g_orig = colr[*,1] & b_orig=colr[*,2]
        r_curr = r_orig & g_curr = g_orig & b_curr = b_orig
        tvlct,r_orig,g_orig,b_orig
ENDELSE

;for nr=0,2 do print, minmax(colr[*,nr] )
;print, keyword_set( original), 'all done!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!;

return
end
