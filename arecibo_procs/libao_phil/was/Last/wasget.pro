;+
;NAME:
;wasget - read a group  of was data records.
;
;SYNTAX: istat=wasget(desc,b,scan=scan,han=han)
;
;ARGS: 
;   desc:{wasdesc} was descriptor returned from wasopen()
;
;RETURNS:
;   istat: int  1 ok, 0 eof, -1 error.
;       b: {wasget}  data structure holdin data.
;
;DESCRIPTION:
;   This is the lowlevel routine that reads the data from the fits file.
;This routine in normally not called by users. The user interface to the
;data in the file is via corget(). corget() will call this routine 
;automatically when it is passed a wasDescriptor rather than a
;logical unit number(lun).
;
;18jan04 - added h.dop. set it so that it is doppler update 
;          each sbc even if it is not being done. We will load the
;          correct frequency, velocity into the header so that this
;          will be true.
;19jan04 - force returned data to always be in increasing freq order.
;          for now key off of flipped keyword (until cdelta1 is fixed).
;-
function wasget,desc,b,scan=scan,han=han
;
;   map the curpos row ptr (0 based) in the scan, grp we are about to read
;
    errmsg=''
    if n_elements(scan) gt 0 then begin
    if waspos(desc,scan) ne 1 then begin
            print,"error positioning to scan:",scan
            return,-1
        endif
    endif
    curPosStart=desc.curpos
;    h=fxbheader(desc.lun)
;    naxis2=fxpar(h,'NAXIS2')
    if curposStart ge descI.totrows then goto,hiteof
	ii=(desc.totscans) eq 0? 0 : desc.totscans-1
    iscan=where(curPosStart  ge desc.scanI[0:ii].startind,count)
    if count eq 0 then return,-1
    iscan=iscan[count-1]

    rowsInGrp=desc.scanI[iscan].rowsingrp
    grpNum=(curPosStart-desc.scanI[iscan].startInd)/$
            desc.scanI[iscan].rowsingrp + 1
    hdr={hdr}
    fhdr={washdr}
;
; allocate the data structure
;
     case desc.scanI[iscan].nbrds of
        1: begin 
            b={b1: {h:hdr,$
                    hf: fhdr,$
                    p:intarr(2),$
                accum: 0.D,$
                    d:fltarr(desc.scanI[iscan].nlags[0],$
                             desc.scanI[iscan].nsbc[0],/nozero)}}
            end
        2: begin
           b={b1:{h:hdr,$
                  hf: fhdr,$
                  p:intarr(2),$
              accum: 0.D,$
                  d:fltarr(desc.scanI[iscan].nlags[0],$
                           desc.scanI[iscan].nsbc[0],/nozero)},$
              b2:{h:hdr,$
                  hf: fhdr,$
                  p:intarr(2),$
              accum: 0.D,$
                  d:fltarr(desc.scanI[iscan].nlags[1],$
                           desc.scanI[iscan].nsbc[1],/nozero)}}
            end
        3: begin
            b={b1:{h:hdr,$
                  hf: fhdr,$
                   p:intarr(2),$
               accum: 0.D,$
                    d:fltarr(desc.scanI[iscan].nlags[0],$
                             desc.scanI[iscan].nsbc[0],/nozero)},$
               b2:{h:hdr,$
                  hf: fhdr,$
                   p:intarr(2),$
                 accum: 0.D,$
                    d:fltarr(desc.scanI[iscan].nlags[1],$
                             desc.scanI[iscan].nsbc[1],/nozero)},$
               b3:{h:hdr,$
                  hf: fhdr,$
                   p:intarr(2),$
                 accum: 0.D,$
                    d:fltarr(desc.scanI[iscan].nlags[2],$
                             desc.scanI[iscan].nsbc[2],/nozero)}}
            end
        4: begin
              b={b1:{h:hdr,$
                  hf: fhdr,$
                   p:intarr(2),$
               accum: 0.D,$
                    d:fltarr(desc.scanI[iscan].nlags[0],$
                             desc.scanI[iscan].nsbc[0],/nozero)},$
               b2:{h:hdr,$
                  hf: fhdr,$
                   p:intarr(2),$
                 accum: 0.D,$
                    d:fltarr(desc.scanI[iscan].nlags[1],$
                             desc.scanI[iscan].nsbc[1],/nozero)},$
               b3:{h:hdr,$
                  hf: fhdr,$
                   p:intarr(2),$
                 accum: 0.D,$
                    d:fltarr(desc.scanI[iscan].nlags[2],$
                             desc.scanI[iscan].nsbc[2],/nozero)},$
               b4:{h:hdr,$
                  hf: fhdr,$
                   p:intarr(2),$
                 accum: 0.D,$
                    d:fltarr(desc.scanI[iscan].nlags[3],$
                             desc.scanI[iscan].nsbc[3],/nozero)}}
            end
    endcase
    colData=fxbcolnum(desc.lun,'data',errmsg=errmsg);
    if errmsg ne '' then goto , nodatacol
