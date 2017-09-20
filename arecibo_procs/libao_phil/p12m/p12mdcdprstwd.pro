;+
;NAME:
;p12mdcdprstwd - decode the program status word
;SYNTAX:prStateD= p12mdcdprstwd(prStateU)
;ARGS: 
; prStateU[n]:long undecoded program state word 
;RETURNS:
;prStateD[n]: {p12mprstwd}  decoded bit field
;DESCRIPTION:
;	The p12mProg statwd is a bit field. This routine
;decodes each 32 bitfield into a struct holding the various
;fields
;-
function  p12mdcdprstwd,stWd
;
;  byte 0
;
	n=n_elements(stWd)
	stWdD=replicate({p12mPrStWd},n)

	stWdD.trPnt      =(stWd and 1) ne 0        ; b0
	stWdD.trPntPending=(stWd and 2) ne 0        ; b1
	stWdD.telState   =(ishft(stWd,-2) and 7)   ; b2-4
	stWdD.reqState   =(ishft(stWd,-5) and 7)   ; b5-7
	stWdD.waitNextState=(ishft(stWd,-8) and 7) ; b8-10
	stWdD.stChangeReq =(stWd and    '800'x) ne 0 ; b11
    stWdD.xfWaitTick  =(stWd and   '1000'x) ne 0 ; b12
    stWdD.xfWaitStop  =(stWd and   '2000'x) ne 0 ; b13
    stWdD.xfWaitReset =(stWd and   '4000'x) ne 0 ; b14
    stWdD.xfWaitReboot=(stWd and   '8000'x) ne 0 ; b15
    stWdD.p12mconactive=(stWd and '10000'x) ne 0 ; b16
    stWdD.onSrc       =(stWd and  '20000'x) ne 0 ; b17
	return,stWdD
end
