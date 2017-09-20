;+
;NAME:
;corsclcal - scale spectrum to K using the cals.
;SYNTAX: corsclcal,b,calI
;ARGS:      b[];{corget} data input from corget.. single integration
;                        or an array of integrations
;   calI[nbrds]:{corcal} structure returned from corcalonoff.
;or        calI:{corcalpf} struct returned from pfcalonoff
; DESCRIPTION
; scale spectra in b to Kelvins using the cal scale factors that  are
;stored in the calI structure.
;
;   The calI can come from two sources:
; 1. you called corcalonoff() 
;    In this case calI[nbrd] will be an array with one entry per board.
; 2. You called pfcalonoff() . This routine returns a single structure that
;    has the calI  for all the boards
; This routine will check to see which type is passed to it.
;
;EXAMPLES:
;
;;1. use corcalonoff.
;   calonscan=315200009L
;   istat=corcalonoff(lun,calI,scan=calonscan)
;;  input position on data 
;   poson=315200007L
;   istat=corinpscan(lun,bposon,scan=poson)
;;  scale this data to kelvins using our cals info
;   corsclcal,bposon,calI
;
;;2. use pfcalonoff
;   calonscan=315200009L
;   istat=pfcalonoff(lun,junk,pfcalI,scanOnAr=calonscan,/blda)
;;  input position on data 
;   poson=315200007L
;   istat=corinpscan(lun,bposon,scan=poson)
;;  scale this data to kelvins using our cals info
;   corsclcal,bposon,pfcalI
;;  
;-
pro   corsclcal,b,cals
;
    on_error,2
;
; check to see if we have pfcalI or corcal structs
;
    if n_tags(cals[0]) eq 3 then begin
;
;    corcal
        nbrds=cals[0].h.cor.numbrdsused
        for i=0,nbrds-1 do begin
;
;       always have a first sbc
;
            b.(i).d[*,0]= b.(i).d[*,0]*cals[i].calscl[0]
;
            if (cals[i].h.cor.numsbcout gt 1) then begin
             b.(i).d[*,1]= b.(i).d[*,1]*cals[i].calscl[1]
            endif
        endfor
    endif else begin
;
;   assume it's the pfcalI struct
;
        nbrds=cals.nbrds
        for ibrd=0,nbrds-1 do begin
;
;       always have a first sbc
;
            b.(ibrd).d[*,0]= b.(ibrd).d[*,0]*cals.calscl[0,ibrd]
            if (cals.pols[1,ibrd] ne 0) then  begin
                b.(ibrd).d[*,1]= b.(ibrd).d[*,1]*cals.calscl[1,ibrd]
            endif
        endfor
    endelse
    return
end
