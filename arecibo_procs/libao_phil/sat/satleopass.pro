;
; compute leo passes that come close to ao za range:
;
; for now just fill in the variables below
; ------------------------------------------
; start modify
tlefile='radar.tle'
yymm00=130300
day1=8
day2=10
hhmmss=010000D
minza=19	
; end modify
;----------------------------------------------
;
ltit1="yyyymmdd hh:mm:ss   az    za      range SatName"
ltit2="       UTC          src            Km"
;
; keep track of last pass plotted so we don't make multiple copies
;
a={ satNm:'',$
	hhmmss:0L,$ last pass
	jd    :0D$  last pass
  } 
maxSat=30
passOut=replicate(a,maxsat)

;  if pass time differs by 10 minutes assume same
;  problem is i'm keying off of min za in sample points
;  but sample points don't  always give the abs minimum
;  so orbits computed starting 1 hour apart may come up with
;  different minimum za's.
;
epssec=10*60.
print,ltit1
print,ltit2
print," "
for day=day1,day2 do begin
;	print,'start day:',day
	yymmdd=yymm00 + day	
	for hr=1,23 do begin &$
!p.multi=0 &$
		satpassplt,yymmdd=yymmdd*1D,hhmmss=hr*10000D,satAr=satAr,tlefile=tlefile &$
;
;	check for anything za < 19
;
		nsat=n_elements(satar)
		for i=0,nsat-1 do begin
			ii=where(satar.zamin lt minZa,cnt)
			if cnt gt 0 then begin
				for j=0,cnt-1 do begin
			 		k=ii[j]
					n=satar[k].npnts
				    eps=.01
					jj=where(abs(satar[k].p[0:n-1].za -satar[k].zamin) lt eps,cnt1)
					if cnt1 eq 0 then begin
						print,"No zaMin day,hr,satNm:",day,hr,satar[k].satnm 
						stop
					endif else begin
;
;						make sure we don't reprint the same passes.
;
						if cnt1 gt 0 then begin
							minVal=min(satar[i].p[jj].za,ind)
							jj=jj[ind]
						endif
						satNm=satar[k].satNm
						p=satAr[k].p[jj]
						caldat,p.jd,mon,dayl,yr,hrl,min,sec
						hhmmss=hrl*10000L + min*100L + sec
						il=where(passOut.satNm eq satNm,cntNm)
						if (cntNm ne 0) then begin 
						    if (abs(passOut[il].hhmmss - hhmmss) lt epssec) then continue
						    passOut[il].hhmmss=hhmmss
						endif else begin
							il=where(passOut.satNm eq '',cnt)
							if cnt eq 0 then begin
								print,"Too many satellites.. increase maxSat variable"
								stop
						    endif
							il=il[0]
							passOut[il].satNm=satNm
							passOut[il].hhmmss=hhmmss
							passOut[il].jd=p.jd
						endelse
						jdDif=(p.jd - passout[il].jd)*1440.
						az=satar[k].p[jj].az
						za=satar[k].p[jj].za
						rng=satar[k].p[jj].rangeKm
						line=string(format=$
			  '(i04,i02,i02,1x,i02,a,i02,a,i02,1x,f6.1,1x,f6.2,1x,f7.0,1x,a)',$
						yr,mon,dayl,hrl,":",min,":",sec,az,za,rng,satar[k].satNm)
						print,line
					    passout[il].jd=p.jd
					endelse
				endfor
			endif
		endfor
	endfor
endfor
end
