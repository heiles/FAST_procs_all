;
function mcalinp1,lun,type,maskind,scan=scan

    if keyword_set(scan) then begin
        scanl=scan
        if (poscan(lun,scanl,1) ne 1) then $
        message,'cannot find scan:'+string(scanl)
    endif else begin
        scanl=0
    endelse
    han=1
    if (corinpscan(lun,boff,brawOff,/sum,han=han) eq 0 ) then $
            message,'error inputs scan:' + string(scanl)
    if (string(boff.b1.h.proc.car[*,0])  ne 'off') then $
            message,'1st scan not a cal off'
    if (corinpscan(lun,bon,brawOn,/sum,han=han) eq 0 ) then $
            message,'error inputing calon scan:'
    if (string(bon.b1.h.proc.car[*,0])  ne 'calon') then $
            message,'2nd scan not a cal on scan'
;
;   fill in meascal struct. 4 entries since 4sbc/board
;
    ret=replicate({meascal},4)
    for i=0,3 do begin
        ret[i].freq =corhcfrtop(boff.(i).h)
        ret[i].type=type
        ret[i].brd =i
        ret[i].scan=boff.(i).h.std.scannumber
        ret[i].spOn =bon.(i).d
        ret[i].spOff=boff.(i).d
        ret[i].tpOn =bon.(i).h.cor.lag0pwrRatio
        ret[i].tpOff=boff.(i).h.cor.lag0pwrRatio
        ret[i].spCal=bon.(i).d/boff.(i).d - 1.
        ret[i].tpCal[0]=median(ret[i].spCal[*,0])
        ret[i].tpCal[1]=median(ret[i].spCal[*,1])
    endfor
    return,ret
end
