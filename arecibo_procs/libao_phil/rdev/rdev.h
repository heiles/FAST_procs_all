; ; constants for pdev device.
; need to first include pdef
;
;
;a={rdev_hdrsp ,$
;		   decF  : 0U	,$; 1=5 dec, 2=4 dec, 3=8 dec, 4=16 dec,5=32 dec
;;                           6=64,7=160
;	     roundEna:0U  ,$; 0,1 enabled 
;		   tuner : 0U	,$; tune word for mixing..2^16*(fout/fclock)
;	    shiftCtrl: 0U	,$; number of bits to shiftup on output
;		   s1cntU: 0U	,$; upper /lower 16 bits of samples to skip before
;		   s1cntL: 0U	,$; start
;		   d1cntU: 0U	,$; upper /lower 16 bits of samples to take
;		   d1cntL: 0U	,$; data block 1 (tx)
;		   s2cntU: 0U	,$; sample offset startupper
;		   s2cntL: 0U	,$; lower
;		   d2cntU: 0U	,$; upper /lower 16 bits of samples to take
;		   d2cntL: 0U	 $; data block 2 (data)
;   }
;
;;a={rdev_hdrsp ,$
;;		   decF  : 0U	,$; 1=5 dec, 2=4 dec, 3=8 dec, 4=16 dec,5=32 dec
;;;                           6=64,7=160
;;	     roundEna:0U  ,$; 0,1 enabled 
;;		   tuner : 0U	,$; tune word for mixing..2^16*(fout/fclock)
;;	    shiftCtrl: 0U	,$; number of bits to shiftup on output
;;
;;		   d1cntU: 0U	,$; upper /lower 16 bits of samples to take
;;		   d1cntL: 0U	,$; data block 1 (tx)
;;
;;
;;		   s2cntU: 0U	,$; upper /lower 16 bits of samples to skip before
;;		   s2cntL: 0U	,$;  height  sampling
;;
;;		   d2cntU: 0U	,$; upper /lower 16 bits of samples to take
;;		   d2cntL: 0U	,$; data block 2 (data)
;;
;;		   s3cntU: 0U	,$; upper /lower 16 bits of samples to skip before
;;		   s3cntL: 0U	 $; start
;;   }
;  15jan10 format
;;a={rdev_hdrsp ,$
;;           decF  : 0U   ,$; 1=5 dec, 2=4 dec, 3=8 dec, 4=16 dec,5=32 dec
;;;                           6=64,7=160
;;         roundEna:0U  ,$; 0,1 enabled (now implemented)
;;           tuner : 0U   ,$; tune word for mixing..2^16*(fout/fclock)
;;		shiftMixer:0U   ,$; upshift before filter. 4 bits maxval
;;		shiftFir  :0U   ,$; upshift After  filter. 5 bits maxval
;;           d1cntL: 0U   ,$; lower /upper 16 bits of samples to take
;;           d1cntU: 0U   ,$; data block 1 (tx)
;;
;;
;;           s2cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
;;           s2cntU: 0U   ,$;  height  sampling count from rf pulse
;;
;;           d2cntL: 0U   ,$; lower /upper 16 bits of samples to take
;;           d2cntU: 0U   ,$; data block 2 (data)
;;
;;           s3cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
;;           s3cntU: 0U   , $; start
;;           d3cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
;;           d3cntU: 0U    $; start
;;   }
;  aug11 format
;;a={rdev_hdrsp ,$
;;           decF  : 0U   ,$; 1=5 dec, 2=4 dec, 3=8 dec, 4=16 dec,5=32 dec
;;;                           6=64,7=160
;;         roundEna:0U  ,$; 0,1 enabled (now implemented)
;;           tuner : 0U   ,$; tune word for mixing..2^16*(fout/fclock)
;;		shiftMixer:0U   ,$; upshift before filter. 4 bits maxval
;;           d1cntL: 0U   ,$; lower /upper 16 bits of samples to take
;;           d1cntU: 0U   ,$; data block 1 (tx)
;;
;;
;;           s2cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
;;           s2cntU: 0U   ,$;  height  sampling count from rf pulse
;;
;;           d2cntL: 0U   ,$; lower /upper 16 bits of samples to take
;;           d2cntU: 0U   ,$; data block 2 (data)
;;
;;           s3cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
;;           s3cntU: 0U   , $; start
;;           d3cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
;;           d3cntU: 0U   ,$; start
;;		
;;	shift_fir_32m: 0U   , $;
;;	shift_fir_20m: 0U   , $;
;;	shift_fir_10m: 0U   , $;
;;	 shift_fir_5m: 0U   , $;
;;   shift_fir_2_5m: 0U   ,$;
;;	 shift_fir_1m: 0U    $
;;   }
;
;  -------------------------------------------------
;  10nov11 format
;  140 Mhz clock
; decf                 decination
;  1    35   Mhz       4
;  2    20   Mhz       7
;  3    10   Mhz      14
;  4     5   Mhz      28
;  5     2.5 Mhz      56
;  6     1   Mhz    140.
;a={rdev_hdrsp ,$
;           decF  : 0U   ,$; 1=5 dec, 2=4 dec, 3=8 dec, 4=16 dec,5=32 dec
;                           6=64,7=160
;         roundEna:0U  ,$; 0,1 enabled (now implemented)
;           tuner : 0U   ,$; tune word for mixing..2^16*(fout/fclock)
;		shiftMixer:0U   ,$; upshift before filter. 4 bits maxval
;           d1cntL: 0U   ,$; lower /upper 16 bits of samples to take
;           d1cntU: 0U   ,$; data block 1 (tx)
;
;
;          s2cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
;           s2cntU: 0U   ,$;  height  sampling count from rf pulse
;
;           d2cntL: 0U   ,$; lower /upper 16 bits of samples to take
;           d2cntU: 0U   ,$; data block 2 (data)
;
;           s3cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
;           s3cntU: 0U   , $; start
;           d3cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
;           d3cntU: 0U   ,$; start
;		shift_fir: 0U   ,$; upshift after fir before readout 
;	     clip_ena: 0     $; clipping enabled
;   }
;
;  -------------------------------------------------
; updated sometime in 2012
;  140 Mhz clock
; decf                 decination
;  1    35   Mhz       4
;  2    20   Mhz       7
;  3    10   Mhz      14
;  4     5   Mhz      28
;  5     2.5 Mhz      56
;  6     1   Mhz    140.
;
;

