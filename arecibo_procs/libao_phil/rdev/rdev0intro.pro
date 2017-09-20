;+
;NAME:
;rdev0Intro - Intro to using rdev routines.
;   
;       rdev is the radar processing version of jeff mocks pdev spectrometer.
;   Data is sampled, filtered, packed, and then output to disc. The disc
;   format consists of a 1024 byte header followed by packed binary data.
;       The header contains the standard pdev header:
;
;hdr.h1:{pdev_hdrpdev ,$
;    magic_num   : "deadbeef"XUL,$ ; unsigned long
;    magic_sp    : 0L          ,$ ; magic number for sp unsigned long
;    adcf        : 0L          ,$  ; adc clock freq Hz.
;    byteswapCode: 0L          ,$  ;
;    blkSize     : 0L          ,$  ; size of each block (integration)
;    nblksdumped : 0L          ,$  ; number of blocks dumped
;    beam        : 0L          ,$  ; from [pdev] section
;    subband     : 0L          }   ; 0,1 from [pdev] section
;
;   It is followed by the rdev specific header (this is currently being defined)
;
; aug11
;  aug11 format
;a={rdev_hdrsp ,$
;           decF  : 0U   ,$; 1=5 dec, 2=4 dec, 3=8 dec, 4=16 dec,5=32 dec
;;                           6=64,7=160
;         roundEna:0U  ,$; 0,1 enabled (now implemented)
;           tuner : 0U   ,$; tune word for mixing..2^16*(fout/fclock)
;        shiftMixer:0U   ,$; upshift before filter. 4 bits maxval
;           d1cntL: 0U   ,$; lower /upper 16 bits of samples to take
;           d1cntU: 0U   ,$; data block 1 (tx)
;
;
;           s2cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
;           s2cntU: 0U   ,$;  height  sampling count from rf pulse
;
;           d2cntL: 0U   ,$; lower /upper 16 bits of samples to take
;           d2cntU: 0U   ,$; data block 2 (data)
;
;           s3cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
;           s3cntU: 0U   , $; start
;           d3cntL: 0U   ,$; lower /upper 16 bits of samples to skip before
;           d3cntU: 0U    $; start
;
;    shift_fir_32m: 0U    $;
;    shift_fir_20m: 0U    $;
;    shift_fir_10m: 0U    $;
;     shift_fir_5m: 0U    $;
;   shift_fir_2_5m: 0U    $;
;     shift_fir_1m: 0U    $
;   }
;
;
;IDL BASICS:
;
;;  starting idl.. init rdev routines:
;;
;   idl
;   @phil
;   @rdevinit
;;
;;  some basic routines:
;;
;  hor ,0,1000      ; this will limit horizontal to 0 to 1000
;  hor              ; with no args this resets to auto scaling
;  ver ,-100,100    ; this will limit vertical scale to -100 to 100
;  ver              ; with no args this resets to auto scaling
;  !p.multi=[0,1,2] ; make 3 plot areas in the plot window (vertically)
;  !p.multi=0       ; reset to 1 plot in the window
;  plot,d           ; plot the array d
;  plot,frq,d       ; plot d versus frq
;;
;; To label a plot...
;;
;  plot,frq,d,title='This is the title',xtitle='freq',ytitle='volts'
;;
;;  to send the plot of x,y data to the postscript file:testfile.ps
;;
;   pscol,'testfile.ps',/full
;   plot,x,y
;   hardcopy
;   x
;;
;; to print the values in an array;
;;
; print,d[0:99]      ; first 100 pnts
;
;USING THE RDEV ROUTINES: 
;
;   idl             ; start idl
;   @phil           ; connect to phils routines
;   @rdevinit       ; initialize the rdev routines
;;
;; print info on the rdev routines:
;;
;  explain,rdevdoc     ; list of all the routines
;  explain,rdevopen    ; rdev documentation.
;;
;;  define the file to use
;;
;   file='/share/pdata/pdev/sp_tamara.20070423.b0a.00000.pdev'
;;
;;  open the file.. returns lun, and the header h.
;   lun=rdevopen(file,hdr)
;;
;;  look at the header
;;
;   help,hdr.h1,/st
;   print,hdr.h2
;;
;;  read 16384 samples: 
;;    returns number of points actually read in: npnts
;;    returns data in int array d[npnts]
;;
;   pntsRequested=16384L
;   npnts=rdevget(lun,hdr,pntsRequested,d)
;;
;; plot the first 1000 points of the data
;;
;   hor,0,1000
;   plot,d[*,0]   ;; I dig polA
;   oplot,d[*,1],col=colph[2]  ;; Q dig polA
;;
;;  plot a histogram of the data
;;
;    rdevhist,hdr,d
;
;;   input data, compute spectra and plot it
;;
;   naccum=rdevspc(lun,hdr,fftlen,spc,toavg=10,/plot)
;
;-