;
;   get some header info for the old header
;
;   time Ast
;
    fxbread,desc.lun,time,'CRVAL5',curPosStart+1,errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
    timeAst= long((time - 4/24.)*3600.)
    if timeAst lt 0L then timeAst=timeAst+86400L
;
;   srcName 
;
    fxbread,desc.lun,src,'OBJECT',curPosStart+1,errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
    src=byte(src)
    if timeAst lt 0L then timeAst=timeAst+86400L
;
;   procname (switch topattern name)
;
    fxbread,desc.lun,proc_name,'PATTERN_NAME',curPosStart+1,errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
    case  1 of
        proc_name eq 'DRIFT': proc_name='cordrift'
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
    fxbread,desc.lun,crval1,'CRVAL1',[curPosStart+1,curPosStart+rowsInGrp],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   freq step between channels.
;
    fxbread,desc.lun,cdelt1,'CDELT1',[curPosStart+1,curPosStart+rowsInGrp],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   ref pix number (count from 1)
;
    fxbread,desc.lun,crpix1,'CRPIX1',[curPosStart+1,curPosStart+rowsInGrp],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   restfreq
;
    fxbread,desc.lun,restfreq,'RESTFREQ',[curPosStart+1,curPosStart+rowsInGrp],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   velocity
;
    fxbread,desc.lun,velocity,'VELOCITY',[curPosStart+1,curPosStart+rowsInGrp],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   ctype1 .. velocity type 
;
    fxbread,desc.lun,ctype1,'CTYPE1',[curPosStart+1,curPosStart+rowsInGrp],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   flip band flipped
;
    fxbread,desc.lun,flipped,'FLIP',[curPosStart+1,curPosStart+rowsInGrp],$
                errmsg=errmsg
    if errmsg ne '' then goto,hdrreaderr
;
;   bandwidth num 0 = 100, 1=50,2=25...
;
    fxbread,desc.lun,bandwd,'BANDWID',[curPosStart+1,curPosStart+rowsInGrp],$
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
    fxbread,desc.lun,lag0,'TOT_POWER',[curPosStart+1,curPosStart+rowsInGrp],$
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
; pattern junk
;
    fxbread,desc.lun,obsNm  ,'OBS_NAME',curPosStart+1, errmsg=errmsg   ; byte
    obsNm=strlowcase(obsNm)
    obsNmLen=strlen(obsNm)
    if errmsg ne '' then goto,hdrreaderr
