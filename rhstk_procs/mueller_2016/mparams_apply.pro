pro mparams_apply, parang, stksrc, mmcoeffs, stkobs, $
    theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
    tdata=tdata, m_tot=m_tot
;+
;PURPOSE: given the known parallactic angles (PARANG), known source
;stokes parameters (STKSRC), and known, guessed, or iterated mueller
;matrix parameters (MMCOEFFS), calculate the data array used in the
;mparamsfit.pro fit (TDATA).
;
;calling sequence:
;mparams_apply, parang, stksrc, mmcoeffs, stkobs, $
;    theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
;    tdata=tdata, m_tot=m_tot
;
;INPUTS:
;PARANG[nrs]: the NRS parallactic angles where the sources were obs (degrees)
;STKSRC[4,nrs] or STKSRC[4] : the array of TRUE stokes params of the NRS
;   sources, which are known (because these sources are pplarization
;   standard calibrators). If NRS>1 and only a single STKSRC is input
;   (i.e., STKSRC[4]), then that STKSRC applies to all PARANG.
;MMCOEFFS: {.deltag, .psi, .alpha, .epsilon, .phi, .chi, .m_tot, $
;           .theta_feed, .theta_astron, .vfctr}
;  the structure with the mm params.
;
;OUTPUTS:
;STKOBS[4,nrs], the predicted observed stokes params
;
;KEYWORDS:
;THETA_ASTRON, the angle_astron required to convert to the IAU
;   convention for polarization position angle. Default is 0
;
;VFCTR_ASTRON: the sign of V required to convert to IAU definition
;   Default is +1
;M_TOT: the m_tot calculated from the MMCOEFFS structure.
;-

if n_elements( theta_astron) eq 0 then theta_astron=0.
if n_elements( vfctr_astron) eq 0 then vfctr_astron=1.

nrd = n_elements( parang)
nrstksrc= n_elements( stksrc)/4

m_astron, theta_astron, vfctr_astron, m_astron
m_tot, mmcoeffs.deltag, mmcoeffs.epsilon, mmcoeffs.alpha, mmcoeffs.phi, $
       mmcoeffs.chi, mmcoeffs.psi, m_tot
m_ast_tot= m_astron ## m_tot

stkobs=fltarr( 4, nrd)

for nd=0, nrd-1 do begin
   m_sky, parang[nd], m_sky
   if nrstksrc eq nrd then $
      stkobs[ *, nd]= m_ast_tot ## m_sky ## stksrc[*, nd] else $
      stkobs[ *, nd]= m_ast_tot ## m_sky ## stksrc
endfor

;DEFINE THE tdata data array used for fitting...
tdata= fltarr( 3,nrd)
for nd= 0, nrd-1 do tdata[ *,nd]= stkobs[1:3,nd]/stkobs[0,nd]
tdata= reform( tdata, 3*nrd)

return
end
