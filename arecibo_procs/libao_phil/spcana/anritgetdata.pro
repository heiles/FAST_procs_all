;
; read in anritsu file
;
function anritgetdata,filename,trA,trB,trC,gotA,gotB,gotC

	n=readasciifile(filename,inpl,comment='')
	icur=0L
	key='DATE'
	icur=anritsearch(inpl,icur,key,ldate)
	if icur eq -1 then goto,errkey
;
	gotAr=intarr(3)
	key="# Begin TRACE A Setup"
	icur=anrittracekeys(inpl,icur,'A',trA,notrace)
	if icur eq -1 then goto,errkey
	gotAr[0]= notrace eq 0
;
	icur++
	key="# Begin TRACE B Setup"
	icur=anrittracekeys(inpl,icur,'B',trB,notrace)
	if icur eq -1 then goto,errkey
	gotAr[1]= notrace eq 0
	icur++
	key="# Begin TRACE C Setup"
	icur=anrittracekeys(inpl,icur,'C',trC,notrace)
	if icur eq -1 then goto,errkey
	gotAr[2]= notrace eq 0
	icur++
;
; 	now get the data
;
	trL=['A','B','C']
	npnts=trA.npnts
	for i=0,2 do begin
		if gotAr[i] then begin
	 		key=string(format='("# Begin TRACE ",a1," Data")',trL[i])
	    	icur=anritsearch(inpl,icur,key,junk,/noval)
			if icur lt 0 then goto,errout
			icur++
			ldat=inpl[icur:icur+npnts - 1L]
			a=stregex(ldat,"[^=]*=([^,]+),([- .0-9]+) ([a-zA-Z]+)",/extr,/sub)
		case i of
			0: begin
				trA.freq=double(reform(a[2,*]))
				trA.dat =double(reform(a[1,*]))
			   end
			1: begin
				trB.freq=double(reform(a[2,*]))
				trB.dat =double(reform(a[1,*]))
			   end
			2: begin
				trC.freq=double(reform(a[2,*]))
				trC.dat =double(reform(a[1,*]))
			   end
		endcase
		endif
	endfor
	gotA=gotAR[0]
	gotB=gotAR[1]
	gotC=gotAR[2]
	return,1
errkey:print,"Error search for key:"+key
errout:
	return,-1
end
