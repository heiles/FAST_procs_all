pro gbtrcvr, rcvrname, rcvrn, nocorrcal, circular, $
	mmprocname=mmprocname

;+
; NAME:
;       GBTRCVR
;
; PURPOSE: 
;       Given receiver name, defines receiver parameters: receiver number,
;       whether or not it has a correlated cal, whether or not it is native
;       circular.
;
; CALLING SEQUENCE:
;	GBTRCVR, rcvrname, rcvrn, nocorrcal, circular
;	         [, mmprocname=mmprocname]
;
; INPUTS:
;	RCVRNAME: the receiver name (can also be an output; SEE BELOW)
;
; OUTPUTS:
;       RCVRN: the receiver number (can also be an output; see below)
;
;       NOCORRCAL: equal to 1 if the receiver does not have a correlated
;                  cal, 0 if it does have a correlated cal
;
;       CIRCULAR: equal to 1 if native circular, 0 if native linear.
;
; KEYWORDS:
;       MMPROCNAME = the name of the default mm_corr procedure for this
;                    rcvr.
;
; MODIFICATION HISTORY:
;       TR Jun 13 2008: Updated to use new default Mueller routines.
;-

; L BAND...
IF ( rcvrname eq 'Rcvr1_2') THEN BEGIN
   rcvrn= 1
   ;mmprocname= 'Rcvr1_2__13dec02'
   ;mmprocname= 'Rcvr1_2__11jan03'
   mmprocname= 'rcvr1_2__default'
   nocorrcal=  0
   circular=  0
   return
ENDIF

; S BAND....
IF ( rcvrname eq 'Rcvr2_3') THEN BEGIN
   rcvrn= 2
   mmprocname= ''
   nocorrcal=  0
   circular=  0
   return
ENDIF

; C BAND...
IF ( rcvrname eq 'Rcvr4_6') THEN BEGIN
   rcvrn= 3
   ;mmprocname= 'Rcvr4_6__06jan03'
   mmprocname= ''
   nocorrcal=  0
   circular=  0
   return
ENDIF

; X BAND...
IF ( rcvrname eq 'Rcvr8_10') THEN BEGIN
   rcvrn= 4
   ;mmprocname= 'Rcvr8_10__06jan03'
   mmprocname= ''
   nocorrcal=  0
   circular=  1
   return
ENDIF

; Ku BAND...
; Tom observed HVCs...
IF ( rcvrname eq 'Rcvr12_18') THEN BEGIN
   rcvrn= 5
   mmprocname= ''
   nocorrcal=  0 ; there is no HIGH cal for Ku band.
   circular=  1
   return
ENDIF

; PF_1 Receiver...
; We observed DLAs with Art Wolfe...
IF ( rcvrname eq 'RcvrPF_1') THEN BEGIN
   rcvrn= 6
   mmprocname= 'RcvrPF_1__07apr'
   nocorrcal=  0
   circular=  0
   return
ENDIF

end ; gbtrcvr
