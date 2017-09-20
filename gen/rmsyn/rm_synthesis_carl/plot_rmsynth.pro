pro plot_rmsynth, lambdasq, stokes_q, stokes_u, phi, $
                  sigma, nsigma, $
                  WEIGHT=weight_in, $
                  MJY=mjy, $
                  PHIRANGE=phirange,$
                  DEROTATE=derotate,$
                  SOURCE=source, $
                  PSFILENAME=psfilename, $
                  FDF_FILENAME=fdf_filename, $
                  PEAK_FILENAME=peak_filename

;+
; SOURCE - source name. Scalar string.
; 
; SIGMA - polarized intensity rms for each channel, a vector
;
; /MJY - all intensities are being passed in with units of mJy; default is
;        to assume Jy.
;
; CALLS: rmsynthesis.pro, rmclean.pro, fit_fdf_peak.pro
;        depends on setcolors, psopen, psclose
;
;
;-

jystr = keyword_set(MJY) ? 'mJy' : 'Jy'

; TODO...
; * add rm uncertainty
;   * do the two methods agree
; pad xrange for lambdasq
; what's right way to handle Q/U estimates for FDF fit?
; print out info for every source
; what is blue circle segment in bryan's output? can we reproduce it?
;-> three brightest clean components

; HOW MANY LAMBDASQ CHANNELS DO WE HAVE...
nchan = N_elements(lambdasq)
nlambdasq = nchan

; WHAT IS OUR FARADAY DEPTH CHANNEL RESOLUTION...
phi_res = phi[1]-phi[0]

; CHECK FOR EXISTENCE OF WEIGHT KEYWORD...
nweight = N_elements(weight_in)
if (nweight eq 0) then begin
   ; IF NOT PASSED IN THEN JUST USE UNIFORM WEIGHTING...
   weight = dblarr(nlambdasq)+1.0
endif else begin
   weight = weight_in
   ; MAKE SURE LAMBDASQ AND WEIGHT ARRAYS ARE THE SAME SIZE...
   if (nweight ne nlambdasq) $
      then message, 'LAMBDASQ and WEIGHT vectors must have the same size.'
endelse

; SET WEIGHT TO ZERO WHERE THERE WERE ANY BLANK PIXELS...
blank = where(finite(stokes_q,/NAN) OR finite(stokes_u,/NAN),nblank)
if (nblank gt 0) then weight[blank] = 0.0d

;=-==========================================

; GETT THE BAND-AVERAGED SIGMA...
; USE /NAN TO EXCLUDE ANY MASKED SIGMA VALUES...
sigma_bavg = 1d0 / sqrt(total(1d0/sigma^2,/NAN,/DOUBLE))

;ngood = total(finite(sigma))
;print, 'SIGMAS: ', sigma_bavg, total(sigma,/nan)/ngood/sqrt(ngood)

; SET THE CUTOFF LEVEL...
cutoff = nsigma * sigma_bavg

;=-==========================================

; RUN RM SYNTHESIS...
rmsynthesis, stokes_q, stokes_u, lambdasq, phi, $
             /DOUBLE, WEIGHT=weight, fdf_dirty

; RUN RMCLEAN ON THE DIRTY FDF...
rmclean, fdf_dirty, phi, lambdasq, cutoff, $
         fdf_clean, $
         fdf_resids, $
         clean_components, $
         WEIGHT=weight, $
         RMSF=rmsf, $
         LAMBDA0SQ=lambda0sq, $
         DEROTATE=keyword_set(DEROTATE), $
         ITERATIONS=iterations;, /WATCH

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; kludge to take middle of rmsf...
nphi = n_elements(phi)
rmsf = rmsf[nphi/2:nphi/2+nphi]
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!
; WANT TO SELECT OUT THE NON-BLANK LAMBDA-SQUARED BEFORE HERE...
;!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!

