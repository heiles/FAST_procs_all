;+
;NAME: 
;galmix - compute galfa lo mixing freqs
;SYNTAX: mixI=galmix(skyCfr,narBandCfr,rfiSky,use275=use275,lo1Low=lo1Low,$
;                    print=print)
;ARGS:
;   skyCfr    : float  sky center frequency as set by first lo.
;   narBandCfr: float  center freq we want for narrow band spectra
;   rfiSky[n] : float  compute the IF locations for these sky frequencies
;   
;KEYWORDS:
;   use275:     if set then use 275 Mhz for IF1 (the default is 250 Mhz).
;   lo1Low:     if set then use a low side LO1. The default is a high side LO.
;   print:      if set then print out the values (cals galmixpr())
;RETURNS:
;   mixI[n]: {} structure holding the computed information (see below).
;
;DESCRIPTION: 
;   The user specifies the rf sky center frequency (as set by the first
;LO) and the center of the narrow band spectra. The routine will then 
;compute the first and and 2nd lo's to use. You can select an IF1 of 
;250 (default) or use 275Mhz (by setting /use275.). If lo1Low is set then
;the first LO will be a low side LO (the default is high side).
;
;   The array rfiSky contains a set of sky frequencies. The routine
;will compute where in the if1, if2 bands these frequencies will fall.
;
;   If the /print keyword is set then the data will be printed to stdout.
;You can pass mixI to galmixpr to print out the info at a later time.
;
;	The structure mixI[n] contains:
;
;IDL> help,mixI,/st
;   SKYF            FLOAT           1385.00  sky center freq (set by 1stLO)
;   NBF             FLOAT           1420.41  narrow band cfr
;   WBF             FLOAT           1439.16  wide band cfr
;   IF1             FLOAT           250.000  if1 used (250 or 275)
;   LO1             FLOAT           1635.00  first LO.
;   LO1SB           INT             -1       -1--> 1stlo high side,1-->loside
;   LO2             FLOAT           195.844  2nd lo frequency
;   RFI_SKY         FLOAT           1330.00  rfi sky freq
;   RFI_IF1         FLOAT           305.000  location in IF1 of rfi
;   RFI_IF2         FLOAT           109.156  location in IF2 of rfi
;
;EXAMPLE:
; 1. Center the RF at 1385 and the narrow band at 1420.4058. Use the
;    250Mhz IF for if1. Also look to see where the two faa radars (1330,1350)
;    fall in the IF band. This setup could be used for a piggy back
;    observering with the extra galactic crowd.
;
; skyCfr=1385.
; nbCfr =1420.4058
; rfiSky=[1330.,1350.]      ; look at where the 2 faa radars fall
; mixI=galmix(skyCfr,nbCfr,rfiSky,/print)
;
; the output is then :
;
;sky     nbCen   wbCen   if1 rfiSky  RfiIf1  rfiIf2   lo1         lo2
;1385.00 1420.41 1439.16 250 1330.00  305.00  109.16 1635.000000  195.844238
;1385.00 1420.41 1439.16 250 1350.00  285.00   89.16 1635.000000  195.844238
;
; 2. use the 275 Mhz IF1. Center the RF and the narrow band center at
;    1420.4058. This is a typical galactic setup with no piggy backing.
;
; skyCfr=1385.
; nbCfr =1420.4058
; rfiSky=[1330.,1350.]      ; look at where the 2 faa radars fall
; mixI=galmix(skyCfr,nbCfr,rfiSky,/print)
;

;
;SEE ALSO: galmixpr 
;
;-
function galmix,skyCfr,nbCfr,rfiSky,use275=use275,lo1low=lo1low,print=print
         
;
;   
;
    nfrq=n_elements(rfiSky)
    nbOffset=-18.75
    wbCfr   =nbCfr - nbOffset
    if1=(keyword_set(use275))?275.:250.
    lo1Sb=(keyword_set(lo1Low))?1:-1
    lo1=   skyCfr - (lo1sb*if1)
    lo2=   if1   - (skyCfr - wbCfr)*lo1sb
    if1Rfi= if1 + (rfiSky*1.-skyCfr)*lo1sb
    if2rfi=if1rfi-lo2 
;
;   now compute the folding
;

    a={  skyF: skyCfr ,$
            nbF: nbCfr ,$
             wbF: wbCfr ,$
              if1: if1 ,$
              lo1: lo1 ,$
            lo1sb: lo1sb ,$ ; 1 unflipped, -1 flipped
              lo2: lo2 ,$

            rfi_sky: rfiSky[0],$
            rfi_If1:if1Rfi[0],$
            rfi_If2:if2Rfi[0]}
    rfiI=replicate(a,nfrq)
    rfiI.rfi_sky=rfiSky
    rfiI.rfi_if1=if1Rfi
    rfiI.rfi_if2=if2Rfi
    if keyword_set(print) then galmixpr,rfiI
    return,rfiI
end
