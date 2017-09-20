;+
; calratiopr - output cal ratio to fd
;-
pro	calratiopr,rcvnum,cali,fd
;
;'	(tsysMeasured/tsysavg)(daynum)  = ratio + slope*daynum '
;rcv freq  cal# pol  ratio   slope     sigma calMeas calCmp %change diode
;ddd dddd.   d   s  dd.ddd  dd.dde-dd  d.ddd ddd.dd  ddd.ddd  ddd.d   d
;
	if n_elements(fd) eq 0 then fd=-1

	printf,fd,$
'fit ratio(daynum)=[tsysMeasure/tsysavg] = constant + slope*dayNum '
	printf,fd,$
format='("daynum:",f4.0," to ",f4.0," evaluate table at last daynum")',$
		cali[0].date1,cali[0].date2

	printf,fd,$
'rcv freq  cal# pol  ratio  slope     sigma calMeas calCmp %change diode'
	diode=[1,2,2,1,1,1,2,2,1,2,2,1,1,1,2,2]

	for i=0,7 do begin
		for j=0,1 do begin
			pol='A'
			if j eq 1 then pol='B'
		line=string(format=$
'(i3," ",f5.0,"   ",i1,"   ",a1,"  ",f6.3," ",e9.2,"  ",f5.3," ",f6.2," ",f7.3,"  ",f5.1,"   ",i1)',$
	rcvnum,cali[i].freq,cali[i].calnum,pol,cali[i].tsysratio[j],$
	cali[i].slopeDay[j],cali[i].sigratio[j],cali[i].calvalm[j],$
	cali[i].calvalC[j],100.*(cali[i].calvalC[j]-cali[i].calvalM[j])/$
		cali[i].calvalM[j],diode[i*2+j])
		printf,fd,line
		endfor
		if i eq 3 then begin
			printf,fd,$
'  -------------------------------------------------------------------'
		endif
	endfor 
	printf,fd,' '
	return
end