; DETERMINE THE MAXIMUM FARADAY DEPTH...
; WE USE THE CHANNEL SPACING AT THE LOW-LAMBDASQ END OF THE BANDPASS...
lambdasq_channel = (lambdasq[nchan-1] gt lambdasq[0]) $
                   ? abs(lambdasq[1]-lambdasq[0]) $
                   : abs(lambdasq[nchan-1]-lambdasq[nchan-2])

; BdB05 EQ (63)...
rm_max = sqrt(3d0) / lambdasq_channel

; BdB05 EQ (62)...
rm_max_scale = !dpi / min(lambdasq)

; WHAT IS THE FWHM OF THE RM SPREAD FUNCTION...
; BdB05 EQ (61)...
rmsf_fwhm = 2d0*sqrt(3)/(max(lambdasq)-min(lambdasq))

; WHAT IS THE UNCERTAINTY IN THE PEAK FARADAY DEPTH...
; BdB05 EQ (A.17)...
sigma_lambdasq = sqrt( (total(lambdasq^2)-(total(lambdasq))^2/nchan)/(nchan-1) )

; BdB05 EQ (A.18)...
;sigma_phi_sq = 0.5/sqrt(nchan-2)/snr_channel/sigma_lambdasq

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
; this will be affected by places where weight=0

; DETERMINE THE PEAK IN THE CLEANED FARADAY DISPERSION FUNCTION...
fit_fdf_peak, real_part(fdf_clean), $
              imaginary(fdf_clean), phi, $
              cutoff, rmsf_fwhm, pclean, phimax;, sigma_qu

;!!!!!!!!!!!!!!!!
;^^^^^^^^^^^^^^^^
; WHAT'S THIS SIGMA_QU ABOUT???
; SIGMA_QU IS PASSED BACK AS THE RMS OF THE STACKED REAL AND IMAGINARY AND
; REAL PARTS; THAT'S NOT QUITE CORRECT!!!

;!!!!!!!!!!!
; THIS IS HARDWIRED; WE'RE NOT LOOKING FOR MULTIPLE PEAKS...
npeaks = 1

; CALCULATE THE SIGNAL-TO-NOISE RATION OF EACH PEAK...
snr_bavg = pclean / sigma_bavg

;!!!!!!!!!!!
;!!!!!!!!!!!
; compare with formalism from appendix
; DETERMINE THE SNR WHERE WE TAKE THE NOISE TO BE THE CHANNEL NOISE,
; SIGMA_Q,U, RATHER THAN THE BAND-AVERAGED NOISE...
sigma_rm = 0.5 * rmsf_fwhm / snr_bavg ; this snr is the peak over band-averaged noise

;================================================================

ps = (N_elements(PSFILENAME) gt 0)
if keyword_set(PS) then begin
   ;ps_file_name = (N_elements(PSFILENAME) eq 0) ? '~/rmsynthesis_plots.ps' : psfilename
   psopen, psfilename, /LANDSCAPE, /COLOR, /TIMES, /BOLD, /ISO
   !x.thick = 5
   !y.thick = 5
   !p.charsize = 0.7
endif else begin
   xsize = 1024
   ysize = 792
   window, XSIZE=xsize, YSIZE=ysize
endelse

font = keyword_set(PS) ? 0 : -1
thick = keyword_set(PS) ? 3 : 0

setcolors, /SYSTEM, /SILENT

