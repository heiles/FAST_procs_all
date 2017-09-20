;pro xpyfit_newcal, nrstrip, offset, pwr, $              
;        tfit, sigma, stripfit, sigstripfit, problem, cov

pro xpyfit_newcal, nrstrip, offset, pwr, $              
        tfit, sigma, stripfit, sigstripfit, problem, cov

;+
;NAME:
;xpyfit_newcal
;PURPOSE:
;      For each 1-d scan (strip), and given the total intensity Stokes I, 
;fits 3 Gaussians, two to sidelobes and one to main beam, for 
;the strip. The main beam Gaussian has a skew parameter to represent coma.
;
;INPUTS:
;   NRSTRIP, the sequential number of the strip (0 to NRSTRIPS-1).
;
;   OFFSET, the angular offset from the assumed center IN UNITS OF
;THE ASSUMED HPBW. 
;
;   PWR, the Stokes I total system temperature at each
;observed point. Units are Kelvins.
;
;OUTPUTS:
;   TFIT, the fitted line to the datapoints.
;
;   SIGMA, the rms of the residuals (PWR- TFIT)
;
;   STRIPFIT, SIGSTRIPFIT, which are defined in the documentation for
;BEAM1DFIT.PRO
;
;   PROBLEM: indicates a problem with the nonlinear Gaussian fits.
;I'm not sure that this is properly defined.
;
;   COV, the covariance matrix, or its normalized counterpart, in the
;nonlinear Gaussian fits. I'm not sure this is properly defined.
;
;NOTES;
;   SIGMALIMIT, is the limit beyond which points are discareded, is
;hardwire defined here. 
;
;   ALL INPUT ANGULAR WIDTHS, OFFSETS and ALL OUTPUT ANGLES are in units
;of the original guessed HPBW.  They are not 1/E and the units are NOT
;arcmin. 
;
;HOW IT WORKS: 
;   FIRST STAGE: It tries three Gaussians, one for each sidelobe and
;one for the main beam. It checks the width and errors
;for the sidelobe fits, and if they ok it returns. If one Gaussian has
;parameters that are out of bounds, it goes to the second stage.
;
;   SECOND STAGE: It tries to fit two Gaussians, one for a sidelobe and
;one for the main beam.  There are two possible cases: one with the
;sidelobe on the left, one with the sidelobe on the right.  It checks
;both solutions and picks the one it likes best, based on the same
;parameter test used in the first stage.  If neither is acceptable, it
;goes to the THIRD STAGE. 
;
;   THIRD STAGE: It fits a Gaussian to the main beam only--no sidelobes.
;
;modified 28 oct 2000 to check widthmin as well as widthmax.
;modified 19 oct 2002 for newcal
;-

common plotcolors

;DEFINE SIGMALIMIT FOR DISCARDING POINTS...
sigmalimit=3.

;IN THE FIT, DISCARD SIDELOBES IF THEIR WIDTHS EXCEED WIDTHMAX...
widthmax = 1.
widthmin = 0.3

hgt_final = fltarr(3)
cen_final = fltarr(3)
wid_final = fltarr(3)
sighgt_final = fltarr(3)
sigcen_final = fltarr(3)
sigwid_final = fltarr(3)
ndata = n_elements( pwr)

;---------FIRST TRY FITTING THREE GAUSSIANS.

ngaussians = 3
tsys00 = 0.5*( pwr[0] + pwr[ndata -1])
slope00 = 0.
alpha00 = 0.

hgt = 0.5*(pwr[ ndata/2 -1]+ pwr[ ndata/2]) - tsys00
hgt0 = [ hgt, 0.05*hgt, 0.05*hgt]
cen0 = [ 0., -1.6, 1.6]
wid0 = [1.0, 0.6, 0.6]

hgt00= hgt0
cen00= cen0
wid00= wid0

;stop

gfit_allcal, sigmalimit, offset, pwr, $
    tsys00, slope00, alpha00, hgt00, cen00, wid00, $
        tfit, sigma, $
    tsys1, slope1, alpha1, hgt1, cen1, wid1, $
        sigtsys1, sigslope1, sigalpha1, sighgt1, sigcen1, sigwid1, $
    problem3, cov

;---------CHECK TO SEE IF THE SIDELOBES ARE REAL BY CHKING THEIR WIDTHS---

