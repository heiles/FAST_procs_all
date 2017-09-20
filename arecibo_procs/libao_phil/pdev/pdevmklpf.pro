;+
;NAME:
;pdevklpf - make pdev low pass filter
;SYNTAX: istat=pdevmklpf(filterType,dec,filter,fbase=fbase)
;ARGS:
;filterType:string  filter type to use. values can be:
;                   'rect'      
;                   'hamming'   
;                   'hanning'  
;                   'blackman'  
;                   'bartlett'  
;                   'tri'       
; 
;dec: int			decimation 2..1024
;KEYWORDS:
;fbase: string		/dir/baseFilename to store the filter data
;                   The program will add the .0,.1,.2.,3 for
;                   the 4 files. If this keyword is not
;                   supplied, then temp files:
;                   /tmp/pdevmklpf.pid.dec.n will be created
;                   and later deleted.
;RETURNS:
;istat	: it		= 0  ok
;                   -1 illegal filterType
;                   -2 illegal decimation
;                   -3 trouble creating file
;                   -4 trouble reading in file we created
;
;filter[4*dec]: float  filter (in voltage).
;-
;                     
;-
function pdevmklpf,filtType,dec,filter,fbase=fbase
;
;   check fileType
;
	delFile=0
	fbaseL=''
	ftypeAr=['rect','hamming','hanning','blackman','bartlett','tri']       

	retStat=0
	fileCreated=0
	ii=where(filttype eq ftypeAr,cnt)
	if cnt eq 0 then begin
		print,"Illegal filter type request:",filtype
		print,"Legal values:",ftypeAr
		retStat=-1
	 	goto,errout
	endif
	if ((dec lt 2 ) or (dec gt 1024)) then begin
		print,"Illegal decimation. values are 2..1024"
		retStat=-2
	 	goto,errout
	endif
	if n_elements(fbase) eq 0 then begin
		spawn,"echo $$",retval
		ival=randomn(seed,/long) mod 1000L
		fbase="/tmp/pdevmklpf." + retval
		delFile=1
	endif
	case 1 of   &$
	((dec ge 2) and (dec lt 10)): ldec=string(format='(i1)',dec) &$
	((dec ge 10) and (dec lt 100)): ldec=string(format='(i2)',dec) &$
	((dec ge 100) and (dec lt 1000)): ldec=string(format='(i3)',dec) &$
	(dec ge 1000) : ldec=string(format='(i4)',dec) &$
	endcase
		
	cmd=aodefdir() +  "etc/bin/pnet_mkdlpf_coeff --dec=" +ldec + " --window="+filttype + $
		" --fn=" + fbase
	errResult=''
	spawn,cmd,retval,errResult
	if errresult ne '' then begin
		print,"Error callinng pnet_mkdlpf_coef:" + errResult
		retStat=-3
	 	goto,errout
	endif
	createdFile=1
;
; 	now input the file
;
	fbaseL=fbase + string(format='(".",i04)',dec)
	istat=pdevinplpf(fbaseL,filter)
	
	if (istat ne 0) then begin
		retStat=-4
		print,"Error inputting filter file"
		goto,errout
	endif
	filter/=32768.
;
; 	now delete file
;
errOut:
	if (fileCreated and $
		((delFile eq 1) or (retStat ne 0))) then begin
		cmd="rm -f " + fbaseL + "*"
	    spawn,cmd,retval,errResult
	endif
return,0
end
