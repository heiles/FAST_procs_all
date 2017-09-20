;+
;NAME:
;shimpnts - return the za for the shim points.
;SYNTAX: shimpnts,shimpnt,za,straddles=straddles
;ARGS:
;	shimpnt[17] : float shim points,0,.5,1.0,1.5,2.0..
;					        (.5 is panelpoint 1-0).			  			
;        za[17] : float zenith angle of shim point.
;KEYWORDS:
;	straddles   :  if set then return za when dome center straddles
;				   the panel point. This includes the 1.11134 offset of
;				   optical axis from center of dome.
;end
pro shimpnts,shimpnt,za,straddles=straddles
;
	npnts=17
	a=fltarr(3,17)
	a=[$
   [ 0.   , 21.117760, 22.2291],$
   [ 0.5  , 20.2512  , 21.362540],$
   [ 1.0  , 19.3303  , 20.441640],$
   [ 1.5  , 18.2515  , 19.362840],$
   [  2.0 ,  17.1793 ,  18.290640],$
   [ 2.5  , 15.8654  , 16.976740],$
   [ 3.0  , 14.5600  , 15.671340],$
   [ 3.5  , 13.1574  , 14.268740],$
   [  4.0 ,  11.7628 ,  12.874140],$
   [ 4.5  , 10.27130 , 11.382640],$
   [ 5.0  ,  8.78690 ,  9.89824],$
   [ 5.5  ,  7.31360 ,  8.42494],$
   [ 6.0  ,  5.84520 ,  6.95654],$
   [ 6.5  ,  4.38050 ,  5.49184],$
   [ 7.0  ,  2.91880 ,  4.03014],$
   [ 7.5  ,  1.45890 ,  2.57024],$
   [ 8.0  ,  0.      ,  1.11134]]
	shimpnt=reform(a[0,*],17)
	za=reform(a[1,*],17)
	if keyword_set(straddles) then za=reform(a[2,*],17)
	return
end
