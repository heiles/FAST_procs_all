;+
;NAME:
;lrdist3inp - input the coef for the 3 distomat fits
;SYNTAX: istat=lrdist3inp(fitI,yymmdd=yymmdd,fname=fname)
;KEYWORDS:
;yymmdd: long   date for data. If not supplied use
;               current date. The coefs can be updated
;               occasionally.
;fname: string  filename for the coef. If not supplied
;               use the default name.
;RETURNS:
;istat:int      0 ok
;               -1 error inputing file
;               -2 no data for requested date
;fitI: {}       holds fitinfo
;
;DESCRIPTION:
;   Input the coef's used to fit the avg plat height to 3 distomat 
;distances.
;
;-
function lrdist3inp,fitI,yymmdd=yymmdd,fname=fname 
;
	forward_function readasciifile
	fitI={$
		date: 0L, $;	for coef
		c135:dblarr(2),$;
		c246:dblarr(2)}

	if n_elements(fname) eq 0 then begin
		fname=aodefdir() + "data/lrfit3.dat"
	endif
	lyyyymmdd=21000000L
	if n_elements(yymmdd) eq 1 then lyyyymmdd=yymdd
	if (lyyyymmdd / 10000L) lt 99 then lyyyymmdd+=20000000L

	n=readasciifile(fname,inp,comment=";")
	if n lt 3 then begin 
		print,"found no data in :",fname
		return,-1
	endif
	i=0
	while (i lt n) do begin
		if (strmid(inp[i],0,1) eq "!") then begin
			dateFile=long(strmid(inp[i],1,8))
			if (dateFile le Lyyyymmdd) then begin
				if (i+2) ge n then return,-2
				a=strsplit(inp[i+1],/extr)
				fitI.c135[0]=double(a[0])
				fitI.c135[1]=double(a[1])
				a=strsplit(inp[i+2],/extr)
				fitI.c246[0]=double(a[0])
				fitI.c246[1]=double(a[1])
			    fitI.date=dateFile
				return,0
			endif
		endif
		i++;
	endwhile
	return,-2
end
