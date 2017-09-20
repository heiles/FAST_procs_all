;+
;NOTE:
;p12m_menuadr - generate file holding menu names and adresses.
;ARGS:
;menuNum: int   1..22 menu numbers
;KEYWORDS:
;sadr    : string a string specifying the parameters to include for this menu
;                 this lets you specify random params: 
;                 eg: '0 1 2 5 6 8 23'
;                    or 'max nn' will generate from 0 to nn
;maxParam: int    if specified then generate 0 to maxparam parameter numbers
;outDir  : string  directory to output to. def is  ./
;DESCRIPTION:
;	Generate ascii file holding menu.param and address (one per line).
;this file can be input to dump_adr to read the menu contents from the drive.
;-
function  p12m_menuadr,menuNum,sadr=sadr,maxParam=maxParam ,outDir=outDir
;
    if n_elements(maxParam) eq 0 then maxParm=51
    if n_elements(outDir) eq 0 then outDir='./'
	iparamAr=lindgen(maxParm+1)
	if n_elements(sadr) eq 1 then begin
		a=strsplit(sadr,/extrac)
		if (strlowcase(a[0]) eq 'max') then begin
			ival=long(a[1])
			iparamAr=lindgen(ival+1)
		endif else begin
			n=n_elements(a)
			iparamAr=lonarr(n)
			for i=0,n-1 do iparamAr[i]=long(a[i])
		endelse
	endif
	outDirL=outDir
	if strmid(outDirL,0, 1,/reverse_offset) ne "/" then outDirL+='/'
	outFile=outDirL + string(format='("p12m_menu_",i02,".dat")',menuNum)
	openw,lun,outFile,/get_lun
	code32='4000'xL
	for i=0,n_elements(iparamAr)-1  do begin
		iparam=iparamAr[i]
		adr=code32 + menuNum*100L + iparam - 1
		ln=string(format='(i02,".",i02,2x,i6)',menuNum,iparam,adr)
		printf,lun ,ln
	endfor
    free_lun,lun
	return,1
end
