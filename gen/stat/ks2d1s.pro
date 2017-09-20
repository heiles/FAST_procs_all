pro ks2d1s, hist2d, xaxis, yaxis, xfctr, yfctr, xdat, ydat, $
	xax, yax, hist_cum, dat_cum, maxidiff, indx_xmax, indx_ymax, $
	diff, p_ks

;+
;PURPOSE AND INPUTS:
;do one-sided 2d ks test. HIST2D is the theoretical histogram, expressed
;as a 2 d array of probability values evaluated at (x,y)=(XAXIS, YAXIS)
;XFCTR, YFCTR are the factors by which to collapse (because, if the nr
;of datapoints is small, having superhigh resolution in the (x,y)
;coordinates only wastes time). this uses REBIN to collapse, so xfctr and
;yfctr must be factors of the (x,y) sizes of hist2d.

;OUTPUTS:;XDAT, YDAT are the x- and y-values of the datapoints.

;XAX, YAX are the x,y values of the center of the 4 quaadrants from
;which the cumulative sums for the k-s statistic are evaluated.

;HIST_CUM and DAT_CUM are 4d arrays of the cumulative sums; hist_cum
;is the cum for the histogram, dat_cum is for the datapoints.

;MAXDIFF is the maximum fractional diffrence, called D in NR, from which
;the lambda is calculated.

;INDX_XMAX, INDX_YMAX are the indices at which the MAXDIFF is found.
;thus, xax[ indx_xmax] is the x value at which maxdiff is found
;
;DIFF[2,2,nx,ny] is the array of quadrant differences. the first two dims refer
;to the X,Y quadrants. thus the diffs in the quadrants where MAXDIFF is 
;found are DIFF[*,*,indx_xmax, indx_ymax]

;P_KS is the P_KS, which should be large if the distributions are identical.

;the procedure prints out its location in a slow do loop.
;it also prints the location in (x,y) and also in (x,y) pixels of the max diff
;it prints out the max diff, the quadrant in which it occurs, and P_KS.

;some tests with a 2d dist fcn and points generated therefrom are not
;encouraging for the reliability of this statistic!

;-

nrdata= float( n_elements( xdat))

sz= size( hist2d)

nrxtot= long( sz[1]/xfctr)
nrytot= long( sz[2]/yfctr)

;RESCALE THEORETICAL HISTOGRAM USING REBIN...
h2d= rebin( hist2d, nrxtot, nrytot)
h2d= h2d/total( h2d)
xax= rebin( xaxis, nrxtot)
yax= rebin( yaxis, nrytot)

;RESCALE THEORETICAL HISTOGRAM USING CONGRID...
;h2d= congrid( hist2d, nrxtot, nrytot, /interp, /minus_one)
;h2d= h2d/total( h2d)
;xax= congrid( xaxis, nrxtot, /interp, /minus_one)
;yax= congrid( yaxis, nrytot, /interp, /minus_one)

hist_cum= fltarr( 2,2, nrxtot, nrytot)
dat_cum= fltarr( 2,2, nrxtot, nrytot)

hist_tot= fltarr( 2,2)
dat_tot= fltarr( 2,2)

;FOR NRX= 0, NRXTOT-1 DO BEGIN
;FOR NRY= 0, NRYTOT-1 DO BEGIN
;hist_tot[ 0,0]= total( h2d[ 0:nrx, 0:nry])
;hist_tot[ 1,0]= total( h2d[ nrx:nrxtot-1, 0:nry])
;hist_tot[ 0,1]= total( h2d[ 0:nrx, nry:nrytot-1])
;hist_tot[ 1,1]= total( h2d[ nrx:nrxtot-1, nry:nrytot-1])

FOR NRX= 1, NRXTOT-1 DO BEGIN
FOR NRY= 1, NRYTOT-1 DO BEGIN
hist_tot[ 0,0]= total( h2d[ 0:nrx-1, 0:nry-1])
hist_tot[ 1,0]= total( h2d[ nrx:nrxtot-1, 0:nry-1])
hist_tot[ 0,1]= total( h2d[ 0:nrx-1, nry:nrytot-1])
hist_tot[ 1,1]= total( h2d[ nrx:nrxtot-1, nry:nrytot-1])

indx= where( (xdat lt xax[ nrx]) and (ydat lt yax[ nry]), count)
;indx= where( (xdat le xax[ nrx]) and (ydat le yax[ nry]), count)
if (count ne 0) then dat_tot[ 0,0]= count

indx= where( (xdat ge xax[ nrx]) and (ydat lt yax[ nry]), count)
;indx= where( (xdat ge xax[ nrx]) and (ydat le yax[ nry]), count)
if (count ne 0) then dat_tot[ 1,0]= count

indx= where( (xdat lt xax[ nrx]) and (ydat ge yax[ nry]), count)
;indx= where( (xdat le xax[ nrx]) and (ydat ge yax[ nry]), count)
if (count ne 0) then dat_tot[ 0,1]= count

indx= where( (xdat ge xax[ nrx]) and (ydat ge yax[ nry]), count)
;indx= where( (xdat ge xax[ nrx]) and (ydat ge yax[ nry]), count)
if (count ne 0) then dat_tot[ 1,1]= count

dat_cum[ *,*, nrx, nry]= dat_tot/ nrdata
hist_cum[ *,*, nrx, nry]= hist_tot

ENDFOR
if ( nrx mod 20) eq 0 then print, nrx

ENDFOR

diff= abs( dat_cum- hist_cum)
maxidiff= max( diff, indxmax)
indxtodims, diff, indxmax, dims, 1
dims= reform(dims)

print, 'max diff occurs at (x,y) = ', xax[ dims[2]], yax[ dims[3]]
print, 'max diff occurs at pixel(x,y) = ', dims[2],  dims[3]
print, 'max diff is ', maxidiff , ' in quadrant ', dims[ 0], dims[ 1]

indx_xmax= dims[ 2]
indx_ymax= dims[ 3]

sqrtn= sqrt( nrdata)
pearson= correlate( xdat, ydat)
corrfcn= sqrt( 1.- pearson^2)

lambda= sqrtn* maxidiff/( 1. + corrfcn*( 0.25 - 0.75/sqrtn) )

p_ks= q_ks( lambda)

print, 'P_KS = ', p_ks

;stop
return
end
