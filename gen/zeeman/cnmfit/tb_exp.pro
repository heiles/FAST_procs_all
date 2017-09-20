pro tb_exp, xdata, zrocnm, taucnm, cencnm, widcnm, tspincnm, ordercnm, $
	continuum, hgtwnm, cenwnm, widwnm, fwnm, $
	tb_cont, tb_wnm_tot, tb_cnm_tot, tb_tot, exp_tausum

;+
;CALCULATE THE EMISSION EXPECTED FROM A BUNCH OF CLOUDS IN ARBITRARY
;ORDER ALONG THE LINE OF SIGHT, AND ALSO A BUNCH OF ZERO-OPACITY EMISSION
;COMPONENTS, and a continuum from behind everything.

; -----------CALLING SEQUENCE--------------------------------
;tb_exp, xdata, zrocnm, taucnm, cencnm, widcnm, tspincnm, ordercnm, $
;	continuum, hgtwnm, cenwnm, widwnm, fwnm, $
;	tb_cont, tb_wnm_tot, tb_cnm_tot, tb_tot, exp_tausum
;
;CNM QUANTITIES:
;    ZROCNM is a single number, not a vector; it's the freq-independent
;           part of the CNM opacity, and should normally be zero.
;    TAUCNM is the vector of central optical depths of CNM component
;    CENCNM, WIDCNM, TSPINCNM are vectors for CNM comps. widths are FWHM
;    ORDERCNM is order along los. if there are 3 clouds, order might be
;    [0,2,1], with G-component 0 being CLOSESTest and G-comp 1 being FURTHEST.
;
;CONTINUUM is the continuum TB, assumed to come from behind all CNM.
;
;WNM QUANS:
;    HGTWNM, CENWNM, WIDWNM, FWNM; all self-explanatory vectors.
;    FWNM; all self-explanatory vectors.
;
;    FWNM IS THE FRACTION OF THE WNM EMISSION THAT LIES IN FRONT OF THE
;          COLD ABSORBING CLOUDS.  each wnm component lies either in front
;          of or behind ALL the CNM components. so if there are 3 WNM comps
;          numbered 0 to 2, FWNM=[0,0.5,1] means that the first lies 
;          behind all CNM, the second behind half of it, and the third 
;          lies in front of all CNM.
;
; -----------OUTPUTS ARE--------------------------------
;       TB_CONT is the continuum, absorbed by the CNM
;	TB_WNM_TOT, the emission from the ensemble of WNM clouds as seen by
;               the observer, with ones behind the CNM absorbed. This 
;               includes the continuum, also absorbed.
;       TB_CNM_TOT, the emission from the ensemble of CNM clouds as seen by
;               the observer, with ones behind others absorbed.
;       tb_tot, the sum of the WNM and CNM...the total emission as seen
;               by the observer
;       EXP_TAUSUM, the total opacity from all CNM components.
;
;
; -----------HISTORY-----------------------------------
;3 MAY 00: CORRECTION: THE ZERO OFFSET WAS INCLUDED IN CALCULATING
;	TB_WNM_TOT.
;
;10nov2009: the above correction assumes that there is continuum coming
;           from in front of all cnm so none of it gets absorbed. we
;           changed it so that it comes from behind all cnm, so it can
;           represent the 3K background and other Galactic continuum.
;           and it used to be called ZROWNM; now we call it CONTINUUM.
;10nov2009: continuum updated; this version differs from previous ones in
;           this regard.
;-


;ZEROTH STEP IS TO REARRANGE CLOUDS IN ORDER OF 'ORDER'.
zro1 = zrocnm
hgt1 = taucnm[ordercnm]
cen1 = cencnm[ordercnm]
wid1 = widcnm[ordercnm]
tspin1 = tspincnm[ordercnm]

;FIRST STEP IS TO CALCULATE THE OPACITY OF EACH COLD CLOUD...
nrcnm = n_elements( hgt1)
;taucnm = fltarr( n_elements(xdata), nrcnm)
taucnmxx = dblarr( n_elements(xdata), nrcnm)

for nrc = 0, nrcnm-1 do begin
gcurv, xdata, zro1, hgt1[nrc], cen1[nrc], wid1[nrc], tau1nrc
taucnmxx[*, nrc] = tau1nrc
endfor

if (n_elements(ordercnm) ne 1) then begin 
	tausum = total( taucnmxx, 2) 
endif else tausum = taucnmxx 
exp_tausum = exp(-tausum)

;********** NEXT CALCULATE THE WNM CONTRIBUTION ********************
;WE EXPRESS THE WNM CONTRIBUTION AS A SUM OF GAUSSIANS:
;	FWNM, ZROWNM, HGTWNM, CENWNM, WIDWNM

;THESE ARE SELF-EXPLANATORY EXCEPT FOR FWNM. 

;
;THE CONTRIBUTION OF THE WNM COMPONENTS TO THE ANTENNA TEMP IS...
;WNM CONTRIBUTION  = SUM, k FROM 0 TO K { G_WNMk [f_k + (1-f_k)exp(-tausum)]}
;WHERE TAUSUM IS THE SUM OF THE OPACITIES OF ALL THE CLOUDS.

tb_cont= continuum* exp_tausum

;stop
tb_wnm_tot = dblarr(n_elements(xdata))
nrwnm = n_elements( hgtwnm)
for nrw = 0, nrwnm-1 do begin
gcurv, xdata, 0., hgtwnm[nrw], cenwnm[nrw], widwnm[nrw], tb_wnm_nrw
tb_wnm_tot = tb_wnm_tot + $
	tb_wnm_nrw*( fwnm[nrw] + (1.-fwnm[nrw])*exp_tausum )
endfor

;*************** NEXT CALCULATE THE CNM CONTRIBUTION ****************

tb_cnm_tot = dblarr(n_elements(xdata))

;BRT TEMP OF EACH CNM CLUMP:
tbclump = fltarr(n_elements(xdata), nrcnm)
for nrc=0, nrcnm-1 do tbclump[*,nrc] = tspin1[nrc] * (1. - exp(-taucnmxx[*,nrc]))

for nrc = 0, nrcnm-1 do begin

tausum_nrc = total( reform(taucnmxx[*, 0:nrc], n_elements(xdata), nrc+1), 2)
exp_tau_nrc = exp( taucnmxx[*, nrc] - tausum_nrc)

tb_cnm_tot = tb_cnm_tot + $
	tspin1[nrc] * (1. - exp(-taucnmxx[*,nrc]) ) * exp_tau_nrc
;stop
endfor

tb_tot = tb_cont+ tb_cnm_tot + tb_wnm_tot

return

end
