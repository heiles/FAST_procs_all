;+
;NAME:
;wasftochdr - convert fits hdr to cor header
;
;SYNTAX: istat=wasftochdr(desc,h,hf=hf,nrows=nrows,pol=pol)
;
;ARGS: 
;   desc:{wasdesc} was descriptor returned from wasopen()
;
;RETURNS:
;   istat: int  1 ok, 0 eof, -1 error.
;    h: {corhdr}  correlator header
;    hf:{washdr}  was hdr extension..
; nrows:   long   number of rows to advance desc.curpos if you
;                 want to update the position.
;pol[2,nbrds]:  long   codes the pol type polA=1, polB=2 for each 
;                 spectra on each board.
;
;DESCRIPTION:
;   Read in fits header for the current group and convert it
;to a correlator header. If the file is not positioned at
;the start of a group, then move forward to the start of the
;next group.
;
;NOTE: this routine does not update the position in the file.
;You are left pointing at the input position.
;-
;history
; 25jun04 - if frontend = alfa, force rfnum to be 17
function wasftochdr,desc,h,hf=hf,nrows=nrows,pol=pol
;
;   map the curpos row ptr (0 based) in the scan, grp we are about to read
;
    errmsg=''
    istat=wasalignrec(desc,scanind=iscan,recInd=recInd)
    if istat ne 1 then return,istat
;
    rowsInRec=desc.scanI[iscan].rowsinrec
    nrows=rowsInRec
    curposUsed=desc.curpos
    recNum=recInd+1
;
    curPosStart=desc.curpos
        
    nbrds=desc.scanI[iscan].nbrds
    pol  =intarr(2,nbrds)
    h =replicate({hdr},nbrds)
    hf=replicate({washdr},nbrds)
;
;  Get the data
;
;   time Ast
;
    fxbread,desc.lun,time,'CRVAL5',curPosStart+1,errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
    timeAst= long((time - 4.)*3600.)
    if timeAst lt 0L then timeAst=timeAst+86400L
;
;   srcName 
;
    fxbread,desc.lun,src,'OBJECT',curPosStart+1,errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
    src=byte(src)
;
;   obs_name this rec
;
    fxbread,desc.lun,obsNm  ,'OBS_NAME',curPosStart+1, errmsg=errmsg   ; byte
    obsNm=strlowcase(obsNm)
    obsNmLen=strlen(obsNm)
    if errmsg ne '' then goto,hdrreaderr
;
;   procname (switch to pattern name)
;
    fxbread,desc.lun,proc_name,desc.colI.patnam,curPosStart+1,errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
    car0   =obsNm                   ; by default use this..
    car0Len=obsNmLen                ; by default use this..
    iar    =lonarr(10)
    case  1 of
        proc_name eq 'ONOFF': begin
                        proc_name='onoff'
                        if obsNm eq 'on' then begin
                            if iscan lt (desc.totscans-2) then begin 
                                iar[1]=(desc.scanI[iscan+2].patnm eq 'CAL')?1:0 
                            endif
                        endif else begin
                            if iscan lt (desc.totscans-1) then begin 
                                iar[1]=(desc.scanI[iscan+1].patnm eq 'CAL')?1:0 
                            endif
                        endelse
                    end
        proc_name eq 'CAL'  : proc_name='calonoff'
        proc_name eq 'DRIFT': proc_name='cordrift'
        proc_name eq 'DPS'  : proc_name='dps'
        proc_name eq 'CROSS': proc_name='cross'
        proc_name eq 'ON'   : proc_name='on'
        proc_name eq 'RUN'   : proc_name='run'
        else : 
    endcase
    procname=byte(proc_name)

    lagconfig=9                 ; << FIX >>
;
;    info for new fit header.. read each row of grp since value can
;    change board to board. there may be more than 1 row in a board.
;
;   freq Hz at reference pixel
;
    fxbread,desc.lun,crval1,'CRVAL1',[curPosStart+1,curPosStart+rowsInRec],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   freq step between channels.
;
    fxbread,desc.lun,cdelt1,'CDELT1',[curPosStart+1,curPosStart+rowsInRec],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   ref pix number (count from 1)
;
    fxbread,desc.lun,crpix1,'CRPIX1',[curPosStart+1,curPosStart+rowsInRec],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   restfreq
;
    fxbread,desc.lun,restfreq,'RESTFREQ',[curPosStart+1,curPosStart+rowsInRec],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   velocity
