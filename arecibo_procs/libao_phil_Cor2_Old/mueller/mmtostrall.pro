;+
;name
; mmtostrall - convert mueller dat to structure format for all files
;-
function mmtostrall,filename
;	common hdrdata
;	common timecoord

	on_ioerror,done
	openr,lun,filename,/get_lun
	curfile=''
	line=''
	rcvnum=0
	maxpat=5000
	a=replicate({mueller},maxpat)
	totpat=0
	while (1) do begin
		readf,lun,line
		if strmid(line,0,1) ne '#' then begin
			reads,line,rcvnum,curfile
			curfile=strtrim(curfile,2)
			aloc=mmtostr(curfile,rcvnum=rcvnum)
			if keyword_set(aloc) then begin
				numpat=(size(aloc))[1]
				a[totpat:totpat+numpat-1]=aloc
			endif else begin
				numpat=0
			endelse
			totpat=totpat+numpat
			lab=string(format='("totpat:",I4," found:",I3," in ",i3," ",a)',$
					totpat,numpat,rcvnum,curfile)
			print,lab
		endif
	endwhile
done:
	free_lun,lun
	if totpat eq 0 then begin
		print,'no patterns found'
		return,''
	endif else begin
		a=a[0:totpat-1]
		return,a
	endelse
end
