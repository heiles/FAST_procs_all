pro ct_fiddle, channels, LOW=low, HIGH=high, GAMMA=gamma, $
               GRANGE=grange
;+
; NAME:
;       ct_fiddle
;
; PURPOSE:
;       To fiddle with the color table.  The user can select which channels 
;       of the color table to manipulate.  The user can change the gamma 
;       correction and the range of the color table indices.
;
; CALLING SEQUENCE:
;	CT_FIDDLE [, CHANNELS] [, LOW=value] [, HIGH=value] [,
;	GAMMA=value] [, GRANGE=[min,max]]
;
; OPTIONAL INPUTS:
;       CHANNELS: A string argument.  CHANNELS sets which color
;                 channels ('R' for red, 'G' for green, 'B' for blue) 
;                 will be manipulated in the color table.  The user
;                 can manipulate one, two or all channels.  To fiddle
;                 with the red and blue channels simultaneously,
;                 set channels equal to the string 'rb'.
;
; KEYWORD PARAMETERS:
;	LOW = The lowest pixel value to use.  If this parameter is omitted,
;	      0 is assumed.  Appropriate values range from 0 to the number 
;	      of available colors-1.
;
;	HIGH = The highest pixel value to use.  If this parameter is omitted,
;	       the number of colors-1 is assumed.  Appropriate values range 
;	       from 0 to the number of available colors-1.
;
;	GAMMA =	Gamma correction factor.  If this value is omitted, 1.0 is 
;		assumed.  Gamma correction works by raising the color indices
;		to the Gamma power, assuming they are scaled into the range 
;		0 to 1.
;
;       GRANGE = The desired range of the gamma axis, a 2-element
;                vector.  The first element is the axis minimum, and 
;                the second is the maximum. The default is [0.1,10.0].
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;	COLORS:	The common block that contains R, G, and B color
;		tables loaded by LOADCT, HSV, HLS and others.
;
; SIDE EFFECTS:
;	Image display color tables are changed.
;
; RESTRICTIONS:
;       If using TrueColor visual class, color decomposition must be 
;       switched off in order for this routine to work.
;
; EXAMPLE:
;       Load the BLUE/GREEN/RED/YELLOW color table and fiddle with 
;       the red and blue channels:
;
;       IDL> loadct, 4
;       % LOADCT: Loading table BLUE/GREEN/RED/YELLOW
;       IDL> ct_fiddle, 'rb'
;
; MODIFICATION HISTORY:
;   08 May 2004  Written by Tim Robishaw, Berkeley
;   Heavily modified version of Carl Heiles's DIDDLE.
;-

on_error, 2

; GET THE IDL COLOR COMMON BLOCK...
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

; GET THE VISUAL CLASS AND CHECK THE STATE OF COLOR DECOMPOSITION...
device, GET_VISUAL_NAME=visual, GET_DECOMPOSED=decomposed

; HOW MANY COLOR TABLE INDICES ARE AVAILABLE...
ncolors = !d.table_size

; COULD BE THE CASE THAT !P.MULTI IS NOT SET TO ZERO,
; SO SAVE INITIAL VALUE, SET IT TO ZERO AND SET BACK TO ZERO
; WHEN DONE...
psave = {p:!p,x:!x,y:!y}
!p.multi = 0

; GET THE CURRENT COLOR TABLE...
tvlct, r_start, g_start, b_start, /GET

; HAS A COLOR TABLE BEEN LOADED YET...
if (N_elements(r_orig) eq 0) then begin
    r_orig = r_start
    g_orig = g_start
    b_orig = b_start
endif

; WHICH CHANNELS WILL BE MANIPULATED...
rgb = (N_elements(CHANNELS) eq 0) ? [1,1,1] : $
      [strpos(strlowcase(channels),'r') ne -1, $
       strpos(strlowcase(channels),'g') ne -1, $
       strpos(strlowcase(channels),'b') ne -1]
rgb = rgb + (total(rgb) eq 0)

