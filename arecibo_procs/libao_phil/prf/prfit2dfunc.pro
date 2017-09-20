;+
;prfit2dfunc - fitting function used by prfit2d
;-
function prfit2dfunc,x,m
	common prfit2d ,prfit2d_azza
;
;p= a0 + a1*sin(azrd)   + a2*cos(azrd)
;         a3*sin(3*azrd) + a4*cos(3*azrd)
;         a5*za*sin(3azrd)  + a6*za*cos(3azrd)
;         a7 *za1   +  a8*za1^2 +  a9*za1^3  + a10*za1^4
;         a11*za1^5 + a12*za1^6 + a13*za1^7  + a14*za1^8
;         a15*za1^9 + a16*za1^10+ a17*za1^11 + a18*za1^12
;
    ;
    i=long(x+.5)
    azrd=prfit2d_azza[i].azrd
    za  =prfit2d_azza[i].za
;
;	if you change -10, 4 or zapoly order.. update them in prfit2d also
;
    zaA  =(za-10.D)/4.D
    zaA2 =zaA*zaA
    zaA3 =zaA2*zaA
    zaA4 =zaA3*zaA
    zaA5 =zaA4*zaA
     zaA6 =zaA5*zaA
     zaA7 =zaA6*zaA
      zaA8 =zaA7*zaA
      zaA9 =zaA8*zaA
      zaA10=zaA9*zaA
      zaA11=zaA10*zaA
     zaA12=zaA11*zaA
     zaA13=zaA12*zaA
   return,[[1.D],[sin(azrd)],[cos(azrd)],[sin(3.D*azrd)],[cos(3.D*azrd)],$
        [za*sin(3.D*azrd)],[za*cos(3.*azrd)],$
        [za*sin(4.D*azrd)],[za*cos(4.*azrd)],$
        [za*sin(6.D*azrd)],[za*cos(6.*azrd)],$
        [zaA],[zaA2],[zaA3],[zaA4], $
        [zaA5],  [zaA6],  [zaA7],  $
        [zaA8],  [zaA9],[zaa10],[zaa11],[zaa12],[zaa13] ]
end
