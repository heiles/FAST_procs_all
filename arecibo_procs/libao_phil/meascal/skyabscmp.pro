; first call doitlbninp..
; this then does the processing
Tabs =292		; 85 F
Trcvr=[16, 12]	; polA polBK
Tscattered=14	;
Tsky      =6
	range=3
	limit=2
;
; this was median filtered
;
	calAbs  =dabs.tpCal
	calSky  =dsky.tpCal
;
;
;	 (Rabs-Rsky)/(Rabs*Rsky)= (Tsky-Tabs)/deltaCal
;
	calRatio  =(Tsky+Tscattered-Tabs)*(calAbs*calSky)/(calAbs-calSky)
;
; 	put on the kelvins
;
	calabs[0,*]  =calabs[0,*]  *(Trcvr[0]+Tabs)
	calabs[1,*]  =calabs[1,*]  *(Trcvr[1]+Tabs)
	calsky[0,*]=calsky[0,*]*(Trcvr[0]+Tsky + Tscattered)
	calsky[1,*]=calsky[1,*]*(Trcvr[1]+Tsky + Tscattered)
;
; 	reform to be in strip and freq order
;   calabs  [2,16,6]
;   calsky[2,16,6]
;   calskybl[2,16,6]
;   calrationb[2,16,6]
;   calratiobb[2,16,6]
;
   calabs    =reform(calabs,2,16,numloopsabs)
   calsky  =reform(calsky  ,2,16,numloopssky)
   numloopsRatio=min([numloopssky,numloopsabs])
   calratio=reform(calratio,2,16,numloopsRatio)
end
