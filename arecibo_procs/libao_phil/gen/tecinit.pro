;
; init for tec data processing
;
@geninit
addpath,'tec'
a={proDat , $ 
        jd  : 0D ,$ 
        tec : 0. ,$; rel tec units:10^16 
        sat : 0  ,$; satellite code 
         ph : 0  ,$; some phase flag 
        uhf : 0  ,$; uhf flag 
        vhf : 0  ,$; vfh flag 
	 passNum: 0L ,$; increments each sat pass
        az  : 0. ,$; deg 
        el  : 0. ,$; deg 
        flat: 0. ,$; deg 
        flon: 0. ,$; deg 
        elat: 0. ,$; deg 
        elon: 0. } ; deg 
;.compile tecinpfile
;.compile tecinpdir
.compile  tecsatlist
