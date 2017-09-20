function pmget, lun, b,quiet=quiet
;
; input pntmod record
;history:
; 07jun00 - switched the return order so d[*,0] is polA (left digitizer)
; 08jun00 - check to make sure all the recs are the same scan
; status:
; 1 - gotit
; 0 - hit eof
; -1- hit different scannumber,grpnumber in middle of strip
; -2  bad data in hdr
;
	on_error,1
	hdr={hdr}
	rec=0
	recsPerStrip=999
	on_ioerror,ioerr
	retstat=1
	repeat begin
		readu,lun,hdr
		doswap=chkswaprec(hdr.std)
		if doswap then hdr=swap_endian(hdr)
		if ( string(hdr.std.hdrMarker) ne 'hdr_' ) then begin
			print,"bad hdr. no hdrid:hdr_"
			retstat=-2
			goto,done
		endif
		if (hdr.ri.smpPairIpp gt 65536) then begin
			print,"smpPairIpp > 65535"
			retstat=-2
			goto,done
		endif
		if (rec eq 0 ) then begin
		   pntsPerRec=hdr.ri.smpPairIpp*hdr.ri.ippsPerBuf
		   if "pntmod" eq string(hdr.proc.procname) then begin
		    	recsPerStrip=hdr.proc.iar(0)
			endif else begin
		    	recsPerStrip=2				; just a cal rec
			endelse
		   logInd=recsPerStrip/2 - 1		;rec before middle to store,az,za
		   if  logInd lt 0 then logInd=0
		   pntsPerStrip=recsPerStrip*pntsPerRec
		   tmp=intarr(2,pntsPerRec)
		   tmpA=intarr(2,pntsPerStrip)
		   b={h:hdr,d:fltarr(pntsPerStrip,2,/nozero),pmi:{pminfo}}
	       b.h=hdr
		   b.pmi.turPosD        =hdr.proc.dar[0]
		   b.pmi.turAmpD        =hdr.proc.dar[1]
		   b.pmi.turFrqh        =hdr.proc.dar[2]
		   b.pmi.recsPerStrip   =recsPerStrip
		   b.pmi.samplesPerStrip=pntsPerStrip
		   b.pmi.secsPerStrip   =hdr.proc.iar[1]
		   b.pmi.secsPerRec     =hdr.proc.iar[2]

		   b.pmi.stripNum       =(hdr.std.grpnum-1)/recsPerStrip + 1
		   b.pmi.zaOffStartD    = hdr.pnt.r.reqOffRd[1] * !radeg
		   b.pmi.za             = hdr.std.grTTD*.0001
		   b.pmi.az             = (hdr.std.azTTD*.0001 mod 360.)
		   scanNum=hdr.std.scannumber
		   grpNum =hdr.std.grpnum
		endif
		if  logInd eq rec then begin
		   b.pmi.za             = hdr.std.grTTD*.0001
		   b.pmi.az             = (hdr.std.azTTD*.0001 mod 360.)
		endif
		ind1=rec*pntsPerRec
		ind2=ind1 + pntsPerRec - 1
		readu,lun,tmp
		if doswap then tmp=swap_endian(tmp)
		tmpA[*,ind1:ind2]=tmp
		rec=rec+1
		if not keyword_set(quiet) then  begin
  		print,'scan:',hdr.std.scanNumber,' grp:',hdr.std.grpNum,' rec:',$
 				hdr.std.grpCurRec
		endif
		if (grpnum ne hdr.std.grpNum) or $
			(scanNum ne hdr.std.scannumber) then begin
			retstat=-1
			goto,done
		endif
		grpnum=grpnum+1
	endrep until  rec ge recsPerStrip
	b.d[*,0]=transpose(tmpA[1,*])
	b.d[*,1]=transpose(tmpA[0,*])
	retstat=1
done:
	return,retstat
ioerr:
	hiteof=eof(lun)
	on_ioerror,NULL
	if (not hiteof) then begin
		message, !ERR_STRING, /NONAME, /IOERROR
	 endif
	 retstat=0 
	 goto,done
end
