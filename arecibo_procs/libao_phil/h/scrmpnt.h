; define scram pnt block
; 	defines		*/

;#define         PNTX_REQ_NOTRACK 0
;#define         PNTX_REQ_TRACK   1
;#define         PNTX_REQ_HOLD    2
;#define         PNTX_REQ_EXIT    3
; 
;#define         MASTER_GREG 1
;#define         MASTER_CH   2
;; 
;  correction.. none, model, encoder only
; 
;#define		    PNTX_COR_NONE	0
;#define		    PNTX_COR_MODEL  1
;#define		    PNTX_COR_ENC    2

;#define         PNTX_ZACOR_IND_GR  0   
;#define         PNTX_ZACOR_IND_CH  1   

; 	typedefs	*/

;  the fill values are to keep doubles/structures aligned on  8 byte
;  boundaries. this is to get around the different packing of structures
;  done by 68k and the sun.
; 

a={PNT_TUPLE,$
    c1	:0D,$;     /* coordinate 1*/
    c2	:0D,$;     /* coordinate 2*/
    st	:0d,$;     /* start time .. seconds from midnight ast*/
    cs	:0L,$;     /* coordinate system for this coordinate*/
	fill:0L}
; 
;  coordinate. Set of tupples that defines a point in pos,off,rate space
; 
a={PNT_COORD,$
        pos		:{pnt_tuple},$;        /* position (8*int)*/
        off		:{pnt_tuple},$;        /* offset   (8*int)*/
        rate	:{pnt_tuple},$;       /* rate     (8*int)*/
        rateStDayNum:0D,$;/* dayNum.frac ast for start time */
        rateDur	:0D} ;     /* duration rate active. solar secs*/
;;
;*****************************************************************************
;*	pntXform state
;******************************************************************************/
; 
;  time info as computed by pntXform
; 
a={PNT_X_TIME,$
        secMidD	:0d,$;    /* seconds from midnight double..*/
        astFrac	:0d,$;    /* fraction of day ast*/
        ut1Frac	:0d,$;    /* fraction of day ut1t*/
        lmstRd	:0d,$;     /* local mean sidereal time in radians*/
        lastRd	:0d,$;     /* local apparent sidereal time in radians*/
        dayNum	:0L,$;     /* dayNumber 1..366 ast*/
        year	:0L,$;       /* 4 digit ast*/
        mjd		:0L,$;        /* modified julian day for ut1Frac*/
		fill	:0L};
; 
;  current point we are tracking
; 
a={PNT_X_CUR_PNT,$
        pnt			:{PNT_COORD},$;    /* coordinate req (28*int)*/
        raDecTrueV	:dblarr(3),$;
        aberV		:dblarr(3),$[3];/* aberation vector*/
        raDecAppV	:dblarr(3),$;/*apparent ra/dec */
        haAppRd		:0D,$;     /*hour angle apparent*/
        azRd		:0D,$;        /* enc az radians (after exit compOffsets)*/
        zaRd		:0D,$;        /* feed za radians */
;;								/* warning.. xxOffCum only valid if
;;								   offset & rate are same coord sys*/
        c1OffCum	:0D,$;    /* we've applied to the 1st coord*/
        c2OffCum	:0D,$;
        lastAzRd	:0D,$;   /* for computing wrap*/
		corAzRd		:0D,$;	/* total correction azimuth*/
		corZaRd		:0D,$;	/* total correction zenith angle*/
        modelCorAzRd:0D,$;  /* model correction az*/
        modelCorZaRd:0D,$;  /* model correction za*/
        modelLocAzDeg:0D,$;/* where we evaluated*/
        modelLocZaDeg:0D,$;
		raJ			:0D,$;		 /* ra J2000 back converted from az,za*/
		decJ		:0D,$;		 /* dec J2000 back converted from az,za*/
		geoVelProj	:0D,$;  /* geocentric vel observer projected onto
;;									raJ,decJ. units:v/c*/
		helioVelProj:0D,$;/* helio centric vel observer projected. v/c*/
        validPnt	:0,$;/* false on startup, and after a stop*/
        axis		:0,$;       /* to control 1-az,2-gr,4-ch*/
		parallacticRd:0.}; /* parallactic angle in radians*/
