function ffteval, nterms, fhgt, theta

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
;	THETA, the angle at which to evaluate the Fourier series.
;
;OUTPUT: 
;	VALUE of the Fourier series at angle THETA.  As originally
;calculataed it's complex, but the imag part is zero so it is conferted
;to float. 
;
;HISTORY: Written by Carl Heiles, original version totally wrong unless
;nterms was equal to n_elements( fhgt). redone 31 may 2005.
;
;-

capn= n_elements( fhgt)

;FREQ IS THE ARRAY OF FREQUENCIES IN THE FFT OUTPUT.  IT'D SMALLEST
;VALUE IS 1 CYCLE PER TURN AROUND THE CIRCLE.  AND ITS LARGEST IS THE
;SAMPLING FREQUENCY, WHICH IS EQUAL TO THE NR OF POINTS AROUND THE
;CIRCLE.  E.G.  FOR 8 ELEMENTS IN FHGT, FREQ RUNS FROM 0 TO 7.  BUT IT'S
;BETTER TO THINK OF FREQS HIGHER THAN THE NYQUIST FREQ (4 IN THIS
;CASE--HALF OF 8) AS BEING NEGATIVE, SO THE FREQS RUN
;0,1,2,3,-4,-3,-2,-1.  THEN WHEN YOU CALCULATE WITH NTERMS LESS THAN 8
;YOU DISCARD THE HIGHER FREQUENCIES.  THIS IS THE RATIONALE BEHIND THE
;FOLLOWING SEQUENCE OF INDEX HANDLING. 

freq= findgen( capn)

drop= (capn- nterms)/2

fhgtcalc= shift( fhgt, capn/2)
fhgtcalc= fhgtcalc[ drop:capn-1-drop]
freqcalc= shift( freq, capn/2)
freqcalc= freqcalc[ drop:capn-1-drop]

dft, freqcalc, fhgtcalc, theta, output, /inverse

output= output* (1. + (nterms eq 2))

output= float( output)
return, output
end

