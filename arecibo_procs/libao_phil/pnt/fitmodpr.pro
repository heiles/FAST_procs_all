;+
; fitmodpr - print the output from fitmodel..
;-
pro fitmodpr,modI,lun=lun,enc=enc,model=model,ln=ln,xp=xp,donote=donote,$
			 scl=scl
;
	note=0
	if keyword_set(donote) then begin
		note=1
		if n_elements(ln) eq 0 then ln=3
		if n_elements(xp) eq 0 then xp=.02
		if n_elements(scl) eq 0 then scl=1
	endif
	mLab=strarr(13)
	mlab[0]='constant'
	mlab[1]='cos(az)'
	mlab[2]='sin(az)'
	mlab[3]='sin(za)'
	mlab[4]='sin(za)**2'
	mlab[5]='cos(3az)'
	mlab[6]='sin(3az)'
	mlab[7]='sin(za-balance)*cos(3az)' 
	mlab[8]='sin(za-balance)*sin(3az)'
	mlab[9]='cos(2az)'
	mlab[10]='sin(2az)'
	mlab[11]='cos(6az)'
	mlab[12]='sin(6az)'
	ncnt=0


	if n_elements(lun) eq 0 then lun=-1
;
; 	output model coef..
;
	if keyword_set(model) then begin
;
;                   ffffff.ff (+/- fff.ff) ffffff.ff 
	    lab='    az         za    model coefficients'
		printf,lun,lab
		if note then begin
			note,ln+ncnt*scl,lab,xp=xp
			ncnt=ncnt+1
		endif
		for i=0,modI.model.numelm-1 do begin
			lin=string(format=$
			  '(f9.2," ",f9.2,"  ",a)',$
				modI.model.azc[i],modI.model.zac[i],mlab[i])
			printf,lun,lin
			if note then begin
				note,ln+ncnt*scl,lin,xp=xp
				ncnt=ncnt+1
			endif
		endfor
		printf,lun,' '
;;		if note then ncnt=ncnt+1
	endif
;
; 	output encoder table
;
	if keyword_set(enc) then begin
		lab='    az        za    deg  encoder table'
		printf,lun,lab
		if note then begin
			note,ln+ncnt*scl,lab,xp=xp
			ncnt=ncnt+1
		endif
		for i=0,40 do begin
			lin=string(format='(f9.2," ",f9.2," ",f6.2)',$
				modI.model.enctblaz[i],modI.model.enctblza[i],i*.5)
			printf,lun,lin
			if note then begin
				note,ln+ncnt*scl,lin,xp=xp
				ncnt=ncnt+1
			endif
		endfor
		printf,lun,' '
		if note then ncnt=ncnt+1
	endif
;npts chisqaz chisqza rmsAz  rmsZa  rmsTot  model
;                     rmsAz  rmsZa  rmsTot
;                     ' 
;dddd ccccc.c ccccc.c xxx.xx xxx.xx xxx.xx xxx.xx xxx.xx xxx.xx
;
	lab="npts chisqaz chisqza rmsAz  rmsZa  rmsTot"
	printf,lun,lab
	if note then begin
		note,ln+ncnt*scl,lab,xp=xp
		ncnt=ncnt+1
	endif
 	lin=string(format=$
'(i4," ",f7.1," ",f7.1," ",f6.2," ",f6.2," ",f6.2," model")',$
   modI.npntsInp,modI.chisq[0],modI.chisq[1],$
   modI.rmsmod[0],modI.rmsmod[1],sqrt(modI.rmsmod[0]^2+modI.rmsmod[1]^2))
	printf,lun,lin
	if note then begin
		note,ln+ncnt*scl,lin,xp=xp
		ncnt=ncnt+1
	endif

 	lin=string(format=$
'("     ","        ","        ",f6.2," ",f6.2," ",f6.2," model + encTable")',$
   modI.rmstot[0],modI.rmstot[1],sqrt(modI.rmstot[0]^2+modI.rmstot[1]^2))
	printf,lun,lin
	if note then begin
		note,ln+ncnt*scl,lin,xp=xp
		ncnt=ncnt+1
	endif
	return
end
