;
newfile=0
if n_elements(fileo) ne 0 then begin
    if fileo ne file then newfile eq 1
endif else begin
     newfile=1
endelse
if newfile then begin
        free_lun,lun
        openr,lun,file,/get_lun
        rew,lun
        fileo=file
endif
toavg=50
toloop=100
spcar=fltarr(4096,3,2,toloop)
;
;   ... start of next 100 secs
; 
while 1 do begin
for i=0,toloop-1 do begin &$
istat=plasmacutoff(lun,spc1,spcH,spcN,spcLen=4096,toavg=toavg,freq=freq,/nonoise,$
        hdr=hdr1) &$
print,i,istat &$
if istat ne 1 then goto,done
spcAr[*,*,*,i]=spc1 &$
endfor
;
spcarN=spcar
meanlf=meanrob(spcar[3500:4000,1,0,*],sig=siglf)
meangr=meanrob(spcar[3500:4000,1,1,*],sig=siggr)
;
spcArN[*,*,0,*]= (spcArN[*,*,0,*] - meanlf)/siglf
spcArN[*,*,1,*]= (spcArN[*,*,1,*] - meangr)/siggr
!p.multi=[0,1,2]
ver,0,100
hor,-1,2
hor
ihgt=1
tm=fisecmidhms3(hdr1[0].std.time)
stripsxy,freq,reform(spcarN[*,ihgt,0,*],4096,toloop),0,0,/step,$
    xtitle='freq [Mhz]',ytitle='sigmas',title='linefeed ' + tm
stripsxy,reverse(freq),reform(spcarN[*,ihgt,1,*],4096,toloop),0,0,/step,$
    xtitle='freq [Mhz]',ytitle='sigmas',title='dome'
;
endwhile
done:
end