;
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
;
    c=299792.458D               ; speed of light km/sec
    velObsProj=(1D + velocity[0]/c - (crval1[0]/restFreq[0]))*c 
    velSys=strmid(ctype1[0],4,4)
    case 1 of 
        strcmp(velSys,'-TOP'):dopStat=0UL
        strcmp(velSys,'-OBS'):dopStat=0UL
        strcmp(velSys,'-LSR'):dopStat='18000000'XUL
        strcmp(velSys,'-HEL'):dopStat='10000000'XUL
        strcmp(velSys,'-GEO'):dopStat='08000000'XUL
        else: dopStat=0UL
    endcase
    j=0                         ; index start of each board
    for ibrd=0,desc.scanI[iscan].nbrds-1 do begin
        for isbc=0,desc.scanI[iscan].nsbc[ibrd]-1 do begin
            fxbread,desc.lun,d,colData,desc.curpos+1,errmsg=errmsg
            if errmsg ne '' then goto,datareaderr
            desc.curpos=desc.curpos+1 
            b.(ibrd).d[*,isbc]=(flipped[j])?reverse(d):d
        endfor
        npol=(desc.scanI[iscan].nsbc[ibrd] ge 2)?2:1
        b.(ibrd).h.std.grpTotRecs=desc.scanI[iscan].nbrds
        b.(ibrd).h.std.time      =timeAst
        b.(ibrd).h.proc.srcname  =src
        b.(ibrd).h.proc.procname =procname
        b.(ibrd).h.proc.car[0:obsNmLen-1,0] =byte(obsNm)
        b.(ibrd).h.std.scanNumber=desc.scanI[iscan].scan
        b.(ibrd).h.std.grpNum    =grpNum
        b.(ibrd).h.cor.numSbcOut =desc.scanI[iscan].nsbc[ibrd]
        b.(ibrd).h.cor.lagsbcOut =desc.scanI[iscan].nlags[ibrd]
        b.(ibrd).h.cor.lagconfig =lagconfig
        b.(ibrd).h.cor.bwnum     =bwnum[j]
        b.(ibrd).h.cor.numbrdsused=desc.scanI[iscan].nbrds
        b.(ibrd).h.cor.boardId   =desc.scanI[iscan].brdNum[ibrd]
        b.(ibrd).h.std.grpCurRec =ibrd + 1  ; <FIX> used for doppler offsets
        b.(ibrd).h.std.azttd     =az
        b.(ibrd).h.std.grttd     =grza
        b.(ibrd).h.std.chttd     =chza
        b.(ibrd).h.std.posTmMs   =postm
        b.(ibrd).h.cor.lag0pwrratio[0:npol-1] =lag0[j:j+npol-1]
        b.(ibrd).h.cor.attndb[0:npol-1]       =$
            desc.scanI[iscan].corattn[0:npol-1,ibrd]
        corStat=0UL
        corStat=(flipped[j])?corStat or '0x00100000'XUL:corStat
        b.(ibrd).h.cor.state=corStat

;
        b.(ibrd).hf.rpfreq      =crval1[j] *1e-6
        b.(ibrd).hf.rpChan      =crpix1[j]
        b.(ibrd).hf.rpRestFreq   =restfreq[j]
        b.(ibrd).hf.chanfreqStep=cdelt1[j]*1e-6
        b.(ibrd).hf.numChan     =desc.scanI[iscan].nlags[ibrd]
        b.(ibrd).h.iflo.if1.st1=iflostat1
        b.(ibrd).h.iflo.if1.st2=iflostat2
;
;   doppler header
;
        b.(ibrd).h.dop.freqOffsets=[0d,0D,0D,0D] ;  force it    
        b.(ibrd).h.dop.velobsProj = velObsProj;
        b.(ibrd).h.dop.freqBcRest = restfreq[j]*1d-6 ; for this board
        b.(ibrd).h.dop.velOrZ     = velocity[j] 
        b.(ibrd).h.dop.factor     = crval1[j]/restfreq[j]
        b.(ibrd).h.dop.id         = byte('DOP ')
        b.(ibrd).h.dop.stat       = dopStat

        j=j+desc.scanI[iscan].nsbc[ibrd]    ; skip to next board
    endfor
    if keyword_set(han) then corhan,b
    return,1

hiteof:
    return,0
nodatacol:
    print,'fits file has no data col in header'
    desc.scanI[iscan].curpos=curposStart
    return,-1
datareaderr:
    desc.curpos=curposStart
    print,'Error reading data array:'+ errmsg
    return,-1
hdrreaderr:
    desc.curpos=curposStart
    print,'Error reading hdr data:'+ errmsg
    return,-1
end
