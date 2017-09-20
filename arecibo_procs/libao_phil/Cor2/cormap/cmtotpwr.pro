;+
;NAME:
;cmtotpwr   - compute total power for a map
;
;SYNTAX:  mtp=cmtotpwr(m,chn1,ch2,mask=mask)
;
;ARGS:
; m[2,nsmp,nstrips] : map freq structure array 
;              chn1 : first freq chn for average. count from 1
;              chn2 : last freq chn for average. count from 1
;ARGS:
;mask[m]:   {cormask} mask to use when computing total power.
;                     If supplied, then ignore chn1,chn2. The dimension
;                     m can be:
;                     1: use same mask for entire map
;               nstrips: use same different mask for each strip
;          nsmp*nstrips: use different mask for each sample
;
;RETURNS:
;   mtpavg[2,nsmp,nstrips]: {cormaptp} return array of total power
;
;
;DESCRIPTION:
;   Average frequency channels chn1 through chn2 of the map and return
;in the mtp structure. It is identical to the m[] structure except that
;the m.d[] frequency data is replaced by a single number which is the
;averaged total power.
;
;EXAMPLE:
;   assume m[2,31,21]  is a map with 2 polarizations, 31 samples per strip, 
;21 strips, and 1024 frequency channels. Then the call :
;   mtp=cmtotpwr(m,100,900)
;returns the struct mtp with mtp.d the total power averaged over channels
;100:900.
;-
function cmtotpwr,m,chn1,chn2,mask=maskAr
;
    a=size(m)
    if a[0] eq 2 then begin
        nstrips=1
        nsmp   =a[2]
    endif else begin
        nstrips=a[3]
        nsmp   =a[2]
    endelse
    nchn   =(size(m[0,0,0].d))[1]
    nmask=n_elements(maskar)
    if nmask gt 0 then begin
        usemask=1
        incOnStrip=0
        incOnSmp  =0
        if (nmask eq nstrips)      then incOnStrip=1
        if (nmask eq nstrips*nsmp) then incOnSmp  =1
    endif else begin
        usemask=0
        if (chn1 lt 1 ) or (chn2 lt 1) or (chn1 gt nchn) or (chn2 gt nchn) or $
        (chn1 gt chn2) then begin
            print,'chn1,chn2 must be between,1 and ',nchn
            return,''
        endif
    endelse

    mtpstr={ h :m[0,0,0].h,$
             p :m[0,0,0].p,$
             az:m[0,0,0].az,$
             za:m[0,0,0].za,$
             azerrasec:m[0,0,0].azerrasec,$
             zaerrasec:m[0,0,0].zaerrasec,$
             rahr:m[0,0,0].rahr,$
             decdeg:m[0,0,0].decdeg,$
             calscl:m[0,0,0].calscl,$
             chnavg: fltarr(2),$    ; start,end channels used.. 1 based..
             d     :0. }
    npol=2
    mtp=replicate(mtpstr,npol,nsmp,nstrips)
    mtp.h=m.h
    mtp.p=m.p
    mtp.az=m.az
    mtp.za=m.za
    mtp.azerrasec=m.azerrasec
    mtp.zaerrasec=m.zaerrasec
    mtp.rahr     =m.rahr
    mtp.decdeg   =m.decdeg
    mtp.calscl   =m.calscl
    if not usemask then begin
       mtp[*,*,*].chnavg[0]=chn1
     mtp[*,*,*].chnavg[1]=chn2
    mtp[0,*,*].d =reform(total(m[0,*,*].d[chn1-1:chn2-1],1),1,nsmp,nstrips)/$
            (chn2-chn1+1)
    mtp[1,*,*].d =reform(total(m[1,*,*].d[chn1-1:chn2-1],1),1,nsmp,nstrips)/$
            (chn2-chn1+1)
;
;    use mask, do one at a time
;
    endif else begin
        if (not incOnStrip) and (not incOnSmp) then begin
            ind=where(maskAr[0].b1 gt .5,count)
            nscl=1./count
        endif
        for istrip=0,nstrips-1 do begin
            if incOnStrip then begin
                im=istrip   ; mask ind to use
                ind=where(maskAr[im].b1 gt .5,count)
                nscl=1./count
                mtp[*,*,istrip].chnavg[0]=count         ; number bins used
                mtp[*,*,istrip].chnavg[1]=count         ; number bins used
            endif
            for ismp=0,nsmp-1 do begin
                if incOnSmp then begin
                    im=(istrip*nsmp)+ismp   ; mask ind to use
                    ind=where(maskAr[im].b1 gt .5,count)
                    nscl=1./count
                    mtp[*,ismp,istrip].chnavg[0]=count  ; number bins used
                    mtp[*,ismp,istrip].chnavg[1]=count  ; number bins used
                endif
                mtp[*,ismp,istrip].d= total(m[*,ismp,istrip].d[ind],1)*nscl
            endfor
        endfor
    endelse
    return,mtp
end
