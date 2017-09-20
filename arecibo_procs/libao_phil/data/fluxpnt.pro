;
; create a file that has the positions and the flux
; for fluxsrc.dat
;
file1='/share/obs4/usr/x102/cat/calib.cat'; from chris x102
file2='/share/obs4/usr/aoui/calib.cat'    ; aoui
file3='/pkg/rsi/local/libao/phil/data/fluxsrcotherpos.dat'
;
; input the catalogs
;
nsrc1=cataloginp(file1,2,cat1)
nsrc2=cataloginp(file2,2,cat2)
nsrc3=cataloginp(file3,2,cat3)
;
; open fluxsrclist.
;
fileIn ='/pkg/rsi/local/libao/phil/data/fluxsrc.dat'
fileOut='/pkg/rsi/local/libao/phil/data/fluxsrcpos.dat'
openr,lunin,fileIn,/get_lun
openw,lunout,fileOut,/get_lun
inp=''
while (not eof(lunin)) do begin
	readf,lunin,inp
	if strmid(inp,0,1) ne 'B'  then begin
		printf,lunout,inp
	endif else begin
	 indAr=strsplit(inp,len=lenAr)
	 src=strmid(inp,0,lenAr[0])
	 restline=strmid(inp,lenAr[0])
	 restline=strtrim(restline,1)
;
; find the source in the two catalogs 
;	
	ind1=where(src eq cat1.name,count1)
	ind1=(count1 gt 0)?ind1[0]:ind1
	ind2=where(src eq cat2.name,count2)
	ind2=(count2 gt 0)?ind2[0]:ind2
	ind3=where(src eq cat3.name,count3)
	ind3=(count3 gt 0)?ind3[0]:ind2
;
;	 check that two positions are the 
;
    epsDeg= 1./3600.			; same to 1 asec..
	catToUse=0 	;		none yet	
	mismatch=0  ;
	case 1 of
		(count1 gt 0) and (count2 gt 0) : begin
			if ((abs(cat1[ind1].rah  - cat2[ind2].rah)*15 gt epsDeg) or $
		    (abs(cat1[ind1].decD - cat2[ind2].decD) gt epsDeg)) then begin
				errRa =(cat1[ind1].rah  - cat2[ind2].rah)*15.*3600.
		        errDec=(cat1[ind1].decD - cat2[ind2].decD)*3600.
				errDeRa=(cat1[ind1].rah  - cat2[ind2].rah)*15.*3600.
				  lab=string(format=$
	 '(a," position mismatch in two files errs ra,dec (asec):",f6.2,1x,f6.2)',$
						src,errRa,errDec)
					print,lab
			endif
			catToUse=1
			end
		(count1 gt 0) : catToUse=1
		(count2 gt 0) : catToUse=2
		(count3 gt 0) : catToUse=3
		else          : begin
			print,src,' not found either catalog'
			goto,botloop
			end
		
	endcase
	case catToUse  of
		1 : begin
			raH =cat1[ind1].raH
			decD=cat1[ind1].decD
			dsign=cat1[ind1].decsgn
		end
		2 : begin
			raH =cat2[ind2].raH
			decD=cat2[ind2].decD
			dsign=cat2[ind2].decsgn
		end
		3 :  begin
			raH =cat3[ind3].raH
			decD=cat3[ind3].decD
			dsign=cat3[ind3].decsgn
		end
	endcase
	raFmt =fisecmidhms3(raH*3600D ,/nocol,/float)
;
; 	fix sign of dec
;
	decFmt=fisecmidhms3(decD*3600D,/nocol,/float)
	decFmt=(dsign lt 0)?"-"+decFmt:' '+decFmt
	outLine=string(format=$
'(a," ",a," ",a," ",a)',src,raFmt,decFmt,restLine)
	printf,lunout,outLine
	endelse
botloop:
	endwhile
	free_lun,lunin
	free_lun,lunout
end
