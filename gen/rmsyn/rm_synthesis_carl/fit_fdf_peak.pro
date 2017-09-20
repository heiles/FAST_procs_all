pro fit_fdf_peak, re_cube, im_cube, phi, $
                  threshold, phi_fwhm, fdf_max, phi_max, sigma_qu, $
                  PROGRESS=progress, NOBIAS=nobias


;+
; NAME:
;       FIT_FDF_PEAK
;
;
; PURPOSE:
;       Fits a 3rd-order polynomial to the peak of a Faraday dispersion
;       function (FDF) and returns the Faraday depth and intensity at the
;       maximum.
;
; CALLING SEQUENCE:
;       FIT_PEAK_FDF, phi, fdf, phi_fwhm, phi_max, fdf_max
;
; INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;       None.
;
; OUTPUTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;	Written by Tim Robishaw, Berkeley  25 Jun 2010
;-

;!!!!!!!
; ADD OPTION TO PASS BACK SINGLE PRECISION...

; pass in AMPLITUDE of FDF...

; This routine takes the RM synthesis polarized intensity spectrum
; (a.k.a. the amplitude of the Faraday dispersion function) and does a
; 3rd-order polynomial fit to the peak in order to determine at which
; Faraday depth the peak occurs.

sz = size(re_cube)

; WHAT IF AN ENTIRE SPECTRUM OF NAN IS SENT IN???

; HOW DO WE HANDLE INPUT ARRAYS OF VARIOUS DIMENSIONS...
case sz[0] of
   ; GIVE US A 1D INPUT AND WE GIVE BACK A [1,1,NPHI] ARRAY...
   1 : begin
      nx = 1
      ny = 1
   end
   ; GIVE US A 2D INPUT AND WE GIVE BACK A [1,NY,NPHI] ARRAY...
   2 : begin
      nx = 1
      ny = sz[1]
   end
   ; GIVE US A 3D INPUT AND WE GIVE BACK A [NX,NY,NPHI] ARRAY...   
   3 : begin
      nx = sz[1]
      ny = sz[2]
   end
   ; WE DON'T WANT >3D INPUTS...
   else : message, "Don't know what to do with a "+strtrim(sz[0],2)+$
                   "D Stokes array."
endcase

; HOW MANY FARADAY DEPTHS DO WE HAVE...
nphi = N_elements(phi)

dphi = abs(phi[1]-phi[0])

; A CRITICALLY SAMPLED FDF HAS 2-3 POINTS PER RMSF FWHM...
if (phi_fwhm/dphi) lt 3.0 then $
   message, 'You are undersampling the RMSF!'

;!!!!!!!!!!!!!
; make sure nphi and sz[3] are the same

re_cube = reform(re_cube,[nx,ny,nphi],/OVERWRITE)
im_cube = reform(im_cube,[nx,ny,nphi],/OVERWRITE)

pi_cube = sqrt(re_cube^2 + im_cube^2)

;if (N_elements(DIMENSION) eq 0) then dimension = 3

; FIND THE PHI WHERE THE SAMPLED FDF IS MAXIMUM...
cube_peak_map = max(pi_cube, DIMENSION=3, cube_peak_index1d_map)

; THE INDEX OF EACH PEAK IS RETURNED AS A 1-DIMENSIONAL ARRAY INDEX...
; WE NEED THE INDEX OF THE THIRD DIMENSION, WHICH IS FARADAY DEPTH...
cube_peak_index3d_map = array_indices([nx,ny,nphi], $
                                      cube_peak_index1d_map,$
                                      /DIMENSIONS)

; REFORM THE 1D FARADAY DEPTH MAP INDICES BACK INTO A 2D MAP...
phi_peak_index_map = reform(cube_peak_index3d_map[2,*],nx,ny)
phi_peak_map = phi[phi_peak_index_map]

;stop

fdf_max = dblarr(nx,ny)
phi_max = dblarr(nx,ny)
sigma_map = dblarr(nx,ny)

below = 0l
edge = 0l
hwhm = 0l
fitted = 0l

