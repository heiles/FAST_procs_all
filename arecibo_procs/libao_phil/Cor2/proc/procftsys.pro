;+
;procftsys - process all the calonoffs in a file
;-
pro procftsys,filename,filenum
	if n_params() lt 2 then filenum=-1
	openr,lun,filename,/get_lun
	rew,lun
	needScan=1
	while (1) do begin
		if (needScan) then begin
			istat=posscan(lun,0,1)
		    if istat ne 1 then goto,done
			istat=corgethdr(lun,hdr)
		endif else begin
			istat=1
		endelse
;		print,'posscan:',istat
		if istat eq 0 then goto,done
		if istat eq -1 then goto,badalign
		needScan=1
	    case string(hdr[0].proc.procname) of
		   'calonoff':begin
				istat=chkcalonoff(lun,hdr,hdrOff)
				case istat of
					0 : goto,done
				   -1 : goto,done
				   -2 : begin
						needScan=1
				printf,filenum,$
		format='("scan:",i9," src:",a16," proc:",a12," ca0:",a8," nomatch")',$
				hdr[0].std.scannumber,string(hdr[0].proc.srcname),$
				string(hdr[0].proc.procname),string(hdr[0].proc.car[*,0])
						end
				   -3 : begin
						needScan=0
				printf,filenum,$
		format='("scan:",i9," src:",a16," proc:",a12," ca0:",a8," nomatch")',$
				hdr[0].std.scannumber,string(hdr[0].proc.srcname),$
				string(hdr[0].proc.procname),string(hdr[0].proc.car[*,0])
						hdr=hdrOff
						end
					1 : begin
				printf,filenum,$
		format='("scan:",i9," src:",a16," proc:",a12," ca0:",a8)',$
				hdr[0].std.scannumber,string(hdr[0].proc.srcname),$
				string(hdr[0].proc.procname),string(hdr[0].proc.car[*,0])
				printf,filenum,$
		format='("scan:",i9," src:",a16," proc:",a12," ca0:",a8," match")',$
				hdrOff[0].std.scannumber,string(hdrOff[0].proc.srcname),$
				string(hdrOff[0].proc.procname),string(hdrOff[0].proc.car[*,0])
			   			end
				endcase
				end
			else : begin
				printf,filenum,$
		format='("scan:",i9," src:",a16," proc:",a12," ca0:",a8)',$
				hdr[0].std.scannumber,string(hdr[0].proc.srcname),$
				string(hdr[0].proc.procname),string(hdr[0].proc.car[*,0])
			   end
		endcase
	endwhile
done:
	free_lun,lun
	 return
badalign:
	printf,filenum,"bad header alignment"
	free_lun,lun
	return
end
