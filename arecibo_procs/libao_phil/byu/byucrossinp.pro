;+
;NAME:
;byucrossinp : input cross data from cor file.
;SYNTAX:
;ncross=byucrossinp(lun,bar,crossInAr,startscan=startscan,npat=npat)
;ARGS:
;lun:	int	logical file from openr
;RETURNS:
;ncross: int  number of crosses found
;bar[120,ncross]:{} cor structures holding data for each cross
;				 	  azstrip[0:59],zastrip[60:119]
;crossIAr[ncross]: info on each cross srcname,azcen,zacen,and position
;                  offsets.
;Note: the source name is generated from the ra,dec. it will be wrong
;for negative decs (+ sign instead of - and probably the deg is wrong.)
;-
function byucrossinp,lun,bar,crossIAr,startscan=startscan,npat=npat 
;
	forward_function corget,corgetm
 	rew,lun
	slAr=getsl(lun)
	if n_elements(startscan) eq 1 then begin
		ii=where(slar.scan eq startscan,cnt)
		if cnt ne 1 then begin
			print,"byucrossinp err: startscan:",startscan," not in file"
			return,0
		endif
		slar=slar[ii:*]
	endif
	if n_elements(npat) eq 1 then begin
		n=npat*2
	endif else begin
		n=n_elements(slar)
	endelse
	crossScans=lonarr(n)
	ncross=0
	gotaz=0
	for i=0,n-1 do begin
;
    	if ((slar[i].numrecs ne 60) || $
       		(slar[i].procname ne "corcross"))  then begin
        	gotaz=0
        	continue
    	endif
    	istat=corget(lun,b,scan=slar[i].scan,sl=slar[i])
    	if ((b.b1.h.proc.dar[1] lt 0.) and $
       		(b.b1.h.proc.dar[2] eq 0.) ) then begin
       		gotaz=1 
       		scanAz=slar[i].scan
       		continue
    	endif
    	if (gotaz) then begin
        	if ((b.b1.h.proc.dar[2] lt 0.) and $
        		(b.b1.h.proc.dar[1] eq 0.) ) then begin
        		crossScans[ncross]=scanAz
        		ncross++
        		gotaz=0
    		endif
		endif
	endfor
	if ncross eq 0 then return,0
	if ncross gt 0 then begin
		crossScans=crossScans[0:ncross-1]
	endif
	for i=0,ncross-1 do begin
		istat=corgetm(lun,120,b,scan=crossScans[i])
		if i eq 0 then bar=replicate(b[0],120,ncross)
		bar[*,i]=b
	endfor
a={ 	srcName     : '',$
		azCen       : 0.,$
		zaCen       : 0.,$
		posOffAzAmin: 0.,$ ;
	    posOffZaAmin: 0.}
	crossIAr=replicate(a,ncross)
	for i=0,ncross-1 do begin
		ra =bar[0,i].b1.h.pnt.r.reqPosRd[0]*!radeg
		dec=bar[0,i].b1.h.pnt.r.reqPosRd[1]*!radeg
;
;	Note .. negative decs will have the wrong sign..
;
		lra=strmid(fisecmidhms3(ra*3600/15.,/nocolon),0,4)
		a1=fix(dec)
		a2=fix((dec-a1)*10)
		ldec=string(format='(i02,i01)',a1,a2)
		crossiar[i].srcname="J"+lra+"+"+ldec
		crossiar[i].azCen  =bar[60,i].b1.h.std.azttd*.0001
		crossiar[i].zaCen  =bar[59,i].b1.h.std.grttd*.0001
		crossiar[i].posOffAzAmin =bar[0,i].b1.h.proc.dar[5]
		crossiar[i].posOffZaAmin =bar[0,i].b1.h.proc.dar[6]
	endfor
	return,ncross
end
