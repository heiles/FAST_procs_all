pro mm_corr_strpfit, indx, m_tot, beamout_arr, beamcorrected_arr, $
	pa, m_skycorr= m_skycorr

;+

;PURPOSE: mueller-correct the strp_cfs array (the array of STRIPFIT data
;values created in HDRDEF_ALLCAL). STRIPFIT is the set of 1-d beam fit
;parameters defined in BEAM_DESCRIBE.

;CALLING SEQUENCE:
;
;	MM_CORR_STRP_CFS, m_tot, hdr2info, indx_patt, strp_cfs_in, strp_cfs_out
;
;INPUTS:
;
;       M_TOT, the mueller matrix for the system as defined in the AOTM
;
;	HDR2INFO, the famous hdr array
;
;	STRP_CFS_IN: the data that will be corrected.
;
;KEYWORD:
;
;       M_SKYCORR, setting it includes the sky correction; default is zero.
;
;OUTPUTS:
;
;	STRP_CFS_OUT: the corrected data.
;	PA, the parallactic angles
;
;-


;DEFINE SIZE OF DATA ARRAY...
ndata= n_elements( beamout_arr[ indx])

;EXTRACT ORIGINAL STRIPFITS DATA FROM STRUCTURE BEAMOUT_ARR...
strp_cfs_in= beamout_arr[ indx].stripfit

;FIND THE PARALLACTIC ANGLE FOR THE CENTER OF EACH STRIP...
pa= !dtor* beamout_arr[ indx].pacntr
pa=reform( pa, 4*ndata)

m_total= fltarr( 4,4, 4* ndata, /nozero)

;CALCULATE M_SKY...IF DESIRED...
IF KEYWORD_SET( M_SKYCORR) THEN BEGIN
m_sky= fltarr( 4,4, 4* ndata)
m_sky[ 0,0, *]= 1.
m_sky[ 3,3, *]= 1.
m_sky[ 1,1, *]= cos( 2.* pa)
m_sky[ 2,1, *]= sin( 2.* pa)
m_sky[ 2,2, *]= m_sky[ 1,1, *]
m_sky[ 1,2, *]= -m_sky[ 2,1, *]

pa= reform(pa, 4, ndata)

for nr=0, 4*ndata-1 do m_total[ *,*,nr]= m_tot ## m_sky[ *,*,nr]
ENDIF ELSE for nr=0, 4*ndata-1 do m_total[ *,*,nr]= m_tot
      
;DON'T FORGET TO TAKE THE INVERSE!!!
for nr=0, 4*ndata-1 do m_total[ *,*,nr]= invert( m_total[ *,*,nr])

strp_cfs_out= reform( strp_cfs_in, 12, 4, 4*ndata)

;;NONORMALIZE WAY...
FOR NR= 1,3 DO BEGIN

for nobs= 0, 4*ndata-1 do begin
tmp= reform (strp_cfs_out[ nr, *, nobs])
mmtmp= reform( m_total[*,*,nobs])
strp_cfs_out[ nr,*,nobs]= mmtmp ## tmp
endfor

endfor

strp_cfs_out= reform( strp_cfs_out, 12, 4, 4, ndata)

beamcorrected_arr= beamout_arr
beamcorrected_arr[ indx].stripfit= strp_cfs_out

return
end
