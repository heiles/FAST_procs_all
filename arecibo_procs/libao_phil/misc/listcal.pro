hybrid=0
freq=findgen(8)*100+1000
nfreq=n_elements(freq)
rcv=5
caltypelab=['lcorcal','hcorcal','lxcal','hxcal',$
			'luncorcal','huncorcal','l90cal','h90cal']  
openw,lunout,'junk.out',/get_lun
lhybrid=['out','in']
for hybrid=0,1 do begin
for j=0,7 do begin
caltype=j
printf,lunout,'... caltype:',caltypelab[j],' hybrid:',lhybrid[hybrid]
printf,lunout,'freq   polA    polB
for i=0,nfreq-1 do begin
	istat=calget1(rcv,caltype,freq[i],calval,hybrid=hybrid)
	lab=string(format='(f6.1," ",f6.3," ",f6.3)',freq[i],calval)
	printf,lunout,lab
endfor
endfor
endfor
free_lun,lunout
end
