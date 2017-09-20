;+
;NAME:
;agcinp - input agc records from a log file.
;SYNTAX: pnts=agcinp(lun,b,nptsreq,cb=cb,fb=fb,onekind=onekind)
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
;DESCRIPTION:
;   agcinp is normally called from agcmoninp or agcinpday.
;-
;26jun02 - change torques to ftlbs, bias,etc
;07jul02 - use hagen nonlinear fit to correct for torque nonlinearities
;
function agcinp,lun,b,npts,cb=cb,fb=fb,onekind=onekind,dbg=dbg
;
;   get the file size, what is left to read
;

    VTX_CNV_AZ_ENC_TO_DEG=1.441775344488189e-4
;
;   from vol 2 page 3-3
    VTX_UNITS_TORQUE_AZ_TO_FTLBS=2.852e-2
;
;   hagen non-linear correction for dome/ch
;  10 volt 12 bit a/d
;  so 13.3*(Cnts*10./2047)^.73 
; hagens fit: 13.3(Vmon)^.73  = footlbs
;             13.3(cnts/2047.*10.)^.73  = footlbs
;  

;   VTX_UNITS_TORQUE_GR_TO_FTLBS=4.031e-2
;   VTX_UNITS_TORQUE_CH_TO_FTLBS=4.031e-2
;
    atodToVolts=10./2047.
    ampToFtlbGr=1.651           ; dome
    tqexp=.73
    tqscl=13.3

    VTX_UNITS_VEL_SETPNT_DEGS_P_SEC_AZ=4.0690e-4
    VTX_UNITS_VEL_SETPNT_DEGS_P_SEC_ZA=4.0690e-5
;
;    convert newton meters to ftlbs
;
    nmtoftlbs=.7376
    VTX_UNITS_BENDING_COMP_AZ_TO_FTLBS=nmtoftlbs
    VTX_UNITS_TORQUE_BIAS_GR_TO_FTLBS =nmtoftlbs
    VTX_UNITS_GRAV_COMP_GR_TO_FTLBS   =nmtoftlbs
    VTX_UNITS_TORQUE_BIAS_CH_TO_FTLBS =nmtoftlbs
    VTX_UNITS_GRAV_COMP_CH_TO_FTLBS   =nmtoftlbs


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
    inppnts=nptsl
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
        tma=systime(1)
        readu,lun,bIn
        if (bIn[0].cb.pos[1] gt 200000L) or (bIn[0].cb.pos[1] lt 10000L) then $
           bIn=swap_endian(bIn)

        tmrd=(systime(1)-tma)+tmrd
        tma=systime(1)
     case code of
        0: begin
            b.cb.time      =bIn.cb.timeMs*.001D
            b.cb.tmOffsetPT=bIn.cb.tmOffsetPTms*.001
            b.cb.freePTpos = bIn.cb.freePTpos
            b.cb.genStat=bIn.cb.genStat
            b.cb.stat[0]=bIn.cb.statAz
            b.cb.stat[1]=bIn.cb.statGr
            b.cb.stat[2]=bIn.cb.statCh
            b.cb.mode[0]=bIn.cb.modeAz
            b.cb.mode[1]=bIn.cb.modeGr
            b.cb.mode[2]=bIn.cb.modeCh
            b.cb.vel    =bIn.cb.vel*.0001
            b.cb.pos    =bIn.cb.pos*.0001

            b.fb.time    = bIn.fb.timeMs*.001
            b.fb.ax      = bIn.fb.ax
            b.fb.azEncDif=(bIn.fb.encPos[0]- bIn.fb.encPos[1]) * $
                    VTX_CNV_AZ_ENC_TO_DEG
            b.fb.tqAz=bIn.fb.measTorqAz*VTX_UNITS_TORQUE_AZ_TO_FTLBS
