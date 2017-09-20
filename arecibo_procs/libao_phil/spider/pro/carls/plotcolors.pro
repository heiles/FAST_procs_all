pro plotcolors,ps=ps
;PUTS COLORS IN THE PLOT TABLE...
common colors     ;, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
common plotcolors ;, black, red, green, blue, cyan, magenta, yellow, white,grey

n_colors=(keyword_set(ps))?256: !d.n_colors
;FIRST DO THE PSEUDOCOLOR CASE...
;IF ( (nrbits eq 8) or (nrbits eq 12)) then begin 
IF ( n_colors le 256)   then begin 

;GENERATE COLORS FOR COLORED LINE PLOTS...
red = bindgen(256) 
s7 = 8
red[n_colors-s7:n_colors-1] =   byte( 255*[ 1,0,0,0,1,1, 0.5, 1])
green = bindgen(256)  
green[n_colors-s7:n_colors-1] = byte( 255*[ 0,1,0,1,0,1, 0.5, 1])
blue = bindgen(256) 
blue[n_colors-s7:n_colors-1] =  byte( 255*[ 0,0,1,1,1,0, 0.5, 1])
tvlct, red, green, blue 
r_orig = red   & r_curr = red
g_orig = green & g_curr = green
b_orig = blue  & b_curr = blue

;NEXT SET THE COLOR VALUES...
black=0 
red=    n_colors-s7 
green=  n_colors-s7+1
blue=   n_colors-s7+2
cyan=   n_colors-s7+3
magenta=n_colors-s7+4
yellow= n_colors-s7+5
grey =  n_colors-s7+6
white =  n_colors-s7+7

ENDIF

;STOP

IF ( n_colors gt 256) then begin 
red = 255l
green = 255l*256l
blue = 255l*(256l^2)
yellow = red+green
cyan = green + blue
magenta = red + blue
white = red+green+blue
black = 0l
grey = 127l*(white/255l)
;
ENDIF

end

