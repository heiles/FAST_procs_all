pro dataimg, nlist, img, divide=divide, $
bytlim=bytlim, plotred=plotred, plotgrn=plotgrn, $
rmsmult=rmsmult, median=median, rebinfctr=rebinfctr, $
windowhgt=windowhgt, removedc=removedc

;+
;make display of data to chk for interference, etc...
;subtracts (default) or divides mean (default) or median from each
;of manyh spectra and displays the result to look for small diffs.
;assumes 1024 channels...needs to be generalized...
;it displays 'residual spectra', equal to orig spectra minus or divided
;       by the mean or median.

;inputs:
;	nlist, the list of original indices (for deletion purposes)
;	img, the data array (image) assume first index multiple of 1024
;		it is rebinned to 1024
;keywords:
;	divide: assume subtracting; if divide is set, do division
;	bytlim: clipping for image display. default is +/- 5%
;	plotred: extra plot in red
;	plotgrn: extra plot in grn
;	rmsmult: scale the rms spectrum by this factor, default=1
;       median: set to use median instead of mean to gen residual spectra
;       rebinfctr= fctr to rebin by in vert dir. default is 4
;       windowhgt= window hgt in pixels; must be divisibl eby rebinfctr.
;                default is 768
;       removedc= remove dc offfset from each residual spectrum
;-

if keyword_set( windowhgt) eq 0 then windowhgt=768l

nchnl= (size( img))[1]
chnlfctr= 1024./float( nchnl)
ndata= (size(img))[2]

;CHECK FOR WINDOW 3 OPEN...
forward_function wopen
opened= wopen()
indx= where( opened eq 3, count)
if count eq 0 then window, 3, xs=1024, ys=768+128

imgzero= bytarr( 1024, 768)
if keyword_set( rmsmult) eq 0 then rmsmult=1.
if keyword_set( rebinfctr) eq 0 then rebinfctr=4

wset,3
wshow
!p.multi=0


;AVERAGE IN THE TIME DIRECTION
if keyword_set(median) then imgtot= median( img, dim=2) $
else imgtot= total(img,2)/ndata

;IF DIVIDE IS SET, NORMALIZE; OTHERWISE, SUBTRACT
IF KEYWORD_SET( DIVIDE) THEN BEGIN
imgg= img
for nr=0l, ndata-1l do imgg[*,nr]=imgg[*,nr]/ imgtot
ENDIF ELSE BEGIN
imgg= img
for nr=0l, ndata-1l do imgg[*,nr]=imgg[*,nr]- imgtot
ENDELSE

;FIND MEDIAN OF EACH SPECTRUM AND DIVIDE BY IT OR SUBTRACT IT 
;	TO REMOVE DC OFFSETS IN VERTICAL DIRECTION
IF KEYWORD_SET( REMOVEDC) THEN BEGIN
        div= fltarr( ndata)
        for nr=0l, ndata-1l do div[nr]= median( imgg[*, nr])
        IF KEYWORD_SET( DIVIDE) THEN BEGIN
        for nr=0l, ndata-1l do imgg[*,nr]= imgg[*,nr]/ div[ nr]
        ENDIF ELSE for nr=0, ndata-1 do imgg[*,nr]= imgg[*,nr]- div[ nr]
    ENDIF

;MAKE A REBINNED, DISPLAYABLE IMAGE OF IMGG
imggrebin= rebin( imgg, 1024, ndata*rebinfctr, /sample)

;stop

;BYTSCL WITH LIMITS TO MAKE IMAGES...
if keyword_set( bytlim) ne 1 then bytlim=0.05
if keyword_set( divide) then begin
	imggb= bytscl( imggrebin, min=1.-bytlim, max=1.+bytlim)
endif else imggb= bytscl( imggrebin, min=-bytlim, max=+bytlim)

;GET RMS SPECTRUM...
irms= fltarr( nchnl)
for nr=0, nchnl-1 do irms[nr]= sqrt( variance( imgg[ nr,*]))

;PLOT REF SPECTRA AT THE TOP
plot, imgtot, pos=[0, 768./(768.+128.), 1, 1], /xsty, /ysty
plot, irms, pos=[0, 768./(768.+128.), 1, 1], $
	yra= [min(irms), max( irms/rmsmult)], /xsty, /ysty, color=!blue, /noerase

;stop

if keyword_set( plotred) then $

if keyword_set( plotgrn) then $
plot, plotgrn, pos=[0, 768./(768.+128.), 1, 1], /xsty, /ysty, /noerase, color=!green

;CYCLE THRU THE IMAGES...
PRINT, 'IMG MAX AND MIN ARE ', minmax( imgg), 'and BYTLIM = ', bytlim
print, 'n for next image; c for cursor; q for quit, s for stop within proc'
print, 'p for profiles'

nrdsply=-1l
nupperdata=-1l
;nlowerdata=0l
;nupperdata=nlowerdata+ (768l/rebinfctr) - 1l < (ndata-1)

GETKBRD:
res= get_kbrd( 1)
IF RES EQ 'n' THEN BEGIN
nlowerdata= nupperdata+ 1l
if nupperdata eq ndata-1 then return

nupperdata=nlowerdata+ (768l/rebinfctr) - 1l < (ndata-1)
nrdsply=nrdsply+ 1l

print, 'nrdsply = ', strtrim(string(nrdsply),2) + $
        ' ; data range is ' + strtrim( string(nlowerdata),2) + $
        ' to ' + strtrim( string( nupperdata),2), ' / ' + $
        strtrim( string( ndata),2)
nlowerdsply= nlowerdata* rebinfctr
nupperdsply= nupperdata* rebinfctr + (rebinfctr-1l) 

;if nlowerdata eq ndata then return
tv, imgzero
tv, imggb[*, nlowerdsply: nupperdsply ]

goto, getkbrd
ENDIF

IF RES EQ 'c' THEN BEGIN
;print, 'add ', nrdsply*768l, ' to the y cursor value'
trc, xx, yy, /noc, /device
datanr= nlowerdata+ yy/ rebinfctr
print, 'you marked chnl ' + strtrim( string( xx/chnlfctr),2) + $
        ' and data number ' + strtrim( string( datanr),2) + $
        ' and nrlist= ' + strtrim( string(nlist[ datanr]),2)
print, 'n for next image; c for cursor; q for quit'
goto, getkbrd
ENDIF

IF RES EQ 'p' THEN BEGIN
profiles, imggrebin[ *, nlowerdsply: nupperdsply ]
print, 'n for next image; c for cursor; q for quit, p for profiles'
goto, getkbrd
ENDIF

IF RES EQ 's' THEN BEGIN
stop
print, 'n for next image; c for cursor; q for quit, p for profiles'
goto, getkbrd
ENDIF

IF RES EQ 'q' THEN RETURN

return
end




