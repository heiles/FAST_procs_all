; 
; header for turret data 
;
; conversion factors
;
turConv={ turConv  , $
		enccntToDeg: 360./(4096. * 210. / 5.0),$;
;/* (5000rpm/2048)*(1pinionrev/93.165mtrrpm)*(1flrrev/17.5pinrev)*360*1/60*/
		degsecToDaCnt: (1./.00898464),$;
		degsec2ToDaIn5ms: (1./1.79692711)}

a={clktime,$
		meas:     0L,   $;          /* measured time*/
    	compTm1:  0L,$;        /* compare time1*/
		compTm2:  0L } ;        /* compare time2*/

a={fltlog,$
        timeSt:  0L,$ ;        /* time stamp*/
        count :  0 ,$ ;      /* count*/
        id    :  0   };     /* fault id.*/

a={turdata,aI_ps24P:     0,$;
   		aI_ps24N:		0,$;
    	aI_psB24P:		0,$;
    	aI_psEnc5P:		0,$;
        aI_VelFB:		0,$;
    	aI_mAmpCurMon:	0,$;
    	aI_mAmpSpdMon:	0,$;
    	aI_sAmpCurMon:	0,$;
    	aI_sAmpSpdMon:	0,$;
    	aI_accel:		0,$;       /* used for dbging Ki,Kp*/
    	aI_ratePotPcu:	0,$;
    	aO_velCmd:		0,$;
    	dI_LS:			0,$;          /* little star */
    	dI_uio1:		0,$;        /* universal i/o 1*/
    	dI_uio2:		0,$;        /* universal i/o 2*/
    	dI_uio3:		 	0,$;          /* not in use ..used for dbg Ki,Kp*/
    	dO_LSuio1:		0,$;      /* little star and uio 1*/
    	dO_uio2_3:	    0,$;   /* universal i/o 2, filler*/
    	st_mDrv:		0,$;        /* master drive*/
    	st_slDrv:       0,$;          /* not used used fordbg Ki,Kp*/
    	st_safLimLockAxis:0,$;
    	st_fault:	     0};

a={turmsgFixed,	  tmMs:		    0L,$; from little star 
         		   pos:		    0L,$; encoder counts 
			   devStat:         0 ,$; 
		      dataValue:        0 ,$; 
			   bytesInp:       9L}  ; bytes input msg


a={turlogInp,	statWd:         0L,$;
            lastReqPos:     	0L,$;
                 ioTry:     	0L,$;
                 ioFail:     	0L,$;
				 inpMsg:    {turmsgFixed},$; last msg input
				 tickMsg:   {turmsgFixed},$; last msg at tick
				 getTime:    {clktime},$;
				 getClock:   {clktime},$;
				 tmStmps :   lonarr(22),$; for each datapoint
				 dat     :   {turdata},$;
				 flts    :   replicate({fltLog},7)}

a={turlog,	statWd:         0L,$;
			secM  :         0.,$; seconds from midnite for tick
			pos   :         0.,$; pos degrees
			devStat:        0L,$; device status
            lastReqPos:     0.,$;
             ioTry:     	0L,$;
            ioFail:     	0L,$;
		        dat:   {turdata},$;
		      datTm:   fltarr(22),$; for each datapoint
			   flts:   replicate({fltLog},7)}
