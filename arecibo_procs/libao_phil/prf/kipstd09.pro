;+
;kipstd09 - compute kips in each tiedown (using 08,09data)
; SYNTAX:
;       kips=kipstd09(az,zaGr,zaCh,temp,tdPos,coef=coef,$
;                        genDat=genDat,posUsed=posUsed,$
;                        tempUsed=tempUsed,day=day,night=night)
; ARGS:		
;     az[N]	    : azimuth in degrees
;     za[N]	    : zenith angle dome in degrees
;    temp[N]    : platform temp degF
;    tdPos[3,N]: tieDown position inches. 0-2 --> td12,td4,td8
; keywords:		
; genDat[N,2]:   if set then generate the position temp,data
;                  genDat[*,0] = avgerage position offset from reference
;                  genDat[*,1] = temp offset from avg temp:73.
; day:           if set then use fit from daytime data (6:18 hr). Default
;                is fit from all data.
; night:        if set then use fit from nighttime data (0:6,18:24 hr). Default
;                is fit using the all data.
; RETURNS:
;  kips[3,N]
;posUsed[3,N]:  tiedown positions used. If /posAvg is set this returns
;               the actual positions used.
;tempUsed[N]:   temperature used
;coef[8,3]    :  float coef for fit that was used
;
; default fit comes from jan08->dec09 . see x101/100217/tdkipstest.pro
;-
function kipstd09,az,gr,ch,temp,tdpos,epoch=epoch,genDat=genDat,$
			posUsed=posUsed,tempused=tempUsed,night=night,day=day,$
			coef=coef
;
	nparms=8
	npts=(n_elements(az) gt 1)?(size(az))[1]:1
	tempFitRef=73
;   from data at temp=73F
	tdPosRef=[14.9969,15.2455,15.0182]
	tdPosRefAvg=total(tdposRef)/3.
	tdPosOff=tdPosRef - tdPosRefAvg
;
;   see if they want us to generate reasonable data
;
	if (n_elements(genDat) gt 0) then begin
		if (n_elements(genDat) ne 2*npts) then begin
			print,"gendat keyword requires ndat,2 points "
			return,-1 
		endif
		tempUsed=genDat[*,1] +tempFitRef
        case 1 of 
			keyword_set(day):coeftd=[37.9104,-.317351]
			keyword_set(night):coeftd=[32.4796,-.235531]
			else             :coeftd=[38.5557,-.323769]
		endcase
		posUsed=fltarr(3,npts)
		for i=0,2 do posUsed[i,*]=genDat[*,0] + tdPosOff[i] + $
				poly(tempUsed,coefTd)
	endif else begin
		tempUsed=temp
		posUsed=tdpos
	endelse
;
	coef=dblarr(nparms,3)
;	print,'epoch:',epoch
	if n_elements(epoch) eq 0 then epoch=2008

	if epoch ne 2008 then begin
		print,"only epoch available is 2008"
		return,-1
	endif
	coefAll=[[5.5732276,-0.74071155,1.4399629 ,0.46272050,0.81416185,-182.46958,21.167952,30.285440],$
          [5.5481072,-0.76089917,0.49036920,1.5331098 ,0.89860882,-179.95944,20.863377,31.488266],$
         [-2.2657032,-0.74318980,0.41915515,0.50050650,1.8854497 ,-183.32148,20.909236,29.324045]]
	coefDay=[[5.6455217,-0.71506383,1.4364386,0.45446468,0.78000692,-180.97605,20.826832,30.514298],$
             [4.9735031,-0.74039176,0.47269054,1.5324140,0.91638081,-180.98490,21.003603,31.148111],$
             [-2.8533123,-0.70760888,0.40012834,0.49951902,1.9007027,-184.80740,21.421683,28.708290]]
	coefNite=[[14.176846,-0.72233693,0.97795621,-1.2681817,2.5060998,-183.19283,21.205532,30.784539],$
              [15.854817,-0.74344720,0.30610966,2.5335186,-0.56984482,-177.93787,20.676704,28.799415],$
              [7.6089936,-0.73521892,0.10311946,1.1601542,0.92382633,-183.63025,20.770456,32.333133]]
	case 1 of
		keyword_set(day): coef=coefDay
		keyword_set(night): coef=coefNite
		else              : coef=coefAll
	endcase

	tdAz=[2.87D,122.87D,242.87D]
	grRd=double(gr)*!dtor
	chRd=double(ch)*!dtor
 
 	dat=fltarr(3,npts)
	for i=0,2 do begin
	  cosAz=cos((az-tdAz[i])*!dtor)
	  dat[i,*]=coef[0,i]          + $
			   coef[1,i]*(tempUsed-tempFitRef) + $
			   coef[2,i]*posUsed[0,*] + $
			   coef[3,i]*posUsed[1,*] + $
			   coef[4,i]*posUsed[2,*] + $
			   cosaz*(coef[5,i]*sin(grRd) + $
			          coef[6,i]*cos(grRd) + $
			          coef[7,i]*sin(chRd)) 
	endfor
	 return,dat
end
