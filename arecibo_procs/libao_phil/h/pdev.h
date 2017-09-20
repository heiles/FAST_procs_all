; ; constants for pdev device.
;
; older version prior to sep07
a={pdev_hdrpdevV1 ,$
	magic_num	: "deadbeef"XUL,$ ; unsigned long
	magic_sp	: 0L          ,$ ; magic number for sp unsigned long
    adcf		: 0L          ,$  ; adc clock freq Hz.
    byteswapCode: 0L          ,$  ; 
    blkSize     : 0L          ,$  ; size of each block (integration)
    nblksdumped : 0L          ,$  ; number of blocks dumped
    beam        : 0L          ,$  ; from [pdev] section
    subband     : 0L          }   ; 0,1 from [pdev] section

a={pdev_hdrpdev ,$
    magic_num   : "feffbeef"XUL,$ ; unsigned long
    magic_sp    : 0L          ,$ ; magic number for sp unsigned long
    adcf        : 0L          ,$  ; adc clock freq Hz.
    byteswapCode: 0L          ,$  ;
    blkSize     : 0L          ,$  ; size of each block (integration)
    nblksdumped : 0L          ,$  ; number of blocks dumped
    beam        : 0L          ,$  ; from [pdev] section
    subband     : 0L          ,$  ; 0,1 from [pdev] section
	lo1mix      : 0L          ,$  ; from [dump]
	lo2mix0     : 0L          ,$  ; from [dump]
	lo2mix1     : 0L          ,$  ; from [dump]
	adcclk      : 0L          ,$  ; 
	time        : 0L          ,$  ; start time
	resv1       : 0L          ,$  ; for phil
	pdevaomagic : 0L          ,$  ; 0x12345678 pdev_hdr_ao present.04aug11
	if1         : 0L          ,$  ; first if1 
;   the values below are loaded by masopen. they are not 
;   in the pdev.hmain header..
	calctl      : 0           ,$  ;0 always off,1 always on, 2 winking cal
	wcaloff     : 0           ,$  ;wink dumps cal on
	wcalon      : 0           ,$  ;wink dumps cal off
	fill1       : 0           ,$
	wcalphase   : 0.          ,$  ;wink position last dump for transition 
	fill        : lonarr(13)  }   ; currently unused

;
;  this is defined in svn/pdev/pnetbld/sp1def.h
a={pdev_hdrsp1 ,$
		 fmtWidth: 0U	,$; 0 8bit,1-16 bit, 2-32bit
		  fmtType: 0U	,$; 0-stokes I,1-s0,s1, 2-s
		  fftlen : 0U	,$; 
		 chndump1: 0U	,$; 1st  channel dumped count from 0
		 chndump2: 0U	,$; last channel dumped count from 0
		 fftaccum: 0U	,$; numberffts to accum
		 fftdrop : 0U	,$; number ffts to drop between accums.
		 arsel   : 0U	,$; dig sel 0=adc0,1=adc1,2=adc2,3=adc3,4-test,5=0
		 aisel   : 0U	,$; 
		 brsel   : 0U	,$; 
		 bisel   : 0U	,$; 
		 arneg   : 0U	,$; 1-> negate voltage
		 aineg   : 0U	,$; 
		 brneg   : 0U	,$; 
		 bineg   : 0U	,$; 
	    pfbBypass: 0U	,$; bypass lopass filter of polyphase filter bank
     fftshiftMask: 0U	,$; each bit dshifts 1 butter fly stage.b0 last stage
	    upshift  : 0U	,$; ; after fft upshifted by this amount
	    Dshift_S0: 0U	,$; ; downshift data prior to integration.
	    Dshift_S1: 0U	,$; 
	    Dshift_S2: 0U	,$; 
	    Dshift_S3: 0U	,$; 

	    Ashift_S0: 0U	,$; upshift accumulated data before packing. 0..7 bits.
	    Ashift_S1: 0U	,$; 
	    Ashift_S2: 0U	,$; 
	    Ashift_S3: 0U	,$; 
	    Ashift_SI: 0U	,$; 
 
	    fftDropSt: 0U	,$; fft to drop at the start.
	     tsPhase : 0U	,$; test signal info (if xxsel=3)
	     tsFreqH : 0U	,$; 
	     tsFreqL : 0U	,$; 
	       tsCwA : 0U	,$; 
	       tsCwB : 0U	,$; 
         tsNoiseA: 0U	,$; 
         tsNoiseB: 0U	,$;
; version 2 additions
		      dLo: 0U   ,$; digital mixing lo
		 dLoPhase: 0U   ,$; for pos a,b phase difference
		   hrMode: 0U   ,$; hires mode
		   hrDec : 0U   ,$; hires decimation
		  hrShift: 0U   ,$; hires shifting
		 hrOffset: 0U   ,$; dlpf offset
		    hrLpf: 0U   ,$; hires low pass filter
		  hrDwell: 0U   ,$; hires low pass filter
		    hrInc: 0U   ,$; hires low pass filter
;  pjp additions 30jun08
		 blanksel: 0U   ,$; gpio pin for extern blank 0xffff=none
		 blankper: 0U   ,$; 0-use extBlnkTime.>0# ticks to blank after
	   ovfadc_thr: 0U   ,$; # adcOvf before blank. 0xffff=off
     ovfadc_dwell: 0U   ,$; # ticks to blank after ovfadc occurs.

		   calsel: 0U   ,$; gpio pin for cal input. 0xf--> no cal
		 calphase: 0U   ,$; 0 to FCNT-1 when cal transitions in dump
		   calctl: 0U   ,$; B0=1 cal on, B1=1 --> winking cal
		    calon: 0U   ,$; # dumps for cal on

		   caloff: 0U   ,$;  # dumps for cal off
           fill1 : 0U   ,$;
           fill2 : 0U   ,$;
           fill3 : 0U   $;
}
;
; pdev_hdr_ao added 04aug11
; b version with bytearr to read from disc,
; other version with strings to use
PDEV_HDRAO_VER='1.00'
a={pdev_hdraob ,$
		   hdrVer: bytarr(4) ,$;
     bandIncrFreq: 0L        ,$; 0=bandflipped,1 band increases in freq
            cfrHz: 0D        ,$; center of band	
         bandWdHz: 0D        ,$; 1/ sampling freq after dlpf	
           object: bytarr(16),$; source name
         frontEnd: bytarr(8) ,$; alfa, lbw etc..
           raJDeg: 0D        ,$; req ra J2000 start of scan degrees
          decJDeg: 0D        ,$; req dec J2000 start of scan degrees
            azDeg: 0D        ,$; azimuth at start
            zaDeg: 0D        ,$; za at start
             imjd: 0L        ,$; start of scan mjd integer days
             isec: 0L        }; integer secs from imjd start of scan
