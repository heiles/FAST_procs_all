;+
;tdlab - return labels for various tiedown bitmaps
;SYNTAX: lab=tdlab(type)
;ARGS  :
;       type    : string :
; 		    'prgstat': program status
;           'devstat': device status
;           'dils'   : digital input little star
;           'di1_2'  : digital uio 1 and 2 (18 entries)
;           'dols'   : digital out little star
;        'drv_fltstat': drive and fault status
;
;RETURNS:
;lab[n] : strarr    labels for each bit in the word
;
;DESCRIPTION:
;	This routine is normally called from tdplotsum(). It provides 
;the labels for all of the status bits.
;
;Warning:
; the order of the labels returned has been modified slightly. Some
;of the original status words had coded sets of bits rather than individual
;bits. This routine provides a decoded list. See tdplotsum to see 
;what you have to do with the binary numbers to used these labels.
;-

function tdlab,type
    
;/*
; * labels for stat values. 16 bits, by on/off.. if first char is ' ', then
; * first position is 1, 2nd position is zero 
; * not used
; * left is bit=1, right:bit=0
;*/

	case type of
		'prgstat': return,$
                   ['running ', $
                    'syncMst1', $
                    '        ', $
                    'ptSkipL ', $
                    'ptFutTim', $
                    'procTick', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ', $
                    'badMode ']
 
;  slvstat needs decoding
;;         'slvstat': return,$
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    'CurStop ','        ',2}, $
;;                    'curSlew ','CurTrk  ',2}, $
;;                    'CurEMnt ','CurMnt  ',2}, $
;;                    'FdBkLd1 ','FdBkLdAv',1}, $
;;                    'FdBkEnc ','FdBkLd2 ',1}, $
;;                    'ReqStop ','        ',2}, $
;;                    'ReqSlew ','ReqTrk  ',2}, $
;;                    'ReqEMnt ','ReqMnt  ',2}, $
;;					'LIoOk   ','-LIoOk  ',0}, $
;;                    'InUse   ','-InUse  ',0}}; 
;
; device stat where i've done some decoding..
;
	'devstat': return,$
                   ['SafteyO ', $
                    'AxisFlt ', $
                    'Drv1Flt ', $
                    '        ', $
                    'Warning ', $
                    'TrckFlt ', $
                    'Rebooted', $
                    'trAndDat', $ 
                    'PwrOn   ', $
                    'DrvEna  ', $
                    'RemCtrL ', $
                    'BrkOff  ', $
                    'ModeStop', $;mode stop,trk,slew,mnt
                    'ModeTrk ',$; dcd2
                    'ModeSlew',$; dcd2
                    'ModeMnt']  ; dcd2

; raw device stat
;;	'Rdevstat': return,$
;;                   ['SafteyO ', $
;;                    'AxisFlt ', $
;;                    'Drv1Flt ', $
;;                    '        ', $
;;                    'Warning ', $
;;                    'TrckFlt ', $
;;                    'dcd_fbkld', $ ; dcd1
;;                    'dcd_fbkld', $ ; dcd1
;;                    'PwrOn   ', $
;;                    'DrvEna  ', $
;;                    'RemCtrL ', $
;;                    'BrkOff  ', $
;;                    'dcd_Mode', $; dcd2
;;                    'dcd_Mode',$; dcd2
;;                    'Rebooted', $
;;                    'trAndDat']

	'dils': return,$
                  [ '-PhUvRly', $
                    '-EmgStop', $
                    '-Psr4Flt', $
                    'PcuCtrl ' ,$
                    'PcuDrvOn' ,$
                    '-DoorOpn' ,$
                    'SafetyC ' ,$
                    'Psr4MC  ' ,$
                    '-BlkOffSw',$
                    'Psr4MCR,' ,$ 
                    '-CRmEmgSt',$
                    '1ppsInt ' ,$
                    '-UpDLmR ' ,$
                    '-DwnDLmR' ,$
                    '-MampOFlt',$
                    '-MampFdBk']

