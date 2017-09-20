;+
;fitazzaprall - print/plot fits for a single receiver. all freq, all pol
;
;-
pro fitazzaprall,fitI,prcoef=prcoef,pol=pol
;
	if n_elements(prcoef) eq 0 then prcoef=0
	if n_elements(pol) eq 0 then pol=3
	s=size(fitI)
	if s[0] eq 1 then begin
		nbrds=1
	endif else begin
		nbrds=s[2]
	endelse
	first=1
	lnA=3
	lnB=20
	frqlab='frqs:'
	for i=0,nbrds-1 do begin
			ln1=lnA
			ln2=lnB
			if (pol eq 1) or (pol eq 3) then $
			fitazzapr,fitI[0,i],over=i,ln=ln1,nocoef=(i ne prcoef),/nosigma
			if (pol eq 2) or (pol eq 3) then $
			fitazzapr,fitI[1,i],over=1,ln=ln2,nocoef=(i ne prcoef),/nosigma
			frqlab= frqlab + string(format='(f6.0)',fitI[0,i].freq)
	endfor
	note,lnA+5,frqlab,xp=.66
	return
end
