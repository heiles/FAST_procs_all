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
for i=0,n_elements(flux) - 1 do begin
	ind=where(flux[i].name eq sflux.name,count)
	if count eq 1 then begin
		if flux[i].notes ne sflux[ind].notes then begin
			a=string(format='(a8,1x,a)',flux[i].name,flux[i].notes)
			print,a
			a=string(format='(9x,a)',sflux[ind].notes)
			print,a
		endif
	endif
endfor
end
