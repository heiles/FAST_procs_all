pro rmsynthesis, stokes_q, $
                 stokes_u, $
                 lambdasq, $
                 phi, $
                 WEIGHT=weight_in, $
                 PROGRESS=progress, $
                 FORLOOPS=forloops, $
                 DOUBLE=double, $
                 LAMBDA0SQ=lambda0sq,$
                 fdf_cube
;+
; NAME:
;       RMSYNTHESIS
;
; PURPOSE:
;       Perform rotation measure synthesis on linearly polarized
;       Stokes paramaters.
;
; CALLING SEQUENCE:
;       RMSYNTHESIS, stokes_q, stokes_u, lambdasq, phi, fdf_cube [,
;                    WEIGHT=vector][,/PROGRESS][,LAMBDASQ=variable]
;
; INPUTS:
;       STOKES_Q - the Stokes Q data; a vector or 2D or 3D array of
;                  floating point values in spectral order (spectral
;                  dimension comes first).
;
;       STOKES_U - the Stokes U data;  a vector or 2D or 3D array of
;                  floating point values in spectral order (spectral
;                  dimension comes first).  Must have the same dimensions
;                  and size as STOKES_Q.
;
;       LAMBDASQ - the lambda-squared sampling of the Stokes measurements;
;                  a floating point vector in units of inverse meters
;                  squared; must have same length as the first dimension of
;                  the Stokes cubes.
;
;       PHI - the Faraday depth; a floating point vector in units of
;             radians per meter-squared.
;
; KEYWORD PARAMETERS:
;       WEIGHT = the weight function (a.k.a. the sampling function) for the
;                complex polarized surface brightness; floating point vector
;                that must have the same length as the LAMBDASQ array.  If
;                not set, a uniform weighting is assumed.
;
;       /DOUBLE - by default, FDF_CUBE is returned as a single-precision
;                 complex array; set this keyword to force it to be
;                 returned in double-precision.  If your input STOKES_Q and
;                 STOKES_U are large, you might not have enough memory to
;                 allocate a double-precision complex FDF_CUBE.
;
;       /PROGRESS - print the progress of the synthesis to the terminal.
;
;       /FORLOOPS - use for loops instead of vectorization; the code uses
;                   vectorization by default and will provide a performance
;                   advantage up to a moderately large number of spectral
;                   channels (see BENCHMARKS below).
;
;       LAMBDA0SQ - set this optional keyword to a named variable to pass
;                   back the weighted mean lambda-squared.
;
; OUTPUTS:
;       FDF_CUBE - the Faraday dispersion function; a single-precision
;                  complex array.  If the inputs STOKES_Q cube is of size
;                  [NFREQ,NX,NY] and the input PHI vector has length NPHI,
;                  then FDF_CUBE has the dimensions [NPHI,NX,NY].  Returned
;                  as double-precision if /DOUBLE keyword is set.
;
; RESTRICTIONS:
;       All arithmetic is done in double precision.  The Faraday
;       dispersion function is returned as a single-precision complex
;       cube. As such, there is a limit to how large each of the input
;       cubes can be based on your system's physical memory.
;
; PROCEDURE:
;       Algorithm from Brentjens & de Bruyn 2005, A&A, 441, 1217.
;
; NOTES:
;       Assumes that data that are blanked are flagged with IEEE NaN.
;
;       If a whole frequency plane is masked out with IEEE NaN but a
;       non-zero weight is passed in for that channel (or the WEIGHT
;       keyword is not passed), then we force the weight for that channel
;       to be zero.
;
;       If masking is not uniform, i.e., if 3 channels are flagged in one
;       spectrum at a given position, but 5 channels are flagged at another
;       position, then this routine needs to be rewritten to deal with a
;       weight cube.
;
; BENCHMARKS:
;       Vectorization offers a performance advantage over using for loops
;       up to some product of NPHI*NLAMBDA.  On my system (x86_64 GNU/Linux
;       7GB memory 4 GB swap) this product is ~ 2 million. You should do
;       your own benchmarks if you're going to reduce lots of massive
;       cubes, but here are some figures from my system:
;
;           NX    NY NLAMBDA  NPHI     FOR-LOOPS    VECTORIZED
;            1     1      10  1000        0.0037        0.0018
;            1     1      10 10000        0.1624        0.1201
;            1     1     512  2048        0.1514        0.1255
;            1     1    2048  2048        0.5805        0.5521
;            8     8    2048  2048       37.6639       10.7935
;           16    16    2048  2048      148.9003       43.4733
;
;       So if you have a 2048 channel ATCA mosaic over 512x1024 pixels,
;       you'll want to break up the cube into small spatial chunks and
;       process each separately, say in 8x8 pixel chunks.  You should run
;       your own benchmarks to figure out what makes most sense.
;
;       I note that the numbers when run on my MacBook Pro are quite
;       different from those above, so run your own tests to see which
;       method is appropriate for your input data cubes.
;
; EXAMPLE:
;       Your telescope gives you a Stokes Q cube and Stokes U cube, most
;       likely arranged in "image order" [longitude,latitude,frequency].
;       RM Synthesis works in the spectral dimension, so we transpose the
;       cubes to "spectral order" [frequency,longitude,latitude]:
;
;       stokes_q = transpose(stokes_q,[2,0,1])
;       stokes_u = transpose(stokes_u,[2,0,1])
;
;       Now we're ready to run RMSYNTHESIS...
;
;       rmsynthesis, stokes_q, stokes_u, lambdasq, phi, fdf_cube
;
;       The Faraday dispersion function cube returned from RMSYNTHESIS is
;       in spectral order.  If you want to save it somewhere, you're
;       probably going to want to put it back in image order, so transpose
;       it while you're transposing the Stokes Q and U cubes back to image
;       order:
;
;       stokes_q = transpose(stokes_q,[1,2,0])
;       stokes_u = transpose(stokes_u,[1,2,0])
;       fdf_cube = transpose(fdf_cube,[1,2,0])
;
; MODIFICATION HISTORY:
;	Written by Tim Robishaw, USyd  08 Jun 2010
;	Changed to deal with masked channels. T. Robishaw  29 Jul 2011
;-

