;+
;NAME:
;pdevtdspc - compute spectra for time domain data
;SYNTAX: n=pdevtdspc(desc,nchan,nspc,spc,posspc=posspc,toavg=toavg)
;ARGS:
;desc:{} from pdevopen()
;nchan: long  number of freq chan in each spectra
;nspc: long number of averaged spectra to return
;KEYWORDS:
;posspc: long	spectra to position to before starting.
;               0--> no position. positioning uses 
;               nchan length spc before averaging
;toavg: long number of spectra toaverage. def=1
;
;RETURNS:
;   n: long number of averaged spectra
;
;DESCRIPTION:
;	Compute spectra from time domain data. It will
;return nspc averaged spectra. Each averaged spc is nchan
;long and has toavg spectra averaged. Data is returned
;for both pols (if recorded).
;	The spectra will be shifted to but dc in the center
;
;	posspc= keyword can position you before reading. The position
;unit is the length of a single spectra (before averaging).
;
;The file will be left positioned after the last averaged
;spectra input. If you hit eof before all spectra are input
;it is left positioned at the end of the last full averaged
;spectra input.
;
;Notes:
;   This routine will probably have trouble spanning
;data sets in more than 1 file.
;
;-
function pdevtdspc,desc,nchan,nspc,spc,posspc=posspc,toavg=toavg
	
	if not keyword_set(toavg) then toavg=1L
	if n_elements(posspc) eq 0 then posspc=0L
	npol=desc.nsbc
	smpPerAvg=nchan*toavg
   	spc=(npol eq 2)?fltarr(nchan,nspc,npol):fltarr(nchan,nspc);
;
	start=1
	avgCnt=0L
	icur=0L
	pos=nchan*posspc
	while (icur lt nspc) do begin
		point_lun,-desc.lun,curPos
		istat=pdevgettmd(desc,smpPerAvg,b,smppos=pos)
		pos=0L
		if (istat ne smpPerAvg) then begin
			point_lun,desc.lun,curpos
			break
		endif
		if npol eq 2 then begin
			spc[*,icur,*]=total(abs(fft(reform(b.d,nchan,toavg,2),dim=1))^2,2)/toavg
		endif else begin
			spc[*,icur]=total(abs(fft(reform(b.d,nchan,toavg),dim=1))^2,2)/toavg
		endelse
		icur++
	endwhile
	if icur ne nspc then begin
		if icur eq 0 then return,istat
		if npol eq 2 then begin
			spc=spc[*,0L:icur-1,*]
		endif else begin
			spc=spc[*,0L:icur-1]
		endelse
	endif
	spc=(npol eq 2)?shift(spc,nchan/2L,0,0):shift(spc,nchan/2,0)
	return,icur
end