; PRINT OUT COPIOUS AMOUNTS OF INFORMATION...
xyouts, 0.005, 0.98, /NORMAL, CHARSIZE=0.6, FONT=font, $
        textoidl($
        'Source: '+((N_elements(SOURCE) gt 0) ? source : 'Unknown')+$
        '!C!CFaraday Depth Channel Spacing: '+string(phi_res,FORMAT='(F0.1)')+' rad m^{-2}'+$
        '!C!CFaraday Depth Resolution: '+string(sigma_rm,FORMAT='(F0.1)')+' rad m^{-2}'+$
        '!C!CRMSF Width: '+string(rmsf_fwhm,FORMAT='(F0.4)')+' rad m^{-2}'+$
        '!C!C\lambda_0^2: '+string(lambda0sq,FORMAT='(F0.8)')+' m^{2}'+$
        '!C!CPolarized Sensitivity: '+string(sigma_bavg,FORMAT='(F0.6)')+' '+jystr+$
        '!C!CPeak Linearly Polarized Flux: '+string(pclean[0],FORMAT='(F0.4)')+' '+jystr+$
        '!C!CSNR: '+string(snr_bavg[0],FORMAT='(F0.2)')+$
        '!C!CFaraday Depth at Peak: '+string(phimax[0],sigma_rm,FORMAT='(F0.2," \pm ",F0.2)')+' rad m^{-2}'+$
        '!C!Cmax scale: '+string(rm_max_scale,FORMAT='(F0.2)')+' rad m^{-2}'+$
        '!C!C\phi_{max}: '+string(rm_max,FORMAT='(F0.2)')+' rad m^{-2}'+$
        '!C!CPeaks: '+string(npeaks,FORMAT='(I0.0)')+$
        '!C!CIterations: '+string(iterations,FORMAT='(I0.0)'),$
        FONT=font)

; PLOT THE PEAK COMPONENT OF THE RMCLEAN ON THIS PLOT...
xclean = pclean*cos(2*!pi*findgen(51)/50.)
;yclean = pclean*sin(2*!pi*findgen(51)/50.)
;oplot, xclean, yclean, THICK=5, LINESTYLE=2

; SET UP PLOTTING PARAMETERS...
xstart = 0.07
xstop = 0.50
ystart = 0.05
height = 0.26
buffer = 0.02
symsz = 0.6
olt = 3

;=========================================================

; PLOT THE POLARIZED INTENSITY VERSUS LAMBDA-SQUARED...
polint = sqrt(stokes_q^2 + stokes_u^2)
maxpol = max(polint)
;maxpol = 0.016/2 ; kludge!!!!
plot, lambdasq, stokes_q, /NODATA, $
      XSTYLE=3, $
      YSTYLE=3, YRANGE=2*maxpol*[-1,1], $
      XTICKFORMAT='(A1)', $
      YTIT='Polarized Intensity ['+jystr+']', $
      FONT=font, $
      /NOERASE, POSITION=[xstart,ystart+buffer+height,xstop,ystart+buffer+2*height]

axis, 0, 0, XAXIS=0, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'
axis, 0, 0, XAXIS=1, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'

symoplot, lambdasq, stokes_q, 0, ERROR=sigma, SYMSIZE=symsz, OUTLINETHICK=olt, FILLCOLOR=!green, OUTLINECOLOR=!forest
symoplot, lambdasq, stokes_u, 2, ERROR=sigma, SYMSIZE=symsz, OUTLINETHICK=olt, FILLCOLOR=!cyan, OUTLINECOLOR=!blue
symoplot, lambdasq, polint, 4, ERROR=sigma, SYMSIZE=symsz, OUTLINETHICK=olt, FILLCOLOR=!orange, OUTLINECOLOR=!red

; OVERPLOT THE Q, U, AND LINEAR POLARIZATION OF THE PEAK CLEANED FDF
; COMPONENTS...
;xfit = findgen(101)/100.*(!x.crange[1]-!x.crange[0])+!x.crange[0]
;pfit = fdf_clean[peakindx[0]] * exp(2.0*dcomplex(0,1)*phimax[0]*(xfit-mean(lambdasq)))
;for i = 1, npeaks-1 do $
;   pfit += fdf_clean[peakindx[i]] * exp(2.0*dcomplex(0,1)*phimax[i]*(xfit-mean(lambdasq)))
;if 0 then begin
;   pfit = fdfclean[0] * exp(2.0*dcomplex(0,1)*phimax[0]*(xfit-mean(lambdasq)))
;   for i = 1, npeaks-1 do $
;      pfit += fdfclean[i] * exp(2.0*dcomplex(0,1)*phimax[i]*(xfit-mean(lambdasq)))
;   qfit = real_part(pfit)
;   ufit = imaginary(pfit)
;   pafit = !radeg * 0.5 * atan(ufit,qfit)
;   oplot, xfit, qfit, THICK=thick, COLOR=!orange
;   oplot, xfit, ufit, THICK=thick, COLOR=!purple
;   oplot, xfit, abs(pfit), THICK=thick, COLOR=!cyan
;endif

