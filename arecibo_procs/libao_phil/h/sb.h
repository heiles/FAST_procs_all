;
; header files for sband transmitter
; 1. mainly accessing the log file
;
; Log file rec specs
;
	sbl_statBytes=47   ; 47 bytes of status bits
	sbl_numMeters=32   ; 32 meters 
	sbl_bytesTime=8   ; 8 bytes time  hh:mm:ss
	sbl_bytesDate=8    ; 8 bytes data  mm:dd:yy
;   80 +47=127 bytes
	sbl_recLen=sbl_statBytes+sbl_numMeters*2 + sbl_bytesTime +sbl_bytesDate
;
; meter definition (int) for file
;
a={sbl_imet,$
      magVK1:0,$ ; 
      magVK2:0,$ ;
      beamV:0,$
      magIK1:0,$
      magIK2:0,$
      bodyI:0,$
      filVK1:0,$
      filVK2:0,$
      filIK1:0,$
      filIK2:0,$
      colIK1:0,$
      colIK2:0,$
      vaciIK1:0,$
      vaciIK2:0,$
      sp1   :0,$
      sp2   :0,$
      wastFwdP:0,$
      fwdPK1:0,$
      reflPK1:0,$
      fwdPK2:0,$
      reflPK2:0,$
      wastReflP:0,$
      turnDlP  :0,$
      antFwdP  :0,$
      antReflP :0,$
      rfDrvPK1 :0,$
      rfDrvPK2 :0,$
      wastFlwRate:0,$
      deltaTemp:0,$
      colFlowK2:0,$
      exciterInpP:0,$
      sp3:0}
;
; meter definition (float) for user

a={sbl_fmet,$
      magVK1   :0.,$
      magVK2   :0.,$
      beamV    :0.,$
      magIK1   :0.,$
      magIK2   :0.,$
      bodyI    :0.,$
      filVK1   :0.,$
      filVK2   :0.,$
      filIK1   :0.,$
      filIK2   :0.,$
      colIK1   :0.,$
      colIK2   :0.,$
      vaciIK1  :0.,$
      vaciIK2  :0.,$
      sp1      :0.,$
      sp2      :0.,$
      wastFwdP :0.,$
      fwdPK1   :0.,$
      reflPK1  :0.,$
      fwdPK2   :0.,$
      reflPK2  :0.,$
      wastReflP:0.,$
      turnDlP  :0.,$
      antFwdP  :0.,$
      antReflP :0.,$
      rfDrvPK1 :0.,$
      rfDrvPK2 :0.,$
      wastFlwRate:0.,$
      deltaTemp:0.,$
      colFlowK2:0.,$
      exciterInpP:0.,$
      sp3:0.}
;
; input record
;
a={sbl_inprec,$
	  tm:bytarr(sbl_bytesTime),$
    date:bytarr(sbl_bytesDate),$
    stat:bytarr(sbl_statBytes),$
    met:{sbl_imet}}
;
a ={sbl_usrrec,$
    dayno:0D   , $ with fraction of day
    year :0    , $
    ltm  : ''  , $
    ldate:''   , $
    stat :bytarr(sbl_statBytes),$
    met  :{sbl_fmet}}
