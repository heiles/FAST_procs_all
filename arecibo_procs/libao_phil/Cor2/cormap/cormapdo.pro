; 
;cormapdo - standard processing of correlator map
; SYNTAX:
;      corampdo mi,m,totpwrd,cals 
; ARGS:
;      mi{cormapstr} - hold map info.. tells us how to process it.
;      m[2,m,n]{}  - where each {} is a board structure with header data
;                    returned from corget
;                    eg. m[0,0,0].d  is the data from a board
;    totpwrd[smpperstrip,numstrips]- float. map data averated pol, 
;                    baseline removed and average over frequency range.
; 
pro cormapdo,mi,m,cals,tpd,tsys,blfrqd,avgbl=avgbl,noscl=noscl
    
    if keyword_set(noscl) then begin
        scldata=0
        normal=0
    endif else begin
        scldata=1
        normal=1
    endelse
    lun=-1
    retbl=0
    if n_params() ge 6  then retbl=1
    avgbl=KEYWORD_SET(avgbl)
;
;   open the map
;
    openr,lun,mi.fname,/get_lun
;
;   input the map
;
    istat=cormapinp(lun,mi.scan,mi.sbc[0],mi.sbc[1],m,$
        cals)
    free_lun,lun
    if istat ne 1 then begin
        print,'error input map',mi.src,' from file:",mi.fname
        return
    endif
    a=size(m.d)
    frqchn=a[1]
    a=size(m)
    mi.ptsinstrip=a[2]
    mi.nstrips =a[3]
    mi.src     =string(m[0,0,0].h.proc.srcname)
    if  scldata then begin
        istat=cormapscl(m,cals,tsys)
        if istat ne 1 then begin
            print,'cormapscl returned error'
            return
        endif
    endif
;
;   baseline pol a, remove off channels
;
    cormapbl,reform(m[0,*,*].d,frqchn,mi.ptsinstrip,nstrips),mi.numbpedge,$
            mi.meanc1,mi.meanc2,bpa ,normal=normal
;
;   baseline pol b, remove off channels
;
    cormapbl,reform(m[1,*,*].d,frqchn,mi.ptsinstrip,nstrips),mi.numbpedge,$
            mi.meanc1,mi.meanc2,bpb ,normal=normal
;
;   average pol
;
    bp=(bpa+bpb)*.5
;
;   average over channels of interest
;
    tpd=total(bp[mi.avgcol1-1:mi.avgcol2-1,*,*],1)/(mi.avgcol2-mi.avgcol1+1)
    if retbl then begin
        if KEYWORD_SET(avgbl) then begin
            blfrqd=bp
        endif else begin
            a=size(bp)
            blfrqd=fltarr(a[1],a[2],a[3],2,/nozero)
            blfrqd[*,*,*,0]=bpa
            blfrqd[*,*,*,1]=bpb
        endelse
     endif

    return
end
