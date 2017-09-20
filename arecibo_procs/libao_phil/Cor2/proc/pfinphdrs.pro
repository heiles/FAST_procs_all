;+
;pfinphdrs - input all headers from a file
;SYNTAX: istat=pfinphdrs(filename,fnameind,hdrscn)
;ARGS:
;		filename  :string filename to process
;	    fnameind  :long   .. index into external filename array
;		hdrscn[]  :{pfhdrstr} array of structures, one per scan to return
;							 The user should allocate this before calling
;							 this routine to the max value needed.
;      istat      : number of files scans processed
;
;DESCRIPTION:
;  Read an entire file inputting the header information for each scan
;int hdrf. This structure will contain the first and last header of a sccan
;as well as the average lag0pwrratio.
;
function pfinphdrs,filename,fnameind,hdrscn
;
	lun=-1
	openr,lun,filename,/get_lun,error=errstat
 	if (errstat ne 0) then begin
		message,!err_string
	endif
	maxscans=(size(hdrscn))[1]
	hdrzero={hdr}				; to zero out unused slots..
	curscan=-1L
	scnind=0L
	lag0avg=fltarr(2,4)
	while 1 do begin
		if corgethdr(lun,newhdr) lt 1 then goto,done
		if newhdr[0].std.scannumber ne curscan then begin
;		   print,'curscan:',curscan,' hdr:',newhdr[0].std.scannumber 
		   if curscan ne -1 then  begin
; 
;		   finish up on previous scan
;	
				hdrscn[scnind].hend[0:nbrds-1]=lasthdr;
			    for i=nbrds,3 do hdrscn[scnind].hend[i]=hdrzero
				hdrscn[scnind].avglag0pwr[*,0:nbrds-1]=lag0avg/grpcnt
				hdrscn[scnind].grpperscan=grpcnt
				hdrscn[scnind].pol=hdrscn[scnind].pol*0. ; zero it out..
				for i=0,nbrds-1 do begin
					hdrscn[scnind].pol[0,i]=1
					lagconfig=hdrscn[scnind].hst[i].cor.lagconfig
					if hdrscn[scnind].hst[i].cor.numsbcout ge 2 then begin
						hdrscn[scnind].pol[1,i]=2
					endif else begin $
						if (lagconfig eq 1) or (lagconfig eq 7) then $
							hdrscn[scnind].pol[0,i]=2
					endelse
				endfor
				lin=string(format=$
					'(i4," ",i9," ",i4," ",a16," ",a12," ",a8)',$
					scnind,$
					hdrscn[scnind].hst[0].std.scannumber,$
					hdrscn[scnind].grpperscan,$
					string(hdrscn[scnind].hst[0].proc.srcname),$
					string(hdrscn[scnind].hst[0].proc.procname),$
					string(hdrscn[scnind].hst[0].proc.car[*,0]))
				print,lin
			    scnind=scnind+1
			endif
			curscan=newhdr[0].std.scannumber
			lag0avg=newhdr.cor.lag0pwrratio
			nbrds=newhdr[0].cor.numbrdsused
			grpcnt=1L
			if (scnind ge maxscans) then begin
				curScan=-1L
				goto,done
			endif
			hdrscn[scnind].hst[0:nbrds-1]=newhdr
			for i=nbrds,3 do hdrscn[scnind].hst[i]=hdrzero
			hdrscn[scnind].nbrds=nbrds
		endif else begin
;
;			add in lag0pwr ratio, count the number of scans
;
			lag0avg=lag0avg + lasthdr.cor.lag0pwrratio
			grpcnt=grpcnt+1
		endelse
		lasthdr=newhdr
	endwhile
done:
	free_lun,lun
	if curscan ne -1 then  begin
;
;      finish up on previous scan
;
        hdrscn[scnind].hend[0:nbrds-1]=lasthdr;
	    for i=nbrds,3 do hdrscn[scnind].hend[i]=hdrzero
        hdrscn[scnind].avglag0pwr[*,0:nbrds-1]=lag0avg/grpcnt
        hdrscn[scnind].grpperscan=grpcnt
		for i=0,nbrds-1 do begin
            hdrscn[scnind].pol[0,i]=1
            lagconfig=hdrscn[scnind].hst[i].cor.lagconfig
            if hdrscn[scnind].hst[i].cor.numsbcout ge 2 then begin
                  hdrscn[scnind].pol[1,i]=2
            endif else begin $
               if (lagconfig eq 1) or (lagconfig eq 7) then $
                    hdrscn[scnind].pol[0,i]=2
            endelse
        endfor
		lin=string(format=$
					'(i4," ",i9," ",i4," ",a16," ",a12," ",a8)',$
					scnind,$
					hdrscn[scnind].hst[0].std.scannumber,$
					hdrscn[scnind].grpperscan,$
					string(hdrscn[scnind].hst[0].proc.srcname),$
					string(hdrscn[scnind].hst[0].proc.procname),$
					string(hdrscn[scnind].hst[0].proc.car[*,0]))
		print,lin
        scnind=scnind+1
    endif
;	if (scnind ne maxscans) and (scnind ne 0)  then hdrscn=hdrscn[0:scnind-1];
	hdrscn.fileind=fnameind
	return,scnind
end
