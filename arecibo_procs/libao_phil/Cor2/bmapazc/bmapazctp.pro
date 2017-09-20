;+
;bmapazctp - process carl heiles bmapazc .. just the total power a,b...
; 
;SYNTAX:
;     istat=bampazctp(lun,hdr,mapa,mapb)
;ARGS:
;     lun: assigned to file, positioned to start of map
;
;RETURNS: 
;     hdr: the header from the first group 
;     mapA: mapa[pntsPerStrip,numstrips,numbrds] - return power info polA
;     mapB: mapB[pntsPerStrip,numstrips,numbrds] - return power info polB
;     istat: 1 - return ok
;            0 - hit eof before end of map. reposition to start of map
;           -1 - i/o error or not positioned on a hdr rec
;           -2 - found differenct procedure
;
;DESCRIPTION:
;  Input the power data for the map. Scale the data to kelvins.
;  Return the maps for pol A,B separately.
;
;SEE ALSO:
;     bmapazc1
;-
function bmapazctp,lun,hdr,mapa,mapb
	forward_function corgethdr,corpwr,corhcalval
	on_ioerror,iolab
	point_lun,-lun,startpos
;
;	get the first header so we can figure out the configuration
;
	istat=corgethdr(lun,hdr)
	if (istat ne 1) then message,'1st corgethdr error'
	procname=string(hdr[0].proc.procName)
	if (procname ne "bmapazc") then begin
		print,"hit procedure:",procname
		point_lun,lun,startpos
		return,-2
	endif
;
;	fill in the info we need to process the map
;   1. samplesperstrip ..
;   2. num strips (not including the cal strips at the ends
;   3. amin az direction (sign --> direction we went)
;   4. amin za direction (sign --> direction we went)
;
	cordmpsecs = hdr[0].cor.dumpsperinteg	; assume 1 sec dumps
	smpPerStrip=(hdr[0].proc.iar[1] + cordmpsecs-1)/cordmpsecs
	numstrips  = hdr[0].proc.iar[0]	; not including cals
	azWdAmin   = hdr[0].proc.dar[0]
	zaWdAmin   = hdr[0].proc.dar[1]
	numBrds    = hdr[0].std.grpTotRecs
	brdsInUse  = lindgen(numBrds)
;
;	reposition to start of rec
;
	point_lun,lun,startpos
	totpnts=smpPerStrip* (numstrips + 2) ; 2 for the cals
	nrecs=corpwr(lun,totpnts,pwrI)
	if (nrecs ne totpnts) then message,'map not complete'
;
;	compute cal 0, cal1 (first,last strips)
;
	cal0A=total(pwri[0:smpPerStrip-1].brd[brdsInUse].a,2)
	cal0B=total(pwri[0:smpPerStrip-1].brd.b,2)
	cal1A=total(pwri[totpnts-smpPerStrip:totpnts-1].brd.a,2)
	cal1B=total(pwri[totpnts-smpPerStrip:totpnts-1].brd.b,2)
;
;	create the float arrays hold the map
;
	mapA=reform($
		  transpose(pwri[smpPerStrip:totPnts-smpPerStrip-1].brd[brdsInuse].a),$
		  smpPerStrip,numstrips,numbrds)
	mapB=reform($
		  transpose(pwri[smpPerStrip:totPnts-smpPerStrip-1].brd[brdsInuse].b),$
		  smpPerStrip,numstrips,numbrds)
;
;	scale to cal value using center value of 1st,last strip
;
	for i=0,numBrds-1 do begin
;
;		input cal value in Kelvins
;
		if  corhcalval(hdr[i],calVal) lt 0 then calVal=[1.,1.]
		aCal=calVal[0]/(((cal0A[i]/smpPerStrip- mapA[smpPerStrip/2,0,i]) + $
			    cal1A[i]/smpPerStrip - mapA[smpPerStrip/2,numstrips-1,i])*.5)
		bCal=calVal[1]/(((cal0B[i]/smpPerStrip- mapB[smpPerStrip/2,0,i]) + $
				   cal1B[i]/smpPerStrip - mapB[smpPerStrip/2,numstrips-1,i])*.5)
		mapA[*,*,i]=aCal*temporary(mapA[*,*,i])
		mapB[*,*,i]=bCal*temporary(mapB[*,*,i])
	endfor
	return,1
iolab:
	if ( eof(lun)  ) then begin
		point_lun,lun,startpos
		return,0
	endif else begin
		point_lun,lun,startpos
		return,-1
	endelse
end
