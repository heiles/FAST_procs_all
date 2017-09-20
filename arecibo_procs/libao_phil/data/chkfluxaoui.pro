;
; check aoui file
;
aouiFile='/share/obs4/usr/aoui/calib.cat'
aouiFileL='calib.cat'
format=2
naoui=cataloginp(aouiFile,format,aoui,com='#')
;
print,'compare ' + aouiFile + ' and /share/mani2/csalter/idl/flux/calibrators'
;
fluxsrcload,sflux,/salter
fluxsrcload,pflux
;
;get the flux,comments from aoui
;
coefAoui =fltarr(3,naoui)
notesAoui=strarr(naoui)
for i=0,naoui-1 do begin &$
	toks=strsplit(aoui[i].eol,/extract) &$
	ind=where(toks eq 'flux:',count) &$
	if count eq 0 then begin &$
		print,aoui[i].name + ' has no flux coef in ' + aouiFileL &$
	endif else begin &$
		coefAoui[*,i]=float(toks[ind[0]+1:ind[0]+3]) &$
	endelse &$
endfor
;
; check if calib.cat has duplicates
;
ind=uniq(aoui.name,sort(aoui.name))
if n_elements(ind) ne naoui then begin &$
	for i=0,naoui-1 do begin &$
	    ii=where(i eq ind,count) &$
		if count eq 0 then print,aoui[i].name+' duplicate name in '+ aouiFileL&$
	endfor &$
endif
;
; check if repeated sources in sflux
;
ind=uniq(sflux.name,sort(sflux.name))
if n_elements(ind) ne n_elements(sflux) then begin &$
    for i=0,n_elements(sflux)-1 do begin &$
        ii=where(i eq ind,count) &$
        if count eq 0 then print,sflux[i].name + ' repeated in salter file' &$
    endfor &$
endif
;
; now verify that coefs match salter file, aoui file
;
for i=0,n_elements(sflux) - 1 do begin &$
    ind=where(sflux[i].name eq aoui.name,count) &$
    if count gt 2 then print,sflux[i].name+ 'occurs multiple times in ' +$
				aouiFileL &$
    if count le 0 then begin &$
;
;      see if it is a variable in phils file
;
		jj=where(pflux.name eq sflux[i].name,cjj)
        lcode=(cjj gt 0)?pflux[jj[0]].code:0
        print,sflux[i].name + ' not in ' + aouiFileL + 'Flux code:' + string(lcode) &$
    endif else begin &$
        if total(abs(coefAoui[*,ind[0]])) ne $
			total(abs(sflux[i].coef)) then begin &$
            print,sflux[i].name + ' coef mismath salterfile, ' + aouiFileL &$
        endif &$
    endelse &$
endfor
;
; check which sources in aouiFile not in salter file
;
for i=0,naoui - 1 do begin &$
    ind=where(aoui[i].name eq sflux.name,count) &$
    if count le 0 then begin &$
    	print,aoui[i].name + ' not in salter file' &$
    endif &$
endfor
end
