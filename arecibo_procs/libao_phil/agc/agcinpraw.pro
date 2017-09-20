;+
;NAME:
;agcinpraw - input raw agc records from a log file.
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
function agcinpraw,lun,b,npts,cb=cb,fb=fb,onekind=onekind,dbg=dbg
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
                b=replicate({cbfbInp},inppnts)
              end
        1   : begin
                b=replicate({cbfbInp},inppnts)
              end
        2   : begin
                b=replicate({cbfbInp},inppnts)
              end
        11  : begin
                b=replicate({cbInp},inppnts)
              end
        12  : begin
                b=replicate({fbInp},inppnts)
              end
     endcase    
     tm2=systime(1) 
     tmalloc=tm2-tm1 
     done=0
     is=0
        tma=systime(1)
        readu,lun,b
        if (b[0].cb.pos[1] gt 200000L) or (b[0].cb.pos[1] lt 10000L) then $
           b=swap_endian(b)

        tmrd=(systime(1)-tma)+tmrd
        tma=systime(1)
	 return,n_elements(b)
end
