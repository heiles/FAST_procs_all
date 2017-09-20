;;+
;agcinp - input a set of critical/full block data from vertex log file.
;SYNTAX: pnts=agcinp(lun,nptsreq,b,cb=cb,fb=fb,onekind=onekind)
;ARGS:
;       lun:    long    lun for file to read from
;   nptsreq:    long    number of recs to read in. if <=0 or not supplied
;                       then read to end of file.
;       b[] :   {cbfb}  return cblock,fblock info here, if cb or fb set then
;                       structure will only be cb or fb    
;      pnts :    long   return the number of points input.
;
;KEYWORDS:
;   cb   : if set, only input cblock
;   fb   : if set, only input fblock
;  onekind: if set then the datafile only has the cb, or fb specified
;
;;-
function agcinp,lun,b,npts,cb=cb,fb=fb  
;
;   get the file size, what is left to read
;
    rdblk=10000L

    VTX_CNV_AZ_ENC_TO_DEG=1.441775344488189e-4
    VTX_UNITS_TORQUE_AZ_I=1.2375e-2
    VTX_UNITS_TORQUE_GR_I = 1.7492e-2
    VTX_UNITS_TORQUE_CH_I =1.7492e-2
    VTX_UNITS_VEL_SETPNT_DEGS_P_SEC_AZ=4.0690e-4
    VTX_UNITS_VEL_SETPNT_DEGS_P_SEC_ZA=4.0690e-5
    VTX_UNITS_BENDING_COMP_AZ_NM=            3.0938e-2
    VTX_UNITS_TORQUE_BIAS_GR_NM =            4.3730e-2
    VTX_UNITS_GRAV_COMP_GR_NM   =            4.3730e-2
    VTX_UNITS_TORQUE_BIAS_CH_NM =            4.3730e-2
    VTX_UNITS_GRAV_COMP_CH_NM   =            4.3730e-2


    cbze=44L
    fbsize=196L
    sizeToUse=cbze+fbsize
    if n_elements(npts) eq 0 then npts=-1
;
;   code   input   output
;    0     both     both
;    1     both     cb  
;    2     both     fb  
;   11     cb       cb  
;   12     fb       fb  
;
    code=0
    if keyword_set(onekind) then code=10
    if keyword_set(cb)     then code=code+1
    if keyword_set(fb)     then code=code+2
    if code eq 11 then sizeToUse=cbze
    if code eq 12 then sizeToUse=fbsize
;
    tmrd   =0.D
    tmalloc=0.D
    tmmv   =0.D
    fst=fstat(lun)
    pntsleft=(fst.size-fst.cur_ptr)/sizeToUse
    nptsl=npts
    if nptsl le 0 then nptsl=pntsleft
    if pntsleft lt npts then nptsL=pntsleft
    if pntsleft le 0 then return,0
    toLoop=nptsL  / rdblk
    atend= nptsL mod rdblk
    inppnts=(nptsL < rdblk)
    if atend ne 0 then toLoop=toLoop+1
