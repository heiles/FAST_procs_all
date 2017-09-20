;------------------------------------
; bmapazccon - contour map data from bmapazc total power
pro bmapazccon,hdr,map,nlevels,dbstep,pntsToUseBase,pol,dotitle=dotitle
;
; pol - 0 - polA, 1- polB
;
	forward_function mapbase,condblevels
	if n_elements(dotitle) eq 0 then dotitle=1
	if n_elements(pol) eq 0 then pol=0
	numStrips  =hdr.proc.iar[0]
	azWidthAmin=hdr.proc.dar[0]
	zaWidthAmin=hdr.proc.dar[1]
	smpPerStrip=hdr.proc.iar[2]
	bmap=mapbase(map,pntsToUseBase)
	levels=condblevels(bmap,nlevels,dbstep,maxval)
;
;  (0..n-1 + .5) * (width 1 integration) 
;
	az1= -azWidthAmin/2. + (findgen(smpPerStrip) + .5)*(azWidthAmin/smpPerStrip)
	za1= -zaWidthAmin/2. + findgen(numStrips) *(zaWidthAmin/(numStrips-1.))
	az= az1 #replicate(1.,numStrips)
	za= transpose(za1 # replicate(1.,smpPerStrip))
;
	title=string(format='("beammap ",A," az:",f6.2," za:",f6.3," lst:",A)', $
		string(hdr.proc.srcName), hdr.std.azTTD*.0001, hdr.std.grTTD*.0001,$
		fisecmidhms3(hdr.pnt.r.lastRd/(2.*!pi)*86400.))
;
	if pol eq 0 then   polNm = " polA" else polNm=" polB"
	brdInd=hdr.std.grpCurRec-1
	frq=hdr.dop.freqBCRest+hdr.dop.freqOffsets[brdInd]
	sbtitle=string(format=$
		'("frq:",f7.2,A," max:",f7.3," dbStep:",i2," minDb:",i3)',$
			  frq,polNm,maxval,dbstep,-(nlevels-1)*dbstep)
	if (dotitle gt 0 ) then  begin
		contour,bmap,az,za,levels=levels,/irregular, ymargin=[5,2],$
		xtitle="az [Amin]", ytitle="za [Amin]",title=title,subtitle=sbtitle
	endif else begin
		contour,bmap,az,za,levels=levels,/irregular, ymargin=[5,2],$
		xtitle="az [Amin]", ytitle="za [Amin]",subtitle=sbtitle
	endelse
	if (dotitle < 0 ) then begin
		xyouts,.5,.975,title,alignment=.5,/normal
	endif
	return
end
