;+
; fitmod - using the pointing errors, fit to a model
;
; SYNTAX: fitmod,azErr,zaErr,params
;
; fit the model:
;  a[0] + 
;  a[1]*cosAz                   + a[2]*sinAz + 
;  a[3]*sinZa                   + 
;  a[4]*sinza^2                 +
;  a[5]*cos3Az                  + a[6]*sin3Az + 
;  a[7]*sin(za-balance)*cos3az  + a[8]*sin(za-balance)*sin3az  
;  a[9]*cos2Az                  + a[10]*sin2Az + 
;  a[11]*cos6Az                 + a[12]*sin6Az 
;- 
; 
;
function fitmod_func,x,m
	common fitmodc,azrd,zard,balanceRd
	
	i=long(x+.5)
	az=azrd[i]
	za=zard[i]
	sinza=sin(za)
	sinzab=sin(za-balanceRd)
    cos3az=cos(3.D*az)
    sin3az=sin(3.D*az)
	return,[       [1.D]        , $
             [cos(az)]       ,[sin(az)],$
		     [sinza]         ,[sinza*sinza],$
		     [cos3az]        ,[sin3az],$
		     [sinzab*cos3az] ,[sinzab*sin3az],$
		     [cos(2.D*az)]   ,[sin(2.D*az)],$
		     [cos(6.D*az)]   ,[sin(6.D*az)]]
end
;+
; fitmod - fit model to az,zenith positions and pointing errors
;
; SYNTAX: fitmod,az,za,azErr,zaErr,modI,resAz,resZa
; ARGS:
;       az[npts] : flt/dbl azimuth positions degrees.
;       za[npts] : flt/dbl zenith  angle positions degrees.
;    azErr[npts] : flt/dbl azimuth errors (great circle) arc seconds. 
;    zaErr[npts] : flt/dbl zenith  angle errors (great circle) arc seconds.
;           modI : {modelInfo} return model data here
;   resAz[npts,2]: hold the residuals from the azimuth fits (asecs).  
;				   ind 0 (azErr-model), ind 1: azErr-(model+enctbl)
;   resZa[npts,2]: hold the residuals from the zenith angle fits (asecs).  
;				   ind 0 (zaErr-model), ind 1: zaErr-(model+enctbl)
; DESCRIPTION:
;   fit the data to the current model (13 parameters) this includes:
;  1. fit to the 13 parameter model. 
;  2. compute the residuals from the fit
;  3. compute the encoder table vs za for az, za
;  4. compute the residual from model+encTbl
;    The fit parameters, encoder table, rms's of fit are returned in
;    modI.
;-
; 14mar05 pjp001 .. put in check for no counts in bin. This will cause
;                   it to not abort, but the numbers you get out are
;                   probably not correct (it's evaluating the thing at
;                   the wrong values..
pro fitmod,az,za,azErr,zaErr,modI,resAz,resZa
;
	common fitmodc,azrd,zard,balanceRd
;
	modI={fitmodInfo}
	numCoef=13
	modI.model.numelm=numCoef
	modI.model.format='B'			; current format
	modI.npntsInp=n_elements(az)
    balancerd=!dtor * 9.15012D	; just in case structure changes..
	modI.model.balanceRd=balanceRd

 	azrd=az*double(!dtor)
 	zard=za*double(!dtor)
	x=dindgen(modI.npntsInp)
	resAz=dblarr(modI.npntsInp,2)
	resZa=dblarr(modI.npntsInp,2)
;
;	azimuth errors fit
;
	coef=svdfit(x,azErr,numCoef,chisq=chisq,sigma=sigma, singular=singular,$
			yfit=yfitaz,/double,function_name='fitmod_func')
	if singular ne 0 then begin
		print,'Warning..azfit had', singular,' singular coefficeints'
	endif
	resAz[*,0]=azErr - yfitaz
	modI.model.azC[0:numCoef-1]=coef
	modI.chisq[0]=chisq
    modI.coefSigma[0:numCoef-1,0]= sigma[0:numCoef-1]
	a=moment(resAz[*,0],sdev=stdev)
	modI.rmsmod[0]= stdev
;
;	zenith angle errors fit
;
	coef=svdfit(x,zaErr,numCoef,chisq=chisq,sigma=sigma,singular=singular,$
				   yfit=yfitza,/double,function_name='fitmod_func')
	if singular ne 0 then begin
		print,'Warning..azfit had', singular,' singular coefficeints'
	endif
	resZa[*,0]=zaErr - yfitza
	modI.model.zaC[0:numCoef-1]=coef
	modI.chisq[1]=chisq
    modI.coefSigma[0:numCoef-1,1]= sigma[0:numCoef-1]
	a=moment(resZa[*,0],sdev=stdev)
	modI.rmsmod[1]= stdev
;
; compute the encoder tables vs za for az,za.. every .5 degrees
; do piecewise linear fits, then evaluate fits at 0,.5,1,1.5,....20.
;
; use the reverse indices from the histogram.
; we get 41 histogram entries centered at:
; .25,.75,1.25,... 19.5, and 20.
;
	zastep=.5
	h=histogram(za,binsize=zastep,min=0.,max=20.,omin=minval,omax=maxval,$
		reverse_indices=rind)
;
; The encoder table is to be  evaluated at the values:  0,.5,1,1.5,...,19.5,20.
; - hist[i] hist[i+1]  straddles enc[i+1]
; - we need to do enc[0], enc[40] separately
;
	goodind=intarr(41)		; 1--> > 2 points in this bin
	lasthbin=-1
	for i=0,38 do begin
		bin1=i
		bin2=i+1
		if(h[bin1] lt 2) then begin
		   if (lasthbin lt 0) then goto,botloop; no starting bin
		   bin1=lasthbin
		endif
		while (h[bin2] lt 2) and  (bin2 lt 40) do bin2=bin2+1
		if h[bin2] lt 2 then goto,botloop
;
;	build the index array for fit
;
		ind=-1
		for j=bin1,bin2 do begin
            if h[j] ne 0 then $		; <pjp001> skip 0 bins 
			ind=[ind,rind[rind[j]:rind[j+1]-1]]
		endfor
		ind=ind[1:*]
		goodind[i+1]=1
		aAz=poly_fit(za[ind],resAz[ind,0],1)
		aZa=poly_fit(za[ind],resZa[ind,0],1)
;
;			evaluate the fit at the za in the middle
;
		modI.model.encTblAz[i+1]=aAz[0]+aAz[1]*zaStep*(i+1)
		modI.model.encTblza[i+1]=aZa[0]+aZa[1]*zaStep*(i+1)
botloop:
	endfor
	minind=min(where(goodind gt 0))
	maxind=max(where(goodind gt 0))
	for i=0,minind do begin
		modI.model.encTblAz[i]= modI.model.encTblAz[minInd]
		modI.model.encTblza[i]= modI.model.encTblza[minInd]
	endfor
	for i=maxind,40 do begin
		modI.model.encTblAz[i]= modI.model.encTblAz[maxInd]
		modI.model.encTblza[i]= modI.model.encTblza[maxInd]
	endfor
;
; 	compute the residuals
;
	modeval,az,za,modi.model,modaz,modza,enc=1
	resAz[*,1]=azErr- modaz
	resZa[*,1]=zaErr- modza
	a=moment(resAz[*,1],sdev=stdev)
	modI.rmsTot[0]= stdev
	a=moment(resZa[*,1],sdev=stdev)
	modI.rmsTot[1]= stdev
	return
end