;
;    allocate the buffers
;
    tm1=systime(1)
    case code of
        0   : begin
                b  =replicate({cbfb}   ,nptsL)
                bIn=replicate({cbfbInp},inppnts)
              end
        1   : begin
                b  =replicate({cb}   ,nptsL)
                bIn=replicate({cbfbInp},inppnts)
              end
        2   : begin
                b  =replicate({fb}   ,nptsL)
                bIn=replicate({cbfbInp},inppnts)
              end
        11  : begin
                b  =replicate({cb}   ,nptsL)
                bIn=replicate({cbInp},inppnts)
              end
        12  : begin
                b  =replicate({fb}   ,nptsL)
                bIn=replicate({fbInp},inppnts)
              end
     endcase    
     tm2=systime(1)
     tmalloc=tm2-tm1
     done=0
     is=0
     for i=1,toLoop do begin
        if  (i eq toLoop) and (atend ne 0) and (toLoop ne 1) then begin
            tma=systime(1)
            rdBlk=atend
            bIn=replicate({cbfbInp},rdBlk)
            tmalloc=(systime(1)-tma)+tmalloc
        endif
        tma=systime(1)
        readu,lun,bIn
        tmrd=(systime(1)-tma)+tmrd
        ie=is+rdBlk-1
        tma=systime(1)
     case code of
        0: begin
            b[is:ie].cb.time      =bIn.cb.timeMs*.001
            b[is:ie].cb.tmOffsetPT=bIn.cb.tmOffsetPTms*.001
            b[is:ie].cb.freePTpos = bIn.cb.freePTpos
            b[is:ie].cb.genStat=bIn.cb.genStat
            b[is:ie].cb.stat[0]=bIn.cb.statAz
            b[is:ie].cb.stat[1]=bIn.cb.statGr
            b[is:ie].cb.stat[2]=bIn.cb.statCh
            b[is:ie].cb.mode[0]=bIn.cb.modeAz
            b[is:ie].cb.mode[1]=bIn.cb.modeGr
            b[is:ie].cb.mode[2]=bIn.cb.modeCh
            b[is:ie].cb.vel    =bIn.cb.vel*.0001
            b[is:ie].cb.pos    =bIn.cb.pos*.0001

            b[is:ie].fb.time    = bIn.fb.timeMs*.001
            b[is:ie].fb.ax      = bIn.fb.ax
            b[is:ie].fb.azEncDif=(bIn.fb.encPos[0]- bIn.fb.encPos[1]) * $
                    VTX_CNV_AZ_ENC_TO_DEG
            b[is:ie].fb.tqAz=bIn.fb.measTorqAz*VTX_UNITS_TORQUE_AZ_I
            b[is:ie].fb.tqGr=bIn.fb.measTorqGr*VTX_UNITS_TORQUE_GR_I
            b[is:ie].fb.tqCh=bIn.fb.measTorqCh*VTX_UNITS_TORQUE_CH_I
            b[is:ie].fb.plcInpStat=bIn.fb.plcInpStat
            b[is:ie].fb.plcOutStat=bIn.fb.plcOutStat
            b[is:ie].fb.posSetPnt =bIn.fb.posSetPnt*.0001
         b[is:ie].fb.velSetPnt[0] =bIn.fb.velSetPnt[0]*$
            VTX_UNITS_VEL_SETPNT_DEGS_P_SEC_AZ
         b[is:ie].fb.velSetPnt[1:2] =bIn.fb.velSetPnt[1:2]*$
            VTX_UNITS_VEL_SETPNT_DEGS_P_SEC_ZA
            b[is:ie].fb.bendingCompAz= bIn.fb.bendingCompAz
            b[is:ie].fb.torqueBiasGr = bIn.fb.torqueBiasGr 
            b[is:ie].fb.gravityCompGr= bIn.fb.gravityCompGr
            b[is:ie].fb.torqueBiasCh = bIn.fb.torqueBiasCh 
            b[is:ie].fb.gravityCompCh= bIn.fb.gravityCompCh
            b[is:ie].fb.posLim       = bIn.fb.posLim*.0001
            b[is:ie].fb.encCor       = bIn.fb.encCor*.0001
            b[is:ie].fb.tmoutNoHostSec= bIn.fb.tmoutNoHostSec
            b[is:ie].fb.tmElapsedSec  = bIn.fb.tmElapsedSec 
            end
        endcase
        tmmv=(systime(1)-tma)+tmmv
        is=is+rdblk
    endfor
    tm4=systime(1)
;lab=string(format='("alloc:",f6.3," read:",f6.3," mv:",f6.3," tot:",f6.3)',$
;           tm2-tm1,tm3-tm2,tm4-tm3,tm4-tm1)
;lab=string(format='("alloc:",f6.3," tot:",f6.3)',$
;           tm2-tm1,tm4-tm1)
lab=string(format='("alloc:",f6.3," read:",f6.3," mv:",f6.3," tot:",f6.3)',$
            tmalloc,tmrd,tmmv,tm4-tm1)
    print,lab
    return,n_elements(b)
end