sharpcorners, THICK=!x.thick

;==================================================

; PLOT STOKES U AS A FUNCTION OF STOKES Q...
maxpol = max(polint)
;maxpol = 0.010 ; kludge!!!!!!
;plotsym, 0, 1.0, /FILL
plot, stokes_q, stokes_u, /NOERASE, /NODATA, $
      XRANGE=maxpol*[-1,1], XSTYLE=3, $
      YRANGE=maxpol*[-1,1], YSTYLE=3, $
      /ISO, $
      PSYM=8, $
      FONT=font, $
      XTIT='Stokes Q ['+jystr+']', YTIT='Stokes U ['+jystr+']', $
      /NORMAL, POSITION=[0.25,0.635,0.50,1.00]

axis, 0, 0, XAXIS=0, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'
axis, 0, 0, XAXIS=1, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'
axis, 0, 0, YAXIS=0, YRANGE=!y.crange, YSTYLE=1, YTICKFORMAT='(A1)'
axis, 0, 0, YAXIS=1, YRANGE=!y.crange, YSTYLE=1, YTICKFORMAT='(A1)'

symoplot, stokes_q, stokes_u, 0, SYMSIZE=symsz, FILLCOLOR=!gray, OUTLINECOLOR=!p.color

; OVERPLOT THE U AND Q FROM THE FDF COMPOSED OF THE PEAK CLEANED FDF
; COMPONENTS...
;oplot, qfit, ufit, $
;       LINESTYLE=2, THICK=7, COLOR=!red

sharpcorners, THICK=!x.thick

;==================================================

; PLOT THE POLARIZATION ANGLE AS A FUNCTION OF WAVELENGTH-SQUARED...
polang = !radeg * 0.5 * atan(stokes_u,stokes_q)
psq = stokes_q^2 + stokes_u^2
sigma_qu = sigma ; these are the rms per channel
paerr = !radeg * 0.5 * sigma_qu / sqrt(psq)
plotsym, 0, 1.0, /FILL
plot, lambdasq, polang, $
      PSYM=8, $
      XSTYLE=3, $
      YSTYLE=1, YRANGE=[-100,100], $
      XTIT=textoidl('(Wavelength \lambda [m])^2',FONT=font), $
      YTIT='Polarization Angle [deg]', $
      FONT=font, $
      /NOERASE, POSITION=[xstart,ystart,xstop,ystart+height], /NODATA

pasymsz = 0.7 * symsz
symoplot, lambdasq, polang, 0, ERROR=paerr, SYMSIZE=pasymsz, OUTLINETHICK=otl, FILLCOLOR=!magenta, OUTLINECOLOR=!purple

axis, 0, 0, XAXIS=0, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'
axis, 0, 0, XAXIS=1, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'

;!!!!!!!!!
; these are the PA in galactic coordinates...
pa = 0.5 * atan(stokes_u, stokes_q)
paerr = 0.5 / (polint / sigma)

;oploterror, lambdasq, psrc[i].birdie.spec.pa, psrc[i].birdie.spec.paerr, $
;            co=!magenta, errco=!magenta, psym=4


; OVERPLOT THE POLARIZATION ANGLE FROM THE FDF COMPOSED OF THE PEAK CLEANED
; FDF COMPONENTS...
;if 0 then begin
;if (min(pafit) lt -89.0) AND (max(pafit) gt 89.0) then begin
;   oplot, xfit, pafit-180.0, THICK=thick, LINES=2, COLOR=!yellow
;   oplot, xfit, pafit+180.0, THICK=thick, LINES=2, COLOR=!yellow
;endif
;oplot, xfit, pafit, THICK=thick, LINES=2, COLOR=!green
;endif

