;+
;NAME:
;satinfo - return tle entries for all satellites
;SYNTAX: nsat=satinfo(satI,tledir=tledir)
;ARGS:
;KEYWORDS:
;tledir: string  directory to for tle's
;             def: /share/megs/predict/tle
;RETURNS:
;nsat: long    number of satellites we found
;satI[nsat]: {} array of struct holding satinfo
;
;DESCRIPTION:
;   Return info on all of the satellites we have tle's for.
;The returned structure contains:
;help,satI,/st
;   NM              STRING    'GIOVE-A'
;   TLEFILE         STRING    '/share/megs/phil/predict/tle/galileo.tle'
;   TLE             STRUCT    -> <Anonymous> Array[1]
;
;   .. The tle info for each satellite
;help,satI[0].tle,/st
;   SATNM           STRING    'GIOVE-A'
;   SATNUM          INT          28922
;   SATCLASS        STRING    'U'
;   LAUNCHYR        LONG              2005
;   LAUNCHNUM       INT             51
;   LAUNCHPIECE     STRING    'A  '
;   EPOCHYR         LONG              2008
;   EPOCHDAY        DOUBLE           260.32344
;   TMDER1          DOUBLE       2.2000000e-07
;   TMDER2          STRING    ' 00000-0'
;    DRAG            DOUBLE           10000.000
;   EPHTYPE         STRING    '0'
;   ELMNUM          INT            394
;   INCLINATION     DOUBLE           56.055200
;   RAASCNODE       DOUBLE           164.58550
;   ECCENTRICITY    STRING    '0007843'
;   ARGOFPERIGEE    DOUBLE           331.59930
;   MEANANOMALY     DOUBLE           28.417500
;   MEANMOTION      DOUBLE           1.7019477
;   REVNUM          LONG              1690
;   LINES           STRING    Array[3]
;-
function satinfo,satI,tledir=tledir
;
;   
; 
	nfiles=satlisttlefiles(tlefiles,tledir=tledir,suf='tle')
	maxSat=1000
	icur=0L
	for ifile=0,nfiles-1 do begin
		nsat=satinptlefile(tlefiles[ifile],tleAr)
		for isat=0,nsat-1 do begin
			if icur eq 0 then begin
				a={ nm:'',$
				   tlefile:'',$
				   tle    :tleAr[0]}
				satI=replicate(a,maxSat)
			endif
			satI[icur].nm=tleAr[isat].satnm
			satI[icur].tlefile=tlefiles[ifile] 
			satI[icur].tle=tleAr[isat]
			icur++
		endfor
	endfor
	if icur eq 0 then begin
		satI=''
		return,0
	endif
	if icur lt maxSat then satI=satI[0:icur-1]
	return,icur
end
