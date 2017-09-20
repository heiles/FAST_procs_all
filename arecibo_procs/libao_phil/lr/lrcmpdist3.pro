;+
;NAME:
;lrcmpdist3 - compute pltAvgHgt for entries with missing distomat readings
;SYNTAX: n=lrcmpdist3(fitI,dist6,cmpI)
;    ARGS:
; fitI  : {}        struct holding fit coef. see lrdist3inp()
; dist6[6,m]: float distances to check for computation
; RETURNS:
;   cmpI:[] holding the fit results
;
;DESCRIPTION:
;   Search dist6[6,m]  for the entries that don't have 6 lr measurements.
;For those that have valid 3 135 or 3 246 reading (but not 6 good ones) ,
;compute the average height from the fit coef in fitI (see lrdist3inp()).
;	Return the indices into dist6[0,I] in ii[] for these entries.
;cmpI will contain:
;IDL> help,cmpi,/st
;** Structure <8c3d18>, 4 tags, length=6480, data length=6472, refs=1:
;   N               LONG            462    number we found to compute
;   II              LONG      Array[462]   index into dist6[0,*] for this 
;   AVGPLTH         DOUBLE    Array[462]   avg hght in meters
;   SETUSED         INT       Array[462]   1 dist135, 2 246
;
;
;-
function lrcmpdist3,fitI,dist6,cmpI
;
	ref=163. 		; close enough
	ref2=ref*2
	ref3=ref*3
	eps =2. 		; must be with 2 meters of ref
	eps3=eps*3.
	eps6=eps*6.
	j135=[0,2,4]
	j246=[1,3,5]
	tot135=total(dist6[j135,*],1)
	tot246=total(dist6[j246,*],1)
	ii135 =where((abs(tot135 - ref3) le eps3) and $
	             (abs(tot246 - ref3) gt eps3),cnt135)
	ii246 =where((abs(tot135 - ref3) gt eps3) and  $
	             (abs(tot246 - ref3) le eps3),cnt246)
	ntot=cnt135 + cnt246
	if (ntot eq 0) then return,0
	cmpI={$
		 n:         ntot,$  ; number we  found
		ii: lonarr(ntot),$  ; indices into dist6 that were computed
		avgPltH:dblarr(ntot),$; compute height .. meters
		setUsed:intarr(ntot) $  ; 1 --> coef135, 2-->coef246 
	}
	avgPltHght=dblarr(ntot)
;
	if (cnt135 gt 0) then begin
		cmpI.avgPltH[0:cnt135-1]=fitI.c135[0] + fitI.c135[1]*tot135[ii135]/3d
		cmpI.setUsed[0:cnt135-1]=1
	endif
;
	if (cnt246 gt 0) then begin
		cmpI.avgPltH[cnt135:*]=fitI.c246[0] + fitI.c246[1]*tot246[ii246]/3d
		cmpI.setUsed[cnt135:*]=2
	endif
;
	if (cnt135 gt 0) then begin
		ii=ii135
	endif
	if (cnt246 gt 0) then begin
		ii=(cnt135 gt 0)?[ii,ii246]:ii246
	endif
	cmpI.ii=ii
;
;	put in time order
;
	jj=sort(ii)
	cmpI.ii=ii[jj] 
	cmpI.avgPltH=cmpI.avgPltH[jj]
	cmpI.setUsed=cmpI.setUsed[jj]
;
	return,cmpI.n
end