; INITIALIZE INPUTS...
if (N_elements(LOW) eq 0) then low = 0L
if (N_elements(HIGH) eq 0) then high = !d.table_size-1L
if (N_elements(GAMMA) eq 0) then gamma = 1.0
if (N_elements(GRANGE) ne 2) then grange=[0.10,10.0]

; SAVE THE ORIGINAL WINDOW NUMBER SO THAT WE GO BACK TO IT UPON RETURN...
windownr = !d.window

; DEFINE THE COLOR TABLE WINDOW AND THE PIXMAP...
window, XSIZE=400, YSIZE=100, /FREE, /PIXMAP
pixwin = !d.window

device, GET_SCREEN_SIZE=screen
;window, XSIZE=400, YSIZE=100, XPOS=0.01*screen[0], YPOS=0.05*screen[1], $
window, XSIZE=400, YSIZE=100, XPOS=0.01*screen[0], YPOS=0.5*screen[1], $
  /FREE, RETAIN=2, TITLE='Color & Gamma Control'
ctwin = !d.window

; OUTPUT DIRECTIONS AND STARTING VALUES...
print, 'Original window: '+strtrim(windownr,2), format='(%"\N",A,%"\N")'
print, '  LEFT button controls MIN'
print, 'MIDDLE button controls GAMMA'
print, ' RIGHT button controls MAX'
print
print, 'The horizontal position of the cursor gives the value.'
print, 'Press <s> to quit and maintain the current color table.'
print, 'Press ANY OTHER key to QUIT', format='(A,%"\N")'
print, 'Color Channels: '+strjoin((['R ','G ','B '])[where(rgb)]), $
       format='(A,%"\N")'
print, '','LOW','HIGH','GAMMA', format='(A10,2A5,A10)'
print, 'STARTING: ', low, high, gamma, format='(A10,2I5,F10.5)'

goto, update

beginagn:

    ; WAS THE CONTROL WINDOW CLOSED...
    device, WINDOW_STATE=openwindows
    windowkill = openwindows[ctwin] eq 0B
    if windowkill then goto, done

    ; SLOW IT DOWN A BIT...
    wait, 0.01

    ; CHECK TO SEE IF WE SHOULD QUIT...
    key_pressed = get_kbrd(0)

    ; KEEP GOING UNTIL A KEY IS PRESSED...
    if (strlen(key_pressed) eq 1) then goto, done

    ; CHECK FOR MOUSE ACTIVITY...
    cursor, xx, yy, /NOWAIT, /DATA
    xx = (0. > xx) < 1.0

    ; WHICH MOUSE BUTTON WAS CLICKED...
    case !mouse.button of
        1 : low = byte(xx * (ncolors-1)) < high ; DON'T GO ABOVE THE HIGH...
        4 : high = byte(xx * (ncolors-1)) > low ; DON'T GO BELOW THE LOW...
        2 : gamma = grange[0]^(1.0-xx) * grange[1]^xx
        else : goto, beginagn
    endcase


