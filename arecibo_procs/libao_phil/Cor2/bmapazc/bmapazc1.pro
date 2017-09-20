;-------------
pro bmapazc1,lun,nlevels,dbstep,pltmsk=pltmsk
;
	forward_function bmapazctp 
	istat=bmapazctp(lun,hdr,mapa,mapb)
	if (istat ne 1) then return
	;
	;   see how many plots they want
	;
	if (n_elements(pltmsk) eq 0) then pltmsk=1
	if  pltmsk eq 0 then pltmsk=1
	plttmp=pltmsk
	if (plttmp eq 0 ) then plttmp=1
	numplts=0
	pltit=indgen(4)
	for i=0,3 do begin
		if (plttmp and 1) then pltit[i]=1 else pltit[i]=0
		numplts=numplts + pltit[i]
		plttmp=ishft(plttmp,-1)
	endfor
	if (numplts gt 2) then across=2 else across=1
	if (numplts gt 1) then down=2 else down=1
	!p.multi=[0,across,down]
	title=1
	if (numplts gt 2) then title=-1
	if pltit[0] then begin
		bmapazccon,hdr[0],mapa[*,*,0],nlevels,dbstep,1,0,dotitle=title
		title=0
	end
	if pltit[1] then begin
		bmapazccon,hdr[0],mapb[*,*,0],nlevels,dbstep,1,1,dotitle=title
		title=0
	end
	if pltit[2] then begin 
		bmapazccon,hdr[1],mapa[*,*,1],nlevels,dbstep,1,0,dotitle=title
		title=0
	end
	if pltit[3] then begin 
		bmapazccon,hdr[1],mapb[*,*,1],nlevels,dbstep,1,1,dotitle=title
		title=0
	end
	return
end
