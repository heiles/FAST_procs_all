;+
;NAME:
;masrdrsatplt - plot radar saturation data
;SYNTAX: masrdrsatplt,tpCln,tpRdr,beamList,rdrFrqAr,hdr,tit=tit,smo=smo,$
;           wait=wait,tm=tm,tpRdrN=tpRdrN,tpClnN=tpClnN,smo1inc=smo1inc
;ARGS:
;     tpCln[n,nbeams]: float total power for clean band
;tpRdr[n,nbeams,nrdr]: float peak power for radar frequencies
;    beamList[nbeams]: int   beam numbers for beams used
;      rdrFrqAr[nrdr]: float lower freq Mhz for each rdr freq used
;              hdr{}:        header from save file
;
;KEYWORDS:
;   tit: string  to add to standard title
;   smo: long    amount to smooth tpCln on first page. default:101
;  wait:         if set then wait for keypress between plots
; expTm: float   time for expanded plot
;durExp: float   duration in secs for expanded plot
;smo1inc: float  increment for smoothed clean band. def:.008
;
;RETURNS:
;                tm[n]: float time (secs) from start of scan
;tpRdrN[n,nbeams,nrdr]: float normalized to Tsys
;     tpClnN[n,nbeams]: float normalized to Tsys
;       frqRdr[lenfft]: float freq array for radar band
;       frqCln[lenfft]: float freq array for clean band
;-
pro masrdrsatplt,tpCln,tpRdr,beamList,rdrFrqAr,hdr,smo=smo,tit=tit,$
        wait=wait,expTm=expTm,durExp=durExp,tm=tm,tpRdrN=tpRdrN,tpClnN=tpClnN,$
        frqRdr=frqRdr,frqCln=frqCln
    forward_function monname
    common colph,decomposedph,colph


    verMaxdb=45
    utcToAo=4D/24D
    mjdToJd=2400000.5D
    beamAr=['beam0','beam1','beam2','beam3','beam4','beam5','beam6']
    if n_elements(tit) eq 0 then tit=''
    tosmo=(n_elements(smo) eq 0)?101:smo
    lenfft=(strsplit(hdr.tdim1,"(),",/extract))[0] 
    a=size(tpCln)
    npts=a[1]
    nbeams=(a[0] eq 1)?1:a[2]
    tmSmp=hdr.cdelt5
    tm=findgen(npts)*tmSmp
    caldat,(hdr.mjdxxobs + mjdToJd ) - utcToAo,mon,day,year
    ldate=string(format='(i2.2,a,i2.2)',day,monname(mon),year mod 100)
    nRdr=n_elements(rdrFrqAr)
    lrdr=strarr(nrdr)
    lrbw=string(format='(f5.3)',hdr.cdelt1*1e-6)
    if (n_elements(expTm) eq 0) || (expTm lt 0.) then begin
        ii=max(tpRdr,ind)
        expTm=tm[ind mod npts]
    endif
    if (n_elements(durExp) eq 0) || (durExp lt 0.) then begin
        durExp=.3
    endif
    eps=.1
    for i=0,nRdr-1 do begin
        case  1 of  
            (abs(rdrFrqAr[i]-1241.74) lt eps) || $
            (abs(rdrFrqAr[i]-1246.2) lt eps): lrdr[i]="AeroStat"
            (abs(rdrFrqAr[i]-1270) lt eps) || $
            (abs(rdrFrqAr[i]-1290) lt eps): lrdr[i]="Remy"
            (abs(rdrFrqAr[i]-1330) lt eps) || $
            (abs(rdrFrqAr[i]-1350) lt eps): lrdr[i]="Faa"
            else: lrdr[i]="Unknown"
        endcase
    endfor
;
;   normalize data to median 
;
    tpRdrN=tpRdr
    tpClnN=tpCln
    for ibm=0,nbeams-1 do begin &$
        tpClnN[*,ibm]/=median(tpClnN[*,ibm])     &$
        for irdr=0,nrdr-1 do begin &$
            tpRdrN[*,ibm,irdr]/=median(tpRdrN[*,ibm,irdr])   &$
        endfor &$
    endfor
        
;
;    page one degraded time resolution: increased sensitivity
;
    !p.multi=[0,1,nrdr+1]
;
;   make vertical scale min,max median +/- 10%
;
    fract=.03
    a=median(tpcln,dim=1)
    amin=min(a,max=amax)
    ver,amin*(1.-fract),amax*(1.+fract)
    cs=1.7
    hor
    col=lonarr(10)+2
;
;   the smoothed clean band
;
    inc=(n_elements(smo1inc) eq 0)?.009 :smo1inc
    ver,.99,1+inc*9
    stripsxy,tm,tpClnN,0,inc,/step,smo=tosmo,charsize=cs,$
        xtitle='time [secs]',ytitle='total pwr [Tsys]',$    
        title=string(format=$
        '(a,1x,a," TotPwr [1375-1525Mhz] smooth to ",f5.1," ms")',$
            tit,ldate,toSmo*tmSmp*1000.)
    ln=round(32./(nrdr+1) *1.1)
    xp=.04
    xpinc=.09
    for i=0,nbeams-1 do begin
        note,ln,beamAr[beamList[i]],xp=xp+xpinc*i,col=colph[i+1]
    endfor
;
;   now loop over the radars
;
    smpIpp=round(.02/tmSmp + .5)            ; number samples 1 radar ipp
    nn=long(npts/smpIpp)
    ii=(lindgen(nn)+ .5)*smpIpp
;
;
    cs=1.7
    fract=.03
    ver,0,verMaxDb
    hor
    col=lonarr(10)+2
    ii=(lindgen(nn)+ .5)*smpIpp
    for irdr=0,nrdr-1 do begin
        y=max(reform(tpRdrN[0L:nn*smpIpp-1,*,irdr],smpIpp,nn,nbeams),dim=1)
        stripsxy,tm[ii],alog10(y)*10,0,0,/step,charsize=cs,$
            xtitle='time [secs]',ytitle='pkPwr [dbTsys]',$  
            title='Peak power vs tm about ' + lrdr[irdr] + " radar"
    endfor

    if keyword_set(wait) then begin
        print,'enter to continue, s=stop,q=quit plotting'
        key=checkkey(/wait)
        if (key eq 's') || (key eq 'S') then stop
        if (key eq 'q') || (key eq 'Q') then return
    endif
;
; page 2 normalize to Tsys, show about peaks
;

;
    ii=where( abs(tm - expTm) lt durExp/2.)
    !p.multi=[0,1,nrdr+1]
    dt=.15
    ver,.95,1.3
    inc=.04
    stripsxy,tm[ii],tpclnN[ii,*,*],0,inc,/step,charsize=cs,$
        xtitle='time [secs]',ytitle='total pwr linear',$    
        title=tit + ' ' + ldate + ' TotPwr [1375-1525] Normalized to Tsys'
    for i=0,nbeams-1 do begin
        note,ln,beamAr[beamList[i]],xp=xp+xpinc*i,col=colph[i+1]
    endfor
    ver,0,verMaxDb
    for irdr=0,nrdr-1 do begin
        stripsxy,tm[ii],alog10(tpRdrN[ii,*,irdr])*10,0,0,/step,charsize=cs,$
        xtitle='time [secs]',ytitle='Peak pwr [dbTsys]',$   
        title='Pk pwr (' + lrbw +'MHz RBW) about ' + lrdr[irdr] + ' radar'
    endfor
;
    return
end
