;+
;NAME:
;alfawappharm - compute alfa,wapp harmonics
;SYNTAX: n=alfawappharm(rfCfr,freqList,harmList,maxHarm=maxHarm,rfidef=rfidef,$
;                       print=print, bpf=bpf)
;ARGS:
; rfCfr      : float    sky center frequency (Mhz) of alfa band
; freqlist[m]: float    sky frequency of birdies to check (Mhz) (also see
;                       rfidef keyword below).
;KEYWORDS:
; maxHarm:int   largest harmonic to use (default is 5).
;  rfidef:int   if this keyword is set then the known large interfering
;               frequencies are loaded into freqList and then used for the
;               computation. See below for a list of the frequencies included.
; print  :      if set then print out the results when done
; bpf[2] :float redefine the min,max frequency of the 250 Mhz IF
;               bandpass filter. The default is 200 to 300. Since the filter
;               is not infinitely sharp, you can try broadening it a bit.
;RETURNS:
;      n: int   number of harmonics found in the final band. This includes
;               any fundamentals
; harmList[n]: struct structure holding the harmonics info.
;
;DESCRIPTION:
;   Compute where harmonics fall in the alfa/wapp configuration. The
;user inputs the sky center frequency of the alfa band as well as 
;a list of frequencies that may create harmonics. The program computes
;where these frequencies and their harmonics end up in the final output band. 
;By default the program searches up to the 5th harmonic. You can change this 
;with the maxHarm keyword. 
;
;   The program sequence is:
;
;0. initialize the list to include all of the fundamental frequencies.
;1. Add all harmonics created by the dewar.
;2. Remove all frequencies outside the 1225-1525 bandpass filter.
;3. Compute harmonics created at the IF in the mixer.
;4. Remove all frequencies outside the 700 Mhz low pass filter.
;5. Create harmonics in the IF created by the fiber/distribution amp.
;6. remove all frequencies outside the 250Mhz bandpass filter
;7. Compute harmonics created by the amp after the bandpass filter and the 
;   a/d.
;8. Digitally downconvert to 0-100
;9. Compute where these frequencies map to on the sky.
;
;   The bpc  keyword lets you change the default 100 Mhz bandwidth of the
;250Mhz bandpass filter. The program assumes the filter is infinitely
;steep. You can widen the 100 Mhz to see if there are any nearby birdies
;that might alias in.
;
;   If the rfidef keyword is set (/rfidef), the program will load a list
;of known interferers into the rfiList variable and then proceed with the
;computation. The list includes:
; aerostat radar: 1241.75,1244.6,1256.5,1261.25
;     remy radar: 1270,1290
;      faa radar: 1330,1350.
;   puntaSalinas: 1232.7, 1247.7 (The 2 modeA freqs that don't overlap 
;                                 with the aerostat)
; 
;   The return structure harmList[] contains:
;RFCFR     FLOAT   1385.0 ; center frequency of alfa band
;BW250     FLOAT    100.0 ; bandwidth of 250Mhz bandpass filter
;MAXHARM   INT        5   ; maximum harmonic used for search
;FREQRF    FLOAT   1350.0 ; The rf frequency of the initial sky birdie
;FREQRFH   FLOAT   1350.0 ; The rf frequecy of the resulting harmonic
;FREQI     FLOAT    285.0 ; the IF frequency of the harmonic 
;FREQH     FLOAT     85.0 ; the harmonic frequency at base band
;HARMNUM   INT        0   ; the order of the harmonic 0=1= the fundamental
;STAGENAMH STRING    'sky'; The stage where the harmonic was created.
;STAGENAMI STRING    'sky'; The stage that preceded the harmonic creation
;
;   You can print out the harmonic list useing alfawappharmpr,harmList
;
;EXAMPLE:
; 1. pass in faa radar frequencies.
;
;   rfiFreq=[1330.,1350]
;   rfCfr=1385
;   n=alfawappharm(rfcfr,rfiFreq,harmL)
;   alfawappharmpr,harmL
;Alfa harmonics.  SkyFreq:1385.0 250BPwidth:100.0 MaxHarm: 5
;
;freqRfi freqSrc harmNum LocationCreated
;1350.0  1350.0     0    sky
;1405.0  1350.0     2    AmpAfter100MhzFilter_AtoD
;1380.0  1350.0     3    AmpAfter100MhzFilter_AtoD
;1375.0  1350.0     4    AmpAfter100MhzFilter_AtoD
;1410.0  1350.0     5    AmpAfter100MhzFilter_AtoD
;
; 2. use the default frequencies 
;
;n=alfawappharm(1375,freqList,harmL,/rfidef,/print)
;
;Alfa harmonics.  SkyFreq:1375.0 250BPwidth:100.0 MaxHarm: 5
;
;freqRfi freqSrc harmNum LocationCreated
;1330.0  1330.0     0    sky
;1350.0  1350.0     0    sky
;1415.0  1330.0     2    AmpAfterIFbpFilter_AtoD
;1375.0  1350.0     2    AmpAfterIFbpFilter_AtoD
;1340.0  1330.0     3    AmpAfterIFbpFilter_AtoD
;1400.0  1350.0     3    AmpAfterIFbpFilter_AtoD
;1405.0  1330.0     4    AmpAfterIFbpFilter_AtoD
;1325.0  1350.0     4    AmpAfterIFbpFilter_AtoD
;1350.0  1330.0     5    AmpAfterIFbpFilter_AtoD
;1400.0  1350.0     5    AmpAfterIFbpFilter_AtoD
;
;NOTES:
; 1. This program maps the sky frequency into the final bandpass. It does
;    not map the location of a birdie in the final bandpass back to the
;    sky frequency.
; 2. The harmonic number tells how fast the birdie will move as you move
;    the center frequency of the sky band. 
;-
function  alfawappharm,rfCfr,freqLInp,harmList,maxharm=maxharm ,verb=verb,$
            bpf=bpf,rfidef=rfidef,print=print
