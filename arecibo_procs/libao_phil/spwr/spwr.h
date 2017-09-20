;
; struct read in by spwrget()
a={sitepwrI,$
	date      : 0L               ,$;yyyymmdd
	time      : 0.               ,$; secsMid ast
	time1970  : 0D               ,$; time secs from 1970
    Imag      : fltarr(3)        ,$; phase a,b,c current 
    Ires      : 0.               ,$; residual current
    VPhtoPh   : fltarr(3)        ,$; AB,BC,CA .. not loading yet
    VtoGnd    : fltarr(3)        ,$; amplitude voltage to ground
    Vres      : 0.               ,$; residual voltage
    IDemandCur: fltarr(3)        ,$; lastest demand values
    IDemandMax: fltarr(3)        ,$; lastest demand values
    phVtoI    : fltarr(3)        ,$;ph Vbc - Ia,Vca -Ib, Vab -Ic (deg)
                                   ; so far no phVtoI data
    PFavg     : 0.               ,$; average power factor
    Pactive   : 0.               ,$; active power.. 0..
    Preactive : 0.               ,$; reactive power
    Papparent : 0.               ,$; apparanet power I*V
    tempC     : 0.               ,$; temp of protected object
    tempRelC  : 0.               ,$; relative temp 
	ssr       : uintarr(6)       } ; system status registers 1..6

; system status registers
; Communications Protocol manual
;   sect 3.3.y page 24-
;
; first index 0-15 bits, 2nd ind reg 1-6
;"","","","","","","",""
ssr1Lab=[$
		"DevGlobWarn", $; b0
        "DevGlobErr" , $; b1
        "sl0BSB_WorE", $; b2
        "sl1PSP_WorE", $; b3
        "sl3BIOWorE" , $; b4
		 "","", "", "","","","","","","",""]; b5-b15 unused
ssr2Lab=[$
		"TestMode"         , $; b0
		"locRem"           , $; b1 1 =loc ?
		"locRemSt"         , $; b2  0=rem,1=loc . only if b1=0
		"activeSetParmGrp1-6_dcd",$; b3-5
		"activeSetParmGrp1-6_dcd",$; b3-5
		"activeSetParmGrp1-6_dcd",$; b3-5
		"timeSyncFailure",$; b6
		""               ,$; b7
		"lastResetCause_pwr",$; b8
		"lastResetCause_Wdog",$; b9
		"lastResetCause_WarmReset",$; b10
        "","","","",""]        ; b11 -b15 not used

; modbus client dependent. get reset when device reads reg
ssr3Lab=[$
        "UnreadEventAvail" , $; b0
        "UnreadFltAvail"   , $; b1
        ""                 , $; b2 
        ""                 , $; b3 
        "anyMomBitUpdated" , $; b4 any momentary bit updated
        "anyMCDBitUpdated" , $; b5
        "deviceReset"      , $; b6 
        ""                 , $; b7 
        "evntRecRdy"       , $; b8 ready for reading
        "fltRecRdy"        , $; b9 ready for reading
        "","","","","",""]   ; b10 -b15 not used

; new data available in category
ssr4Lab=[$
        "catPhysInpNew" , $; b0
        "catProtfuncNew", $; b1
        "catLEDAlrmNew" , $; b2
        "catDistbNew" , $; b3
        "catDemandValNew",$; b4
        "catPkDemandNew",$; b5
        "","",           $; b6-b7 unused 
        "","","","","","","",""] ; b8-b15 unused

; new 16 alive counter
ssr5Lab=[$
        "AliveCntr_b0-b15" ] ; b0-b15
ssr6Lab=[$
        "CmdResultCode_b0-7",$ ; b0-b7
;                         0-ok
;                         201-device in local
;                         202-control operation reserverd by another client
;                         203-select timeout or execute/cancel without select
;                         204-control op internally blocked
;                         205-control op timedout
;                         250-other reason
;          
        "respType_b8-9"   ,$ ; b8-b9
        "cmdState_b10-11" ,$ ; b10-b11
        "clntSeqNo_b11-15" ] ; b12-b15
ssrLab=[ssr1lab,ssr2lab,ssr3lab,ssr4lab,ssr5lab,ssr6lab]
