;+
;NAME:
;corcalcmp - given calon,off buffers, compute scale to kelvins
;SYNTAX:  istat=corcalcmp(calOn,calOff,calScl,datToScl,han=han,$
;                 useinpm=useinpm,bla=bla,blda=blda,edgefract=edgefract,$
;                  mask=mask,caldif=caldif,calValAr=calValAr,Tsys=Tsys
;
;ARGS:    
;       calOn[n]: {corget} cal on data. If n is greater than 1, then 
;                          the n calOn recs will be averaged together.
;      calOff[n]: {corget} cal off data. If n is greater than 1, then 
;                          the n caloff recs will be averaged together.
;KEYWORDS:
;           han:           if set then hanning smoooth the cal data
;       useinpm:           if set then user passed mask in via mask keyword.
;           bla:           If set then corblauto will use the caldeflection
;                          to compute the mask of channels to use
;           blda:          If set then corblauto will be passed 
;                          (calon-caloff)/caloff . It will fit and compute
;                          the mask using this value.
;  edgefract[2]:float      fraction of the bandpass to ignore on each
;                          edge. Default is .08 . If 1 number is provided,
;                          it is will be  used for both edges.
;  extraParms:             any extra parameters will be passed to 
;                          corblauto (if /bla is set). In particular you
;                          can used deg=,fsin=,verb= .
;
;RETURNS:
;       istat:        int  1 ok, 0 trouble getting cal value
;calScl[2,numbrds]: float  factor that converts correlator counts to 
;                          kelvins for each pol of each board [pol,brd].
;                          [0,n] is the first pol of each board (whether
;                          it is polA or polB). If a board has only 1 pol
;                          then calScl[1,n] will be 0.
;                          See WARNIG below..
;   
;  datToScl[m]: {corget}   If provided, this data will be scaled to
;                          kelvins for you.
;         mask: {cormask}  The mask used when computing the cal. This is
;                          computed in the following order:
;                          1. if bla set, then mask comes from corblauto
;                          2. if mask is provided then it is used as 
;                             passed in:
;                          3. if edge= provided, then mask is computed
;                             ignoring the edgefraction specified.
;                          4. edgefraction is set to .08 and then use 3.
;                          keyword.
;       caldif: {corget}   return calon-caloff in correlator counts.
;     calValAr: fltar(2,nbrds) return calvalues for each board. index
;                          [0,*] is the first spectra of board, [1,*] is the
;                          2nd spectra of the board.
;     Tsys: fltar(2,nbrds,2) return Tsys as measured from the spectra
;                          [pol,nbrds,calOn/calOff]
;
;DESCRIPTION:
;   Given the cal on and off records, compute the scaling factors to go from
;correlator counts to kelvins. It returns the results in calScl. If the 
;argument, datToScl is provided, then scale this data to kelvins using
;the computed values (it should be {corget} structures).
;
;   The routine computes (where .i are the individual channels):
;      calDif.i= calon.i - calOff.i
;
;   It will then average the cal over a section (or mask) of the bandpass.
;   The mask is derived in the following order:
;     1. /useinpm is set. The user passes in the mask
;     2. /bla     is set. corblauto will determine the mask from the
;                 caldeflection.
;     3. edgefract is provided. It will make a mask ignoring this fraction
;                 of channels from each edge.
;   
;   It then computes (for each pol on each brd):
;     calScl[sbc,brd]= calK/mean(calDefl.i )
;               where the mean is summed over the non-zero mask elements.
;
;   If datToScl is provided then it will be converted to kelvins and returned.
;   The mask used in the cal computation is returned (if you do a bandpass
;   correction you will probably want to normalize to this set of
;   channels).
;
;EXAMPLE:
;   This routine can be used if the cal onoff was taken with a 
; non stanard routine. Suppose you have a cal Off followed by a 
;cal on record:
;   print,corgetm(lun,b,2,/han)  ; assume b[0] is cal off ,b[1] is cal on
;
;   istat=corcalcmp(b[1],b[0],calscl,b,/bla,verb=-1,deg=4,fsin=4,mask=mask)
;   
;
;Notes:
;   Calon,caloff are assumed to be from the same calon/off measurement.
;It uses the first entry of calOn to find the rcvr, freq to get the
;cal values.
;
;   datToScl should be the same setup as calOn,calOff (eg same number
;of boards, and pols per board.
;
;WARNING:
;   calscl is returned as a fltarr(2,nbrds) where the first index
;is the sbc per board. If the board has only 1 sbc, then 
;calscl[1,x] is 0.   Be careful passing calscl to the cormath() routine
;to do the multiplication. Cormath wants 1 scaler for each sbc. It does
;not want the extra zeros. 
; the WRONG way..
; bk=cormath(b,smul=calscl) ... This will fail if a brd has 1 sbc.
;
; the CORRECT way..
; calsclOk=calscl[where(calscl ne 0.)]  .. gets rid of the zeros
; bk=cormath(b,smul=calsclok) .. this will work ok..
;-
;history:
;
function corcalcmp,calon,caloff,calScl,datToScl,bla=bla,blda=blda,$
                   useinpm=useinpm,edgefract=edgefract,mask=mask,caldif=caldif,$
                   calValAr=calvalAr,Tsys=Tsys,_extra=_e
;
;   on_error,2
    retstat=0
    iTon =0             ; for tsys struct index for calon,caloff tsys
    iToff=1
;
;   create the cal structure to return
    numbrds=n_tags(calon[0])
    nrecs=n_elements(calOn)
    calScl=fltarr(2,numbrds)
    calvalAr=fltarr(2,numbrds)
    caldifTp=fltarr(2,numbrds)
    useTsys=arg_present(tsys)
    if useTsys then Tsys=fltarr(2,numbrds,2)
    if n_elements(edgefract) eq 0 then begin
        edgefract=.08
    endif

    if nrecs gt 1 then begin
        con=coravg(calon)
        coff=coravg(calOff)
        if keyword_set(han) then begin
          corhan,con
          corhan,coff
        endif
        caldif=cormath(con,coff,/sub)
    endif else begin
        if keyword_set(han) then begin
            corhan,calon  ,con
            corhan,caloff ,coff
            caldif=cormath(con,coff,/sub)
        endif else begin
            caldif=cormath(calon,caloff,/sub)
            if keyword_set(blda) or useTsys  then begin
                coff=caloff
                con=calon
            endif
        endelse
    endelse
;
    if not keyword_set(useinpmask) then begin
        case 1 of 
        keyword_set(bla):begin
            istat=corblauto(caldif,blfit,mask,coef,edge=edgefract,_extra=_e)
            end
        keyword_set(blda):begin
            ctemp=cormath(caldif,coff,/div)
            istat=corblauto(ctemp,blfit,mask,coef,edge=edgefract,_extra=_e)
            end
        else: begin
            mask=cormaskmk(caldif,edgefract=edgefract)
            end
        endcase
    endif
;
;   compute total power and scale
;
    for ibrd=0,numbrds-1 do begin
        npol=(calon[0].(ibrd).p[1] eq 0) ? 1:2
        polB1st=calon[0].(ibrd).p[0] eq 2
        istat=corhcalval(calon[0].(ibrd).h,calvalLoc)
        if istat eq -1 then goto,badcal
;
;       corhcalval always returns calval[2] with polA then polB
;       if only 1 sbc and polB, need to move calval[1]-> calval[0]
;
        if polB1st then begin
          calvalloc[0]=calvalloc[1]
          calvalloc[1]=0.
        endif
        calValAr[*,ibrd]=calvalloc
;
;   compute mean value ,scale
;
        ind=where(mask.(ibrd)[*,0] gt .1,count)
        caldifTp[0,ibrd]=total(caldif.(ibrd).d[ind,0])/count
        calscl[0,ibrd]=calvalLoc[0]/caldifTp[0,ibrd]
        if useTsys then begin
            tsys[0,ibrd,iTon]=total(con.(ibrd).d[ind,0])/count*calscl[0,ibrd]
            tsys[0,ibrd,iToff]=total(coff.(ibrd).d[ind,0])/count*calscl[0,ibrd]
        endif
        if npol gt 1 then begin
            ind=where(mask.(ibrd)[*,1] eq 1,count)
            caldifTp[1,ibrd]=total(caldif.(ibrd).d[ind,1])/count
            calscl[1,ibrd]=calvalLoc[1]/caldifTp[1,ibrd]
            if useTsys then begin
                tsys[1,ibrd,iTon]=total(con.(ibrd).d[ind,1])/$
                            count*calscl[1,ibrd]
                tsys[1,ibrd,iToff]=total(coff.(ibrd).d[ind,1])/$
                            count*calscl[1,ibrd]
            endif
        endif
    endfor
    if n_elements(datToScl) gt 0 then begin
        ind=where(calscl ne 0.,count)
        calsclL=calscl[ind]
        datToScl=cormath(datToScl,smul=calsclL)
    endif
    return,1
badcal: print,'could not find calvalue'
        return,0

end
