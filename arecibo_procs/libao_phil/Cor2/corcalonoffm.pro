;+
;NAME:
;corcalonoffm -  process a cal on/off pair with a mask
;SYNTAX:  istat=corcalonoffm(lun,m,retDat,spc,scan=scan,calval=caltouse,sl=sl,$
;               edgefract=edgefract,han=han,swappol=swappol)
;ARGS:    
;           lun:  unit number to read from (already opened).
;             m:  {cormask} holds masks for the data 0 or 1.
;                 It is created by the cormask routine.
;                 Note. if m.b1[1024,2] has two entries per board, it uses
;                       the first entry for both pols on the board.
;retData[nbrds]:  {cals} return data as array of structures. 
;        spc[2]:  {corget} if provided then return the calon (spc[0]) and
;                  caloff spectra (spc[1]) after converting them to K.
;               
;KEYWORDS:
;          scan:  if set, position to start of this scan before read
; caltouse[2,nbrds]: cal value polA,polB for each board
;            sl[]: {sl} returned from getsl routine. If provided then 
;                     position to scan will be direct access.
;       edgefract: float if provided then create the mask ignoring m. Ignore
;                  edgefract*lagsSbc lags from each side of the bandpass.
;                  Return the mask in m (whatever is there gets overwritten).
;             han: if set then hanning smooth the spectra
;         swappol: if set then swap polA,polB cal values. This can be
;                  used to correct for the 1320 hipass cable reversal or
;                  the use of a xfer switch in the iflo.
;RETURNS:
;       istat - 1 ok, 0 did not complete
;DESCRIPTION:
;   Read the calOnOff records and the cal values for the receiver
; and frequency. Compute the cal using the non zero lags in the mask m.
;   If edgefract is provided, then create the mask ignoring whatever is in m.
; Zero edgefract*lagsbc lags from each side of the bandpass. Return this mask
; in m (overwriting whatever was there).
;   The cal values and the scale factors (correlator counts to Kelvins) are
; returned in the data structure retDat[n] (1 for each correlator board). 
; The data stucture format is:
;  retDat[i].h:        {hdr}  from first cal on
;  retDat[i].calval[2]:float  calval in kelvin for each sbc of this board
;  retDat[i].calscl[2]:float   to scale to kelvins calT/(calon-caloff)
;        h.cor.calOn  will contain the total power calOn (correlator units)
;        h.cor.calOff will contain the total power calOff (correlator units)
;                              calon-caloff is total power.
;
;   If a particular board has only 1 sbc, then the data will be in the
; first entry [0] (whether or not it is polA or polB).
;   If the spc parameter is provided, the spectral data for the cal 
;on (spc[0]) and the cal off (spc[1]) will be returned after converting
;them to Kelvins.
;
;    You can scale any other spectra to Kelvins using:
;  b.bN.d[*,sbcn]*= retDat[N-1].calscl[sbcn]
;SEE ALSO:
;   corcalonoff
;-
;history:
;31jun00 - converted to new form of corget..
;15jun02 - pjp5.5 patch for 5.4,5.5
;12aug02 - added edgefract and spc.
;
function corcalonoffm,lun,m,retDat,spc,scan=scan,calval=caltouse,sl=sl,$
                      edgefract=edgefract,han=han,swappol=swappol
;
;   
    forward_function chkcalrec
;   on_error,2
    retstat=1
;
;   see if they want us to position to start of the scan
;
    if keyword_set(scan) then begin
        if keyword_set(sl) then begin
           istat=posscan(lun,scan,1,sl=sl)
        endif else begin
           istat=posscan(lun,scan,1)
           if istat ne 1 then begin
                 print,'corcalonoff, error positioning to ',scan
                goto,errout
           endif
        endelse
    endif
; 
;   average the next scan.. the on..
;
    istat=corinpscan(lun,calon,/sum,maxrecs=10,han=han)
    if istat ne 1 then begin 
        print,'corcalonoffm, error reading calon scan'
        goto,errout
    endif
;
;    do a few checks to make sure it is the start of a cal on /off..
;
    if corhcalrec(calon.b1.h[0]) ne 1 then begin 
        print,'corcalonoff. 1st record not calon rec'
        goto,errout
    endif
    if calon.b1.h[0].std.grpnum ne 1 then begin
        print,'corcalonoffm. 1st record not start of group'
        goto,errout
    endif
;
;   average the next scan.. the off..
;
    istat=corinpscan(lun,caloff,/sum,maxrecs=10,han=han)
    if istat ne 1 then begin 
        print,'corcalonoffm, error reading caloff scan'
        goto,errout
    endif
    if corhcalrec(caloff.b1.h[0]) ne 2 then begin 
        print,'corcalonoff.. last rec were not a calOff'
        goto,errout
    endif
;
;   create the cal structure to return
;
;   a={      h:          h[0],$; header from 1st calon, holds tp,info too
;           calval:     fltarr(2),$; cal value 1,2nd sbc
;       calscl:     fltarr(2)} ; cal scale 1st,2nd sbc..
    numbrds=calon.b1.h.cor.numbrdsused 
    retDat=replicate({corcal},numbrds)
;
;   if edgefract provided, generate the mask and return in m
;
    if n_elements(edgefract) gt 0 then cormask,calon,m,edgefract=edgefract
;
;   move header then get cal values. compute scale factor over the mask
;   not the whole bandpass.
;
    for i=0,numbrds-1 do begin
        retdat[i].h=calon.(i).h             
;
;       get the cal value for this receiver at this freq. returns 
;       [2] .. polA, polB
;
        masksum= total(m.(i)[*,0],1)
        for j=0,(calon.(i).h.cor.numsbcout < 2)-1 do begin
            retdat[i].h.cor.calOn[j]  =total((calon.(i).d[*,j]) *m.(i)[*,0],1)/$
                    masksum
            retdat[i].h.cor.calOff[j] =total((caloff.(i).d[*,j])*m.(i)[*,0],1)/$
                    masksum
        endfor
        delta= retdat[i].h.cor.calOn - retdat[i].h.cor.calOff
        if n_elements(caltouse) eq 0 then begin
            if corhcalval(retDat[i].h,calval,swappol=swappol) eq -1 then begin
                print,"err:corcalonoff. calling corhcalval brd:",i+1
                goto,errout
            endif
        endif else begin
            calval=caltouse[*,i]
        endelse
;
;       corhcalval always returns calval[2] with polA then polB
;       if only 1 sbc and polB, need to move calval[1]-> calval[0]
;
        if retdat[i].h.cor.numsbcout eq 1 then begin ; just 1 sbc
            lagconfig=retDat[i].h.cor.lagconfig
            if  (lagconfig eq 1) or (lagconfig eq 7) then calval[0]=calval[1]
             calval[1]=0.
             delta[1]=1.                    ; so we do not blow up on divide
        endif
        retdat[i].calval=calval
        retdat[i].calscl=retdat[i].calval/ delta
    endfor
    if arg_present(spc) then begin
        spc=corallocstr(calon,2)
        corstostr,caloff,1,spc
        corsclcal,spc,retDat
    endif
    return,1
errout:
    return,retstat
end
