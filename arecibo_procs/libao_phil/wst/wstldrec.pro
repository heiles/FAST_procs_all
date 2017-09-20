;+
;NAME: 
;wstldrec - load struct from ascii input
;
;SYNTAX: a=wstldrec(inpl)
;ARGS:
;  inpl: string  ascii record read from oriondata.txt.
;               
;DESCRIPTION:
;   load wst structure from ascii input line
;-
function wstldrec,inpl
	
	aa=strsplit(inpl,',',/extract)
	n=n_elements(aa)
	str={wststr}
	j=0
	str.jd           =wstdatetojd(aa[j++])
	str.windspd      =float(aa[j++])
;	str.windDirRaw   =float(aa[j++])
    j++
	str.windDirAdj   =float(aa[j++])
	str.wiAvg3sec.spd=float(aa[j++])
	str.wiAvg3sec.dir=float(aa[j++])
	str.wiAvg2min.spd=float(aa[j++])
	str.wiAvg2min.dir=float(aa[j++])
	str.wiAvg10min.spd=float(aa[j++])
	str.wiAvg10min.dir=float(aa[j++])
	str.wiGust10min.dir=float(aa[j++])
	str.wiGust10min.spd=float(aa[j++])
	str.gust10minJd    =wstdatetojd(aa[j++])
;	str.wiGust60min.dir=float(aa[j++])
;	str.wiGust60min.spd=float(aa[j++])
;	str.gust60minJd    =wstdatetojd(aa[j++])
	j+=3
	str.temp           =aa[j++] 
	str.relHum         =aa[j++] 
;	str.windChill      =aa[j++] 
;	str.heatIndex      =aa[j++] 
	j+=2
 	str.dewpoint       =aa[j++] 
; 	str.degDays        =aa[j++] 
; 	str.avgTempDay     =aa[j++] 
; 	str.degDayStart    =aa[j++] 
	j+=3
 	str.barPresRaw     =aa[j++] 
 	str.barPresAdj     =aa[j++] 
; 	str.denAlt         =aa[j++] 
; 	str.wetBulbGlobeTemp=aa[j++] 
	j+=2
  	str.vapPresSat      =aa[j++] 
  	str.vapPres         =aa[j++] 
  	str.dryAirPres      =aa[j++] 
  	str.dryAirDen       =aa[j++] 
  	str.wetAirDen       =aa[j++] 
  	str.humAbs          =aa[j++] 
;  	str.airDenRat       =aa[j++] 
;  	str.altAdj          =aa[j++] 
;  	str.saeCorFact      =aa[j++] 
	j+=3
  	str.rainToday       =aa[j++] 
;  	str.rainWeek        =aa[j++] 
	j++
  	str.rainMonth       =aa[j++] 
;;  	str.rainYear        =aa[j++] 
	j++
  	str.rainIntensity   =aa[j++] 
  	str.rainDuration    =aa[j++] 
  	str.trueNorthOff    =aa[j++] 
	return,str
end
