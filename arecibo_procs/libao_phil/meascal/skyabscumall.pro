;
; try cum filtering all of the data at 1 freq at at time
;
ufrq=dabs[uniq(dabs.freq,sort(dabs.freq))].freq
nfrq=n_elements(ufrq)

numSbcTot
calAbsF=fltarr(2,numSbcTot)
fracAbsF=fltarr(2,numSbcTot)
calSkyF=fltarr(2,numSbcTot)
fracSkyF=fltarr(2,numSbcTot)
nchn=n_elements(dabs[0].spOn[*,0])


for i=0,nfrq-1 do begin
	ind=where(dabs.freq  eq ufrq[i],count)
	for pol=0,1 do begin
		x=reform(dabs[ind].spcal[*,pol],count*nchn)
        cumfilter,x,range,limit,indxgood,indxbad,countbad
		calAbsF[pol,i]= median(x[indxgood])
		fracAbsF[pol,i]=1.- countbad/(1.*nchn*count)
	endfor
;
	ind=where(dsky.freq  eq ufrq[i],count)
	for pol=0,1 do begin
		x=reform(dsky[ind].spcal[*,pol],count*nchn)
        cumfilter,x,range,limit,indxgood,indxbad,countbad
		calSkyF[pol,i]= median(x[indxgood])
		fracSkyF[pol,i]=1.- countbad/(1.*nchn*count)
	endfor
endfor
calRatioF=(Tsky + Tscattered-Tabs)*(calAbsF*calSkyF)/(calAbsF-calSkyF)
calAbsF[0,*]=calAbsF[0,*]*(Trcvr[0]+Tabs)
calAbsF[1,*]=calAbsF[1,*]*(Trcvr[1]+Tabs)
calSkyF[0,*]=calSkyF[0,*]*(Trcvr[0]+Tsky+ Tscattered)
calSkyF[1,*]=calSkyF[1,*]*(Trcvr[1]+Tsky+ Tscattered)
end
