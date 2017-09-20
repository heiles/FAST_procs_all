;
; struct holding the data
;
  a={alfaMon,$
	   tmA: '',$		; yyyymmddhhmmss in ascii
       jd :   0D,$
       locRem  : 0 ,$   ;  1 - local mode, 0 - remote control
       bias_stat:intarr(2,7),$; 0 off, 1 on}
       vd       :fltarr(2,7,3),$; [pol],[beam],[stage1,2,3]
       Id       :fltarr(2,7,3),$; ditto
       vg       :fltarr(2,7,3),$; ditto
       t20      :fltarr(4),$  
       t70      :fltarr(4),$
       V32P     :0.,$
       V20P     :0.,$
       V20N     :0.,$
       V9P      :0.,$
       V15P     :fltarr(6),$
       V15N     :fltarr(4),$
       V5P      :fltarr(2),$
       calCtl   : 0,$;
       nseLev   :0 ,$;
       nseDiodeT:0.,$;
       vacStat  :0,$;
       vacLev   :0.}
