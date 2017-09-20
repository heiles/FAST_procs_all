pro getrcvr, b_0, rcvr_name, rcvrn, nocorrcal, circular, $
	mmprocname=mmprocname

;+
;PURPOSE: defines receiver parameters: receiver name, receiver number,
;whether or not it has a correlated cal, whether or not it is native
;circular. 

;CALLING SEQUENCE:
;	GETRCVR, b_0, rcvr_name, rcvrn, nocorrcal, circular

;INPUTS:
;	B_0, the structure variable from CORGET (SEE BELOW!!!).
;	RCVR_NAME, the receiver name (can also be an output; SEE BELOW)
;	RCVRN, the receiver number (can also be an output; SEE BELOW)

;OUTPUTS:
;	RCVR_NAME, the receiver name (can also be an output; see below)
;	RCVRN, the receiver number (can also be an output; see below)
;	NOCORRCAL, equal to 1 if the receiver does not have a correlated
;cal, 0 if it does have a correlated cal
;	CIRCULAR, equal to 1 if native circular, 0 if native linear.

;OPTIONAL OUTPUT: MMPROCNAME, the name of the mm_corr procedure for this
;rcvr.

;HOW THIS PROCEDURE WORKS (yes, it's a kluge!!!):

;	If you call this with B_0 being a structure, then it determines the
;rcvr_name and rcvrn from the structure header.

;	If you call it with B_0 NOT being a structure, then:

;	1. If RCVRN is defined, then it uses RCVRN as input and provides
;the other variables as outputs.

;	2. If RCVRN is NOT defined, then it uses RCVR_NAME as input and
;provides the other variables as outputs.

;MODIFICATION HISTORY:
;	06JUN01: changed the 610 procedure name to use the results from
;the 06jun01 determination for the CH line frequency. 
;   20sep01: pjp. added mmp_sbw_20sep01_nocalcor. all params set to 0 to
;			      bootstrap the processing.
;   22oct01: pjp. added mmp_327_22oct01_nocalcor. all params set to 0 to
;			      bootstrap the processing.
;   19dec01: pjp. added mmp_xb_19dec01_nocalcor. all params set to 0 to
;			      bootstrap the processing.
;   08apr02: pjp. added mmp_sbh_08apr02_nocalcor. all params set to 0 to
;   14jul04: pjp. added alfa rcvr as rcvnum 17
;                 added dummy mmp_alfa_14jul04_nocalcor. (
;   15oct12: pjp  gr430 circular_[1] = 0 .. but 430Dome is circular. switched
;                 to circular[1]_[1]=1. This will change the mm4 processing
;                 . All mm4 processing needs to be rerun .
;   13may13: pjp  added entry for test receiver. lincoln labs test ant
;                 just to get pointing,beamwidth, sefd.... has no cal
;-

IF (n_tags( b_0) ne 0) THEN BEGIN
rcvrn= iflohrfnum(b_0.b1.h.iflo)
if ( pnthgrmaster( b_0.b1.h.pnt) eq 0) then rcvrn=100
ENDIF 

rcvrnum = [1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,51,61,$  
          100,  101, 107,  121,17]


norcvr = 'NO RECEIVER HAS THIS NUMBER!!'

; note 1 --> true. 0 --> false  .. -1 also --> false (usually not present)
nocorrcal_= [    -1,      0,    0,    -1,      0,    1,    0,      0, $ 
	  0,      0,      0,  0,    -1,    -1,     -1,    -1,   $
	   -1,      -1,       1,       -1, 0 ,     -1   , 0 ]

circular_= [    -1,       1,    0,    -1,      0,    0,    0,      0, $
	  0,      0,      1,  1,    -1,    -1,     -1,    -1,   $
	   -1,      -1,       1,       -1,  0,     -1   ,  0 ]

rcvrname_ = ['327' ,'430' ,'800' ,norcvr,'lbw' ,'test' ,'sbw','sbh', $
        'cb' ,'cbh','xb','sbn' ,norcvr,norcvr,norcvr,'noise' , $
	'lbwifw' ,'lbnifw' ,'430ch' ,'chlb' ,'ao19ao','sb750' ,'alfa']
 
;mmprocnames= ['', 'mmp_430_08sep00_nocalcorr', 'mmp_610_08sep00', $		
mmprocnames= ['mmp_327_22oct01_nocalcor', 'mmp_430_08sep00_nocalcorr', $    ;1,2,
  'mmp_800_18may09_nocalcorr','', 'mmp_lbw_10jul04_nocalcorr', $                    ;3,4,5
  'mmp_test_13may13_nocalcorr','mmp_sbw_20sep01_nocalcorr',$                 ;6,7
   'mmp_sbh_08apr02_nocalcorr', $  ;end of line 1                           ;8
  'mmp_cb_08sep00_nocalcorr', 'mmp_cbh_14feb04_nocalcorr',$               ;9,10
  'mmp_xb_19dec01_nocalcorr', 'mmp_sbn_08sep00',$                        ;11,12
  '', '','','', $ ;end of line 2                                   ;13,14,15,16
'', '', 'mmp_430ch_08sep00', '',$
	'mmp_ao19ao_25jul13_nocalcorr',$
	'','mmp_alfa_14jul04_nocalcorr'] ;51,61,100,101,121,17

;rcvr_name = norcvr

IF (n_elements( rcvrn) ne 0) then BEGIN
	indx = where( rcvrn eq rcvrnum, count)
	rcvr_name = rcvrname_[ indx[ 0]] 
ENDIF ELSE BEGIN
indx= where( rcvr_name eq rcvrname_, count)
rcvrn = rcvrnum[ indx[0]]
ENDELSE

if (count ne 1) then return

nocorrcal = nocorrcal_[ indx[ 0]]
circular= circular_[ indx[ 0]]
mmprocname= mmprocnames[ indx[0]]

;stop
;return, rcvr_name
end
