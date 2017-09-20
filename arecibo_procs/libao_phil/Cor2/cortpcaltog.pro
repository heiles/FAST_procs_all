;+
;NAME:
;cortpcaltog - compute total power for toggling cals
;SYNTAX:nrecs=cortpcaltog(lun,tpon,tpoff,scanst=scanst,frq=frq,hdr=hdr,$
;                         verb=verb,calonInd=calOnind,median=median)
;ARGS:
;   lun int  for file to read
;KEYWORDS:
;   scanst: long scan to position to. 0, -1 --> no position
;   verb  :      pass to corblauto, -1--> plot fits
;   ndeg  :      pass to corblauto. poly fit deg. def=1
;   fsin  :      pass to corblauto. sin fit order. def=6
;  median :      if set then use median when averaging
;RETURNS:
;ncals: long    number of cal toggles found (nrecs/2)
;tpon[ncals,nsbc,npol] : float total power cal on
;tpoff[ncals,nsbc,npol]: float total power cal off
;frq[nsbc]: float  freq Mhz for center freq each sbc.
;hdr[nsbc]: {hdr}  return headers from first rec
;calOnInd:  long  0--> first rec calon, 1--> 2nd rec cal on
;
;DESCRIPTION:
;   Process a scan where the cal is toggling on/off each record.
;Steps:
;   - input the records of scan with hanning smoothing
;   - compute bavg=calOnAvg/calOffAvg.. this removes bandpass
;   - fit 6 order harmonic, 1 order poly to bavg using corblauto.
;     create mask of all points with residuals < 3 sigma in fit.
;   - for each record:
;     compute totalPwr over mask. place in tpon or tpOff
;-
;
function cortpcaltog,lun,tpon,tpoff,scanst=scanst ,frq=frq,hdr=hdr,$
          verb=verb,ndeg=ndeg,fsin=fsin,maxrecs=maxrecs,calOnInd=calOnInd,$
          median=median
    
    verb=keyword_set(verb)?verb:0
    fsin=keyword_set(fsin)?fsin:6
    deg =keyword_set(ndeg)?ndeg:1
    maxrecs=keyword_set(maxrecs)?maxrecs:500
    nsig=3. 
;
    scanL=keyword_set(scanSt)?scanSt:0
    scanL=(scanL le 0)?0:scanL
    if ((istat=corinpscan(lun,b,/han,scan=scanl,maxrecs=maxrecs)) eq 0) then begin
        print,'Error inputing scan.. status:',istat
        return,0
    endif
    nsbc=b[0].b1.h.cor.NUMBRDSUSED
    npol=b[0].b1.h.cor.numsbcout
    nrecs=n_elements(b)
    nrecsOn=nrecs/2
    frq=fltarr(nsbc)
    hdr=replicate(b[0].b1.h,nsbc)
    for i=0,nsbc-1 do begin
        frq[i]=corhcfrtop(b[0].(i).h)
        hdr[i]=b[0].(i).h
    endfor
    tpon =fltarr(nrecsOn,nsbc,npol)
    tpoff=fltarr(nrecsOn,nsbc,npol)

    b=reform(b,2,nrecsOn)
    tp1=median(b[0].b1.d[*,0])
    tp2=median(b[1].b1.d[*,0])
    ion=(tp1 gt tp2)?0:1
    ioff = (ion + 1) mod 2
    calOnInd=ion
    bon=reform(b[ion,*])
    boff=reform(b[ioff,*]) &$
    if keyword_set(median) then begin
        br=cormath(cormedian(bon),cormedian(boff),/div) &$
    endif else begin
        br=cormath(coravg(bon),coravg(boff),/div) &$
    endelse
    istat=corblauto(br,bf,maskused,coef,nsig=nsig,deg=deg,fsin=fsin,verb=verb)
    for isbc=0,nsbc-1 do begin &$
        for ipol=0,npol-1 do begin &$
            m=maskused.(isbc)[*,ipol] &$
            ii=where(m eq 1,mt) &$
            for irec=0,nrecsOn-1 do begin &$
            tpOn[irec,isbc,ipol]=(total(bon[irec].(isbc).d[ii,ipol]))/mt &$
            tpOff[irec,isbc,ipol]=(total(boff[irec].(isbc).d[ii,ipol]))/mt &$
            endfor &$
        endfor &$
    endfor
    return,nrecson
;

end
