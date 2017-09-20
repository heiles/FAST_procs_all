;+
;NAME: 
;wstdatetojd - convert wst string date to jd
;
;SYNTAX: jd=wstdatetojd(datestr)
;ARGS:
;   datestr: string  format "mm/dd/yy hh:mm:ss" ast
;               
;DESCRIPTION:
;   Convert datestr from weather station to julday.
;-
function wstdatetojd,datestr
	
	asttogmt=4./24D
	mm=long(strmid(datestr,0,2))
	dd=long(strmid(datestr,3,2))
	yr=long(strmid(datestr,6,2)) + 2000L
	hr=long(strmid(datestr,9,2))
	min=long(strmid(datestr,12,2))
	sec=double(strmid(datestr,15,2))
	return,julday(mm,dd,yr,hr,min,sec) + astToGmt
end