;
; go through the various steps
;
    forward_function alfawappharm1

    radarList=[1241.75,1244.6,1256.5,1261.25,1270,1290.,1330,1350.,$
               1232.7, 1241.6 ]
    maxHarmDef=5
    verb=keyword_set(verb)?1:0
    bw=100.
    filt1RfBndDef=[1220,1520]
    filt2If      =[0,700]       ; low pass filter
    filt3If      =(n_elements(bpf) eq 2)?bpf: [ 200,300] ; band pass
    lo1=rfCfr + 250.
    if n_elements(maxharm) eq 0 then maxharm=maxharmDef
    if keyword_set(rfidef) then freqLInp=radarList
;    print,freqLInp
    nfrqInp=n_elements(freqLInp)
;
;   harmonic list structure
;
    harmStr={ $
        rfCfr: 0. ,$ rf centerfreq of band
        bw250  : 0., $ bandwidth 250 Mhz filter
        maxHarm: 0 ,$ max harmonic searched
        freqRf: 0.  ,$ frequency input
        freqRfH:0.  ,$ the rf frequency that the harmonics shows up at
        freqI : 0.  ,$ frequency of harmonic
        freqH : 0.  ,$ frequency of harmonic
        harmNum: 0   ,$ harmonic number
       stageNamH: ''  ,$ stage H name
       stageNamI: ''   $ name for stageI
      }
;
;   put the initial freq in with harm=0 in harmList
;
    harmList=replicate(harmStr,nfrqInp)
    harmList.freqRf = freqLInp
    harmList.freqI  = freqLInp
    harmList.freqH  = freqLInp
    harmList.harmNum= 0
    harmList.stageNamH='sky'
    harmList.stageNamI='sky'
;
;  1. harmonics in dewar 
;
    stageNamI='sky'
    stageNamH='dewar'
    n=alfawappharm1(harmList.freqRf,harmList.freqI,maxHarm,harmI)
    if n gt 0 then begin
       alfawappharmfill,harmI,stageNamI,stageNamH,harmList
       if verb then begin
           print,'harmonics in dewar.'
           print,"num new/tot harm:",n,n_elements(harmList),harmI[2,*]
       endif
    endif
;
;  2. apply the rf bandpass filter filter
;
    ind=where((harmList.freqH ge filt1RfBndDef[0] ) and $
               (harmList.freqH le filt1RfBndDef[1] ),count)
    if count eq 0 then goto,norfi
    harmList=harmList[ind]
    if verb then begin
         print,"tot harm after RfFilter:",n_elements(harmList)
         print,harmList.freqH
    endif
;
;   now down convert using first lo
;
    harmList.freqI=lo1 - harmList.freqI
    harmList.freqH=lo1 - harmList.freqH
;
;   compute harmonics in mixer. input is all the old harmonics.
;
    stageNamH='mixer1'
    stageNamI='dewar'
    n=alfawappharm1(harmList.freqRf,harmList.freqH,maxharm,harmI)
    if n gt 0 then begin
       alfawappharmfill,harmI,stageNamI,stageNamH,harmList
       if verb then begin
           print,'harmonics in mixer.'
           print,"num new/tot harm:",n,n_elements(harmList),harmI[2,*]
       endif
    endif