icomp = dcomplex(0,1)

; GET NUMBER OF FREQUENCY CHANNELS...
nlambdasq = N_elements(lambdasq)

; FIND POSITIONS THAT HAVE BEEN MASKED OUT IN THE STOKES Q OR U CUBES...
; HERE WE'RE ASSUMING BLANKED DATA HAVE BEEN ASSIGNED IEEE NaN...
blank_mask = finite(stokes_q,/NAN) OR finite(stokes_u,/NAN)

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

; GET THE SIZE OF THE INPUT STOKES CUBES...
szq = size(stokes_q)
szu = size(stokes_u)

; SANITY CHECK THAT Q AND U ARE SAME SIZE...
if (array_equal(szq[1:szq[0]],szu[1:szu[0]]) eq 0) then $
   message, "Stokes Q and U arrays MUST be the same size."

; NOW MAKE SURE THEY'RE IN SPECTRAL ORDER...
if (szq[1] ne nlambdasq) then $
   message, "Stokes Q and U arrays MUST be in spectral order "+$
            "with frequency axis in first dimension."

; HOW DO WE HANDLE INPUT ARRAYS OF VARIOUS DIMENSIONS...
case szq[0] of
   ; GIVE US A 1D INPUT AND WE GIVE BACK A [1,1,NPHI] ARRAY...
   1 : begin
      nx = 1
      ny = 1
      blank = where(blank_mask, nblank)
   end
   ; GIVE US A 2D INPUT AND WE GIVE BACK A [1,NY,NPHI] ARRAY...
   2 : begin
      nx = 1
      ny = szq[2]
      ; TO MAKE LIFE EASIER, WE TEMPORARILY TURN 2D ARRAY INTO 3D AND TURN
      ; IT BACK TO 2D BEFORE LEAVING...
      stokes_q = reform(stokes_q,[nlambdasq,nx,ny],/OVERWRITE)
      stokes_u = reform(stokes_u,[nlambdasq,nx,ny],/OVERWRITE)
      blank = where(total(blank_mask,2), nblank)
   end
   ; GIVE US A 3D INPUT AND WE GIVE BACK A [NX,NY,NPHI] ARRAY...   
   3 : begin
      nx = szq[2]
      ny = szq[3]
      blank = where(total(total(blank_mask,2),2), nblank)
   end
   ; WE DON'T WANT >3D INPUTS...
   else : message, "Don't know what to do with a "+strtrim(szq[0],2)+$
                   "D Stokes array."
endcase

; SET WEIGHT TO ZERO WHERE CHANNELS HAVE BEEN BLANKED...
if (nblank gt 0) then weight[blank] = 0.0d

; FREE UP SOME MEMORY...
blank_mask = 0b 

; HAVE WE ASKED TO DO THE MATH IN DOUBLE PRECISION...
double = keyword_set(DOUBLE)

; HOW MANY FARADAY DEPTHS DO WE HAVE...
nphi = N_elements(phi)

; INITIALIZE THE FARADAY DISPERSION FUNCTION CUBE...
fdf_cube = double $
           ? dcomplexarr(nphi,nx,ny) $
           : complexarr(nphi,nx,ny)

; BdB EQUATIONS (24) AND (38) GIVE THE INVERSE SUM OF THE WEIGHTS...
K = 1d0 / total(weight,DOUBLE=double)

; GET THE MEAN OF THE LAMBDA-SQUARED DISTRIBUTION...
; THIS IS EQUATION (32) OF BdB05...
lambda0sq = K * total(weight * lambdasq,DOUBLE=double)

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;lambda0sq = total(lambdasq,DOUBLE=double)/nlambdasq
;lambda0sq = 0.2 * lambda0sq
;lambda0sq = 0.0

