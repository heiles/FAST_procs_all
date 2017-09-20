function ffteval, nterms, fhgt, theta, nofloat=nofloat

;+ 
;
;PURPOSE: evaluate an inverse Fourier series using a smaller number freqs
;than the original FT calculated. For example, we began with 8 points
;around a circle, called pts, and got FHGT= fft( pts), there are 8 FHGT
;values at 8 different frequencies. the original data were real so the 8
;FHGT values are hermitian. now we can calculate the original points
;using all the 8 frequencies or just some of them, e.g. 6, 4, or 2 (the
;number must be even). NTERMS is the number of frequencies, equal to 8 to
;use all the original freqs, or equal tl 6, 4, or 2 to retain only the
;low freq terms.
;
;CALLING SEQUENCE:
;	RESULT= FFTEVAL( nterms, fhgt, theta)
;
;INPUTS: 
;	NTERMS is nr of frequencies actually employ. NTERMS must be even
;and less than or equal to the number of terems in fhgt.
;
;	FHGT, the complex array of Fourier coefficients. must have 2^N elements.
;
;	THETA, the angle RADIANS at which to evaluate the Fourier series.
;
;KEYWORDS:
;NOFLOAT: it normally eliminates the imaginary part of the output. set to
;         retain it. 
;
;OUTPUT: 
;	VALUE of the Fourier series at angle THETA.  As originally
;calculataed it's complex, but the imag part is zero so it is conferted
;to float. 
;
;HISTORY: Written by Carl Heiles, original version totally wrong unless
;nterms was equal to n_elements( fhgt). redone 31 may 2005. redone
;again 1 jun. redone again 2 jun. redone finally (we hope!) 6 mun.
;
;-

;SOME EXPLANATION:
;FREQ is the array of frequencies in the fft output.  It's smallest
;value is 1 cycle per turn around the circle.  and its largest is the
;sampling frequency, which is equal to the nr of points around the
;circle.  E.G.  for 8 elements in fhgt, freq runs from 0 to 7.  but it's
;better to think of freqs higher than the nyquist freq (4 in this
;case--half of 8) as being negative, so the freqs run
;0,1,2,3,-4,-3,-2,-1.  Then when you calculate with nterms less than 8
;you discard the higher frequencies.  this is the rationale behind the
;following sequence of index handling. 

;WHEN YOU CALCULATE WITH NTERMS LT 8, YOU HAVE TO USE NTERMS EVEN.

nterms1= nterms
if nterms lt 8 then nterms1 = nterms + ((nterms mod 2) eq 0)

capn= n_elements( fhgt)

freq= shift( (findgen( capn)- capn/2), capn/2)

thetause= theta/(2.*!pi)

drop= (capn- nterms)/2

fhgtcalc= shift( fhgt, capn/2)
fhgtcalc= fhgtcalc[ drop:drop+nterms1-1]
freqcalc= shift( freq, capn/2)
freqcalc= freqcalc[ drop:drop+nterms1-1]

dft, freqcalc, fhgtcalc, thetause, output, /inverse

if keyword_set( nofloat) eq 0 then output= real_part( output)

;stop
return, output
end

