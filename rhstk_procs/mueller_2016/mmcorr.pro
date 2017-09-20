pro mmcorr, m_tot, m_astron, parallactic_deg, stokesuncal, stokescal, $
	m_skycorr= m_skycorr, m_astro=m_astro

;+

;PURPOSE: mueller-correct the stokesuncal array. 

;CALLING SEQUENCE:
;
;       MMCORR, m_tot, m_astron, parallactic_deg, stokesuncal, stokescal, $
;       	m_skycorr= m_skycorr, m_astro=m_astro
;
;INPUTS:
;       M_TOT[ 4,4], the mueller matrix for the system as defined in the AOTM
;       M_ASTRON[ 4,4], the 'astronomical' mueller matrix.
;	PARALLACTIC_DEG[ npos], the vector of parallactic angle in degrees
;	STOKESUNCAL[ nchnls, 4, npos]: the data that will be corrected.
;
;KEYWORD:
;
; M_SKYCORR, setting it includes the sky correction; default is zero.
; M_ASTRO, setting it includes the 'astronomical' correction
;          (which defines the sense of circular and applies the proper position
;          angle to obtain true sky stokes parameters); default is zero.
;
;OUTPUTS:
;	STOKESCAL: the corrected data. 
;-

;pa= (pangle( azmidpntn, zamidpntn, 1))
sz= size( stokesuncal)
stokescal= fltarr( sz[1], sz[2], sz[3])
npos= sz[ 3]
parallactic= reform( !dtor* parallactic_deg, npos)

m_total= fltarr( 4,4, npos, /nozero)
;CALCULATE M_SKY...IF DESIRED...
IF KEYWORD_SET( M_SKYCORR) THEN BEGIN
m_sky= fltarr( 4,4, npos)
m_sky[ 0,0, *]= 1.
m_sky[ 3,3, *]= 1.
m_sky[ 1,1, *]= cos( 2.* parallactic)
m_sky[ 2,1, *]= sin( 2.* parallactic)
m_sky[ 2,2, *]= m_sky[ 1,1, *]
m_sky[ 1,2, *]= -m_sky[ 2,1, *]

for nr=0, npos-1 do m_total[ *,*,nr]= m_tot ## m_sky[ *,*,nr]
ENDIF ELSE for nr=0, npos-1 do m_total[ *,*,nr]= m_tot
      
;DON'T FORGET TO TAKE THE INVERSE!!!
for nr=0, npos-1 do m_total[ *,*,nr]= invert( m_total[ *,*,nr])

;THEN ROTATE TO ASTRONOMICAL PS IF DESIRED...
if keyword_set( m_astro) then $
for nr=0, npos-1 do m_total[ *,*,nr]= m_astron ## m_total[ *,*,nr]

;SHORT WAY...
for nr=0, npos-1 do $
stokescal[ *,*,nr]= m_total[ *,*,nr] ## stokesuncal[ *,*,nr] 


;stop

return
end
