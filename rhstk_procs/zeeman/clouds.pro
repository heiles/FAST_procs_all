pro clouds, nclouds, array, digi2
;+
;	CLOUDS considers a number of clouds equal to nclouds and
;returns an array of all possible arrangements of order of cloud
;along the line of sight. array a number whose digits (beginning with
;0 and ending with nclouds-1) represent the
;clouds and whose ordering represents the order along the line of
;sight. For example, if there are three clouds then array is...
; array = [12          21         102         120         201         210]
;
; DIGI2 is a digitized version of array. in the above example, digi2[3,6] is...
;	nr	digi2[0,nr]	digi2[1,nr]	digi2[2,nr]	
;	0	0		1		2
;	1	0		2		1
;	2	1		0		2
;...etc...
;
;CALLING SEQUENCE:
;       CLOUDS, nclouds, array, digi2
;
;INPUTS
;       NCLOUDS, the nr of clouds
;
;OUTPUTS
;       ARRAY, the array of cloud orderings (see above)
;       DIGI2, the digitized version of array (see above)
;
;RESTRICTIONS: NCLOUDS MUST BE GT 1 AND LE 10.
;MODS: ARRAY AND DIGI2 WERE REVERSED WRT EACH OTHER; FIXED ON 13OCT01
;
;history:
;       CH added documentation on 3 may 2012
;-

;TAKE CARE OF THE ONE-CLOUD CASE:
if (nclouds eq 1) then begin
	array= [0]
	digi2= intarr(1,1)
	digi2= reform( digi2,1,1)
	return
endif

;GENERATE AN ARRAY OF NUMBERS THAT CONTAIN ALL POSSIBLE ARRANGEMENTS 
;OF THE CLOUDS. FOR THREE CLOUDS, FOR EXAMPLE, THIS IS INDGEN(300).
lr = long(nclouds)
nlr = lr * 10l^(lr-1)      
array = indgen(nlr, /long)  

;GENERATE A SET OF 3 DIGITS FOR THESE CLOUDS...
digi1=intarr(lr, nlr)
for nr=0, lr-1 do digi1[nr,*] = array/long(10l^nr) - $
	10l*(array/long(10l^(nr+1)))

;print, array
;print, digi1

;ELIMINATE ALL MEMBERS OF THE ARRAY WHOSE DIGIT VALUES EXCEED NCLOUD-1...
indxtot = lonarr(lr * nlr)   
counter = 0l

for nr=0, lr-1 do begin
indx = where( digi1[nr,*] gt lr-1, count)

if (count ne 0) then begin
indxtot[counter:counter+count-1] = indx
counter = counter+count
endif

endfor

indxttt = indxtot[0:counter-1]
indxuniq = indxttt( uniq(indxttt, sort(indxttt)))
array[indxuniq] = -1
indx = where(array ne -1)
array = array[indx]

;print, array

;AT THIS POINT, ARRAY CONTAINS ALL POSSIBLE ARRANGEMENTS OF THE CLOUDS
;IN WHICH NO DIGITS EXCEED NCLOUD-1. HOWEVER, THERE EXIST DUPLICATE
;DIGITS, AND WE MUST ELIMINATE THEM...

;----------BEGIN DO LOOP....---------------------------------------

for mr = lr-2l, 0l , -1l do begin

digi1 = intarr(lr, n_elements(array))
for nr=0l, lr-1l do digi1[nr,*] = array/long(10l^nr) - $
	10l*(array/long(10l^(nr+1l)))

;STOP

indxtot = lonarr(lr * nlr)   
counter = 0l

for nr=0l, mr do begin
indx = where( digi1[ mr+1, *] eq digi1[nr,*], count)

if (count ne 0) then begin
indxtot[counter:counter+count-1] = indx
counter = counter+count
endif

;STOP

endfor

indxttt = indxtot[0:counter-1]

indxuniq = indxttt( uniq(indxttt, sort(indxttt)))
;indxuniq = indxtot( uniq(indxtot, sort(indxtot)))
array[indxuniq] = -1
indx = where(array ne -1)
array = array[indx]

endfor

;for mr = lr-2l, 0l , -1l do begin

digi2 = intarr(lr, n_elements(array))
for nr=0l, lr-1l do digi2[nr,*] = array/long(10l^nr) - $
	10l*(array/long(10l^(nr+1l)))

for nr= 0, n_elements(array)-1 do digi2[ *,nr]= reverse( digi2[ *,nr])

;endfor



;STOP

end