; 
;  pntXform request info
; 
a={PNT_X_REQ,$
        wrapReq		:0L,$;    /* 0-compute,1-[0,360),2-[360.,720]*/
        reqState	:0L,$;   /* 0-none,1-track,2-hold,3-exit*/
        pendPValid	:0L,$;/* true--> pntXform looks at point*/
        master		:0L,$;    /* to use 1 gr, 2 ch */
		pntCor		:0L,$;    /* pointing correction. 0-none,1-model,2-enc*/
		settleTmSec	:0,$; 	  /* settle time in seconds <pjp001>*/
		fill		:0,$; 	  
		trackTol	:0D,$;  /* tolerance for tracking.. radians*/
        pendP		:{PNT_COORD}};      /* 28*int pending point */
; 
;  pntXform requests for turret, map onto  pnt_coord_tur
; 
a={PNT_COORD_TT,$
		c		:fltarr(4)};       /* coordinate info*/

;;;  	sin motion 	*/
;;a={pnt_x_tur_sin,$
;;    	posStRd		:0.,$;        /* start posiition in radians*/
;;    	ampRd		:0.,$;          /* amplitude in radians*/
;;    	frqW		:0.,$;           /* frequency radians/sec*/
;;    	phaseRd		:0.};        /* phase offset radians*/
;;
;;;  position and constant velocity*/
;; 
;;a={pnt_x_tur_pv,$
;;    	posStRd	:0.,$;        /* start posiition in radians*/
;;    	velRdSec:0.,$;       /* radians per second*/
;;    	filler	:lonarr(2)}; /* how long we've being doing it*/
;;
;;;   scan between two points with constant time*/
;;
;;typedef struct {
;;    float       pos1Rd;     /* start posiition in radians*/
;;    float       pos2Rd;     /* end position in radians*/
;;    float       timeMovSec; /* time to move between two points*/
;;    int         filler;
;;    } PNT_X_TUR_SCAN;
;;	
;;typedef struct {
;;    unsigned int    reqState:2; /* 0-noReq,1-tracking ,2-holdpnt*/
;;    unsigned int    validPnt:1; /* true--> pntXform looks at point*/
;;    unsigned int     movCode:3; /* 1-sin,2-pos,vel,3-scan,4-tietrk*/
;;    unsigned int        fill:26;
;;    }PNT_X_TUR_STATWD;

a={PNT_X_REQ_TUR,$
        statWd	:0L,$; PNT_X_TUR_STATWD bitfield
		fill	:0L,$;	
		startTm	:0d,$;    /* seconds from midnite*/
        pnt	:{PNT_COORD_TT}};  /* pending point */

a={PNT_X_CUR_TUR,$
        statWd		:0L,$; PNT_X_TUR_STATWD bitfield
		timeStamp	:0L,$;/* ditto*/
		pos			:0.,$;		 /* value sent to turret*/
		vel			:0.,$;		 /* ditto */
        stDayNum	:0D,$; /* dayNum.frac ast for start time */
        pnt			:{PNT_COORD_TT}};    /* coordinate passed to use */
; 
;  tiedown info
; 
;;typedef struct {
;;    unsigned int    reqState:2; /* 0-noReq,1-tracking ,2-holdpnt*/
;;    unsigned int    validPnt:1; /* true--> pntXform looks at point*/
;;    unsigned int     movCode:3; /* 1-sin,2-pos,vel,3-scan,4-tietrk*/
;;    unsigned int        fil:26;
;;    } PNT_X_REQ_TIE_STATWD;
a={PNT_TIE_PAT,$
        c:fltarr(8)};       /* coordinate info*/
