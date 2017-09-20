;+
;NAME:
;masdpsp - double position switching
;SYNTAX: istat=masdpsp,flist,b,fdir=fdir,flux=flux,fnmI=fnmI,
;				 srcOn=srcOn,srcOff=srcOff,$
;                bpon=bpon,bpoff=bpoff,src_onoff=src_onoff
;ARGS:
;flist[4]: string  srcOn,srcOff,bpOn,bpOff filenames
;
;KEYWORDS:
;  fdir : string If supplied then prepend this to each entry in flist.
;                You could also just include the directory in flist.
;  flux : float  bandpass calibrator flux
;fnmI[4]: {}     srcOn,srcOff,bpOn,bpOff from masfilelist. If supplied use
;                this rather than flist[].
;RETURNS  :
;   istat : 1   ok, -1 error reading a file
;	    b : {masget} (srcOn-srcOff)/(bpOn-bpOff) * flux averaged.     
;srcOn[n] :{masget} the srcOn records
;srcOff[n]:{masget} the srcOff records
;  bpOn[m]:{masget} the bandpass on records
; bpOff[m]:{masget} the bandpass off records
;src_onoff:{masget}  srcOn/srcOff averaged
;
;DESCRIPTION:
;	Perform double position switching processing:
;   b=avg(srcOn-srcOff)/avg(bpOn-bpOff)  * fluxBpCalibrator 
;
;The routine will also return the individual records for srcOn,srcOff,
;bpon,bpoff if you supply the keywords as well as the averaged
;src_onoff = avg(srcOn/srcOff)
;SEE ALSO
;masdpsfind()
;-
function masdpsp,flist,b,fdir=fdir,flux=flux,fnmI=fnmI,$
				 srcOn=srcOn,srcOff=srcOff,$
                bpon=bpon,bpoff=bpoff,src_onoff=src_onoff
;
	NM='masdpsp'
	if (n_elements(fnmi) gt 0) then begin
		if n_elements(fnmi) lt 4 then begin
			print,NM + $
			  ":fnmi keyword must have 4 entries for:srcOn,srcOff,bpon,bpoff"
			return,-1
		endif
		flistL=fnmI[0:3].dir + fnmI[0:3].fname
	endif else begin
		if n_elements(flist) lt 4 then begin
			print,NM + $
			 ":flist arg must have 4 entries for:srcOn,srcOff,bpon,bpoff"
			return,-1
		endif
	    if n_elements(fdir) eq 0 then fdir=''
		flistL=flist[0:3]
		for i=0,3 do flistL[i]=fdir +flistL[i]
	endelse

;   Input the data

	if (masgetfile(desc,srcOn,filename=flistL[0]) ne 1 ) then begin
			print,NM+":err reading srcOn:"+flistLL[0]
			return,-1
	endif
	if (masgetfile(desc,srcOff,filename=flistL[1]) ne 1 ) then begin
		print,NM+":err reading srcOff:"+flistL[1]
		return,-1
	endif
	if (masgetfile(desc,bpOn,filename=flistL[2]) ne 1 ) then begin
		print,NM+":err reading bpOn:"+flistL[2]
		return,-1
	endif
	if (masgetfile(desc,bpOff,filename=flistL[3]) ne 1 ) then begin
		print,NM+":err reading bpOn:"+flistL[3]
		return,-1
	endif
;
;   compute the averages
;
	n=masaccum(srcOn ,srcOnAvg,/avg,/new)
	n=masaccum(srcOff,srcOffAvg,/avg,/new)
	n=masaccum(bpOn ,bpOnAvg,/avg,/new)
	n=masaccum(bpOff,bpOffAvg,/avg,/new)
;
;   now the srcOn-srcOff, bpon - bpoff
;
	b=masmath(srcOnAvg,srcOffAvg,/sub)
	bpOnOff=masmath(bpOnAvg,bpOffAvg,/sub)
	b=masmath(b,bpOnOff,/div)
;
;   check for divide by 0
;
	ii=where(finite(b.d) eq 0,cnt)
	if cnt gt 0  then (b.d[ii] = 0.)
	if n_elements(flux) gt 0 then b.d*=flux
	if arg_present(src_onoff) then begin
		src_onoff=masmath(srcOnAvg,srcOffAvg,/div)
	endif
    return,1
end