sharpcorners, THICK=!x.thick

;==================================================

; MAKE A LEGEND FOR THE Q, U, AND P SYMBOLS...

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; CAN ESTIMATE CHARACTER SIZE HERE...
;delx = 0.03
;xoff = 0.015

xyouts, !x.window[0], !y.window[1]+0.0055, /NORMAL, 'Q', FONT=font
symoplot, !x.window[0]+0.012, !y.window[1]+0.011, /NORMAL, 0, SYMSIZE=symsz, OUTLINETHICK=otl, FILLCOLOR=!green, OUTLINECOLOR=!forest

xyouts, !x.window[0]+0.020, !y.window[1]+0.0055, /NORMAL, 'U', FONT=font
symoplot, !x.window[0]+0.032, !y.window[1]+0.011, /NORMAL, 2, SYMSIZE=symsz, OUTLINETHICK=otl, FILLCOLOR=!cyan, OUTLINECOLOR=!blue

xyouts, !x.window[0]+0.040, !y.window[1]+0.0055, /NORMAL, 'P', FONT=font
symoplot, !x.window[0]+0.050, !y.window[1]+0.011, /NORMAL, 4, SYMSIZE=symsz, OUTLINETHICK=otl, FILLCOLOR=!orange, OUTLINECOLOR=!red

;!!!!!!!!!!!!!!!!!!!!!!!!
; can we add paerr error bars?
; we can calculate this directly!!!

;==================================================

; SET UP PLOTTING PARAMETERS FOR FARADAY DISPERSION FUNCTIONS...
height = 0.18
buffer = 0.005
ystart = 0.05
xstart = 0.59
xstop = 0.98
xthick = keyword_set(PS) ? 3 : 0
ythick = keyword_set(PS) ? 3 : 0
xticklen = (xstop-xstart) / height * 0.02

;===================================================

; PLOT THE RMSF...
plot, phi, real_part(rmsf), $
      XRANGE=phirange, $
      XSTYLE=3, YRANGE=minmax(rmsf), YSTYLE=3, $
      YMINOR=2, $
      XTHICK=xthick, YTHICK=ythick, $
      ;XTIT=textoidl('Faraday Depth \phi [rad m^{-2}]',FONT=font), $
      XTICKFORMAT='(A1)', XTICKLEN=xticklen, $
      YTIT='Rotation Measure!CSpread Function', $
      FONT=font, $
      /NOERASE, POSITION=[xstart,ystart+4*height+4*buffer,xstop,ystart+5*height+4*buffer]

axis, 0, 0, XAXIS=0, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'
axis, 0, 0, XAXIS=1, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'

oplot, phi, imaginary(rmsf), LINESTYLE=1
oplot, phi, abs(rmsf), THICK=3, COLOR=!gray

xyouts, !x.window[1], !y.window[1]+0.008, /NORMAL, $
        textoidl('\phi_{FWHM} = '+string(rmsf_fwhm,FORMAT='(F0.4)')+' rad m^{-2}',FONT=font), $
        ALIGN=1, FONT=font

charsz = keyword_set(PS) ? 0.5 : 1.0
legend, ['Amplitude','Real Part','Imag Part'], $
        LINES=[0,0,1], THICK=[3,1,1], COLOR=[!gray,!p.color,!p.color], $
        BOX=0, CHARSIZE=charsz, FONT=font

sharpcorners, THICK=!x.thick

;===================================================