a={rdev_hdrsp ,$
           decF  : 0U   ,$; 1=4 dec, 2=7 dec, 3=14 dec, 4=28 dec,5=56 dec
;                           6=140
         roundEna:0U  ,$; 0,1 enabled (now implemented)
           tunerL: 0U   ,$; tune word for mixing low 16 bits...2^16*(fout/fclock)
           tunerU: 0U   ,$; tune word for mixing upper 16 bits...2^16*(fout/fclock)
           d1cntL: 0U   ,$; lower /upper 16 bits of samples to take
           d1cntU: 0U   ,$; data block 1 (tx)
           s2cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
           s2cntU: 0U   ,$;  height  sampling count from rf pulse
           d2cntL: 0U   ,$; lower /upper 16 bits of samples to take
           d2cntU: 0U   ,$; data block 2 (data)
           s3cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
           s3cntU: 0U   , $; start
           d3cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
           d3cntU: 0U   ,$; start
		shift_fir: 0U   ,$; upshift after fir before readout. number of bits to shift 
	     gp_sel  : 0U   ,$; 0=gp0 selected
	     adc1_sel: 0U   ,$; 0= adc0 selected transmitter
	     adc2_sel: 0U    $; 1= adc1 selected receiver
		}


a={ rdev_hdr,$
	h1    : {pdev_hdrpdev},$
    h2    : {rdev_hdrsp}}
