;
pro windmkyr,year,d,stmon=stmon,endmon=endmon,plotit=plotit
	tosmo=31
	if not keyword_set(plotit) then plotit= 0
	if plotit then a=label_date(date_f="%D%M")
	mon1=(keyword_set(stmon))? stmon:1
	mon2=(keyword_set(endmon))? endmon:12
	for mon=mon1,mon2 do begin
		n=windmkmon(year,mon,d)
		if plotit then begin
			if n gt 2 then begin
				a=label_date(date_format="%D%M")
				tosmoL=(n lt 10*tosmo)?1:tosmo
				plot,d.jd-4/24D,smooth(d.vel,tosmoL),xtickf='label_date'
			endif else begin
				print,'no data for ',year,mon
			endelse
		endif 
	endfor
end