a={pdev_hdrao  ,$
		   hdrVer: ''        ,$; "1.00" '' ==> not present
     bandIncrFreq: 0L        ,$; 0=bandflipped,1 band increases in freq
            cfrHz: 0D        ,$; center of band	
         bandWdHz: 0D        ,$; 1/ sampling freq after dlpf	
           object: ""        ,$; source name
         frontEnd: ""        ,$; alfa, lbw etc..
           raJDeg: 0D        ,$; req ra J2000 start of scan degrees
          decJDeg: 0D        ,$; req dec J2000 start of scan degrees
            azDeg: 0D        ,$; azimuth at start
            zaDeg: 0D        ,$; za at start
             imjd: 0L        ,$; start of scan mjd integer days
             isec: 0L        }; integer secs from imjd start of scan
;
; info in dump.. this is not the order disc
;
a={pdev_hdrdump, $	
	 seqNum	 : 0U	,$ ; wraps at 64K
	 fftAccum: 0U   ,$ ; number actually done.. in case of blanking
     calOn   : 0    ,$ ; true if set during any part of integration.
	 adcOverFlow: 0 ,$ ; 4 bits..
	 pfbOverFlow: 0 ,$ ; 4 bits..
	 satCntVShift:0 ,$ ; 4 bits..
     satCntAccS2S3:0,$ ;
     satCntAccS0S1:0,$ ;
     satCntAshftS2S3:0,$;
     satCntAshftS0S1:0 }
       
 PDEV_MAX_LEN  = 8192L			; max spectrum length
 XDUMP_HDR_SIZE= 1024L 			; hdr length at start of file (bytes)
 XDUMP_HDRV1   =    8L          ; long Offset start of users header.
 XDUMP_HDRV2   =   32L          ; long Offset start of users header.
 XDUMP_PDEVMAGICV1_VAL='deadbeef'XUL  ; magic value for pdev
 XDUMP_PDEVMAGICV2_VAL='feffbeef'XUL  ; magic value for pdev
 XDUMP_MAGIC_SP1_VAL='2e83fb01'XUL  ; magic value for sp1 section.
 RESV1_PSRVPHIL     = 1             ; bit set-->spectra bitflip and 
                                    ; 8bytehdr flip(phils psrv).
 PDEV_MAGIC_AOHDR_VAL='12345678'XUL ; if pdevhdr_ao present
;
;typedef struct {
;    FILE            **fp;                   // Array of file descriptors
;    u32             hdr[XDUMP_HDR_SIZE];    // File header
;    u16             *uhdr;                  // Pointer to user header
;    u16             iseq;                   // initial seqnum;
;    char            *fnbase;                // filename without seqnum
;    char            *fnroot;                // just name without path or seqn
;    u64             totallen;               // all blocks + header length
;    int             nfiles;                 // Number of files
;    u64             filesz;                 // First file size
;    u8              *blkbuf;                // temp buffer for reading blocks
;
;    //  sp1 specific stuff
;    int             len;                    // length of transform
;    u32             bhdr[2];
;    u16             revtab[PDEV_MAX_LEN];   // Bit reverse table 
;    u32             s0[PDEV_MAX_LEN];
;    u32             s1[PDEV_MAX_LEN];
;    s32             s2[PDEV_MAX_LEN];
;    s32             s3[PDEV_MAX_LEN];
;} pdev_file;
;
; structure to hold filename after parsing.
;
;   fnmI={pdevfnmpars,$
;            dir: '',$; directory name (with trailing /)
;          fname: '',$; basename of file
;           proj: '',$; first section
;          date : 0L,$; yyyymmdd
;           obs : '',$; 3rd section
;          brdNum:0 ,$; 0..6
;         bandNum:0 ,$; 0,1
;          grpNum:0 ,$; 0,1
;         seqNum: 0L}
; changed to mimick the .mas routines
   fnmI={pdevfnmpars,$
            dir: '',$; directory name (with trailing /)
          fname: '',$; basename of file
           proj: '',$; first section
          date : 0L,$; yyyymmdd
           src : '',$; 3rd section
          bm:0 ,$; 0..6
          band:0 ,$; 0,1
          grp:0 ,$; 0,1
          num: 0L}