; PLOT THE DIRTY FDF...
plot, phi, real_part(fdf_dirty), $
      XRANGE=phirange, $
      XSTYLE=3, YRANGE=minmax([real_part(fdf_dirty),imaginary(fdf_dirty),abs(fdf_dirty)]), YSTYLE=3, $
      YMINOR=2, $
      XTHICK=xthick, YTHICK=ythick, $
      ;XTIT=textoidl('Faraday Depth \phi [rad m^{-2}]',FONT=font), $
      XTICKFORMAT='(A1)', XTICKLEN=xticklen, $
      YTIT='Dirty Faraday Dispersion!CFunction ['+jystr+']', $
      FONT=font, $
      /NOERASE, POSITION=[xstart,ystart+3*height+3*buffer,xstop,ystart+4*height+3*buffer]

axis, 0, 0, XAXIS=0, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'
axis, 0, 0, XAXIS=1, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'


nsigma_str = string(nsigma,FORMAT="(I0.0)")

oplot, !x.crange, cutoff*[1,1], LINESTYLE=1, COLOR=!red
xyouts, !x.crange[0], cutoff, textoidl(nsigma_str+'\sigma_{QU}',FONT=font), FONT=font, COLOR=!red

sharpcorners, THICK=!x.thick

oplot, phi, imaginary(fdf_dirty), LINESTYLE=1
oplot, phi, abs(fdf_dirty), THICK=3, COLOR=!gray

;===================================================

; PLOT THE CLEAN FDF...
plot, phi, real_part(fdf_clean), $
      XRANGE=phirange, $
      ;XSTYLE=3, YRANGE=minmax([fdf_clean,abs(fdf_clean)]), YSTYLE=3, $
      XSTYLE=3, YRANGE=minmax([real_part(fdf_clean),imaginary(fdf_clean),abs(fdf_clean)]), YSTYLE=3, $
      YMINOR=2, $
      XTHICK=xthick, YTHICK=ythick, $
      ;XTIT=textoidl('Faraday Depth \phi [rad m^{-2}]',FONT=font), $
      XTICKFORMAT='(A1)', XTICKLEN=xticklen, $
      YTIT='Cleaned FDF ['+jystr+']', $
      FONT=font, $
      /NOERASE, POSITION=[xstart,ystart+2*height+2*buffer,xstop,ystart+3*height+2*buffer]

axis, 0, 0, XAXIS=0, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'
axis, 0, 0, XAXIS=1, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'


oplot, !x.crange, cutoff*[1,1], LINESTYLE=1, COLOR=!red
xyouts, !x.crange[0], cutoff, textoidl(nsigma_str+'\sigma_{QU}',FONT=font), FONT=font, COLOR=!red

sharpcorners, THICK=!x.thick

oplot, phi, imaginary(fdf_clean), LINESTYLE=1
oplot, phi, abs(fdf_clean), THICK=3, COLOR=!gray

;===================================================

; PLOT THE FDF RESIDUALS...
plot, phi, real_part(fdf_resids), $
      XRANGE=phirange, $
      XSTYLE=3, YRANGE=2*minmax(fdf_resids), YSTYLE=3, $
      YMINOR=2, $
      XTHICK=xthick, YTHICK=ythick, $
      ;XTIT=textoidl('Faraday Depth \phi [rad m^{-2}]',FONT=font), $
      XTICKFORMAT='(A1)', XTICKLEN=xticklen, $
      YTIT='FDF Residuals ['+jystr+']', $
      FONT=font, $
      /NOERASE, POSITION=[xstart,ystart+1*height+1*buffer,xstop,ystart+2*height+1*buffer]

axis, 0, 0, XAXIS=0, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'
axis, 0, 0, XAXIS=1, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'

oplot, phi, imaginary(fdf_resids), LINESTYLE=1
oplot, phi, abs(fdf_resids), THICK=3, COLOR=!gray

oplot, !x.crange, cutoff*[1,1], LINESTYLE=1, COLOR=!red
xyouts, !x.crange[0], cutoff, textoidl(nsigma_str+'\sigma_{QU}',FONT=font), FONT=font, COLOR=!red

sharpcorners, THICK=!x.thick

;===================================================

