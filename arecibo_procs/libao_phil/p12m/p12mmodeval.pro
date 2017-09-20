;+
;NAME:
;p1mmodeval - evaluate the model errors at the requested az,el
;
;SYNTAX : p12mmodeval,az,el,modelData,azErrAsec,elErrAsec,$
;                     refCorD=refCorD
;
; ARGS    : 
;   az[]  :     azimuth positions degrees.
;   el[]  :     elevation angle positions degrees.
;   modelData: {modelData} loaded by p12mmodinp. 
; Returns:
;   azErrAsec:  [] return greate circle az error in arc seconds.
;   elErrAsec:  [] return  el error in arc seconds.
;                  This includes the refraction correction.
;   refCorD:    [] elR -El in deg. This is already included in elErrAsec
;                  i've included it here just for reference.
;
; DESCRIPTION:
;   Evaluate the model at the specified az, el locations. 
; Use the model data in the structure modelData
; (this structure can be loaded via p12mmodinp).
;
; Return the model errors in great circle arc seconds evaluated at the
; az,el. The errors are defined such that:
; 1. let azComp,elComp be the computed az, el to move the telescope to.
; 2. compute azE, elE from the model.
; 3. azTouse = azComp + AzE*asecToRad
;    ElTouse = ElComp + ElE*asecToRad
; 4. this includes the refraction correction to el
;-
pro p12mmodeval,azInp,elInp,mI,azErrAsec,elErrAsec,refCorD=refCorD
;
;  some constants..
;
    ddtor=!dpi/180.d    
    minEl=5.8D;
    maxEl=88d;
;	 el 0,360 positive. then -90 to 90
    el=elInp mod 360d
	az=azInp;
	ii=where(el lt 0d,cnt)
	if cnt gt 0 then el[ii]+=360d
	ii= where (el gt 90d,cnt)
	if cnt gt 0 then begin
		el[ii]-=360d
		ii=where(el lt -90d,cnt)
		if cnt gt 0 then begin
			el[ii]+=180d
			az[ii]+=180d
		endif
	endif
	az=az mod 360d
	ii=where(az lt 0d,cnt)
	if cnt gt 0  then az[ii]+=360d

;	 az is now 0..360. make el within limits

    ii=where(el lt minel,cnt)
	if cnt gt 0 then el[ii]=minEl
    ii=where(el gt maxel,cnt)
	if cnt gt 0 then el[ii]=maxEl
    azErrAsecs=0.d
    elErrAsecs=0.d
	case mI.type of
	 	1: begin
    	  ; el limit to 88 --> tan(el) 1/cos(el) does not blow up
    	  ; refracted elevation
    	  elR=el + (.0019279D + $
             1.02D/(tan(ddtor*(el + (10.3D/(el+5.1D))))))/60d;
    	  cosAz=cos(ddtor*az);
    	  sinAz=sin(ddtor*az);
    	  cosEl=cos(ddtor*elR);
    	  sinEl=sin(ddtor*elR);
    	  cotEl=cosEl/sinEl;
		  refCorD=elR - El
	      azErrAsec=(mI.coefC1[1-1] +$
                     mI.coefC1[2-1]*cosEl  +$
                     mI.coefC1[3-1]*sinEl  +$
                     mI.coefC1[4-1]*sinEl*cosAz  +$
                     mI.coefC1[5-1]*sinEl*sinAz)
          elErrAsec=(-mI.coefC1[4-1]*sinAz + $
                    mI.coefC1[5-1]*cosAz + $
                    mI.coefC1[7-1]       +$
                    mI.coefC1[8-1]*cosEl +$
                    mI.coefC1[9-1]*cotEl)  + (refCorD)*3600d
		  end
     else: begin
           message,'model ' + mI.type + ' not yet supported'
           end
    endcase
	return
end