;
    fxbread,desc.lun,velocity,'VELOCITY',[curPosStart+1,curPosStart+rowsInRec],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   ctype1 .. velocity type 
;
    fxbread,desc.lun,ctype1,'CTYPE1',[curPosStart+1,curPosStart+rowsInRec],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   flip band flipped
;
    fxbread,desc.lun,flipped,desc.colI.flip,[curPosStart+1,$
			curPosStart+rowsInRec],errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   bandwidth num 0 = 100, 1=50,2=25...
;
    fxbread,desc.lun,bandwd,'BANDWID',[curPosStart+1,curPosStart+rowsInRec],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
    bwnum=long(alog(100./(bandwd*1d-6))/alog(2.) + .5) ;to  Mhz
;
;   azimuth
;
    fxbread,desc.lun,az,desc.colI.az,curPosStart+1, errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
    az=long(az*10000.+.5)
;
;   lag0 pwrratio
;
    fxbread,desc.lun,lag0,'TOT_POWER',[curPosStart+1,curPosStart+rowsInRec],$
            errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   main elevation .. assume dome.. 
;
    fxbread,desc.lun,grza,desc.colI.el,curPosStart+1,errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
    grza=long((90.-grza)*10000. + .5)
;
;   ch za 
;
    fxbread,desc.lun,chza,desc.colI.elalt,curPosStart+1,errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
    chza=long((90.-chza)*10000. + .5)
;
;   time stamp for position
;
    fxbread,desc.lun,postm,desc.colI.encTm,curPosStart+1, errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   ifval
;
    fxbread,desc.lun,ifVal,'IFVAL',[curPosStart+1,curPosStart+rowsInRec],$
                 errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
; iflo junk:
;
    fxbread,desc.lun,caltype,'CALTYPE',curPosStart+1, errmsg=errmsg ; ascii
    if errmsg ne '' then goto,hdrreaderr 
    case 1 of
        caltype eq 'hcal'   : ical=5
        caltype eq 'hcorcal': ical=1
        caltype eq 'hxcal'  : ical=3
        caltype eq 'h90cal' : ical=7
        caltype eq 'lcal'   : ical=4
        caltype eq 'lcorcal': ical=0
        caltype eq 'lxcal'  : ical=2
        caltype eq 'l90cal' : ical=6
        else : ical=0
    endcase
    fxbread,desc.lun,rfnum  ,'RFNUM',curPosStart+1, errmsg=errmsg   ; byte
    if errmsg ne '' then goto,hdrreaderr
	fxbread,desc.lun,frontend ,'FRONTEND',curPosStart+1, errmsg=errmsg   ; byte
	if errmsg ne '' then goto,hdrreaderr
	if frontend eq 'ALFA' then rfnum=17
    fxbread,desc.lun,lbwhybrid ,'LBWHYB',curPosStart+1, errmsg=errmsg   ; byte
    if errmsg ne '' then goto,hdrreaderr
    lbwLinPol=(lbwhybrid eq 0)?1:0
    fxbread,desc.lun,ifnum ,'IFNUM',curPosStart+1, errmsg=errmsg   ; byte
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,hybrid10gc ,'HYBRID',curPosStart+1, errmsg=errmsg   ; byte
    if errmsg ne '' then goto,hdrreaderr
    hybrid10gc=(hybrid10gc eq 0)?0:1
    iflostat1=(ishft(ulong(rfnum),27))      or (ishft(ulong(ifnum),24)) or $
              (ishft(ulong(hybrid10gc),23)) or (ishft(ulong(lbwLinPol),21)) 
    iflostat2=(ishft(ulong(ical),24))
;
    fxbread,desc.lun,syn1 ,'SYN1',curPosStart+1, errmsg=errmsg   ; byte
    if errmsg ne '' then goto,hdrreaderr
    fxbread,desc.lun,syn2 ,'SYNFRQ',curPosStart+1, errmsg=errmsg   ; byte
    if errmsg ne '' then goto,hdrreaderr
