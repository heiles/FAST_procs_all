;
; format for texas catalog at 365 Mhz
; abreviations used:
; + ok, C caution, W warning
a={cattexas , $
	name	: ' '   ,$; iau name  Bxxxx+xxx
	ra		:  0.   ,$; hhmmss.ss .. 1950
	dec     :  0.   ,$; ddmmss.ss .. 1950
	flux365 :  0.   ,$; Jy
	fluxerr :  0.   ,$; Jy
	specInd :  0.   ,$; spec index 330 to
 specIndErr :  0.   ,$; spec index
;
	srcmodel: ' '   ,$;model for src:P point,D double,A asymetric double
	dblsize :  0.   ,$;double extent asecs (between components)
;
; status 
	modfit  : ' '	,$;model fit:+,C,W,,N model doesnt fit
	srcenv  : ' '	,$;environmet:+ not confused,C,W,X sidelobe of othersrc?
	lobeshift: ' '  };+ no, C,W
;