;;/*  sin motion  */
;;typedef struct {
;;    float       posStIn[3];     /* start posiition in inches*/
;;    float       ampIn;          /* amplitude in inches*/
;;    float       frqW;          /* frequency rd/sec*/
;;    float       phaseRd;        /* phase offset radians*/
;;    float       filler[2];
;;    } PNT_TIE_PAT_SIN;
;;/* position and constant velocity*/
;;typedef struct {
;;    float       posStIn[3];        /* start posiition inches*/
;;    float       velInSec[3];       /* velocity inches/sec*/
;;    float       filler[2];
;;    } PNT_TIE_PAT_PV;
;;/*  scan between two points with constant time*/
;;typedef struct {
;;    float       pos1In[3];     /* start posiition in radians*/
;;    float       pos2In[3];     /* end position in radians*/
;;    int         timeMovSec; /* time to move between two points*/
;;    int         startTm;    /* seconds from midnite 23jul01 not used???*/
;;    } PNT_TIE_PAT_SCAN;
;;typedef struct {
;;    int         icode;          /* 1-temp,2-az/za,3-both*/
;;    float       offsetIn[3];   /* from std position in inches*/
;;    float       offsetTempF;   /* offset from std temp in defF*/
;;    float       filler[3];
;;    } PNT_TIE_PAT_TRK;

a={PNT_X_REQ_TIE,$
        statWd		:0L,$;PNT_X_REQ_TIE_STATWD
        fill		:0L,$;
        startTm		:0d,$;    /* seconds from midnite*/
        pnt			:{PNT_TIE_PAT}};      /* pending point pattern request*/

;;typedef struct {
;;	unsigned int	reqState:2; /* 0-noReq,1-tracking ,2-holdpnt*/
;;    unsigned int    validPnt:1; /* true--> pntXform looks at point*/
;;    unsigned int     movCode:3; /* 1-sin,2-pos,vel,3-scan,4-tietrk*/
;;	unsigned int	atrkMode:3; /* 0-no,1-temp,2-pos,3-postemp*/
;;	unsigned int	atrkHghtUseTemp:1;/* trk hgt, no lr so used temp from last
;;										 valid height*/
;;	unsigned int	rampActive:1;  /* 1--> currently in a ramp*/
;;	unsigned int	reqPrfErrCor:1;/* add prfErr to model cor if in prf mode*/
;;	unsigned int        fill:20;
;;	} PNT_X_CUR_TIE_STATWD;

a={PNT_X_CUR_TIE,$
	    statWd	:0L,$; PNT_X_CUR_TIE_STATWD/* <pjp016>*/
		tempF	:0.,$;		/* last temp we used*/
		avgHgt	:0.,$;		/* avg Height feet from laser rangers*/
        timeStamp:0L,$;   /* for below position*/
        pos		:fltarr(3),$;      /* 1st value sent to tiedown*/
        vel		:fltarr(3),$;      /* ditto */
        stDayNum:0D,$; /* dayNum.frac ast for start time */
        pnt		:{PNT_TIE_PAT}};     /* pattern info passed to use */
; 
;  tertiary info
; 
;;typedef struct {
;;	unsigned int	reqState:2; /* 0-noReq,1-tracking ,2-holdpnt*/
;;    unsigned int    validPnt:1; /* true--> pntXform looks at point*/
;;    unsigned int      crdSys:4; /* 1-enc,2-inchOff,3-domeCenLine,4-focus*/
;;    unsigned int     movCode:4; /* 1-sin,2-pos,vel,3-scan*/
;;	unsigned int        fill:21;
;;	} PNT_X_REQ_TER_STATWD;
;
a={PNT_TER_PAT,$
        c:fltarr(12)};

a={PNT_X_REQ_TER,$
	    statWd		:0L,$;PNT_X_REQ_TER_STATWD
        fill		:0l,$;
        startTm		:0d,$;    /* seconds from midnite*/
        pnt			:{pnt_ter_pat}};      /* pending point pattern request*/

;;typedef struct {
;;	unsigned int	reqState:2; /* 0-noReq,1-tracking ,2-holdpnt*/
;;    unsigned int    validPnt:1; /* true--> pntXform looks at point*/
;;    unsigned int      crdSys:4; /* 1-enc,2-inchOff,3-domeCenLine,4-focus*/
;;    unsigned int     movCode:4; /* 1-sin,2-pos,vel,3-scan*/
;;	unsigned int        fil:21;
;;	} PNT_X_CUR_TER_STATWD;


