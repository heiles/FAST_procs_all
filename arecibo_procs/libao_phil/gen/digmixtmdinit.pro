;+
;NAME:
;digmixtmdinit - initialize structure for digital mixing
;SYNTAX: mixI=digmixtmdinit(smpFrq,newCfr)
;ARGS:
;  smpFrq: double   sample frequency of complex data.
;  newCfr: double   new Center frequency for baseband data.
;RETURNS:
;   mixI: {}        structure holding mixing info
;
;DESCRIPTION:
;   digmixtmdinit() initializes the mixI structure for calls to digmixtmd.
;The data to be mixed is assumed to be complex baseband data (centered at 0 freq).
; 	The user specifies smpFrq (in whatever units you want). This will define the time 
;spacing between individual complex samples (1/smpFrq).
;	The newCfr is the new center freq after mixing (in the same units as smpFrq).
;It should be between +/- smpFrq/2.  After mixing, this will be the new center of the
;band.
;	The mixI structure contains:
;** Structure <8c1ca8>, 4 tags, length=32, data length=32, refs=1:
;   SMPFRQ          DOUBLE       1.5000000e+08
;   NEWCFR          DOUBLE           68000000.
;   LOFRQ           DOUBLE          -68000000.
;   LOPHASE         DOUBLE         -0.52941176
;	
;  Each time digmixtmd is called, the lophase is updated to the correct phase for
;the next call to digmixtmd. This lets you make multiple calls to digmixtmd.
;Example:
;	Assume:
;	1. data complex sampled at 100 Mhz
;   2. you want to mix 30 Mhz to the center of the band
;   3. you want to do this for an entire files worth of data.
;	- open file
;	- mixI=digmixtmdinit(100e6,30e6)
;     bout=complexarr(maxsamples)
;     icur=0
;	- while ((nsamples=readbuf(bufInp)) != eof)
;		dout[icur:icur+nsamples-1]=digmixtmd(bufInp,mixI)
;       icur+=nsamples
;     endwhile
;-
function digmixtmdinit,smpFrq,newCfr
	mixI={ $
		smpFrq: smpFrq*1d ,$ ; in hz
        newCfr: newCfr*1d ,$;  new Center of baseband
        loFrq:-newCfr*1d ,$;  mixing freq
		loPhase   : 0d $; last phase of mix cosine
	}
	return,mixI
end
