;+
;NAME:
;imbpc - bandpass correct a days worth of data
;SYNTAX: dbpc=imbpc(d)
;ARGS:
;   d   :{imday}    days worth of data already input
;   dbpc:{imday}    same data after bandpass correction.
;-
function imbpc,d
;
; convert to linear, keep converted copy too.
;
    dl=d                    ; copy
    nfrq=(size(d.frql))[1]  ; number of frequencies
    mind=fltarr(401)        ; mimimum array. used  for each freq.
;
;   loop over frequencies
;
    for i=0,nfrq-1 do begin
        indlist=where(d.r.h.cfrdataMhz eq d.frql[i],count) ; this frequency 
        if count eq 0 then goto,botloop
        imgfrq,dl,dl.frql[i],dfrq
        imbpc1,dfrq
        dl.r[indlist].d=dfrq.r.d
botloop:
    endfor
    return,dl
end
;+
;imbpc1; - bandpass correct 1 freq range
;SYNTAX: imbpc1,d1
;ARGS:
;   d1  :{imday}    1 freq range, update in place
;-
pro imbpc1,d1
;
    imlin,d1                ; convert to linear
    mind=dblarr(401)        ; mimimum array. used  for each freq.
;
;   loop over frequencies
;
;
;       compute the minimum for each channel
;
        for j=0,400 do begin &$
            mind[j]=min(d1.r.d[j,*]) &$
        endfor 
;
;   normalize min base to by unity
    mind  =mind/(total(mind)/401.) ; normalize bp correction to 1
;
;   now divide each element this freq by the bp correction
;
        d1.r.d=mav(d1.r.d,1./mind)
;
;       load back into linear data for this freq
;
;
;   go back to db
;
    d1.r.d=alog10(d1.r.d)*10.
    return
end