;
; pattern junk
;
; 
; broken !!FIX!!
; std.grpCurRec ..since they don't start with first board all the time
; cor.bwNum     .. they have 100 Mhz bw.
; most of the h.dop header
;
;  compute observer velocity projected, and then dopplerCorFactor
;
;  DF=frqRP/frqBCRest=1./(1. + velObj-velUsrProj)
;  (1.+velobj-velusrProj)=frqBC/frqRP
;   (1. + velObj - frqBCRest/frqRP  = velUsrProj
;
;   FIX.. below is leaving velType to vel rather than Z
;   looks like sign of velocity is wrong..
;
    c=299792.458D               ; speed of light km/sec
    velObsProj=(1D + velocity[0]/c - (restFreq[0]/crval1[0]))*c 
    velSys=strmid(ctype1[0],4,4)
    case 1 of 
        strcmp(velSys,'-TOP'):dopStat=0UL
        strcmp(velSys,'-OBS'):dopStat=0UL
        strcmp(velSys,'-LSR'):dopStat='18000000'XUL
        strcmp(velSys,'-HEL'):dopStat='10000000'XUL
        strcmp(velSys,'-GEO'):dopStat='08000000'XUL
        else: dopStat=0UL
    endcase
;
; fits was one row per spectra,
; hdrcor has one entry per board..
; for those entries that differ by board, 
;  need to move info 1 board at a time.
;
    j=0                         ; index start of each board
;
;   things that do not change board to board
;
    h.std.grpTotRecs=desc.scanI[iscan].nbrds
    h.std.time      =timeAst
    h.proc.srcname  =src
    h.proc.procname =procname
    h.proc.car[0:car0Len-1,0] =byte(car0)
    h.std.scanNumber=desc.scanI[iscan].scan
    h.std.grpNum    =recNum
    h.cor.numbrdsused=desc.scanI[iscan].nbrds

    h.std.azttd     =az
    h.std.grttd     =grza
    h.std.chttd     =chza
    h.std.posTmMs   =postm

    h.iflo.if1.st1=iflostat1
    h.iflo.if1.st2=iflostat2
	h.iflo.if1.lo1=syn1

    h.dop.id         = byte('DOP ')
    h.dop.stat       = dopStat
    h.dop.velobsProj = velObsProj;
;
;   things that change board to board
;   .. here we grab from desc.scanI.. order is already set..
;
    h.cor.numSbcOut =desc.scanI[iscan].nsbc[0:nbrds-1]
    h.cor.lagsbcOut =desc.scanI[iscan].nlags[0:nbrds-1]
    h.cor.boardId   =desc.scanI[iscan].brdNum[0:nbrds-1]
    hf.numChan=desc.scanI[iscan].nlags[0:nbrds-1]
;
;   now loop over stuff that changes board to board that we read
;   from table
    j=0                         ; index for start this board in row arrays
    for ibrd=0,nbrds-1 do begin
        npol=(desc.scanI[iscan].nsbc[ibrd] ge 2)?2:1
        pol[0:npol-1,ibrd]=ifval[j:j+npol-1]+1
        h[ibrd].cor.lagconfig =lagconfig
        h[ibrd].cor.bwnum     =bwnum[j]
        h[ibrd].std.grpCurRec =ibrd + 1  ; <FIX> used for doppler offsets
        h[ibrd].cor.lag0pwrratio[0:npol-1] =lag0[j:j+npol-1]
        h[ibrd].cor.attndb[0:npol-1]       =$
        desc.scanI[iscan].corattn[0:npol-1,ibrd]
        corStat=0UL
        corStat=(flipped[j])?corStat or '0x00100000'XUL:corStat
        h[ibrd].cor.state=corStat
        h[ibrd].proc.iar=iar
	    h[ibrd].iflo.if2.synFreq=syn2
;
        hf[ibrd].rpfreq       =crval1[j] *1e-6
        hf[ibrd].rpChan       =crpix1[j]
        hf[ibrd].rpRestFreq   =restfreq[j]
        hf[ibrd].chanfreqStep =cdelt1[j]*1e-6
;
;   doppler header
;
        h[ibrd].dop.freqOffsets=[0d,0D,0D,0D] ;  force it    
        h[ibrd].dop.freqBcRest = restfreq[j]*1d-6 ; for this board
        h[ibrd].dop.velOrZ     = velocity[j] 
        h[ibrd].dop.factor     = crval1[j]/restfreq[j]

        j=j+desc.scanI[iscan].nsbc[ibrd]    ; skip to next board
    endfor
;
;    
    if (proc_name eq 'calonoff') and (car0  eq 'on') then  begin
        h.cor.calon = h.cor.lag0pwrratio
    endif else begin
        h.cor.caloff = h.cor.lag0pwrratio
    endelse
    return,1

hiteof:
    return,0
hdrreaderr:
    print,'Error reading hdr data:'+ errmsg
    return,-1
end
