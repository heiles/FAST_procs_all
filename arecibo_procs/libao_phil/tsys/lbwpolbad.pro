;
; recompute lbw tsys using circular.. use when tsys program run
; but the circuitry is not switching to linear pol for cal
; input is the 8 lines from tsysall. it will undo the
; linear cals and recompute as circular
;
pro lbwpolbad,filename 
;
	on_ioerror,done
	openerr=0
	openr,lun,filename,/get_lun,error=openerr
	if openerr ne 0 then message,'error opening file:'+filename
	inpline=' '
	while 1 do begin
		readf,lun,inpline
		inp=strsplit(inpline,/extract)
;		print,inpline + '..old'
		if (inp[0] eq '5') then begin
			cala=float(inp[2])
			calb=float(inp[3])
			tsysa=float(inp[4])
			tsysb=float(inp[5])
			cal=(cala+calb)*.5
			tsysaN=tsysa/cala*(cal)
			tsysbN=tsysb/calb*(cal)
			line=string(format=$
'(a2," ",a8," ",f6.3," ",f6.3," ",f6.1," ",f6.1)',$
			inp[0],inp[1],cal,cal,tsysaN,tsysbN)
			print,line
		endif else begin
			print,inpline
		endelse
	endwhile
done: free_lun,lun
	return
end
