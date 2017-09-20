pro zgfit_selfabs, xdata, vdata, $
        continuum, hgtwnm, cenwnm, widwnm, fwnm, $
	zrocnm, hgtcnm, cencnm, widcnm, tspincnm, ordercnm, $
        vsplit, delvsplit, vfitted, cov
;+
;NAME: ZGFIT_SELFABS -- Fit B fields to Stokes V data, assuming
;one or more emitting Gaussians and one or more self-absorbing gaussians
;
;CALLING SEQUENCE:
;zgfit_selfabs, xdata, vdata, $
;        continuum, hgtwnm, cenwnm, widwnm, fwnm, $
;	zrocnm, hgtcnm, cencnm, widcnm, tspincnm, ordercnm, $
;        vsplit, delvsplit, vfitted, cov
;
;INPUTS:
;     XDATA: the velocity or freq axis
;     VDATA: the data points of the Stokes V spectrum.
;     CONTINUUM: the background Stokes I/2 continuum (e.g. 2.8 K for
;          CBR). See IMPORTANT NOTE below.
;     HGTWNM: the array of Gaussian heights of the Stokes I/2 spectrum. 
;          See IMPORTANT NOTE below.
;     CENWNM: the array of Gaussian centers of the Stokes I/2 spectrum.
;     WIDWNM: the array of Gaussian FWHM of the Stokes I/2 spectrum.
;     FWNMWNM: the array of locations of cnm/wnm along los. 0 means all
;       CNM components lie in front of this WNM component, thus
;       producing self-absorption; 1 means they lie behind. Any
;       fractional value between 0 and 1 is fine.
;     ZROCNM: velocity-independent offset of optical depth. (Normally
;       this is zero)
;     HGTCNM: the array of absorbing gaussian heights
;     CENCNM, the array of absorbing gaussian centr
;     WIDCNM, the array of absorbing gaussian FWHM
;     TSPINCNM, the array of absorbing gaussian spin temp
;
;OUTPUTS:
;     VSPLIT: the array of N splittings of the Gaussians. Order is the WNM
;     gaussians followed by the CNM gaussians. UNITS are those of XDATA.
;     DELVSPLIT: the array of N fitted splitting uncertainties. Order as above. 
;     VFITTED: the fitted v spectrum.
;     COV: the normalized covariance matrix.
;
; ********* IMPORTANT NOTE ***********
;The CONTINUUM and WNM intensities are for Stokes I/2, i.e. the
;conventional brightness temp of a 21-cm line. Thus, these are both
;Stokes I/2. Similarly, TSPINCNM is the actual spin temp in K.

;NOTE ON ALGEBRAIC SIGNS: 
;        The IAU definiton of Stokes V is: V = RCP - LCP, where RCP and
;LCP are the IEEE definition (RCP is CLOCKWISE rotation of the e vector
;as seen from the TRANSMITTER). This procedure returns VSPLIT in units
;of the XDATA. For example, if XDATA is frequency, then a positive
;VSPLIT for a given feqture means that its RCP lies at a higher
;frequency than the LCP by a total amount equal to vsplit. If XDATA is
;velocity, then a positive VSPLIT means that its RCP lies at a higher
;velocity thatn the LCP, i.e. at a smalller frequency. 
;
;       For the HI line, a total frequency shift between the two
;circularly-polarized components is 1.4g B_los Hz/microG. Here g is the
;Lande g factor, equal to 2 for 1420 MHz line. We have the following
;splittings (total splitting between LCP and RCP): 
;
;       HI      1420    2.8 Hz/microG.
;       OH      1612    1.31
;       OH      1665    3.27
;       OH      1667    1.96
;       OH      1720    1.31
;
;NOTE:
;	ABSORBTION ASSUMED TO BE OF THE FORM
;	optical depth = hgtcnm * exp[ (xdata - cencnm)/(0.6005612*widcnm))^2]
;
;   Numerical Derivatives wrt velocity are calculated using offset of
;   +/- delcen. Default for delcen is 0.037 of the component's
;   width (optimum was established  by numerical expt).
;-

nrwnm= n_elements( hgtwnm)
nrcnm= n_elements( hgtcnm)
nga= nrwnm+ nrcnm
datasize = n_elements( vdata)
delcenwnm= 0.037* widwnm
delcencnm= 0.037* widcnm

;SET UP EQUATIONS OF CONDITION MATRIX...
s = fltarr( nrwnm+ nrcnm, datasize)
td = vdata
xd= xdata

;if keyword_set( plotyes) then plot, xc, td

;GET THE EMISSION DERIVATIVES...
;do numerical derivatives, offsetting cen by +/- delcen km/s
for nrw = 0, nrwnm-1 do begin
cenplus= cenwnm
cenminus= cenwnm
cenplus[ nrw]=  cenwnm[ nrw] + delcenwnm[ nrw]
cenminus[ nrw]= cenwnm[ nrw] - delcenwnm[ nrw]
tb_exp, xdata, zrocnm, hgtcnm, cencnm, widcnm, tspincnm, ordercnm, $
        continuum, hgtwnm, cenplus, widwnm, fwnm, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_tot_plus, exp_cnmsum 
tb_exp, xdata, zrocnm, hgtcnm, cencnm, widcnm, tspincnm, ordercnm, $
        continuum, hgtwnm, cenminus, widwnm, fwnm, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_tot_minus, exp_cnmsum 
;s[nrw, *] = (tb_tot_plus- tb_tot_minus)/( 2.*delcenwnm[ nrw])
s[nrw, *] = (-tb_tot_plus+ tb_tot_minus)/( 2.*delcenwnm[ nrw])
endfor

;GET THE ABSORPTION CONTRIBUTION...
;do numerical derivatives, offsetting cen by +/- delcen km/s
for nrc = 0, nrcnm-1 do begin
cenplus= cencnm
cenminus= cencnm
cenplus[ nrc]= cencnm[ nrc] + delcencnm[ nrc]
cenminus[ nrc]= cencnm[ nrc] - delcencnm[ nrc]
tb_exp, xdata, zrocnm, hgtcnm, cenplus, widcnm, tspincnm, ordercnm, $
        continuum, hgtwnm, cenwnm, widwnm, fwnm, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_tot_plus, exp_cnmsum 
tb_exp, xdata, zrocnm, hgtcnm, cenminus, widcnm, tspincnm, ordercnm, $
        continuum, hgtwnm, cenwnm, widwnm, fwnm, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_tot_minus, exp_cnmsum 
;s[nrwnm+ nrc, *] = (tb_tot_plus- tb_tot_minus)/( 2.*delcencnm[ nrc])
s[nrwnm+ nrc, *] = (-tb_tot_plus+ tb_tot_minus)/( 2.*delcencnm[ nrc])
endfor

;stop
;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
ss = transpose(s) ## s
st = transpose(s) ## td
ssi = invert(ss)
a = ssi ## st

;GET THE ERRORS...
resid = td - (s ## a)
sigsq = total(resid^2)/(datasize- nga)
vsplit = reform( a)
delvsplit = sqrt( sigsq*ssi[(nga+1)*indgen(nga)])
vfitted = reform( s ## a)

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[(nga+1)*indgen(nga)]
doug = doug#doug
cov = ssi/sqrt(doug)

return
end
