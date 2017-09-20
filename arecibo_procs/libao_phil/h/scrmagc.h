; define the agcProgState structure
; 

;		includes	*/
@agc.h
;
;    connection state values
; 
;#define AGC_CON_NOTCONNECTED    0
;#define AGC_CON_SELECT_LISTEN   1
;#define AGC_CON_ACCEPTING       2
;#define AGC_CON_CONNECTED       3
;
;  bits determining what agcPrDbg outputs
; 
;#define AGC_PRDBG_STD       1
;#define AGC_PRDBG_CBLK      2
;#define AGC_PRDBG_FBLK      4
;#define AGC_PRDBG_LOCPROG   8
;#define AGC_PRDBG_ALL      -1


;#define	 AGC_NUM_AXIS 3

;#define AGC_DLOG_PT_NAME  "/share/obs1/pnt/pt/dlogPt"
;#define AGC_DLOG_POS_NAME "/share/obs1/pnt/pos/dlogPos"
;#define AGC_DLOG_CBLK_NAME "/share/obs1/pnt/cblk/dlogCblk"
;#define AGC_DLOG_FBLK_NAME "/share/obs1/pnt/fblk/dlogFblk"
;#define AGC_DLOG_PREPROC_NAME "/share/obs1/pnt/pos/dlogPreProc"
;	typedefs	*/

;*************************************************************************
; 	state of pointing program.. 
; ******************************
; 	- There are usually two typedefs for each kind of state:
; 
;
; 	state of our connection with the vertex cpu
; 
a={AGC_STATE_VTX_CON,$
	 	stat     : 0L,$ ;	 /*0 no connect,1 listen loop,2 accept,3 connected*/
		numTryCon: 0L,$; /* we've tried to connect*/
		numCon   : 0L,$; /* times we've connected*/
		listenLoopCnt:0L $;;/* times we looped on listen(10sec each)*/
		}
;
; 	state of i/o to vertex cpu.
; 
a={AGC_STATE_VTX_IO,$
		needSync: 0L ,$ ;		/* i/o failed we need to resync*/
		syncTry : 0L ,$ ;		/* times we tried to sync*/
		syncOk  : 0L ,$ ;		    /* times we successfully synced*/
		readTry : 0L ,$;		/* read from vtx attempts*/
		readOk  : 0L ,$;
		writeTry: 0L ,$ ;
		writeOk : 0L ,$ ;
		fill    : 0L ,$ ;
	    con     : {AGC_STATE_VTX_CON}$;		/* connect info*/
		}
;
;   store position/time value. we do it for each axis separately
;   since we can send a command to change 1 axis at 1 time and
;   another axis at a different time.
; 
a={AGC_PT_VTX ,$
		axis : 0L ,$;	  /*1,2,4 orred together controlled*/
		timeMs: 0L,$; 	  /* millisecs from midnite*/
		posTTD: lonarr(3) $;/* az,gr,ch position 1/10000 degrees*/
		} 
;
;   vertex has a fifo for program tracking. we need to remember the
;   requested positions so that we can compute the position errors.
;   The queue is allocated at startup. It holds the requested position
;   and the constrained position (after checking for limits).
; 
a={AGC_STAT_PT_QENT,$
	    req:{AGC_PT_VTX},$;		/* requested position*/
	    con:{AGC_PT_VTX} $;		/* constrained position*/
		} 
;
; 	the position errors. this is ours - theirs.
;   do it for requested and constrained positions. also record the
;   time and time differences
; 
a={AGC_STAT_POS_ERRS, $
		aoPrevSec	:{AGC_STAT_PT_QENT},$;
		aoCurSec	:{AGC_STAT_PT_QENT},$;
		vtxPrevSec	:{AGC_PT_VTX},$;
		vtxCurSec	:{AGC_PT_VTX},$;
	    tmSecMidnite:0L			 ,$;	/* for the interpolated pos errors*/
	    axis		:0L,$;   /* 1,2,4 orred together.. from request*/			
		reqPosDifRd	:dblarr(3),$;
		conPosDifRd	:dblarr(3) $;

;       following for debugging
;		yVtx		:dblarr(3),$;
;		yAoReq		:dblarr(3),$;
;		yAoCon		:dblarr(3)$;
		} 

;
; 	status errors from cblk,fblk decoded to error numbers
;   beware: VTX_ERR_LIST contains a ptr to an malloced array to hold errnums.
;           for scramnet memory, this ptr is garbage... there is no malloced
; 			list.
a={VTX_ERR_LIST,$
    numErrs		:0L,$;        /* found*/
    maxErrs		:0L,$;        /* allowed*/
    filler 		:0l $;   ; was *perrs (a pointer..not used in scram version).
    }
