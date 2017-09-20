;+
;NAME:
;rdevposipp - position to start of ipp in file
;SYNTAX istat=rdevposipp(desc,ipp)
;                     
;ARGS:
;  desc : {}     returned from rdevopen()
;    ipp:long    ipp in file to compute position for. Count from 0.
;RETURNS:
;   istat:ulong  0 position ok, -1 error
;
;DESCRIPTION:
;   Position to the start of the requested ipp in the file.
;Ipps are counted from 0. This is the ipp number in the file, not the ipp 
;number from the start of the observation.
;-
function    rdevposipp,desc,ipp

;
;	first figure out the byte offset for the first ipp of this
;   file
;
	bytesSample=2*2
	nsmpIpp=desc.txsmpipp + desc.dsmpipp + desc.nsmpIpp
	ippInFile=long(desc.smpInfile/nsmpIpp)
	if ipp ge ippInFile then begin
		print,format=$
'("requested ipp:",i5," not in file. File contains:",i5," ipps")',$
		ipp,ippInFile
		return,-1
	endif
    if (desc.smpOffStFile eq 0) then begin
     	bytePos=1024L
    endif else begin
     	ippSt=(desc.smpoffStFile/nsmpIpp)
        smpSkip=(1D - (ippSt - long(ippSt)))*nsmpIpp
        if abs(smpSkip) lt .5 then begin
           smpSkip=0L
        endif
        smpSkip=long(smpSkip + .5)
        bytePos=smpSkip*bytesSample
     endelse
	 bytePos+=ipp*(nsmpIpp*bytesSample)
	 point_lun,desc.lun,bytepos
	 return,0
end
