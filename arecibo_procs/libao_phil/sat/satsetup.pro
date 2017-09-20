;+
;NAME:
;satsetup - return setup info for sat routines
;SYNTAX: satSetupI=satsetup()
;ARGS: none
;KEYWORDS: none
;RETURNS:
;satSetupI:{}   returns strucuture containing locations of various files/dir.
;
;DESCRIPTION:
;   Call satsetup() to get the default locations for files and
;directories.
;-
function satsetup
;
;   secsRef corresponds to jdRef...(utc)
; 
    predDir='/share/megs/phil/predict/'
    return,{    predictCmd: predDir + 'predict',$; binary to execute
        qthFile   : predDir + 'arecibo.qth',$; ao location
        tleDir    : predDir + 'tle/',$  ; tle files
        tleSuf    : ['tle','txt']}  ; suf of tle files
end
