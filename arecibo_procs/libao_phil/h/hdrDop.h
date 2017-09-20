;
;   doppler correction, frequencies
;
;statwd:bitmap.. first bit, leftmost bit of word
;
;typedef struct {
;    unsigned int  dopCorAllBands:1;/* 1 yes, 0 just center of band*/
;    unsigned int  velCrdSys:4;     /* 1-geo,2-helio,3-lsr */
;    unsigned int  velType:2;       /* 0-vel,1-zo,2-zr*/
;    unsigned int  fill:25;
;    } HDRAO_DOP_STAT_WORD;
;
a={hdrdop,          id:  bytarr(4,/nozero), $
                   ver:  bytarr(4,/nozero), $
                factor:         0.D,$; freqRest*fac=freqTopo
                 velOrZ:        0.D,$; vel km/sec velCrdSys or Z.(stat.velType)
            freqBCRest:         0.D,$; rest freq rf band center
           freqOffsets:dblarr(4,/nozero),$; freq offsets in mhz
;								 1.dopCorAllBands=1: add to freqBCRest 
;                                2.dopCorAllBands=0: add to freqBCTopocentric
            velObsProj:         0.D,$;vel of observer in velCrdSys (km/sec)
;			                          projected along the req pointing direction
                 tmDop:         0L,$;time doppler computed.secMidnite AST
				  stat:         0L,$; stat word (see bit description)
			   	  fill: lonarr(2,/nozero)}; filler
