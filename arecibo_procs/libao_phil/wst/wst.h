;
; abreviations used:
;adj - adjusted
;alt  - altitude
;avg  - average
;bar  - barometric
;cor  - correction
;deg  - degrees 
;den  - density
;dir  - direction
;dur  -  duration 
;fact - factor
;hum  - humidity
;off  - offset
;pres - pressure
;rel  - relative
;temp - temperature
;vap  - vapor
;wi   - wind Info
;
aa={wst_spddir,$;
		spd: 0.,$;
		dir: 0.}
;
; notes:
; wind speed: updated 1 a sec
; wind gust reading reset to 0 at midnite
; winddirection: direction the wind is coming from.
; rainfor day; inches . reset to 0 at midnite.
; rainfor week; inches . reset to 0 at start of week 
; Avg: these are rolling avg of windSpd, windDirAdj
;Gust: rolling maximum wind spd
;saturated vapor pres:
;      pres of a vapor in equilibrium with its non-vapor phases
;      when air is saturated with water vapor
;dry air pres: barometric pressure - vapor pressure.
;absolute humidity:actual amount of water vapor in air:lbm/ft^3
;raintoday: inches in .01 inch increments

a={wststr,  $;
jd          :  0d,$; timestamp julday
windSpd     :  0.,$;Wind Speed 3 sec rolling avg of 250 ms samples
;;windDirRaw  :  0.,$;Raw Wind Direction
windDirAdj  :  0.,$; Adjusted Wind Direction
wiAvg3sec	:  aa,$; 3 Second Rolling Average  of windspd,dirAdj
wiAvg2min	:  aa,$; 2 Minute  Rolling Average
wiAvg10min	:  aa,$; 10 Minute Rolling Average  
wiGust10min	:  aa,$; 10 Minute Gust 
gust10MinJd : 0D,$; 10 Minute Gust Time
;;wiGust60min :  aa,$; 60 Minute Gust 
;;gust60MinJd : 0D,$; 60 Minute Gust Time
temp        : 0.,$;  Temperature 1
relHum      : 0.,$;  Relative Humidity
;;windChill   : 0.,$;  Wind Chill
;;heatIndex   : 0.,$;  Heat Index
dewPoint    : 0.,$;  Dew Point
;;degDays     : 0.,$;  Degree Days
;;avgTempDay  : 0.,$;  Average Temperature Today
;;degDayStart : 0.,$;  Degree Day Start for degree day avg
barPresRaw  : 0.,$;  Raw Barometric Pressure
barPresAdj  : 0.,$;  Adjusted Barometric Pressure with alt and offset applied
;;denAlt      : 0.,$;  Density Altitude
;;wetBulbGlobeTemp:0.,$; Wet Bulb Globe Temperature
vapPresSat  : 0.,$;  Saturated Vapor Pressure:
vapPres     : 0.,$;  Vapor Pressure
dryAirPres  : 0.,$;  Dry Air Pressure
dryAirDen   : 0.,$;  Dry Air Density
wetAirDen   : 0.,$;  Wet Air Density
humAbs      : 0.,$; Absolute Humidity
;;airDenRatio : 0.,$; Air Density Ratio
;;altAdj      : 0.,$; Adjusted Altitude
;;saeCorFact  : 0.,$; SAE Correction Factor
rainToday   : 0.,$; Rain Today inches. reset to 0 at midnite.update 15 secs
;;rainWeek    : 0.,$; Rain this week inches
rainMonth   : 0.,$; Rain this month inches
;;rainYear    : 0.,$; Rain this year
rainIntensity:0.,$; Rain Intensity inches/hour. running 5min avg
rainDuration: 0.,$; Rain Duration  seconds
;hail        : 0.,$;Hail
;hailDur     : 0.,$; Hail Duration
;hailInt     : 0.,$;Hail Intensity
trueNorthOff: 0. } ;True North Offset