; PLOT THE CLEAN COMPONENTS...
plot, phi, phi*0, /NODATA, $
      XRANGE=phirange, $
      XSTYLE=3, YRANGE=minmax([real_part(clean_components),imaginary(clean_components),abs(clean_components)]), YSTYLE=3, $
      YMINOR=2, $
      XTHICK=xthick, YTHICK=ythick, $
      XTICKLEN=xticklen, $
      XTIT=textoidl('Faraday Depth \phi [rad m^{-2}]',FONT=font), $
      YTIT='FDF Model Components ['+jystr+']', $
      FONT=font, $
      NOCLIP=0,$
      /NOERASE, POSITION=[xstart,ystart,xstop,ystart+height]

axis, 0, 0, XAXIS=0, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'
axis, 0, 0, XAXIS=1, XRANGE=!x.crange, XSTYLE=1, XTICKFORMAT='(A1)'

detect = where(clean_components ne complex(0,0),ndetect)

modsymsz = 0.9

for i = 0, ndetect-1 do oplot, phi[detect[i]]*[1,1], [0,real_part(clean_components[detect[i]])], COLOR=!blue
symoplot, phi[detect], real_part(clean_components[detect]), 0, SYMSIZE=modsymsz, FILLCOLOR=!cyan, OUTLINECOLOR=!blue, NOCLIP=0

for i = 0, ndetect-1 do oplot, phi[detect[i]]*[1,1], [0,imaginary(clean_components[detect[i]])], COLOR=!forest
symoplot, phi[detect], imaginary(clean_components[detect]), 2, SYMSIZE=modsymsz, FILLCOLOR=!green, OUTLINECOLOR=!forest, NOCLIP=0

for i = 0, ndetect-1 do oplot, phi[detect[i]]*[1,1], [0,abs(clean_components[detect[i]])], COLOR=!red
symoplot, phi[detect], abs(clean_components[detect]), 4, SYMSIZE=modsymsz, FILLCOLOR=!orange, OUTLINECOLOR=!red, NOCLIP=0

sharpcorners, THICK=!x.thick

;===================================================

if keyword_set(PS) then psclose

setcolors, /SYSTEM, /SILENT
!x.thick=0
!y.thick=0
!x.ticklen=0
!p.charsize=0

;return

;===================================================

; PRINT OUT THE RESULTS...

;stop

if (N_elements(FDF_FILENAME) gt 0) then begin

   openw, lun, fdf_filename, /GET_LUN
   
   ; DEFINE THE COLUMN HEADING...
   headings = string(['Faraday Depth',$
                      'Re(dirty)',$
                      'Im(dirty)',$
                      'Re(clean)',$
                      'Im(clean)',$
                      'Re(resid)',$
                      'Im(resid)',$
                      'Re(model)',$
                      'Im(model)'], FORMAT='(A16)')

   ; SHOULD PUT UNITS HERE...

   ; BUILD THE DATA TABLE...
   table = transpose([[string(phi,FORMAT='(F16.5)')],$
                      [string(real_part(fdf_dirty),FORMAT='(F16.8)')],$
                      [string(imaginary(fdf_dirty),FORMAT='(F16.8)')],$
                      [string(real_part(fdf_clean),FORMAT='(F16.8)')],$
                      [string(imaginary(fdf_clean),FORMAT='(F16.8)')],$
                      [string(real_part(fdf_resids),FORMAT='(F16.8)')],$
                      [string(imaginary(fdf_resids),FORMAT='(F16.8)')],$
                      [string(real_part(clean_components),FORMAT='(F16.8)')],$
                      [string(imaginary(clean_components),FORMAT='(F16.8)')]])

   ;printf, lun, [[headings],[table]]
   printf, lun, [[headings],[table]], FORMAT='(9A16)'

   close, lun
   free_lun, lun

   ;stop

endif

;return

if (N_elements(PEAK_FILENAME) gt 0) then begin

   openw, lun, peak_filename, /GET_LUN

   printf, lun, pclean, phimax, sigma_rm, sigma_bavg, pclean/sigma_bavg

   close, lun
   free_lun, lun

endif

end
