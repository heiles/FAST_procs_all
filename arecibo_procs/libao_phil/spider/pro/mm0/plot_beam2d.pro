pro plot_beam2d, beamout, windowsize, $
    show= show, nterms= nterms, $
    totalbeam_mag= totalbeam_mag

;+
;NAME:
;plot_beam2d
;PURPOSE: display the 2d beam; return the total beam map optional

;INPUTS:

;   BEAMOUT, the structure containing the output data.

;   WINDOWSIZE, the size of windows to give the image in pixels. The
;windows are square and if the existing windoes are not of the proper
;size they are regenerated. We use windows 0 and 1.

;OUTPUTS:

;OPTIONAL OUTPUTS:
;
;   TOTALBEAM_MAG, the windowsize by windowsize image of the total
;beam that is normally displayed on the little 200 by 200 window in the
;bottom right corner.

;KEYWORDS:

;   SHOW: if set, it gives images of the fitted beam and sidelobe

;   NTERMS, the number of terms to use in reconstructing the
;sidelobe structure from the Fourier fit to the sidelobe structure. Use
;of NTERMS=8 forces the reconstruction to duplicate the measured points
;because there were 8 measured data points (2 on each end of the strip,
;so they are located every 45 deg around the circle). Use of NTERMS<8 is
;equivalent to least squares fitting those 8 points with a Fourier series
;having the chosen value of NTERMS, which means that the fitted curve
;will not go through the points. Seeing as the 'measured points' are really
;the result of model fits to the sidelobes with Gaussians, and that these
;fitted parameters are not perfect, I don't believe using NTERMS=8 is
;justified. Rather, some smaller value is better. Currently I am using 6.
;This needs some investigation by looking at the sidelobe coefficients,
;the original strip data, and the reconstructed results using different
;values of NTERMS to see what's appropriate. 

;-

if (keyword_set( nterms) eq 0) then nterms= 6

b2dfit= beamout.b2dfit

;BEAM MAP HAS NxN PIXELS; DEFINE N AS NR OF PTS PER STRIP...
ptsperstrip=  b2dfit[ 18,1]

;DEFINE THE AZ, ZA ARRAYS FOR THE BEAM MAPS (UNITS ARE ARCMIN)...
make_azza_newcal, ptsperstrip, b2dfit, pixelsize, azarray, zaarray

;GENERATE THE SIDELOBE AND MAINBEAM MAPS...
sidelobe_eval, nterms, beamout.fhgt, beamout.fcen, beamout.fhpbw, $
    azarray, zaarray, sidelobe
sidelobe= sidelobe/b2dfit[2,0]

mainbeam_eval_newcal, azarray, zaarray, b2dfit, mainbeam
mainbeam= mainbeam/b2dfit[2,0]
 
sidelobe_mag = congrid( sidelobe, windowsize, windowsize, /interp, /minus_one)
mainbeam_mag= congrid( mainbeam, windowsize, windowsize, /interp, /minus_one)
totalbeam_mag = mainbeam_mag+ sidelobe_mag

;--------
;DISPLAY THE SIDELOBE MAP...
IF (keyword_set( show)) THEN BEGIN

;CHECK WINDOWS...OPEN IF NECESSARY
device, window=opnd
for nwindow= 0,1 do begin 
if ( opnd(nwindow) eq 0) then begin 
        window, nwindow, xs=windowsize, ys=windowsize 
endif else begin 
        wset,nwindow 
        if ( (!d.x_vsize ne windowsize) or (!d.y_vsize ne windowsize)) $
                then window, nwindow, xs=windowsize, ys=windowsize 
endelse 
endfor

wset,0 & wshow
tvscl, sidelobe_mag
plots, [0.5,0.5], [0,1], /norm, lines=1
plots, [0,1], [0.5,0.5], /norm, lines=1

;DISPLAY BOTH TOGETHER...
wset,1 & wshow
tvscl, totalbeam_mag
plots, [0.5,0.5], [0,1], /norm, lines=1
plots, [0,1], [0.5,0.5], /norm, lines=1

ENDIF

return
end

