pro beam1dfit, nrc, beamin_arr, beamout_arr,stkoffsets_chnl_arr,byChnl=byChnl

;+
;NAME:
;beam1dfit - 1d fits to stokes i,q,u,v for each strip
;SYNTAX: beam1dfit,nrc, beamin_arr, beamout_arr,stkoffsets_chnl_arr, $
;                  byChnl=byChnl
;
;DESCRIPTION
;Fit the total intensity (the one-dimensional fit) separately for each
;strip using ifit_allcal.pro, which fits three gaussians--one for each
;sidelobe and one for the main beam. The main beam gaussian has a
;skewness parameter.
;
;Then, using the results from the x+y fit,  fit the 1-d beam for all
;polarized stokes params for all strips using sqfit_allcal.pro, which
;fixes all parameters for the sidelobe gaussians except for the height
;and for the main beam gaussian includes squint and squash terms.
;
;Note that no input angles other than the total offset from center 
;are required to do these fits, so the only angular variable is
;totoffst[ ptsperstip,4]
;
;INPUTS: 
;       NRC: the pattern number.
;    BEAMIN: the input data structure, from which we extract...
;HPBW_GUESS: the value of the HPBW to use as the initial guess
;            in the nonlinear 1d Gaussian fits to each strip cut across 
;            the beam.
;TOTOFFSET[ ptsperstrip, nrstrips]: the total angular offset from
;            center along each strip. UNITS ARE ARCMIN, in contrast to the
;            original version of this program in which units were the assumed
;            hpbw. nrstrips is 4 in original usage.
;
;STOKESOFFSET[4,ptsperstrip,nrstrips]: the continuum Stokes parameters [4] 
;            for each point in each of the nrstrips strips.
;
;KEYWORDS:
;
;    CHNLS: if set, does each chnl, reading inputs from
;           beamin_arr.stkoffsets and writing to beamout_arr.stripfit_chnls. 
;           Otherise it does the continuum, which are the average over many 
;           chls. 
;OUTPUTS:
;
;BEAMOUT_ARR: INTO WHICH WE INSERT EITHER STRIPFIT (FOR THE CONTINUUM)
;             OR STRIPFIT_CHNLS( VALUES FOR EACH AND EVERY SINGLE CHANNEL)...
;
;----------->>> IMPORTANT NOTE ON UNITS <<<--------------------
;|                                                            |
;|  Units of the INPUT angle are arcmin.                  |
;|  They are converted to units of HPBW_GUESS internally  |
;|  Units of STRIPFIT angles are HPBW_GUESS.              |
;|                                                            |
;----------->>> IMPORTANT NOTE ON UNITS <<<--------------------
;
;STRIPFIT[ 12, 4, nrstrips]: the ls fit parameters, defined as follows:
;       [ 12, 4, nrstrips] are [parameter, stokes, strip]
;       stripfit[ 0, *,*] = skew of main beam
;       stripfit[ 1, *,*] = hgt of main beam
;       stripfit[ 2, *,*] = hgt of left sidelobe
;       stripfit[ 3, *,*] = hgt of right sidelobe
;       stripfit[ 4, *,*] = [cen, squint,squint,squint] of main beam
;       stripfit[ 5, *,*] = cen of left sidelobe
;       stripfit[ 6, *,*] = cen of right sidelobe
;       stripfit[ 7, *,*] = [wid, squash, squash, squash] of main beam
;       stripfit[ 8, *,*] = HPBW of left sidelobe
;       stripfit[ 9, *,*] = HPBW  of right sidelobe
;       stripfit[ 10, *,*] = zero offset
;       stripfit[ 11, *,*] = slope
;     where 'left sidelobe' refers to the first one in time along the scan
;     and 'right sidelobe' refers to the latter one.
;
;SIGSTRIPFIT[ 12, 4, nrstrips]: the errors in the above fit parameters
;
;   TEMPFITS[ 4, 60, nrstrips]: the fits to the data from all those ls fits
;                [ stokes, datanr, stripnr] (i.e., the fits to the datapoints,
;                not the datapoints; useful for plotting)
;NOTE: TEMPFITS IS NOT SAVED IN CHNL MODE.
;-

;NAMING CONVENTION:
;   XPY IS X PLUS Y, NOMINALLY THE STOKES I
;   XMY IS X MINUS Y, THE DIFFERENCE BETWEEN THE TWO CHANNELS
;   XY IS REAL(XY)
;   YX IS IMAG(XY)

;--------------------NOW LS FIT EACH STRIP, THEN DISPLAY EACH STRIP----

;DEFINE QUANTITIES THAT CHARACTERIZE THE STRIP...
hpbw_guess= beamin_arr[ nrc].hpbw_guess
totoffset= beamin_arr[ nrc].totoffsets

nrstrips= (size( totoffset))[ 2]
stripfit = fltarr( 12, 4, nrstrips)
sigstripfit = fltarr( 12, 4, nrstrips)
tempfits = fltarr( 4, 60, nrstrips)

nchnls=1
if (keyword_set( byChnl)) then nchnls= (size( stkoffsets_chnl_arr))[ 1]

FOR NCH= 0, NCHNLS-1 DO BEGIN

IF (KEYWORD_SET( byChnl)) THEN BEGIN
    stokesoffset= reform( stkoffsets_chnl_arr[ nch, *, *, *,nrc])
ENDIF ELSE stokesoffset= beamin_arr[ nrc].stkoffsets_cont

;LS FIT EACH STRIP...
FOR NRSTRIP= 0, NRSTRIPS-1 DO BEGIN 

;GET THE ANGLE OFFSETS--*****IN UNITS OF THE HPBW_GUESS*****...
offset = totoffset[ *, nrstrip]/ hpbw_guess

;DO THE FITS...
xpyfit_newcal, nrstrip, offset, stokesoffset[ 0, *, nrstrip], $
        tfit, sigma, stripfit, sigstripfit, problem, cov
tempfits[ 0, *, nrstrip]= tfit

FOR NSTK = 1, 3 DO BEGIN
sqfit_newcal, nrstrip, nstk, offset, $
    stokesoffset[ nstk, *, nrstrip], $
    tfit, sigma, stripfit, sigstripfit, problem, cov 
tempfits[ nstk, *, nrstrip]= tfit
ENDFOR   ;;;;nstk

IF (KEYWORD_SET( byChnl)) THEN BEGIN
; <pjp004> check for not finite..
    p=finite(stripfit)
    ind=where(p eq 0,count)
    if count ne 0 then begin
        lab=string(format=$
'("bad chnlfit src",a," frq:",f6.1," pat:",i2," chnl:",i3," fit zeroed.")',$
                beamout_arr[nrc].sourcename,beamout_arr[nrc].b2dfit[17,0],$
                nrc,nch)
        print,string(7b),lab
        beamout_arr[ nrc].stripfit_chnl[ nch, *, *, *]= 0.
    endif else begin 
        beamout_arr[ nrc].stripfit_chnl[ nch, *, *, *]= stripfit
    endelse
ENDIF ELSE BEGIN
    beamout_arr[ nrc].stripfit= stripfit
    beamout_arr[ nrc].sigstripfit= sigstripfit
    beamin_arr[ nrc].tempfits= tempfits
ENDELSE

ENDFOR    ;;;;;; nrstrip

ENDFOR    ;;;;; NCH

end
