;+
;NAME:
;svXftoDesign - set transformation from measured pnts to design system.
;
;SYNTAX: svXftoDesign,scale,rotate,offset,noclear=noclear 
;
;ARGS:
;	scale	 : double  Scale value from netrology logfile output.
;	rotate[3]: double  x,y,z rotation angles in degrees from logfile output.
;	offset[3]: double  x,y,z displacements from logfile.
;KEYWORDS:
;	noclear  : int     if set then don't clear the matrix before
;					   adding these elements. allows for concatenated
;					   transformations.
;RETURNS:
;	Sets the !p.t 4x4 matrix in idl.
;
;DESCRIPTION:
;	The sokkia netrology software computes a transformation matrix from
;the active measuring coordinate system back into the system coordinates
;(usually the design coordinates) when you hit transform/compute (see 9-5
;of the sokkia software manual). This transformation will map the measured 
;object coordinate system back into the system coordinates.
;
;EXAMPLE:
;Assume sokkia log file had:
;Transform System
;Parameters:
;Scale              1.000013547
;X Rotation            -0.00678
;Y Rotation             0.24671
;Z Rotation             0.00385
;X                      -4.2402
;Y                      -0.0988
;Z                       0.6748
;RMS of Residuals         0.0142
;Residuals:
;L1B1                  -0.0038       -0.0056        0.0184
;						0.0000        0.0000        0.0000
;
;Let the theoretical (design file) and measured coordinates be:
;B1  : -169.5300      135.4400     -419.4438 design file
;L1B1: -167.1003      135.4818     -419.4318 measured point
;
;scale=1.000013547
;rot=[-0.00678,0.24671,0.00385]
;off=[ -4.2402,-0.0988,0.6748]
; 
;svXftoDesign,scale,rot,off
;
;You can now use !p.t to transform from the measured to the design 
;coordinates. You must use 4 vectors (with the last element == 1) 
;
;vb1  =[b1  ,1.]
;vl1b1=[l1b1,1.]
;vb1cmp= (!p.t ## vl1b1)
;print,vb1 - vb1cmp
;--> -0.00387573  -0.00558472    0.0184937      0.00000
; this will equal the residuals from the fit.
;
; You can concatanate multiple trasnformations by using the /noclear
;keyword after the first call.
;-
pro svXftoDesign,scale,rot,offset,noclear=noclear

	if not keyword_set(noclear) then t3d,/reset
	t3d,rotate=-rot
	t3d,scale=[scale,scale,scale]
	t3d,translate=offset
	return
end
