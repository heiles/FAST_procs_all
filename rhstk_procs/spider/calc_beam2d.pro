pro calc_beam2d, nrc, beamin_arr, beamout_arr,  $
	nterms=nterms

;+
;PURPOSE: evaluate properties of the 2d beam and load b2dfit.
;INPUTS:
;
;	from structure BEAMIN
;
;	STRIPFIT, the 1-d stripfit ls fit coefficients from BEAM_DESCRIBE
;
;	BEAMOUT, a structure which contains...
;		B2DFIT, the 2-d ls fit coefficients from BEAM2D_DESCRIBE.
;		fhgt, fcen, fhpbw, generated in this proc.
;
;	SOURCEFLUX, used for getting kperjy
;
;OUTPUTS: ALL CALCULATED QUANTITIES OF SIGNIFICANCE ARE PUT INTO B2DFIT.
;
;	SIDELOBE_INTEGRAL, the integral of the sidelobe pattern in units
;of Kelvins arcmin^2.
;
;	MAINBEAM_INTEGRAL, the integral of the mainbeam pattern in units
;of Kelvins arcmin^2.
;
;	SIDELOBE, the sidelobe pattern on the original 60 X 60 observing
;grid.
;
;	MAINBEAM, the mainbeam pattern on the original 60 X 60 observing
;grid. 
;
;	KPERJY, the kperjy of the source. here Kelvins is Stokes I/2.
;
;	FHGT, the ratio of the heights of first sidelobe to main beam.
;
;	ETA_MAINBEAM, the main beam efficiency
;
;	ETA_SIDELOBE, the sidelobe efficiency
	
;KEYWORDS:

;	NTERMS, the number of terms to use in reconstructing the
;sidelobe structure from the Fourier fit to the sidelobe structure. Use
;of NTERMS=8 forces the reconstruction to duplicate the measured points
;because there were 8 measured data points (2 on each end of the strip,
;so they are located every 45 deg around the circle). Use of NTERMS<8 is
;equivalent to least squares fitting those 8 points with a Fourier series
;having the chosen value of NTERMS, which means that the fitted curve
;will not go through the points. Seeing as the 'measured points' are really
;the result of model fits to the sidelobes with Gaussians, and that these
;fitted parameters are not perfect, I don't believe using NTERMS=8 is
;justified. Rather, some smaller value is better. Currently I am using 6.
;This needs some investigation by looking at the sidelobe coefficients,
;the original strip data, and the reconstructed results using different
;values of NTERMS to see what's appropriate. 

;-

;EXTRACT FROM STRUCTURES...
stripfit= beamout_arr[ nrc].stripfit
b2dfit= beamout_arr[ nrc].b2dfit
sourceflux=  beamout_arr[ nrc].sourceflux


lambda= 30000./b2dfit[ 17, 0]

if (keyword_set( nterms) eq 0) then nterms=6

;BEAM MAP HAS NxN PIXELS; DEFINE N AS NR OF PTS PER STRIP...
ptsperstrip=  (size( beamin_arr[nrc].totoffsets))[ 1]

;DEFINE THE AZ, ZA ARRAYS FOR THE BEAM MAPS (UNITS ARE ARCMIN)...
make_azza_newcal, ptsperstrip, b2dfit, pixelsize, azarray, zaarray

;GENERATE THE SIDELOBE FOURIER COEFFICIENTS...
ft_sidelobes_newcal, stripfit, b2dfit, fhgt, fcen, fhpbw

;print, 'nterms ', nterms
;GENERATE THE SIDELOBE AND MAINBEAM MAPS...
sidelobe_eval, nterms, fhgt, fcen, fhpbw, azarray, zaarray, sidelobe
sidelobe= sidelobe/b2dfit[2,0]
sidelobe_integral= pixelsize^2 * total( sidelobe)

mainbeam_eval_newcal, azarray, zaarray, b2dfit, mainbeam
mainbeam= mainbeam/b2dfit[2,0]
mainbeam_integral=  pixelsize^2 * total( mainbeam)

totalbeam_integral= sidelobe_integral+ mainbeam_integral
mainbeam_integral= mainbeam_integral/lambda^2
sidelobe_integral= sidelobe_integral/lambda^2

;*************** NOTE THAT WE DEFINE SOME PORTIONS OF B2DFIT HERE!!! *******

if (n_elements( sourceflux) eq 0) then sourceflux= -1.0
b2dfit[ 12,*] = [ sourceflux, 0.]
b2dfit[ 13,*] = [ float( fhgt[ 0]), 0.]

;NOTE THE 0.5 IN KPERJY DEFINITION...WE WANT STOKES I/2 HERE, NOT STOKES I!!
kperjy= 0.5* b2dfit[2,0]/sourceflux
eta_mainbeam= 2.34 * kperjy * mainbeam_integral
eta_sidelobe= 2.34 * kperjy * sidelobe_integral

b2dfit[ 14,*] = [eta_mainbeam, 0.]
b2dfit[ 15,*] = [eta_sidelobe, 0.]
b2dfit[ 16,*] = kperjy
b2dfit[ 18, 1]= ptsperstrip


beamout_arr[ nrc].b2dfit= b2dfit
beamout_arr[ nrc].fhgt= fhgt
beamout_arr[ nrc].fcen= fcen
beamout_arr[ nrc].fhpbw= fhpbw

;stop, 'end of calc_beam2d'

return
end