;
;   now put low pass filter 0-700 on the data
;
    ind=where((harmList.freqH ge filt2If[0] ) and $
              (harmList.freqH le filt2If[1] ),count)
    if count eq 0 then goto,norfi
    harmList=harmList[ind]
    if verb then begin
         print,"tot harm after 700Mhz lowpass:",n_elements(harmList)
         print,harmList.freqH
    endif
;
;   now redo the harmonics. This is from fiber  and isolation amp
;   before the 100 Mhz filter downstairs.
;
    stageNamH='Fiber/IFamps'
    stageNamI='LoPass700'
    n=alfawappharm1(harmList.freqRf,harmList.freqH,maxharm,harmI)
    if n gt 0 then begin
       alfawappharmfill,harmI,stageNamI,stageNamH,harmList
       if verb then begin
           print,'harmonics in fiber/amp before 100 Mhz filter.'
           print,"num new/tot harm:",n,n_elements(harmList),harmI[2,*]
       endif
    endif
;
;   apply the 100 mhz filter centered at 250.
;
    ind=where( (harmList.freqH ge filt3If[0] ) and $
               (harmList.freqH le filt3If[1] ),count)
    if count eq 0 then goto,norfi
    harmList=harmList[ind]
    if verb then begin
         print,"tot harm after 250Bpfilt:",n_elements(harmList)
         print,harmList.freqH
    endif
;
; now redo the harmonics for an amp after the filter or the a/d
;
    stageNamH='AmpAfterIFbpFilter_AtoD'
    stageNamI='BP250'
    n=alfawappharm1(harmList.freqRf,harmList.freqH,maxharm,harmI)
    if n gt 0 then begin
       alfawappharmfill,harmI,stageNamI,stageNamH,harmList
       if verb then begin
           print,'harmonics after 100 Mhz filter a/d.'
           print,"num new/tot harm:",n,n_elements(harmList),harmI[2,*]
       endif
    endif
    if verb then begin
         print,"tot harm after A/D:",n_elements(harmList)
         print,harmList.freqH
    endif
;
;  now we need to down convert
;
    freqMod=harmList.freqH mod 100D
    freqDiv=long(harmList.freqH) / 100L
    ind=where(freqDiv mod 2 eq 1,count)
    if count gt 0 then freqMod[ind]=100-freqMod[ind] ; it's flipped
    harmList.freqH=freqMod
;
;  now compute the rf freq where the harmonic shows up at.
;
    harmList.freqRfH=rfCfr + bw/2 - harmList.freqH
    harmList.rfCfr=rfCfr
    harmList.bw250= filt3if[1]-filt3if[0]
    harmList.maxHarm= maxHarm
    if keyword_set(print) then  alfawappharmpr,harmlist
    return,n_elements(harmList)
norfi:
    harmList=''
    return,0
end 
;
function alfawappharm1,freqRf,freqIn,maxHarm,harmI
;
;   start at second harmonic
;
    nharm=maxHarm-1
    nfreq=n_elements(freqIn)
    harmI=fltarr(4,nfreq*nharm) ; [0 freq, [1 harm number 
    itot=0L
    for i=2,maxHarm do begin
            harmI[0,itot:itot+nfreq-1]=freqRf
            harmI[1,itot:itot+nfreq-1]=freqIn
            harmI[2,itot:itot+nfreq-1]=i*freqIn
            harmI[3,itot:itot+nfreq-1]=i
            itot+=nfreq
    endfor
    return,itot
end
;
; fill the harmonic structure
;
pro alfawappharmfill,harmI,namI,namH,harmL

    n=n_elements(harmI[0,*])
    h=replicate(harmL[0],n)
    h.freqRf   =reform(harmI[0,*])
    h.freqI    =reform(harmI[1,*])
    h.freqH    =reform(harmI[2,*])
    h.harmNum  =reform(harmI[3,*])
    h.stageNamH=namH
    h.stageNamI=namI
    harmL=[harmL,h]
    return
end
;freqRfi freqSrc harmNum LocationCreated 
;ffff.f  ffff.fbbbbii      xx
;f6.1 
pro alfawappharmpr,harmL

    n=n_elements(harmL)
    lab=string(format=$
'("Alfa harmonics.  SkyFreq:",f6.1," 250BPwidth:",f5.1," MaxHarm:",i2)',$
            harmL[0].rfCfr,harmL[0].bw250,harmL[0].maxHarm)
    print
    print,lab
    print
    print,"freqRfi freqSrc harmNum LocationCreated" 
    for i=0,n-1 do begin
    lab=string(format='(f6.1,2x,f6.1,4x,i2,4x,a)',$
            harmL[i].freqrfH,harmL[i].freqRf,harmL[i].harmNum,$
            harmL[i].stageNamH)
    print,lab
    endfor
    return
end