;           b.fb.tqGr=bIn.fb.measTorqGr*VTX_UNITS_TORQUE_GR_TO_FTLBS 
            b.fb.tqGr=   tqscl*((bIn.fb.measTorqGr*atodToVolts)^tqexp)
            b.fb.tqCh=   tqscl*((bIn.fb.measTorqCh*atodToVolts)^tqexp)
            b.fb.plcInpStat=bIn.fb.plcInpStat
            b.fb.plcOutStat=bIn.fb.plcOutStat
            b.fb.posSetPnt =bIn.fb.posSetPnt*.0001
         b.fb.velSetPnt[0] =bIn.fb.velSetPnt[0]*$
            VTX_UNITS_VEL_SETPNT_DEGS_P_SEC_AZ
         b.fb.velSetPnt[1:2] =bIn.fb.velSetPnt[1:2]*$
            VTX_UNITS_VEL_SETPNT_DEGS_P_SEC_ZA
            b.fb.bendingCompAz= bIn.fb.bendingCompAz*$
                VTX_UNITS_BENDING_COMP_AZ_TO_FTLBS
            b.fb.torqueBiasGr = bIn.fb.torqueBiasGr*$
                VTX_UNITS_TORQUE_BIAS_GR_TO_FTLBS
            b.fb.gravityCompGr= bIn.fb.gravityCompGr*$
                VTX_UNITS_GRAV_COMP_GR_TO_FTLBS
            b.fb.torqueBiasCh = bIn.fb.torqueBiasCh *$
                VTX_UNITS_TORQUE_BIAS_CH_TO_FTLBS
            b.fb.gravityCompCh= bIn.fb.gravityCompCh*$
                VTX_UNITS_GRAV_COMP_CH_TO_FTLBS
            b.fb.posLim       = bIn.fb.posLim*.0001
            b.fb.encCor       = bIn.fb.encCor*.0001
            b.fb.tmoutNoHostSec= bIn.fb.tmoutNoHostSec
            b.fb.tmElapsedSec  = bIn.fb.tmElapsedSec 
            end
;
;           both in cb out
;
       1: begin
            b.time      =bIn.cb.timeMs*.001D
            b.tmOffsetPT=bIn.cb.tmOffsetPTms*.001
            b.freePTpos = bIn.cb.freePTpos
            b.genStat=bIn.cb.genStat
            b.stat[0]=bIn.cb.statAz
            b.stat[1]=bIn.cb.statGr
            b.stat[2]=bIn.cb.statCh
            b.mode[0]=bIn.cb.modeAz
            b.mode[1]=bIn.cb.modeGr
            b.mode[2]=bIn.cb.modeCh
            b.vel    =bIn.cb.vel*.0001
            b.pos    =bIn.cb.pos*.0001
            end
;
;       both in , fb out
        2: begin
            b.time    = bIn.fb.timeMs*.001
            b.ax      = bIn.fb.ax
            b.azEncDif=(bIn.fb.encPos[0]- bIn.fb.encPos[1]) * $
                   VTX_CNV_AZ_ENC_TO_DEG
            b.tqAz=bIn.fb.measTorqAz*VTX_UNITS_TORQUE_AZ_TO_FTLBS
;            b.tqGr=bIn.fb.measTorqGr*VTX_UNITS_TORQUE_GR_TO_FTLBS
            b.tqGr=   tqscl*((bIn.fb.measTorqGr*atodToVolts)^tqexp)
            b.tqCh=   tqscl*((bIn.fb.measTorqCh*atodToVolts)^tqexp)
;            b.tqCh=bIn.fb.measTorqCh*VTX_UNITS_TORQUE_CH_TO_FTLBS
            b.plcInpStat=bIn.fb.plcInpStat
            b.plcOutStat=bIn.fb.plcOutStat
            b.posSetPnt =bIn.fb.posSetPnt*.0001
    b.velSetPnt[0] =bIn.fb.velSetPnt[0]*VTX_UNITS_VEL_SETPNT_DEGS_P_SEC_AZ
    b.velSetPnt[1:2] =bIn.fb.velSetPnt[1:2]*VTX_UNITS_VEL_SETPNT_DEGS_P_SEC_ZA
            b.bendingCompAz= bIn.fb.bendingCompAz*$
                VTX_UNITS_BENDING_COMP_AZ_TO_FTLBS
            b.torqueBiasGr = bIn.fb.torqueBiasGr*$
                VTX_UNITS_TORQUE_BIAS_GR_TO_FTLBS
            b.gravityCompGr= bIn.fb.gravityCompGr*$
                VTX_UNITS_GRAV_COMP_GR_TO_FTLBS
            b.torqueBiasCh = bIn.fb.torqueBiasCh*$
                VTX_UNITS_TORQUE_BIAS_CH_TO_FTLBS
            b.gravityCompCh= bIn.fb.gravityCompCh*$
                VTX_UNITS_GRAV_COMP_CH_TO_FTLBS
            b.posLim       = bIn.fb.posLim*.0001
            b.encCor       = bIn.fb.encCor*.0001
            b.tmoutNoHostSec= bIn.fb.tmoutNoHostSec
            b.tmElapsedSec  = bIn.fb.tmElapsedSec
            end
