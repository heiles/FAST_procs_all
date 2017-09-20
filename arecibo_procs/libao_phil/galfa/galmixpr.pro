;+
;NAME: 
;galmixpr - formatted print of galmix() data.
;SYNTAX: galmixpr,mixI,notitle=notitle
;ARGS:
;   mixI[n] : {}float  info returned by galmix()
;KEYWORDS:
;   notitle: if set then don't print the title. This is handy if you 
;            are calling galmixpr multiple times and you only want
;            one heading.
;DESCRIPTION: 
;   Print the info returned by galmix() to std out.
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
; mixI=galmix(skyCfr,nbCfr,rfiSky)
;
; galmixpr,mixI
; the output is then :
;
;sky     nbCen   wbCen   if1 rfiSky  RfiIf1  rfiIf2   lo1         lo2
;1385.00 1420.41 1439.16 250 1330.00  305.00  109.16 1635.000000  195.844238
;1385.00 1420.41 1439.16 250 1350.00  285.00   89.16 1635.000000  195.844238
;
;SEE ALSO: galmix
;-
pro galmixpr,rfiI,notitle=notitle

    n=n_elements(rfiI)
    tit=$
'sky     nbCen   wbCen   if1 rfiSky  RfiIf1  rfiIf2   lo1         lo2'
 
;xxxx.xx xxxx.xx xxxx.xx xxx xxxx.xx xxxx.xx xxxx.xx xxxx.xxxxxx xxxx.xxxxxx

    if not (keyword_set(notitle)) then print,tit
    for i=0,n - 1 do begin
        rf=rfiI[i]
        lab=string(format='(3(f7.2,1x),i3,1x,3(f7.2,1x),2(f11.6,1x))',$
            rf.skyf,rf.nbf,rf.wbf,long(rf.if1),rf.rfi_sky,rf.rfi_if1,$
                rf.rfi_if2,rf.lo1,rf.lo2)
        print,lab
    endfor
    return
end