; combine di1,di2 in di1_2 needs 18 bits
;;	'di1': return,$
;;                   ['-MampOTmp', $
;;                    '-MdrvOff ', $
;;                    '-MmotOTmp', $
;;                    '-UpFLim  ', $
;;                    '-DwnFLim ', $
;;                    '-UpDLim  ', $
;;                    '-DwnDLim ', $
;;                    '-WatchDog', $
;;                    '-PcuEmgSt', $
;;                    'RstMon   ', $
;;                    'PcuConn ' , $
;;                    'AlarmRly',  $
;;                    '-CrmEmgSR', $
;;                    'BrkOffMn', $
;;                    'BrkOffCm',  $
;;                    'PcuRst  ']
;; 
;;	'di2': return,$
;;                   ['CabOvTmp', $
;;                    'PwrOnM  ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ']
    'di1_2': return,$
	              ['-MampOTmp', $
                    '-MdrvOff ', $
                    '-MmotOTmp', $
                    '-UpFLim  ', $
                    '-DwnFLim ', $
                    '-UpDLim  ', $
                    '-DwnDLim ', $
                    '-WatchDog', $
                    '-PcuEmgSt', $
                    'RstMon   ', $
                    'PcuConn ' , $
                    'AlarmRly',  $
                    '-CrmEmgSR', $
                    'BrkOffMn',  $
                    'BrkOffCm',  $
                    'PcuRst  ', $
                    'CabOvTmp', $
                    'PwrOnM  ']

	'dols': return,$
                   ['Pwr2On  ', $
				    'DrvOnLt ', $
                    'FltOnLt ', $
                    'LimLt   ', $
                    'StrbLt  ', $
                    '        ', $
                    'Pwr1On  ', $
                    'Alarm   ', $
                    'BrkOffCm', $
                    'MampEna ', $
                    'MampRst ', $
                    'WatchDog', $
                    '        ', $
                    '        ', $
                    '        ', $
                    '        ']
;
; drvstat needs decoding
;  i combined drvstat and fltstat into drv_fltstat
; 
;;	'drvstat': return, $
;;                   ['dcd_enaDis',$ ;ignore 1st 2
;;                    'dcd_fltPwr',$ ; ditto
;;                    'FltCntOp', $
;;                    'OutptFlt', $
;;                    'DrvOTmp ', $
;;                    'MotOTmp ', $
;;                    'FldBFlt ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ' ]
 
;;	'fltstat': return,$
;;                   ['SafetyO ', $
;;                    '        ', $
;;                    'CmdSpdEr', $
;;                    'OvrSpd  ', $
;;                    'Drv1Fail', $
;;                    '        ', $
;;                    'PwrSFail', $
;;                    '        ', $
;;                    'BrkFail ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        ', $
;;                    '        '] 
;   combine drv,fault status, decode them
	'drv_fltstat': return, [$
                    'DrvDisab',$ ;ignore 1st 2
                    'DrvEna  ',$ ; ditto
                    'DrvPwred',$ ;ignore 1st 2
                    'DrvFlt  ',$ ; ditto
                    'FltCntOp', $
                    'OutptFlt', $
                    'DrvOTmp ', $
                    'MotOTmp ', $
                    'FldBFlt ', $

		            'SafetyO ', $
		            '        ', $
                    'CmdSpdEr', $
                    'OvrSpd  ', $
                    'Drv1Fail', $
                    'PwrSFail', $
                    'BrkFail ' ] 


;  
; pdata->val[TTT_GSIND_GEN_SAFETY])
;     xxxx     xxxx    xxxx    xxxx
;     statSaf, statLim, free, statAxis
;   each 4 bits is an index into one of the arrays
;;
;;LOCAL   char        *tieStatAxis[16]={
;;                              [          ' ',   
;;                    		     'PwrOff  ', $
;;                               'Stopped ', $
;;                    			 'AlarmOn ', $
;;                               'Driving0', $
;;                    			 'BrakeOff', $
;;                               'Moving  ', $
;;                                        ' ',$   
;;                                        ' ',$   
;;                                        ' ',$   
;;                                        ' ',$   
;;                                        ' ',$   
;;                                        ' ',$   
;;                                        ' ',$  
;;                                        ' ',$  
;;                                        ' ']    
;;
;;LOCAL   char         *tieStatLim[16]={
;;                             [  	   ' ', $
;;                    			'LimOk   ', $
;;                              'LimUp1lm ',$
;;                    			'LimUpflm', $
;;                              'LimDn1lm', $
;;                    			'LimDnflm', $
;;                                     ' ', $ 
;;                                     ' ', $ 
;;                                     ' ', $ 
;;                                     ' ', $ 
;;                                     ' ', $ 
;;                                     ' ', $ 
;;                                     ' ', $ 
;;                                     ' ', $ 
;;                                     ' ', $ 
;;                                     ' ']    
;;
;;LOCAL   char         *tieStatSafety [16]={
;;                             [  	   ' ', $
;;                    			'SafOk   ', $
;;                              'SafUpFlm', $
;;                    			'SafFlt  ', $
;;                              'SafInSrv', $
;;
;;                    			'SafDnFlm', $
;;                              'SafEmgSt', $
;;                              'SafEmgSC', $
;;                    			'SafEmgSP', $
;;
;;                              'SafPhUv ', $
;;                    			'SafDoRst', $
;;                              'SafDaFlt',   
;;                              'SafBLift',   
;;                                       ' ',   
;;                                       ' ',   
;;                                       ' ']    
            
        else : return,$
        ['prgstat','slvstat','devstat','dils','di1','di2','dols',$
        'drvstat','fltstat']
        endcase
    return,''
end
