;+
;NAME:
;corposonoffm - process a on/off scan using a mask
;SYNTAX: istat=corposonoffm(lun,m,b,t,cals,sclcal=sclcal,scan=scan,sl=sl,$
;                           maxrecs=maxrecs,dbg=dbg,swappol=swappol)
;ARGS  :
;       lun:    int .. assigned to open file.
;         m:    {cormask} holds the mask in the bi.data portion.
;                        should be 1 or 0.
;                        Note: if m.b1[1024,2] has 2 masks per board, this
;                        routine uses the first maskfor both pols..
;KEYWORDS:
;    sclcal: if not zero then scale to kelvins using the cal on/off
;             that follows the scan
;      scan: position to first record of scan before reading.     
;      sl[]:  {sl} returned from getsl(). If provided then direct access
;                  is available to scan.
;   maxrecs: maximum records in a scan. default 300.
;   swappol: if set then swap polA,polB cal values. This can be
;            used to correct for the 1320 hipass cable reversal or
;            the use of a xfer switch in the iflo.
;   _extra :  calval=caltouse[2,nbrds] .. for corcalonoff..
;RETURNS:
;         b:    {corget} return (on-off)*X here..
;               X is: 
;                   sclCal true : (kelvins/corcnt)/<off>.. units are then K
;                   sclcal false: off                   .. units are TsysOff
;         t:    {temps} total power temp info contains..
;                   t.src  .. on/off-1 (same as lag0pwrratio)
;                   t.on   .. temp on src
;                   t.off  .. temp off
;                   units are Kelvins if /sclcal else Tsys Off
;    cals[]:    {cal} return cal info. see coronoffcal..
;               this is an optional argument
;     istat:   int   1 gotit, 0 didnot complete
;                       cal value to use polA,B by board instead of
;                       value in file
;DESCRIPTION:
;   Process a position switch on,off pair. Return a single spectrum
;per sbc of  (posOn-posOff)/posOff. The units will be Tsys posOff or
;Kelvins (if /sclcal) is set. The t structure holds the total power info
;for on/off -1, on source, and off source. The units are either
;Kelvins (/usecal set) or TsysOff.
;The cal record info is also returned in the cals structure.
;
;   The header will be that from the first record of the on with the
;following modifications:
;   h.std.gr,az,chttd is the average for the on scan
;   h.cor.lag0pwratio is the average of (on-off)/off the units will be
;                     TsysPosOff or kelvins depending on /sclcal.
;structures:
;   b - holds the spectral data and headers: has N elements:
;   b.b1 - board 1 thru
;   b.bn - board n
;   each b.bN has:
;        b.bN.h  - header
;        b.bN.d[nlags,nsbc] - spectral data
;
;   t - is a structure that holds temperature/power data .
;      For each element the first dimension holds the polarizations.
;      If there are two polarizations per board then polA is in t.aaa[0,x] and
;      and polB is in t.aaa[1,x]. If there is only 1 polarization per
;      board then the data is always in t.aaa[0,x].
;      The second dimension is the board.
;        t.src[2,8] (on-off)*X power
;        t.on[2,8]   on  power
;        t.off[2,8]  off power
;        The power units will be Kelvins if /corscl is set. If not,
;        the units will be  TsysOffPos.
;   
;  cals[nbrds] holds the cal info. it is an array of {cal} structures:
;   cals[i].h          - header from first cal on.
;   cals[i].calval[2]  - cal value for each sbc this board
;   cals[i].calscl[2]  - to convert corunits to kelvins sbc,1,2
;       cals[i].h.cor.calOn  - has the total power calOn
;       cals[i].h.cor.calOff - has the total power calOff .. units are
;                              correlator units.
; Note.. there is a difference between < on/off - 1> and
;        <on>/<off> namely the bandpass shape .. let f be the bandpass shape:
;        then < f*on/(f*off) -1> doesnot have the bandpass
;        but   <f*on>/<f*off> does  the basic problem is that
;        <a>/<b> is not equal to <a/b>
;-
;modhistory
;31jun00 - updated for new corget
; 4jul00 - added t struct
; 5jun03 - updated for cmask changes.. looks like this wasn't 
;          working since it use a cmask that looked like {corget}. But
;          it was passing it to routines like corcalonoffm() that wanted
;          a cmask struct.
; 2aug03 - added maxrecs keyword
;
function corposonoffm,lun,m,b,t,cals,sclcal=sclcal,scan=scan,sl=sl,$
                maxrecs=maxrecs,dbg=dbg,_extra=e,swappol=swappol
