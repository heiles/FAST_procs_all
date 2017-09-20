;+
;NAME:
;terfstateinit - initialize tertiary focus state common block.
;SYNTAX: terfstateinit,dcToFocDeg=dcToFocDeg,encPosOrig=encPosOrig,origDc=origDc
;ARGS:
;	none
;KEYWORDS:
;	dcToFocDeg: float angle in degrees to go from dome centerline coordinate
;			          system to focus coordinate system. default 18 deg.
;encPosOrig[3]: float encoder positions for the focus origin in encoder
;					  units (hor,ver,tilt). They left and right sides are
;				      treated equally. The defaults are xxx.
;  origDc[4,5]: float origin of focus position in dome centerline coodinates.
;					  positions are P1,P2,P3,P4,P5. Each vector is dimension
;					  4:x,y,z,translation..
;RETURNS:
;   			loads values int terstate structure in terfocstate common
;			    block.
;DESCRIPTION:
;   The tertiary focus routines use the information in terstate (located in
;terfocstate common block) to do the movements of the tertiary. The structure
;contains:
;a={terState,origDc: fltarr(4,5) ,$;con points origin in dome centerline
;            origFoc:fltarr(4,5) ,$;con points origin in focus
;            dcToFocM:fltarr(4,4),$;
;            focToDcM:fltarr(4,4),$;
;            encPosOrig: fltarr(3),$;V,H,T .. use left..
;            dcToFocDeg: 0.   ,$; Dc to Focus z axis..
;            dP12         : 0.    ,$; fixed distance p12
;            dP35         : 0.    ,$; fixed distance p35
;            dP14         : 0.    ,$; fixed distance p14
;            dP24         : 0.    } ; fixed distance p24
;
;This routine should be called before using any of the terfxxxx routines.
;You need to call @terinit before calling this routine.
;The routines currently assume that the left and right values are the same.
;
;NOTE:
; The point naming conventions are:
;P1 - vertical   fixed connection point
;P2 - horizontal fixed connection point
;P3 - connection points of hor,ver
;P4 - tilt fixed connection point
;P5 - tilt connection point at tertiary.
;-
pro terfstateinit,dcToFocDeg=dcToFocDeg,encPosOrig=encPosOrig,origDc=origDc
    common terfocstate,terstate
   
     terstate={terState}
     y=0.

	 terparms,dcorig=dcorig,encorig=encorig,dctofocdeg=dctofocdegLoc
     terstate.dcToFocDeg=dctofocdegLoc
     terstate.encPosOrig=[encorig[0],encorig[2],encorig[4]] ; use left values
     terstate.origDc=dcorig[*,0:4];  use left values.
     if n_elements(dcToFocDeg) ne 0 then terstate.dcToFocDeg= dcToFocDeg
     if n_elements(encPosOrig) ne 0 then terstate.encPosOrig=encPosOrig
     if n_elements(origDc) ne 0 then terstate.origDc[0:2,*]=origDc
;
; matrix dome centerline to focus
; 1. translate to p3 as origin (this is the focus of the tertiary?
; 2. rotate by - dcToFocAngRd
;
    t3d,/reset
    t3d,translate=-terstate.origDc[0:2,2]   ; p3 now the origin
    t3d,rotate=[0.,-terState.dcToFocDeg,0.]
    terstate.dcToFocM=!p.t
;
; The inverse matrix, focus to dome centerline
;
    t3d,/reset
    t3d,rotate=[0.,terState.dcToFocDeg,0.]
    t3d,translate=terstate.origDc[0:2,2]     ; back to dome centerline
    terstate.focToDcM=!p.t
;
;   compute the fixed distPPs
;
    terstate.dP12=terfdistpp(terstate.origDc[*,0],terstate.origDc[*,1])
    terstate.dP35=terfdistpp(terstate.origDc[*,2],terstate.origDc[*,4])
    terstate.dP14=terfdistpp(terstate.origDc[*,0],terstate.origDc[*,3])
    terstate.dP24=terfdistpp(terstate.origDc[*,1],terstate.origDc[*,3])
;
;   origin of connection points in focus
;
    terstate.origFoc=terfmultmpnts(terstate.dcToFocM,terstate.origDc)
    return
end
