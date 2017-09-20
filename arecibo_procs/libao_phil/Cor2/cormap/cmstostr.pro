;+
;NAME:
;cmstostr   - combine map datasets into an array.
;
;SYNTAX:    cmstostr,m,ind,marr,nmaps=nmaps,chn1=chn1,chn2=chn2
;
;ARGS:
;   m[2,nsmp,nstrips]: {cormap} map data for 1 map
;                 ind:  long    index for this map
;   marr[2,nsmp,nstrips,nmaps]:{corget} store maps here
;
;KEYWORDS:
;                chn1: long . first freq chn to keep. count from 0.def:0
;                chn2: long . last  freq chn to keep. count from 0.def:last
;               nmaps: long . if specified then allocate marr to hold
;                             this many maps.
;DESCRIPTION:
;   The data returned by cormapinp is an anonymous structure. This allows
;it to be dynamically generated. A drawback is that you can't combine
;different anonymous structures into an array. This routine allows
;you to place cormapinp array structures from calls into an array. Each
;map must be the same dimensions. The chn1,chn2 keywords allow you to 
;keeep only a subset of the frequency channels (to keep the memory usage
;down).
;
;EXAMPLE:
;   alloc=nmaps
;   for i=0,nmaps-1 do begin
;       istat=cormapinp(lun,scan,1,2,m,cals)          .. get the first record
;       cmstostr,m,i,marr,nmaps=alloc,chn1=951,chn2=1100
;       alloc=0
;   endfor
;-
pro cmstostr,m,ind,marr,nmaps=nmaps,chn1=chn1,chn2=chn2
;
    sm   =size(m)
    if keyword_set(nmaps) then begin
        nsmps  =sm[2]
        nstrips=sm[3]
        frqchn=n_elements(m[0,0,0].d) 
        if (n_elements(chn1) ne 0) or (n_elements(chn2) ne 0) then begin
            if n_elements(chn1) eq 0 then chn1=0
            if n_elements(chn2) eq 0 then chn2=frqchn-1
            c={  $
                    h :     m[0,0,0].h,$;
                    p :              0.,$;
                    az:              0.,$;
                    za:              0.,$;
                    azErrAsec:       0.,$;
                    zaErrAsec:       0.,$;
                    raHr:            0.,$;
                    decDeg:          0.,$;
                    calscl:          0.,$;
                    d : fltarr(chn2-chn1+1,/nozero)}
            marr=replicate(c,2,nsmps,nstrips,nmaps)
        endif else begin
            chn1=0
            chn2=frqchn-1L
            marr=replicate(m[0,0,0],2,nsmps,nstrips,nmaps)
        endelse
        smarr=size(marr)
        nsmps  =smarr[2]
        nstrips=smarr[3]
        marr.h.proc.iar[8]=lonarr(2,nsmps,nstrips,nmaps)+chn1
        marr.h.proc.iar[9]=lonarr(2,nsmps,nstrips,nmaps)+chn2
    endif
    iar8=marr[*,*,*,ind].h.proc.iar[8]
    iar9=marr[*,*,*,ind].h.proc.iar[9]
    marr[*,*,*,ind].h = m[*,*,*].h
    marr[*,*,*,ind].h.proc.iar[8]=iar8
    marr[*,*,*,ind].h.proc.iar[9]=iar9
    marr[*,*,*,ind].p = m[*,*,*].p
    marr[*,*,*,ind].az= m[*,*,*].az
    marr[*,*,*,ind].za= m[*,*,*].za
    marr[*,*,*,ind].azErrAsec= m[*,*,*].azErrAsec
    marr[*,*,*,ind].zaErrAsec= m[*,*,*].zaErrAsec
    marr[*,*,*,ind].raHr = m[*,*,*].raHr
    marr[*,*,*,ind].decDeg= m[*,*,*].decDeg
    marr[*,*,*,ind].calscl= m[*,*,*].calscl
    chn1=marr[0,0,0,0].h.proc.iar[8]
    chn2=marr[0,0,0,0].h.proc.iar[9]
    if (chn1 eq 0) and (chn2 eq marr[0,0,0,0].h.cor.lagsbcout-1) then begin
       marr[*,*,*,ind].d= m[*,*,*].d
    endif else begin
       marr[*,*,*,ind].d= m[*,*,*].d[chn1:chn2]
    endelse
    return
end