; 
a={AGC_STAT_ERRS, $
	 	totErrs	:0L,$;		/* we've currently got*/
		timeMs	:0L,$;			/* last error check*/
		gen		:{VTX_ERR_LIST},$;		/* generic errors 3 int long*/ 
		az		:{VTX_ERR_LIST},$;		/* azimuth errors*/
		gr		:{VTX_ERR_LIST},$;		/* gregorian errors*/
		ch		:{VTX_ERR_LIST} $;		/* carriage house errors*/
		}

a={AO_OPARM,$
        encCorTTD	    :lonarr(3),$;   /* az,gr,ch TTD*/
        tmoffsetPTMs	:0L,$;  		/*time offset prog track millisecs*/
        tmoutNoHostSec	:0,$;			/* no request from host.. secs*/
	    filler			:0 $;		    /* for sun alignment*/
    }
;
; fbInp and cbInp are defined in agc.h
;
a={VTX_MSGPRE_RSP,$
    hdrId		:bytarr(4),$;  /* "<TT>" in 4 bytes, no null termination*/
    msgLenB		:0  ,$;;/* length in bytes including header*/
    msgType		:0   $;/* type of msg*/
    } 

a={VTX_RSP_CBLK,$
    	pre		:{VTX_MSGPRE_RSP},$;
    	dat		:{cbInp} $ ;     /* critical data block*/
    }
a={VTX_RSP_FBLK,$
      	pre		:{VTX_MSGPRE_RSP},$;       /* prefix of hdr*/
      	dat		:{fbInp} $;   /* full data block*/
    } 
;
; msg response VtxToAgcProg
;
a={VTX_RSP_MSG_DATA,$
    status		:0,$;
    genStat		:0U,$;   /* general status*/
    timeMs		:0L,$;             /* time in millisecs*/
    posAz		:0L,$;              /* azimuth        position 10^-4 deg*/
    posGr		:0L,$;              /* gregorian      position 10^-4 deg*/
    posCh		:0L $;              /* carriage house position 10^-4 deg*/
    }
;
; 	state  
; note: on 32 bit linux this is 908 bytes
;       on 64 bit linux it is 912 (there are 4 bytes at the end
;       multiscram (on solaris) sends 912. ditto.
; 
a={AGC_STATE,$
		statWd			:0L,$;  /* bit description*/
		fastCblk		:0L,$;/* 1-fastCblk,2-fastFblk if nothing else*/
  	    secMLastTick	:0L,$;/* sec from mid last tick 0..86399*/
		tickProcessing	:0L,$;/* true --> doing tick processing*/
	    vtxIo			:{AGC_STATE_VTX_IO},$;	      /* vertex i/o info*/
		seqNum			:0L,$;	  /* sequence number fo messages*/
		ctrlReq			:lonarr(3),$;/*1 thru 4 who drives axis*/
		ctrlCur			:lonarr(3),$;/*1 thru 4 who drives axis*/
		;/* if true, za is for greg, we then balance with the ch */
		masterMode		:0L,$;/* 1 greg compute ch
		modeReq			:lonarr(3),$;/* cur mode each axis
	    modeCur			:lonarr(3),$;/* cur mode each axis*/
		auxReq			:lonarr(3),$;/* aux for az/gr/ch*/
		auxCur			:lonarr(3),$;
		mRateDataReq	:dblarr(3),$;/* rd/sec request*/
		mPosDataReq		:dblarr(3),$;/* rd's request*/
		posErr			:{AGC_STAT_POS_ERRS},$;/* record last position errors*/
	    dbg             :lonarr(22) ,$; was overspeed and posErr dbging.
		; /* double word aligned until here */
		lastOnQCon		:{AGC_PT_VTX},$;last cnstrn pos on q. time<0 --> nopos
		lastOffQ		:{AGC_STAT_PT_QENT},$;  /* last we took off*/
		lastOffQSkipped :0L,$;
		ptDiffSecs		:0L,$;  /* last program track*/
		offQSkipped		:0L,$; /* time had passed.. total.*/ 
		onQSkipped		:0L,$;  /* time had passed..total*/ 
		oparmReq		:{AO_OPARM},$;	/* operating parameters requested */
		oparmCur		:{AO_OPARM},$;	/* operating parameters current */
		cblkMCur		:{VTX_RSP_CBLK},$;  /* current critical block msg*/
		fblkMCur		:{VTX_RSP_FBLK},$;   /* current full block msg*/
		cmdRspDat		:{VTX_RSP_MSG_DATA},$;	/* from last command send*/
		errs			:{AGC_STAT_ERRS},$;		/* hold errors..*/
		filler2         :lonarr(2)$;/* needed on 32 bit machines make multiple of 8 bytes*/
		}