; ONLY UPDATE THE DISPLAY IF A CHANGE WAS MADE...
update:

    ; DISPLAY IN THE PIXMAP...
    wset, pixwin

    ; STRETCH THE COLOR TABLE OVER THE NEW VALUES...
    ctnew = bytscl( ( (findgen(ncolors)-low) / $
                      ((low lt high) ? (high-low) : 1.0) $
                      < 1.0 > 0.0 )^gamma, $
                    MIN=0.0, MAX=1.0, TOP=ncolors-1)

    ; ONLY CHANGE SPECIFIED CHANNELS...
    if rgb[0] then r_curr = r_start[ctnew]
    if rgb[1] then g_curr = g_start[ctnew]
    if rgb[2] then b_curr = b_start[ctnew]

    ; LOAD THE STRETCHED COLOR TABLE...
    tvlct, r_curr, g_curr, b_curr

    ; ESTABLISH POSITIONS OF AXES...
    plot, [0,1], [0,1], /NODATA, XSTYLE=5, YSTYLE=5, $
          POSITION=[.05,.15,.95,.85]

    ; TV THE COLOR TABLE...
    xsize = (!x.window[1]-!x.window[0])*!d.x_vsize+1
    ysize = (!y.window[1]-!y.window[0])*!d.y_vsize+1
    x0 = !x.window[0]*!d.x_vsize
    y0 = !y.window[0]*!d.y_vsize
    tv, bytscl(findgen(xsize), TOP=ncolors-1) # (bytarr(round(ysize/3))+1B), $
        x0, y0, CHANNEL=0

    ; TV THE RED, GREEN, AND BLUE CHANNELS...
    tv, bytscl(findgen(xsize), TOP=ncolors-1) # (bytarr(round(ysize/9))+1B), $
        x0, y0+6./9.*ysize, CHANNEL=1*decomposed
    tv, bytscl(findgen(xsize), TOP=ncolors-1) # (bytarr(round(ysize/9))+1B), $
        x0, y0+7./9.*ysize, CHANNEL=2*decomposed
    tv, bytscl(findgen(xsize), TOP=ncolors-1) # (bytarr(round(ysize/9))+1B), $
        x0, y0+8./9.*ysize, CHANNEL=3*decomposed

    ; BOTTOM AXIS WILL BE FOR LOW/HIGH COLOR INDICES...
    axis, XAXIS=0, XSTYLE=1, XRANGE=[0,ncolors-1], XTICKS=10, $
          XTICKV=[indgen(8)*(fix((ncolors-1)/8)+1),ncolors-1], TICKLEN=0.1, $
          CHARSIZE=0.86

    ; TOP AXIS WILL BE FOR GAMMA...
    axis, XAXIS=1, XSTYLE=1, XRANGE=grange, /XLOG, TICKLEN=0.1, $
          CHARSIZE=0.86
    xyouts, 0.25, 0.33*(1+2*!y.window[1]), /NORMAL, 'Gamma', $
            CHARSIZE=0.86

    ; PLOT THE FUNCTIONAL FORM OF GAMMA IN THE PIXMAP...
    xplot = findgen(1000)/999.
    oplot, (low + (high-low)*xplot)/float(ncolors-1), xplot^gamma

    ; PLOT THE MIN, MAX...
    plots, low/float(ncolors-1)*[1,1], !y.crange
    plots, high/float(ncolors-1)*[1,1], !y.crange

    ; OUTPUT THE NEW VALUES...
    xyouts, .21, .45, strtrim(low,2), /NORMAL, CHARSIZE=1.5, ALIGN=0.0
    xyouts, .83, .45, strtrim(high,2), /NORMAL, CHARSIZE=1.5, ALIGN=1.0
    xyouts, .5, .45, string(gamma, format='(f8.3)'), /NORMAL, ALIGN=0.5, $
            CHARSIZE=1.5

    ; DUMP THE PIXMAP IMAGE ON THE WINDOW...
    wset, ctwin
    device, COPY=[0,0,!d.x_vsize,!d.y_vsize,0,0,pixwin]

    ; GO BACK TO THE WINDOW...
    wset, ctwin

    goto, beginagn

done:

; GO BACK TO ORIGNAL WINDOW...
wset, windownr
!p = psave.p
!x = psave.x
!y = psave.y

; REPORT THE ENDING PARAMETERS AND RETURN TO THE PREVIOUS ACTIVE WINDOW...
print, 'ENDING: ', low, high, gamma, format='(A10,2I5,F10.5,%"\N")'
print, 'Returning to window: '+strtrim(windownr,2),format='(A,%"\N")'

; DELETE THE COLOR TABLE WINDOW AND THE PIXMAP...
wdelete, pixwin
if not windowkill then wdelete, ctwin

if (key_pressed eq 's') then begin
    ; SAVE THIS COLOR TABLE AS THE ORIGINAL COLOR TABLE...
    r_orig = r_curr
    g_orig = g_curr
    b_orig = b_curr
endif else begin
    ; RESET THE COLOR TABLE TO STARTING VALUES...
    r_curr = r_start 
    g_curr = g_start 
    b_curr = b_start
    tvlct, r_curr, g_curr, b_curr
endelse

end; ct_fiddle