if keyword_set(FORLOOPS) then goto, for_loops

; MINIMIZE THE NUMBER OF INNER-LOOP OPERATIONS BY DEFINING THE ARGUMENT OF
; THE EXPONENTIAL TERM IN BdB05 EQUATIONS (25) AND (36) FOR THE FARADAY
; DISPERSION FUNCTION...
arg = exp(-2d0 * icomp * phi ## (lambdasq - lambda0sq))

;^^^ AT SOME POINT, MAKING AN [NPHI,NLAMBDASQ] ARRAY IS GOING TO CAUSE A
; PERFORMANCE PENALTY (ESPECIALLY SINCE WE DO IT AGAIN ***INSIDE*** THE FOR
; LOOP) WHEN COMPARED TO THE FOR LOOP METHOD...

; DO THE SYNTHESIS AT EACH PIXEL IN THE IMAGE...
for j = 0, ny-1 do begin
   for i = 0, nx-1 do begin

      ; DEFINE THE OBSERVED POLARIZED SURFACE BRIGHTNESS...
      ; BdB05 EQUATIONS (8) AND (14)...
      p = (weight * dcomplex(stokes_q[*,i,j],stokes_u[*,i,j])) # rebin([1.0],nphi)
      
      ; CALCULATE THE FARADAY DISPERSION FUNCTION...
      ; BdB05 EQUATIONS (25) AND (36)...
      fdf_cube[0,i,j] = K * total(p * arg, 1, /NAN, DOUBLE=double)

      ; FREE MEMORY USED TO STORE P...
      ; IT'S FASTER TO DO THIS THAN TO USE A TEMPORARY() CALL ABOVE...
      p = 0b

   endfor

   ; GIVE US A PROGRESS REPORT IF WE'VE ASKED FOR ONE...
   if keyword_set(PROGRESS) then $
      print, 100*float(j)/(ny-1), format='($,"Progress: ",I4,"%",%"\R")'
endfor

; IN PRINCIPLE, IT WOULD BE FASTER TO MULTIPLY BY K HERE, OUTSIDE THE LOOP
; ABOVE, THAN INCLUDING THE MULTIPLICATION STEP IN THE FOR LOOP, BUT FOR
; GIGANTIC CUBES LIKE WE'RE DEALING WITH, THIS STEP IS INSANE BECAUSE WE
; HAVE TO MAKE A 2ND COPY OF THE POSSIBLY GIGANTIC FDF_CUBE JUST TO DO A
; SIMPLE MULTIPLICATION!

; IF A 2D ARRAY WAS INPUT, MAKE SURE WE PASS IT BACK AS 2D...
if (szq[0] eq 2) then begin
   stokes_q = reform(stokes_q,/OVERWRITE)
   stokes_u = reform(stokes_u,/OVERWRITE)
   fdf_dirty = reform(fdf_cube,/OVERWRITE)
endif

return

;=================================================================
; HERE WE AVOID VECTORIZING AND JUST USE A FOR LOOP...

for_loops:

; MINIMIZE THE NUMBER OF INNER-LOOP OPERATIONS BY DEFINING THE ARGUMENTS OF
; THE FOURIER TRANSFORM BEFORE WE ENTER THE LOOP...
arg = -2d0 * icomp * (lambdasq - lambda0sq)

; DO THE SYNTHESIS AT EACH PIXEL IN THE IMAGE...
for j = 0, ny-1 do begin
   for i = 0, nx-1 do begin

      ; DEFINE THE WEIGHTED COMPLEX POLARIZED INTENSITY...
      ; BdB05 EQUATION (14)....
      wp = weight * dcomplex(stokes_q[*,i,j],stokes_u[*,i,j])

      ; CALCULATE THE FARADAY DISPERSION FUNCTION...
      ; BdB05 EQUATIONS (25) AND (36)...
      ; WEIGHT BY K AFTER THE LOOP TO MINIMIZE IN-LOOP OPERATIONS...
      for p = 0, nphi-1 do $
         fdf_cube[p,i,j] = K * total(wp * exp(arg * phi[p]),/DOUBLE,/NAN) 

   endfor
   ; GIVE US A PROGRESS REPORT IF WE'VE ASKED FOR ONE...
   if keyword_set(PROGRESS) then $
      print, 100*float(j)/(ny-1), format='($,"Progress: ",I4,"%",%"\R")'
endfor

; IF A 2D ARRAY WAS INPUT, MAKE SURE WE PASS IT BACK AS 2D...
if (szq[0] eq 2) then begin
   stokes_q = reform(stokes_q,/OVERWRITE)
   stokes_u = reform(stokes_u,/OVERWRITE)
   fdf_dirty = reform(fdf_cube,/OVERWRITE)
endif

end ; rmsynthesis
