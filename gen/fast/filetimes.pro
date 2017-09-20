pro filetimes, path, filename, jd, ut, lst, t0
;
;+
; filetimes: given a filename, return its last-modification times as jd, lst,
; and ut, and t0
;
;calling sequence
;  filetimes, path, filename, jd, ut, lst, t0; t0 is sec from midnite 1970.
;
;input the path and file name, output the 3 times
;uses the system variables !obswlong to get the lst
;-
str= file_info( path + filename)
t0= str.mtime
datestring= systime(0, t0, /ut)
monthname= strmid( datestring, 4,3)
monthnr= ( monthnr2monthname( monthname,/inverse) )[0]
daynr= fix( strmid( datestring, 8,2))
hour= fix( strmid( datestring, 11,2))
min= fix( strmid( datestring, 14,2))
sec= fix( strmid( datestring, 17,2))
year= fix( strmid( datestring, 20,4))
;print, monthnr, daynr, hour, min, sec, year                                        
jd = JULDAY(Monthnr, Daynr, Year, Hour, Min, Sec)

ut= hour + min/60. + sec/3600.

lst= ilst( jul=jd)
;stop
return
end
