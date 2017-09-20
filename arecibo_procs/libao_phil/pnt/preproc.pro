;
; routines to access preproc info
;
function preprocinp,lun,skip=skip,npts=npts
	a={preprocinp,  timeMs: 0L,$;
	                ptaxis: 0 ,$;
	               preaxis: 0 ,$;
	               posLim:  lonarr(3,/nozero),$;
	               posPre:  lonarr(3,/nozero)}
	a={preproc   ,  time:   0.,$;
	                ptaxis: 0 ,$;
	               preaxis: 0 ,$;
	               posLim:  fltarr(3,/nozero),$;
	               posPre:  fltarr(3,/nozero)}
	if not keyword_set(skip) then skip=0
	if not keyword_set(npts) then npts=10000
	preinp=replicate({preprocinp},npts)
	preinp.timeMs=-1;
	on_ioerror,gotit1
	readu,lun,preinp
gotit1:
	ind=where(preinp.timeMs gt 0,count)
	if (count eq 0) then return,''
	preproc=replicate({preproc},count)
	preproc.time=preinp[ind].timeMs*.001
	preproc.ptaxis=preinp[ind].ptaxis
	preproc.preaxis=preinp[ind].preaxis
	preproc.posLim=preinp[ind].posLim*.0001
	preproc.posPre=preinp[ind].posPre*.0001
	return,preproc
end
