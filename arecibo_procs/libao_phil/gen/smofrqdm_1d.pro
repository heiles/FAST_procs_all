;+
;NAME:
;smofrqdm_1d - freq domain smoothing (1d)
;SYNTAX: yNew=smofrqdm_1d(y,fracSmo=fracSmo,ftype=ftype,$
;             filtertouse=filtertouse,retfilt=retfilt)
;ARGS:
;  y[n]: float  data to smooth
;KEYWORDS:
;   fracSmo:float   (0 to 1.) fraction of spatial frequency to keep.
;   filterType: int 1 - apply fracSmo boxcar 
;                   2 - apply fracSmo boxCar*hanning window
;                   3 - apply fracSmo boxCar*winCos4
;filterToUse[n]:float if Supplied, then ignore fracSmo,filtertype. Use this
;                     array as the multiplier in the freq domain.
;                    (note. Dc should be at index n/2 (count from 0)
;RETURNS:
;ynew[n]: float  the filtered data
;retfilt[n]: float the filter used in the freq domain. dc is at the center
;
;DESCRPIPTION:
;   Smooth a 1 d function by multiplying the fft of the function by
;a smoothing function. By default this is a boxcar window of length
;fracSmo*n. You can specify a tapering of the boxcar window using
;fitlertype 2 or 3. You can also specify your own smoothing function
;via filterToUse. 
;   In the frequency domain, the data is rotated so that dc is at
; n/2 (count from 0) before the multiply is done.
;
;EXAMPLES:
;   .. let y contain a 53 cycle and 200 cycle sine wave.
;   .. Then try and remove the 200 cycle cosine by using 
;      a boxcar smoothed with a cos^4 window. The nyquist rate is
;      511 so 200/511. = .3914. Try a filter of .38 to see how much of the
;      200 cycle sin wave is left (not much). 
;
;   y=mksin(1024,53) + mksin(1024,200)
;   
;   fract=.38  
;   ynew=smofrqdm_1d(y,fracSmo=fract,ftype=2)
;   plot,abs(fft(ynew))
;
;WARNING: The routine computes the filter size using fix(n*fract). 
;         The smallest measurable change is fract is 1./n
;
;SEE ALSO:
;   smofrqdm_2d
;-
function smofrqdm_1d,y,fracSmo=fracSmo,ftype=ftype,filterToUse=filterToUse,$
		retfilt=retfilt
;
;   
	dtype=size(y,/type)
	iscomplex=(dtype eq 6) or (dtype eq 9)
    len=n_elements(y)
    if not keyword_set(fracSmo) then fracSmo=.5
    if not keyword_set(ftype)   then ftype=1
    extFilter=0
    if n_elements(filterToUse) ne 0 then begin
        if n_elements(filterToUse) ne len then begin
            message,'smofft1d.. The filterToUse must match the dataLen'
        endif
        extFilter=1
    endif
    if not extFilter then begin
        filterToUse=fltarr(len)
        i1=fix((.5- fracSmo/2.)*len)
        i2=fix((.5 + fracSmo/2.)*len)-1
        case ftype of
        2: filterToUse[i1:i2]=hanning(i2-i1+1)
        3: filterToUse[i1:i2]=wincos4(i2-i1+1)
     else: filterToUse[i1:i2]=1.
     endcase
    endif
;
;      1. fft(Y) -> to freqDomain
;      2. shift to center (len/2)
;      3. multilply by filter
;      4. shift back to 0
;      5. fft back to time domain
;      6.  take the real part
;
	if arg_present(retfilt) then retfilt=filterToUse
	if (iscomplex) then begin
           tmp=shift(fft(y),len/2)
		   frqDm=complex(float(tmp)*filterToUse,imaginary(tmp)*filtertouse)
    	   return,fft(shift(frqDm,-len/2),1)
	endif else begin
    	return,float(fft(shift(shift(fft(y),len/2)*filterToUse,-len/2),1))
	endelse
end
