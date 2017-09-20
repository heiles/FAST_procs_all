pro zgfit, xdata, tdata, hgt0, cen0, wid0, $
          bfld, berr, vpredicted, cov, WEIGHT=weight, $
           resid=resid, sigsq=sigsq
;+
;NAME:
;   ZGFIT
;
;PURPOSE:
;    Fit B fields to Stokes V data, assuming Gaussians are the
;         total intensity spectrum.
;CALLING SEQUENCE:
;    ZGFIT, xdata, tdata, hgt0, cen0, wid0, $
;        bfld, berr, vpredicted, cov [, WEIGHT=weight], $
;        [resid=resid], [sigsq=sigsq]
;INPUTS:
;     xdata: the abscissa values
;     tdata: the data points of the Stokes V spectrum. IT MUST BE
;       GAIN-CORRECTED!!!
;     hgt0: the array of N Gaussian heights of the Stokes I/2 spectrum.
;     cen0: the array of N Gaussian centers of the Stokes I/2 spectrum.
;     wid0: the array of N Gaussian widths of the Stokes I/2 spectrum.
;
;OUTPUTS:
;     bfld: the array of N fields of the Gaussians. 
;     berr: the array of N fitted centers.
;     vpredicted: the array of the best fit to Stokes V
;     cov: the normalized covariance matrix.
;
;KEYWORDS:
;     WEIGHT = array of weights for weighted least-squares fit
;
;UNITS OF FITTED FIELD:
;       Bfld is the frequency separation betweeen the RHC and LHC 
;components in units of channels. Thus, if the channel width is 2800 Hz
;and bfld is returned as 1.00, and if the splitting is 2.8 Hz per microG
;as it is for HI, then the freq separation between the two components is
;2800 Hz and the field is 1000 Microg.
;
;RESTRICTIONS:
;    None...that we know of.
;EXAMPLE:
;    You have fit N Gaussians to a total intensity profile; their
;         parameters are in the N-element arrays hgt, cen, wid. 
;         You also have the Stokes V spectrum, which is the array 
;         tdata, and you want to derive the associated field strengths. 
;         ZGFIT, tdata, hgt0, cen0, wid0, bfld, berr, cov
;HISTORY:
;    29jun05: Tim fixed definition of derivative spectrum.
;    07jul05: Tim adds weighting option.
;    09aug05: Tim makes Vpredicted same # of elements as Stokes I and V
;
;18aug2006: tim and carl determined that the following commentary,
;written by tim about a year ago, is WRONG and changed things back to
;they way they originally were.
   ; THIS IS WHAT CARL HAD HERE...
   ;diff = 0.5*( shift( ttotal, -1) - shift( ttotal, 1))

   ; B IS PROPORTIONAL TO dI(nu)/dnu
   ; FURTHER DOWN THE PIPELINE, WE CALCULATE B ASSUMING
   ; THE SPLITTING IS DERIVED HERE AS dI(channel)
   ; THE ROUTINE THAT CALCULATES B FROM THE SPLITTING
   ; TAKES CARE OF WHETHER YOU WERE OBSERVING
   ; I(nu) OR I(vlsr) AND ADDS A NEGATIVE IF THE LATTER
   ; WE WANT THE DERIVATIVE WITH RESPECT TO CHANNEL
   ; SO WE JUST TAKE THE DIFFERENCE BETWEEN THE UP-SHIFTED
   ; AND DOWN-SHIFTED SPECTRA...
;   diff = 0.5 * ( shift( ttotal, +1) - shift( ttotal, -1))

;+

ngaussians = n_elements( hgt0)
datasize = n_elements( tdata)

if (N_elements(weight) eq 0) $
  then wgt = dblarr(datasize-2) + 1d0 $
  else wgt = weight[1:datasize-2]

;SET UP EQUATIONS OF CONDITION MATRIX...
s = fltarr(ngaussians, datasize-2)
s0 = s
td = tdata[1:datasize-2]
twgt = td * wgt
for ng = 0, ngaussians-1 do begin
   gcurv, xdata, 0.0, hgt0[ng], cen0[ng], wid0[ng], ttotal
   diff = 0.5*( shift( ttotal, -1) - shift( ttotal, 1))

   s[ng, *] = diff[1:datasize-2] * wgt
   s0[ng, *] = diff[1:datasize-2]
endfor

;stop

;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
ss = transpose(s) ## s
st = transpose(s) ## transpose(twgt)
ssi = invert(ss)
a = ssi ## st

;stop

;GET THE ERRORS...
bt = reform(s ## a)
resid = twgt - bt
sigsq = total(resid^2)/(datasize-2-ngaussians)
bfld = reform(a)
berr = sqrt( sigsq*ssi[(ngaussians+1)*indgen(ngaussians)])

vpredicted = [0,reform(s0 ## a),0]

;stop
;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[(ngaussians+1)*indgen(ngaussians)]
doug = doug#doug
cov = ssi/sqrt(doug)

return
end
