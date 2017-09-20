function ffteval, nterms, fhgt, theta

;+ 
;NAME:
;ffteval-
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


;FREQ IS THE ARRAY OF FREQUENCIES IN THE FFT OUTPUT.  IT'D SMALLEST
;VALUE IS 1 CYCLE PER TURN AROUND THE CIRCLE.  AND ITS LARGEST IS THE
;SAMPLING FREQUENCY, WHICH IS EQUAL TO THE NR OF POINTS AROUND THE
;CIRCLE.  E.G.  FOR 8 ELEMENTS IN FHGT, FREQ RUNS FROM 0 TO 7.  BUT IT'S
;BETTER TO THINK OF FREQS HIGHER THAN THE NYQUIST FREQ (4 IN THIS
;CASE--HALF OF 8) AS BEING NEGATIVE, SO THE FREQS RUN
;0,1,2,3,-4,-3,-2,-1.  THEN WHEN YOU CALCULATE WITH NTERMS LESS THAN 8
;YOU DISCARD THE HIGHER FREQUENCIES.  THIS IS THE RATIONALE BEHIND THE
;FOLLOWING SEQUENCE OF INDEX HANDLING. 

;WHEN YOU CALCULATE WITH NTERMS LT 8, YOU HAVE TO USE NTERMS ODD SO THAT
;THE HIGHEST NEG AND POS FREQ GET COUNTED TWICE; OTHERWISE ONLH THE
;HIGHEST NEG FREQ GETS COUNTED, WHICH MAKES THE THING YOU'RE TRANSFORMING
;NON-HERMITIAN, AND IT GIVES THE WRONG ANSWER. 

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

output= float( output)

;stop
return, output
end