;IF THERE ANY PROBLEMS WITH THE 3 GAUSSIAN FIT, THEN WE TRY TWO VERSIONS
;OF THE TWO GAUSSIAN FIT USING THE CENTRAL ONE PLUS FIRST THE LEFT, THEN
;THE RIGHT. 

;stop,'NR1, WID1, WIDTHMAX = ', wid1, widthmax, HGT1, SIGHGT1

if ( problem3 ne 0) then GOTO, DOINDX0

;indx = where( wid1[1:2] lt widthmax, count)
indx = where( (wid1[1:2] lt widthmax) and (wid1[1:2] gt widthmin), count)

;NOW CHECK THE ERROR IN THE AMPLITUDE...
if (count eq 2) then indx = where( sighgt1[ 1:2] lt 0.45*hgt1[ 1:2], count)

if (count eq 2) then begin
    tsys_final = tsys1
    slope_final = slope1
    alpha_final = alpha1
    hgt_final = hgt1
    cen_final = cen1
    wid_final = wid1
    sigtsys_final = sigtsys1
    sigslope_final = sigslope1
    sigalpha_final = sigalpha1
    sighgt_final = sighgt1
    sigcen_final = sigcen1
    sigwid_final = sigwid1
    goto, finished
endif

DOINDX0:
ngaussians = 2

;FIRST TRY THE LEFT..;
indx=0
hgt00 = [hgt0[ 0], [hgt0[ 1 + indx]]]
cen00 = [cen0[ 0], [cen0[ 1 + indx]]]
wid00 = [wid0[ 0], [wid0[ 1 + indx]]]

gfit_allcal, sigmalimit, offset, pwr, $
    tsys00, slope00, alpha00, hgt00, cen00, wid00, $
        tfit, sigma, $
    tsys1dx0, slope1dx0, alpha1dx0, hgt1dx0, cen1dx0, wid1dx0, $
        sigtsys1dx0, sigslope1dx0, sigalpha1dx0, $
    sighgt1dx0, sigcen1dx0, sigwid1dx0, problemdx0, covdx0

;THEN TRY THE RIGHT...
indx=1
hgt00 = [hgt0[ 0], [hgt0[ 1 + indx]]]
cen00 = [cen0[ 0], [cen0[ 1 + indx]]]
wid00 = [wid0[ 0], [wid0[ 1 + indx]]]

gfit_allcal, sigmalimit, offset, pwr, $
    tsys00, slope00, alpha00, hgt00, cen00, wid00, $
        tfit, sigma, $
    tsys1dx1, slope1dx1, alpha1dx1, hgt1dx1, cen1dx1, wid1dx1, $
        sigtsys1dx1, sigslope1dx1, sigalpha1dx1, $
    sighgt1dx1, sigcen1dx1, sigwid1dx1, problemdx1, covdx1

;stop,'NR2, WID1DX0, WIDTHMAX = ', wid1DX0, widthmax, HGT1DX0, SIGHGT1DX0

;CHECK ACCEPTABILITY OF INDX0 SOLUTION...
indx0_good= 1
if ( problemdx0 ne 0) then indx0_good= 0
;indx = where( wid1dx0[1] lt widthmax, countdx0)
indx = where( (wid1dx0[1] lt widthmax) and (wid1dx0[1] gt widthmin), countdx0)

;NOW CHECK THE ERROR IN THE AMPLITUDE...
if (countdx0 eq 1) then $
    indx = where( sighgt1dx0[ 1] lt 0.45*hgt1dx0[ 1], countdx0)

if (countdx0 ne 1) then indx0_good= 0

;stop,'NR3, WID1DX1, WIDTHMAX = ', wid1DX1, widthmax, HGT1DX1, SIGHGT1DX1

;CHECK ACCEPTABILITY OF INdx1 SOLUTION...
indx1_good= 1
if ( problemdx1 ne 0) then indx1_good= 0
indx = where( (wid1dx1[1] lt widthmax) and (wid1dx1[1] gt widthmin), countdx1)

;NOW CHECK THE ERROR IN THE AMPLITUDE...
if (countdx1 eq 1) then $
    indx = where( sighgt1dx1[ 1] lt 0.45*hgt1dx1[ 1], countdx1)

if (countdx1 ne 1) then indx1_good= 0

;COMPARE THE TWO SOLUTIONS...

