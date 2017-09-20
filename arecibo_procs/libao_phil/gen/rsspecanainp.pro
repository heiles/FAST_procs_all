;+
;NAME:
;rsspecanainp - input R&S spectrum from save file
;SYNTAX: npnts=rsspecanainp(fname,frq,spc,info=info,/print)
;ARGS:
;   lun:    open to xxx.txt file.. form export trace .txt mode (tabs)
;  print:   if set the print out the ascii info header as it is read in.
;RETURNS:
;   npnts : 0  trouble reading file
;           501  points found
;   frq[501]: freq of trace 1 in mhz
;   spc[501]: spectra trace 1 in dbm
;   info[28] : string return the 28 ascii info lines read from the file.
;
;DESCRIPTION:
;   The Rhode and Schwartz spectrum analyzer can save its
;trace data in a text file. This routine will input the text file and
;return the spectra and frequency.
;   The steps in getting at trace from the ybt250 to idl is:
; . in idl 
;   @phil
;   openr,lun,filename,/get_lun
;   npnts=rsspecanainp(lun,spc1,frq1,info=info,/print)
; The
;-
function rsspecanainp,fname,frq,spc,info=info,print=print
;
;
; read in the ascii files
;
	nlines=readasciifile(fname,inpL)
;
;	check file type
;
	ltype='Type;ZVL-13;'
	a=strcmp(inpL[0],ltype)
	if (not a[0]) then begin
		print,'1st line. expected:',ltype,' got:',a[0]
		return,0
	endif
;
; 	get number of data values
;
	indVal=28-1
	a=strsplit(inpL[indVal],';',/extract)
	if (a[0] ne "Values") then begin
		print,"Line 28 should be: Values..., found:",inpL[indVal]
		return,0
	endif
	npnts=long(a[1])
;
;	check if correct file
	if nlines ne (28+npnts) then begin
		print,"expected 28+",npnts," lines. but read:",nlines
		return,0
	endif
    info=inpL[0:27]
;
;   check that the data read in ok:
;
    if (strmid(info[3],0,13) ne 'Mode;ANALYZER')  then begin
        print,'Incorrect line. Expected: Mode;ANALYZER..got:',$
				strmid(info[3],0,13)
        return,0
    endif
;
; split the freq, data
;
	a=stregex(inpL[28:*],'([^;]*);([^;]*)',/extract,/subexpr)
	frq=reform(double(a[1,*]))*1d-6
	spc =reform(double(a[2,*]))
	if (keyword_set(print)) then begin
		for i=0,27 do print,format='(i3,1x,a)',i,info[i]
	endif
	return,npnts
end
