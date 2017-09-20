pro ft_sidelobes_newcal, stripfit, b2dfit, fhgt, fcen, fhpbw, nstk=nstk

;+
;PURPOSE: generate the fourier coefficients that describe the hgt, cen,
;and wid of the Gaussians that describe the sidelobes.

;CALLING SEQUENCE:
;FT_SIDELOBES, stripfit, b2dfit, fhgt, fcen, fhpbw, nstk=nstk

;INPUTS:

;	STRIPFIT, the results of the 1-d strip fits described and
;derived in BEAM_DESCRIBE.

;	B2DFIT, the results of the 2-d pattern fits described and
;derived in BEAM2D_DESCRIBE. 

;OUTPUTS:

;	FHGT, FCEN, FHPBW: the Fourier coefficients of the sidelobe hgt,
;cen, and width. These are complex and have dimension equal to twice
;the number of strips--e.g. 4 strips means they have dimension 8 (one 
;for each end). .

;KEYWORD:
;	NSTK: IF SPECIFIED, RETURNS THE BEAM FOR THE PARTICULAR STOKES
;	PARAMETER. 0,1,2,OR 3. IF NOT specified, it returns Stokes I.

;******************* IMPORTANT NOTE NR 1 **************************
;	the angle units are ***ARCMIN***, so when the FT coefficients
;are used to obtain the sidelobe the angular units must be ARCMIN.

;******************* IMPORTANT NOTE NR 2 **************************
;	the hgt, cen, and hpbw quantities must be ordered properly so
;that as you go around the circle they increase sequentially. The
;ordering below is correct for the 4-strip Arecibo pattern. 
;
;	This program will also do a 2-strip pattern. However, you must
;make sure that the ordering of the points is correct!
;******************************************************************

;COMMENT: all widths are HPBW
;-

if (n_elements( nstk) eq 0) then nstk=0
hpbw_nominal = b2dfit[ 10, 1]

;FIRST DETERMINE THE NUMBER OF STRIPS...
nrstrips= (size( stripfit))[ 2]

hgt= fltarr( 2*nrstrips)
cen= fltarr( 2*nrstrips)
hpbw= fltarr( 2*nrstrips)

IF (NRSTRIPS EQ 4) THEN BEGIN
hgt[0 ]= stripfit[ 3, nstk, 0]
hgt[1 ]= stripfit[ 3, nstk, 3]
hgt[2 ]= stripfit[ 3, nstk, 1]
hgt[3 ]= stripfit[ 2, nstk, 2]
hgt[4 ]= stripfit[ 2, nstk, 0]
hgt[5 ]= stripfit[ 2, nstk, 3]
hgt[6 ]= stripfit[ 2, nstk, 1]
hgt[7 ]= stripfit[ 3, nstk, 2]

cen[0 ]= stripfit[ 3+3,0,0]
cen[1 ]= stripfit[ 3+3,0,3]
cen[2 ]= stripfit[ 3+3,0,1]
cen[3 ]= -stripfit[ 3+2,0,2]
cen[4 ]= -stripfit[ 3+2,0,0]
cen[5 ]= -stripfit[ 3+2,0,3]
cen[6 ]= -stripfit[ 3+2,0,1]
cen[7 ]= stripfit[ 3+3,0,2]

hpbw[0 ]= stripfit[ 6+3,0,0]
hpbw[1 ]= stripfit[ 6+3,0,3]
hpbw[2 ]= stripfit[ 6+3,0,1]
hpbw[3 ]= stripfit[ 6+2,0,2]
hpbw[4 ]= stripfit[ 6+2,0,0]
hpbw[5 ]= stripfit[ 6+2,0,3]
hpbw[6 ]= stripfit[ 6+2,0,1]
hpbw[7 ]= stripfit[ 6+3,0,2]
ENDIF

IF (NRSTRIPS EQ 2) THEN BEGIN
hgt[0 ]= stripfit[ 3, nstk, 0]
hgt[1 ]= stripfit[ 3, nstk, 1]
hgt[2 ]= stripfit[ 2, nstk, 0]
hgt[3 ]= stripfit[ 2, nstk, 1]

cen[0 ]= stripfit[ 3+3,0,0]
cen[1 ]= stripfit[ 3+3,0,1]
cen[2 ]= -stripfit[ 3+2,0,0]
cen[3 ]= -stripfit[ 3+2,0,1]

hpbw[0 ]= stripfit[ 6+3,0,0]
hpbw[1 ]= stripfit[ 6+3,0,1]
hpbw[2 ]= stripfit[ 6+2,0,0]
hpbw[3 ]= stripfit[ 6+2,0,1]
ENDIF

;PUT CENTER AND HPBW IN UNITS OF ARCMIN...
cen= cen* hpbw_nominal
hpbw= hpbw* hpbw_nominal

;CHECK FOR ZERO HEIGHTS OF THE SIDELOBE...
indx= where(hgt eq 0., count_indx)

;IF THERE ARE ZERO HEIGHTS, REPLACE THE CORRESPONDING CENTERS AND WIDTHS
;	BY THE AVERAGE OF ALL NONZERO ONES...
if ( count_indx ne 0) then begin
jndx= where( hgt ne 0., count_jndx)
IF ( count_jndx ne 0) THEN BEGIN
cen[ indx] = mean( cen[jndx])
hpbw[ indx] = mean( hpbw[jndx])
ENDIF ELSE BEGIN
hpbw[ indx] = 1.
ENDELSE
endif

fhgt = fft( hgt)
fcen = fft( cen)
fhpbw = fft( hpbw)

end