if ( (indx0_good eq 0) and (indx1_good eq 0)) then goto, USENONE
if ( (indx0_good eq 0) and (indx1_good eq 1)) then goto, USEX1
if ( (indx0_good eq 1) and (indx1_good eq 0)) then goto, USEX0

USEx0:
tsys_final = tsys1dx0
slope_final = slope1dx0
alpha_final = alpha1dx0
hgt_final[0:ngaussians-1] = hgt1dx0
cen_final[0:ngaussians-1] = cen1dx0
wid_final[0:ngaussians-1] = wid1dx0
sigtsys_final = sigtsys1dx0
sigslope_final = sigslope1dx0
sigalpha_final = sigalpha1dx0
sighgt_final[0:ngaussians-1] = sighgt1dx0
sigcen_final[0:ngaussians-1] = sigcen1dx0
sigwid_final[0:ngaussians-1] = sigwid1dx0
goto, finished

USEX1:
tsys_final = tsys1dx1
slope_final = slope1dx1
alpha_final = alpha1dx1
hgt_final[0:ngaussians-1] = hgt1dx1
cen_final[0:ngaussians-1] = cen1dx1
wid_final[0:ngaussians-1] = wid1dx1
sigtsys_final = sigtsys1dx1
sigslope_final = sigslope1dx1
sigalpha_final = sigalpha1dx1
sighgt_final[0:ngaussians-1] = sighgt1dx1
sigcen_final[0:ngaussians-1] = sigcen1dx1
sigwid_final[0:ngaussians-1] = sigwid1dx1
goto, finished


;COME HERE IF NO SIDELOBES WERE ACCEPTABLE

USENONE:
hgt00 = hgt0[ 0]
cen00 = cen0[ 0]
wid00 = wid0[ 0]
ngaussians=1

;stop, '0'

gfit_allcal, sigmalimit, offset, pwr, $
    tsys00, slope00, alpha00, hgt00, cen00, wid00, $
        tfit, sigma, $
    tsys1, slope1, alpha1, hgt1, cen1, wid1, $
        sigtsys1, sigslope1, sigalpha1, sighgt1, sigcen1, sigwid1, $
    problem, cov

tsys_final = tsys1
slope_final = slope1
alpha_final = alpha1
hgt_final[0:ngaussians-1] = hgt1
cen_final[0:ngaussians-1] = cen1
wid_final[0:ngaussians-1] = wid1
sigtsys_final = sigtsys1
sigslope_final = sigslope1
sigalpha_final = sigalpha1
sighgt_final[0:ngaussians-1] = sighgt1
sigcen_final[0:ngaussians-1] = sigcen1
sigwid_final[0:ngaussians-1] = sigwid1

finished:
;MAKE SURE THAT THE LATTER TWO CENTERS ARE ORDERED CORRECTLY!

indxorder = [ 0,1,2]
IF (cen_final[ 1] gt 0.) then indxorder=[ 0,2,1]

stripfit[ 0, 0, nrstrip] = alpha_final
stripfit[ 1:3, 0, nrstrip] = hgt_final[ indxorder]

;stripfit[ 4:6, 0, nrstrip] = cen_final[ indxorder]
for nrrstk=0, 3 do stripfit[ 4:6, nrrstk, nrstrip] = cen_final[ indxorder]
;stripfit[ 7:9, 0, nrstrip] = wid_final[ indxorder]
for nrrstk=0, 3 do stripfit[ 7:9, nrrstk, nrstrip] = wid_final[ indxorder]

stripfit[ 10, 0, nrstrip] = tsys_final  
stripfit[ 11, 0, nrstrip] = slope_final
sigstripfit[ 0, 0, nrstrip] = sigalpha_final
sigstripfit[ 1:3, 0, nrstrip] = sighgt_final[ indxorder]

;sigstripfit[ 4:6, 0, nrstrip] = sigcen_final[ indxorder]
for nrrstk=0, 3 do sigstripfit[ 4:6, nrrstk, nrstrip] = sigcen_final[ indxorder]

;sigstripfit[ 7:9, 0, nrstrip] = sigwid_final[ indxorder]
for nrrstk=0, 3 do sigstripfit[ 7:9, nrrstk, nrstrip] = sigwid_final[ indxorder]

sigstripfit[ 10, 0, nrstrip] = sigtsys_final  
sigstripfit[ 11, 0, nrstrip] = sigslope_final

;stop, 'AT END OF xpyfit_allcal'

RETURN

end
