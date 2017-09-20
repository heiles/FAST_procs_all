;+
;NAME:
;mcalinp - input data for meascal routine.
;SYNTAX: d=mcalinp(lun,type,numsteps,numloops,scan=scan)
;ARGS  :
;       lun : int   of correlator file to read
;       type: int   1- on absorber, 2 on sky
;   numsteps: int   number of steps to cover the frequency range
;                   these are usually the 100 Mhz junks.
;   numloops: int   the number of types you swept the entire frequency
;                   range. The scans must be contiguous on disc.
;KEYWORDS:
;   scan    :long   scan number to position to before reading. If 
;                   not provided then read from the current position.
;                   not provided then read from the current position.
;   maskSig :float  sigmas to use for rms by record masking
;RETURNS:
;   d[numsteps*numloops*4]: {meascal} return the data here (see below).
;DESCRPTION:
;   The meascal data acquisition routine steps through a frequency range
;turning the cal off then on. It is normally run on absorber and then
;on the sky. The setup is 4 sbc by 256 lags spanning 4*25 Mhz in a chunk.
;An option of the routine is to loop multiple times through the frequency
;range.
;   This routine reads the data and separates each sbc into a separate
;element in the {meascal} array. The user provides the lun, type (
;1 for absorber, 2 for sky) and the number of 100 Mhz steps and times
;the entire frequency range was repeated. 
;   The returned data array contains and entry for each sbc of each step:
;
; d.frq    - center freq of sbc in Mhz
; d.type   - 1 for absorber, 2 for sky (user supplies this value).
; d.scan   - scan number for the cal off scan
; d.brd    - board number in correlator 0..3
; d.spOn[256,2]  -holds the calon  spectra for polA and polB
; d.spOff[256,2] -holds the caloff spectra for polA and polB
; d.spCal[256,2] -holds the calOn/caloff -1 spectra for polA and polB
; d.tpOn[2]  - total power cal on (pola,polb)
; d.tpOff[2] - total power cal off (pola,polb)
;-
function mcalinp,lun,type,numsteps,numloops,scan=scan
;
    forward_function mcalinp1
    retAr=replicate({meascal},numsteps*numloops*4)
    if keyword_set(scan) then begin
        if (posscan(lun,scan,1) ne 1) then $
            message,'error positioning to scan' + string(scan)
    endif  
    ind=0
;
;   loop through the number of loops they did
;
    for i=0,numloops-1 do begin
;
;       loop through the steps per loop this covers the entire frequency
;       range.
;
        for j=0,numsteps-1 do begin
            retAr[ind:ind+3]=mcalinp1(lun,type,j*4)
            ind=ind+4       
        endfor
    endfor
    return,retAr
end
