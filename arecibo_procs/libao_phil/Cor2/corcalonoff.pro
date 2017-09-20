;+
;NAME:
;corcalonoff -  process a cal on/off pair
;SYNTAX:  istat=corcalonoff(lun,retDat,calOnrec,scan=scan,calval=calval,
;                           sl=sl,swappol=swappol)
;ARGS:    
;           lun:  unit number to read from (already opened).
;retData[nbrds]:  {cals} return data as array of structures. 
;      calOnRec:  {corget}optional parameter. If present it is the first
;                       calon rec (in case you already read it).
;KEYWORDS:
;          scan:  if set, position to start of this scan before read
; calval[2,nbrds]: cal value polA,polB for each board
;            sl[]: {sl}  scan list array returned from getsl. If sl is
;                        included then direct access positioning is available.
;         swappol: if set then swap polA,polB cal values. This can be 
;                  used to correct for the 1320 hipass cable reversal or
;                  the use of a xfer switch in the iflo.
;RETURNS:
;       istat - 1 ok, 0 did not complete
;DESCRIPTION:
;   Read the calOnOff records and the cal values for the receiver
; and frequency. Return the cal info in the retData[nbrds] array of
; cal structs (one entry in retData for each correlator board). 
; The stucture format is:
;  retDat[i].h:        {hdr}  from first cal on
;  retDat[i].calval[2]:float  calval in Kelvins for each sbc of this board
;  retDat[i].calscl[2]:float  scale factor to use when scaling from 
;                             correlator counts to Kelvins: calT/(calon-caloff)
;        h.cor.calOn  will contain the total power calOn (correlator units)
;        h.cor.calOff will contain the total power calOff (correlator units)
;                              calon-caloff is the total power of the cal.
;
;   If a particular board has only 1 sbc, then the data will be in the
;   first entry [0] (whether or not it is polA or polB).
;
; The routine will average multiple dumps if necessary.
;
; You can scale your spectra to Kelvins via
;  b.bN.d[*,sbcn]= retDat[N-1].calscl[sbcn]*b.bN.d[*,sbcn]
;-
;history:
;31jun00 - converted to new form of corget..
;15jun02 - pjp5.5 patch for 5.4,5.5
;12aug03 - bug with multiple records/scan. fixed int
;
function corcalonoff,lun,retDat,calOnRec,scan=scan,calval=calval,sl=sl,$
                     swappol=swappol
;
;   
    forward_function chkcalrec,wascheck
;   on_error,2
    retstat=0
    usewas=wascheck(lun)    
;
;   see if they want us to position to start of the scan
;
    if keyword_set(scan) then begin
        if keyword_set(sl) then begin
            istat=posscan(lun,scan,1,sl=sl)
        endif else begin
            istat=posscan(lun,scan,1)
        endelse
        if istat ne 1 then begin
            print,'corcalonoff, error positioning to ',scan
            goto,errout
        endif
    endif
; 
;    if they passed in the first record, use it, else read a new one
;
    if  (n_params() ge 3) then begin
        nbrds=calonrec.b1.h.cor.numbrdsused
            h=replicate(calonrec.b1.h,nbrds)
        for i=1,nbrds-1 do begin
                h[i]=calonrec.(i).h
        endfor
    endif else begin
        istat=corgethdr(lun,h)
        if istat ne 1 then begin
            print,'corcalonoff: i/o err rec 1 corgethdr stat:',istat
            goto,errout
        endif
    endelse
;
;    do a few checks to make sure it is the start of a cal on /off..
;
    if corhcalrec(h[0]) ne 1 then begin 
        print,'corcalonoff. 1st record not calon rec'
        goto,errout
    endif
    if h[0].std.grpnum ne 1 then begin
        print,'corcalonoff. 1st record not start of groupc'
        goto,errout
    endif
;
;    compute number of recs in on and off  
;
     if useWas then begin
         numrecs=1
     endif else begin
        secInteg=h[0].proc.iar[0]
        secsPerRec= h[0].cor.dumpsperinteg * $
                  (h[0].cor.dumplen*(h[0].cor.masterclkperiod*1e-9))
        numrecs=long(secInteg/secsPerRec + .5)
     endelse
;
;    input the the rest of the data.. it just reads the headers..
;
     num=corpwr(lun,2*numrecs-1,pwra,lasthdr)
;
;   make sure we got the number of recs, and the last rec is a calOff
;       
    if num ne 2*numrecs-1 then begin
        print,'corcalonoff.. did not get all the calon/off recs'
        goto,errout
    endif
    if corhcalrec(lasthdr[0]) ne 2 then begin 
        print,'corcalonoff.. last recs were not a calOff'
        goto,errout
    endif
;
;   create the cal structure to return
;
;   a={      h:          h[0],$; header from 1st calon, holds tp,info too
;           calval:     fltarr(2),$; cal value 1,2nd sbc
;       calscl:     fltarr(2)} ; cal scale 1st,2nd sbc..
    numbrds=(size(h))[1]
    retDat=replicate({corcal},numbrds)
;
;   move header for first rec
;    
    if (size(retdat.h))[0] eq 2 then begin  ;< pjp5.5>
;   > 5.3
      retdat.h=reform(h,1,numbrds)             
    endif else begin
        retdat.h=h              
    endelse
    if numrecs eq 1 then begin
        retdat.h.cor.calOff=pwra.pwr[*,0:numbrds-1]
    endif else begin
;
;       sum rest of calon recs. we've already read the first rec
;       need to distinguish between >2 recs for the total dimension
;
        if numrecs eq 2 then  begin
            retdat.h.cor.calon=(retdat.h.cor.calon + $
                    pwra[0].pwr[*,0:numbrds-1])/numrecs
        endif else begin
            retdat.h.cor.calon=(retdat.h.cor.calon + $
                total(pwra[0:numrecs-2].pwr[*,0:numbrds-1],3))/numrecs
        endelse
;
;       sum all of cal off recs. we have at least 2 recs..,avg 3 dimension
;       pwra has 2*nrecs-1 since the first on rec was read ahead of time
;
        retdat.h.cor.caloff= $
            total(pwra[numrecs-1:numrecs*2-2].pwr[*,0:numbrds-1],3)/numrecs
    endelse
done:
;
;   for each board get the cal values..and compute scale factor
;
    for j=0,numbrds-1 do begin
;
;       get the cal value for this receiver at this freq. returns 
;       [2] .. polA, polB
;
        delta=retdat[j].h.cor.calOn - retDat[j].h.cor.calOff
        if n_elements(calval) eq 0 then begin
           if corhcalval(retDat[j].h,calvalloc,swappol=swappol) eq -1 then begin
                print,"err:corcalonoff. calling corhcalval brd:",j+1
                goto,errout
            endif
        endif else begin
            calvalloc=calval[*,j]
        endelse
;
;       corhcalval always returns calval[2] with polA then polB
;       if only 1 sbc and polB, need to move calval[1]-> calval[0]
;
        if retdat[j].h.cor.numsbcout eq 1 then begin ; just 1 sbc
            lagconfig=retDat[j].h.cor.lagconfig
            if  (lagconfig eq 1) or (lagconfig eq 7) then $
                calvalloc[0]=calvalloc[1]
             calvalloc[1]=0.
             delta[1]=1.                    ; so we do not blow up on divide
        endif
        retdat[j].calval=calvalloc
        retdat[j].calscl=retdat[j].calval/ delta
    endfor
    return,1
errout:
    return,retstat
end
