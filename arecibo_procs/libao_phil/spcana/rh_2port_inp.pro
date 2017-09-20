;
; input rhode &schwartz 2 port network analyzer
; measurements
;
function rh_2port_inp,fname,naI,date,finp=finp
;
	n=readasciifile(fname,finp)
	if n le 0 then begin
		print,"no data input. istat=:",n
	    return,n
	endif
;
	ltype='! Rohde & Schwarz ZVL13 2Ports'
	irec=1
	astr={ freq:0D,$
		   s11 :dcomplex(0.,0.),$
		   s21 :dcomplex(0.,0.),$
		   s12 :dcomplex(0.,0.),$
		   s22 :dcomplex(0.,0.)$
		 }
	if strcmp(finp[irec],ltype,strlen(ltype)) eq 0 then begin
		print,"wrong file format:"
		print,"Expected:",ltype
		print,"Found:",finp[irec]
		return,-1
	endif
	irec=2
	a=stregex(finp[irec],"! Date: (.*)",/sub,/extr)
	date=a[1]
;
;	check freq order
;
	ltype='! FREQ   S11re   S11im   S21re   S21im    S12re   S12im    S22re   S22im'
	irec=3
	if (strcmp(finp[irec],ltype) ne 1) then begin
		print,"wrong file format:"
		print,"Freq Expected:",ltype
		print,"     Found:",finp[rec]
		return,-1
	endif

	icur=0
	regex=$
;          0       1        2        3        4         5        6        7      8  +1 for a[]
;         FREQ    S11re    S11im    S21re    S21im     S12re    S12im    S22re   S22im'
'^[^#!] *([^ ]*) *([^ ]*) *([^ ]*) *([^ ]*) *([^ ]*) *([^ ]*) *([^ ]*) *([^ ]*) *([^ ]*)'
	a=stregex(finp,regex,/sub,/ext)
	ii=where(a[0,*] ne '',cnt)
	naI=replicate(astr,cnt)
	i=1
	nai.freq=reform(double(a[1,ii])) 
	i=2
	nai.s11 =complex(reform(double(a[i,ii])),reform(double(a[i+1,ii])))
	i=4
	nai.s21 =complex(reform(double(a[i,ii])),reform(double(a[i+1,ii])))
	i=6
	nai.s12 =complex(reform(double(a[i,ii])),reform(double(a[i+1,ii])))
	i=8
	nai.s22 =complex(reform(double(a[i,ii])),reform(double(a[i+1,ii])))
	return,cnt
end 
