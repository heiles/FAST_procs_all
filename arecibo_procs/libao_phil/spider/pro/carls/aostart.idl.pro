;ALWAYS USE THIS FILE FIRST FOR APR98 DATA.

;COMMON ANGLESTUFF CONTAINS ARECIBO OBSERVATORY COORDINATES...
common anglestuff, obslong, obslat, cosobslat, sinobslat

;THE FOLLOWING LONG AND LAT WERE IN THE OLD ARECIBO NOTEBOOK AND ARE WRONG.
;obslong = ten(66,45,18.8)
;obslat = ten(18,21,13.7)

;THE FOLLOWING LONG AND LAT ARE FROM PHIL 2 MAR 1999...
obslong = ten(66,45,10.8)
obslat = ten(18,21,14.2)

cosobslat = cos(!dtor*obslat)
sinobslat = sin(!dtor*obslat)

