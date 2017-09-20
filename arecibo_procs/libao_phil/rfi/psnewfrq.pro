;
; punta salinas new freq
; generate and array with their freq
;  frq[nchan,2]  2 is the actual xmit freq
; the otherRd  is a list of the carsr radar
; the ok[] array has 1 if the xmitter ps freq
; center are at least bw away from the center of each carsr
; freq. currently set to 2 mhz.
;
ofile='/home/phil/psfreqnew.html'
nchn=100
chnl=fltarr(nchn)
chnl[0:14]=findgen(15) + 1223
chnl[15:85]=findgen(85-15+1)*2 + 1239
chnl[86:99]=findgen(99-86+1)   + 1380.
frq=fltarr(nchn,2)
frq[*,0]=chnl-7.5
frq[*,1]=chnl+7.5
;for i=0,nchn-1 do print,i+1,frq[i,0],chnl[i],frq[i,1],$
;		format='(i3,1x,f6.1,1x,f6.1,1x,f6.1)'

otherRd=[$
[1252.41,1257.59,1344.41,1349.59],$; faa
[1269.41,1275.58,1327.41,1332.59]]
;
otherRd=reform(otherRd,n_elements(otherRd))

; carsr 1 Mhz bw, puntasalins about 1 Mhz
;  so make cfr ps 1.5 Mhz from carsr center 
bw=2.
ok=intarr(nchn) + 1
for i=0,nchn-1 do begin &$
	iibad=where((abs(frq[i,0] - otherRd) lt bw ) or $
	            (abs(frq[i,1] - otherRd) lt bw ),cnt) &$
	if cnt gt 0 then ok[i]=0 &$
endfor
ii=where(ok eq 0,cntbad)
excl=intarr(100) 
excl[0:11]=1
excl[87:99]=1
;" 13 1227.5 1235.0 1242.5   1
openw,lunout,ofile,/get_lun
otherRd=reform(otherRd,2,4)
tdS="<td>"
tdE="</td>"
tdES=tdE + tdS
trS="<tr>"
trE="</tr>"


printf,lunout,'FAA freq:'
printf,lunout,otherRd[0,0],otherRd[1,0],format='(3x,f6.1,1x,f6.1)'
printf,lunout,otherRd[0,1],otherRd[1,1],format='(3x,f6.1,1x,f6.1)'
printf,lunout,'PuntaBorinquen freq:' 
printf,lunout,otherRd[0,2],otherRd[1,2],format='(3x,f6.1,1x,f6.1)'
printf,lunout,otherRd[0,3],otherRd[1,3],format='(3x,f6.1,1x,f6.1)'
printf,lunout," "

lab=trS + tdS + "num" + tdES + "cfr"   + tdes + "txLow" + $
	                    tdes + "txHi"  +tdes  + "CarsrFrq=1" + tdE + trE
printf,lunout,"<table>"
printf,lunout,lab
for i=0,nchn-1 do begin
;	if (excl[i] eq 0) then begin
		printf,lunout,trS,tdS,i+1,tdES,chnl[i],tdES,frq[i,0],tdES,frq[i,1],$
		tdES,(ok[i] eq 1)?0:1,tdE,trE,$
format='(a,a,1x,i3,1x,a,1x,f6.1,1x,a,1x,f6.1,1x,a,1x,f6.1,1x,a,1x,i3,a,a)'
;	endif
endfor

printf,lunout,"</table>"
free_lun,lunout
end 
