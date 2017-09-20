;+
;prfpntErr - compute pointing error caused by pitch,roll, or focus motion.
;
; SYNTAX:
; 	prfpnterr,za,pitch,roll,focErrRadIn,azErr,zaErr
; ARGS:
;         za[n]: 	float.  zenith angle in degrees
;      pitch[n]: 	float.  pitch error in degrees.
;       roll[n]: 	float.  roll error in degrees.
;focErrRadIn[n]: 	float.  focus error radial inches.
;	   azErr[n]:	float. return azimuth error (great circle asecs) here.
;	   zaErr[n]:	float. return zenith angle error (great circle asecs) here.
;
;
;DESCRIPTION:
; 	Compute the pointing error to correct for pitch,roll, and focus motion. 
;   You should add  the returned value to the current pointing model.
;   You should pass in the actual pitch,roll, focus motion you are doing
;   (and not what you are correcting for). 
;   eg. if the dome was measured to have a pitch of .1 degrees, you 
;   would move it by -.1 degrees to correct for it. This routine
;   wants the -.1 degrees (the actual motion).
;
;   The sign convention:
;
;PITCH:
;	  Positive pitch moves the end of the azimuth arm vertically up as you
;     rotate about the center of the dome or platform (this is lynn bakers
;     convention).
;     
;     Suppose you are at za=10, pointing on source. Then pitch the dome
;     by .1. The ray striking the dish moves up, the position on the sky
;     moves away from zenith. With the pitch of .1 you need to move the
;     dome down hill to point at the source again.
;     PNTERR = - K*PITCH .. sign is opposite.
;ROLL:
;	  Positive roll rotates the dome/floor clockwise when looking up the 
;     azimuth arm from the center (lynn bakers convention). Suppose you are
;     at za=10, az=270 (source is setting directly in the east.). Roll by
;     .1 degrees. You are now looking north of east. To correct you must
;     look farther south. To do this, move the dome farther north 
;	  (or increase the azimuth angle);
;     ROLLERR =  K*ROLL .. sign is same direction as the roll
;FOCUS:
;	  Positive focus error moves you away from the primary (lynn bakers
;     convention). let gr be at za=10 deg and pointing on source. Draw the 
;	  ray from center of curvature to dish thru the dome. Moving up 1"
;     along this line still points at the center of curvature. The problem
;     is that our definition of za is the linear distance along the
;     elevation rail. We are now at a small distance (or smaller za). So
;     as you move in positive focus you must move down in za (linear distance)
;     to point at the object
;     FOCERR= -K * FOCUS
;SUMMARY;
;  PITCHERR, FOCERR = - DIRECTION MOVED
;  RollErr            + DIRECTION MOVED
;
; history:
; 11may00 - was include temperature motion in errors. not correct since
;           the temperature motion brings us back to where the model
;           was made. You might want to include a term that takes 
;		    into account hitting one of the tiedown limits..
;
; 30may00 - recomputed pitch,roll, from matrix computation.
;-
pro prfPntErr,za,pitch,roll,focErrRadIn,azErr,zaErr
;
; focus: fR radial focus error
;        fV veritcal focus error.. this is the hypotenuse. we overshoot
;           to get back on the paraxial surface, then the pointing error
;           brings us back down..
;		 R : radius 435 feet
;
;      fV=fR/cos(za)
;
;     dza= sin(za)*fV /R = tan(za)* fR / R 
;     
;   fit to pntErr/pitch this include pulling back into focus
;   this is the angle we moved in za because we moved thru a pitch angle
;   specified. To correct for this, you would move by the negative.  
;
	cfP0=0.13975462
    cfP1=-0.00021076865
    cfP2=-0.00015472838
;
;   fit to rollErr/rol  same as above. we move this direction in az.
;
    cfR0=-0.13948981
    cfR1=2.7843142e-05
    cfR2=0.00014963878
;
	radOpt=435.
	zaRd=za*!dtor
;
;   computed focus error. we measured no change in pnt do to focus..
;
	zaFocErrAsecs=   -tan(zaRd)* focErrRadIn/(radOpt*12.) * $
					  !radeg * 3600.
;
;   pitch  error from cmpppnterr.pro.. This assumes that you 
;   pitch the dome and then pull it back into focus. - sign since we
;   are going to correct for this error. 
;
;   pntErr/pitch = cfP0 + cfP1*za + cfP2*za^2
;
	zaPitchErrAsecs= -((cfP0 + za*(cfP1 + za*cfP2))* pitch*3600.)
;
;   the roll
;	pntErr/roll  = cfR0 + cfR1*za + cfR2*za^2
;
	azRollErrAsecs= -(cfR0 + za*(cfR1 + za*cfR2))* roll*3600.
;
;
	azErr= azRollErrAsecs
;;  	zaErr= zaFocErrAsecs + zaPitchErrAsecs 
  	zaErr= zaPitchErrAsecs 
	return
end
