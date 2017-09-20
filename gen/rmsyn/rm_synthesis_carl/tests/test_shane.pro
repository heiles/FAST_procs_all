
; TEST SOME OF SHANE'S ATCA CABB DATA...

; read in shane's data...
;file = '0454_lambdasq_QI_UI_error.txt'
file = '1039_lambdasq_QI_UI_error.txt'
;file = '1610_lambdasq_QI_UI_error.txt'
;file = '1903_lambdasq_QI_UI_error.txt'

readcol, file, lambdasq, q, u, sigma_q, sigma_u
source = strmid(file,0,4)

;phi = 500.0 * (findgen(4097)/2048.-1d0)
;n = 1024
n = 8001
;n=64001l
phi = 4000 * (findgen(n)/(n/2)-1d0)

goto, skippo

; TRY UNIFORM WEIGHTING TO COMPARE WITH GEORGE...
weight = q*0+1d0

rmsynthesis, q, u, lambdasq, phi, fdf_dirty, WEIGHT=weight

plot, phi, real_part(fdf_dirty), LINES=1
oplot, phi, imaginary(fdf_dirty), LINES=2
oplot, phi, abs(fdf_dirty)

rmclean, fdf_dirty, phi, lambdasq, cutoff, fdf_clean, WEIGHT=weight, RMSF=rmsf;, /WATCH

oplot, phi, abs(fdf_clean), co=!red, thick=3

stop

;============================================
; CAN'T RUN GEORGE'S CLEAN WITH WEIGHTS...
; BUT FOR UNIFORM WEIGHTING WE GET IDENTICAL CLEANED FDFs...

c=2.99792458d8
freq = c/sqrt(lambdasq)

rmclean_george, real_part(fdf_dirty), imaginary(fdf_dirty), 0.0, 0.0, phi, $
                pclean, pmodel, presid, $
                qclean, qmodel, qresid, $
                uclean, umodel, uresid, $
                niters, METHOD='peakp', CUTOFF=cutoff

oplot, phi, pclean, co=!green, lines=2, thick=3

skippo:

;=========================================
; NOW WEIGHT BY RMS...

sigma_qu_sq = 0.5*(sigma_q^2 + sigma_u^2)
weight = 1d0/sigma_qu_sq
sigma_qu = sqrt(sigma_qu_sq)

plot_rmsynth, lambdasq, q, u, phi, sigma_qu, 3.0, $
              WEIGHT=weight, phirange=[-400,400], $
              SOURCE=source,$
              ;/DEROTATE,$
              FDF_FILENAME='~/foo1.txt'
              ;PSFILENAME=source+'_shane.ps',$
              ;FDF_FILENAME=source+'_shane_fdf.txt'

stop

delvarx, rmsf

rmsynthesis, q, u, lambdasq, phi, fdf_dirty, WEIGHT=weight

!p.multi=[0,1,2]
plot, phi, real_part(fdf_dirty), LINES=1, yr=max(abs(fdf_dirty))*[-1,1]
oplot, phi, imaginary(fdf_dirty), LINES=2
oplot, phi, abs(fdf_dirty)

rmclean, fdf_dirty, phi, lambdasq, cutoff, fdf_clean, WEIGHT=weight, $
         RMSF=rmsf, PHI_RMSF=phi_rmsf, FWHM=fwhm ;, /WATCH

oplot, phi, fdf_clean, co=!magenta, lines=2, thick=3

fit_fdf_peak, real_part(fdf_clean), imaginary(fdf_clean), phi, $
              cutoff, fwhm, fdf_max, phi_max

plot, phi_rmsf, real_part(rmsf), LINES=1, yr=max(abs(rmsf))*[-1,1], xs=3,co=!red, xr=[-200,200]
oplot, phi_rmsf, imaginary(rmsf), LINES=2, co=!yellow
oplot, phi_rmsf, abs(rmsf)
!p.multi=0

print, fdf_max, phi_max

stop

;===========================================
; COMPARE WITH CHRIS' CLEAN...

; WE GOT IDENTICAL RESULTS TO CHRIS FOR DIRTY SPECTRUM, BUT HE WAS
; CALCULATING LAMBDA_0 INCORRECTLY, SO WE HAD TO ALTER OUR CODE TO TAKE
; STRAIGHT MEAN OF LAMBDASQ RATHER THAN WEIGHTED

; BECAUSE HE HAD DIFFERENT LAMBDA_0, OUR CLEAN COMPS MIGHT NOT BE
; COMPARABLE...

readcol, '~/output.1039.txt', chan, rm, red, imd, rec, imc, SKIP=1

psopen, '~/chris.ps', /landscape,/color
setcolors, /sys,/sil

!p.multi=[0,1,4]
plot, rm, red
oplot, phi, real_part(fdf_dirty), co=!red

plot, rm, imd
oplot, phi, imaginary(fdf_dirty), co=!red

plot, rm, rec
oplot, phi, real_part(fdf_clean), co=!red

plot, rm, imc
oplot, phi, imaginary(fdf_clean), co=!red

!p.multi=0

psclose
setcolors, /sys, /sil

end
