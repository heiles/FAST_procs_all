;+
;NAME:
;anrittracekeys - get trace kewords
;SYNTAX:icur=anrittracekeys(inpl.n,indstart,traceNm,traceI,notrace)
;ARGS:
;inpl[n]: strarr  of input data
;indstart : long    index to start on .. count from zero
;traceNm  : string  "A","B", or "C"
;RETURNS:
;ISTAT  :    -1   a key was not found
;            >=1   index for last key found
;traceI:{}     holding key values
;notrace: int  if ==1 then this trace was not in the file
;
;DESCRIPTION
; get trace keywords 
;
function anrittracekeys,inpl,indstart,traceNm,traceI,notrace 
;
	
	notrace=0
	minlines=10
	n=n_elements(inpl)
	if indstart ge n then begin
		print,"Starting index ge number of elements"
		return,-1
	endif
	icur=indStart
	key=string(format='("# Begin TRACE ",a1," Setup")',strupcase(traceNm))
	icurStart=anritsearch(inpl,icur,key,junk,/noval)
	if icur lt 0 then goto,errout
	key="# Setup Done"
	icurEnd=anritsearch(inpl,icur,key,junk,/noval)
	if (icurEnd - icurStart) lt minlines then  begin
		notrace=1
		return,icurEnd
	endif
	icur=icurStart+1
;
;  get number of points first
;
	key="UI_DATA_POINTS" 
	ijunk=anritsearch(inpl,icur,key,lval)
	if ijunk lt 0 then goto,errout
	npnts=long(double(lval) + .5)

	traceI={traceI,$
    cfr: 0d,$
    span:0d,$
    rbw: 0d,$
    vbw: 0d,$
    preampon:0,$
    traceMode:0,$ ; 0 - normal,1-avg, 2-peakhold
	traceavg :0L,$; only valid if traceMode=1??
    npnts: npnts,$
	freq : dblarr(npnts),$
	dat  : dblarr(npnts)}
;
	key="CENTER_FREQ"
	icur=anritsearch(inpl,icur,key,lval)
	if icur lt 0 then goto,errout
	traceI.cfr=double(lval)
	icur++

	key="SPAN"
	icur=anritsearch(inpl,icur,key,lval)
	if icur lt 0 then goto,errout
	traceI.span=double(lval)
	icur++

	key="RBW"
	icur=anritsearch(inpl,icur,key,lval)
	if icur lt 0 then goto,errout
	traceI.rbw=double(lval)
	icur++

	key="VBW"
	icur=anritsearch(inpl,icur,key,lval)
	if icur lt 0 then goto,errout
	traceI.vbw=double(lval)
	icur++

	key="PREAMP_SET"
	icur=anritsearch(inpl,icur,key,lval)
	if icur lt 0 then goto,errout
	traceI.preampon=(double(lval) ne 0.0D)
	icur++

	key="TRACE_AVERAGE"
	icur=anritsearch(inpl,icur,key,lval)
	if icur lt 0 then goto,errout
	traceI.traceavg=long(lval)
	icur++

	key="TRACE_MODE"
	icur=anritsearch(inpl,icur,key,lval)
	if icur lt 0 then goto,errout
	traceI.tracemode=(double(lval) ne 0.0D)
	icur++
	return,icurEnd
errout:
	print,"Error searching for key:",key," for trace:",traceNm
	return,-1
end