a={PNT_X_CUR_TER,$
	    statWd		:0L,$;PNT_X_CUR_TER_STATWD 
        timeStamp	:0L,$;   /* for below position*/
        pos		 	:fltarr(5),$;      /* 1st value sent to ter*/
        vel			:fltarr(5),$;      /* ditto */
		stDayNum	:0d,$; /* dayNum.frac ast for start time */
        pnt			:{PNT_TER_PAT}};     /* pattern info passed to use */

; 
;  model related variables
; 
a={PNT_X_MODEL,$
        encOffAzRd:0D,$;    /* add to position great circle*/
        encOffZaRd:dblarr(2)}; /* 0==greg, 1=ch*/
; 
;  pntXform state
; 
;;typedef struct {
;;		unsigned int	pntProgRunning       :1;
;;		unsigned int	agcProgRunning       :1;
;;		unsigned int	agcProgTrkMode       :1;
;;		unsigned int	pntProgHasPnt        :1;
;;
;;		unsigned int	pntProgReqTrk        :1; /* not holding pnt*/
;;		unsigned int	settling             :1;
;;		unsigned int	firstSettle          :1;/* waiting for first in tol*/
;;		unsigned int	onSrcAndTracking     :1;/* all of the above*/
;;
;;		unsigned int	reqSrcInZaRange      :1;/* req Src pos within za limit*/
;;		unsigned int	newPntInPipeline     :1;/* waiting 2 secs to be active*/
;;		unsigned int    pntXAgcPrComOk       :1;/* pntx,agcProg talking ok*/
;;
;;		unsigned int    lrLastHghtOk         :1;/* last height input ok*/
;;		unsigned int    lrLastTempOk         :1;/* last temp input ok*/
;;		unsigned int    prfErrIncluded       :1;/* add prf err to model
;;		                                           if tdprf active*/
;;		unsigned int	lrNoComCnt		     :4;/* if n > 0 then no com with
;;						  distomats for last n  trys (3 min per try)*/
;;		unsigned int	distOk			     :6;/* one for each distomat ok*/
;;		unsigned int    alfaProgRunning      :1;/* alfa prog running ok*/
;;		unsigned int	fill			     :7;
;;		} PNT_X_STATWD;
; 
; 	info that is supplied/computed 2 seconds in advance to fill the
;   pipeline of pntXform->pntAgc->vertex..
; 
a={PNT_X_PL,$
        tm		:{PNT_X_TIME},$;        /* for this pipelined point(14*int)*/
        curP	:{PNT_X_CUR_PNT},$;   /* current point (64*int)*/
        model	:{PNT_X_MODEL},$;	/* (4*in)t*/
        req		:{PNT_X_REQ},$;    /* from pntTcl (36*int)*/
;;		/*  turret info */
        reqTur	:{PNT_X_REQ_TUR},$;   /* from pntTcl*/
        curTur	:{PNT_X_CUR_TUR},$;   /* current position*/
        reqTie	:{PNT_X_REQ_TIE},$;   /* from pntTcl*/
        curTie  :{PNT_X_CUR_TIE},$;   /* current position*/
        reqTer	:{PNT_X_REQ_TER},$;   /* from pntTcl*/
        curTer	:{PNT_X_CUR_TER}};   /* current position*/
	
; 
;  pntXform state
; 
a={PNT_STATE,$
		pl				:{PNT_X_PL},$;
        curTm			:{PNT_X_TIME},$;  /* last tick (14*int)*/
;;		/*--- end buffered data*/
		statWd			:0L,$;PNT_X_STATWD /* (1*int)*/
		settleTmCnt		:0,$;
		tdToUse			:0B,$;/* 0->7 1-td12,2=td4,4-td8*/
		terToUse		:0B,$;/* 0->7 1-Ver,2-hor,4=tile*/
	    modelCorEncAzZa	:dblarr(2),$; /*radians   pjp038*/
        agcStErrs		:0L,$;/* times we had an error*/
        errAgcSemTakePntX:0L,$;	/* agcState semaphore*/
        errAgcSemTakePntT:0L,$;
		errPntXSemTakePntX:0l};	/* pntXReq semaphore*/
