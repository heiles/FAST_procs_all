
;+
;NAME:
;rdevfindipps - find which dataset ipps belong to in a file.
;SYNTAX   [npwr,nmracf,nclp,ntopsid]=rdevfindipps(desc,pwr=iipwr,mracf=iimracf,clp=iiclp,$
;                           topsid=iitopsid,txSkipUsec=txSkipUsec,$
;                           bad=iibad,nbad=nbad 
;                     
;ARGS:
;  desc : {}     returned from rdevopen()
;KEYWORDS:
;minval    : float	minvalue for a tx Sample to be high
;                   abs(txVal)  in counts
;txSkipUsec: float	number of usecs to skip at start of txpulse
;                   So you start at the rising edge of first baud.
;					default is 1.56 usecs
; notopsid:         If set then the file contains no topsid data
; notclp  :         if set then the file contains no clp data.
;
;RETURNS:
; nipps[4] : long number for each experiment
; iipwr[]  : long	 return indices for power profile
; iimracf[]: long	 return indices for mracf
; iiclp[]  : long return indices for clp
; iitopsid[]:long return indices for topsid
; iibad[]  : long return indeics for ipps that don't fit into a dataset
; nbad     : long number of bad ipps
;
;
;DESCRIPTION:
;   Scan a file and find the ipp indices for each requested dataset
;
;-
function    rdevfindipps,desc,pwr=iipwr,mracf=iimracf,clp=iiclp,topsid=iitopsid,$
						txSkipUsec=txSkipUsec,bad=iibad,nbad=nbad,$
                        notopsid=notopsid,noclp=noclp
;
;	go get to start of rf pulse
;
	if n_elements(txSkipUsec) eq 0 then txSkipUsec=1.567
	if n_elements(minval) eq 0 then minval=100.
;
;	default rf widths in usecs.
;
	rf_pwr  =52.
	rf_mracf=300.
	rf_clp  =440.
	rf_topsid=500.
	nsamples=1			;  grab 1 samples at each offset
	backOffUsecs=6.	    ;  sample comes this many usecs before end of rf.
;  
	txTimes=[rf_pwr,rf_mracf,rf_clp,rf_topsid] + txSkipUsec - backOffUsecs
;	indices in txTimes for the different datasets
;
	ipwr=0
	imracf=1
	iclp=2
    itopsid=3
;
	nipps=rdevgrabtxsmp(desc,txTimes,nsamples,txAr)
;	for each ipp see if we've found a data set for it.
;   start at the longest and work back
;
	used=intarr(nipps)
	iitopsid=where(abs(txar[*,itopsid]) gt minVal,ncntTopsid)
	if ncntTopSid gt 0 then  used[iitopsid]=1
;
	iiclp =where((abs(txar[*,iclp]) gt minVal) and (used eq 0),ncntClp)
	if ncntClp gt 0 then  used[iiclp]=1
;
	iimracf=where((abs(txar[*,imracf]) gt minVal) and (used eq 0),ncntMracf)
	if ncntMracf gt 0 then  used[iimracf]=1
;
	iipwr=where((abs(txar[*,ipwr]) gt minVal) and (used eq 0),ncntPwr)
	if ncntPwr gt 0 then  used[iiPwr]=1
;
;	ipps that don't match anything.
;
	iibad=where(used eq 0,nbad)
	return,[ncntpwr,ncntmracf,ncntclp,ncnttopsid]
end
