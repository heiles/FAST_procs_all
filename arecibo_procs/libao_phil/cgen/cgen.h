;
;  include for cummings generator
; *
; * single generator def
;
aa={cgen1,$
            devType :     0L   ,$;
            ctrlSW  :     0l   ,$; 		// control switch   
            state   :     0l   ,$;
       		faultCode:    0L   ,$;
       		faultType:    0L   ,$;
            KWpercent:    0.   ,$;
            totKWSt:      0.   ,$;		// from status block	
            nfpa110:      0L   ,$;
       		extendedSt:   0L   ,$;       // status
; start gen AC DATA
            freq:         0.   ,$;           // hz
            totPF:        0.   ,$;           
            totKVA:       0.   ,$;           
            totKW:        0.   ,$;           
            totKVAR:      0.   ,$;           
            voltsAB:      0.   ,$;           
            voltsBC:      0.   ,$;           
            voltsCA:      0.   ,$;           
            voltsA:       0.   ,$;           
            voltsB:       0.   ,$;           
            voltsC:       0.   ,$;           
            ampsA:        0.   ,$;           
            ampsB:        0.   ,$;           
            ampsC:        0.   ,$;           
            ampsApercent: 0.   ,$;           // percent amps
            ampsBpercent: 0.   ,$;           
            ampsCpercent: 0.   ,$;           
            batVolt:      0.   ,$;			// volts DC           
            oilPres:      0.   ,$;            //KPA
            oilTemp:      0.   ,$;            //degK
            coolantTemp:  0.   ,$;        //degK
            miscTemp1:    0.   ,$;           //degK
            miscTemp2:    0.   ,$;           //degK
            fuelRate:     0.   ,$;           //gal/Hr 
            engRPM:       0.   ,$;             //rpm
            engStarts:    0L   ,$;          //count
            engRunTime:   0.   ,$;       // hours
            totKWH:       0.   ,$;       // from 2 locations
            totFuel:      0.   ,$;       // gallons
            startctrl:    0L   ,$;       // 
            resetctrl:    0L   $;        // 
	} 
b={cgeninfo,$
    recMarker:bytarr(4),$
    recNum   :0L,$
	yyyymmdd :0L,$
	secMid  :0L,$
    jd      :0D,$ ;  added 21nov13.. julian date.
	genI    :replicate(aa,4)}