;
;
;   
    forward_function corcalonoffm
    if not keyword_set(scan)    then scan=0
    if not keyword_set(sl)    then sl=0
    if not keyword_set(dbg)     then dbg=0
    if not keyword_set(sclcal)  then sclcal=0
    if not keyword_set(maxrecs)  then maxrecs=0
;
;   on 
;
    if dbg then start=systime(1)
    if (corinpscan(lun,b,/sum,scan=scan,sl=sl,maxrecs=maxrecs,dbg=dbg) eq 0 )$
        then goto,errinp
    print,'on scan:',b.b1.h.std.scannumber
    if dbg then begin
        endtm=systime(1)
        print,'corinpscan on',endtm-start
    endif
    if ( string(b.(0).h.proc.car[*,0]) ne 'on') then begin
        print,'1st scan not an on',b.(0).h.std.scannumber
        goto,errinp
    endif
;
;   off
;
    if dbg then start=systime(1)
    if (corinpscan(lun,boff,/sum,maxrecs=maxrecs,dbg=dbg) eq 0 ) then $
        goto,errinp
    if dbg then begin
        endtm=systime(1)
        print,'corinpscan off',endtm-start
    endif
    if ( string(boff.b1.h.proc.car[*,0]) ne 'off') then begin
        print,'2nd scan not an off',boff.b1.h.std.scannumber
        goto,errinp 
    endif
;
    if dbg then start=systime(1)
;
;   input calOnOff if they have cals, or /sclcal
;
    if (n_params() ge 4) or sclcal  then begin
        if ((b.b1.h.proc.iar[1] and 1) eq 0 ) then begin
            print,'no cal records to input'
            goto,errinp
        endif
        if corcalonoffm(lun,m,cals,_extra=e,swappol=swappol) ne 1 then begin
            print,'error processing cal on,off'
            goto,errinp
        endif
    endif 
;
;     compute on/off - 1 we are in units of Tsys Off
;     also update the temp array and lag0pwrratio
;
    nbrds=b.b1.h.cor.numbrdsused
    t={cortmp}
    t.k=0
    if sclcal then t.k = 1
    for i=0,nbrds-1 do begin
        t.p[*,i]=b.(i).p
        masksum  =total(m.(i)[*,0],1)
        offsumavg=total(boff.(i).d*m.(i)[*,0],1)/masksum
        onsumavg =total(b.(i).d*m.(i)[*,0],1)/masksum
        if sclcal then begin
;
;           The scaling factor K/corCnts * (meanPosOff in mask)
;           the 2nd term is converting the off we divide with into a 
;           normalized (over the mask) off so we are still in correlator
;           cnts.
;
            t.on[0,i] = onsumavg[0]  * cals[i].calscl[0]
            t.off[0,i]= offsumavg[0] * cals[i].calscl[0]
            b.(i).d[*,0]=((b.(i).d[*,0]/boff.(i).d[*,0])-1.)* offsumavg[0] * $
                            cals[i].calscl[0]
            t.calscl[0,i]=cals[i].calscl[0]
            t.calval[0,i]=cals[i].calval[0]
            if b.(i).p[1] ne 0 then begin
                t.on[1,i]   = onsumavg[1]  * cals[i].calscl[1]
                t.off[1,i]  = offsumavg[1] * cals[i].calscl[1]
                t.calscl[1,i]=cals[i].calscl[1]
                t.calval[1,i]=cals[i].calval[1]
                b.(i).d[*,1]=((b.(i).d[*,1]/boff.(i).d[*,1])-1.)* offsumavg[1]*$
                            cals[i].calscl[1]
            endif
        endif else begin
            t.on[0,i] = onsumavg[0]  /offsumavg[0]
            t.off[0,i]= 1
            b.(i).d[*,0]=((b.(i).d[*,0]/boff.(i).d[*,0]) - 1.) 
            if b.(i).p[1] ne 0 then begin
                t.on[1,i]   = onsumavg[1]  /offsumavg[1]
                t.off[1,i]  = 1.
                b.(i).d[*,1]=((b.(i).d[*,1]/boff.(i).d[*,1])-1.)
            endif
        endelse
        a= total(b.(i).d*m.(i)[*,0],1)/masksum
        t.src[0,i]=a[0]
        if b.(i).p[1] ne 0 then t.src[1,i]=a[1]
        b.(i).h.cor.lag0pwrratio=t.src[*,i]
;
    endfor
    if dbg then begin
        endtm=systime(1)
        print,'computing',endtm-start
    endif
    return,1
errinp:
    return,0
end
