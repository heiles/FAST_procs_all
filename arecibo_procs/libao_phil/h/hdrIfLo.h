;
; if1 info
;
;
; first status word
;
;typedef struct {
;    unsigned int    rfNum     :5;   /* rf number 1->16*/
;    unsigned int    ifNum     :3;   /* 1--> 5*/
;    unsigned int    hybridIn  :1;   /* 1--> 10ghz hybrid in*/
;    unsigned int    lo1Hsd    :1;   /* 1--> lo1 is high side lo*/
;    unsigned int    lbwLinPol :1;   /* 1-->linear pol lbw*/
;    unsigned int    syn1RfOn  :1;   /* 1--> synth outputs rf*/
;    unsigned int    syn2RfOn  :1;   /* 1--> synth outputs rf*/
;    unsigned int    lbFbA     :9;   /* lb filter used polA*/
;    unsigned int    lbFbB     :9;   /* lb filter used polB*/
;    unsigned int    useFiber  :1;   /* 1--> come down on fiber*/
;    } IF1_HDR_STAT1;
;
;   2nd status word
;
;typedef struct {
;    unsigned int    calRcvMux :4;   /* rcv num for mux 0..15*/
;    unsigned int    calType   :4;   /* type of cal used 0..15. def:if1Con.h*/
;
;    unsigned int    ac1PwrSw  :4;   /* 1--> on . 3 devices*/
;    unsigned int    ac2PwrSw  :4;   /* 1--> on . 4 devices*/
;
;    unsigned int    zmNormal  :1;   /* 1--> not switched*/
;    unsigned int    zmDiodeOn :1;    /* 1--> zm diode on*/
;    unsigned int    zmDiodeToA:1;   /* 1--> added to chan A*/
;
;    unsigned int    sbShClosed:1;   /* 1--> sband shutter closed*/
;    unsigned int    lo2Hsd    :4;   /* bitmap 1=hisd. b0 1st syn*/
;    unsigned int    shClosed  :1;     /* 1--> non-sband  sband shutter closed*/
;    unsigned int    cbLinPol  :1;   /* 1-> cband linear, 0->cband circular*/
;    unsigned int    alfaFb    :1;   /* 0 wb, 1-filter in (100 Mhz)*/
;    unsigned int    free      :1;   /* no longer in use*/
;    unsigned int    if750nb   :1;   /* 1--> if1 750 narrow band filter*/
;    unsigned int    if2ghzwb  :1;   /* 1--> 2_12 ghz if wide band (2ghz)*/
;    unsigned int    terAcOn   :1;   /* 1 --> tertiary ac is on */
;    unsigned int    tilt      :1;   /* 1 mon tilt, 0 montemp*/
;    } IF1_HDR_STAT2; 
;
;  attenuators
;
a={hdrif1attn,					     $
               rf: bytarr(2,/nozero),$;polA/B rf attn 1 db steps 0..11
              iff: bytarr(2,/nozero),$;polA/B if attn 1 db steps 0..11
               zm: bytarr(2,/nozero),$;polA/B zm attn .1 db steps 0..15=0 1.5db
          zmNDLev:                0B,$;zm noise diode level 0..165. .1db steps
             fill:                0B}
;
;  if1 header structure
;
a={hdrif1, 					         $
              st1:             '0'XL,$;first stat word 
              st2:             '0'XL,$;2nd   stat word 
            rfFrq:               0.D,$;rf Freq topoCentric hz
              lo1:               0.D,$;1st lo in hz
             attn:      {hdrif1attn},$; attenuators 
           pwrDbm: fltarr(2,/nozero),$;power meter polA,B in dbm
       pwrTmStamp:                0L,$;second midnite pwr meter reading
          hybLoPh:                0B,$;10ghz lo phase offset binary units 1
         hybSigPh:                0B,$;10ghz signal phase offset binary units
             fill:  bytarr(2,/nozero)}
;
; if2 header info
;
;
;  if2 status word.
;
;ztypedef struct {
;    unsigned int    ifInpFreq :2;   /*inp freq. 0,1,2,3->spare,300,750,1500*/
;    unsigned int    vlbaInpFrq:1;   /* 0-750,1:2000                        */
;    unsigned int    xferNormal:1;   /* 1-normal, 0-switched                */
;    unsigned int    sbDopTrack:1;   /* 1--> true, 0 false                  */
;    unsigned int    noiseSrcOn:1;   /* 1--> on, 0 off                      */
;    unsigned int    dualPol30 :1;   /* 30mhzIf 2 pol, 1-true, 0 - 4 polA   */
;    unsigned int    vis30Mhz  :1;   /* 1--> greg, 0 ch                     */
;    unsigned int    calttlSrc :4;   /* 1-->8 cal ttl level source          */
;    unsigned int    pwrMToIf  :1;   /* power meter swithed to IF input     */
;    unsigned int    unused    :19;
;    } IF2_HDR_STAT1;
;
;   status word 1 for each mixer
;
;typedef struct {
;    unsigned int    synDest  :2;   /* 1-260to30,2-vlba/sb,3-mixers,0-fp    */
;    unsigned int    mixerCfr :2;   /*mixFreq. 0,1,2,3->750,1250,1500,1750  */
;    unsigned int    ampInpSrc:2;   /*0,1=syn,2=heliax,3=300 if             */
;    unsigned int    ampExtMsk:7;   /* bitmask 1-> ext input, 0-> from if/lo*/
;    unsigned int    unused   :19;
;    } IF2_HDR_STAT4;
;
;  if2 stucture
;
a={hdrif2,						     $
          synFreq: dblarr(4,/nozero),$; 4 synth freq in hZ 
              st1:                0L,$; stat word, general 
              st4: lonarr(4,/nozero),$;stat 1 for each mixer 
           pwrDbm: fltarr(2,/nozero),$; power meter polA,B dbm
       pwrTmStamp:                0L,$; seconds from midnite when pwr meas 
             gain: bytarr(2,/nozero),$;gain polA  -11 to 30 db !!! unsigned!!
             fill: bytarr(6,/nozero)}
;
; main struct
;
a={hdriflo,	   id: bytarr(4,/nozero),$; "iflo" no null terminated
	          ver: bytarr(4,/nozero),$; "xx.x "
              if1:          {hdrif1},$; if1 lo 
              if2:          {hdrif2},$; if2 lo 
             fill:bytarr(8,/nozero)}
;
;  structure to read in cal data
;
; caltypeorder is: lcor,hcor,lxcal,hxcal,luncor,huncor,l90cal,h90cal
;				   same as the index of calType above
;
a={calFrqEntry, freq:   0.,               $;freq Mhz
			    cval: fltarr(2,8)        }; (pola/b, caltype)
;