for j = 0, ny-1 do begin
   for i = 0, nx-1 do begin

      ; IS THIS PIXEL MASKED...
      if finite(cube_peak_map[i,j],/NAN) then begin
         fdf_max[i,j] = !values.f_nan
         phi_max[i,j] = !values.f_nan
         continue
      endif

      peak_phi = phi[phi_peak_index_map[i,j]]

      ; WE SHOULD ONLY BOTHER TO DO A FIT IF THE PEAK IS GREATER THAN THE
      ; NOISE LEVEL...
      if (cube_peak_map[i,j] le threshold) then begin

         fdf_max[i,j] = pi_cube[i,j,phi_peak_index_map[i,j]]
         phi_max[i,j] = peak_phi

         below += 1l

         continue

      endif

      ; ONLY FIT TO THE VALUES WITHIN 10% OF THE FWHM...
      fit_index = where(abs(phi-peak_phi) le 0.1*phi_fwhm, nfit)

      ;stop

      ; IF THE FIT RANGE IS AT THE EDGE THEN DON'T DO A FIT...
      if (fit_index[0] eq 0) OR (fit_index[nfit-1] eq nphi-1) then begin

         fdf_max[i,j] = pi_cube[i,j,phi_peak_index_map[i,j]]
         phi_max[i,j] = peak_phi

         edge += 1l

         continue

      endif

      ; KLUDGEY....
      ; IF THE PEAK IS WITHIN 1/2 FWHM OF AN EDGE THEN DON'T FIT...
      ; WE'RE FINDING THE POLY FIT FAILS FOR THESE, BUT WE DON'T KNOW
      ; WHY...
      ;if (abs(phi[0] - peak_phi) lt 0.5*phi_fwhm) OR $
      ;   (abs(phi[nphi-1] - peak_phi) lt 0.5*phi_fwhm) then begin

      ;   fdf_max[i,j] = pi_cube[i,j,phi_peak_index_map[i,j]]
      ;   phi_max[i,j] = phi[phi_peak_index_map[i,j]]

      ;   hwhm += 1l

      ;   continue

      ;endif

      ; DO THE POLYNOMIAL FIT AND STORE THE COEFFICIENTS...
      ;pcoeff = poly_fit(phi[fit_index], fdf_cube[i,j,fit_index], 3, YFIT=pcurve, COVAR=covar, CHISQ=chisq, /DOUBLE)
      ;pcoeff3 = poly_fit(phi[fit_index], pi_cube[i,j,fit_index], 3, YFIT=pcurve3, /DOUBLE)
      pcoeff = poly_fit(phi[fit_index], pi_cube[i,j,fit_index], 2, YFIT=pcurve, COVAR=covar, CHISQ=chisq, /DOUBLE)

      ;if (abs(phi[0] - peak_phi) lt 0.5*phi_fwhm) OR $
      ;   (abs(phi[nphi-1] - peak_phi) lt 0.5*phi_fwhm) then begin

      ;   plot, phi[fit_index], pi_cube[i,j,fit_index], xs=3, ys=19
      ;   oplot, phi[fit_index], pi_cube[i,j,fit_index], ps=4, co=!red
      ;   pcurve = pcoeff[0]+pcoeff[1]*phi[fit_index]+pcoeff[2]*phi[fit_index]^2
      ;   oplot, phi[fit_index], pcurve, co=!green

      ;   hwhm += 1l

      ;   io = get_kbrd(1)
         ;continue

      ;endif

      ;plot, phi, pi_cube[i,j,*], xs=3
      ;plot, phi[fit_index], pi_cube[i,j,fit_index], xs=3, ys=19
      ;oplot, phi[fit_index], pi_cube[i,j,fit_index], ps=4, co=!red
      ;pcurve = pcoeff[0]+pcoeff[1]*phi[fit_index]+pcoeff[2]*phi[fit_index]^2
      ;oplot, phi[fit_index], pcurve, co=!green
      ;oplot, phi[fit_index], pcurve3, co=!yellow

      ;print
      ;print, chisq
      ;print, covar

      ;io = get_kbrd(1)
      ;continue

      ;if i eq 422 and j eq 1 then stop
      ;if i eq 308 and j eq 6 then stop
      
      ; FIND WHERE THE DERIVATIVE IS ZERO...
      ;peak_phi = (-pcoeff[2]-sqrt(pcoeff[2]^2-3.0*pcoeff[1]*pcoeff[3]))/(3.0*pcoeff[3])
      peak_phi = -0.5 * pcoeff[1]/pcoeff[2]
      phi_max[i,j] = peak_phi

      if abs(peak_phi) gt 5000 then stop

      ; WHAT IS THE INTENSITY OF THE FDF AT THE PEAK POSITION...
      peak_pi = poly(peak_phi, pcoeff)

      ; EXCLUDE ALL POINTS OUTSIDE THE PEAK...
      width = 2*phi_fwhm
      mask_indx = where(abs(phi-peak_phi) ge width)

      ; GET THE SIGMA BY STACKING THE REAL AND IMAGINARY PART AND TAKING
      ; THE STANDARD DEVIATION...
      sigma_qu = stddev([re_cube[i,j,*],$
                         im_cube[i,j,*]])

      sigma_map[i,j] = sigma_qu

      ; DEFAULT IS TO BIAS CORRECT...
      if not keyword_set(NOBIAS) then begin
         peak_pi = sqrt(peak_pi^2 - sigma_qu^2)
      endif

      fdf_max[i,j] = peak_pi

      fitted += 1l

      if fdf_max[i,j] lt 0 then stop

   endfor

   ; GIVE US A PROGRESS REPORT IF WE'VE ASKED FOR ONE...
   if keyword_set(PROGRESS) then $
      print, 100*float(j)/(ny-1), format='($,"Progress: ",I4,"%",%"\R")'

endfor

;!!!!!!!!!!!!!!!!!
; COMPARE TO FDF_MAX TO CUBE_PEAK_MAP AND PHI_MAX TO PHI_PEAK_MAP TO LOOK
; FOR BAD FITS!

;fdf_cube = reform(fdf_cube,/OVERWRITE)
re_cube = reform(re_cube,/OVERWRITE)
im_cube = reform(im_cube,/OVERWRITE)

sigma_qu = sigma_map

if (nx eq 1) AND (ny eq 1) then begin
   fdf_max = fdf_max[0]
   phi_max = phi_max[0]
   sigma_qu = sigma_map[0]
endif

help, below, edge, hwhm, fitted

print, n_elements(fdf_max), below+edge+hwhm+fitted

end ; fit_fdf_peak
