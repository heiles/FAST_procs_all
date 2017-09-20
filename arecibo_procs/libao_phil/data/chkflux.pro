;
; check the latest flux from chris with the current fluxex in fluxsrc.dat
;
fluxsrcload,flux
fluxsrcload,sflux,/salter
;
; 
print,'compare fluxsrc.dat and' + '/share/mani2/csalter/idl/flux/calibrators'
j=0
; hold indices for those with different coefs.
;  [0,*] is index into chris file
;  [1,*] is index into fluxsrc.dat
inddif=lonarr(2,200)
;
; check if repeated sources in sflux
;
ind=uniq(sflux.name,sort(sflux.name))
if n_elements(ind) ne n_elements(sflux) then begin
	for i=0,n_elements(sflux)-1 do begin
	    ii=where(i eq ind,count) 
		if count eq 0 then print,sflux[i].name + ' repeated in salter file'
	endfor
endif

for i=0,n_elements(sflux) - 1 do begin
	ind=where(sflux[i].name eq flux.name,count)
	if count gt 2 then print,sflux[i].name+ 'occurs multiple times in flux.dat'
	if count le 0 then begin
		print,sflux[i].name + " not in fluxsrc.dat"
	endif else begin
		if total(abs(flux[ind[0]].coef)) ne total(abs(sflux[i].coef)) then begin
			print,sflux[i].name + ' coef mismath salterfile,fluxsrc.dat'
			inddif[0,j]=i			
			inddif[1,j]=ind[0]
			j=j+1
		endif else begin
			if flux[ind[0]].rms ne sflux[i].rms then $
				print,sflux[i].name + ' rms mismatch'
		endelse
	endelse
endfor
if j gt 0 then inddif=inddif[*,0:j-1]
;
; check that idldat does not have extra sources..
for i=0,n_elements(flux) - 1 do begin
	if strmid(flux[i].name,0,1) eq 'B' then begin
		ind=where(flux[i].name eq sflux.name,count)
		if count le 0 then begin
	print,flux[i].name + ' code:'+ string(flux[i].code) + ' not in salter file'
		endif
	endif
endfor
;
; plot out difference frequencies
;
freq=findgen(50)*200+200.
ln=3
xp=.02
for i=0,j-1 do begin &$
	col=i+1 &$
	nm=sflux[inddif[0,i]].name
	if i eq 0 then begin &$
		plot,alog10(freq),alog10(fluxsrc(nm,freq)),$
		color=colph[col],xtitle='log10 (freq [Mhz])',$
		ytitle='log10(flux [Jy])',$
title='source flux vs frequency for Csalters and idl flux files' &$
	endif else begin &$
		oplot,alog10(freq),alog10(fluxsrc(nm,freq)),color=colph[col] &$
	endelse &$
	note,ln+i,nm,xp=xp,color=colph[col] &$
endfor
note,ln+j,'solid line:chris salters file',xp=xp
note,ln+j+1,'dash  line:fluxsrc.dat',xp=xp
fluxsrcload,flux
for i=0,j-1 do begin &$
	col=i+1 &$
	nm=sflux[inddif[0,i]].name &$
	oplot,alog10(freq),alog10(fluxsrc(nm,freq)),color=colph[col],linestyle=2 &$
endfor
flag,alog10(1420.)
note,3,'<-- 1420Mhz',xp=.6
end
