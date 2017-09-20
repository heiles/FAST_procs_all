;
; header for tiedown data
;
TIE_PENC_CNTS_PER_INCH=43663.36
TIE_INCHES_PER_PENC_CNT=2.29024976e-5

a={tdstat,aI_ps24P:     0,$;
   		aI_ps24N:		0,$;
    	aI_psB24P:		0,$;
    	aI_psEnc5P:		0,$;
        aI_VelFB:		0,$;
    	aI_mAmpCurMon:	0,$;
    	aI_mAmpSpdMon:	0,$;
    	aI_ldCell1:		0,$;
    	aI_ldCell2:		0,$;
    	aI_accel:		0,$;       /* used for dbging Ki,Kp*/
    	aI_ratePotPcu:	0,$;
    	aO_velCmd:		0,$;
    	dI_LS:			0,$;          /* little star */
    	dI_uio1:		0,$;        /* universal i/o 1*/
    	dI_uio2:		0,$;        /* universal i/o 2*/
    	fill1:		 	0,$;          /* not in use ..used for dbg Ki,Kp*/
    	dO_LSuio1:		0,$;      /* little star and uio 1*/
    	dO_uio2_fill:	0,$;   /* universal i/o 2, filler*/
    	st_mDrv:		0,$;        /* master drive*/
    	fill2:			0,$;          /* not used used fordbg Ki,Kp*/
    	st_safLimLockAxis:0,$;
    	st_fault:	     0};

a={tdtickInfo,	  tmMs:		    0L,$; from little star 
         		   pos:		    0L,$; encoder counts
         	   ldCell1:		    0L,$; load cell raw counts. .02 kips/count
         	   ldCell2:		    0L,$; load cell 1.. .02 kips/count
		       devStat:         0 ,$; 
		      dataValid:       0 , $; 0--> following data not valid 
			     tdstat:     {tdstat}}   

a={tdslv,		statWd:         0L,$;
            lastReqPos:     	0L,$;
                 ioTry:     	0L,$;
                 ioFail:     	0L,$;
                 tickI:     	{tdtickinfo}}

a={tdall,         secM:         0L,$;seconds from midnite last 1 sec tick
                statWd:         0L,$;prog stat wd
               syncTry:         0L,$;times we tried to sync
              syncFail:         0L,$;times sync failed
               vtxTmMs:         0L,$;time from vertex millisecs
                 az:         0L,$;az position 1/10,000 of a degreed
                 gr:         0L,$;gr position 1/10,000 of a degreed
                 ch:         0L,$;az position 1/10,000 of a degreed
                tempPl:         0L,$;not implemented
				   slv: replicate({tdslv},3)}

a={td,	 secM:	0L,$;
			az:     0.,$;
			gr:     0.,$;
			ch:     0.,$;
			pos:   fltarr(3),$;
			kips: fltarr(2,3),$;	
			kipst:  0.}

a={tdlr,    day: double(0.),$;  
			az:     0.,$;
			gr:     0.,$;
			ch:     0.,$;
			pos:   fltarr(3),$;
			kips: fltarr(2,3),$;	
			kipst:  0.,$;
			temp:   0.,$; temp deg F
			hght:   0.} ; average platform height feet
