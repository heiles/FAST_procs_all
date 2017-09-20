;+
;SYNTAX:  calratio,tsysmin,tsysmax,d,diode=diode
;ARGS:
;	d[]	: {tsysrec} data for 1 receiver all cals
;	i1  : cal index to compute 0..7
;	i0  : cal index for base
;
;
function calratio,tmin,tmax,d,diode=diode,step=step,over=over
;
; 	keep things within tsysmin,max... load in tr tsysrec...
;
	deg=1
	nsig=2.
	coef=fltarr(2)
	sig=fltarr(2)
	a={calratio,    calnum :      0       ,$;
                 freq:            0.      ,$;  freq mhz
				 date1:           0.,$; first daynum data
				 date2:           0.,$; last  daynum data
              calvalM: fltarr(2)    ,$; quoted
			tsysRatio: fltarr(2)    ,$; tsys/tsysbase
			slopeDay : fltarr(2)    ,$; when fitting ratio, fraction/day
			 sigRatio: fltarr(2), $;
		      calvalC: fltarr(2)}
	cali=replicate({calratio},8)
;
; 	compute the average cal value over all 8 cals for each pol by day.
;	weight by the cal value (since larger cals are more accurate)
;
	avgtsys=total(d.r.ct.tsysv*(d.r.ct.calv>1e-6),2);sum all cals each day 1 pol
	avgtsys[0,*]=avgtsys[0,*]/total(d.r.ct.calv[0] > 1e-6,1)	; sum cal values
	avgtsys[1,*]=avgtsys[1,*]/total(d.r.ct.calv[1] > 1e-6,1)
;	avgtsys=total(d.r.ct.tsysv,2)/8.
	for j=0,7 do begin
;
;		get rid of outliers
;
		cal =d.r.ct[j].tsysv
		ind1=where((cal[0,*] ge tmin) and (cal[0,*] le tmax) and  $
				   (avgtsys[0,*] ge tmin) and (avgtsys[0,*] le tmax) and $
				   (cal[1,*] ge tmin) and (cal[1,*] le tmax) and  $
				   (avgtsys[1,*] ge tmin) and (avgtsys[1,*] le tmax))
		tr=d.r[ind1]
		cal =tr.ct[j].tsysv
		stop
		base=avgtsys[*,ind1]
		nrecs=(size(ind1))[1]
		coli=[1,2,3,4,5,6,7,9]
		diodeind= [[0,1],[1,0],[0,0],[1,1],[0,1],[1,0],[0,0],[1,1] ]
		cali[j].calnum=j
		for i=0,1 do begin
		    r=reform(cal[i,*]/base[i,*])
			c=poly_fit(tr.date,r,deg,yfit,yband,sigma,double)
    		delta= r-yfit
			ind=where(abs(delta) le (nsig*sigma)) 
			c1=poly_fit(tr[ind].date,r[ind],deg,yfit1,yband,sigma1,/double)
			numind=(size(ind))[1]
			cali[j].freq=tr[ind[numind-1]].freq		; freq mhz
			cali[j].date1=tr[ind[0]].date		; first daynum
			cali[j].date2=tr[ind[numind-1]].date; last daynum
			cali[j].calvalM[i]=tr[nrecs-1].ct[j].calv[i]
			cali[j].tsysratio[i]=c1[0] + c1[1]*cali[j].date2
			cali[j].slopeDay[i] =c1[1]
			cali[j].sigratio[i] =sigma1
			cali[j].calvalC[i]= cali[j].calvalM[i]/cali[j].tsysratio[i] 
			sym=0
			if (j ge 4) then sym=0
			col=coli[j]
			if keyword_set(diode) then col=coli[diodeind[i,j]]
			if  i eq 0 then begin
				if (j eq 0) or keyword_set(over)  then begin
					plot,tr[ind].date,r[ind],color=col,psym=sym 
				endif else begin 
					oplot,tr[ind].date,r[ind],color=col,psym=sym
				endelse
			endif else begin
					oplot,tr[ind].date,r[ind],color=col,linestyle=0,psym=-1
			endelse
			oplot,tr[ind].date,yfit1,linestyle=0,color=col
			if keyword_set(step) then begin
				test=' '
				print,j,i
				read,'return or s to stop',test
				if test eq 's' then stop
		   endif
		endfor
	endfor
	return,cali
end
