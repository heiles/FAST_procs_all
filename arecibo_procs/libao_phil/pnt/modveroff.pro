;+
;NAME:
;modveroff - compute offset for receiver from sband model
;
;SYNTAX : modveroff(fit,fitsb,offfix,npts,offnew,offsb,indnew,indsb,$
;					median=median
;
; ARGS    : 
;   fit[] : {x101fitval} source tracked with new feed.
; fitsb[] : {x101fitval} source tracked with sbn feed.
;
; RETURNS :
; offsb[2]: float  avg [aze,zae] for sb
;offnew[2]: float  avg [aze,zae] for new rcvr
;offfix[2]: float  offsb-offnew to add to offset new receiver
;   npts  : long   number of common points.
;
;	KEYWORDS:
;   median  :   if set then use the median rather than the average
;   usemm   :   if set then input data is mueller matrix structs
;
; DESCRIPTION:
;	Models are made with the sband narrow receiver. The same model is
; then used for all the other receivers. An offset in az,za is applied
; to allow for turret/horn motion. To compute these offsets
; a source is tracked with the sband and then the "other" receiver. The 
; average offset between the sband and "other" receiver is used at 
; the offset for the new receiver.
;
; When running the verify we have an offset for the sbn receiver (measured
; by the model). We also have the offset difference for each receiver and 
; sbn from the previous model. We arrange the verify models so each receiver
; has the same offset relative to sbn that it had in the previous model.
;  	This routine then computes (verifyErrSbn - verifyErrRcv). This value
; should be added to the offset value used by the rcv when doing the
; verify run.
;
; NOTES:
; 1. pnt errs reported by spider scans need to be subtracted from model
;    so you point at the source.
; 2. We try to make the pnt err for the new rcvr the same as the pnt error
;    for sbn (we do not try to make it 0).
;
; EXAMPLE:
; 	Use the sbn and lbw receivers. 
;   Suppose the offset differences for model 11 (the previous model) were:
;       sbn11az= 10 sbn11za=-5
;       lbw11az=  8 lbw11za=-11
;                 2         -6  difference
;
; The measured model offsets for model12 sbn were:
;   sbn12az=  5 sbn12za=-9
;
; So we would use the following for the lbw verify offsets:
;   lbw12az= 5-2=3 lbw12za= -9 -6 = -15
;  
; 
; Suppose we tracked the versrc with sbn and got (spider scans)
; sbnveraz=-3   sbnverza=+5     sbn offsets (sub from  model to trk pk)
;
; if the average tracking errors for lbw were then:
; lbwveraz=-1   lbwverza=+2
;
; This routine would then return:
; sbnveraz - lbwveraz
;  -3 -(-1)=-2 az, 5 - (2)=3
;
;  THESE RETURNED VALUES SHOULD BE added to the LBW OFFSETS USED FOR VERSRC.
;   3 + -2=1, za -15 + 3 = -12
;
;14jan08.. why added....???? spider scans... because..
;    let :
;           lbw=-5asec    src         sbn=+10Asecs
;                         pk             meas 
;                  |       |               |
;                          
; let errsb = +10 asecs be reported by spider scans
;      --> sbmodel is tracking error is +10 asecs from pk
;          You need to add -10 to model to track the peak
;
; let errlbw= -5 be reported by spider scans
;      --> lbwmodel is tracking error is -5 asecs from pk
;          You need to add 5 asec to model to track the peak
;
; to make lbwmodel track +10 asecs from pk (the same as sbn err)
;                you must move it +15 asecs.
;       (errsb - errlbw)
;       (10 - (-5) ) =  15
;
;  so add the returned value to the lbw model values used for the verify run.
;-
;
pro modveroff,fit,fitsb,offfix,npts,offnew,offsb,indnew,indsb,median=median,$
		usetur=usetur
;
	if n_elements(median) eq 0 then median=0
	if not keyword_set(usetur) then begin
		azsb=fitsb.az
		zasb=fitsb.za
		az=fit.az
		za=fit.za
		ind=where(azsb lt 0, count)
		if count gt 0 then azsb[ind]=azsb[ind] + 360.
		ind=where(az lt 0, count)
		if count gt 0 then az[ind]=az[ind] + 360.
		azsb=azsb mod 360.
		az  =az   mod 360.
		azErrsbA=fitsb.fit.azerr*60.
		azErrA  =  fit.fit.azerr*60.
		zaErrsbA=fitsb.fit.zaerr*60.
		zaErrA  =  fit.fit.zaerr*60.
	endif else begin
		azsb=fitsb.az mod 360.
		az  =fit.az   mod 360
		azErrsbA=fitsb.aze
		azErrA  =  fit.aze
		zaErrsbA=fitsb.zae
		zaErrA  =  fit.zae
	endelse
;
;	make contigous
;
	ind=where((az le 90) or (az ge 270),count)
	if count gt 0 then  begin
		ind=where(az lt 270,count)
		if count gt 0 then begin
			az[ind]=az[ind]+360.
		endif
	endif

	ind=where((azsb le 90) or (azsb ge 270),count)
	if count gt 0 then  begin
		ind=where(azsb lt 270,count)
		if count gt 0 then begin
			azsb[ind]=azsb[ind]+360.
		endif
	endif
; first last az common
	azf=max([min(az),min(azsb)])
	azl=min([max(az),max(azsb)])

	indsb  =where((azsb ge azf) and (azsb le azl))
	indnew =where((az ge azf) and (az le azl))

	if median ne 0 then begin
		azesb=median(azErrsbA[indsb])
		zaesb=median(zaErrSbA[indsb])
		aze  =median(azErrA[indnew])
		zae  =median(zaErrA[indnew])
	endif else begin
		azesb=mean(azErrSbA[indsb])
		zaesb=mean(zaErrSbA[indsb])
		aze  =mean(azErrA[indnew])
		zae  =mean(zaErrA[indnew])
	endelse

	npts=n_elements(indnew)
	offsb =[azesb,zaesb]
	offnew=[aze  ,zae]
	offfix=offsb-offnew
	return
end
