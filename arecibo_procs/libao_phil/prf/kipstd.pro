;+
;kipstd - compute kips in each tiedown
; SYNTAX:
;       kips=kipstd(az,za,tempDegF,tdPos,epoch=epoch,coef=coef)
; ARGS:		
;     az[N]	    : azimuth in degrees
;     za[N]	    : zenith angle dome in degrees
;     temp[N]   : temperature degF
;     tdPos[3,N]: tieDown position inches. 0-2 --> td12,td4,td8
; keywords:		
;	epoch:  int  2002 (default) from year 2002
;	             2000 from data 7mar00 to 4may00
; RETURNS:
;  kips[3,N]
;
; default fit comes from 7mar00 through 4may00 data
; epoch 2002- 2002 year (see x101/td/model/yr2002.pro
; both use T=0 for the temp offset and pos=0 for the td height offset.
;-
function kipsTd,az,za,temp,tdpos,epoch=epoch
;
	coef=dblarr(7,3)
;	print,'epoch:',epoch
	if n_elements(epoch) eq 0 then epoch=2002

	if epoch eq 2000 then begin
	coef[*,0]=[ 100.45773D, -1.0497530D ,1.5247928D,0.24439508D, .30963731D,$
	       	   -172.5949D , 26.00069D]

	coef[*,1]=[  90.681302D,-0.95299733D,0.4259555D,1.26950700D,0.28917371D,$
		       -166.65655D, 25.368758D]

	coef[*,2]=[ 95.574206D, -0.99063736D,0.44217290D,0.24524094D,1.4037357D,$
   		       -168.99757D , 25.274322D]
	endif else begin
; rms 12: 1.25 
		coef[*,0]=[ 85.414880D,-.99255797D,1.5809861D,0.42926605D,0.25346778D,$
					-177.18513D,25.503133d]
; rms 4: 1.25

		coef[*,1]=[87.129790, -0.95094186D,.62349196D,1.2984087D,.351092250D,$
				   -174.03565D,25.468217D]

; rms 8:1.314
		coef[*,2]=[78.148738D,-0.86282270D,.53916799D,.50355874D,1.2900018D,$
				   -171.73717D, 24.555275D]
	endelse
	tdAz=[2.87D,122.87D,242.87D]
	zaRd=double(za)*!dtor
 
	npts=(size(az))[1]
 	dat=fltarr(3,npts)
	for i=0,2 do begin
	  cosAz=cos((az-tdAz[i])*!dtor)
	  dat[i,*]=coef[0,i]          + $
			   coef[1,i]*temp + $
			   coef[2,i]*tdPos[0,*] + $
			   coef[3,i]*tdPos[1,*] + $
			   coef[4,i]*tdPos[2,*] + $
			   coef[5,i]*cosAz*sin(zaRd) + $
			   coef[6,i]*cosAz*cos(zaRd)
	endfor
	 return,dat
end
