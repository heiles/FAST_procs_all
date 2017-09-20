pro SaveSpider_rhstk, Data, FileName, NDumps

;Stg1Path = getenv('GBTPATH')+'/polcal/stg1/sav/'
Stg1Path = ''

NData = N_elements(Data)

Ngood = 0
Nbad  = 0

for i = 0, NData-1 do begin
        
    ; SELECT ONLY THE GOOD PATTERNS...

    ; POL CAL SCANS HAVE >1 SUBSCAN...
    if ((*Data[i]).Nsubscan eq 1) then continue

    ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ; THIS MIGHT NOT BE TRUE WITH NEW SPIDER SCAN
    ; PROCEDURE!!!

    ; IS THIS WHERE THE PATTERN STARTS...
;    if (abs((*Data[i]).subscan[0].ZAOffSet) lt 0.325) AND $
;      ((*Data[i]).subscan[0].AZOffSet gt 0.325) $
    if (abs((*Data[i]).subscan[0].ZAOffSet) lt 1./60.) AND $
      ((*Data[i]).subscan[0].AZOffSet gt 1./60.) $
      then begin

        ; START NEW PATTERN...
        PatternIndx = i

    endif else begin

;        if N_elements(PatternIndx) eq 0 then patternindx = i

        ; ADD THIS POINTER TO THE PATTERN...
;        PatternIndx = [PatternIndx,i]
	PatternIndx = (N_elements(PatternIndx) eq 0) ? i : [PatternIndx,i]

        ; HAVE WE FILLED A PATTERN...
        if (N_elements(PatternIndx) eq 4) then begin

            ; IS THE PATTERN COMPLETE...
            legs = intarr(4)
            for j = 0, 3 do legs[j] = (*Data[PatternIndx[j]]).NSubScan
            complete = array_equal(legs,shift(legs,1))

            ;stop
            ; KLUDGE FOR SUN DATA...
            ;ndumps = ((*data[0]).sname eq 'sun_spillover') ? 900 : 80

            ; KLUDGE FOR AMANDA'S GOOF...
            ;if ((*data[0]).projid eq 'AGBT05C_031_13') then ndumps = 40
            ;if ((*data[0]).projid eq 'AGBT05C_031_07') then ndumps = 40
            ;if ((*data[0]).projid eq 'AGBT05C_031_26') then ndumps = 39

            ;for j = 0, 3 do $
            ;  complete = complete AND $
            ;             ((*Data[PatternIndx[j]]).NSubScan eq ndumps)

            if not complete then continue

            ; CONCATENATE THE PATTERN...
            for j = 0, 3 do $
              Strip = (N_elements(Strip) eq 0) $
                      ? (*Data[PatternIndx[0]]) $
                      : [Strip, (*Data[PatternIndx[j]])]

            ; ADD THE CALS...
            CalIndx = PatternIndx[[0,0,1,1,2,2,3,3]]+[-1,1,-1,1,-1,1,-1,1]

            ; IF THE FIRST CAL IS MISSING...
            BadStart = (CalIndx[0] lt 0)
            if not BadStart $
              then BadStart = ((*Data[CalIndx[0]]).NSubScan gt 1)

            ; THEN JUST COPY THE SECOND CAL TO THE FIRST...
            if BadStart then CalIndx[0] = Calindx[1]

            ; IF THE LAST CAL IS MISSING...
            BadEnd = (CalIndx[7] gt NData-1)
            if not BadEnd $
              then BadEnd = ((*Data[CalIndx[7]]).NSubScan gt 1)

            ; THEN JUST COPY THE SECOND TO LAST CAL TO THE LAST...
            if BadEnd then CalIndx[7] = Calindx[6]

            ; CONCATENATE THE CALS...
            for j = 0, 3 do begin
                if (N_elements(CalBefore) eq 0) then begin
                    CalBefore = (*Data[CalIndx[0]])
                    CalAfter  = (*Data[CalIndx[1]])
                endif else begin
                    CalBefore = [CalBefore, (*Data[CalIndx[2*j]])]
                    CalAfter  = [CalAfter , (*Data[CalIndx[2*j+1]])]
                endelse
            endfor

            Ngood = Ngood+1

        endif else Nbad = NBad+1

    endelse

endfor

if (N_elements(Strip) ne N_elements(calbefore)) OR $
  (N_elements(Strip) ne N_elements(calafter)) then message, 'Uh Oh'

;stop, patternindx

if (N_elements(Strip) gt 0) then begin
    help, Strip, calbefore, calafter
    message, 'Saving...', /INFO
    save, filename=Stg1Path+FileName, Strip, CalBefore, CalAfter, /VERB, /COMP
    message, 'Saving Completed.', /INFO
endif

; FREE UP THE POINTER...
ptr_free, data

; ADD THE GOOD/BAD STATISTICS...
;openu, 1, '~/goodbad.dat', /APPEND
;printf, 1, ngood, nbad
;close, 1

end; SavePolCal

