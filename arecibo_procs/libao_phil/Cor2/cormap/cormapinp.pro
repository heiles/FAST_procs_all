;+
;NAME:
;cormapinp  - input a correlator map.
;
;SYNTAX:istat=cormapinp(lun,scan,polABrdNum,polBBrdNum, m,cals,norev=norev,
;                           han=han,sl=sl,maxrecs=maxrecs,avgsmp=avgsmp,
;                           calrecs=calrecs)
;
;ARGS:
;       lun: int  logical unit number for file. It should already be opened.
;      scan: long scan number for start of map.
;polABrdNum: int  correlator board index (1 thru 4) to take polA data from.
;polBBrdNum: int  correlator board index (1 thru 4) to take polB data from.
;
;KEYWORDS:
;   norev:    When you drive both directions, the routine will normally
;             reverse the odd strips so that the  data,header, and cals of
;             adjacent strips will line up in RA. Setting norev to true 
;             will override this default. The data will be returned in 
;             the order it is taken.
;     han:    if set then hanning smooth the data on input.
;     sl[]:   {sl} scanlist array returned from call a previous call to
;             getsl(). If this keyword is provided then direct access is
;             used rather than sequentially reading the file.
;   maxrecs:  long  If you have more than 300 records in a scan you will have
;                   to set maxrecs to that value.
;    avgsmp:  long  Number of samples to average together. Handy if you've
;                   oversampled each strip. If this number does not divide
;                   evenly into the samples/strip, then samples at the end
;                   will be dropped.
;                   avsmp=0 or 1 is the same as no averaging
;
;RETURNS:
;   istat:    int  1: got all the strips
;                  0: got part of requested map
;                 -1: got no data.
;m[2,pnts/strip,nstrips]:{} array of structures holding the returned 
;                       data and header. (see below for a description).
;cals[nstrips*n]    :{} array of structures containing the processed
;                       cal on,off data (cal value and scale factor)
;                        (see below for a description).
;calrecs[nstrips*n]:{calrecs} array holding the raw cal on, cal off
;                       input data. For the i'th calOn/off measured the 
;                       the structure contains cal spectra as float arrays:
;                          calrecs[i].scan        ..scan number forcalOnScan 
;                          calrecs[i].calPerStrip ..0,1,or 2
;                          calrecs[i].con[nchans,2]
;                          calrecs[i].coff[nchans,2]
;                       where i is the i'th calon/off, nchannels are the
;                       number of frequency channels, and [,2] has polA, polB
;                       You can use this data to do rfi excision and then
;                       recompute the cals[] array.
;
;DESCRIPTION:
;   Input a map taken with the correlator routines cormap1,cormapdec, 
;cordrift, or cormapbm. You open the datafile (eg openr,lun,filename,/get_lun)
;prior to calling this routine and then pass in the lun. The scan argument 
;tells the routine where to start reading. This should be the first scan of the
;map. If the map starts with a calon/off and you gave the scan of the
;first strip, the routine will search backwards looking for the cal that goes
;with the first strip (so either is ok to enter). You need to also
;specify which boards of the correlator contain the polA, polB data you
;want to extract (it will only process 1 set of polA, polB data at a time).
;The board numbers are indexed 1 through 4. If polA, polB were input on
;on the same board, then use the same board number for both.
;
;The routine will figure out from the header the size of the map, whether 
;it is a partial map, which directions you drove, and how the cals were taken.
;
;   The map information is returned as an array m of structures. The
;dimensions of the array are:  
;
;  m[pol,pntsperstrip,numstrips].  pol=2
;
;Each element of the array contains the information for a particular 
;sample and polarization. The contents of m (for this example assume
;2048 freq channels,and we are looking at sample 5 of strips 7
;(counting from 1):
;
; m[0,5,7].h        the header for pola, 
; m[0,5,7].d[2048]  the data   for pola
; m[0,5,7].p        the total power value for this sample (linear scale).
; m[0,5,7].az       the azimuth position in degrees at the end of 
;                   each sample.
; m[0,5,7].za       the zenith angle position in degrees at the end of
;                   each sample.
; m[0,5,7].azErrAsec the azimuth tracking error in arcseconds at the
;                   end of each sample (great circle).
; m[0,5,7].zaErrAsec the zenith angle tracking error in arcseconds at the
;                   end of each sample.
; m[0,5,7].raHr     the RA in hours at the middle of each sample.
; m[0,5,7].decDeg   the declination in degrees at the middle of each sample.
; m[0,5,7].calscl   cal scale factor for this position. calst,calend, or
;                   (calst+calEnd)/2.
;
;
;m.h holds the header information for this sample. It contains
;several sub structures:
;  m.h.std  - the standard header
;  m.h.pnt  - the pointing header
;  m.h.iflo - the iflo header
;  m.h.dop  - the doppler,freq,velocity header
;  m.h.cor  - the correlator header
;  m.h.proc - the datataking procedure part of the header.
;Some locations of interest are:
;  m.h.std.scannumber: the scan number for the strip
;  m.h.pnt.r.reqPosRd[2]: requested ra,dec for center of map in radians.
;
;If you drove both directions in ra then lining up the samples numbers from
;each strip would not give a map in increasing ra. By default the routine
;will flip the order of the even strips (counting from 1) in the entire
;map (it flips the order of the headers and cals as well as the data). eg..
;   suppose the map has 15 strips, counting from 1 it will flip the samples
;   in strips 2,4,6,8,10,12,14,12,14 so the ra will line up.
;If you started in the middle of a map, then it will flip the strips relative
;to the number in the entire map. eg.
;   suppose the map has 15 strips and your first strip was strip 4, then it
;   would flip 1,3,5... of the returned strips (since these would normally
;   be flipped in the entire map).
;Setting the /norev keyword will override the default and return the data
;in the order it was taken in each strip.
;
;The cal data is returned in an array of cal structures. It is 
;dimensioned cals[nstrips*n]. n is 1 if you took 1 cal per strip and 2 if 
;you took 2. The contents of the cal structure are:
;
; cals[i].h         - the header for the on cal record.
; cals[i].calval[2] - the cal value in kelvins for polA,polB interpolated
;                     to your frequency.
; cals[i].calscl[2] - the cal scaling factor to go from correlator counts
;                     to kelvins for pol A,polB. it is:
;                     computed as : calValKelvins/(calOn-caloff)
;
; The correlator part of the header contains the cal on, cal off 
; counts:
;   cals[i].h.cor.calon[2]  polA,polB cal on  total power
;   cals[i].h.cor.caloff[2] polA,polB cal off total power
;
;   If you provide the calrecs keyword, then the actual cal spectra will
;also be returned in an array of calrecs structure. Each element contains
;the info for one cal on/off measurement. The contents are:
;
;  calrecs[i].scan        ..scan number forcalOnScan 
;  calrecs[i].calPerStrip ..0,1,or 2
;  calrecs[i].con[nchans,2].. cal on spectra correlator units 
;  calrecs[i].coff[nchans,2]  cal off spectra correlator units
;  
;  nchans are the number of frequency channels per spectra. If there
;  are two sbc per board then polA will be [nchans,0], polB will be [nchans,1]
;  If there can be 0,1 or 2 cals per strip.
;  This data can be used to recompute the cal values after rfi excision.
;
;EXAMPLE:
; Suppose we are mapping with 15 samples/strip, 11 strips, and two correlator
; boards with 1024 pola/polB on each board. We also took 1 cal per strip.
;
; Since arrays are indexed from 0,lets count our samples and strips from 0.
; Then:
;
; m[0,4,3].d[*]      polA sample 4,strip 3
; m[1,4,3].d[*]      polB sample 4,strip 3
;
; the headers would be:
; m[0,4,3].h         polA header sample 4,strip 3
; m[1,4,3].h         polB header sample 4,strip 3
; 
; Assuming there is 1 cal rec/strip, you could scale the spectra in 
; the first strip to kelvins with:
;  m[0,*,0].d=m[0,*,0]* cals[0].calscl[0]
;  m[1,*,0].d=m[1,*,0]* cals[0].calscl[1]
;
; If we took two cals per strip then the cals for the i'th strip (counting
;from zero would be:
;   cals[2*i:2*i+1]
;
;SEE ALSO:
; cor2/corget, cor2/cormapsclK, cor2/arch_getmap,cormap/cormapinplist
;
;NOTES: 
;1. For lbw the routine assumes the cal values are for the measured 
;polarizations. If the circular hybrid is in, then the cal values from 
;the file (which are linear, need to be averaged). This probably needs a 
;parameter to flag this (or maybe rely on the header to have the iflo info..)
;
;2. cormapbm does a beam map in great circle azimuth,za relative to the
;center of the source. The m.raHr and m.decDeg values  are the az,za offsets
;(great circle) in degrees rather than the ra and dec (sorry about this
;but it was too late to change the variable names to m.c1,m.c2).
; m.raHr   -- azimuth offset relative to src center in degrees.
; m.decDeg -- zenth angle offset relative to src center in degrees.
;
;3.The header contains a proc section that holds procedure dependant information
;
;m.h.proc.iar[10] integer data
;m.h.proc.dar[10] double data
;
; These contain some of the parameters that were used in the datataking 
;procedure:
; ---------------------
;HDR.PROC.IAR definition for cormap1,cormapdec
;   code      : bit 0: coord    : 0 J2000, 1 1950
;             : bit 1: rawidth  : 0 great cirle, 1 little circle ra width
;             : bit 2: direction: 0 both ways  , 1 increasing ra only
;             : bit 3: update doppler odd strips
;             : bit 4: update doppler even strips
;             : bit 5: cal on/off start of strip
;             : bit 6: cal on/off end   of strip
;             : bit 8: cal on/off start of map (once only)
;             : bit 9: 1--> adjust correlator power levels at start position.
; iar[0] - code value used
; iar[1] - number of strips requested in map (total.. not this call)
; iar[2] - 1st strip to start on (count from 1)
; iar[3] - integrations per strip
; iar[4] - stripNumber this strip (count from 1)
;          (from start of map, not start of call)
; iar[5] - start time seconds from midnite ast this strip
;
;HDR.PROC.dAR definition for cormap1,cormapdec
; dar[0] - seconds per integration
; dar[1] - raOffAmin   for map .. what user entered
; dar[2] - decOffAmin  for map .. what user entered
; dar[3] - decStepAmin for map .. what was used
;          strip info
; dar[4] - raRateRd   for map ..
;
; dar[5] - raRateRd  this strip little circle
; dar[6] - raOffRd   this strip little circle
; dar[7] - decOffRd   this strip
; ---------------------
;HDR.PROC.IAR for cordrift
;  code     code where each bit signifies an option:
;  code     code where each bit signifies an option:
;       1 bit0:  coord : 0 J2000, 1 1950
;       2 bit1:  cal on/off end of strip: 1 yes, 0 no
;       4 bit2:  0:raOffset=stripTime/2.,
;                1:raOffset=stripTime*1.0027../2 .. convert to sidereal secs
;       8 bit 3: update doppler firstStrip (only)
;    0x10 bit 4: update doppler each strip (including first)
;   0x100 bit 8: coradjpwr at start of 1st strip
;   0x200 bit 9: coradjpwr at start of every strip
;   0x400 bit10: cal onoff start of each strip
;
; iar[0] - code value used
; iar[1] - requested number of times to loop (strips if decStp != 0)
; iar[2] - requested seconds to drift
; iar[3] - integrations per strip
; iar[4] - current strip count from 1
; iar[5] - start time seconds from midnite ast this strip
; iar[6] - extra settle time secs..
; iar[7] - stripsPerStep in dec
;HDR.PROC.dAR definition for cordrift
; dar[0] - seconds per integration
; dar[1] - haOffRd     for map .. what user entered current coord..
; dar[2] - decOffAmin  for map .. what user entered
; dar[3] - decStepAmin for map .. what user entered
;          strip info
; dar[4] - decOffsetThis strip   amin
; ---------------------
;HDR.PROC.IAR for cormapbm (beam maps)
;  code     code where each bit signifies an option:
;             : bit 0: coord    : 0 J2000, 1 1950
;             : bit 1: azwidth  : always great circle
;             : bit 2: direction: 0 both ways  , 1 increasing az only
;             : bit 3:
;             : bit 4:
;             : bit 5: cal on/off start of strip
;             : bit 6: cal on/off end   of strip
;             : bit 8: cal on/off start of map (once only)
;             : bit 9: 1--> adjust correlator power levels at start position.
;
; iar[0] - code value used
; iar[1] - number of strips requested in map (total.. not this call)
; iar[2] - 1st strip to start on (count from 1)
; iar[3] - integrations per strip
; iar[4] - stripNumber this strip (count from 1)
;          (from start of map, not start of call)
; iar[5] - start time seconds from midnite ast this strip
;
;HDR.PROC.dAR definition for cormapbm
; dar[0] - seconds per integration
; dar[1] - azOffAmin   for map .. great circle
; dar[2] - zaOffAmin  for map  ..
; dar[3] - zaStepAmin for map  .. w
;          strip info
; dar[4] - azRateRd   for map ..(great circle
;
; dar[5] - azRateRd  this strip great circle
; dar[6] - azOffRd   this strip great circle
; dar[7] - zaOffRd   this strip
;
;modhistory
;31jun00 update for new corget format
;20dec00 updated to use h.proc information
;09jun01 added support for sl keyword
;04nov01 when computing positions, the rate seconds are sidereal. need
;        to compute duration solar->sidereal
;07dec01 fixed up m.rahr for cordrift. Had constant position for each strip.
;16dec02 added maxrecs
;16dec02 added avgsmp. updated:
;       all
;        h.cor.dumpsPerInteg
;        h.proc.iar[3] - integrations per strip
;        h.proc.dar[0] secs per integration
;       cordrift
;       iar[2] secs req to drift
;07apr03 check procname and source name..
;01jun03 <pjp001> idlversion >= 5.5 now treat embedded structures
;        as arrays of 1. This breaks the reform code. Need to test
;        version of idl to do reform correctly.
;05dec03 start adding support for cormapbm
;10jan04 it now searches backwards for the first cal if the user
;        enters the scan number of the first strip..
;03feb04 was not computing number of cals to return if cals on both
;        edge of strip
;20feb04 newer versions of idl were creating different dimensions of the
;        arrays .. eg d[128,1,30] and d[128,30]. This was causing problems
;        on the reversing.. I tried to fix it here..
;07feb04 case statement line 580.. first test was cormap1 or cordrift
;        2nd test was cordrift, should have been cormapdec. This caused
;        cormapdec patterns to fail.
;26jul04 need to check rcvr number. Some clever people were interleaving
;        maps of same name, but different receivers..
;-
function cormapinp,lun,scan,polABrd,polBBrd,m,cals,norev=norev,han=han,sl=sl,$
                   maxrecs=maxrecs,avgsmp=avgsmp,calrecs=calrecs
;
; 1. position to scan. read header figure out
;
    forward_function corget
    forward_function cormapinpcal

;   some flags we fill in later
;
    doavgsmp=0
    cordrift=0
    cormap  =0
    ndimD   =-1             ; used for reversing. dif versions idl have dif dim
    ndimH   =-1
    if keyword_set(avgsmp) then begin
        avgsmp=long(avgsmp)
        if avgsmp gt 1 then doavgsmp=1
    endif
    solToSid=1.00273790935
    if not keyword_set(norev) then norev=0
    if not keyword_set(han) then han=0
    if not keyword_set(sl) then sl=0
    retCalRecs=0
    if (arg_present(calrecs)) then begin
        retCalRecs=1                  ; return cal recs
    endif
    istat=posscan(lun,scan,1,sl=sl)   ; position to start
    if  istat ne 1 then begin
        print,'scan ',scan,' not found'
        return,-1
    endif
    point_lun,-lun,startpos
    istat=corget(lun,b)
    point_lun,-lun,i                     ; get current position
    read1Len=i-startpos                  ; bytes 1 dump
    if istat ne 1 then begin
         if istat eq 0 then begin
            print,'could not find scan',scan,'..hit eof'
         endif  else begin
            print,'could not find scan',scan,'..bad header'
            return,-1
         endelse
    endif
    startIsCal=0
    istat=corhcalrec(b.b1.h)
    if istat eq 1 then begin                 ; jump to first strip for hdr
        startIscal=1
        point_lun,-lun,i                     ; start caloff
        point_lun,lun,startpos+2L*read1Len   ; start 1st strip
        istat=corget(lun,b)                  ; get the hdr first strip
    endif
    point_lun,lun,startpos
;
;   check that this is cormap or cormapdec data 
;
    cormap1  =0
    cordrift =0
    cormapdec=0
    cormapbm =0
    case string(b.b1.h.proc.procname) of 
        'cormap1': begin
                cormap=1
                cormap1=1
                end 
        'cormapdec': begin
                cormap=1
                cormapdec=1
                end 
        'cormapbm': begin
                cormap=1
                cormapbm=1
                end 
        'cordrift': begin
                cordrift=1
                end 
         else    : begin
            print,'scan ',b.b1.h.std.scannumber,$
                ' is not cormap1,cordrift, or cormapdec data'
            return,-1
            end
   endcase
   matchProc=string(b.b1.h.proc.procname)
   matchSrc =string(b.b1.h.proc.srcname)
   matchRcv =iflohrfnum(b.b1.h.iflo)
;
;   get the samples per strip, number of strips to use
;
    totstripsmap=b.b1.h.proc.iar[1]
    if (cormap) then begin
        firststrip  =b.b1.h.proc.iar[2]-1           ; count from 0
        bothdir     =(b.b1.h.proc.iar[0] and 4) eq 0
    endif else begin
        firststrip  =b.b1.h.proc.iar[4]-1           ; count from 0
        bothdir     =0
    endelse
    smpperstrip    =b.b1.h.proc.iar[3]
    numstrips   =totstripsmap-firststrip
;
;   figure out the cals
;   8  - cal at start of map only
;   1,3- cal at start of each strip
;   2,3- cal at end of each strip
;
    totcals=0
    caltype=0
    cals=0                      ; so we reallocate in cormapcalinp
    needCalAtStart=0
    if ( cormap eq 1) then  begin
        caltype     =ishft(b.b1.h.proc.iar[0],-5) and 11
        case 1 of
            (caltype eq 1): begin needCalAtStart=1 & totcals=numstrips & end
            (caltype eq 2): totcals=numstrips
            (caltype eq 3): begin needCalAtStart=1 & totcals=numstrips*2 & end
            (caltype eq 8): begin needCalAtStart=1 & totcals=1 & end
            (caltype eq 0): totcals=0
            else: begin
                 print,'bad caltype found in proc.iar[0]:',caltype
                 return,-1
                 end
        endcase
    endif else begin
        calStart=((b.b1.h.proc.iar[0] and '400'XL) ne 0)?1:0
        calEnd  =((b.b1.h.proc.iar[0] and '2'XL) ne 0)?1:0
        calType = calEnd*2+calStart
        if (calType eq 1) or (calType eq 2 )  then totcals=numstrips
        if (calType eq 3)                     then totcals=numstrips*2
        needCalAtStart=calStart
    endelse
    case  totcals of
        0          : calsperstrip=0
        1          : calsperstrip=0
        numstrips  : calsperstrip=1
        2*numstrips: calsperstrip=2
    endcase
    if totcals eq 0 then retCalRecs=0   ; none to return

    bIndA=polABrd-1             ; board index
    bIndB=polBBrd-1
    nbrds=n_tags(b[0])
    if ((bindA ge nbrds) or $
       (bindA ge nbrds)) then begin
        print,'Illegal board request for this dataset'
        return,-1
    endif
    sbcIndA=0                   ; pol index  within board
    sbcIndB=0
    calrec =0l                  ; count the cal records input
    if b.(bIndb).h.cor.numsbcout eq 2 then sbcIndB=1
;    print,"print inda, indb",sbcIndA,sbcIndA
;
;   allocate struct to hold hdr start each strip then the data
;   c.h           for 1 pol
;   c.d[numlags]  for 1 pol
;
    c={  $
        h :     b.(bIndA).h,$; 
        p :              0.,$;
        az:              0.,$;
        za:              0.,$;
        azErrAsec:       0.,$;
        zaErrAsec:       0.,$;
        raHr:            0.,$;
        decDeg:          0.,$;
        calScl:          0.,$;
        d : fltarr(b.(bIndA).h.cor.lagSbcOut,/nozero)}
    m=replicate(c,2,smpperstrip,numstrips)
    if (retCalRecs) then begin
        lensbc=n_elements(b[0].(bIndA).d[*,sbcIndA])
        a={ scan    :           0L, $ ; scan number for calOn scan
        calsperStrip: calsPerStrip, $ ; 0,1,2..0--> just at start of map
             con    : fltarr(lensbc,2), $ ; lensbc,polA/polB 
             coff   : fltarr(lensbc,2)}   ; lensbc,polA/polB 
        calrecs=replicate(a,totcals)      ; 
        retCalInd=0                         ; location for next cal rec     
    endif
;
;   if there is a cal at the start of the map (once per map or at
;   start of rec) make sure we are pointing at a cal rec. If they
;   passed in the scan of the first strip then back up looking for the
;   cal.
;  
    if  (needCalAtStart) and  (not startIsCal) then begin
        startPos=startPos - 2*read1Len  
        if startPos lt 0 then  begin
            print,'could not position to cal scan at start'
            return,-1
        endif
        point_lun,lun,startpos; start 1st strip
        istat=corget(lun,b)     ; get the hdr first strip
        if istat eq 0 then begin                 ; jump to first strip for hdr
            print,'could not position to cal scan at start'
            return,-1
        endif
        istat=corhcalrec(b.b1.h)
        if istat ne 1 then begin
            print,'cal rec missing at start of map'
            return,-1
        endif
        point_lun,lun,startpos; start 1st strip
    endif
;
;   if caltype == 8 then do the 1 cal at the beginning separate from main loop 
;
    if  (caltype eq 8) then begin
        if  cormapinpcal(lun,b,cals,bIndA,bIndB,calrec,totcals,strip+1,$
            han=han,/rdrec) ne 1 then begin
            print,"Error 1st cal rec"
            return,-1
        endif
        if retCalRecs then begin
            calrecs[retCalInd].scan      =b[0].(bIndA).h.std.scannumber
            calrecs[retCalInd].con[*,0]  =b[0].(bIndA).d[*,sbcIndA]
            calrecs[retCalInd].con[*,1]  =b[0].(bIndB).d[*,sbcIndB]
            calrecs[retCalInd].coff[*,0] =b[1].(bIndA).d[*,sbcIndA]
            calrecs[retCalInd].coff[*,1] =b[1].(bIndB).d[*,sbcIndB]
            retCalInd=retCalInd+1
        endif
    endif
;
;   main loop to input the data
;
    stripsdone=0
    flipinc  = (firststrip mod 2)    ;flip odd strips on entire map
    for strip=0,numstrips-1 do begin
;
;       cal at start of strip   
;
        if  (caltype eq 1) or (caltype eq 3) then begin
            if  cormapinpcal(lun,b,cals,bIndA,bIndB,calrec,totcals,strip+1,$
                /rdrec,han=han) ne 1 then goto,done
            if matchSrc ne string(b[0].b1.h.proc.srcname) then begin
                print,'Found new source:',string(b[0].b1.h.proc.srcname)
                goto,done
            endif
            rfnum=iflohrfnum(b[0].b1.h.iflo)
            if matchRcv ne rfnum then begin
               print,'Found new receiver ,scan,rcvnumber:',$
                    b[0].b1.h.std.scannumber,rfnum
                goto,done
            endif
            if retCalRecs then begin
                calrecs[retCalInd].scan      =b[0].(bIndA).h.std.scannumber
                calrecs[retCalInd].con[*,0]  =b[0].(bIndA).d[*,sbcIndA]
                calrecs[retCalInd].con[*,1]  =b[0].(bIndB).d[*,sbcIndB]
                calrecs[retCalInd].coff[*,0] =b[1].(bIndA).d[*,sbcIndA]
                calrecs[retCalInd].coff[*,1] =b[1].(bIndB).d[*,sbcIndB]
                retCalInd=retCalInd+1
            endif
        endif
;
        istat=corinpscan(lun,b,han=han,maxrecs=maxrecs)
        if istat eq 0 then goto,done
        if matchSrc ne string(b[0].b1.h.proc.srcname) then begin
                print,'Found new source:',string(b[0].b1.h.proc.srcname)
                goto,done
        endif
        if matchProc ne string(b[0].b1.h.proc.procname) then begin
                print,'Found different procedure:',$
                    string(b[0].b1.h.proc.procname)
                goto,done
        endif
        rfnum=iflohrfnum(b[0].b1.h.iflo)
        if matchRcv ne rfnum then begin
               print,'Found new receiver ,scan,rcvnumber:',$
                    b[0].b1.h.std.scannumber,rfnum
                goto,done
        endif

        recsfound=n_elements(b)
        if (recsfound ne smpperstrip) then begin
            print,'only found ',recsfound,' recs in strip',strip+1,' scan:',$
                b[0].b1.h.std.scannumber
            goto,done
        endif
        scancur=b[0].b1.h.std.scannumber
;
;       get ra/dec.. depends if cormap1,cormapdec or cordrift
;       Note: if cormapbm, then raHr decDeg is the az,za great circle
;             offset in degrees (sorry about that...)!!!
;
        case 1 of
          cormap1 or cordrift: begin
             if cormap1 then begin
                raOff=b.b1.h.proc.dar[6]
                raRate= b.b1.h.proc.dar[5]
             endif else begin
                raOff=b.b1.h.proc.dar[1] ;this is current Ra offset
                raRate= 15./3600.*!dtor  ;15"sec/sec this is current ra!!
             endelse
             raHr =(b.b1.h.pnt.r.reqposrd[0] + $
                raOff              +                          $;offset ra
                b.b1.h.proc.dar[0]*(findgen(smpperstrip)+.5)* $;tm center integr
                solToSid * raRate) *              $;rate rd/sec
                24. / (2.*!pi)                                 ; to hours
              decDeg =(b.b1.h.pnt.r.reqposrd[1] + $
                       b.b1.h.proc.dar[7]) * !radeg
          end
          cormapdec : begin
             raHr =(b.b1.h.pnt.r.reqposrd[0] + $
                    b.b1.h.proc.dar[6])*24./(2.*!pi)
              decDeg =(b.b1.h.pnt.r.reqposrd[1] + $
                       b.b1.h.proc.dar[7]       + $
                b.b1.h.proc.dar[0]*(findgen(smpperstrip)+.5)* $;tm center integr
                solToSid* b.b1.h.proc.dar[5])    *  !radeg     ;rate rd/sec
          end
          cormapbm :  begin
;
;                 again.. raHr  =azOffDeg gc
;                         decdeg=zaOffDeg gc ...
;                 too late to change the names to c1,c2
;
;                 (azOffRd gc) + (smpIndex)*rateAzRdsec
            raHr= (b.b1.h.proc.dar[6] + (findgen(smpperstrip) + .5) *  $
                    b.b1.h.proc.dar[5]) * !radeg        
                
            decDeg= b.b1.h.proc.dar[7] * !radeg     
          end
        endcase
;
;       if we are going both directions, we need to flip the 
;       array on odd strips of the entire map
;
        if bothdir and (((strip+flipinc) mod 2) eq 1) and (norev eq 0) $
                then begin
            rev=1
            for i=0,smpperstrip-1 do begin
                m[0,smpperstrip-i-1,strip].h=b[i].(bindA).h
                m[1,smpperstrip-i-1,strip].h=b[i].(bindB).h
            endfor
            b=reform(b,1,n_elements(b),/overwrite)
;
;           different versions of idl,create different dimensions.
;           some have embedded[n,1,m] ..
;           we want to reverse the last dimension.
;
            if ndimd eq -1 then begin
                sz1=size(b.(bindA).d[*,sbcIndA])
                ndimd=sz1[0]
                sz2=size(b.(bindA).h.cor.lag0pwrratio[sbcIndA])
                ndimh=sz2[0]
;               print,sz1
;               print,sz2
;               stop
;               print,ndimd,ndimh
            endif
            m[0,*,strip].d=reverse(b.(bindA).d[*,sbcIndA],ndimd)
            m[1,*,strip].d=reverse(b.(bindB).d[*,sbcIndB],ndimd)
            m[0,*,strip].p=reverse(b.(bindA).h.cor.lag0pwrratio[sbcIndA],ndimh)
            m[1,*,strip].p=reverse(b.(bindB).h.cor.lag0pwrratio[sbcIndB],ndimh)
            m[0,*,strip].az=reverse(b.b1.h.std.azttd*.0001,ndimh)
            m[0,*,strip].za=reverse(b.b1.h.std.grttd*.0001,ndimh)
            m[0,*,strip].azErrAsec=reverse(b.b1.h.pnt.errAzRd*!radeg*3600.*$
                            sin(m[0,*,strip].za*!dtor),ndimh)
            m[0,*,strip].zaErrAsec=reverse(b.b1.h.pnt.errZaRd*!radeg*3600.,$
                                    ndimh)
            m[0,*,strip].raHr =reform(reverse(raHr),1,n_elements(rahr))
            m[0,*,strip].decDeg =reform(reverse(decDeg),1,n_elements(decDeg))
;           print,'flip'
;           stop
            m[1,*,strip].az    = m[0,*,strip].az
            m[1,*,strip].za    = m[0,*,strip].za    
            m[1,*,strip].azErrAsec = m[0,*,strip].azErrAsec 
            m[1,*,strip].zaErrAsec = m[0,*,strip].zaErrAsec 
            m[1,*,strip].raHr  = m[0,*,strip].raHr  
            m[1,*,strip].decDeg= m[0,*,strip].decDeg
        endif else begin
            rev=0
            b=reform(b,1,n_elements(b),/overwrite)
            m[0,*,strip].h=b.(bIndA).h
            m[1,*,strip].h=b.(bIndB).h
            m[0,*,strip].d=b.(bIndA).d[*,sbcIndA]
            m[1,*,strip].d=b.(bIndB).d[*,sbcIndB]
            m[0,*,strip].p=b.(bindA).h.cor.lag0pwrratio[sbcIndA]
            m[1,*,strip].p=b.(bindB).h.cor.lag0pwrratio[sbcIndB]

            m[0,*,strip].az=b.b1.h.std.azttd*.0001
            m[0,*,strip].za=b.b1.h.std.grttd*.0001
            m[0,*,strip].azErrAsec=b.b1.h.pnt.errAzRd*!radeg*3600.*$
                            sin(m[0,*,strip].za*!dtor)
            m[0,*,strip].zaErrAsec=b.b1.h.pnt.errZaRd*!radeg*3600.
            m[0,*,strip].raHr   =reform(raHr,1,n_elements(raHr))
            m[0,*,strip].decDeg =reform(decDeg,1,n_elements(decDeg))
;           print,'no flip'
;           stop
            m[1,*,strip].az    = m[0,*,strip].az
            m[1,*,strip].za    = m[0,*,strip].za    
            m[1,*,strip].azErrAsec = m[0,*,strip].azErrAsec 
            m[1,*,strip].zaErrAsec = m[0,*,strip].zaErrAsec 
            m[1,*,strip].raHr  = reform(m[0,*,strip].raHr,1,n_elements(raHr))  
            m[1,*,strip].decDeg= reform(m[0,*,strip].decDeg,1,$
                        n_elements(decDeg))
        endelse
        b=reform(b,n_elements(b),/overwrite)


        if  (caltype eq 2) or (caltype eq 3) then begin
            if  cormapinpcal(lun,b,cals,bIndA,bIndB,calrec,totcals,strip+1,$
                    /rdrec,han=han) ne 1 then goto,done
            if matchSrc ne string(b[0].b1.h.proc.srcname) then begin
                print,'Found new source:',string(b[0].b1.h.proc.srcname)
                goto,done
            endif
            rfnum=iflohrfnum(b[0].b1.h.iflo)
            if matchRcv ne rfnum then begin
               print,'Found new receiver ,scan,rcvnumber:',$
                    b[0].b1.h.std.scannumber,rfnum
                goto,done
            endif

            if retCalRecs then begin
                calrecs[retCalInd].scan      =b[0].(bIndA).h.std.scannumber
                calrecs[retCalInd].con[*,0]  =b[0].(bIndA).d[*,sbcIndA]
                calrecs[retCalInd].con[*,1]  =b[0].(bIndB).d[*,sbcIndB]
                calrecs[retCalInd].coff[*,0] =b[1].(bIndA).d[*,sbcIndA]
                calrecs[retCalInd].coff[*,1] =b[1].(bIndB).d[*,sbcIndB]
                retCalInd=retCalInd+1
            endif
;
;           if we are doing cals before and after and we just
;           flipped the row, also flip the cals
;
            if (caltype eq 3) and rev then begin
              tmp=cals[calrec-1]
              cals[calrec-1]=cals[calrec-2]
              cals[calrec-2]=tmp
              if retCalRecs then begin
                tmp=calrecs[retCalInd-1]
                calrecs[retCalInd-1]=calrecs[retCalInd-2]
                calrecs[retCalInd-2]=tmp
              endif
            endif
        endif
        stripsdone=stripsdone+1
        print,"strip:",strip+firststrip,"  scan:",scancur," pnts:",recsfound,$
            ' rev:',rev

    endfor
done:
;
;   fill in the cal scale factors. depends on the cals they used.
;
    if stripsdone ne numstrips then begin
        m=temporary(m[*,*,0:stripsdone-1])
        if (caltype eq 1) or (caltype eq 2) then begin
            cals=cals[0:stripsdone-1]
            if retCalRecs then calrecs=calrecs[0:stripsdone-1]
        endif else begin
;            if (caltype eq 3) then cals   =cals[0:(stripsdone-1)*2]
;            if retCalRecs     then calrecs=calrecs[0:(stripsdone-1)*2]
             if (caltype eq 3) then cals   =cals[0:stripsdone*2-1]
             if retCalRecs     then calrecs=calrecs[0:stripsdone*2-1]
        endelse
    endif  
;
;   move the cal scale factor into m.calscl
;
    case 1 of 
;
;       1 cal/strip. each sample in strip gets this value
;
        (caltype eq 1) or (caltype eq 2): begin
            if stripsdone eq 1 then begin
            m[0,*,*].calscl=reform(cals.calscl[0] ## (fltarr(smpperstrip)+1.),$
                            1,smpperstrip)
            m[1,*,*].calscl=reform(cals.calscl[1] ## (fltarr(smpperstrip)+1.),$
                            1,smpperstrip)
            endif else begin
            m[0,*,*].calscl=reform(cals.calscl[0] ## (fltarr(smpperstrip)+1.),$
                            1,smpperstrip,stripsdone)
            m[1,*,*].calscl=reform(cals.calscl[1] ## (fltarr(smpperstrip)+1.),$
                            1,smpperstrip,stripsdone)
            endelse
              end
;
;       2 cal/strip. each sample in strip gets average of start,end cal
;
        (caltype eq 3): begin
            ind=indgen(stripsdone)*2
            m[0,*,*].calscl= reform($
                (cals[ind].calscl[0]+cals[ind+1].calscl[0])*.5 $
                ## (fltarr(smpperstrip)+1.),1,smpperstrip,stripsdone)
            m[1,*,*].calscl= reform($
                (cals[ind].calscl[1]+cals[ind+1].calscl[1])*.5 $
                ## (fltarr(smpperstrip)+1.),1,smpperstrip,stripsdone)
            end
;
;       1 cal at start of map. this value for entire map
;
        (caltype eq 8):begin
            m[0,*,*].calscl=cals.calscl[0]
            m[1,*,*].calscl=cals.calscl[1]
            end
        else : m.calscl=0.
        endcase
;
;   see if we avg samples of the map
;
    if doavgsmp then begin
        mtmp=temporary(m)
        smpPerStripAvg=smpPerStrip/avgsmp
        m=replicate(c,2,smpperstripAvg,stripsdone)
        if smpperstripAvg*avgsmp ne smpPerStrip then $
                mtmp=mtmp[*,0:smpPerStripAvg*avgsmp-1L,*]
        mtmp=reform(mtmp,2,avgsmp,smpperstripavg,stripsdone,/overwrite)
;
;       grab the last of each smp to avg for the following fields
;
;       <pjp001>
        if (!version.release ge '5.5') then begin
            m.h =reform(mtmp[*,avgsmp-1,*,*].h,1,2,smpperstripavg,stripsdone)
        endif else begin
            m.h =reform(mtmp[*,avgsmp-1,*,*].h,2,smpperstripavg,stripsdone)
        endelse
        m.az=reform(mtmp[*,avgsmp-1,*,*].az,2,smpperstripavg,stripsdone)
        m.za=reform(mtmp[*,avgsmp-1,*,*].za,2,smpperstripavg,stripsdone)
        m.azErrAsec=reform(mtmp[*,avgsmp-1,*,*].azErrAsec,2,smpperstripavg,$
                           stripsdone)
        m.zaErrAsec=reform(mtmp[*,avgsmp-1,*,*].zaErrAsec,2,smpperstripavg,$
                           stripsdone)
;
;       use the average of the smps in the field for the following
;
        m[0,*,*].p=total(mtmp[0,*,*,*].p,2)/avgsmp
        m[1,*,*].p=total(mtmp[1,*,*,*].p,2)/avgsmp
        raHr  =total(mtmp[0,*,*,*].raHr,2)  /avgsmp
        decdeg=total(mtmp[0,*,*,*].decDeg,2)  /avgsmp
        m[0,*,*].raHr=raHr
        m[1,*,*].raHr=raHr
        m[0,*,*].decDeg=decDeg
        m[1,*,*].decDeg=decDeg
        m[0,*,*].calscl=total(mtmp[0,*,*,*].calscl,2)/avgsmp
        m[1,*,*].calscl=total(mtmp[1,*,*,*].calscl,2)/avgsmp
        m[0,*,*].d     =total(mtmp[0,*,*,*].d,3)/avgsmp
        m[1,*,*].d     =total(mtmp[1,*,*,*].d,3)/avgsmp
;
;       fix up some of the header locations
;
        m.h.cor.dumpsperinteg= m.h.cor.dumpsperinteg * avgsmp
        m.h.proc.iar[3]=smpperstripavg
        m.h.proc.dar[0]= m.h.proc.dar[0] * avgsmp
        if cordrift then m.h.proc.iar[2]= m.h.proc.dar[0]*smpperstripavg
    endif
;   
    if stripsdone eq numstrips then return,1
    return,0
end
