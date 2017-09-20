;
; get some laser ranging data for a jd range..
; doesn't cross year boundary
; @lrinit before running
;
function gettdlr,yymmdd,d,ndays=ndays
;
;  convert mjd to jd then shift to ast base from gmt
;
	forward_function lrpcinprange
	if n_elements(ndays) eq 0 then ndays=1

	astToUtc=4D/24D
	yymmdd1=yymmdd
	yr=yymmdd1/10000L + 2000L
	mon=yymmdd1/100L mod 100L
	day=yymmdd1 mod 100L
	dayno1=dmtodayno(day,mon,yr)
;
	dayno2=dayno1+ndays -1
	maxDay=(isleapyear(yr))?366L:365L
	if dayno2 gt maxday then begin
		print,"gettrlr can't cross year boundary)"
		return,-1
	endif
;
	
	dm=daynotodm(dayno2,yr)
	yymmdd2=yr*10000L + dm[1]*100 + dm[0]
;
; 	get the lrpc data
;
;  get the lr data then create subset matching mm data
;
	istat=lrpcinprange(yr,yymmdd1 mod 10000L,yymmdd2 mod 10000L,lrd)
	nlr=n_elements(lrd)
;
	yrAr=lonarr(n_elements(lrd))+yr
	lrJd=(daynotojul(lrd.date,yrAr) +  astToUtc)
	day1=long(lrd[0].date) 
	day2=long(lrd[nlr-1].date) 
;
; now the tiedown data
;
	for id=day1,day2 do begin &$
		aa=daynotodm(id,yr[0]) &$
	    d=aa[0] &$
		m=aa[1] &$
		yymmdd=(yr[0] mod 100L)*10000L + m*100L + d &$
		n=tdinpday(yymmdd,td1) &$
	    aa=yymmddtojulday(yymmdd*1D) + td1.secM/86400D + astToUtc &$
		if (id eq day1) then begin &$
				td=td1 &$
			    tdJd=aa &$
		endif else begin &$
				td=[td,td1] &$
			    tdJd=[tdJd,aa] &$
		endelse &$
	endfor
	a={jd	: 0D		,$ 
       dayno: 0D        ,$  ast
	   yr   : 0L        ,$  ast

      avgHPl: 0.        ,$  feet
	  tempPl: 0.        ,$  platform temp
	    dok : 0         ,$  1 if measurement ok
	   
	  avgHTd: 0.        ,$ avg td height inches
	  tdPos: fltarr(3)  ,$
	  tdKips: fltarr(2,3) $
	}
	d=replicate(a,nlr)
	d.jd  =lrJd 
	d.dayno= lrd.date
	d.yr    = yrAr
	d.avgHPl=lrd.avgH
    d.tempPl=lrd.tempPl
    d.dok   =lrd.dok

	avgHTd=total(td.pos,1)/3.
	d.avgHtd =interpol(avgHTd,tdJd,lrJd)
	for i=0,2 do d.tdpos[i]=interpol(td.pos[i],tdJd,lrJd)
	for i=0,5 do d.tdkips[i]=interpol(td.kips[i],tdJd,lrJd)
	return,nlr
end
