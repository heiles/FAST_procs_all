;+
;agclab - return labels for various vertex bitmaps
;SYNTAX: lab=agclab(type)
;ARGS  :
;       type    : string :cbgstat cblk general status
;                         cbastat cblk axis status
;                         cbamode cblk axis mode
function agcLab,type
    
        case type of  
            'cbgstat' : return,$
            [   'EmgOff   ', $
                'SrnOff   ', $
                'LimOvr   ', $
                'PCUComFlt', $
                '581ComFlt', $
                'AzBending', $
                'EFlg     ', $
                'MainOUVol', $
                'Drv1CabOT', $
                'Drv2CabOT', $
                'Drv3CabOT', $
                '24VPwrFlt', $
                'BrkPwrFlt', $
                'PLCPwrFlt', $
                'DrvPwrOff', $
                'CabOpen  ']  
            'cbastat': return,$
              ['ServoFail', $
                'Enc1Flt ', $
                'Enc2FltAz', $
                'DrvEnable', $
                'MotnFail ', $
                'MotorOT  ', $
                'EncFail  ', $
                'BrkFail  ', $
                'NegLim   ', $
                'NegPLim  ', $
                'OprRng   ', $
                'PosPLim  ', $
                'PosLim   ', $
                'EmgLim   ', $
                '{AzStpCC}', $
                'BrkRel   ']
            'cbamode'   : return,$
               ['RateMode ', $
                'PosMode  ', $
                'StowMode ', $
                'ProgTMode', $
                'SpareB4  ', $
                'SpareB5  ', $
                'SpareB6  ', $
                'SpareB7  ', $
                'PCUCtrl  ', $
                'LCUCtrl  ', $
                'OCUCtrl  ', $
                'VMECtrl  ', $
                'SpareB12 ', $
                'PCUNotAct', $
                'LocalOnly', $
                'spareB15 ']
            'q8'    : return,$
     ['DCSAz: 421.0 #1 / K1 (d_n1)',$
     'DCSAz: 421.0 #1 / K2 (d_nA)',$
     'DCSAz: 421.0 #1 / K3 (d_n4)',$
     'DCSAz: 421.0 #1 / K4 (-d_nA)',$
     'DCSAz: 421.0 #2 / K1 (d_n5)',$
     'DCSAz: 421.0 #2 / K2 (d_nB)',$
     'DCSAz: 421.0 #2 / K3 (d_n8)',$
     'DCSAz: 421.0 #2 / K4 (-d_nB)']
            'q9'    : return,$
     ['DCSAz: 421.0 #3 / K1 (tot d_n M11/12)',$
     'DCSAz: 421.0 #3 / K2 (torque bias 11/12',$
     'DCSAz: 421.0 #3 / K3 (tot d_n M41/42)',$
     'DCSAz: 421.0 #3 / K4 (torque bias 41/42',$
     'DCSAz: 421.0 #4 / K1 (tot d_n M51/52)',$
     'DCSAz: 421.0 #4 / K2 (torque bias 51/52',$
     'DCSAz: 421.0 #4 / K3 (tot d_n M81/82)',$
     'DCSAz: 421.0 #4 / K4 (torque bias 81/82']

            'q10'   : return,$
    ['DCS: load setpnt Az 1 ',$
    'DCS: load setpnt Az 2 ',$
    'DCS: accelramp Az fast ',$
    'DCS: torque bias Az on ',$
    'DCS: sum_n cntrlr Az on ',$
    'DCS: delta_n cntrler Az on ',$
    'DCS: I-portion n-loop Az on ',$
    '..................... ']
        'fbeqstat'  : return,$
            [   'PwrS1Flt ', $
                'PwrS2Flt ', $
                'MnCont1On', $
                'MnCont2On', $
                'DCBus1Flt', $
                'DCBus2Flt', $
                'BrkG1Fuse', $
                'BrkG2Fuse', $
                'spareB8  ', $
                'spareB9  ', $
                'spareB10 ', $
                'spareB11 ', $
                'locDisabl', $
                'spareB13 ', $
                'spareB14 ', $
                'pdlm/col ']
        'fbampstataz'  : return,$
                ['Amp11Flt ', $
                'Amp11NRdy', $
                'Amp12Flt ', $
                'Amp12NRdy', $
                'Amp51Flt ', $
                'Amp51NRdy', $
                'Amp52Flt ', $
                'Amp52NRdy', $
                'Amp41Flt ', $
                'Amp41NRdy', $
                'Amp42Flt ', $
                'Amp42NRdy', $
                'Amp81Flt ', $
                'Amp81NRdy', $
                'Amp82Flt ', $
                'Amp82NRdy']
        'fbampstatgr'  : return,$
             [  'Amp11Flt ', $
                'Amp11NRdy', $
                'Amp12Flt ', $
                'Amp12NRdy', $
                'Amp21Flt ', $
                'Amp21NRdy', $
                'Amp22Flt ', $
                'Amp22NRdy', $
                'Amp31Flt ', $
                'Amp31NRdy', $
                'Amp32Flt ', $
                'Amp32NRdy', $
                'Amp41Flt ', $
                'Amp41NRdy', $
                'Amp42Flt ', $
                'Amp42NRdy']
        'fbmotstatch'  : return,$
            [   "Amp1 Flt ", $
                "Amp1 NRdy", $
                "Amp2 Flt ", $
                "Amp2 NRdy"]


        'fbmotstataz'  : return,$
               ['OvrTmpM11', $
                'OvrTmpM12', $
                'OvrTmpM51', $
                'OvrTmpM52', $
                'OvrTmpM41', $
                'OvrTmpM42', $
                'OvrTmpM81', $
                'OvrTmpM82']
        'fbmotstatgr'  : return,$
            [   'OvrTmpM11', $
                'OvrTmpM12', $
                'OvrTmpM21', $
                'OvrTmpM22', $
                'OvrTmpM31', $
                'OvrTmpM32', $
                'OvrTmpM41', $
                'OvrTmpM42']
        'fbmotstatch'  : return,$
            [   'OvrTmpM1 ', $
                'OvrTmpM2 ']


        'fbmotauxstat'  : return,$
                ['mot/Grp1 ', $
                'mot/Grp2 ', $
                'mot3     ', $
                'mot4     ', $
                'mot5     ', $
                'mot6     ', $
                'mot7     ', $
                'mot8     ', $
                'bio      ', $
                'rGenWrn  ', $
                'rGenFB1  ', $
                'rGenFB2  ', $
                'rGenFB3  ', $
                'rGenFB4  ', $
                'rGenFB5  ', $
                'rGenFB6  ']

        

            
        else : return,$
['cbgstat,cbastat,cbamode,fbeqstat,fbauxstat,q8,q9,q10' ,$
 'fbampstat{az,gr,ch},fbmotstat{az,gr,ch}']
        endcase
    return,''
end