;
;       cb in , cb out
;
      11: begin
            b.time      =bIn.timeMs*.001D
            b.tmOffsetPT=bIn.tmOffsetPTms*.001
            b.freePTpos = bIn.freePTpos
            b.genStat=bIn.genStat
            b.stat[0]=bIn.statAz
            b.stat[1]=bIn.statGr
            b.stat[2]=bIn.statCh
            b.mode[0]=bIn.modeAz
            b.mode[1]=bIn.modeGr
            b.mode[2]=bIn.modeCh
            b.vel    =bIn.vel*.0001
            b.pos    =bIn.pos*.0001
            end 

;
;   fb inp, fboutput
;
        12: begin
            b.time    = bIn.timeMs*.001
            b.ax      = bIn.ax
            b.azEncDif=(bIn.encPos[0]- bIn.encPos[1]) * $
                    VTX_CNV_AZ_ENC_TO_DEG
            b.tqAz=bIn.measTorqAz*VTX_UNITS_TORQUE_AZ_TO_FTLBS
;           b.tqGr=bIn.measTorqGr*VTX_UNITS_TORQUE_GR_TO_FTLBS
            b.tqGr=   tqscl*((bIn.fb.measTorqGr*atodToVolts)^tqexp)
            b.tqCh=   tqscl*((bIn.fb.measTorqCh*atodToVolts)^tqexp)
;            b.tqCh=bIn.measTorqCh*VTX_UNITS_TORQUE_CH_TO_FTLBS
            b.plcInpStat=bIn.plcInpStat
            b.plcOutStat=bIn.plcOutStat
            b.posSetPnt =bIn.posSetPnt*.0001
            b.velSetPnt[0] =bIn.velSetPnt[0]*VTX_UNITS_VEL_SETPNT_DEGS_P_SEC_az
          b.velSetPnt[1:2]=bIn.velSetPnt[1:2]*VTX_UNITS_VEL_SETPNT_DEGS_P_SEC_za
            b.bendingCompAz= bIn.bendingCompAz*$
                VTX_UNITS_BENDING_COMP_AZ_TO_FTLBS
            b.torqueBiasGr = bIn.torqueBiasGr*$
                VTX_UNITS_TORQUE_BIAS_GR_TO_FTLBS
            b.gravityCompGr= bIn.gravityCompGr*$
                VTX_UNITS_GRAV_COMP_GR_TO_FTLBS
            b.torqueBiasCh = bIn.torqueBiasCh*$
                VTX_UNITS_TORQUE_BIAS_CH_TO_FTLBS
            b.gravityCompCh= bIn.gravityCompCh*$
                VTX_UNITS_GRAV_COMP_CH_TO_FTLBS
            b.posLim       = bIn.posLim*.0001
            b.encCor       = bIn.encCor*.0001
            b.tmoutNoHostSec= bIn.tmoutNoHostSec
            b.tmElapsedSec  = bIn.tmElapsedSec
            end
    
        endcase
        tmmv=(systime(1)-tma)+tmmv
    tm4=systime(1)
;lab=string(format='("alloc:",f6.3," read:",f6.3," mv:",f6.3," tot:",f6.3)',$
;           tm2-tm1,tm3-tm2,tm4-tm3,tm4-tm1)
;lab=string(format='("alloc:",f6.3," tot:",f6.3)',$
;           tm2-tm1,tm4-tm1)
    if keyword_set(dbg) then begin
lab=string(format='("alloc:",f6.3," read:",f6.3," mv:",f6.3," tot:",f6.3)',$
            tmalloc,tmrd,tmmv,tm4-tm1)
    print,lab
    endif
    return,n_elements(b)
end
