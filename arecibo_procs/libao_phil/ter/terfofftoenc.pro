;+
;NAME:
;terfofftoenc - convert focus offset to encoder values
;SYNTAX: pnts=terfofftoenc(offx,offz,rot)
;ARGS:
;   offx : float  offset in x direction inches (focus coordinates).
;   offz : float  offset in z direction inches (focus coordinates).
;   rot  : float  rotation in degrees about the new P3 position. Only P5
;			      gets affected.
;RETURNS:
;	enc[3]:float  The encoder values for:Ver,Hor,Tilt in encoder units.
;DESCRIPTION:
;   Convert from offsets in focus coordinate system to encoder values. These
;values can then be sent to the motors to move the tertiary. The routine
;currently treats left, right (hor,ver) equally.
;	Before calling this routine you must call terfstateinit to initialize
;the common block terfocstate  with the various origins.
;	Any rotation requested i applied after the x,z offset.So the rotation
;will be about the "new" P3 position.
;
;NOTE:
; The point naming conventions are:
;P1 - vertical   fixed connection point
;P2 - horizontal fixed connection point
;P3 - connection points of hor,ver
;P4 - tilt fixed connection point
;P5 - tilt connection point at tertiary.
;-
function terfofftoenc,offx,offz,rot
;
;
    common terfocstate,terstate
	forward_function terfdistpp
;
;   apply offsets to p3,p5
   
    p3=terstate.origFoc[*,2]+[offx,0.,offz,0.]
    p5=terstate.origFoc[*,4]+[offx,0.,offz,0.]
;
; if rotation
; 1. apply to point p5 only. it's about the new p3
; 2. translate to p3
; 3. rotate by angle
; 4.
    if rot ne 0. then begin
        t3d,/reset
        t3d,translate=-p3[0:2]
        t3d,rotate=[0.,rot,0]
        t3d,translate=p3[0:2]
        p5=p5 ## !p.t
    endif
;
; compute the new distances
;
    dp13=terfdistpp(terstate.origFoc[*,0],terstate.origFoc[*,2])-$
         terfdistpp(terstate.origFoc[*,0],p3)
    dp23=terfdistpp(terstate.origFoc[*,1],terstate.origFoc[*,2])-$
         terfdistpp(terstate.origFoc[*,1],p3)
    dp45=terfdistpp(terstate.origFoc[*,3],terstate.origFoc[*,4])-$
         terfdistpp(terstate.origFoc[*,3],p5)
    return,[dp13*25400.+terstate.encPosOrig[0],$
            dp23*20000.+terstate.encPosOrig[1],$
            dp45*20000.+terstate.encPosOrig[2]]
end
